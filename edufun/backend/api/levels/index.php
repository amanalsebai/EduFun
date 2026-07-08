<?php
// مراحل اللعبة (Levels).
//   GET  /levels/?game_code=X&child_id=N  → قائمة المراحل + حالة كل مرحلة للطفل
//   POST /levels/  body:{child_id, game_code, level_number, stars}
//        → إكمال مرحلة (يتحقق من الفتح، يزيد النجوم بالفرق فقط، ويحدّث ملخّص اللعبة)
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/unlocks.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {

    // ─────────── قائمة مراحل لعبة مع حالة الطفل ───────────
    case 'GET':
        $code    = $_GET['game_code'] ?? '';
        $childId = isset($_GET['child_id']) ? (int) $_GET['child_id'] : 0;
        if ($code === '') badRequest('game_code مطلوب');

        $st = $db->prepare(
            "SELECT level_number, title_ar, stars_reward, config
             FROM game_levels WHERE game_code = ? AND is_active = 1
             ORDER BY level_number ASC"
        );
        $st->execute([$code]);
        $levels = $st->fetchAll();

        // حالة إكمال الطفل لكل مرحلة
        $done = [];
        if ($childId > 0) {
            $ps = $db->prepare(
                "SELECT level_number, stars_earned FROM level_progress
                 WHERE child_id = ? AND game_code = ? AND completed = 1"
            );
            $ps->execute([$childId, $code]);
            foreach ($ps->fetchAll() as $r) {
                $done[(int) $r['level_number']] = (int) $r['stars_earned'];
            }
        }

        $ageUnlocked = $childId > 0
            ? is_age_unlocked($db, $childId, game_min_age($db, $code))
            : true;

        // المرحلة مفتوحة إذا كانت الأولى أو أُكملت التي قبلها.
        $out = [];
        $prevCompleted = true;
        foreach ($levels as $lv) {
            $num       = (int) $lv['level_number'];
            $completed = isset($done[$num]);
            $out[] = [
                'level_number' => $num,
                'title_ar'     => $lv['title_ar'],
                'stars_reward' => (int) $lv['stars_reward'],
                'config'       => $lv['config'],
                'completed'    => $completed,
                'stars_earned' => $completed ? $done[$num] : 0,
                'unlocked'     => $ageUnlocked && $prevCompleted,
            ];
            $prevCompleted = $completed; // تسلسل الفتح
        }

        ok([
            'game_code'    => $code,
            'age_unlocked' => $ageUnlocked,
            'levels'       => $out,
        ]);
        break;

    // ─────────── إكمال مرحلة ───────────
    case 'POST':
        $b = body();
        if (empty($b['child_id']) || empty($b['game_code']) || !isset($b['level_number'])) {
            badRequest('child_id و game_code و level_number مطلوبة');
        }
        $childId = (int) $b['child_id'];
        $code    = $b['game_code'];
        $num     = (int) $b['level_number'];
        $stars   = (int) ($b['stars'] ?? 0);

        // 1) العمر مفتوح؟ (منع تجاوز القفل من العميل)
        if (!is_age_unlocked($db, $childId, game_min_age($db, $code))) {
            send(false, null, 'هذا المستوى مقفل — أكمِل مستواك الحالي أولاً', 403);
        }

        // 2) المرحلة موجودة؟
        $ls = $db->prepare(
            "SELECT stars_reward FROM game_levels
             WHERE game_code = ? AND level_number = ? AND is_active = 1"
        );
        $ls->execute([$code, $num]);
        $lvl = $ls->fetch();
        if (!$lvl) notFound('المرحلة غير موجودة');

        // 3) المرحلة مفتوحة؟ (الأولى أو أُكملت السابقة)
        if ($num > 1) {
            $pc = $db->prepare(
                "SELECT completed FROM level_progress
                 WHERE child_id = ? AND game_code = ? AND level_number = ?"
            );
            $pc->execute([$childId, $code, $num - 1]);
            $prev = $pc->fetch();
            if (!$prev || (int) $prev['completed'] !== 1) {
                send(false, null, 'أكمِل المرحلة السابقة أولاً', 403);
            }
        }

        // النجوم المطلوبة: المرسلة أو مكافأة المرحلة الافتراضية.
        if ($stars <= 0) $stars = (int) $lvl['stars_reward'];

        $db->beginTransaction();
        try {
            // كم نجمة سُجّلت سابقاً على هذه المرحلة؟ (نزيد بالفرق فقط)
            $chk = $db->prepare(
                "SELECT stars_earned FROM level_progress
                 WHERE child_id = ? AND game_code = ? AND level_number = ?"
            );
            $chk->execute([$childId, $code, $num]);
            $prevRow   = $chk->fetch();
            $prevStars = $prevRow ? (int) $prevRow['stars_earned'] : 0;
            $delta     = max(0, $stars - $prevStars);

            $up = $db->prepare(
                "INSERT INTO level_progress
                   (child_id, game_code, level_number, completed, stars_earned, completed_at)
                 VALUES (?, ?, ?, 1, ?, NOW())
                 ON DUPLICATE KEY UPDATE completed = 1,
                     stars_earned = GREATEST(stars_earned, VALUES(stars_earned)),
                     completed_at = NOW()"
            );
            $up->execute([$childId, $code, $num, $stars]);

            if ($delta > 0) {
                $db->prepare("UPDATE children SET total_stars = total_stars + ? WHERE id = ?")
                   ->execute([$delta, $childId]);
            }

            // إذا اكتملت كل مراحل اللعبة → علّم الملخّص game_progress.completed=1
            $gameCompleted = sync_game_completion($db, $childId, $code);

            $db->commit();
        } catch (Exception $e) {
            $db->rollBack();
            send(false, null, 'فشل تسجيل المرحلة', 500);
        }

        $row = $db->prepare("SELECT total_stars FROM children WHERE id = ?");
        $row->execute([$childId]);
        $tot = $row->fetch();

        created([
            'child_id'       => $childId,
            'game_code'      => $code,
            'level_number'   => $num,
            'game_completed' => $gameCompleted,
            'total_stars'    => $tot ? (int) $tot['total_stars'] : null,
        ], 'تم تسجيل المرحلة');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

<?php
// تقدّم الطفل في الألعاب.
// POST يُسجّل إكمال لعبة ويزيد نجوم الطفل بالفرق (delta) فقط لتفادي
// التضخّم عند إعادة لعب نفس اللعبة.
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$childId = isset($_GET['child_id']) ? (int) $_GET['child_id'] : null;

switch ($method) {

    // كل تقدّم طفل:  GET /progress/?child_id=1
    case 'GET':
        if (!$childId) badRequest('child_id مطلوب');
        $stmt = $db->prepare("SELECT * FROM game_progress WHERE child_id = ?");
        $stmt->execute([$childId]);
        ok($stmt->fetchAll());
        break;

    // تسجيل فوز بلعبة:  POST /progress/
    // body: {"child_id":1,"game_code":"word_game","stars":50}
    case 'POST':
        $b = body();
        if (empty($b['child_id']) || empty($b['game_code'])) {
            badRequest('child_id و game_code مطلوبان');
        }
        $childIdQ = (int) $b['child_id'];
        $code     = $b['game_code'];
        $stars    = (int) ($b['stars'] ?? 0);

        $db->beginTransaction();
        try {
            // كم نجمة كانت مسجّلة سابقاً على هذه اللعبة؟
            $check = $db->prepare(
                "SELECT stars_earned, completed FROM game_progress
                 WHERE child_id = ? AND game_code = ?"
            );
            $check->execute([$childIdQ, $code]);
            $prev = $check->fetch();
            $prevStars = $prev ? (int) $prev['stars_earned'] : 0;
            // لا نزيد النجوم الكلّية إلا بزيادة اللعبة (لمنع التضخّم عند الإعادة)
            $delta = max(0, $stars - $prevStars);

            // UPSERT
            $stmt = $db->prepare(
                "INSERT INTO game_progress (child_id, game_code, completed, stars_earned, completed_at)
                 VALUES (?, ?, 1, ?, NOW())
                 ON DUPLICATE KEY UPDATE completed = 1,
                     stars_earned = GREATEST(stars_earned, VALUES(stars_earned)),
                     completed_at = NOW()"
            );
            $stmt->execute([$childIdQ, $code, $stars]);

            // زيادة مجموع نجوم الطفل بالفرق فقط
            if ($delta > 0) {
                $upd = $db->prepare(
                    "UPDATE children SET total_stars = total_stars + ? WHERE id = ?"
                );
                $upd->execute([$delta, $childIdQ]);
            }

            $db->commit();
        } catch (Exception $e) {
            $db->rollBack();
            send(false, null, 'فشل تسجيل التقدّم', 500);
        }

        // نُعيد النجوم الكلّية الجديدة ليُحدِّث فلاتر شريطه العلوي فوراً.
        $row = $db->query("SELECT total_stars FROM children WHERE id = $childIdQ")->fetch();
        created(
            [
                'child_id'    => $childIdQ,
                'game_code'   => $code,
                'total_stars' => $row ? (int) $row['total_stars'] : null,
            ],
            'تم تسجيل التقدّم'
        );
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

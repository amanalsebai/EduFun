<?php
// التقييم المبدئي: POST يُدخل سجلّاً جديداً، GET يعيد آخر تقييم.
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$childId = isset($_GET['child_id']) ? (int) $_GET['child_id'] : null;

switch ($method) {

    // آخر تقييم للطفل
    case 'GET':
        if (!$childId) badRequest('child_id مطلوب');
        $stmt = $db->prepare(
            "SELECT * FROM assessments WHERE child_id = ? ORDER BY taken_at DESC, id DESC LIMIT 1"
        );
        $stmt->execute([$childId]);
        $row = $stmt->fetch();
        $row ? ok($row) : ok(null, 'لا يوجد تقييم بعد');
        break;

    // حفظ نتيجة تقييم جديدة + تحديث درجات المجالات
    case 'POST':
        $b = body();
        if (empty($b['child_id'])) badRequest('child_id مطلوب');
        $childIdQ = (int) $b['child_id'];
        $math     = (int) ($b['math_score']     ?? 0);
        $language = (int) ($b['language_score'] ?? 0);
        $logic    = (int) ($b['logic_score']    ?? 0);

        $db->beginTransaction();
        try {
            $ins = $db->prepare(
                "INSERT INTO assessments (child_id, math_score, language_score, logic_score)
                 VALUES (?, ?, ?, ?)"
            );
            $ins->execute([$childIdQ, $math, $language, $logic]);

            // زامِن درجات المجالات أيضاً
            $getSub = $db->prepare("SELECT id FROM subjects WHERE code = ?");
            $upsert = $db->prepare(
                "INSERT INTO child_scores (child_id, subject_id, score) VALUES (?, ?, ?)
                 ON DUPLICATE KEY UPDATE score = VALUES(score)"
            );
            foreach (['math' => $math, 'language' => $language, 'logic' => $logic] as $code => $sc) {
                $getSub->execute([$code]);
                $subj = $getSub->fetch();
                if (!$subj) continue;
                $upsert->execute([$childIdQ, (int) $subj['id'], $sc]);
            }

            $db->commit();
        } catch (Exception $e) {
            $db->rollBack();
            send(false, null, 'فشل حفظ التقييم', 500);
        }

        $newId = (int) $db->lastInsertId();
        created(
            ['id' => $newId, 'child_id' => $childIdQ,
             'math_score' => $math, 'language_score' => $language, 'logic_score' => $logic],
            'تم حفظ التقييم'
        );
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

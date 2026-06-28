<?php
// درجات المجالات الثلاثة لكل طفل (math / language / logic).
// PUT يحدّث الدرجات (UPSERT)، GET يعيدها كمصفوفة مفاتيحها code.
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$childId = isset($_GET['child_id']) ? (int) $_GET['child_id'] : null;

switch ($method) {

    // GET /scores/?child_id=1  →  {"math":4,"language":2,"logic":5}
    case 'GET':
        if (!$childId) badRequest('child_id مطلوب');
        $stmt = $db->prepare(
            "SELECT s.code, cs.score
             FROM child_scores cs
             JOIN subjects s ON s.id = cs.subject_id
             WHERE cs.child_id = ?"
        );
        $stmt->execute([$childId]);
        $out = ['math' => 0, 'language' => 0, 'logic' => 0];
        foreach ($stmt->fetchAll() as $r) {
            $out[$r['code']] = (int) $r['score'];
        }
        ok($out);
        break;

    // PUT /scores/?child_id=1  body: {"math":4,"language":2,"logic":5}
    case 'PUT':
        if (!$childId) badRequest('child_id مطلوب');
        $b = body();

        $getSub = $db->prepare("SELECT id FROM subjects WHERE code = ?");
        $upsert = $db->prepare(
            "INSERT INTO child_scores (child_id, subject_id, score) VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE score = VALUES(score)"
        );

        $db->beginTransaction();
        try {
            foreach (['math', 'language', 'logic'] as $code) {
                if (!isset($b[$code])) continue;
                $getSub->execute([$code]);
                $subj = $getSub->fetch();
                if (!$subj) continue;
                $upsert->execute([$childId, (int) $subj['id'], (int) $b[$code]]);
            }
            $db->commit();
        } catch (Exception $e) {
            $db->rollBack();
            send(false, null, 'فشل تحديث الدرجات', 500);
        }

        ok(['child_id' => $childId] + array_intersect_key($b, array_flip(['math', 'language', 'logic'])),
           'تم تحديث الدرجات');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

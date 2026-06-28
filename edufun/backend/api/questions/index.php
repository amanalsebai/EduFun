<?php
// CRUD لأسئلة التقييم المبدئي. GET يدعم فلترة اختيارية ?age=6
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$id     = isset($_GET['id']) ? (int) $_GET['id'] : null;

switch ($method) {

    // ─────────── READ ───────────
    case 'GET':
        if ($id) {
            $stmt = $db->prepare("SELECT * FROM assessment_questions WHERE id = ?");
            $stmt->execute([$id]);
            $row = $stmt->fetch();
            $row ? ok($row) : notFound('السؤال غير موجود');
        } elseif (isset($_GET['age'])) {
            $stmt = $db->prepare(
                "SELECT * FROM assessment_questions WHERE age = ?
                 ORDER BY sort_order ASC, id ASC"
            );
            $stmt->execute([(int) $_GET['age']]);
            ok($stmt->fetchAll());
        } else {
            $rows = $db->query(
                "SELECT * FROM assessment_questions ORDER BY age ASC, sort_order ASC, id ASC"
            )->fetchAll();
            ok($rows);
        }
        break;

    // ─────────── CREATE ───────────
    case 'POST':
        $b = body();
        if (empty($b['age']) || empty($b['category']) || empty($b['question'])
            || !isset($b['option_a']) || !isset($b['option_b'])) {
            badRequest('age و category و question و option_a و option_b مطلوبة');
        }
        $stmt = $db->prepare(
            "INSERT INTO assessment_questions
                (age, category, question, option_a, option_b, option_c, option_d, correct_index, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );
        $stmt->execute([
            (int) $b['age'],
            $b['category'],
            $b['question'],
            $b['option_a'],
            $b['option_b'],
            $b['option_c'] ?? '',
            $b['option_d'] ?? '',
            (int) ($b['correct_index'] ?? 0),
            (int) ($b['sort_order'] ?? 0),
        ]);
        $newId = (int) $db->lastInsertId();
        $row = $db->query("SELECT * FROM assessment_questions WHERE id = $newId")->fetch();
        created($row, 'تمت إضافة السؤال');
        break;

    // ─────────── UPDATE (حقول اختيارية) ───────────
    case 'PUT':
        if (!$id) badRequest('id مطلوب');
        $b = body();
        $stmt = $db->prepare(
            "UPDATE assessment_questions
             SET age           = COALESCE(?, age),
                 category      = COALESCE(?, category),
                 question      = COALESCE(?, question),
                 option_a      = COALESCE(?, option_a),
                 option_b      = COALESCE(?, option_b),
                 option_c      = COALESCE(?, option_c),
                 option_d      = COALESCE(?, option_d),
                 correct_index = COALESCE(?, correct_index),
                 sort_order    = COALESCE(?, sort_order)
             WHERE id = ?"
        );
        $stmt->execute([
            isset($b['age']) ? (int) $b['age'] : null,
            $b['category'] ?? null,
            $b['question'] ?? null,
            $b['option_a'] ?? null,
            $b['option_b'] ?? null,
            $b['option_c'] ?? null,
            $b['option_d'] ?? null,
            isset($b['correct_index']) ? (int) $b['correct_index'] : null,
            isset($b['sort_order']) ? (int) $b['sort_order'] : null,
            $id,
        ]);
        $row = $db->query("SELECT * FROM assessment_questions WHERE id = $id")->fetch();
        $row ? ok($row, 'تم التحديث') : notFound('السؤال غير موجود');
        break;

    // ─────────── DELETE ───────────
    case 'DELETE':
        if (!$id) badRequest('id مطلوب');
        $stmt = $db->prepare("DELETE FROM assessment_questions WHERE id = ?");
        $stmt->execute([$id]);
        $stmt->rowCount() > 0 ? ok(null, 'تم الحذف') : notFound('السؤال غير موجود');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

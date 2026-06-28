<?php
// CRUD للأطفال — هذا هو القالب المرجعي لباقي الموارد.
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$id     = isset($_GET['id']) ? (int) $_GET['id'] : null;

switch ($method) {

    // ─────────── READ: طفل واحد أو كل الأطفال ───────────
    case 'GET':
        if ($id) {
            $stmt = $db->prepare("SELECT * FROM children WHERE id = ?");
            $stmt->execute([$id]);
            $row = $stmt->fetch();
            $row ? ok($row) : notFound('الطفل غير موجود');
        } else {
            $stmt = $db->query("SELECT * FROM children ORDER BY id ASC");
            ok($stmt->fetchAll());
        }
        break;

    // ─────────── CREATE ───────────
    case 'POST':
        $b = body();
        if (empty($b['name']) || empty($b['age'])) {
            badRequest('الاسم والعمر مطلوبان');
        }
        $stmt = $db->prepare(
            "INSERT INTO children (name, age, total_stars) VALUES (?, ?, ?)"
        );
        $stmt->execute([
            $b['name'],
            (int) $b['age'],
            (int) ($b['total_stars'] ?? 0),
        ]);
        $newId = (int) $db->lastInsertId();
        $row = $db->query("SELECT * FROM children WHERE id = $newId")->fetch();
        created($row, 'تم إنشاء الطفل');
        break;

    // ─────────── UPDATE (حقول اختيارية) ───────────
    case 'PUT':
        if (!$id) badRequest('المعرّف (id) مطلوب');
        $b = body();
        $stmt = $db->prepare(
            "UPDATE children
             SET name        = COALESCE(?, name),
                 age         = COALESCE(?, age),
                 total_stars = COALESCE(?, total_stars)
             WHERE id = ?"
        );
        $stmt->execute([
            isset($b['name']) ? $b['name'] : null,
            isset($b['age']) ? (int) $b['age'] : null,
            isset($b['total_stars']) ? (int) $b['total_stars'] : null,
            $id,
        ]);
        $row = $db->query("SELECT * FROM children WHERE id = $id")->fetch();
        $row ? ok($row, 'تم التحديث') : notFound('الطفل غير موجود');
        break;

    // ─────────── DELETE ───────────
    case 'DELETE':
        if (!$id) badRequest('المعرّف (id) مطلوب');
        $stmt = $db->prepare("DELETE FROM children WHERE id = ?");
        $stmt->execute([$id]);
        $stmt->rowCount() > 0 ? ok(null, 'تم الحذف') : notFound('الطفل غير موجود');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

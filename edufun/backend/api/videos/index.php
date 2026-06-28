<?php
// CRUD لمكتبة الفيديوهات (الدروس). GET يدعم فلترة اختيارية ?subject=math
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
            $stmt = $db->prepare("SELECT * FROM videos WHERE id = ?");
            $stmt->execute([$id]);
            $row = $stmt->fetch();
            $row ? ok($row) : notFound('الفيديو غير موجود');
        } elseif (isset($_GET['subject'])) {
            $stmt = $db->prepare(
                "SELECT * FROM videos WHERE subject_code = ?
                 ORDER BY sort_order ASC, id ASC"
            );
            $stmt->execute([$_GET['subject']]);
            ok($stmt->fetchAll());
        } else {
            $rows = $db->query(
                "SELECT * FROM videos ORDER BY subject_code ASC, sort_order ASC, id ASC"
            )->fetchAll();
            ok($rows);
        }
        break;

    // ─────────── CREATE ───────────
    case 'POST':
        $b = body();
        if (empty($b['subject_code']) || empty($b['title']) || empty($b['url'])) {
            badRequest('subject_code و title و url مطلوبة');
        }
        $stmt = $db->prepare(
            "INSERT INTO videos (subject_code, title, channel, url, thumbnail, min_age, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        $stmt->execute([
            $b['subject_code'],
            $b['title'],
            $b['channel'] ?? '',
            $b['url'],
            $b['thumbnail'] ?? '',
            (int) ($b['min_age'] ?? 6),
            (int) ($b['sort_order'] ?? 0),
        ]);
        $newId = (int) $db->lastInsertId();
        $row = $db->query("SELECT * FROM videos WHERE id = $newId")->fetch();
        created($row, 'تمت إضافة الفيديو');
        break;

    // ─────────── UPDATE (حقول اختيارية) ───────────
    case 'PUT':
        if (!$id) badRequest('id مطلوب');
        $b = body();
        $stmt = $db->prepare(
            "UPDATE videos
             SET subject_code = COALESCE(?, subject_code),
                 title        = COALESCE(?, title),
                 channel      = COALESCE(?, channel),
                 url          = COALESCE(?, url),
                 thumbnail    = COALESCE(?, thumbnail),
                 min_age      = COALESCE(?, min_age),
                 sort_order   = COALESCE(?, sort_order)
             WHERE id = ?"
        );
        $stmt->execute([
            $b['subject_code'] ?? null,
            $b['title'] ?? null,
            $b['channel'] ?? null,
            $b['url'] ?? null,
            $b['thumbnail'] ?? null,
            isset($b['min_age']) ? (int) $b['min_age'] : null,
            isset($b['sort_order']) ? (int) $b['sort_order'] : null,
            $id,
        ]);
        $row = $db->query("SELECT * FROM videos WHERE id = $id")->fetch();
        $row ? ok($row, 'تم التحديث') : notFound('الفيديو غير موجود');
        break;

    // ─────────── DELETE ───────────
    case 'DELETE':
        if (!$id) badRequest('id مطلوب');
        $stmt = $db->prepare("DELETE FROM videos WHERE id = ?");
        $stmt->execute([$id]);
        $stmt->rowCount() > 0 ? ok(null, 'تم الحذف') : notFound('الفيديو غير موجود');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

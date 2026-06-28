<?php
// كتالوج الألعاب: GET (مع فلترة اختيارية ?min_age=) + عمليات إدارة CRUD.
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$id     = isset($_GET['id']) ? (int) $_GET['id'] : null;

switch ($method) {

    case 'GET':
        if (isset($_GET['min_age'])) {
            $minAge = (int) $_GET['min_age'];
            $stmt = $db->prepare(
                "SELECT g.id, g.game_code, g.title_ar, g.subtitle, g.category_label,
                        g.subject_id, g.min_age, g.sort_order, g.is_active, s.code AS subject_code
                 FROM games g JOIN subjects s ON s.id = g.subject_id
                 WHERE g.min_age = ? AND g.is_active = 1
                 ORDER BY g.sort_order ASC, g.id ASC"
            );
            $stmt->execute([$minAge]);
            ok($stmt->fetchAll());
        } else {
            $rows = $db->query(
                "SELECT g.id, g.game_code, g.title_ar, g.subtitle, g.category_label,
                        g.subject_id, g.min_age, g.sort_order, g.is_active, s.code AS subject_code
                 FROM games g JOIN subjects s ON s.id = g.subject_id
                 WHERE g.is_active = 1
                 ORDER BY g.min_age ASC, g.sort_order ASC, g.id ASC"
            )->fetchAll();
            ok($rows);
        }
        break;

    case 'POST':
        $b = body();
        if (empty($b['game_code']) || empty($b['title_ar']) || empty($b['subject_id'])) {
            badRequest('game_code و title_ar و subject_id مطلوبة');
        }
        $stmt = $db->prepare(
            "INSERT INTO games (game_code, title_ar, subject_id, min_age)
             VALUES (?, ?, ?, ?)"
        );
        $stmt->execute([
            $b['game_code'], $b['title_ar'],
            (int) $b['subject_id'], (int) ($b['min_age'] ?? 6),
        ]);
        $newId = (int) $db->lastInsertId();
        $row = $db->query("SELECT * FROM games WHERE id = $newId")->fetch();
        created($row, 'تمت إضافة اللعبة');
        break;

    case 'PUT':
        if (!$id) badRequest('id مطلوب');
        $b = body();
        $stmt = $db->prepare(
            "UPDATE games
             SET game_code = COALESCE(?, game_code),
                 title_ar  = COALESCE(?, title_ar),
                 subject_id= COALESCE(?, subject_id),
                 min_age   = COALESCE(?, min_age)
             WHERE id = ?"
        );
        $stmt->execute([
            $b['game_code'] ?? null,
            $b['title_ar']  ?? null,
            isset($b['subject_id']) ? (int) $b['subject_id'] : null,
            isset($b['min_age']) ? (int) $b['min_age'] : null,
            $id,
        ]);
        $row = $db->query("SELECT * FROM games WHERE id = $id")->fetch();
        $row ? ok($row, 'تم التحديث') : notFound('اللعبة غير موجودة');
        break;

    case 'DELETE':
        if (!$id) badRequest('id مطلوب');
        $stmt = $db->prepare("DELETE FROM games WHERE id = ?");
        $stmt->execute([$id]);
        $stmt->rowCount() > 0 ? ok(null, 'تم الحذف') : notFound('اللعبة غير موجودة');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}

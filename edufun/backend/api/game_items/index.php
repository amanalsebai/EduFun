<?php
// محتوى الألعاب النصية القابل للتعديل من لوحة admin.
//   GET /game_items/?game_code=X[&level_number=N]
//   → قائمة عناصر المحتوى (text1..text4) مرتّبة، للمستوى المحدّد (أو كل المستويات).
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db   = (new Database())->connect();
$code = $_GET['game_code'] ?? '';
if ($code === '') badRequest('game_code مطلوب');

if (isset($_GET['level_number'])) {
    $level = (int) $_GET['level_number'];
    $stmt = $db->prepare(
        "SELECT level_number, text1, text2, text3, text4
         FROM game_items
         WHERE game_code = ? AND level_number = ? AND is_active = 1
         ORDER BY sort_order ASC, id ASC"
    );
    $stmt->execute([$code, $level]);
} else {
    $stmt = $db->prepare(
        "SELECT level_number, text1, text2, text3, text4
         FROM game_items
         WHERE game_code = ? AND is_active = 1
         ORDER BY level_number ASC, sort_order ASC, id ASC"
    );
    $stmt->execute([$code]);
}

ok($stmt->fetchAll());

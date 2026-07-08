<?php
// حالة فتح الأعمار لطفل — نقطة الحقيقة لفتح المستوى التالي.
//   GET /unlocks/?child_id=N
//   → { base_age, total_stars, ages: { "6": {completed,total,unlocked,games_done,games_total}, ... } }
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/unlocks.php';

$db      = (new Database())->connect();
$childId = isset($_GET['child_id']) ? (int) $_GET['child_id'] : 0;
if ($childId <= 0) badRequest('child_id مطلوب');

// نجوم الطفل
$cs = $db->prepare("SELECT age, total_stars FROM children WHERE id = ?");
$cs->execute([$childId]);
$child = $cs->fetch();
if (!$child) notFound('الطفل غير موجود');

$baseAge = (int) $child['age'];
$ages    = [];

// كل الأعمار المتوفّرة في كتالوج الألعاب.
$distinct = $db->query(
    "SELECT DISTINCT min_age FROM games WHERE is_active = 1 ORDER BY min_age ASC"
)->fetchAll();

foreach ($distinct as $r) {
    $age    = (int) $r['min_age'];
    $games  = games_of_age($db, $age);
    $total  = count($games);

    $done = 0;
    if ($total > 0) {
        $in = implode(',', array_fill(0, $total, '?'));
        $st = $db->prepare(
            "SELECT COUNT(*) AS c FROM game_progress
             WHERE child_id = ? AND completed = 1 AND game_code IN ($in)"
        );
        $st->execute(array_merge([$childId], $games));
        $done = (int) $st->fetch()['c'];
    }

    $ages[(string) $age] = [
        'games_done'  => $done,
        'games_total' => $total,
        'completed'   => $total > 0 && $done >= $total,
        'unlocked'    => is_age_unlocked($db, $childId, $age),
    ];
}

ok([
    'base_age'    => $baseAge,
    'total_stars' => (int) $child['total_stars'],
    'ages'        => $ages,
]);

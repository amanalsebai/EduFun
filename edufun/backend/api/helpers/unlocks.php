<?php
// منطق مشترك لفتح الأعمار وإكمال الألعاب/المراحل — يُستخدم في
// levels/index.php و unlocks/index.php لضمان قاعدة واحدة للحقيقة.

/// العمر الأساسي المسجّل للطفل (المستوى الذي بدأ منه).
function child_base_age(PDO $db, int $childId): int {
    $st = $db->prepare("SELECT age FROM children WHERE id = ?");
    $st->execute([$childId]);
    $row = $st->fetch();
    return $row ? (int) $row['age'] : 6;
}

/// كل الألعاب المفعّلة ضمن عمر معيّن (min_age).
function games_of_age(PDO $db, int $age): array {
    $st = $db->prepare(
        "SELECT game_code FROM games WHERE min_age = ? AND is_active = 1"
    );
    $st->execute([$age]);
    return array_column($st->fetchAll(), 'game_code');
}

/// هل أكمل الطفل كل ألعاب هذا العمر؟
/// (لعبة مكتملة = لها صف completed=1 في game_progress).
function is_age_completed(PDO $db, int $childId, int $age): bool {
    $games = games_of_age($db, $age);
    if (count($games) === 0) return false;

    $in = implode(',', array_fill(0, count($games), '?'));
    $st = $db->prepare(
        "SELECT COUNT(*) AS c FROM game_progress
         WHERE child_id = ? AND completed = 1 AND game_code IN ($in)"
    );
    $st->execute(array_merge([$childId], $games));
    $done = (int) $st->fetch()['c'];
    return $done >= count($games);
}

/// هل العمر مفتوح للطفل؟
/// - أي عمر ≤ العمر الأساسي: مفتوح.
/// - عمر أعلى: يُفتح فقط إذا اكتملت كل الأعمار من الأساسي حتى ما قبله.
function is_age_unlocked(PDO $db, int $childId, int $age): bool {
    $base = child_base_age($db, $childId);
    if ($age <= $base) return true;
    for ($a = $base; $a < $age; $a++) {
        if (!is_age_completed($db, $childId, $a)) return false;
    }
    return true;
}

/// عدد مراحل اللعبة المفعّلة.
function game_levels_count(PDO $db, string $gameCode): int {
    $st = $db->prepare(
        "SELECT COUNT(*) AS c FROM game_levels WHERE game_code = ? AND is_active = 1"
    );
    $st->execute([$gameCode]);
    return (int) $st->fetch()['c'];
}

/// عدد المراحل التي أكملها الطفل في لعبة.
function child_completed_levels(PDO $db, int $childId, string $gameCode): int {
    $st = $db->prepare(
        "SELECT COUNT(*) AS c FROM level_progress
         WHERE child_id = ? AND game_code = ? AND completed = 1"
    );
    $st->execute([$childId, $gameCode]);
    return (int) $st->fetch()['c'];
}

/// عمر لعبة (min_age) أو 0 إن لم توجد.
function game_min_age(PDO $db, string $gameCode): int {
    $st = $db->prepare("SELECT min_age FROM games WHERE game_code = ?");
    $st->execute([$gameCode]);
    $row = $st->fetch();
    return $row ? (int) $row['min_age'] : 0;
}

/// يضبط ملخّص game_progress.completed=1 عندما تكتمل كل مراحل اللعبة،
/// ليبقى منطق «اكتمال العمر» والشاشات القديمة متوافقاً.
function sync_game_completion(PDO $db, int $childId, string $gameCode): bool {
    $total = game_levels_count($db, $gameCode);
    if ($total === 0) return false;
    $done = child_completed_levels($db, $childId, $gameCode);
    if ($done < $total) return false;

    // مجموع نجوم اللعبة عبر مراحلها (لتعبئة stars_earned في الملخّص).
    $st = $db->prepare(
        "SELECT COALESCE(SUM(stars_earned),0) AS s FROM level_progress
         WHERE child_id = ? AND game_code = ? AND completed = 1"
    );
    $st->execute([$childId, $gameCode]);
    $sum = (int) $st->fetch()['s'];

    $up = $db->prepare(
        "INSERT INTO game_progress (child_id, game_code, completed, stars_earned, completed_at)
         VALUES (?, ?, 1, ?, NOW())
         ON DUPLICATE KEY UPDATE completed = 1,
             stars_earned = GREATEST(stars_earned, VALUES(stars_earned)),
             completed_at = NOW()"
    );
    $up->execute([$childId, $gameCode, $sum]);
    return true;
}

<?php
// إدارة مراحل الألعاب (game_levels) — إضافة/تعديل/حذف.
// كل لعبة لها عدة مراحل متسلسلة، وإعدادات المرحلة (config) بصيغة JSON تُقرأ في التطبيق.
require_once __DIR__ . '/inc.php';

// قائمة الألعاب لربط المرحلة بلعبة.
$games = $pdo->query("SELECT game_code, title_ar, min_age FROM games ORDER BY min_age, sort_order")->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM game_levels WHERE id = ?");
        $stmt->execute([(int) $_POST['id']]);
        flash('levels.php', 'تم حذف المرحلة');
    }

    $isActive = isset($_POST['is_active']) ? 1 : 0;

    // نبني إعدادات الصعوبة (config JSON) من حقول واضحة — المستخدم لا يكتب JSON.
    $cfg = [];
    if (($r = trim($_POST['rounds'] ?? ''))    !== '') $cfg['rounds']    = (int) $r;
    if (($m = trim($_POST['maxNumber'] ?? '')) !== '') $cfg['maxNumber'] = (int) $m;
    if (($f = trim($_POST['maxFactor'] ?? '')) !== '') $cfg['maxFactor'] = (int) $f;
    $config = empty($cfg) ? null : json_encode($cfg, JSON_UNESCAPED_UNICODE);

    $data = [
        trim($_POST['game_code'] ?? ''),        // 0
        (int) ($_POST['level_number'] ?? 1),    // 1
        trim($_POST['title_ar'] ?? ''),         // 2
        (int) ($_POST['stars_reward'] ?? 20),   // 3
        $config,                                // 4
        (int) ($_POST['sort_order'] ?? 0),      // 5
        $isActive,                              // 6
    ];

    if ($action === 'create' && $data[0] !== '') {
        try {
            $stmt = $pdo->prepare(
                "INSERT INTO game_levels
                    (game_code, level_number, title_ar, stars_reward, config, sort_order, is_active)
                 VALUES (?, ?, ?, ?, ?, ?, ?)"
            );
            $stmt->execute($data);
            flash('levels.php', 'تمت إضافة المرحلة');
        } catch (PDOException $e) {
            flash('levels.php', 'تعذّر الحفظ: هذه المرحلة (لعبة + رقم) موجودة مسبقاً');
        }
    }

    if ($action === 'update') {
        $data[] = (int) $_POST['id'];
        $stmt = $pdo->prepare(
            "UPDATE game_levels
             SET game_code=?, level_number=?, title_ar=?, stars_reward=?, config=?, sort_order=?, is_active=?
             WHERE id=?"
        );
        $stmt->execute($data);
        flash('levels.php', 'تم تحديث المرحلة');
    }
    redirect('levels.php');
}

$editing = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM game_levels WHERE id = ?");
    $stmt->execute([(int) $_GET['edit']]);
    $editing = $stmt->fetch();
}

$rows = $pdo->query(
    "SELECT l.*, g.title_ar AS game_title, g.min_age
     FROM game_levels l
     LEFT JOIN games g ON g.game_code = l.game_code
     ORDER BY g.min_age, l.game_code, l.level_number"
)->fetchAll();

$activeChecked = (!$editing || (int) ($editing['is_active'] ?? 1) === 1) ? 'checked' : '';

// فكّ إعدادات الصعوبة المخزّنة لتعبئة الحقول عند التعديل.
$cfgEdit = ($editing && !empty($editing['config'])) ? (json_decode($editing['config'], true) ?: []) : [];

render_header('المراحل');
?>
<div class="card">
  <h2><?= $editing ? '✏️ تعديل مرحلة' : '➕ إضافة مرحلة جديدة' ?></h2>
  <p class="hint">⚠️ المراحل تُفتح بالتسلسل: المرحلة 2 لا تُفتح إلا بإكمال المرحلة 1.
     إعدادات الصعوبة اختيارية — عبّئ ما يناسب اللعبة فقط: «عدد الجولات» لكل الألعاب، «أكبر رقم» لألعاب الجمع/الطرح،
     «أكبر عامل ضرب» لمغامرة الضرب. المحتوى النصي (الكلمات، الجُمل...) يُدار من صفحة «محتوى الألعاب».</p>
  <form method="post">
    <input type="hidden" name="action" value="<?= $editing ? 'update' : 'create' ?>">
    <?php if ($editing): ?><input type="hidden" name="id" value="<?= (int) $editing['id'] ?>"><?php endif; ?>
    <div class="grid">
      <div>
        <label>اللعبة</label>
        <select name="game_code" required>
          <?php foreach ($games as $g): ?>
            <option value="<?= h($g['game_code']) ?>" <?= ($editing['game_code'] ?? '') === $g['game_code'] ? 'selected' : '' ?>>
              <?= h($g['title_ar']) ?> (<?= (int) $g['min_age'] ?> سنوات) — <?= h($g['game_code']) ?>
            </option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>رقم المرحلة</label>
        <input type="number" name="level_number" min="1" max="20" value="<?= h($editing['level_number'] ?? 1) ?>" required>
      </div>
      <div>
        <label>مكافأة النجوم</label>
        <input type="number" name="stars_reward" min="0" value="<?= h($editing['stars_reward'] ?? 20) ?>">
      </div>
      <div>
        <label>الترتيب</label>
        <input type="number" name="sort_order" value="<?= h($editing['sort_order'] ?? 0) ?>">
      </div>
    </div>
    <div style="margin-top:14px">
      <label>عنوان المرحلة (بالعربية)</label>
      <input type="text" name="title_ar" value="<?= h($editing['title_ar'] ?? '') ?>" placeholder="مثال: المستوى الأول — سهل">
    </div>
    <div style="margin-top:14px">
      <label>إعدادات الصعوبة (اختيارية — بدون رموز)</label>
      <div class="grid">
        <div>
          <label style="font-weight:400">عدد الجولات</label>
          <input type="number" name="rounds" min="1" max="20" value="<?= h($cfgEdit['rounds'] ?? '') ?>" placeholder="مثال: 5">
        </div>
        <div>
          <label style="font-weight:400">أكبر رقم (الجمع/الطرح)</label>
          <input type="number" name="maxNumber" min="1" value="<?= h($cfgEdit['maxNumber'] ?? '') ?>" placeholder="مثال: 10">
        </div>
        <div>
          <label style="font-weight:400">أكبر عامل ضرب</label>
          <input type="number" name="maxFactor" min="2" max="12" value="<?= h($cfgEdit['maxFactor'] ?? '') ?>" placeholder="مثال: 9">
        </div>
      </div>
    </div>
    <div style="margin-top:14px">
      <label style="display:flex; align-items:center; gap:8px; cursor:pointer">
        <input type="checkbox" name="is_active" value="1" <?= $activeChecked ?> style="width:auto; margin:0">
        <span>مُفعّلة (تظهر في التطبيق)</span>
      </label>
    </div>
    <div style="margin-top:16px; display:flex; gap:8px">
      <button class="btn ok" type="submit"><?= $editing ? 'حفظ التعديل' : 'إضافة' ?></button>
      <?php if ($editing): ?><a class="btn ghost" href="levels.php">إلغاء</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="card">
  <h2>كل المراحل (<?= count($rows) ?>)</h2>
  <table>
    <tr><th>#</th><th>اللعبة</th><th>المرحلة</th><th>العنوان</th><th>النجوم</th><th>الصعوبة</th><th>مفعّلة</th><th>إجراءات</th></tr>
    <?php foreach ($rows as $l):
      $c = !empty($l['config']) ? (json_decode($l['config'], true) ?: []) : [];
      $diff = [];
      if (isset($c['rounds']))    $diff[] = 'جولات: ' . (int) $c['rounds'];
      if (isset($c['maxNumber'])) $diff[] = 'أكبر رقم: ' . (int) $c['maxNumber'];
      if (isset($c['maxFactor'])) $diff[] = 'أكبر عامل: ' . (int) $c['maxFactor'];
    ?>
      <tr style="<?= (int) $l['is_active'] === 0 ? 'opacity:.55' : '' ?>">
        <td><?= (int) $l['id'] ?></td>
        <td><?= h($l['game_title'] ?? $l['game_code']) ?><br><code dir="ltr" style="font-size:11px"><?= h($l['game_code']) ?></code></td>
        <td style="text-align:center"><?= (int) $l['level_number'] ?></td>
        <td><?= h($l['title_ar']) ?></td>
        <td style="text-align:center"><?= (int) $l['stars_reward'] ?> ⭐</td>
        <td><?= $diff ? h(implode(' • ', $diff)) : '<span style="color:#9aa">—</span>' ?></td>
        <td style="text-align:center"><?= (int) $l['is_active'] === 1 ? '✅' : '🚫' ?></td>
        <td>
          <div class="row-actions">
            <a class="btn ghost sm" href="levels.php?edit=<?= (int) $l['id'] ?>">تعديل</a>
            <form method="post" onsubmit="return confirm('حذف هذه المرحلة؟');" style="display:inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<?= (int) $l['id'] ?>">
              <button class="btn danger sm" type="submit">حذف</button>
            </form>
          </div>
        </td>
      </tr>
    <?php endforeach; ?>
  </table>
</div>
<?php
render_footer();

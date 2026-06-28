<?php
// إدارة كتالوج الألعاب — إضافة/تعديل/حذف (مع حقول الإدارة: الوصف، التصنيف، الترتيب، التفعيل).
require_once __DIR__ . '/inc.php';

// المجالات لقائمة الاختيار
$subjects = $pdo->query("SELECT id, code, name_ar FROM subjects ORDER BY id")->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM games WHERE id = ?");
        $stmt->execute([(int) $_POST['id']]);
        flash('games.php', 'تم حذف اللعبة');
    }

    // checkbox يُرسَل فقط عند تفعيله؛ نحوّله إلى 1/0 صراحةً.
    $isActive = isset($_POST['is_active']) ? 1 : 0;

    $data = [
        trim($_POST['game_code'] ?? ''),       // 0
        trim($_POST['title_ar'] ?? ''),        // 1
        trim($_POST['subtitle'] ?? ''),        // 2
        trim($_POST['category_label'] ?? ''),  // 3
        (int) ($_POST['subject_id'] ?? 0),     // 4
        (int) ($_POST['min_age'] ?? 6),        // 5
        (int) ($_POST['sort_order'] ?? 0),     // 6
        $isActive,                             // 7
    ];

    if ($action === 'create' && $data[0] !== '' && $data[1] !== '' && $data[4] > 0) {
        try {
            $stmt = $pdo->prepare(
                "INSERT INTO games
                    (game_code, title_ar, subtitle, category_label, subject_id, min_age, sort_order, is_active)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
            );
            $stmt->execute($data);
            flash('games.php', 'تمت إضافة اللعبة');
        } catch (PDOException $e) {
            flash('games.php', 'تعذّر الحفظ: رمز اللعبة (game_code) مستخدم مسبقاً');
        }
    }

    if ($action === 'update') {
        $data[] = (int) $_POST['id'];
        $stmt = $pdo->prepare(
            "UPDATE games
             SET game_code=?, title_ar=?, subtitle=?, category_label=?, subject_id=?, min_age=?, sort_order=?, is_active=?
             WHERE id=?"
        );
        $stmt->execute($data);
        flash('games.php', 'تم تحديث اللعبة');
    }
    redirect('games.php');
}

$editing = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM games WHERE id = ?");
    $stmt->execute([(int) $_GET['edit']]);
    $editing = $stmt->fetch();
}

$rows = $pdo->query(
    "SELECT g.*, s.name_ar AS subject_name FROM games g
     JOIN subjects s ON s.id = g.subject_id
     ORDER BY g.min_age, g.sort_order, g.id"
)->fetchAll();

// مُفعّلة افتراضياً عند الإضافة؛ وعند التعديل نعكس القيمة المحفوظة.
$activeChecked = (!$editing || (int) ($editing['is_active'] ?? 1) === 1) ? 'checked' : '';

render_header('الألعاب');
?>
<div class="card">
  <h2><?= $editing ? '✏️ تعديل لعبة' : '➕ إضافة لعبة جديدة' ?></h2>
  <p class="hint">⚠️ رمز اللعبة (game_code) يجب أن يطابق الرمز المستخدم داخل تطبيق فلاتر حتى تُفتح الشاشة الصحيحة ويُحسب التقدّم.</p>
  <form method="post">
    <input type="hidden" name="action" value="<?= $editing ? 'update' : 'create' ?>">
    <?php if ($editing): ?><input type="hidden" name="id" value="<?= (int) $editing['id'] ?>"><?php endif; ?>
    <div class="grid">
      <div>
        <label>رمز اللعبة (game_code)</label>
        <input type="text" name="game_code" value="<?= h($editing['game_code'] ?? '') ?>" required dir="ltr">
      </div>
      <div>
        <label>المجال</label>
        <select name="subject_id">
          <?php foreach ($subjects as $s): ?>
            <option value="<?= (int) $s['id'] ?>" <?= (int) ($editing['subject_id'] ?? 0) === (int) $s['id'] ? 'selected' : '' ?>><?= h($s['name_ar']) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>العمر الأدنى</label>
        <input type="number" name="min_age" min="6" max="9" value="<?= h($editing['min_age'] ?? 6) ?>">
      </div>
      <div>
        <label>التصنيف (يظهر على البطاقة)</label>
        <input type="text" name="category_label" value="<?= h($editing['category_label'] ?? '') ?>" placeholder="مثال: لغويات / حساب / إدراك">
      </div>
      <div>
        <label>الترتيب</label>
        <input type="number" name="sort_order" value="<?= h($editing['sort_order'] ?? 0) ?>">
      </div>
    </div>
    <div style="margin-top:14px">
      <label>العنوان (بالعربية)</label>
      <input type="text" name="title_ar" value="<?= h($editing['title_ar'] ?? '') ?>" required>
    </div>
    <div style="margin-top:14px">
      <label>الوصف (يظهر تحت العنوان على البطاقة)</label>
      <textarea name="subtitle" placeholder="جملة قصيرة تشرح اللعبة"><?= h($editing['subtitle'] ?? '') ?></textarea>
    </div>
    <div style="margin-top:14px">
      <label style="display:flex; align-items:center; gap:8px; cursor:pointer">
        <input type="checkbox" name="is_active" value="1" <?= $activeChecked ?> style="width:auto; margin:0">
        <span>مُفعّلة (تظهر في التطبيق) — أزِل العلامة لإخفائها مؤقتاً دون حذفها</span>
      </label>
    </div>
    <div style="margin-top:16px; display:flex; gap:8px">
      <button class="btn ok" type="submit"><?= $editing ? 'حفظ التعديل' : 'إضافة' ?></button>
      <?php if ($editing): ?><a class="btn ghost" href="games.php">إلغاء</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="card">
  <h2>كل الألعاب (<?= count($rows) ?>)</h2>
  <table>
    <tr><th>#</th><th>رمز اللعبة</th><th>العنوان</th><th>التصنيف</th><th>المجال</th><th>العمر</th><th>ترتيب</th><th>مفعّلة</th><th>إجراءات</th></tr>
    <?php foreach ($rows as $g): ?>
      <tr style="<?= (int) $g['is_active'] === 0 ? 'opacity:.55' : '' ?>">
        <td><?= (int) $g['id'] ?></td>
        <td dir="ltr" style="text-align:right"><code><?= h($g['game_code']) ?></code></td>
        <td><?= h($g['title_ar']) ?></td>
        <td><?= h($g['category_label']) ?></td>
        <td><span class="pill"><?= h($g['subject_name']) ?></span></td>
        <td><?= (int) $g['min_age'] ?></td>
        <td><?= (int) $g['sort_order'] ?></td>
        <td><?= (int) $g['is_active'] === 1 ? '✅' : '🚫' ?></td>
        <td>
          <div class="row-actions">
            <a class="btn ghost sm" href="games.php?edit=<?= (int) $g['id'] ?>">تعديل</a>
            <form method="post" onsubmit="return confirm('حذف هذه اللعبة؟');" style="display:inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<?= (int) $g['id'] ?>">
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

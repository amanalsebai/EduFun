<?php
// إدارة أسئلة التقييم المبدئي — إضافة/تعديل/حذف.
require_once __DIR__ . '/inc.php';

$CATS = ['math' => 'الرياضيات', 'language' => 'اللغة', 'logic' => 'المنطق'];
$LETTERS = ['أ', 'ب', 'ج', 'د'];

// ─────────── معالجة العمليات (POST) ───────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM assessment_questions WHERE id = ?");
        $stmt->execute([(int) $_POST['id']]);
        flash('questions.php', 'تم حذف السؤال');
    }

    $data = [
        (int) ($_POST['age'] ?? 6),
        $_POST['category'] ?? 'math',
        trim($_POST['question'] ?? ''),
        trim($_POST['option_a'] ?? ''),
        trim($_POST['option_b'] ?? ''),
        trim($_POST['option_c'] ?? ''),
        trim($_POST['option_d'] ?? ''),
        (int) ($_POST['correct_index'] ?? 0),
        (int) ($_POST['sort_order'] ?? 0),
    ];

    if ($action === 'create' && $data[2] !== '') {
        try {
            $stmt = $pdo->prepare(
                "INSERT INTO assessment_questions
                    (age, category, question, option_a, option_b, option_c, option_d, correct_index, sort_order)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );
            $stmt->execute($data);
            flash('questions.php', 'تمت إضافة السؤال');
        } catch (PDOException $e) {
            flash('questions.php', 'تعذّر الحفظ: قد تكون خانة (العمر + الترتيب) مستخدمة مسبقاً');
        }
    }

    if ($action === 'update') {
        $data[] = (int) $_POST['id'];
        $stmt = $pdo->prepare(
            "UPDATE assessment_questions
             SET age=?, category=?, question=?, option_a=?, option_b=?, option_c=?, option_d=?, correct_index=?, sort_order=?
             WHERE id=?"
        );
        $stmt->execute($data);
        flash('questions.php', 'تم تحديث السؤال');
    }
    redirect('questions.php');
}

$editing = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM assessment_questions WHERE id = ?");
    $stmt->execute([(int) $_GET['edit']]);
    $editing = $stmt->fetch();
}

$rows = $pdo->query("SELECT * FROM assessment_questions ORDER BY age, sort_order, id")->fetchAll();

render_header('أسئلة التقييم');
?>
<div class="card">
  <h2><?= $editing ? '✏️ تعديل سؤال' : '➕ إضافة سؤال جديد' ?></h2>
  <form method="post">
    <input type="hidden" name="action" value="<?= $editing ? 'update' : 'create' ?>">
    <?php if ($editing): ?><input type="hidden" name="id" value="<?= (int) $editing['id'] ?>"><?php endif; ?>
    <div class="grid">
      <div>
        <label>العمر</label>
        <select name="age">
          <?php foreach ([6,7,8,9] as $a): ?>
            <option value="<?= $a ?>" <?= (int) ($editing['age'] ?? 6) === $a ? 'selected' : '' ?>><?= $a ?> سنوات</option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>المجال</label>
        <select name="category">
          <?php foreach ($CATS as $code => $name): ?>
            <option value="<?= $code ?>" <?= ($editing['category'] ?? '') === $code ? 'selected' : '' ?>><?= $name ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>الترتيب (خانة فريدة لكل عمر)</label>
        <input type="number" name="sort_order" value="<?= h($editing['sort_order'] ?? 0) ?>">
      </div>
    </div>
    <div style="margin-top:14px">
      <label>نص السؤال</label>
      <textarea name="question" required><?= h($editing['question'] ?? '') ?></textarea>
    </div>
    <div class="grid" style="margin-top:14px">
      <?php foreach (['a','b','c','d'] as $i => $key): ?>
        <div>
          <label>الخيار <?= $LETTERS[$i] ?></label>
          <input type="text" name="option_<?= $key ?>" value="<?= h($editing['option_' . $key] ?? '') ?>" <?= $i < 2 ? 'required' : '' ?>>
        </div>
      <?php endforeach; ?>
    </div>
    <div style="margin-top:14px; max-width:260px">
      <label>الإجابة الصحيحة</label>
      <select name="correct_index">
        <?php foreach ($LETTERS as $i => $l): ?>
          <option value="<?= $i ?>" <?= (int) ($editing['correct_index'] ?? 0) === $i ? 'selected' : '' ?>>الخيار <?= $l ?></option>
        <?php endforeach; ?>
      </select>
    </div>
    <div style="margin-top:16px; display:flex; gap:8px">
      <button class="btn ok" type="submit"><?= $editing ? 'حفظ التعديل' : 'إضافة' ?></button>
      <?php if ($editing): ?><a class="btn ghost" href="questions.php">إلغاء</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="card">
  <h2>كل الأسئلة (<?= count($rows) ?>)</h2>
  <table>
    <tr><th>#</th><th>العمر</th><th>المجال</th><th>السؤال</th><th>الإجابة الصحيحة</th><th>إجراءات</th></tr>
    <?php foreach ($rows as $q): ?>
      <tr>
        <td><?= (int) $q['id'] ?></td>
        <td><?= (int) $q['age'] ?></td>
        <td><span class="pill"><?= h($CATS[$q['category']] ?? $q['category']) ?></span></td>
        <td><?= h($q['question']) ?></td>
        <td><strong><?= h($q['option_' . ['a','b','c','d'][(int) $q['correct_index']]]) ?></strong></td>
        <td>
          <div class="row-actions">
            <a class="btn ghost sm" href="questions.php?edit=<?= (int) $q['id'] ?>">تعديل</a>
            <form method="post" onsubmit="return confirm('حذف هذا السؤال؟');" style="display:inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<?= (int) $q['id'] ?>">
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

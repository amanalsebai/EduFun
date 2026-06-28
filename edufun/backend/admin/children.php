<?php
// إدارة الأطفال — إضافة/تعديل/حذف + عرض النجوم.
require_once __DIR__ . '/inc.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM children WHERE id = ?");
        $stmt->execute([(int) $_POST['id']]);
        flash('children.php', 'تم حذف الطفل');
    }

    $data = [
        trim($_POST['name'] ?? ''),
        (int) ($_POST['age'] ?? 6),
        (int) ($_POST['total_stars'] ?? 0),
    ];

    if ($action === 'create' && $data[0] !== '') {
        $stmt = $pdo->prepare("INSERT INTO children (name, age, total_stars) VALUES (?, ?, ?)");
        $stmt->execute($data);
        flash('children.php', 'تمت إضافة الطفل');
    }

    if ($action === 'update') {
        $data[] = (int) $_POST['id'];
        $stmt = $pdo->prepare("UPDATE children SET name=?, age=?, total_stars=? WHERE id=?");
        $stmt->execute($data);
        flash('children.php', 'تم تحديث بيانات الطفل');
    }
    redirect('children.php');
}

$editing = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM children WHERE id = ?");
    $stmt->execute([(int) $_GET['edit']]);
    $editing = $stmt->fetch();
}

$rows = $pdo->query("SELECT * FROM children ORDER BY id")->fetchAll();

render_header('الأطفال');
?>
<div class="card">
  <h2><?= $editing ? '✏️ تعديل طفل' : '➕ إضافة طفل جديد' ?></h2>
  <form method="post">
    <input type="hidden" name="action" value="<?= $editing ? 'update' : 'create' ?>">
    <?php if ($editing): ?><input type="hidden" name="id" value="<?= (int) $editing['id'] ?>"><?php endif; ?>
    <div class="grid">
      <div>
        <label>الاسم</label>
        <input type="text" name="name" value="<?= h($editing['name'] ?? '') ?>" required>
      </div>
      <div>
        <label>العمر</label>
        <select name="age">
          <?php foreach ([6,7,8,9] as $a): ?>
            <option value="<?= $a ?>" <?= (int) ($editing['age'] ?? 6) === $a ? 'selected' : '' ?>><?= $a ?> سنوات</option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>عدد النجوم</label>
        <input type="number" name="total_stars" value="<?= h($editing['total_stars'] ?? 0) ?>">
      </div>
    </div>
    <div style="margin-top:16px; display:flex; gap:8px">
      <button class="btn ok" type="submit"><?= $editing ? 'حفظ التعديل' : 'إضافة' ?></button>
      <?php if ($editing): ?><a class="btn ghost" href="children.php">إلغاء</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="card">
  <h2>كل الأطفال (<?= count($rows) ?>)</h2>
  <table>
    <tr><th>#</th><th>الاسم</th><th>العمر</th><th>⭐ النجوم</th><th>تاريخ الإنشاء</th><th>إجراءات</th></tr>
    <?php foreach ($rows as $c): ?>
      <tr>
        <td><?= (int) $c['id'] ?></td>
        <td><?= h($c['name']) ?></td>
        <td><?= (int) $c['age'] ?></td>
        <td><?= (int) $c['total_stars'] ?></td>
        <td><span class="pill"><?= h($c['created_at']) ?></span></td>
        <td>
          <div class="row-actions">
            <a class="btn ghost sm" href="children.php?edit=<?= (int) $c['id'] ?>">تعديل</a>
            <form method="post" onsubmit="return confirm('حذف هذا الطفل وكل بياناته؟');" style="display:inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<?= (int) $c['id'] ?>">
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

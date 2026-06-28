<?php
// إدارة مكتبة الفيديوهات (الدروس) — إضافة/تعديل/حذف.
require_once __DIR__ . '/inc.php';

$SUBJECTS = ['math' => 'الرياضيات', 'language' => 'اللغة', 'logic' => 'المنطق'];

// ─────────── معالجة العمليات (POST) ───────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM videos WHERE id = ?");
        $stmt->execute([(int) $_POST['id']]);
        flash('videos.php', 'تم حذف الفيديو');
    }

    $data = [
        $_POST['subject_code'] ?? 'math',
        trim($_POST['title'] ?? ''),
        trim($_POST['channel'] ?? ''),
        trim($_POST['url'] ?? ''),
        trim($_POST['thumbnail'] ?? ''),
        (int) ($_POST['min_age'] ?? 6),
        (int) ($_POST['sort_order'] ?? 0),
    ];

    if ($action === 'create' && $data[1] !== '' && $data[3] !== '') {
        $stmt = $pdo->prepare(
            "INSERT INTO videos (subject_code, title, channel, url, thumbnail, min_age, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        $stmt->execute($data);
        flash('videos.php', 'تمت إضافة الفيديو');
    }

    if ($action === 'update') {
        $data[] = (int) $_POST['id'];
        $stmt = $pdo->prepare(
            "UPDATE videos SET subject_code=?, title=?, channel=?, url=?, thumbnail=?, min_age=?, sort_order=?
             WHERE id=?"
        );
        $stmt->execute($data);
        flash('videos.php', 'تم تحديث الفيديو');
    }
    redirect('videos.php');
}

// الفيديو قيد التعديل (إن وُجد)
$editing = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM videos WHERE id = ?");
    $stmt->execute([(int) $_GET['edit']]);
    $editing = $stmt->fetch();
}

$videos = $pdo->query("SELECT * FROM videos ORDER BY subject_code, sort_order, id")->fetchAll();

render_header('الفيديوهات');
?>
<div class="card">
  <h2><?= $editing ? '✏️ تعديل فيديو' : '➕ إضافة فيديو جديد' ?></h2>
  <form method="post">
    <input type="hidden" name="action" value="<?= $editing ? 'update' : 'create' ?>">
    <?php if ($editing): ?><input type="hidden" name="id" value="<?= (int) $editing['id'] ?>"><?php endif; ?>
    <div class="grid">
      <div>
        <label>المجال</label>
        <select name="subject_code">
          <?php foreach ($SUBJECTS as $code => $name): ?>
            <option value="<?= $code ?>" <?= ($editing['subject_code'] ?? '') === $code ? 'selected' : '' ?>><?= $name ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>العمر الأدنى</label>
        <input type="number" name="min_age" min="6" max="9" value="<?= h($editing['min_age'] ?? 6) ?>">
      </div>
      <div>
        <label>الترتيب</label>
        <input type="number" name="sort_order" value="<?= h($editing['sort_order'] ?? 0) ?>">
      </div>
    </div>
    <div style="margin-top:14px">
      <label>عنوان الفيديو</label>
      <input type="text" name="title" value="<?= h($editing['title'] ?? '') ?>" required>
    </div>
    <div class="grid" style="margin-top:14px">
      <div>
        <label>القناة</label>
        <input type="text" name="channel" value="<?= h($editing['channel'] ?? '') ?>">
      </div>
      <div>
        <label>رابط YouTube</label>
        <input type="url" name="url" value="<?= h($editing['url'] ?? '') ?>" required>
      </div>
    </div>
    <div style="margin-top:14px">
      <label>رابط الصورة المصغّرة (اختياري — يُولَّد تلقائياً إن تُرك فارغاً للأنماط المعتادة)</label>
      <input type="url" name="thumbnail" value="<?= h($editing['thumbnail'] ?? '') ?>">
      <div class="hint">مثال: https://img.youtube.com/vi/&lt;معرّف_الفيديو&gt;/0.jpg</div>
    </div>
    <div style="margin-top:16px; display:flex; gap:8px">
      <button class="btn ok" type="submit"><?= $editing ? 'حفظ التعديل' : 'إضافة' ?></button>
      <?php if ($editing): ?><a class="btn ghost" href="videos.php">إلغاء</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="card">
  <h2>كل الفيديوهات (<?= count($videos) ?>)</h2>
  <table>
    <tr><th>#</th><th>المجال</th><th>العنوان</th><th>القناة</th><th>العمر</th><th>الترتيب</th><th>إجراءات</th></tr>
    <?php foreach ($videos as $v): ?>
      <tr>
        <td><?= (int) $v['id'] ?></td>
        <td><span class="pill"><?= h($SUBJECTS[$v['subject_code']] ?? $v['subject_code']) ?></span></td>
        <td><a href="<?= h($v['url']) ?>" target="_blank"><?= h($v['title']) ?></a></td>
        <td><?= h($v['channel']) ?></td>
        <td><?= (int) $v['min_age'] ?></td>
        <td><?= (int) $v['sort_order'] ?></td>
        <td>
          <div class="row-actions">
            <a class="btn ghost sm" href="videos.php?edit=<?= (int) $v['id'] ?>">تعديل</a>
            <form method="post" onsubmit="return confirm('حذف هذا الفيديو؟');" style="display:inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<?= (int) $v['id'] ?>">
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

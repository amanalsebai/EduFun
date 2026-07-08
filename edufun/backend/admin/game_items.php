<?php
// إدارة محتوى الألعاب النصية (game_items) — إضافة/تعديل/حذف بحقول واضحة لكل لعبة.
// المستخدم لا يكتب JSON إطلاقاً: أسماء الحقول تتبدّل حسب اللعبة المختارة.
require_once __DIR__ . '/inc.php';

// الألعاب النصية التي لها محتوى قابل للتحرير (بأسماء ودّية).
$textGames = [
    'word_game'        => 'ترتيب الكلمات',
    'english_spelling' => 'التهجئة الإنجليزية',
    'sentence_game'    => 'تكوين الجُمل',
    'ar_en_matching'   => 'توصيل عربي-إنجليزي',
    'grammar_matching' => 'توصيل الإعراب',
    'question_builder' => 'صانع الأسئلة',
    'error_hunter'     => 'صائد الأخطاء',
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'delete') {
        $pdo->prepare("DELETE FROM game_items WHERE id = ?")->execute([(int) $_POST['id']]);
        flash('game_items.php', 'تم حذف العنصر');
    }

    $data = [
        trim($_POST['game_code'] ?? ''),        // 0
        (int) ($_POST['level_number'] ?? 1),    // 1
        trim($_POST['text1'] ?? ''),            // 2
        trim($_POST['text2'] ?? ''),            // 3
        trim($_POST['text3'] ?? ''),            // 4
        trim($_POST['text4'] ?? ''),            // 5
        (int) ($_POST['sort_order'] ?? 0),      // 6
        isset($_POST['is_active']) ? 1 : 0,     // 7
    ];

    if ($action === 'create' && $data[0] !== '' && $data[2] !== '') {
        $pdo->prepare(
            "INSERT INTO game_items (game_code, level_number, text1, text2, text3, text4, sort_order, is_active)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        )->execute($data);
        flash('game_items.php?game=' . urlencode($data[0]), 'تمت إضافة العنصر');
    }

    if ($action === 'update') {
        $data[] = (int) $_POST['id'];
        $pdo->prepare(
            "UPDATE game_items
             SET game_code=?, level_number=?, text1=?, text2=?, text3=?, text4=?, sort_order=?, is_active=?
             WHERE id=?"
        )->execute($data);
        flash('game_items.php?game=' . urlencode($data[0]), 'تم تحديث العنصر');
    }
    redirect('game_items.php');
}

$editing = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM game_items WHERE id = ?");
    $stmt->execute([(int) $_GET['edit']]);
    $editing = $stmt->fetch();
}

// فلترة القائمة حسب لعبة (اختياري).
$filter = $_GET['game'] ?? ($editing['game_code'] ?? '');
if ($filter !== '' && isset($textGames[$filter])) {
    $stmt = $pdo->prepare(
        "SELECT * FROM game_items WHERE game_code = ? ORDER BY level_number, sort_order, id"
    );
    $stmt->execute([$filter]);
    $rows = $stmt->fetchAll();
} else {
    $rows = $pdo->query("SELECT * FROM game_items ORDER BY game_code, level_number, sort_order, id")->fetchAll();
}

$activeChecked = (!$editing || (int) ($editing['is_active'] ?? 1) === 1) ? 'checked' : '';

render_header('محتوى الألعاب');
?>
<div class="card">
  <h2><?= $editing ? '✏️ تعديل عنصر' : '➕ إضافة عنصر جديد' ?></h2>
  <p class="hint">✨ اختر اللعبة أولاً، وستظهر لك الحقول المناسبة بأسمائها الواضحة. لا حاجة لكتابة أي رموز.
     كل عنصر يخصّ <b>مستوى</b> معيّناً — أضِف عناصر أكثر لنفس المستوى لزيادة المحتوى (مثلاً كلمات أكثر).</p>
  <form method="post">
    <input type="hidden" name="action" value="<?= $editing ? 'update' : 'create' ?>">
    <?php if ($editing): ?><input type="hidden" name="id" value="<?= (int) $editing['id'] ?>"><?php endif; ?>
    <div class="grid">
      <div>
        <label>اللعبة</label>
        <select name="game_code" id="game_code" required onchange="applyLabels()">
          <option value="">— اختر اللعبة —</option>
          <?php foreach ($textGames as $code => $name): ?>
            <option value="<?= h($code) ?>" <?= ($editing['game_code'] ?? '') === $code ? 'selected' : '' ?>><?= h($name) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label>رقم المستوى</label>
        <input type="number" name="level_number" min="1" max="20" value="<?= h($editing['level_number'] ?? 1) ?>">
      </div>
      <div>
        <label>الترتيب داخل المستوى</label>
        <input type="number" name="sort_order" value="<?= h($editing['sort_order'] ?? 0) ?>">
      </div>
    </div>

    <div id="f_text1" style="margin-top:14px">
      <label id="l_text1">الحقل 1</label>
      <input type="text" name="text1" id="text1" value="<?= h($editing['text1'] ?? '') ?>">
    </div>
    <div id="f_text2" style="margin-top:14px">
      <label id="l_text2">الحقل 2</label>
      <input type="text" name="text2" id="text2" value="<?= h($editing['text2'] ?? '') ?>">
    </div>
    <div id="f_text3" style="margin-top:14px">
      <label id="l_text3">الحقل 3</label>
      <input type="text" name="text3" id="text3" value="<?= h($editing['text3'] ?? '') ?>">
    </div>
    <div id="f_text4" style="margin-top:14px">
      <label id="l_text4">الحقل 4</label>
      <input type="text" name="text4" id="text4" value="<?= h($editing['text4'] ?? '') ?>">
    </div>

    <div style="margin-top:14px">
      <label style="display:flex; align-items:center; gap:8px; cursor:pointer">
        <input type="checkbox" name="is_active" value="1" <?= $activeChecked ?> style="width:auto; margin:0">
        <span>مُفعّل (يظهر في التطبيق)</span>
      </label>
    </div>
    <div style="margin-top:16px; display:flex; gap:8px">
      <button class="btn ok" type="submit"><?= $editing ? 'حفظ التعديل' : 'إضافة' ?></button>
      <?php if ($editing): ?><a class="btn ghost" href="game_items.php">إلغاء</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="card">
  <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px">
    <h2 style="margin:0">المحتوى (<?= count($rows) ?>)</h2>
    <form method="get" style="display:flex; gap:8px; align-items:center">
      <label style="margin:0">تصفية:</label>
      <select name="game" onchange="this.form.submit()" style="width:auto">
        <option value="">كل الألعاب</option>
        <?php foreach ($textGames as $code => $name): ?>
          <option value="<?= h($code) ?>" <?= $filter === $code ? 'selected' : '' ?>><?= h($name) ?></option>
        <?php endforeach; ?>
      </select>
    </form>
  </div>
  <table style="margin-top:14px">
    <tr><th>اللعبة</th><th>مستوى</th><th>المحتوى</th><th>مفعّل</th><th>إجراءات</th></tr>
    <?php foreach ($rows as $it):
      $parts = array_filter([$it['text1'], $it['text2'], $it['text3'], $it['text4']], fn($v) => $v !== '');
    ?>
      <tr style="<?= (int) $it['is_active'] === 0 ? 'opacity:.55' : '' ?>">
        <td><?= h($textGames[$it['game_code']] ?? $it['game_code']) ?></td>
        <td style="text-align:center"><?= (int) $it['level_number'] ?></td>
        <td><?= h(implode('  •  ', $parts)) ?></td>
        <td style="text-align:center"><?= (int) $it['is_active'] === 1 ? '✅' : '🚫' ?></td>
        <td>
          <div class="row-actions">
            <a class="btn ghost sm" href="game_items.php?edit=<?= (int) $it['id'] ?>">تعديل</a>
            <form method="post" onsubmit="return confirm('حذف هذا العنصر؟');" style="display:inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<?= (int) $it['id'] ?>">
              <button class="btn danger sm" type="submit">حذف</button>
            </form>
          </div>
        </td>
      </tr>
    <?php endforeach; ?>
  </table>
</div>

<script>
// أسماء الحقول لكل لعبة (null = الحقل غير مستخدم فيُخفى).
const FIELDS = {
  word_game:        {text1:'الكلمة',                          text2:'الإيموجي',              text3:null,               text4:null},
  english_spelling: {text1:'الكلمة (بالإنجليزية)',            text2:'الإيموجي',              text3:'التلميح',          text4:null},
  sentence_game:    {text1:'الجملة الصحيحة (كلمات بمسافات)',  text2:null,                    text3:null,               text4:null},
  ar_en_matching:   {text1:'الكلمة بالعربية',                 text2:'بالإنجليزية',            text3:'الإيموجي',         text4:null},
  grammar_matching: {text1:'الجملة كاملة',                    text2:'الكلمة',                text3:'إعرابها',          text4:null},
  question_builder: {text1:'الإجابة (بالإنجليزية)',           text2:'السؤال الصحيح (إنجليزي)',text3:'التلميح',          text4:null},
  error_hunter:     {text1:'الجملة كاملة (كلمات بمسافات)',    text2:'الكلمة الخطأ',          text3:'الكلمة الصحيحة',   text4:'التلميح'},
};

function applyLabels() {
  const code = document.getElementById('game_code').value;
  const map = FIELDS[code] || {text1:'الحقل 1', text2:'الحقل 2', text3:'الحقل 3', text4:'الحقل 4'};
  ['text1','text2','text3','text4'].forEach(function(key) {
    const label = map[key];
    const wrap = document.getElementById('f_' + key);
    if (label) {
      document.getElementById('l_' + key).textContent = label;
      wrap.style.display = '';
    } else {
      wrap.style.display = 'none';
      document.getElementById(key).value = ''; // امسح القيمة غير المستخدمة
    }
  });
}
applyLabels(); // طبّق عند التحميل (يشمل حالة التعديل)
</script>
<?php
render_footer();

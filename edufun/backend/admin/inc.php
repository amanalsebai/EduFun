<?php
// =====================================================================
//  لوحة إدارة EduFun — ملف مشترك (اتصال القاعدة + الترويسة/التذييل + أدوات).
//  بدون حماية: مخصّصة للتشغيل المحلي على XAMPP.
//  الرابط:  http://localhost/edufun/admin/
// =====================================================================

// نعيد استخدام نفس إعدادات اتصال الـ API (PDO + utf8mb4).
require_once __DIR__ . '/../api/config/database.php';

/** اتصال PDO جاهز للاستخدام في كل صفحات اللوحة. */
$pdo = (new Database())->connect();

/** تهريب آمن للنصوص قبل عرضها في HTML. */
function h($s) { return htmlspecialchars((string) $s, ENT_QUOTES, 'UTF-8'); }

/** إعادة توجيه (نمط Post/Redirect/Get لمنع إعادة إرسال النموذج). */
function redirect($to) { header("Location: $to"); exit; }

/** رسالة نجاح تُمرَّر عبر ?msg= بعد العمليات. */
function flash($page, $msg) { redirect($page . '?msg=' . urlencode($msg)); }

/** أسماء المجالات بالعربية. */
function subjectName($code) {
    return ['math' => 'الرياضيات', 'language' => 'اللغة', 'logic' => 'المنطق'][$code] ?? $code;
}

/** ترويسة الصفحة + شريط التنقّل + الأنماط. */
function render_header($title) {
    $nav = [
        'index.php'     => '🏠 الرئيسية',
        'children.php'  => '🧒 الأطفال',
        'games.php'     => '🎮 الألعاب',
        'levels.php'    => '🎯 المراحل',
        'game_items.php' => '📝 محتوى الألعاب',
        'videos.php'    => '🎬 الفيديوهات',
        'questions.php' => '❓ أسئلة التقييم',
    ];
    $current = basename($_SERVER['PHP_SELF']);
    $msg = isset($_GET['msg']) ? $_GET['msg'] : '';
    ?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= h($title) ?> — لوحة EduFun</title>
  <style>
    :root { --p:#5b3df5; --p2:#7a5cff; --bg:#f4f5fb; --ink:#1f2233; --muted:#6b7088; --line:#e6e8f2; --ok:#13a05c; --danger:#e23d57; }
    * { box-sizing:border-box; }
    body { margin:0; font-family:"Segoe UI",Tahoma,Arial,sans-serif; background:var(--bg); color:var(--ink); }
    header { background:linear-gradient(120deg,var(--p),var(--p2)); color:#fff; padding:18px 24px; box-shadow:0 4px 18px rgba(91,61,245,.25); }
    header h1 { margin:0; font-size:20px; }
    header .sub { opacity:.85; font-size:13px; margin-top:2px; }
    nav { display:flex; flex-wrap:wrap; gap:8px; padding:12px 24px; background:#fff; border-bottom:1px solid var(--line); position:sticky; top:0; z-index:5; }
    nav a { text-decoration:none; color:var(--ink); padding:8px 14px; border-radius:10px; font-weight:600; font-size:14px; }
    nav a:hover { background:var(--bg); }
    nav a.active { background:var(--p); color:#fff; }
    main { max-width:1000px; margin:24px auto; padding:0 16px; }
    .card { background:#fff; border:1px solid var(--line); border-radius:16px; padding:20px; margin-bottom:22px; box-shadow:0 2px 10px rgba(31,34,51,.04); }
    .card h2 { margin:0 0 14px; font-size:17px; }
    table { width:100%; border-collapse:collapse; font-size:14px; }
    th, td { text-align:right; padding:10px 12px; border-bottom:1px solid var(--line); vertical-align:middle; }
    th { color:var(--muted); font-weight:700; background:#fafbff; }
    tr:hover td { background:#fafbff; }
    input, select, textarea { width:100%; padding:10px 12px; border:1px solid var(--line); border-radius:10px; font:inherit; background:#fff; }
    textarea { resize:vertical; min-height:54px; }
    label { display:block; font-size:13px; font-weight:600; margin:0 0 6px; color:var(--muted); }
    .grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; }
    .btn { display:inline-block; border:none; cursor:pointer; padding:9px 16px; border-radius:10px; font:inherit; font-weight:700; color:#fff; background:var(--p); text-decoration:none; }
    .btn:hover { filter:brightness(1.05); }
    .btn.ok { background:var(--ok); }
    .btn.danger { background:var(--danger); }
    .btn.ghost { background:#fff; color:var(--ink); border:1px solid var(--line); }
    .btn.sm { padding:6px 11px; font-size:13px; }
    .row-actions { display:flex; gap:6px; }
    .flash { background:#e7faf0; color:var(--ok); border:1px solid #b8eccf; padding:12px 16px; border-radius:12px; margin-bottom:18px; font-weight:600; }
    .pill { background:var(--bg); border:1px solid var(--line); border-radius:999px; padding:3px 10px; font-size:12px; color:var(--muted); }
    .stat-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr)); gap:16px; }
    .stat { background:linear-gradient(120deg,#fff,#fafbff); border:1px solid var(--line); border-radius:16px; padding:18px; }
    .stat .n { font-size:30px; font-weight:800; color:var(--p); }
    .stat .l { color:var(--muted); font-size:14px; margin-top:4px; }
    .hint { color:var(--muted); font-size:12px; margin-top:4px; }
  </style>
</head>
<body>
  <header>
    <h1>🎓 لوحة إدارة EduFun</h1>
    <div class="sub">إدارة الأطفال والألعاب والفيديوهات وأسئلة التقييم — تشغيل محلي على XAMPP</div>
  </header>
  <nav>
    <?php foreach ($nav as $file => $label): ?>
      <a href="<?= $file ?>" class="<?= $current === $file ? 'active' : '' ?>"><?= $label ?></a>
    <?php endforeach; ?>
  </nav>
  <main>
    <?php if ($msg !== ''): ?>
      <div class="flash">✅ <?= h($msg) ?></div>
    <?php endif; ?>
<?php
}

/** تذييل الصفحة. */
function render_footer() {
    ?>
  </main>
</body>
</html>
<?php
}

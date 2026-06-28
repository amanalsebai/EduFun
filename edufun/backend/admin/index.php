<?php
// لوحة التحكم الرئيسية — إحصائيات سريعة.
require_once __DIR__ . '/inc.php';

$counts = [
    'children'  => (int) $pdo->query("SELECT COUNT(*) FROM children")->fetchColumn(),
    'games'     => (int) $pdo->query("SELECT COUNT(*) FROM games")->fetchColumn(),
    'videos'    => (int) $pdo->query("SELECT COUNT(*) FROM videos")->fetchColumn(),
    'questions' => (int) $pdo->query("SELECT COUNT(*) FROM assessment_questions")->fetchColumn(),
];

render_header('الرئيسية');
?>
<div class="card">
  <h2>نظرة عامة</h2>
  <div class="stat-grid">
    <a class="stat" href="children.php" style="text-decoration:none;color:inherit">
      <div class="n"><?= $counts['children'] ?></div><div class="l">🧒 الأطفال</div></a>
    <a class="stat" href="games.php" style="text-decoration:none;color:inherit">
      <div class="n"><?= $counts['games'] ?></div><div class="l">🎮 الألعاب</div></a>
    <a class="stat" href="videos.php" style="text-decoration:none;color:inherit">
      <div class="n"><?= $counts['videos'] ?></div><div class="l">🎬 الفيديوهات</div></a>
    <a class="stat" href="questions.php" style="text-decoration:none;color:inherit">
      <div class="n"><?= $counts['questions'] ?></div><div class="l">❓ أسئلة التقييم</div></a>
  </div>
</div>

<div class="card">
  <h2>روابط مفيدة</h2>
  <p class="hint">الـ API الأساسي:</p>
  <ul>
    <li><a href="../api/ping.php" target="_blank">فحص الاتصال (ping)</a></li>
    <li><a href="../api/children/" target="_blank">/api/children/</a></li>
    <li><a href="../api/videos/" target="_blank">/api/videos/</a></li>
    <li><a href="../api/questions/" target="_blank">/api/questions/</a></li>
    <li><a href="http://localhost/phpmyadmin/" target="_blank">phpMyAdmin</a></li>
  </ul>
</div>
<?php
render_footer();

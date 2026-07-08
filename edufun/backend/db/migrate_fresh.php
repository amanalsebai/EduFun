<?php
/**
 * migrate:fresh --seed  (على نمط لارافيل) — بـ PHP خام.
 *
 * يحذف قاعدة البيانات edufun_db بالكامل، ثم يعيد إنشاء المخطّط ويزرع كل البيانات
 * الأوّلية (المجالات، الألعاب، المراحل، محتوى الألعاب، الفيديوهات، أسئلة التقييم).
 *
 * التشغيل:
 *   - سطر الأوامر:   php migrate_fresh.php
 *   - المتصفّح:      http://localhost/edufun/db/migrate_fresh.php?confirm=yes
 *
 * ⚠️ تحذير: يمحو كل البيانات الحالية (الأطفال، النجوم، التقدّم...). للتطوير المحلي فقط.
 *
 * ملاحظة: يستخدم عميل mysql.exe مع --default-character-set=utf8mb4 لضمان
 * استيراد النصوص العربية سليمة (بدون تشويه mojibake).
 */

// ── إعدادات (تطابق api/config/database.php) ──────────────────────────────
const DB_NAME  = 'edufun_db';
const DB_USER  = 'root';
const DB_PASS  = '';                                   // root بلا كلمة مرور (XAMPP الافتراضي)
$mysqlBin = getenv('MYSQL_BIN') ?: 'C:\\xampp\\mysql\\bin\\mysql.exe';
$sqlDir   = __DIR__;                                   // ملفات .sql بجانب هذا الملف

// ترتيب التنفيذ مهم: المخطّط أولاً، ثم إثراء الألعاب، ثم المحتوى/المراحل.
$files = [
    'edufun_schema.sql',      // المخطّط + بذور أساسية (children, subjects, games, videos...)
    'games_meta.sql',         // أعمدة إضافية للألعاب + إصلاح العناوين
    'edufun_content.sql',     // بذور الفيديوهات وأسئلة التقييم
    'edufun_levels.sql',      // جداول المراحل + بذورها
    'edufun_game_items.sql',  // محتوى الألعاب النصية
];

// ── حماية: من المتصفّح يتطلّب تأكيداً صريحاً + محلي فقط ───────────────────
$isCli = (PHP_SAPI === 'cli');
if (!$isCli) {
    header('Content-Type: text/plain; charset=utf-8');
    $remote = $_SERVER['REMOTE_ADDR'] ?? '';
    $isLocal = in_array($remote, ['127.0.0.1', '::1'], true);
    if (!$isLocal) {
        http_response_code(403);
        exit("مرفوض: هذه الأداة للتشغيل المحلي فقط.\n");
    }
    if (($_GET['confirm'] ?? '') !== 'yes') {
        exit("⚠️  هذه العملية ستحذف قاعدة البيانات بالكامل وتعيد زرعها.\n\n" .
             "للتأكيد افتح:\n  " .
             "http://localhost/edufun/db/migrate_fresh.php?confirm=yes\n");
    }
}

/** ينفّذ أمر mysql مع تمرير ملف SQL عبر stdin (يتجنّب مشاكل الاقتباس على ويندوز). */
function run_mysql(string $bin, array $args, ?string $stdinFile = null): array {
    $desc = [
        0 => $stdinFile ? ['file', $stdinFile, 'r'] : ['pipe', 'r'],
        1 => ['pipe', 'w'],
        2 => ['pipe', 'w'],
    ];
    $cmd = array_merge([$bin], $args);
    $proc = @proc_open($cmd, $desc, $pipes);
    if (!is_resource($proc)) {
        return [1, '', 'تعذّر تشغيل mysql — تحقّق من المسار: ' . $bin];
    }
    if (!$stdinFile) fclose($pipes[0]);
    $out = stream_get_contents($pipes[1]); fclose($pipes[1]);
    $err = stream_get_contents($pipes[2]); fclose($pipes[2]);
    $code = proc_close($proc);
    return [$code, $out, $err];
}

function say(string $msg) { echo $msg . "\n"; @flush(); }

// وسائط الاتصال المشتركة.
$auth = ['-u', DB_USER];
if (DB_PASS !== '') $auth[] = '-p' . DB_PASS;
$charset = '--default-character-set=utf8mb4';

say("== EduFun: migrate:fresh --seed ==");
say("عميل mysql: $mysqlBin");

// 1) إسقاط القاعدة (fresh).
[$code, , $err] = run_mysql($mysqlBin, array_merge($auth, ['-e', 'DROP DATABASE IF EXISTS ' . DB_NAME]));
if ($code !== 0) { say("✗ فشل حذف القاعدة: $err"); exit(1); }
say("✓ تم حذف القاعدة القديمة (إن وُجدت)");

// 2) تشغيل ملفات SQL بالترتيب.
$ok = 0;
foreach ($files as $i => $name) {
    $path = $sqlDir . DIRECTORY_SEPARATOR . $name;
    if (!is_file($path)) { say("… تخطّي (غير موجود): $name"); continue; }

    // الملف الأول ينشئ القاعدة (CREATE DATABASE)، فلا نمرّر اسم قاعدة له.
    $args = ($i === 0)
        ? array_merge($auth, [$charset])
        : array_merge($auth, [$charset, DB_NAME]);

    [$code, , $err] = run_mysql($mysqlBin, $args, $path);
    if ($code !== 0) {
        say("✗ فشل استيراد $name:\n$err");
        exit(1);
    }
    $ok++;
    say("✓ استُورد: $name");
}

say("");
say("🎉 اكتمل التهيئة والزرع بنجاح ($ok ملف).");
say("القاعدة '" . DB_NAME . "' جاهزة من جديد ببيانات أوّلية نظيفة.");

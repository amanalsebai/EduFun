<?php
// فحص الاتصال: يستخدمه زر الاتصال العائم (FAB) في فلاتر.
require_once __DIR__ . '/config/cors.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/helpers/response.php';

$db = (new Database())->connect();
ok(['server' => 'edufun', 'time' => date('c')], 'الاتصال ناجح ✅');

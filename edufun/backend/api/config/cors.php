<?php
// رؤوس CORS للسماح لفلاتر (ومتصفّح التطوير) بالاتصال.
// في الإنتاج: ضع نطاق التطبيق بدل *.
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=UTF-8');

// طلب OPTIONS التمهيدي (preflight) من المتصفّحات نردّ عليه فوراً.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

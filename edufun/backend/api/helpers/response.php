<?php
// استجابات JSON موحّدة الشكل لكل المسارات.
function send($success, $data = null, $message = '', $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data'    => $data,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function ok($data = null, $message = '')                { send(true,  $data, $message, 200); }
function created($data = null, $message = 'تم الإنشاء')  { send(true,  $data, $message, 201); }
function badRequest($message = 'طلب غير صالح')           { send(false, null, $message, 400); }
function notFound($message = 'غير موجود')                { send(false, null, $message, 404); }

// قراءة جسم الطلب JSON القادم من فلاتر.
function body() {
    $raw = file_get_contents('php://input');
    return json_decode($raw, true) ?? [];
}

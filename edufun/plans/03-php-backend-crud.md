# 03 — باك إند PHP وأنظمة CRUD

## 1. هيكلة المجلدات داخل XAMPP

كل ملفات الباك إند توضع في `xampp/htdocs/edufun/` لتصبح متاحة على
`http://localhost:80/edufun`:

```
xampp/htdocs/edufun/
├─ db/
│   └─ edufun_schema.sql          # سكربت القاعدة (الملف 02)
└─ api/
    ├─ config/
    │   ├─ database.php           # اتصال PDO بقاعدة البيانات
    │   └─ cors.php               # رؤوس CORS + معالجة OPTIONS
    ├─ helpers/
    │   └─ response.php           # دوال موحّدة لإرجاع JSON
    ├─ ping.php                   # فحص الاتصال (يستخدمه زر الـ FAB)
    ├─ children/
    │   └─ index.php              # CRUD كامل للأطفال
    ├─ progress/
    │   └─ index.php              # CRUD لتقدّم الألعاب
    ├─ scores/
    │   └─ index.php              # قراءة/تحديث الدرجات
    ├─ assessment/
    │   └─ index.php              # حفظ/قراءة التقييم
    └─ games/
        └─ index.php              # كتالوج الألعاب (CRUD للإدارة)
```

> **فكرة التوجيه (Routing):** Apache يوجّه `/edufun/api/children/` تلقائياً إلى
> `children/index.php`. داخل كل `index.php` نتفرّع حسب `$_SERVER['REQUEST_METHOD']`
> (GET/POST/PUT/DELETE) فننفّذ عملية CRUD المناسبة. لا حاجة لإطار عمل (framework).

---

## 2. الملفات المشتركة (Config & Helpers)

### `api/config/database.php` — اتصال PDO

```php
<?php
// إعدادات الاتصال بقاعدة البيانات على XAMPP (المستخدم الافتراضي root بلا كلمة مرور)
class Database {
    private $host = '127.0.0.1';
    private $db_name = 'edufun_db';
    private $username = 'root';
    private $password = '';
    private $charset = 'utf8mb4';
    public $conn;

    public function connect() {
        $this->conn = null;
        try {
            $dsn = "mysql:host={$this->host};dbname={$this->db_name};charset={$this->charset}";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            // ضمان الترميز العربي الصحيح
            $this->conn->exec("SET NAMES utf8mb4");
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'فشل الاتصال بقاعدة البيانات: ' . $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        return $this->conn;
    }
}
```

### `api/config/cors.php` — السماح لفلاتر بالاتصال

```php
<?php
// نسمح بالوصول من أي أصل (مناسب للتطوير المحلي).
// في الإنتاج: ضع نطاق التطبيق بدل *.
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=UTF-8');

// متصفّح الويب/فلاتر-ويب يرسل طلب OPTIONS تمهيدياً (preflight) — نردّ عليه فوراً.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}
```

### `api/helpers/response.php` — استجابات JSON موحّدة

```php
<?php
// شكل ثابت لكل الاستجابات حتى يسهل على فلاتر تحليلها.
function send($success, $data = null, $message = '', $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data'    => $data,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function ok($data = null, $message = '')          { send(true,  $data, $message, 200); }
function created($data = null, $message = 'تم الإنشاء') { send(true, $data, $message, 201); }
function badRequest($message = 'طلب غير صالح')      { send(false, null, $message, 400); }
function notFound($message = 'غير موجود')           { send(false, null, $message, 404); }

// قراءة جسم الطلب JSON من فلاتر
function body() {
    $raw = file_get_contents('php://input');
    return json_decode($raw, true) ?? [];
}
```

### `api/ping.php` — فحص الاتصال (لزر الـ FAB)

```php
<?php
require_once __DIR__ . '/config/cors.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/helpers/response.php';

// نتأكد أن السيرفر + القاعدة يعملان معاً
$db = (new Database())->connect();
ok(['server' => 'edufun', 'time' => date('c')], 'الاتصال ناجح ✅');
```

---

## 3. نمط الـ CRUD الكامل — مثال `children`

هذا الملف هو **القالب** لباقي الموارد. ادرسه جيداً ثم كرّره مع تعديل الجدول والحقول.

### `api/children/index.php`

```php
<?php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$id     = isset($_GET['id']) ? (int) $_GET['id'] : null;

switch ($method) {

    // ─────────── READ: قراءة طفل واحد أو كل الأطفال ───────────
    case 'GET':
        if ($id) {
            $stmt = $db->prepare("SELECT * FROM children WHERE id = ?");
            $stmt->execute([$id]);
            $row = $stmt->fetch();
            $row ? ok($row) : notFound('الطفل غير موجود');
        } else {
            $stmt = $db->query("SELECT * FROM children ORDER BY id DESC");
            ok($stmt->fetchAll());
        }
        break;

    // ─────────── CREATE: إضافة طفل ───────────
    case 'POST':
        $b = body();
        if (empty($b['name']) || empty($b['age'])) {
            badRequest('الاسم والعمر مطلوبان');
        }
        $stmt = $db->prepare(
            "INSERT INTO children (name, age, total_stars) VALUES (?, ?, ?)"
        );
        $stmt->execute([
            $b['name'],
            (int) $b['age'],
            (int) ($b['total_stars'] ?? 0),
        ]);
        $newId = (int) $db->lastInsertId();
        $row = $db->query("SELECT * FROM children WHERE id = $newId")->fetch();
        created($row, 'تم إنشاء الطفل');
        break;

    // ─────────── UPDATE: تعديل طفل ───────────
    case 'PUT':
        if (!$id) badRequest('المعرّف (id) مطلوب');
        $b = body();
        $stmt = $db->prepare(
            "UPDATE children
             SET name = COALESCE(?, name),
                 age = COALESCE(?, age),
                 total_stars = COALESCE(?, total_stars)
             WHERE id = ?"
        );
        $stmt->execute([
            $b['name'] ?? null,
            isset($b['age']) ? (int) $b['age'] : null,
            isset($b['total_stars']) ? (int) $b['total_stars'] : null,
            $id,
        ]);
        $row = $db->query("SELECT * FROM children WHERE id = $id")->fetch();
        $row ? ok($row, 'تم التحديث') : notFound('الطفل غير موجود');
        break;

    // ─────────── DELETE: حذف طفل ───────────
    case 'DELETE':
        if (!$id) badRequest('المعرّف (id) مطلوب');
        $stmt = $db->prepare("DELETE FROM children WHERE id = ?");
        $stmt->execute([$id]);
        $stmt->rowCount() > 0 ? ok(null, 'تم الحذف') : notFound('الطفل غير موجود');
        break;

    default:
        badRequest('طريقة غير مدعومة');
}
```

النقاط المهمّة في هذا القالب:
- **Prepared Statements** دائماً (`prepare` + `execute`) لمنع حقن SQL.
- التحقّق من المدخلات قبل الكتابة.
- استجابة JSON موحّدة عبر `response.php`.
- رموز حالة HTTP صحيحة (200/201/400/404).

---

## 4. مثال CRUD مع منطق إضافي — `progress`

عند إنهاء لعبة نسجّل التقدّم **و** نزيد نجوم الطفل (نفس منطق `ProgressManager`).

### `api/progress/index.php`

```php
<?php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

$db     = (new Database())->connect();
$method = $_SERVER['REQUEST_METHOD'];
$childId = isset($_GET['child_id']) ? (int) $_GET['child_id'] : null;

switch ($method) {

    // كل تقدّم طفل معيّن:  GET /progress/?child_id=1
    case 'GET':
        if (!$childId) badRequest('child_id مطلوب');
        $stmt = $db->prepare("SELECT * FROM game_progress WHERE child_id = ?");
        $stmt->execute([$childId]);
        ok($stmt->fetchAll());
        break;

    // تسجيل فوز بلعبة:  POST /progress/
    // body: {"child_id":1,"game_code":"word_game","stars":3}
    case 'POST':
        $b = body();
        if (empty($b['child_id']) || empty($b['game_code'])) {
            badRequest('child_id و game_code مطلوبان');
        }
        $stars = (int) ($b['stars'] ?? 0);

        // معاملة (transaction) لضمان تماسك التقدّم + النجوم
        $db->beginTransaction();
        try {
            // UPSERT: أنشئ السجل أو علّمه مكتملاً (UNIQUE child_id+game_code)
            $stmt = $db->prepare(
                "INSERT INTO game_progress (child_id, game_code, completed, stars_earned, completed_at)
                 VALUES (?, ?, 1, ?, NOW())
                 ON DUPLICATE KEY UPDATE completed = 1,
                     stars_earned = GREATEST(stars_earned, VALUES(stars_earned)),
                     completed_at = NOW()"
            );
            $stmt->execute([$b['child_id'], $b['game_code'], $stars]);

            // زيادة مجموع نجوم الطفل
            $upd = $db->prepare(
                "UPDATE children SET total_stars = total_stars + ? WHERE id = ?"
            );
            $upd->execute([$stars, $b['child_id']]);

            $db->commit();
        } catch (Exception $e) {
            $db->rollBack();
            send(false, null, 'فشل تسجيل التقدّم', 500);
        }
        created(['child_id' => (int)$b['child_id'], 'game_code' => $b['game_code']]);
        break;

    default:
        badRequest('طريقة غير مدعومة');
}
```

---

## 5. باقي الموارد (نفس القالب)

- **`scores/index.php`**: `GET ?child_id=` يعيد الدرجات الثلاث،
  `PUT ?child_id=` يحدّث `child_scores` لكل مجال (UPSERT على `child_id+subject_id`).
- **`assessment/index.php`**: `POST` يُدخل سجلّاً في `assessments`،
  `GET ?child_id=` يعيد آخر تقييم.
- **`games/index.php`**: `GET` يعيد الكتالوج (اختيارياً `?min_age=`)؛
  ولأغراض الإدارة يدعم POST/PUT/DELETE بنفس قالب `children`.

كل التواقيع (المسارات والحقول) موثّقة في [04-api-documentation.md](04-api-documentation.md).

---

## 6. ملاحظات أمان للتطوير المحلي

- المستخدم `root` بلا كلمة مرور مقبول **للتطوير على اللابتوب فقط**. لا تنشره كما هو.
- `Access-Control-Allow-Origin: *` مناسب للتطوير؛ قيّده في الإنتاج.
- لا تطبع رسائل أخطاء قاعدة البيانات التفصيلية في الإنتاج (تكشف بنية النظام).
- استخدم HTTPS وكلمة مرور قوية ومستخدم MySQL محدود الصلاحيات قبل أي نشر حقيقي.

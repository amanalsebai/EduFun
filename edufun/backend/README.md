# EduFun — الباك إند (PHP + MySQL على XAMPP)

هذا المجلد (`backend/`) يحتوي على الخادم بالكامل. انسخه إلى داخل `htdocs` في XAMPP
ليصبح متاحاً على `http://localhost/edufun/api`.

## البنية

```
backend/
├─ db/
│   └─ edufun_schema.sql     # مخطّط + بيانات أوّلية (seed)
└─ api/
    ├─ .htaccess             # توجيه /children/ → children/index.php
    ├─ ping.php              # فحص الاتصال
    ├─ config/
    │   ├─ database.php      # اتصال PDO (utf8mb4)
    │   └─ cors.php          # رؤوس CORS + معالجة OPTIONS
    ├─ helpers/
    │   └─ response.php      # ok() / created() / badRequest() / notFound() / body()
    ├─ children/index.php    # CRUD الأطفال
    ├─ progress/index.php    # تسجيل إكمال لعبة + زيادة النجوم بالفرق فقط
    ├─ scores/index.php      # قراءة/تحديث درجات المجالات
    ├─ assessment/index.php  # حفظ/قراءة التقييم المبدئي
    └─ games/index.php       # كتالوج الألعاب (+ CRUD للإدارة)
```

## النشر على XAMPP

1. ثبّت XAMPP وشغّل **Apache** و **MySQL** من لوحة التحكم.
2. انسخ محتوى هذا المجلد ليصبح:

   ```
   C:\xampp\htdocs\edufun\api\...      (محتوى backend/api)
   C:\xampp\htdocs\edufun\db\...       (محتوى backend/db)
   ```

   أو ببساطة انسخ `backend/*` إلى مجلد جديد اسمه `edufun` داخل `htdocs` (مع إعادة تسمية
   إن أردت). الأهم أن تصبح المسارات:
   ```
   http://localhost/edufun/api/ping.php
   ```

3. أنشئ القاعدة باستيراد المخطّط:
   - **phpMyAdmin:** افتح `http://localhost/phpmyadmin` ← Import ← اختر
     `backend/db/edufun_schema.sql` ← Go.
   - **سطر الأوامر:**
     ```powershell
     & "C:\xampp\mysql\bin\mysql.exe" -u root < "C:\xampp\htdocs\edufun\db\edufun_schema.sql"
     ```

## اختبار سريع

```bash
# فحص الاتصال (يجب أن يرجع success:true)
curl http://localhost/edufun/api/ping.php

# إنشاء طفل
curl -X POST http://localhost/edufun/api/children/ \
  -H "Content-Type: application/json" \
  -d '{"name":"سارة","age":7}'

# قراءة كل الأطفال
curl http://localhost/edufun/api/children/

# تسجيل فوز بلعبة (يزيد النجوم بالفرق فقط لمنع التضخّم)
curl -X POST http://localhost/edufun/api/progress/ \
  -H "Content-Type: application/json" \
  -d '{"child_id":1,"game_code":"word_game","stars":50}'
```

## الوصول من هاتف حقيقي

اكتب في زر الاتصال داخل التطبيق **IP اللابتوب على الواي‑فاي** (مثلاً `192.168.1.20`)
على البورت `80`. لا تنسَ فتح البورت في جدار Windows الناري:

```powershell
# في PowerShell كمسؤول
New-NetFirewallRule -DisplayName "Apache HTTP 80" -Direction Inbound `
  -Protocol TCP -LocalPort 80 -Action Allow
```

كل التفاصيل في `plans/07-xampp-setup.md`.

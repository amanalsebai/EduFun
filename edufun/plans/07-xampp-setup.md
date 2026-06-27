# 07 — إعداد XAMPP والشبكة والمسار `/edufun`

## 1. تثبيت وتشغيل XAMPP

1. ثبّت XAMPP (يتضمّن Apache + MySQL/MariaDB + PHP).
2. افتح **XAMPP Control Panel** وشغّل:
   - **Apache** (سيرفر الويب — البورت 80).
   - **MySQL** (قاعدة البيانات — البورت 3306).
3. تحقّق: افتح `http://localhost` في المتصفح — يجب أن تظهر صفحة XAMPP.

> لو كان البورت 80 مشغولاً (مثلاً بسبب IIS أو Skype):
> غيّره من Apache → Config → `httpd.conf`: بدّل `Listen 80` إلى `Listen 8080`،
> وعندها يصبح المسار `http://localhost:8080/edufun` (واكتب `8080` في زر الـ FAB).

## 2. وضع مشروع الباك إند في المسار الصحيح

ضع مجلد المشروع داخل `htdocs`:

```
C:\xampp\htdocs\edufun\
    ├─ api\        (كل أكواد PHP — الملف 03)
    └─ db\
        └─ edufun_schema.sql
```

بمجرّد وضعه هناك يصبح متاحاً تلقائياً على:

```
http://localhost:80/edufun           ← جذر المشروع
http://localhost:80/edufun/api/ping.php
```

## 3. إنشاء قاعدة البيانات

### الطريقة (أ): phpMyAdmin (واجهة رسومية)
1. افتح `http://localhost/phpmyadmin`.
2. تبويب **Import** → اختر `edufun_schema.sql` → **Go**.
3. ثم استورد سكربت الـ Seed (البيانات الأوّلية من الملف 02).

### الطريقة (ب): سطر الأوامر
```powershell
# من PowerShell
& "C:\xampp\mysql\bin\mysql.exe" -u root < "C:\xampp\htdocs\edufun\db\edufun_schema.sql"
```

تحقّق أن القاعدة `edufun_db` والجداول أُنشئت.

## 4. اختبار الباك إند من المتصفح

افتح:
```
http://localhost/edufun/api/ping.php
```
يجب أن ترى:
```json
{"success":true,"message":"الاتصال ناجح ✅","data":{"server":"edufun","time":"..."}}
```
لو رأيت هذا، فالطبقتان (PHP + MySQL) تعملان معاً. ✅

## 5. الوصول من هاتف حقيقي — أهم جزء للشبكة

التطبيق على الهاتف لا يعرف `localhost` الخاص باللابتوب؛ يحتاج **IP اللابتوب على الواي‑فاي**.

### الخطوة 1: اعرف IP اللابتوب
```powershell
ipconfig
```
ابحث عن محوّل الواي‑فاي (Wireless LAN adapter Wi-Fi) →
`IPv4 Address` مثل `192.168.1.20`. هذا ما تكتبه في زر الـ FAB.

### الخطوة 2: تأكّد أن الجهازين على نفس الشبكة
اللابتوب والهاتف على **نفس راوتر الواي‑فاي**.

### الخطوة 3: اجعل Apache يستمع لكل الشبكة (ليس localhost فقط)
افتراضياً Apache في XAMPP يستمع على كل الواجهات (`Listen 80` = `0.0.0.0:80`)،
فلا حاجة لتعديل غالباً. لو كان مقيّداً بـ `Listen 127.0.0.1:80` غيّره إلى `Listen 80`.

### الخطوة 4: افتح بورت 80 في جدار Windows الناري (السبب الأشيع للفشل)
```powershell
# نفّذها في PowerShell كمسؤول (Run as Administrator)
New-NetFirewallRule -DisplayName "Apache HTTP 80" -Direction Inbound `
  -Protocol TCP -LocalPort 80 -Action Allow
```
> هذا يسمح للهاتف بالوصول إلى Apache. بدونه ينجح الاتصال من اللابتوب نفسه
> ويفشل من الهاتف.

### الخطوة 5: اختبر من متصفح الهاتف
على الهاتف افتح:
```
http://192.168.1.20/edufun/api/ping.php
```
لو ظهر JSON الناجح → التطبيق سيتصل. اكتب نفس الـ IP في زر الـ FAB.

## 6. خريطة العناوين حسب نوع المُشغِّل

| المُشغِّل | IP يُكتب في الـ FAB | المسار الكامل |
|----------|---------------------|----------------|
| متصفح/سطح مكتب على نفس اللابتوب | `localhost` | `http://localhost:80/edufun/api` |
| محاكي أندرويد (Emulator) | `10.0.2.2` | `http://10.0.2.2:80/edufun/api` |
| هاتف أندرويد حقيقي (Wi-Fi) | `192.168.x.x` | `http://192.168.x.x:80/edufun/api` |
| محاكي iOS | `localhost` | `http://localhost:80/edufun/api` |

## 7. قائمة استكشاف الأخطاء (Troubleshooting)

| العَرَض | السبب المحتمل | الحل |
|--------|----------------|------|
| `ping.php` يعمل على اللابتوب لا على الهاتف | جدار ناري يحجب 80 | افتح البورت (الخطوة 4) |
| فشل الاتصال من المحاكي | كتبت `localhost` | استخدم `10.0.2.2` |
| `ERR_CLEARTEXT_NOT_PERMITTED` | أندرويد يمنع http | `usesCleartextTraffic="true"` (الملف 05) |
| حروف عربية «؟؟؟» | ترميز الاتصال | `SET NAMES utf8mb4` + `utf8mb4` بالجداول |
| `Access-Control` / CORS | رؤوس ناقصة | تضمين `cors.php` في كل endpoint |
| `localhost` يعمل، الـ IP لا | Apache يستمع لـ 127.0.0.1 فقط | `Listen 80` في httpd.conf |
| البورت 80 مشغول، Apache لا يبدأ | IIS/Skype/خدمة أخرى | بدّل لبورت 8080 |

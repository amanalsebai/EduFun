# المهمة 03 — تشغيل حيّ وإثبات إضافة الطفل للقاعدة

> اقرأ `00-README.md` أولاً. نفّذ بعد المهمة 01.

## الهدف
إثبات أنّ التطبيق فعلاً **يُنشئ طفلاً جديداً في القاعدة** عند الـ onboarding، وأنه **يسحب**
الفيديوهات والأسئلة من القاعدة. نستخدم **Chrome** لأن `localhost` يصل لـ XAMPP من الويب مباشرة.

## المتطلّبات
- XAMPP (Apache + MySQL) يعمل. تحقّق:
  ```
  curl http://localhost/edufun/api/ping.php      # يجب أن يرجع success:true
  ```

---

## الخطوة 1 — عدّاد الأطفال قبل الاختبار
```
& "C:\xampp\mysql\bin\mysql.exe" -u root -N -e "USE edufun_db; SELECT COUNT(*) FROM children;"
```
سجّل الرقم (مثلاً `N`).

## الخطوة 2 — شغّل التطبيق على Chrome
```
cd C:\Users\Abdalgani\Desktop\wpu\EduFun\edufun
C:\cores\flutter\bin\flutter run -d chrome
```
> إن لم يكن دعم الويب مفعّلاً: `C:\cores\flutter\bin\flutter config --enable-web` ثم أعد المحاولة.
> بديل: `flutter run -d windows` (سطح المكتب) — `localhost` يعمل أيضاً.

## الخطوة 3 — مرّ على الـ onboarding
1. انتظر شاشة البداية → اختر عمراً (مثلاً 6).
2. في شاشة الاسم اكتب اسماً مميّزاً (مثلاً `اختبار-حيّ-١`) واضغط «هيا نبدأ».
3. أجب على أسئلة التقييم حتى النهاية.

## الخطوة 4 — تأكّد أنّ الطفل أُضيف
```
& "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 -e "USE edufun_db; SELECT id,name,age FROM children ORDER BY id DESC LIMIT 3;"
```
- يجب أن يظهر صفّ جديد بالاسم `اختبار-حيّ-١` والعمر الصحيح.
- العدّاد الآن `N+1`.
- أو افتح `http://localhost/edufun/admin/children.php` وتأكّد ظهوره.

## الخطوة 5 — تأكّد أنّ المحتوى يُسحب من القاعدة
- **الفيديوهات:** افتح `http://localhost/edufun/admin/videos.php` وعدّل عنوان فيديو رياضيات
  (أضِف مثلاً « — مُعدّل»). داخل التطبيق افتح شاشة الدروس → يجب أن يظهر العنوان المعدّل.
- **الأسئلة:** عدّل سؤالاً لعمر 6 من `questions.php` ثم أعِد الـ onboarding بعمر 6 → يظهر السؤال المعدّل.

> ملاحظة: أعِد أي تعديل تجريبي بعد التأكّد (أو احذف صفّ الطفل التجريبي):
> ```
> & "C:\xampp\mysql\bin\mysql.exe" -u root -e "USE edufun_db; DELETE FROM children WHERE name='اختبار-حيّ-١';"
> ```

---

## ماذا تتوقّع
| السلوك | النتيجة المتوقّعة |
|---|---|
| onboarding كامل | صفّ طفل جديد في `children` |
| تعديل فيديو من اللوحة | يظهر في شاشة الدروس بالتطبيق |
| تعديل سؤال من اللوحة | يظهر في التقييم بالتطبيق |
| إيقاف Apache/MySQL ثم onboarding | لا انهيار؛ التطبيق يعمل «محلياً» بالمحتوى البديل (لا يُضاف طفل) |

## معايير القبول
- [ ] عدّاد `children` يزيد بمقدار 1 بعد onboarding واحد.
- [ ] الطفل يظهر في `admin/children.php` بالاسم الصحيح (عربي سليم).
- [ ] تعديل فيديو/سؤال من اللوحة ينعكس في التطبيق.

## إن فشل (تشخيص)
- `ping` يفشل → Apache/MySQL متوقّف أو البورت محجوز.
- الطفل لا يُضاف رغم نجاح ping → افحص الـ IP المحفوظ في إعدادات الاتصال (يجب أن يطابق منصّة التشغيل)، وراجع المهمة 01.
- عربي تالف في القاعدة → استُورد محتوى بدون `--default-character-set=utf8mb4` (راجع المزالق في README).

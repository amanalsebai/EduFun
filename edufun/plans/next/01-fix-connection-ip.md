# المهمة 01 — إصلاح فخّ الـ IP في التسجيل

> اقرأ `00-README.md` أولاً (السياق والمزالق).

## المشكلة
عند الـ onboarding يُسجَّل الطفل عبر `Session.registerNewChild` → `POST /children/`. لكن:
- القيمة الافتراضية للاتصال `localhost:80` لا تصل لـ XAMPP من **محاكي أندرويد** (يحتاج `10.0.2.2`) ولا من **جهاز حقيقي** (يحتاج IP اللابتوب).
- **زرّ ضبط الاتصال غير موجود في شاشات الـ onboarding** (موجود فقط في `MainLayoutScreen` وبعض الألعاب). فأول تسجيل يفشل بصمت ويعمل «محلي» (id=0) → لا يُضاف طفل.

## الهدف
1. جعل القيمة الافتراضية لـ IP **ذكية حسب المنصّة**.
2. إتاحة **زرّ ضبط الاتصال داخل شاشات الـ onboarding** ليُصحّح المستخدم العنوان قبل التسجيل.

## الملفات المتأثّرة
- تعديل: `lib/core/network/connection_settings.dart`
- تعديل: `lib/features/onboarding/age_selection_screen.dart`
- تعديل: `lib/features/onboarding/name_input_screen.dart`
- موجود ويُعاد استخدامه: `lib/core/network/connection_settings_dialog.dart` (نافذة جاهزة — تُفتح بـ `showDialog`).

---

## الخطوة 1 — قيمة IP افتراضية حسب المنصّة

في `lib/core/network/connection_settings.dart`:

أضِف الاستيراد أعلى الملف:
```dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
```

استبدل الثابت `defaultIp` بـ getter (واترك `defaultPort` كما هو):
```dart
  /// القيمة الافتراضية للـ IP حسب المنصّة:
  /// - محاكي أندرويد يصل للابتوب عبر 10.0.2.2 (وليس localhost).
  /// - الويب/سطح المكتب/محاكي iOS: localhost.
  /// - الجهاز الحقيقي: يبقى localhost افتراضياً ويجب أن يضبطه المستخدم على IP اللابتوب.
  static String get defaultIp {
    if (kIsWeb) return 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return 'localhost';
  }

  static const defaultPort = '80';
```

> `defaultTargetPlatform` من `foundation` آمن على الويب (لا يحتاج `dart:io`). `getIp()`/`getPort()` تبقى كما هي لأنها تستعمل `defaultIp`/`defaultPort`.

---

## الخطوة 2 — زرّ اتصال في شاشة اختيار العمر

في `lib/features/onboarding/age_selection_screen.dart`، داخل `_buildHeader()` يوجد `Row` فيه `mainAxisAlignment: spaceBetween` وعنصر واحد (شارة PLAYZONE). أضِف زرّ اتصال كعنصر ثانٍ:

```dart
  Widget _buildHeader(BuildContext context) {   // ← مرّر context
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container( /* … شارة PLAYZONE كما هي … */ ),

        // زرّ ضبط الاتصال بالسيرفر (مهم لأول تسجيل)
        IconButton(
          tooltip: 'إعدادات الاتصال بالسيرفر',
          icon: const Icon(Icons.wifi_tethering, color: AppColors.tertiary),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ConnectionSettingsDialog(),
          ),
        ),
      ],
    );
  }
```

أضِف الاستيراد أعلى الملف:
```dart
import '../../core/network/connection_settings_dialog.dart';
```

وعدّل نداء `_buildHeader()` في `build` ليصبح `_buildHeader(context)`.

---

## الخطوة 3 — زرّ اتصال في شاشة الاسم (شبكة أمان)

في `lib/features/onboarding/name_input_screen.dart`، أضِف `AppBar` شفّاف فيه نفس الزرّ، حتى لو وصل المستخدم مباشرة لهذه الشاشة:

```dart
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'إعدادات الاتصال بالسيرفر',
            icon: const Icon(Icons.wifi_tethering, color: AppColors.tertiary),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ConnectionSettingsDialog(),
            ),
          ),
        ],
      ),
      body: SafeArea( /* … باقي الشاشة كما هي … */ ),
    );
```

أضِف الاستيراد:
```dart
import '../../core/network/connection_settings_dialog.dart';
```

> اختياري لكنه مفيد: في `name_input_screen._continue()`، بعد فشل التسجيل (`id == 0`) بدّل رسالة الـ SnackBar لتقترح فتح إعدادات الاتصال (مثلاً زر "ضبط الاتصال" داخل الـ SnackBar يفتح نفس النافذة).

---

## معايير القبول
- [ ] على محاكي أندرويد: أول onboarding ينجح ويُضاف طفل (الافتراضي صار `10.0.2.2`).
- [ ] يظهر زرّ اتصال في شاشة العمر وشاشة الاسم، ويفتح نافذة الاتصال ويختبرها (`ping`).
- [ ] `flutter analyze` على الملفات الثلاثة: بلا أخطاء.

## التحقّق
```
C:\cores\flutter\bin\flutter analyze lib/core/network/connection_settings.dart lib/features/onboarding/age_selection_screen.dart lib/features/onboarding/name_input_screen.dart
```
ثم نفّذ المهمة 03 لإثبات أنّ الطفل يُضاف فعلاً.

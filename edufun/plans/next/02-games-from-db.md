# المهمة 02 — ربط كتالوج الألعاب بقاعدة البيانات

> اقرأ `00-README.md` أولاً. هذه أكبر مهمة — نفّذها بعد 01 و 03.

## الوضع الحالي (مهم لفهم القيود)
- قائمة ألعاب كل عمر **مكتوبة يدوياً** في `lib/core/utils/progress_manager.dart` (`gamesByAge`)،
  وكل شاشة عمر (`age_6_games_screen.dart` … `age_9_games_screen.dart`) تبني بطاقات `_GameCard`
  **ثابتة** مع `onTap` ينتقل إلى **widget لعبة محدّد**.
- جدول `games` في القاعدة موجود (`game_code, title_ar, subject_id, min_age`) لكن **Flutter لا يقرأه**.

## القيد المعماري (لا يمكن تجاوزه)
كل لعبة هي **شاشة Flutter مخصّصة** (كود برمجي)، لا يمكن «إنشاؤها» من القاعدة. لذلك:
- **تقدر القاعدة تتحكّم بـ:** أيّ الألعاب تظهر، عناوينها/أوصافها، ترتيبها، تفعيلها/تعطيلها، لأي عمر.
- **لا تقدر القاعدة:** تخترع لعبة جديدة بلا شاشة مقابلة في Flutter.

الحل: **كتالوج من القاعدة + سجلّ (registry) في Flutter يربط `game_code` بالشاشة**. الألعاب التي
لا يوجد لها `game_code` في السجلّ تُتجاهَل (أو تُعرض «قريباً»).

---

## الجزء أ — توسيع جدول games (القاعدة)

أنشئ `backend/db/games_meta.sql`:
```sql
SET NAMES utf8mb4;
USE edufun_db;

ALTER TABLE games
  ADD COLUMN IF NOT EXISTS subtitle       VARCHAR(200) NOT NULL DEFAULT '' AFTER title_ar,
  ADD COLUMN IF NOT EXISTS category_label VARCHAR(40)  NOT NULL DEFAULT '' AFTER subtitle,
  ADD COLUMN IF NOT EXISTS sort_order     INT          NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_active      TINYINT(1)   NOT NULL DEFAULT 1;

-- عبّئ الوصف/التصنيف من النصوص المكتوبة يدوياً في شاشات الأعمار.
-- (القيم أدناه أمثلة من شاشة العمر 7؛ استخرج البقية من age_6/8/9_games_screen.dart)
UPDATE games SET subtitle='رتب الكلمات المبعثرة لتكوين جمل مفيدة بذكائك!', category_label='لغويات', sort_order=1 WHERE game_code='sentence_game';
UPDATE games SET subtitle='تعلم كلمات جديدة ووصل المعاني ببعضها!',        category_label='لغات',   sort_order=2 WHERE game_code='ar_en_matching';
UPDATE games SET subtitle='تحديات الجمع والطرح السريعة لتصبح عبقرياً!',   category_label='حساب',   sort_order=3 WHERE game_code='advanced_math';
-- TODO: أكمل لبقية الـ game_code (انظر جدول الربط في الجزء ج).
```
ثم استورده بفرض utf8mb4، وانسخ الملف إلى htdocs:
```
& "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 edufun_db < "C:\Users\Abdalgani\Desktop\wpu\EduFun\edufun\backend\db\games_meta.sql"
Copy-Item "C:\Users\Abdalgani\Desktop\wpu\EduFun\edufun\backend\db\games_meta.sql" "C:\xampp\htdocs\edufun\db\games_meta.sql"
```

> الـ API `/games/index.php` يعيد `SELECT *` فيشمل الأعمدة الجديدة تلقائياً. (راجع أن `?min_age=` يفلتر؛ وأضِف `is_active` للفلترة إن رغبت، وضِف `ORDER BY sort_order`.)

تعديل مقترح في `backend/api/games/index.php` (وانسخه لـ htdocs): في فرع `?min_age=` أضِف
`AND g.is_active = 1` و `ORDER BY g.sort_order ASC`.

---

## الجزء ب — نموذج + repository (Flutter)

أنشئ `lib/core/data/models/game.dart`:
```dart
class Game {
  final int id;
  final String code;        // game_code — مفتاح الربط بالشاشة
  final String title;       // title_ar
  final String subtitle;
  final String categoryLabel;
  final int minAge;
  final int sortOrder;

  Game({required this.id, required this.code, required this.title,
        required this.subtitle, required this.categoryLabel,
        required this.minAge, required this.sortOrder});

  factory Game.fromJson(Map<String, dynamic> j) => Game(
        id: int.tryParse('${j['id']}') ?? 0,
        code: (j['game_code'] ?? '').toString(),
        title: (j['title_ar'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? '').toString(),
        categoryLabel: (j['category_label'] ?? '').toString(),
        minAge: int.tryParse('${j['min_age']}') ?? 6,
        sortOrder: int.tryParse('${j['sort_order']}') ?? 0,
      );
}
```

أنشئ `lib/core/data/repositories/game_repository.dart`:
```dart
import '../../network/api_client.dart';
import '../models/game.dart';

class GameRepository {
  Future<List<Game>> getByAge(int age) async {
    final r = await ApiClient.get('/games/', query: {'min_age': '$age'});
    if (!r.success || r.data is! List) return [];
    return (r.data as List)
        .map((e) => Game.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

---

## الجزء ج — سجلّ ربط game_code ← شاشة اللعبة (Flutter)

أنشئ `lib/features/games/game_registry.dart`. **تحقّق من أسماء الـ classes الفعلية** بقراءة كل ملف
لعبة قبل الاستخدام (الأسماء أدناه متوقّعة من المسارات):

```dart
import 'package:flutter/material.dart';

import 'language/word_game_screen.dart';
import 'cognitive/color_matching_screen.dart';
import 'math/addition_game_screen.dart';
import 'language/sentence_game_screen.dart';
import 'cognitive/ar_en_matching_screen.dart';
import 'math/advanced_math_screen.dart';
import 'language/english_spelling_screen.dart';
import 'math/math_adventure_screen.dart';
import 'language/grammar_matching_screen.dart';
import 'math/crossmath_game_screen.dart';
import 'language/error_hunter_screen.dart';
import 'language/question_builder_screen.dart';

/// يربط game_code (من القاعدة) ببناء شاشة اللعبة المقابلة في Flutter.
/// أي game_code غير موجود هنا يعني «لا شاشة له» ويُتجاهَل في العرض.
final Map<String, WidgetBuilder> gameScreens = {
  'word_game':       (_) => const WordGameScreen(),
  'color_matching':  (_) => const ColorMatchingScreen(),
  'addition_game':   (_) => const AdditionGameScreen(),
  'sentence_game':   (_) => const SentenceGameScreen(),
  'ar_en_matching':  (_) => const ArEnMatchingScreen(),
  'advanced_math':   (_) => const AdvancedMathScreen(),
  'english_spelling':(_) => const EnglishSpellingScreen(),
  'math_adventure':  (_) => const MathAdventureScreen(),
  'grammar_matching':(_) => const GrammarMatchingScreen(),
  'crossmath':       (_) => const CrossmathGameScreen(),
  'error_hunter':    (_) => const ErrorHunterScreen(),
  'question_builder':(_) => const QuestionBuilderScreen(),
};
```

> جدول الربط (game_code → ملف):
> word_game→language/word_game_screen · color_matching→cognitive/color_matching_screen · addition_game→math/addition_game_screen · sentence_game→language/sentence_game_screen · ar_en_matching→cognitive/ar_en_matching_screen · advanced_math→math/advanced_math_screen · english_spelling→language/english_spelling_screen · math_adventure→math/math_adventure_screen · grammar_matching→language/grammar_matching_screen · crossmath→math/crossmath_game_screen · error_hunter→language/error_hunter_screen · question_builder→language/question_builder_screen

---

## الجزء د — تحويل شاشات الأعمار لتقرأ من القاعدة

حوّل كل شاشة عمر من `StatelessWidget` إلى `StatefulWidget` تجلب الكتالوج وتبني البطاقات منه،
مع **الإبقاء على البطاقات الثابتة كبديل** عند فشل الاتصال (لا تحذفها — انقلها لقائمة fallback).

نمط لـ `age_7_games_screen.dart` (طبّق نفسه على 6/8/9):
```dart
class Age7GamesScreen extends StatefulWidget { /* … */ }

class _Age7GamesScreenState extends State<Age7GamesScreen> {
  List<Game> _games = [];
  bool _loaded = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final games = await GameRepository().getByAge(7);
    // أبقِ فقط ما له شاشة مسجّلة
    final playable = games.where((g) => gameScreens.containsKey(g.code)).toList();
    setState(() { _games = playable; _loaded = true; });
  }

  // في _buildGamesGrid: لو _games غير فارغة ابنِ منها، وإلا استخدم البطاقات الثابتة (fallback).
  // لكل Game: عنوان=g.title، وصف=g.subtitle، تصنيف=g.categoryLabel،
  // onTap: Navigator.push(context, MaterialPageRoute(builder: gameScreens[g.code]!))
}
```
- الألوان/الأيقونات البصرية لكل بطاقة ليست في القاعدة؛ وزّعها دورياً من لوحة ألوان `AppColors`
  (مثلاً حسب `index % 3`) للحفاظ على الشكل الحالي.
- استورد في كل شاشة: `game_registry.dart`, `game_repository.dart`, `models/game.dart`.

---

## (اختياري) الجزء هـ — صفحة إدارة الحقول الجديدة
حدّث `htdocs/edufun/admin/games.php` (و`backend/admin/games.php`) لإضافة حقول `subtitle`،
`category_label`، `sort_order`، `is_active` في نموذج الإضافة/التعديل وفي الجدول.

---

## معايير القبول
- [ ] `GET /games/?min_age=7` يعيد الأعمدة الجديدة (subtitle/category_label/sort_order).
- [ ] شاشات الأعمار تعرض الألعاب من القاعدة؛ تعطيل لعبة (`is_active=0`) من اللوحة يُخفيها من التطبيق.
- [ ] تعديل عنوان/وصف لعبة من اللوحة ينعكس في التطبيق.
- [ ] عند إيقاف السيرفر: الشاشات تعرض البطاقات الثابتة البديلة بلا انهيار.
- [ ] `flutter analyze` على كل الملفات الجديدة/المعدّلة: بلا أخطاء.

## ملاحظات
- محتوى اللعبة نفسه (الكلمات/المسائل داخل كل لعبة) يبقى مكتوباً في الكود — ربطه بالقاعدة مهمة منفصلة
  أكبر (تحتاج جداول محتوى لكل نوع لعبة) وليست ضمن هذه المهمة.

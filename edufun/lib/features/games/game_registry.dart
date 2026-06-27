import 'package:flutter/material.dart';

import 'cognitive/ar_en_matching_screen.dart';
import 'cognitive/color_matching_screen.dart';
import 'language/english_spelling_screen.dart';
import 'language/error_hunter_screen.dart';
import 'language/grammar_matching_screen.dart';
import 'language/question_builder_screen.dart';
import 'language/sentence_game_screen.dart';
import 'language/word_game_screen.dart';
import 'math/addition_game_screen.dart';
import 'math/advanced_math_screen.dart';
import 'math/crossmath_game_screen.dart';
import 'math/math_adventure_screen.dart';

/// يربط `game_code` (من القاعدة) ببناء شاشة اللعبة المقابلة في Flutter.
///
/// القاعدة تتحكّم بأيّ الألعاب تظهر وعناوينها ووصفها وترتيبها، لكن لا يمكنها
/// «اختراع» لعبة جديدة بلا شاشة مقابلة. أي `game_code` غير موجود هنا يُعتبر
/// «لا شاشة له» فيُتجاهَل في العرض (لا نعرض بطاقة تؤدّي للايزدحام).
final Map<String, WidgetBuilder> gameScreens = {
  // عمر 6
  'word_game': (_) => const WordGameScreen(),
  'color_matching': (_) => const ColorMatchingScreen(),
  'addition_game': (_) => const AdditionGameScreen(),
  // عمر 7
  'sentence_game': (_) => const SentenceGameScreen(),
  'ar_en_matching': (_) => const ArEnMatchingScreen(),
  'advanced_math': (_) => const AdvancedMathScreen(),
  // عمر 8
  'english_spelling': (_) => const EnglishSpellingScreen(),
  'math_adventure': (_) => const MathAdventureScreen(),
  'grammar_matching': (_) => const GrammarMatchingScreen(),
  // عمر 9
  'crossmath': (_) => const CrossMathGameScreen(),
  'error_hunter': (_) => const ErrorHunterScreen(),
  'question_builder': (_) => const QuestionBuilderScreen(),
};

/// هل يوجد شاشة Flutter مسجّلة لهذا الـ code؟ (لعرضه أو تجاهله)
bool hasGameScreen(String code) => gameScreens.containsKey(code);

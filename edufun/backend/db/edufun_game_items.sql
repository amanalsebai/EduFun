-- =====================================================================
--  EduFun — محتوى الألعاب النصية (game_items) قابل للتعديل من لوحة admin
--  الاستيراد (يجب فرض utf8mb4 وإلا تَلِف النص العربي):
--    & "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 edufun_db < edufun_game_items.sql
--
--  جدول واحد عام لكل الألعاب النصية. معنى الحقول text1..text4 يختلف حسب اللعبة،
--  وتُعرَض بأسماء واضحة في صفحة admin/game_items.php (بدون أن يكتب المستخدم JSON).
--
--   اللعبة            text1                text2            text3        text4
--   word_game         الكلمة               الإيموجي         —            —
--   english_spelling  الكلمة (EN)          الإيموجي         التلميح      —
--   sentence_game     الجملة الصحيحة       —                —            —
--   ar_en_matching    الكلمة بالعربي       بالإنجليزي        الإيموجي     —
--   grammar_matching  الجملة               الكلمة           إعرابها      —
--   question_builder  الإجابة (EN)         السؤال الصحيح(EN) التلميح      —
--   error_hunter      الجملة كاملة         الكلمة الخطأ     الكلمة الصحيحة التلميح
-- =====================================================================

SET NAMES utf8mb4;
USE edufun_db;

CREATE TABLE IF NOT EXISTS game_items (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  game_code    VARCHAR(40)  NOT NULL,
  level_number TINYINT      NOT NULL DEFAULT 1,
  text1        VARCHAR(300) NOT NULL DEFAULT '',
  text2        VARCHAR(300) NOT NULL DEFAULT '',
  text3        VARCHAR(300) NOT NULL DEFAULT '',
  text4        VARCHAR(300) NOT NULL DEFAULT '',
  sort_order   INT          NOT NULL DEFAULT 0,
  is_active    TINYINT(1)   NOT NULL DEFAULT 1,
  KEY idx_game_level (game_code, level_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- إعادة زرع نظيفة لمحتوى الألعاب السبع (آمنة للتشغيل المتكرّر).
DELETE FROM game_items WHERE game_code IN
  ('word_game','english_spelling','sentence_game','ar_en_matching',
   'grammar_matching','question_builder','error_hunter');

-- ── ترتيب الكلمات (word_game): الكلمة + الإيموجي ──────────────────────
INSERT INTO game_items (game_code, level_number, text1, text2, sort_order) VALUES
  ('word_game', 1, 'موز', '🍌', 1),
  ('word_game', 1, 'قط',  '🐱', 2),
  ('word_game', 2, 'أسد', '🦁', 1),
  ('word_game', 2, 'بطة', '🦆', 2),
  ('word_game', 2, 'نمر', '🐯', 3),
  ('word_game', 3, 'فيل', '🐘', 1),
  ('word_game', 3, 'قلم', '✏️', 2),
  ('word_game', 3, 'باب', '🚪', 3);

-- ── التهجئة الإنجليزية (english_spelling): الكلمة + الإيموجي + التلميح ──
INSERT INTO game_items (game_code, level_number, text1, text2, text3, sort_order) VALUES
  ('english_spelling', 1, 'STAR', '⭐', 'تبدأ بحرف الـ S وتضيء في السماء ليلاً!', 1),
  ('english_spelling', 1, 'FROG', '🐸', 'تبدأ بحرف الـ F ولونها أخضر وتقفز في الماء!', 2),
  ('english_spelling', 1, 'TOY',  '🧸', 'تبدأ بحرف الـ T وتعني لعبة تسلينا دائماً!', 3),
  ('english_spelling', 2, 'CAT',  '🐱', 'حيوان أليف يقول مياو!', 1),
  ('english_spelling', 2, 'SUN',  '☀️', 'يضيء نهارنا ويشرق صباحاً!', 2),
  ('english_spelling', 2, 'FISH', '🐟', 'يسبح في الماء وله زعانف!', 3),
  ('english_spelling', 3, 'MOON', '🌙', 'يضيء سماء الليل!', 1),
  ('english_spelling', 3, 'BOOK', '📖', 'نقرأ فيه القصص!', 2);

-- ── تكوين الجُمل (sentence_game): الجملة الصحيحة (كلمات بمسافات) ────────
INSERT INTO game_items (game_code, level_number, text1, sort_order) VALUES
  ('sentence_game', 1, 'هذا بابا يحبني', 1),
  ('sentence_game', 2, 'القطة تشرب الحليب', 1),
  ('sentence_game', 3, 'الشمس تشرق صباحاً', 1);

-- ── عربي-إنجليزي (ar_en_matching): عربي + إنجليزي + إيموجي ─────────────
INSERT INTO game_items (game_code, level_number, text1, text2, text3, sort_order) VALUES
  ('ar_en_matching', 1, 'قطة',   'Cat',   '🐱', 1),
  ('ar_en_matching', 1, 'كلب',   'Dog',   '🐶', 2),
  ('ar_en_matching', 1, 'تفاحة', 'Apple', '🍎', 3),
  ('ar_en_matching', 2, 'شمس',   'Sun',   '☀️', 1),
  ('ar_en_matching', 2, 'قمر',   'Moon',  '🌙', 2),
  ('ar_en_matching', 2, 'نجمة',  'Star',  '⭐', 3),
  ('ar_en_matching', 3, 'كتاب',  'Book',  '📖', 1),
  ('ar_en_matching', 3, 'بيت',   'House', '🏠', 2),
  ('ar_en_matching', 3, 'ماء',   'Water', '💧', 3);

-- ── توصيل الإعراب (grammar_matching): الجملة + الكلمة + إعرابها ────────
INSERT INTO game_items (game_code, level_number, text1, text2, text3, sort_order) VALUES
  ('grammar_matching', 1, 'أكل الولدُ التفاحةَ', 'أكل',      'فعل ماضٍ',         1),
  ('grammar_matching', 1, 'أكل الولدُ التفاحةَ', 'الولدُ',    'فاعل مرفوع',       2),
  ('grammar_matching', 1, 'أكل الولدُ التفاحةَ', 'التفاحةَ',  'مفعول به منصوب',    3),
  ('grammar_matching', 2, 'يقرأُ الطالبُ كتاباً', 'يقرأُ',     'فعل مضارع',        1),
  ('grammar_matching', 2, 'يقرأُ الطالبُ كتاباً', 'الطالبُ',   'فاعل مرفوع',       2),
  ('grammar_matching', 2, 'يقرأُ الطالبُ كتاباً', 'كتاباً',    'مفعول به منصوب',    3),
  ('grammar_matching', 3, 'كتبَ محمدٌ الدرسَ',   'كتبَ',      'فعل ماضٍ',         1),
  ('grammar_matching', 3, 'كتبَ محمدٌ الدرسَ',   'محمدٌ',     'فاعل مرفوع',       2),
  ('grammar_matching', 3, 'كتبَ محمدٌ الدرسَ',   'الدرسَ',    'مفعول به منصوب',    3);

-- ── صانع الأسئلة (question_builder): الإجابة + السؤال الصحيح + التلميح ──
INSERT INTO game_items (game_code, level_number, text1, text2, text3, sort_order) VALUES
  ('question_builder', 1, 'I am playing football', 'What are you doing?', 'ابدأ بكلمة السؤال (What) ثم الفعل المساعد (are).', 1),
  ('question_builder', 1, 'My book is on the table', 'Where is my book?', 'ابدأ بكلمة السؤال عن المكان (Where) ثم الفعل المساعد (is).', 2),
  ('question_builder', 2, 'She is ten years old', 'How old is she?', 'ابدأ بـ How old ثم الفعل is.', 1),
  ('question_builder', 3, 'They live in Amman', 'Where do they live?', 'ابدأ بـ Where ثم الفعل المساعد do.', 1);

-- ── صائد الأخطاء (error_hunter): الجملة + الكلمة الخطأ + الصحيحة + التلميح ─
INSERT INTO game_items (game_code, level_number, text1, text2, text3, text4, sort_order) VALUES
  ('error_hunter', 1, 'ذهب الولد الا المدرسة', 'الا', 'إلى', 'كلمة ''الا'' تحتاج لشيء في بدايتها وتحتها لتصبح حرف جر صحيح!', 1),
  ('error_hunter', 1, 'هاذا بيت جميل جداً', 'هاذا', 'هذا', 'هناك حرف ألف زائد ينطق ولا يكتب في اسم الإشارة!', 2),
  ('error_hunter', 1, 'قراءت قصة ممتعة أمس', 'قراءت', 'قرأتُ', 'الهمزة في ''قراءت'' يجب أن تجلس فوق الألف!', 3),
  ('error_hunter', 2, 'العب فِي الحديقه', 'الحديقه', 'الحديقة', 'الكلمة تنتهي بتاء مربوطة وليست هاء!', 1),
  ('error_hunter', 3, 'شربت كوب حليب لذيذ', 'كوب', 'كوبَ', 'المفعول به منصوب بالفتحة!', 1);

-- تحقّق سريع (يدوي).
SELECT game_code, level_number, COUNT(*) AS items
FROM game_items GROUP BY game_code, level_number ORDER BY game_code, level_number;

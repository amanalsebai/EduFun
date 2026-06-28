-- games_meta.sql
-- توسيع جدول games ببيانات وصفية يتحكّم بها كتالوج التطبيق، وإصلاح العناوين
-- العربية التالفة (mojibake) الموجودة حالياً، وتعبئة الوصف/التصنيف/الترتيب
-- استخراجاً من النصوص المكتوبة يدوياً في شاشات الأعمار (age_6..9_games_screen.dart).
--
-- الاستيراد (يجب فرض utf8mb4 وإلا تَلِف النص العربي):
--   & "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 edufun_db < games_meta.sql

SET NAMES utf8mb4;
USE edufun_db;

-- 1) إضافة الأعمدة الجديدة (آمن للتشغيل المتكرّر على MariaDB 10.4+).
ALTER TABLE games
  ADD COLUMN IF NOT EXISTS subtitle       VARCHAR(200) NOT NULL DEFAULT '' AFTER title_ar,
  ADD COLUMN IF NOT EXISTS category_label VARCHAR(40)  NOT NULL DEFAULT '' AFTER subtitle,
  ADD COLUMN IF NOT EXISTS sort_order     INT          NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_active      TINYINT(1)   NOT NULL DEFAULT 1;

-- 2) إصلاح العناوين التالفة + تعبئة الوصف والتصنيف والترتيب لكل لعبة.
--    sort_order يطابق ترتيب الظهور داخل كل شاشة عمر.

-- عمر 6
UPDATE games SET title_ar='ترتيب الكلمات',       subtitle='رتب الكلمات المبعثرة لتكوين جملة صحيحة!',            category_label='لغويات',         sort_order=1, is_active=1 WHERE game_code='word_game';
UPDATE games SET title_ar='توصيل الألوان',       subtitle='طابق كل لون باسمه بأسرع ما يمكن!',                    category_label='إدراك',          sort_order=2, is_active=1 WHERE game_code='color_matching';
UPDATE games SET title_ar='الرياضيات الممتعة',   subtitle='تعلّم الجمع والطرح بألعاب شيقة وممتعة!',               category_label='حساب',           sort_order=3, is_active=1 WHERE game_code='addition_game';

-- عمر 7
UPDATE games SET title_ar='ترتيب الجمل',         subtitle='رتب الكلمات المبعثرة لتكوين جمل مفيدة بذكائك!',       category_label='لغويات',         sort_order=1, is_active=1 WHERE game_code='sentence_game';
UPDATE games SET title_ar='توصيل عربي-إنجليزي',  subtitle='تعلم كلمات جديدة ووصل المعاني ببعضها!',               category_label='لغات',           sort_order=2, is_active=1 WHERE game_code='ar_en_matching';
UPDATE games SET title_ar='الرياضيات المتقدمة',  subtitle='تحديات الجمع والطرح السريعة لتصبح عبقرياً!',           category_label='حساب',           sort_order=3, is_active=1 WHERE game_code='advanced_math';

-- عمر 8
UPDATE games SET title_ar='مكتشف الكلمات',       subtitle='تهجّى الكلمات الإنجليزية واكتشف الحروف المفقودة!',     category_label='لغة إنجليزية',   sort_order=1, is_active=1 WHERE game_code='english_spelling';
UPDATE games SET title_ar='الضرب والقسمة',       subtitle='مغامرة في عالم الضرب والقسمة لاحتراف الحساب!',        category_label='رياضيات',        sort_order=2, is_active=1 WHERE game_code='math_adventure';
UPDATE games SET title_ar='توصيل الإعراب',       subtitle='وصِّل كل كلمة بإعرابها الصحيح في الجملة!',            category_label='قواعد عربية',    sort_order=3, is_active=1 WHERE game_code='grammar_matching';

-- عمر 9
UPDATE games SET title_ar='كروس ماث',            subtitle='ألعاب ذكاء ورياضيات ممتعة! حل المعادلات المتقاطعة لتصبح عبقرياً في الحساب.', category_label='حساب', sort_order=1, is_active=1 WHERE game_code='crossmath';
UPDATE games SET title_ar='صائد الأخطاء',        subtitle='هل يمكنك العثور على الأخطاء وعلامات الترقيم المخفية؟ ضع كل علامة في مكانها!', category_label='برمجة', sort_order=2, is_active=1 WHERE game_code='error_hunter';
UPDATE games SET title_ar='صانع الأسئلة',        subtitle='رتب الكلمات الإنجليزية المبعثرة لتصنع سؤالاً صحيحاً بطريقة تفاعلية مسلية.',   category_label='تحدي',   sort_order=3, is_active=1 WHERE game_code='question_builder';

-- 3) تحقّق سريع (يدوي).
SELECT id, game_code, title_ar, subtitle, category_label, min_age, sort_order, is_active
FROM games ORDER BY min_age, sort_order;

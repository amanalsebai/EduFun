-- =====================================================================
--  EduFun — نظام المراحل (Levels) لكل لعبة + تقدّم الطفل على مستوى المرحلة
--  الاستيراد (يجب فرض utf8mb4 وإلا تَلِف النص العربي):
--    & "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 edufun_db < edufun_levels.sql
-- =====================================================================

SET NAMES utf8mb4;
USE edufun_db;

-- 1) تعريف المراحل لكل لعبة (تُدار من لوحة admin).
CREATE TABLE IF NOT EXISTS game_levels (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  game_code    VARCHAR(40)  NOT NULL,
  level_number TINYINT      NOT NULL,
  title_ar     VARCHAR(100) NOT NULL DEFAULT '',
  stars_reward INT          NOT NULL DEFAULT 20,
  config       TEXT         NULL,          -- إعدادات المرحلة (JSON: صعوبة/عدد جولات/نطاق أرقام)
  sort_order   INT          NOT NULL DEFAULT 0,
  is_active    TINYINT(1)   NOT NULL DEFAULT 1,
  UNIQUE KEY uq_game_level (game_code, level_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) تقدّم الطفل على مستوى كل مرحلة.
CREATE TABLE IF NOT EXISTS level_progress (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  child_id     INT NOT NULL,
  game_code    VARCHAR(40) NOT NULL,
  level_number TINYINT NOT NULL,
  completed    TINYINT(1) NOT NULL DEFAULT 0,
  stars_earned INT NOT NULL DEFAULT 0,
  completed_at TIMESTAMP NULL,
  UNIQUE KEY uq_child_level (child_id, game_code, level_number),
  CONSTRAINT fk_lvl_child FOREIGN KEY (child_id)
    REFERENCES children(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================================
--  Seed: 3 مراحل لكل لعبة (سهل / متوسط / صعب).
--  config يحمل إعدادات تُقرأ في فلاتر:
--    rounds     = عدد الجولات/الأسئلة داخل المرحلة
--    maxNumber  = أكبر رقم يُولَّد (ألعاب الحساب)
--    maxFactor  = أكبر عامل ضرب/قسمة (مغامرة الرياضيات)
-- =====================================================================

INSERT INTO game_levels (game_code, level_number, title_ar, stars_reward, config, sort_order) VALUES
  -- عمر 6
  ('word_game',       1, 'المستوى الأول — سهل',   20, '{"rounds":1}',              1),
  ('word_game',       2, 'المستوى الثاني — متوسط', 20, '{"rounds":2}',              2),
  ('word_game',       3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":3}',              3),

  ('color_matching',  1, 'المستوى الأول — سهل',   20, '{"rounds":4}',              1),
  ('color_matching',  2, 'المستوى الثاني — متوسط', 20, '{"rounds":6}',              2),
  ('color_matching',  3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":8}',              3),

  ('addition_game',   1, 'المستوى الأول — سهل',   20, '{"rounds":5,"maxNumber":5}',  1),
  ('addition_game',   2, 'المستوى الثاني — متوسط', 20, '{"rounds":5,"maxNumber":10}', 2),
  ('addition_game',   3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":6,"maxNumber":20}', 3),

  -- عمر 7
  ('sentence_game',   1, 'المستوى الأول — سهل',   20, '{"rounds":1}',              1),
  ('sentence_game',   2, 'المستوى الثاني — متوسط', 20, '{"rounds":2}',              2),
  ('sentence_game',   3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":3}',              3),

  ('ar_en_matching',  1, 'المستوى الأول — سهل',   20, '{"rounds":4}',              1),
  ('ar_en_matching',  2, 'المستوى الثاني — متوسط', 20, '{"rounds":6}',              2),
  ('ar_en_matching',  3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":8}',              3),

  ('advanced_math',   1, 'المستوى الأول — سهل',   20, '{"rounds":5,"maxNumber":10}', 1),
  ('advanced_math',   2, 'المستوى الثاني — متوسط', 20, '{"rounds":5,"maxNumber":20}', 2),
  ('advanced_math',   3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":6,"maxNumber":50}', 3),

  -- عمر 8
  ('english_spelling',1, 'المستوى الأول — سهل',   20, '{"rounds":1}',              1),
  ('english_spelling',2, 'المستوى الثاني — متوسط', 20, '{"rounds":2}',              2),
  ('english_spelling',3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":3}',              3),

  ('math_adventure',  1, 'المستوى الأول — سهل',   20, '{"rounds":5,"maxFactor":5}',  1),
  ('math_adventure',  2, 'المستوى الثاني — متوسط', 20, '{"rounds":5,"maxFactor":10}', 2),
  ('math_adventure',  3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":6,"maxFactor":12}', 3),

  ('grammar_matching',1, 'المستوى الأول — سهل',   20, '{"rounds":1}',              1),
  ('grammar_matching',2, 'المستوى الثاني — متوسط', 20, '{"rounds":2}',              2),
  ('grammar_matching',3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":3}',              3),

  -- عمر 9
  ('crossmath',       1, 'المستوى الأول — سهل',   20, '{"maxNumber":10}',           1),
  ('crossmath',       2, 'المستوى الثاني — متوسط', 20, '{"maxNumber":20}',           2),
  ('crossmath',       3, 'المستوى الثالث — تحدٍّ',  20, '{"maxNumber":50}',           3),

  ('error_hunter',    1, 'المستوى الأول — سهل',   20, '{"rounds":1}',              1),
  ('error_hunter',    2, 'المستوى الثاني — متوسط', 20, '{"rounds":2}',              2),
  ('error_hunter',    3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":3}',              3),

  ('question_builder',1, 'المستوى الأول — سهل',   20, '{"rounds":1}',              1),
  ('question_builder',2, 'المستوى الثاني — متوسط', 20, '{"rounds":2}',              2),
  ('question_builder',3, 'المستوى الثالث — تحدٍّ',  20, '{"rounds":3}',              3)
ON DUPLICATE KEY UPDATE
  title_ar = VALUES(title_ar),
  stars_reward = VALUES(stars_reward),
  config = VALUES(config),
  sort_order = VALUES(sort_order),
  is_active = 1;

-- 3) تحقّق سريع (يدوي).
SELECT game_code, level_number, title_ar, stars_reward, config
FROM game_levels ORDER BY game_code, level_number;

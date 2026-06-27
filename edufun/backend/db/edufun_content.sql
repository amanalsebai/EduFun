-- =====================================================================
--  EduFun — جداول المحتوى القابل للإدارة (فيديوهات + أسئلة التقييم)
--  هذه الترقية تنقل المحتوى المكتوب يدوياً داخل تطبيق فلاتر إلى قاعدة
--  البيانات ليصبح قابلاً للتعديل من لوحة الإدارة.
--
--  ⚠️ مهم: استورد هذا الملف مع فرض ترميز utf8mb4 وإلا تَلِف النص العربي:
--    & "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 ^
--        edufun_db < "C:\xampp\htdocs\edufun\db\edufun_content.sql"
-- =====================================================================

SET NAMES utf8mb4;
USE edufun_db;

-- 1) مكتبة الفيديوهات (الدروس)
CREATE TABLE IF NOT EXISTS videos (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  subject_code VARCHAR(20)  NOT NULL,                 -- math / language / logic
  title        VARCHAR(200) NOT NULL,
  channel      VARCHAR(120) NOT NULL DEFAULT '',
  url          VARCHAR(300) NOT NULL,
  thumbnail    VARCHAR(300) NOT NULL DEFAULT '',
  min_age      TINYINT      NOT NULL DEFAULT 6,
  sort_order   INT          NOT NULL DEFAULT 0,
  created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_video_url (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) أسئلة التقييم المبدئي (مفتاح فريد: العمر + ترتيب السؤال = خانة)
CREATE TABLE IF NOT EXISTS assessment_questions (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  age           TINYINT      NOT NULL,
  category      VARCHAR(20)  NOT NULL,                -- math / language / logic
  question      VARCHAR(300) NOT NULL,
  option_a      VARCHAR(120) NOT NULL,
  option_b      VARCHAR(120) NOT NULL,
  option_c      VARCHAR(120) NOT NULL DEFAULT '',
  option_d      VARCHAR(120) NOT NULL DEFAULT '',
  correct_index TINYINT      NOT NULL DEFAULT 0,       -- 0..3
  sort_order    INT          NOT NULL DEFAULT 0,
  created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_q_slot (age, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
--  بيانات أوّلية (مطابقة لما كان مكتوباً يدوياً في فلاتر)
--  ON DUPLICATE KEY UPDATE = آمنة لإعادة التشغيل دون تكرار.
-- ---------------------------------------------------------------------

INSERT INTO videos (subject_code, title, channel, url, thumbnail, min_age, sort_order) VALUES
  ('math',     'أنشودة جدول الضرب الرائعة للأطفال ✖️',          'قناة أسرتنا',   'https://www.youtube.com/watch?v=cAsEunbybFY', 'https://img.youtube.com/vi/cAsEunbybFY/0.jpg', 6, 1),
  ('math',     'تعلم الرياضيات - الجمع والطرح البسيط ➕',        'تعلم مع زكريا', 'https://www.youtube.com/watch?v=4YWeorY2zP0', 'https://img.youtube.com/vi/4YWeorY2zP0/0.jpg', 6, 2),
  ('math',     'تعليم الأرقام والعد للأطفال 🔢',                 'روضة الأطفال',  'https://www.youtube.com/watch?v=DR-cfDsHCGA', 'https://img.youtube.com/vi/DR-cfDsHCGA/0.jpg', 6, 3),
  ('language', 'تعلم قواعد الإملاء وعلامات الترقيم للأطفال ❗',  'لغتي الجميلة',  'https://www.youtube.com/watch?v=F3_603S_P_k', 'https://img.youtube.com/vi/F3_603S_P_k/0.jpg', 6, 1),
  ('language', 'أنشودة الحروف العربية الهجائية 🔤',             'قناة كرزة',     'https://www.youtube.com/watch?v=5V988L_L668', 'https://img.youtube.com/vi/5V988L_L668/0.jpg', 6, 2),
  ('language', 'تعلم المد والحركات (الفتحة والضمة والكسرة) ✍️', 'تعليم الأطفال', 'https://www.youtube.com/watch?v=zT9Xm3iN3hM', 'https://img.youtube.com/vi/zT9Xm3iN3hM/0.jpg', 6, 3),
  ('logic',    'ألعاب ذكاء وتقوية الملاحظة والمنطق للأطفال 🧠', 'تفكير ذكي',     'https://www.youtube.com/watch?v=D_Z9nKkU_wI', 'https://img.youtube.com/vi/D_Z9nKkU_wI/0.jpg', 6, 1),
  ('logic',    'تعلم الأشكال الهندسية للأطفال 🔷',              'عالم المعرفة',  'https://www.youtube.com/watch?v=Ip_self6Y3Q', 'https://img.youtube.com/vi/Ip_self6Y3Q/0.jpg', 6, 2)
ON DUPLICATE KEY UPDATE
  subject_code = VALUES(subject_code), title = VALUES(title), channel = VALUES(channel),
  thumbnail = VALUES(thumbnail), min_age = VALUES(min_age), sort_order = VALUES(sort_order);

INSERT INTO assessment_questions (age, category, question, option_a, option_b, option_c, option_d, correct_index, sort_order) VALUES
  -- عمر 6
  (6, 'language', 'ما هو الحرف الذي تبدأ به كلمة ''تفاحة''؟',                      'ت', 'ب', 'س', 'أ', 0, 0),
  (6, 'math',     'إذا كان معك تفاحتين، وأعطاك والدك تفاحة، كم يصبح المجموع؟',    '2', '3', '4', '5', 1, 1),
  (6, 'logic',    'أي من هذه الحيوانات يطير في السماء؟',                          'القطة', 'السمكة', 'العصفور', 'الكلب', 2, 2),
  -- عمر 7
  (7, 'language', 'رتب الحروف التالية لتكوين كلمة مفيدة: (م، ز، و)',              'زمو', 'موز', 'وزم', 'زوم', 1, 0),
  (7, 'math',     'كم ناتج: ٥ + ٤ = ؟',                                          '٨', '٩', '١٠', '٧', 1, 1),
  (7, 'logic',    'القطة بالنسبة للمواء، كالكلب بالنسبة للـ...',                  'زئير', 'صهيل', 'نباح', 'تغريد', 2, 2),
  -- عمر 8
  (8, 'language', 'ما هو مرادف كلمة ''سعيد''؟',                                   'حزين', 'مسرور', 'غاضب', 'خائف', 1, 0),
  (8, 'math',     'كم ناتج: ١٥ - ٧ = ؟',                                         '٦', '٨', '٩', '٧', 1, 1),
  (8, 'logic',    'ما هو الشكل الذي له ٤ أضلاع متساوية؟',                         'الدائرة', 'المثلث', 'المستطيل', 'المربع', 3, 2),
  -- عمر 9
  (9, 'language', 'أين نضع الفاصلة (،)؟',                                         'نهاية الجملة', 'للتعجب', 'بين الجمل المتتابعة', 'للسؤال', 2, 0),
  (9, 'math',     'كم ناتج: ٨ × ٧ = ؟',                                          '٥٤', '٥٦', '٦٤', '٤٨', 1, 1),
  (9, 'logic',    'إذا كان اليوم الثلاثاء، فماذا سيكون بعد ٣ أيام؟',             'الخميس', 'الجمعة', 'السبت', 'الأحد', 1, 2)
ON DUPLICATE KEY UPDATE
  category = VALUES(category), question = VALUES(question),
  option_a = VALUES(option_a), option_b = VALUES(option_b),
  option_c = VALUES(option_c), option_d = VALUES(option_d),
  correct_index = VALUES(correct_index);

-- إصلاح اسم الطفل التجريبي (id=1) الذي تلِف عند الاستيراد الأول بترميز خاطئ
UPDATE children SET name = 'بطلنا الصغير' WHERE id = 1;

/// محتوى البطاقات التعليمية مفصولاً عن الواجهة، ليسهل توسيعه
/// (ولاحقاً نقله إلى جدول `flashcards` في قاعدة البيانات وإدارته من لوحة admin).
class CardData {
  final String icon;
  final String title;
  final String? subtitle; // سطر توضيحي أعلى وجه البطاقة
  final String backTitle;
  final String backSubtitle;
  final List<String>? backLines; // لعرض جدول كامل على ظهر البطاقة (جداول الضرب)

  const CardData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.backTitle,
    required this.backSubtitle,
    this.backLines,
  });
}

/// تحويل رقم إلى أرقام عربية مشرقية (٠١٢٣٤٥٦٧٨٩) — تُستخدم في بطاقات عمر 8–9.
String arNum(int n) {
  const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => east[int.parse(c)]).join();
}

// =====================================================================
//  عمر 6–7
// =====================================================================

/// الأعداد الزوجية والفردية (كما هي).
const List<CardData> evenOddCards6to7 = [
  CardData(
    icon: "❓",
    title: "ما هو العدد الزوجي؟",
    backTitle: "يقبل القسمة على 2",
    backSubtitle: "مثل: 2, 4, 6, 8",
  ),
  CardData(
    icon: "❓",
    title: "ما هو العدد الفردي؟",
    backTitle: "لا يقبل القسمة على 2",
    backSubtitle: "مثل: 1, 3, 5, 7",
  ),
];

/// مضاعفات الأعداد من 2 إلى 10 — بطاقة لكل عدد، تُولَّد برمجياً.
final List<CardData> multiplesCards6to7 = [
  for (int n = 2; n <= 10; n++)
    CardData(
      icon: "🔢",
      title: "مضاعفات العدد $n؟",
      backTitle: List.generate(5, (i) => n * (i + 1)).join('، '),
      backSubtitle: "نزيد $n في كل مرة!",
    ),
];

/// الأكبر والأصغر — التعريفان الأصليان + أمثلة تطبيقية.
const List<CardData> compareCards6to7 = [
  CardData(
    icon: "↔️",
    title: "علامة الأكبر من؟",
    backTitle: " [ < ] ",
    backSubtitle: "تفتح فمها دائماً للعدد الكبير!",
  ),
  CardData(
    icon: "↔️",
    title: "علامة الأصغر من؟",
    backTitle: " [ > ] ",
    backSubtitle: "تشير للعدد الصغير!",
  ),
  CardData(
    icon: "🐊",
    title: "أيهما أكبر: 7 أم 3؟",
    subtitle: "مثال",
    backTitle: "7 أكبر من 3",
    backSubtitle: "التمساح يفتح فمه للعدد 7!",
  ),
  CardData(
    icon: "🐊",
    title: "أيهما أصغر: 12 أم 15؟",
    subtitle: "مثال",
    backTitle: "12 أصغر من 15",
    backSubtitle: "12 يأتي قبل 15 عند العد!",
  ),
  CardData(
    icon: "⚖️",
    title: "ماذا لو تساوى العددان: 9 و 9؟",
    subtitle: "مثال",
    backTitle: "متساويان [ = ]",
    backSubtitle: "نستخدم علامة يساوي!",
  ),
  CardData(
    icon: "🐊",
    title: "أيهما أكبر: 20 أم 8؟",
    subtitle: "مثال",
    backTitle: "20 أكبر من 8",
    backSubtitle: "العدد ذو الخانتين أكبر هنا!",
  ),
];

// =====================================================================
//  عمر 8–9
// =====================================================================

/// جداول الضرب الكاملة من ٢ إلى ٩ — كل بطاقة جدول كامل على ظهرها.
final List<CardData> multiplicationCards8to9 = [
  for (int n = 2; n <= 9; n++)
    CardData(
      icon: "✖️",
      title: "جدول الضرب ${arNum(n)}",
      subtitle: "اضغط لترى الجدول كاملاً",
      backTitle: "جدول ${arNum(n)}",
      backSubtitle: "احفظه وستصبح بطل الضرب!",
      backLines: [
        for (int i = 1; i <= 10; i++)
          "${arNum(n)} × ${arNum(i)} = ${arNum(n * i)}",
      ],
    ),
];

/// أساسيات القسمة — تعريف وعلاقة بالضرب وأمثلة محلولة بطريقة سهلة.
const List<CardData> divisionCards8to9 = [
  CardData(
    icon: "🍎",
    title: "ما هي القسمة؟",
    backTitle: "توزيع بالتساوي",
    backSubtitle: "٦ تفاحات على ٣ أطفال: لكل طفل تفاحتان!",
  ),
  CardData(
    icon: "💡",
    title: "١٢ ÷ ٣ = ؟",
    subtitle: "الطريقة السهلة: فكّر بالضرب!",
    backTitle: "٤",
    backSubtitle: "لأن ٣ × ٤ = ١٢ — القسمة عكس الضرب!",
  ),
  CardData(
    icon: "✋",
    title: "١٥ ÷ ٥ = ؟",
    subtitle: "مثال محلول",
    backTitle: "٣",
    backSubtitle: "عُدَّ خمسة خمسة: ٥، ١٠، ١٥ — ثلاث مرات!",
  ),
  CardData(
    icon: "➗",
    title: "٤٥ ÷ ٥ = ؟",
    backTitle: "٩",
    backSubtitle: "لأن ٥ × ٩ = ٤٥ — أحسنت يا بطل!",
  ),
  CardData(
    icon: "➗",
    title: "٣٦ ÷ ٦ = ؟",
    backTitle: "٦",
    backSubtitle: "لأن ٦ × ٦ = ٣٦ — مذهل وممتاز!",
  ),
  CardData(
    icon: "1️⃣",
    title: "أي عدد ÷ ١ = ؟",
    backTitle: "العدد نفسه",
    backSubtitle: "٧ ÷ ١ = ٧ — القسمة على واحد لا تغيّر شيئاً!",
  ),
  CardData(
    icon: "🪞",
    title: "أي عدد ÷ نفسه = ؟",
    backTitle: "١",
    backSubtitle: "٨ ÷ ٨ = ١ — كل واحد يأخذ قطعة واحدة!",
  ),
];

/// أساسيات الإعراب — تعريفات الأركان + مثال جملة معربة كلمة كلمة.
const List<CardData> grammarCards8to9 = [
  CardData(
    icon: "🏃",
    title: "ما هو الفعل؟",
    subtitle: "أساسيات الإعراب",
    backTitle: "كلمة تدل على حدث",
    backSubtitle: "مثل: كتبَ، يلعبُ، اجلسْ",
  ),
  CardData(
    icon: "🙋",
    title: "ما هو الفاعل؟",
    subtitle: "أساسيات الإعراب",
    backTitle: "مَن قام بالفعل",
    backSubtitle: "مرفوع وعلامة رفعه الضمة: جاء الولدُ",
  ),
  CardData(
    icon: "🎯",
    title: "ما هو المفعول به؟",
    subtitle: "أساسيات الإعراب",
    backTitle: "مَن وقع عليه الفعل",
    backSubtitle: "منصوب وعلامة نصبه الفتحة: أكل التفاحةَ",
  ),
  CardData(
    icon: "📖",
    title: "ما هو المبتدأ؟",
    subtitle: "أساسيات الإعراب",
    backTitle: "اسم تبدأ به الجملة الاسمية",
    backSubtitle: "مرفوع بالضمة: العلمُ نورٌ",
  ),
  CardData(
    icon: "✍️",
    title: "إعراب (كتبَ)؟",
    subtitle: "كتبَ الطالبُ الدرسَ",
    backTitle: "فعل ماضٍ",
    backSubtitle: "مبني على الفتح",
  ),
  CardData(
    icon: "✍️",
    title: "إعراب (الطالبُ)؟",
    subtitle: "كتبَ الطالبُ الدرسَ",
    backTitle: "فاعل مرفوع",
    backSubtitle: "وعلامة رفعه الضمة الظاهرة",
  ),
  CardData(
    icon: "✍️",
    title: "إعراب (الدرسَ)؟",
    subtitle: "كتبَ الطالبُ الدرسَ",
    backTitle: "مفعول به منصوب",
    backSubtitle: "وعلامة نصبه الفتحة الظاهرة",
  ),
  CardData(
    icon: "📖",
    title: "إعراب (العلمُ)؟",
    subtitle: "العلمُ نورٌ",
    backTitle: "مبتدأ مرفوع بالضمة",
    backSubtitle: "يا لك من نحوي ذكي!",
  ),
  CardData(
    icon: "📖",
    title: "إعراب (التفاحةَ)؟",
    subtitle: "أكل الولدُ التفاحةَ",
    backTitle: "مفعول به منصوب",
    backSubtitle: "ممتاز وعبقري نحو!",
  ),
];

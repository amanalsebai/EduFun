import 'package:flutter/material.السحب والإفلات" (Drag & Drop)** الممتع للأطفال.

يرجى إنشاء الملفات التالية ونسخ الأكواد بداخلها:

---

### 1. لعبة ترتيب الحروف (7 سنوات): dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/`lib/features/games/language/word_game_screen.dart`
هذه اللعبة تحتوي على صورةcustom_app_bar.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/glass_card.dart';

class WordGameScreen extends StatelessWidget {
const WordGameScreen({super.key});

@override
Widget build(BuildContext context) {
(موزة)، وأماكن فارغة، وحروف مبعثرة يسحبها الطفل لتكوين الكلمة.

return Scaffold(
backgroundColor: AppColors.background,
body: SafeArea(
bottom: false,
child```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/: Column(
children: [
const CustomAppBar(score: 160),
Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
custom_bottom_nav.dart';

class WordGameScreen extends StatefulWidget {
const WordGameScreen({super.key});

@override
State<WordGameScreen> createState() => _WordGameScreenState();
}

classchildren: [
_buildHeader(),
const SizedBox(height: 30),
_buildGameCanvas(),
const SizedBox(height: 30),
_buildHintButton(),
],
_WordGameScreenState extends State<WordGameScreen> {
// حالة الأماكن الفارغة (تح),
),
),
const CustomBottomNav(currentIndex: 1),
],
توي على الحرف إذا تم وضعه، أو null إذا كانت فارغة)
List<String?> target),
),
);
}

Widget _buildHeader() {
return const Column(Slots = [null, null, null];

// الحروف المتاحة للسحب
List
children: [
Text(
"ترتيب الكلمات",
style: TextStyle(fontSize: 40,<Map<String, dynamic>> availableLetters = [
{"char": "م", "color": AppColors.error}, fontWeight: FontWeight.w900, color: AppColors.secondary),
),
SizedBox(
{"char": "و", "color": AppColors.secondary},
{"char": "ز",height: 8),
Text(
"اسحب الحروف لتكوين اسم الفاكهة!",
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors. "color": AppColors.outlineVariant},
];

@override
Widget build(BuildContext context) {
onSurfaceVariant),
),
],
);
}

Widget _buildGameCanvas()    return Scaffold(
backgroundColor: const Color(0xFFE4FFCD),
body: Stack(
{
return GlassCard(
padding: const EdgeInsets.all(30),
child: Column        children: [
// الخلفية المزخرفة
Positioned.fill(child: _buildPattern(
children: [
// صورة الموزة
Container(
width: 160,
Background()),

SafeArea(
bottom: false,
child: Column(
children: [
const Customheight: 160,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
colorAppBar(score: 150),
Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.only(: Colors.white,
shape: BoxShape.circle,
border: Border.all(color:bottom: 120, top: 20, left: 24, right: 24),
child: AppColors.secondaryContainer, width: 8),
boxShadow: [BoxShadow(color: Colors. Column(
children: [
_buildTitle(),
const SizedBox(height: 30),black.withOpacity(0.1), blurRadius: 20)],
),
child: Transform.rotate
_buildGameCard(),
const SizedBox(height: 30),
_buildHintButton(),
],(
angle: 0.2,
child: Image.network(
"https://lh3.googleusercontent.
),
),
),
],
),
),

// شcom/aida-public/AB6AXuAH2s_UV0EyiehpzU5rريط التنقل السفلي
const Positioned(bottom: 0, left: 0, right: Y9TVff4kiB4MkNcEECj1mmeMFAJyC_61R80, child: CustomBottomNav(currentIndex: 1)),
],
),
);
S3X8S6PF7qJd82_JaXxO1BPN3rYl}

Widget _buildPatternBackground() {
return CustomPaint(
painter: DotPainter(color: AppColors.F2D5we8j0IuSAs3V_DOHDUYMcCiriLCF1surfaceContainerHigh),
);
}

Widget _buildTitle() {
return const Column(
children:L7lPw4WW7SVrSigeTKf_zYRndyiQQhy1KqatK64IKGB0XwH7TxJ6cpU2qo10ES4A40IZ [
Text(
"ترتيب الكلمات",
style: TextStyle(fontSize: 40_0GRZLurjwpA6x8tJ_q3Hp6ed1NWMECD2, fontWeight: FontWeight.w900, color: AppColors.secondary),
),
SizedBoxUpsnpuwITtwZFbntn_rBrZN9fpMF3jKxstUvq(height: 8),
Text(
"اسحب الحروف لتكوين اسم الفاكهCbc1cI_LCdz8d1n7hWq",
fit: BoxFit.containة!",
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors,
),
),
),
const SizedBox(height: 40),

    .onSurfaceVariant),
),
],
);
}

Widget _buildGameCard() {
return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color          // الأماكن الفارغة للحروف
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: Colors.white.withOpacity(0.8),
borderRadius: BorderRadius.circular(24),
    : List.generate(3, (index) => Container(
margin: const EdgeInsets.symmetric(horizontal: 8),
width: 70,
height: 70,
decoration: BoxDecoration(
color: AppColors.secondary        border: Border.all(color: Colors.white, width: 2),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset:Container.withOpacity(0.3),
shape: BoxShape.circle,
border: Border.all(color: AppColors.secondaryContainer, width: 3),
),
)),
),
const SizedBox const Offset(0, 10))],
),
child: Column(
children: [
// صورة الهدف (الموزة)
Container(
width: 180,
height: 1(height: 30),

// الحروف المبعثرة (قابلة للسحب - شكلي80,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
colorاً حالياً)
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
_: Colors.white,
shape: BoxShape.circle,
border: Border.all(color: AppColors.secondaryContainer, width: 8),
boxShadow: [BoxShadow(color: Colors.buildLetterBall("م", AppColors.error, const Color(0xFF8A1D00)),
black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,               const SizedBox(width: 16),
_buildLetterBall("و", AppColors.secondary, const Color5))],
),
child: Image.network(
"https://lh3.googleusercontent.com/aida(0xFF004C71)),
const SizedBox(width: 16),
_buildLetterBall("ز", AppColors.outline, const Color(0xFF2D6600)),
-public/AB6AXuAH2s_UV0EyiehpzU5rY9TVff4kiB4MkNcEECj1mmeMFAJyC_61R8S3X8            ],
),
],
),
);
}

Widget _buildLetterBall(String letter, Color color, Color shadow) {
return Container(
width: 70,
height:S6PF7qJd82_JaXxO1BPN3rYlF2D5 70,
decoration: BoxDecoration(
color: color,
shape: BoxShape.circle,
boxShadowwe8j0IuSAs3V_DOHDUYMcCiriLCF1L7lPw: [BoxShadow(color: shadow, offset: const Offset(0, 8))],
),
4WW7SVrSigeTKf_zYRndyiQQhy1KqatK64IKGBchild: Center(
child: Text(
letter,
style: const TextStyle(fontSize: 0XwH7TxJ6cpU2qo10ES4A40IZ_0GRZL32, fontWeight: FontWeight.w900, color: Colors.white),
),
),urjwpA6x8tJ_q3Hp6ed1NWMECD2Upsnpuw
);
}

Widget _buildHintButton() {
return Column(
children: [
Container(ITtwZFbntn_rBrZN9fpMF3jKxstUvqCbc1cI_LCdz8d1n7hWq",
fit: BoxFit.contain,
),
width: 60,
height: 60,
decoration: const BoxDecoration(
color:
),
const SizedBox(height: 40),

// أماكن وضع الحروف (DragTargets) AppColors.primaryContainer,
shape: BoxShape.circle,
boxShadow: [BoxShadow(
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: List.generate(3,color: AppColors.tertiary, offset: Offset(0, 6))],
),
child (index) => _buildDragTarget(index)),
),
const SizedBox(height: 30),

// الحروف القابلة للسحب (Draggables)
Row(
mainAxisAlignment: MainAxisAlignment.: const Icon(Icons.lightbulb_rounded, color: AppColors.onPrimaryContainer, size: 30),
),
const SizedBox(height: 8),
const Text("تلميح", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
],
center,
children: availableLetters.map((letter) {
bool isUsed = targetSlots.contains(letter["char"]);    );
}
}
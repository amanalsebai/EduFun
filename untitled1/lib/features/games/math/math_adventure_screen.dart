import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';

class MathAdventureScreen extends StatelessWidget {
  const MathAdventureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(score: 220),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildProblemBento(),
                    const SizedBox(height: 40),
                    _buildAnswerChoices(),
                    const SizedBox(height: 40),
                    _buildHintCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: const Border(bottom: BorderSide(color: AppColors.tertiary, width: 3)),
          ),
          child: const Text("ضرب وقسمة", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        const Text("اختر الإجابة الصحيحة!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
      ],
    );
  }

  Widget _buildProblemBento() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // الجزء الأيمن (المسألة)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("8", style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                    Text("×", style: TextStyle(fontSize: 50, color: AppColors.primaryContainer)),
                    Text("7", style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                    Text("=", style: TextStyle(fontSize: 50, color: AppColors.primary)),
                    Text("؟", style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: AppColors.outlineVariant)),
                  ],
                ),
                // شريط التقدم
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  color: AppColors.outlineVariant,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // الجزء الأيسر (الصاروخ)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDSt2iaiG6xYJBBaPWIpMNW6qy7CEFpVJ13cxBy7FpbqYj3_zUEidV9yar8e7LAc5dcMjhYYDigd4wyfzAubOHCozEVDm5DH5mHp_clXaFQTIykv_rSl6jIJQ_CoY6CuEc3l7AELTXgEmHdRcwlGGkZ4cRC8TrhspXFD1VUZoGL2UF-IXgz086buVq8V6xPAvrW6JTA8RgA0haJ-26hkHOK3u2CJ74rt47bh3VuR-rRr9WsZmnZyBd3Hmr9hFF_HTlcSc-KSr8jh5Vh",
                  width: 80,
                ),
                const SizedBox(height: 10),
                const Text("انطلق!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerChoices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BigAnswerButton(text: "54", color: AppColors.secondaryContainer),
        _BigAnswerButton(text: "56", color: AppColors.primaryContainer, isCorrect: true),
        _BigAnswerButton(text: "64", color: AppColors.tertiaryContainer),
      ],
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.psychology, color: AppColors.onSurfaceVariant, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "تذكر أن 8 × 5 = 40، ثم أضف 8 مرتين أخريين. أنت تستطيع!",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigAnswerButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isCorrect;

  const _BigAnswerButton({required this.text, required this.color, this.isCorrect = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCorrect ? 120 : 100,
      height: isCorrect ? 120 : 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 8), blurRadius: 0)
        ],
      ),
      child: Center(
        child: Text(text, style: TextStyle(fontSize: isCorrect ? 50 : 40, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
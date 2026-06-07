import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart';

/// بطاقة تقدّم المستوى: تُظهر كم لعبة أنهى الطفل من مستواه،
/// وعندما يُكمل كل ألعاب مستواه ويفوز بها تفتح له زر الانتقال لألعاب المستوى التالي.
class NextLevelUnlockCard extends StatelessWidget {
  final int age;

  /// انتقال لشاشة ألعاب المستوى التالي. يكون null في أعلى مستوى (٩ سنوات).
  final VoidCallback? onGoToNextLevel;

  const NextLevelUnlockCard({super.key, required this.age, this.onGoToNextLevel});

  @override
  Widget build(BuildContext context) {
    final total = ProgressManager.gamesByAge[age]?.length ?? 0;

    // يُعاد البناء فوراً عند فوز الطفل بلعبة جديدة (progressTick)
    return ValueListenableBuilder<int>(
      valueListenable: ProgressManager.progressTick,
      builder: (context, _, __) {
        return FutureBuilder<int>(
          future: ProgressManager.completedCountForAge(age),
          builder: (context, snapshot) {
            final done = snapshot.data ?? 0;
            final allDone = total > 0 && done >= total;
            return _buildCard(context, done, total, allDone);
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, int done, int total, bool allDone) {
    final double progress = total == 0 ? 0 : done / total;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: allDone
              ? [AppColors.primaryContainer, AppColors.secondaryContainer]
              : [Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: allDone ? AppColors.primary : AppColors.surfaceContainerHigh, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(allDone ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: allDone ? AppColors.primary : AppColors.onSurfaceVariant, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  allDone ? "رائع! أكملت كل ألعاب مستواك 🎉" : "تقدّمك في هذا المستوى",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // شريط التقدّم: عدد الألعاب المُنجزة من أصل الإجمالي
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text("أنجزت $done من $total ألعاب",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),

          const SizedBox(height: 16),

          if (allDone && onGoToNextLevel != null)
            // ✅ زر فتح ألعاب المستوى التالي
            GestureDetector(
              onTap: onGoToNextLevel,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("افتح ألعاب المستوى التالي", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    SizedBox(width: 8),
                    Text("🔓", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            )
          else if (allDone && onGoToNextLevel == null)
            // أعلى مستوى: لا يوجد مستوى تالٍ
            const Text("أنت بطل خارق! أتقنت كل المستويات 🏆",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary))
          else
            // لم يُكمل بعد: رسالة تحفيزية
            const Text("افز بكل الألعاب لتفتح ألعاباً جديدة من المستوى التالي! 🚀",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/data/models/game_level.dart';
import '../../../core/data/repositories/level_repository.dart';
import '../../../core/network/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../game_registry.dart';

/// شاشة اختيار مرحلة لأي لعبة — تجلب المراحل وحالتها من `GET /levels/`
/// (مع بديل محلي عند الانقطاع)، وتعرضها كخريطة عقد مرقّمة تُفتح بالتسلسل.
///
/// عند الضغط على مرحلة مفتوحة تُفتح شاشة اللعبة ممرِّرةً [GameLevel] المختارة،
/// وعند العودة تُعاد قراءة الحالة (قد تُفتح المرحلة التالية).
class LevelSelectScreen extends StatefulWidget {
  final String gameCode;
  final String title;

  const LevelSelectScreen({
    super.key,
    required this.gameCode,
    required this.title,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<GameLevel> _levels = const [];
  bool _ageUnlocked = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // يهيّئ الطفل ويزامن ملخّص التقدّم قبل جلب المراحل.
    await ProgressManager.syncFromServer();

    List<GameLevel> levels = const [];
    bool ageUnlocked = true;

    if (Session.isOnline) {
      final res = await LevelRepository().getLevels(widget.gameCode, Session.currentChildId);
      levels = res.levels;
      ageUnlocked = res.ageUnlocked;
    }

    // بديل محلي: إن لم يصل شيء من السيرفر نبني المراحل من الكاش المحلي.
    if (levels.isEmpty) {
      levels = await _buildOfflineLevels();
    }

    if (!mounted) return;
    setState(() {
      _levels = levels;
      _ageUnlocked = ageUnlocked;
      _loading = false;
    });
  }

  Future<List<GameLevel>> _buildOfflineLevels() async {
    final levels = <GameLevel>[];
    bool prevCompleted = true;
    for (int i = 1; i <= ProgressManager.defaultLevelsPerGame; i++) {
      final done = await ProgressManager.isLevelCompletedLocal(widget.gameCode, i);
      levels.add(GameLevel.offline(i, completed: done, unlocked: prevCompleted));
      prevCompleted = done;
    }
    return levels;
  }

  Future<void> _openLevel(GameLevel level) async {
    final builder = levelGameBuilders[widget.gameCode];
    if (builder == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => builder(level)),
    );
    // بعد العودة قد تكون المرحلة أُكملت وفُتحت التالية.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(showBackButton: true),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        if (!_ageUnlocked) _buildAgeLockedBanner(),
                        for (int i = 0; i < _levels.length; i++) ...[
                          _buildLevelNode(_levels[i], i + 1),
                          if (i < _levels.length - 1) _buildConnector(_levels[i].completed),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
        children: [
          Text(widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
          const SizedBox(height: 6),
          const Text("اختر مرحلة لتبدأ التحدّي!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        ],
      );

  Widget _buildAgeLockedBanner() => Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.4)),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Expanded(
              child: Text("هذا المستوى مقفل — أكمِل مستواك الحالي أولاً!",
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.error)),
            ),
          ],
        ),
      );

  Widget _buildLevelNode(GameLevel level, int display) {
    final completed = level.completed;
    final unlocked = level.unlocked && _ageUnlocked;

    final Color bg = completed
        ? AppColors.primaryContainer
        : (unlocked ? Colors.white : AppColors.surfaceContainerHigh);
    final Color accent = completed
        ? AppColors.primary
        : (unlocked ? AppColors.tertiary : AppColors.onSurfaceVariant);

    return GestureDetector(
      onTap: unlocked ? () => _openLevel(level) : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Center(
                child: completed
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 30)
                    : (unlocked
                        ? Text("$display", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white))
                        : const Icon(Icons.lock_rounded, color: Colors.white, size: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.titleAr.isNotEmpty ? level.titleAr : "المرحلة $display",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        completed ? "أُنجزت • +${level.starsReward} نجمة" : "${level.starsReward} نجمة",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (unlocked && !completed)
              const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(bool active) => Center(
        child: Container(
          width: 4,
          height: 24,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

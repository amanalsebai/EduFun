import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FlashcardFlip extends StatefulWidget {
  final String frontIcon;
  final String frontTitle;
  final String? frontSubtitle;

  final String backTitle;
  final String backSubtitle;
  final Color themeColor;

  /// أسطر إضافية تُعرض كجدول كامل على ظهر البطاقة (مثل جدول ضرب كامل).
  /// عند تمريرها يُصغَّر العنوان الخلفي وتُعرض الأسطر تحته بمقاس متكيّف.
  final List<String>? backLines;

  const FlashcardFlip({
    super.key,
    required this.frontIcon,
    required this.frontTitle,
    this.frontSubtitle,
    required this.backTitle,
    required this.backSubtitle,
    required this.themeColor,
    this.backLines,
  });

  @override
  State<FlashcardFlip> createState() => _FlashcardFlipState();
}

class _FlashcardFlipState extends State<FlashcardFlip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    // أنيميشن من 0 إلى 180 درجة (Pi)
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // إضافة عمق 3D للبطاقة (Perspective)
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value);

          // إذا تجاوزت الزاوية 90 درجة، نعرض الوجه الخلفي
          final isBackShowing = _animation.value >= (pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isBackShowing ? _buildBackSide() : _buildFrontSide(),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest, // أبيض
        borderRadius: BorderRadius.circular(20),
        border: Border(bottom: BorderSide(color: widget.themeColor, width: 8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      padding: const EdgeInsets.all(16),
      // ✅ معالجة الـ Overflow: المحتوى يتقلّص ليتسع داخل البطاقة مهما طال السؤال
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.frontIcon, style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
          if (widget.frontSubtitle != null)
            Text(
              widget.frontSubtitle!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              widget.frontTitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onSurface, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    // يجب عكس المحتوى الخلفي لأنه سيكون مقلوباً بسبب الدوران 180 درجة
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        decoration: BoxDecoration(
          color: widget.themeColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: widget.themeColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: widget.backLines != null ? _buildBackTable() : _buildBackSimple(),
      ),
    );
  }

  /// الظهر الافتراضي: عنوان كبير + سطر توضيحي.
  Widget _buildBackSimple() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.backTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: Text(
            widget.backSubtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  /// ظهر بنمط جدول: عنوان صغير ثم كل الأسطر، تتقلّص لتتسع مهما كان عددها.
  Widget _buildBackTable() {
    return Column(
      children: [
        Text(
          widget.backTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                for (final line in widget.backLines!)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.backSubtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white70),
        ),
      ],
    );
  }
}
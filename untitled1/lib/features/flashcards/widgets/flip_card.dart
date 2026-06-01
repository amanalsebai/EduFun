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

  const FlashcardFlip({
    super.key,
    required this.frontIcon,
    required this.frontTitle,
    this.frontSubtitle,
    required this.backTitle,
    required this.backSubtitle,
    required this.themeColor,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.frontIcon, style: const TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          if (widget.frontSubtitle != null)
            Text(
              widget.frontSubtitle!,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 8),
          Text(
            widget.frontTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.onSurface),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.backTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.backSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
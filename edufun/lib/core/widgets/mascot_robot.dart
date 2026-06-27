import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_colors.dart';

class MascotRobot extends StatelessWidget {
  final double size;

  const MascotRobot({super.key, this.size = 130});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceContainerHigh, width: size * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipOval(
        child: Image.network(
          AppConstants.robotMascotUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.smart_toy, size: size * 0.5, color: AppColors.secondary),
        ),
      ),
    );
  }
}
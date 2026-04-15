(16), border: Border(bottom: BorderSide(color: color, width: 6))),
child: Rowimport 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
(
children: [
Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color, shapeimport '../../../core/widgets/custom_app_bar.dart';

class SentenceGameScreen extends StatefulWidget {
    : BoxShape.circle), child: Icon(icon, size: 20)),
const SizedBox(widthconst SentenceGameScreen({super.key});

@override
State<SentenceGameScreen> createState() =>: 8),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_SentenceGameScreenState();
}

class _SentenceGameScreenState extends State<SentenceGameScreen> {
Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color:  List<String?> targetSlots = [null, null, null];

List<Map<String, dynamic>> availableWords = [
{"word": "يحبني", "color": AppColors.primaryContainer, "onColor": AppColors AppColors.onSurfaceVariant)),
Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
],
),
],
),
),
);
}
}
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ColorMatchingScreen extends StatelessWidget {
  const ColorMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CustomAppBar(score: 130),
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildGameBoard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text("لعبة مطابقة الألوان", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(20)),
          child: const Text("وصّل كل صورة بلونها الصحيح!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الجهة اليسرى (الألوان)
          const Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ColorTarget(color: AppColors.secondary, label: "أزرق"),
              SizedBox(height: 50),
              _ColorTarget(color: AppColors.tertiaryContainer, label: "أصفر"),
              SizedBox(height: 50),
              _ColorTarget(color: AppColors.primaryContainer, label: "أحمر"),
            ],
          ),
          // الجهة اليمنى (الصور)
          const Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ImageSource(
                imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDr_KigA69HNGZWR1fF1HOFKyoILAzA9QY7iBfKyuayqrzpB4bkOEbBGDHZkE8v2_jyWfG28nCOaXPdM7zlKxqB7kW0co-NV51uW3-p9pab9PPbrf2mKcZ7OcnL2Ku4iox-dW1ZhOc5QVpswWJ-wR8CL70-7Gn0PGBgYOgh3S5p7n0HA9we-BpPpb_9D9ajFjbt7-lbZAKwXZSp0QKE_NdcN5SFa4URjYSWxGq-AGAItrMT5--xyOYJ944gUUcM7gL6WD65O06pQFeX",
                label: "تفاحة",
                nodeColor: AppColors.primaryContainer,
              ),
              SizedBox(height: 20),
              _ImageSource(
                imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBN6eKUYfC-N7cLzlyKX7qyhkJn-YUVDil6Q2WwE0jbZ3yCB_aoJAL5xfD5iOPrK4aGGRc8I46orgcKYfgnbI87LvpXNAo_vkS8EChhdSu6maOuBcEwf08tTZr844ktkHdqlL_4DIucgyFipNhVBwCXbzIZjf9FqEFgkdZI_HKNk2SuqCi5Vqbc-21nMqObD2ZBcoklvN76e_Hd_UQ0p-C_WdwexsITrqnaNebtUp-sFjJg7O6Sla955YCAE3KHFxWgxdCLVww7y8cu",
                label: "موزة",
                nodeColor: AppColors.tertiaryContainer,
              ),
              SizedBox(height: 20),
              _ImageSource(
                imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDjiyphjh6oKJfEPDi1O7LMzsmhEjkQDPPB_v13jJoIk3KrGY_DyH6EAwpFXPneZIjqTvGQrtcq5c3QkgnoZ_tWxsZ_cVN2cl9x7jbaF9ckSoV7QybJSWDoZb8WO476mgVx0k6tkEdJPUZnR51fD2BGEDdEjfjQV-J4m-Xx1DqsX_KR6WooyoeOaup1SX1D3_X2G2B57s_JMTE_0JyBF2fO-__0nhVdo3Kvf2mV5ulV_xmCxwZcSBvBilJ9VS-KujuvFiUSUAudaJi4",
                label: "سماء",
                nodeColor: AppColors.secondaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorTarget extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorTarget({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 10),
        Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 4))]),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _ImageSource extends StatelessWidget {
  final String imageUrl;
  final String label;
  final Color nodeColor;
  const _ImageSource({required this.imageUrl, required this.label, required this.nodeColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Image.network(imageUrl, errorBuilder: (c, e, s) => const Icon(Icons.error)),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 10),
        Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: nodeColor)),
      ],
    );
  }
}
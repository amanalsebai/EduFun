import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';

class LessonVideo {
  final String title; final String channel; final String url; final String thumbnail;
  LessonVideo({required this.title, required this.channel, required this.url, required this.thumbnail});
}

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});
  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String weakestSubject = 'math';
  bool isLoading = true;

  final Map<String, List<LessonVideo>> _lessonsBank = {
    'math': [
      LessonVideo(title: "أنشودة جدول الضرب الرائعة للأطفال ✖️", channel: "قناة أسرتنا", url: "https://www.youtube.com/watch?v=cAsEunbybFY", thumbnail: "https://img.youtube.com/vi/cAsEunbybFY/0.jpg"),
      LessonVideo(title: "تعلم الرياضيات - الجمع والطرح البسيط ➕", channel: "تعلم مع زكريا", url: "https://www.youtube.com/watch?v=4YWeorY2zP0", thumbnail: "https://img.youtube.com/vi/4YWeorY2zP0/0.jpg"),
    ],
    'language': [
      LessonVideo(title: "تعلم قواعد الإملاء وعلامات الترقيم للأطفال ❗", channel: "لغتي الجميلة", url: "https://www.youtube.com/watch?v=F3_603S_P_k", thumbnail: "https://img.youtube.com/vi/F3_603S_P_k/0.jpg"),
      LessonVideo(title: "أنشودة الحروف العربية الهجائية 🔤", channel: "قناة كرزة", url: "https://www.youtube.com/watch?v=5V988L_L668", thumbnail: "https://img.youtube.com/vi/5V988L_L668/0.jpg"),
    ],
    'logic': [
      LessonVideo(title: "ألعاب ذكاء وتقوية الملاحظة والمنطق للأطفال 🧠", channel: "تفكير ذكي", url: "https://www.youtube.com/watch?v=D_Z9nKkU_wI", thumbnail: "https://img.youtube.com/vi/D_Z9nKkU_wI/0.jpg"),
    ]
  };

  @override
  void initState() { super.initState(); _analyzeWeakness(); }

  Future<void> _analyzeWeakness() async {
    final prefs = await SharedPreferences.getInstance();
    int math = prefs.getInt('score_math') ?? 0;
    int language = prefs.getInt('score_language') ?? 0;
    int logic = prefs.getInt('score_logic') ?? 0;
    int lowest = math; String weak = 'math';
    if (language < lowest) { lowest = language; weak = 'language'; }
    if (logic < lowest) { lowest = logic; weak = 'logic'; }
    setState(() { weakestSubject = weak; isLoading = false; });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("عذراً، لم نتمكن من فتح الرابط."))); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    final recommendedVideos = _lessonsBank[weakestSubject] ?? [];
    String subjectTitle = weakestSubject == 'math' ? "الرياضيات والحساب" : (weakestSubject == 'language' ? "اللغة العربية والإملاء" : "المنطق والذكاء");

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(currentIndex: 1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ✅ تم تصحيح الـ CustomAppBar هنا بحذف الـ score
            const CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("أكاديمية الأبطال 🎓", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
                    const SizedBox(height: 8),
                    const Text("دروس مخصصة مدعومة بالذكاء الاصطناعي لتقوية مهاراتك!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    _buildAdaptiveBanner(subjectTitle),
                    const SizedBox(height: 30),
                    const Text("الدروس المقترحة لك اليوم:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      itemCount: recommendedVideos.length,
                      itemBuilder: (context, index) => _buildVideoCard(recommendedVideos[index]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveBanner(String subjectTitle) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.secondaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.secondary, width: 2)), child: Row(children: [const Text("🚀", style: TextStyle(fontSize: 40)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("توصية المعلم الذكي:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer)), const SizedBox(height: 4), Text("بناءً على تقييمك الأخير، جهزنا لك دروساً مميزة لتقويتك في قسم: [$subjectTitle]", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSecondaryContainer, height: 1.4))]))]));
  Widget _buildVideoCard(LessonVideo video) => Card(elevation: 4, shadowColor: Colors.black12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: InkWell(onTap: () => _launchUrl(video.url), borderRadius: BorderRadius.circular(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(video.thumbnail, height: 180, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 180, color: Colors.grey, child: const Icon(Icons.play_circle_fill, size: 50, color: Colors.white)))), Padding(padding: const EdgeInsets.all(16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text(video.channel, style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold))])), const Icon(Icons.play_arrow_rounded, size: 40, color: AppColors.primary)]))])));
}
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'core/widgets/themed_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 420),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 48.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                const SizedBox(height: 12),
                _buildTopBar(context, colorScheme),
                const SizedBox(height: 32),
                _buildHeader(context),
                const SizedBox(height: 36),
                _buildInquiryCard(context, colorScheme),
                const SizedBox(height: 20),
                _buildReportCard(context, colorScheme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.person, color: Colors.white),
          label: const Text('تحديث البيانات'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white12,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'بوابتك الآمنة للمرور',
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 80),
            ),
          ],
          totalRepeatCount: 1,
        ),
        const SizedBox(height: 10),
        const Text(
          'استعلام وإبلاغ عن المخالفات',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildInquiryCard(BuildContext context, ColorScheme colorScheme) { // Corrected: Add context parameter
    return GlassContainer(
      height: 200,
      width: double.infinity,
      color: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(22.0),
      borderWidth: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'استعلام عن لوحة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'مثال: س ي 5432',
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: 'رقم اللوحة',
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.credit_card, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(40),
              ),
              child: Text(
                'استعلام',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ColorScheme colorScheme) {
    return GlassContainer(
      height: 350,
      width: double.infinity,
      color: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(22.0),
      borderWidth: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showReportOptions(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      elevation: 5,
                    ),
                    child: const Text(
                      'نوع البلاغ',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'إبلاغ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library, color: Colors.black),
                    label: const Text('صور', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    label: const Text('كاميرا', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              textAlign: TextAlign.right,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'اكتب  رقم السيارة',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'إرسال',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportOptions(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'اختر نوع البلاغ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          ListTile(
            trailing: const Icon(Icons.error, color: Colors.white70),
            title: const Text('تحرش', textAlign: TextAlign.right),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            trailing: const Icon(Icons.speed, color: Colors.white54),
            title: const Text('سرعة زائدة', textAlign: TextAlign.right),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            trailing: const Icon(Icons.car_crash_sharp, color: Colors.white),
            title: const Text('سرقة', textAlign: TextAlign.right),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            trailing: const Icon(Icons.local_parking, color: Colors.grey),
            title: const Text('إعاقة حركة المرور', textAlign: TextAlign.right),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
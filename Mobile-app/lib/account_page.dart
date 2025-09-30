import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'core/widgets/themed_background.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: ThemedBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: SingleChildScrollView(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 420),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 48.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                const SizedBox(height: 12),
                _buildProfileHeader(context),
                const SizedBox(height: 28),
                _buildUserInfoCard(context, colorScheme),
                const SizedBox(height: 20),
                _buildSettingsCard(context, colorScheme),
                const SizedBox(height: 20),
                _buildLogoutButton(context, colorScheme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              color: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          ' جمال عبد الناصر',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'ahln@example.com',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ColorScheme colorScheme) {
    return GlassContainer(
      height: 200,
      width: double.infinity,
      color: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(22.0),
      borderWidth: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'معلومات الحساب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('رقم الهاتف', '+20 1147049592'),
            const SizedBox(height: 15),
            _buildInfoRow('تاريخ التسجيل', 'يناير 2024'),
            const SizedBox(height: 15),
            _buildInfoRow('عدد البلاغات', '12 بلاغ'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, ColorScheme colorScheme) {
    return GlassContainer(
      height: 230,
      width: double.infinity,
      color: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(20.0),
      borderWidth: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'الإعدادات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildSettingButton(context, colorScheme, 'تعديل الملف الشخصي', Icons.edit),
            const SizedBox(height: 15),
            _buildSettingButton(context, colorScheme, 'إشعارات', Icons.notifications),
            const SizedBox(height: 15),
            _buildSettingButton(context, colorScheme, 'الأمان', Icons.security),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingButton(BuildContext context, ColorScheme colorScheme, String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: colorScheme.primary),
      label: Text(
        title,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 5,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout),
      label: const Text(
        'تسجيل الخروج',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        elevation: 8,
      ),
    );
  }
}

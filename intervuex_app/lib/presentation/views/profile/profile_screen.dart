import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/core/widgets/report_ai_modal.dart';
import 'package:intervuex_app/presentation/providers/language_provider.dart';
import 'package:intervuex_app/presentation/providers/theme_provider.dart';
import 'package:intervuex_app/presentation/views/profile/account_deletion_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtextColor = isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;
    final mutedTextColor = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('CP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Candidate Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Technical Candidate • Target: Software Engineer', style: TextStyle(fontSize: 12, color: subtextColor)),
                        const SizedBox(height: 4),
                        const Text('Active Interview Track', style: TextStyle(fontSize: 11, color: AppColors.indigoLight, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Appearance & Theme Selection
            Text('APPEARANCE & THEME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedTextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('App Color Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Switch between Dark Mode, Light Mode, or sync with System:', style: TextStyle(fontSize: 12, color: subtextColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _themeChoice(
                        context,
                        'Dark',
                        Icons.dark_mode_rounded,
                        ThemeMode.dark,
                        themeMode,
                        subtextColor,
                        borderColor,
                        () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                      ),
                      const SizedBox(width: 8),
                      _themeChoice(
                        context,
                        'Light',
                        Icons.light_mode_rounded,
                        ThemeMode.light,
                        themeMode,
                        subtextColor,
                        borderColor,
                        () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _themeChoice(
                        context,
                        'System',
                        Icons.brightness_auto_rounded,
                        ThemeMode.system,
                        themeMode,
                        subtextColor,
                        borderColor,
                        () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Language Preferences
            Text('LANGUAGE PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedTextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Understanding & Coaching Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Select which language you want interview concept explanations in:', style: TextStyle(fontSize: 12, color: subtextColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _langChoice(
                        'English',
                        ExplanationLanguage.english,
                        lang,
                        subtextColor,
                        borderColor,
                        () => ref.read(languageProvider.notifier).setLanguage(ExplanationLanguage.english),
                      ),
                      const SizedBox(width: 8),
                      _langChoice(
                        'தமிழ் (Tamil)',
                        ExplanationLanguage.tamil,
                        lang,
                        subtextColor,
                        borderColor,
                        () => ref.read(languageProvider.notifier).setLanguage(ExplanationLanguage.tamil),
                      ),
                      const SizedBox(width: 8),
                      _langChoice(
                        'हिन्दी (Hindi)',
                        ExplanationLanguage.hindi,
                        lang,
                        subtextColor,
                        borderColor,
                        () => ref.read(languageProvider.notifier).setLanguage(ExplanationLanguage.hindi),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Interview Answer Language', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('English (Default)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. AI Safety & Privacy Policies
            Text('SAFETY, DATA & COMPLIANCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedTextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: AppColors.warning),
                    title: const Text('Report AI Content', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Flag inaccurate, offensive, or bad translations', style: TextStyle(fontSize: 12, color: subtextColor)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ReportAIModal.show(context, contentId: 'general', contentType: 'general_feedback');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.success),
                    title: const Text('Data Safety & Privacy Map', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Resumes are processed securely without third-party sale', style: TextStyle(fontSize: 12, color: subtextColor)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('IntervueX Privacy & Safety'),
                          content: const Text(
                            'Your resume, job postings, and mock interview transcripts are encrypted in transit and at rest. '
                            'We do not sell personal data, and AI API keys are never stored on client devices.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Understood')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppColors.danger),
                    title: const Text('Delete Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger)),
                    subtitle: Text('Permanently erase all personal data and packs', style: TextStyle(fontSize: 12, color: subtextColor)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountDeletionScreen()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'InterVueX v1.0.0 (Build 2026.1)\nAI Career-Tech Architecture',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: mutedTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _themeChoice(
    BuildContext context,
    String label,
    IconData icon,
    ThemeMode choice,
    ThemeMode currentMode,
    Color subtextColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    final isSelected = choice == currentMode;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.electricIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.electricIndigo : borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : subtextColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : subtextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langChoice(
    String label,
    ExplanationLanguage choice,
    ExplanationLanguage current,
    Color subtextColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    final isSelected = choice == current;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.electricIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.electricIndigo : borderColor),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : subtextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/core/widgets/report_ai_modal.dart';
import 'package:intervuex_app/data/services/firebase_service.dart';
import 'package:intervuex_app/presentation/providers/language_provider.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/providers/theme_provider.dart';
import 'package:intervuex_app/presentation/views/profile/account_deletion_screen.dart';
import 'package:intervuex_app/presentation/views/shell/main_shell_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _initials(User? user) {
    if (user == null || user.isAnonymous) return '?';
    final name = user.displayName ?? '';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return name[0].toUpperCase();
    }
    final email = user.email ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final variant = ref.watch(themeVariantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;
    final displayName = (!isAnonymous && (user?.displayName?.isNotEmpty == true))
        ? user!.displayName!
        : (isAnonymous ? 'Anonymous User' : 'Candidate');
    final email = (!isAnonymous && (user?.email?.isNotEmpty == true))
        ? user!.email!
        : (isAnonymous ? 'Not signed in' : '');

    final subtextColor =
        isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;
    final mutedTextColor =
        isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
    final borderColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('Profile & Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Profile Header Card ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.15),
                    primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: variant.gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials(user),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAnonymous
                                ? 'Anonymous Session'
                                : 'Active Interview Track',
                            style: TextStyle(
                                fontSize: 11,
                                color: primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── 2. Appearance & Theme ─────────────────────────────────
            Text('APPEARANCE & THEME',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mutedTextColor,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Display Mode',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Dark Mode, Light Mode, or match your system:',
                      style:
                          TextStyle(fontSize: 12, color: subtextColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _themeChoice(context, 'Dark', Icons.dark_mode_rounded,
                          ThemeMode.dark, themeMode, subtextColor, borderColor,
                          () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark)),
                      const SizedBox(width: 8),
                      _themeChoice(context, 'Light', Icons.light_mode_rounded,
                          ThemeMode.light, themeMode, subtextColor, borderColor,
                          () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light)),
                      const SizedBox(width: 8),
                      _themeChoice(context, 'System', Icons.brightness_auto_rounded,
                          ThemeMode.system, themeMode, subtextColor, borderColor,
                          () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 14),
                  const Text('Accent Color',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Choose your app\'s accent color palette:',
                      style: TextStyle(fontSize: 12, color: subtextColor)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppThemeVariant.values.map((v) {
                      final isSelected = v == variant;
                      return GestureDetector(
                        onTap: () => ref
                            .read(themeVariantProvider.notifier)
                            .setVariant(v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? v.gradient : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? v.primary
                                  : borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: v.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : v.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                v.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : subtextColor,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle,
                                    size: 14, color: Colors.white),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 3. Language Preferences ───────────────────────────────
            Text('LANGUAGE PREFERENCES',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mutedTextColor,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Understanding & Coaching Language',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                      'Select which language you want interview concept explanations in:',
                      style: TextStyle(fontSize: 12, color: subtextColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _langChoice('English', ExplanationLanguage.english, lang,
                          subtextColor, borderColor,
                          () => ref.read(languageProvider.notifier).setLanguage(ExplanationLanguage.english)),
                      const SizedBox(width: 8),
                      _langChoice('தமிழ் (Tamil)', ExplanationLanguage.tamil,
                          lang, subtextColor, borderColor,
                          () => ref.read(languageProvider.notifier).setLanguage(ExplanationLanguage.tamil)),
                      const SizedBox(width: 8),
                      _langChoice('हिन्दी (Hindi)', ExplanationLanguage.hindi,
                          lang, subtextColor, borderColor,
                          () => ref.read(languageProvider.notifier).setLanguage(ExplanationLanguage.hindi)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Interview Answer Language',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('English (Default)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 4. Safety, Data & Compliance ──────────────────────────
            Text('SAFETY, DATA & COMPLIANCE',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mutedTextColor,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.flag_outlined,
                        color: AppColors.warning),
                    title: const Text('Report AI Content',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'Flag inaccurate, offensive, or bad translations',
                        style:
                            TextStyle(fontSize: 12, color: subtextColor)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ReportAIModal.show(context,
                          contentId: 'general',
                          contentType: 'general_feedback');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined,
                        color: AppColors.success),
                    title: const Text('Data Safety & Privacy Map',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'Resumes are processed securely without third-party sale',
                        style:
                            TextStyle(fontSize: 12, color: subtextColor)),
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
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Understood')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever,
                        color: AppColors.danger),
                    title: const Text('Delete Account',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger)),
                    subtitle: Text(
                        'Permanently erase all personal data and packs',
                        style:
                            TextStyle(fontSize: 12, color: subtextColor)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AccountDeletionScreen()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 5. Sign Out ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                      color: AppColors.danger.withOpacity(0.4), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                          'Are you sure you want to sign out of IntervueX?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: const Text('Sign Out',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                    }
                    await FirebaseService.instance.signOut();
                    ref.read(shellNavIndexProvider.notifier).state = 0;
                    ref.read(activePackIdProvider.notifier).state = null;
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: variant.gradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt,
                            color: Colors.white, size: 24),
                      ),
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
    final primary = Theme.of(context).colorScheme.primary;
    final isSelected = choice == currentMode;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? primary : borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? Colors.white : subtextColor),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.electricIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected
                    ? AppColors.electricIndigo
                    : borderColor),
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

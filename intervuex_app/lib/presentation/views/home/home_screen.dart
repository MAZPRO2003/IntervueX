import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/providers/theme_provider.dart';
import 'package:intervuex_app/presentation/views/jobs/analyze_job_screen.dart';
import 'package:intervuex_app/presentation/views/resumes/analyze_resume_screen.dart';
import 'package:intervuex_app/presentation/views/packs/pack_dashboard_screen.dart';
import 'package:intervuex_app/presentation/views/packs/packs_list_screen.dart';
import 'package:intervuex_app/presentation/views/questions/question_list_screen.dart';
import 'package:intervuex_app/presentation/views/companies/companies_directory_screen.dart';
import 'package:intervuex_app/presentation/views/companies/company_tracks_sheet.dart';
import 'package:intervuex_app/presentation/providers/company_provider.dart';
import 'package:intervuex_app/data/models/pack_model.dart';
import 'package:intervuex_app/presentation/views/questions/flashcards_screen.dart';
import 'package:intervuex_app/presentation/views/questions/code_sandbox_screen.dart';
import 'package:intervuex_app/presentation/views/shell/main_shell_screen.dart';
import 'package:intervuex_app/presentation/views/profile/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _displayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return 'there';
    final name = user.displayName ?? '';
    if (name.isNotEmpty) return name.split(' ').first;
    return user.email?.split('@').first ?? 'there';
  }

  String _initials() {
    final user = FirebaseAuth.instance.currentUser;
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
    final packsAsync = ref.watch(packsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final variant = ref.watch(themeVariantProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: variant.gradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'InterVueX',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          // Profile avatar — taps to open Profile screen
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: variant.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(packsListProvider.notifier).loadPacks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ── Personalized Greeting ──────────────────────────────
              Text(
                '${_greeting()}, ${_displayName()} 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Let\'s crush your next interview.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // 2. ── Active Pack Hero Banner ─────────────────────────────
              packsAsync.when(
                data: (packs) {
                  final activeId = ref.watch(activePackIdProvider);
                  InterviewPackModel? targetPack;
                  if (activeId != null) {
                    try {
                      targetPack = packs.firstWhere((p) => p.id == activeId);
                    } catch (_) {
                      targetPack = packs.isNotEmpty ? packs.first : null;
                    }
                  } else if (packs.isNotEmpty) {
                    targetPack = packs.first;
                  }

                  if (targetPack == null) {
                    // No pack — CTA to add one
                    return _buildNoPackBanner(context, primary, isDark);
                  }

                  return _buildActivePackBanner(
                      context, ref, targetPack, variant, isDark, primary, secondary);
                },
                loading: () => Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _buildNoPackBanner(context, primary, isDark),
              ),

              const SizedBox(height: 24),

              // 3. ── Quick Actions Grid ──────────────────────────────────
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textDarkMuted
                        : AppColors.textLightMuted,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _actionTile(
                      context,
                      icon: Icons.quiz_rounded,
                      label: 'Practice\nQuestions',
                      color: primary,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const QuestionListScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionTile(
                      context,
                      icon: Icons.mic_rounded,
                      label: 'Mock\nInterview',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        ref.read(shellNavIndexProvider.notifier).state = 2;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionTile(
                      context,
                      icon: Icons.upload_file_rounded,
                      label: 'Analyze\nResume',
                      color: const Color(0xFFF97316),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AnalyzeResumeScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionTile(
                      context,
                      icon: Icons.auto_awesome_rounded,
                      label: 'AI\nCoach',
                      color: secondary,
                      onTap: () {
                        ref.read(shellNavIndexProvider.notifier).state = 3;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. ── Explore Top Companies ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOP COMPANIES',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textDarkMuted
                            : AppColors.textLightMuted,
                        letterSpacing: 0.5),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CompaniesDirectoryScreen()));
                    },
                    child: Text(
                      'View All →',
                      style: TextStyle(
                          fontSize: 12,
                          color: primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ref.watch(companiesListProvider).when(
                    data: (companies) => SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: companies.length,
                        itemBuilder: (context, cIdx) {
                          final comp = companies[cIdx];
                          final cColor = _parseColor(comp.colorHex);
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () => CompanyTracksSheet.show(context, comp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: cColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            comp.shortName.length > 3
                                                ? comp.shortName.substring(0, 3)
                                                : comp.shortName,
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: cColor),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${comp.hiringPrograms.length}T',
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    comp.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comp.category,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? AppColors.textDarkMuted
                                            : AppColors.textLightMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator())),
                    error: (e, s) => const SizedBox(),
                  ),

              const SizedBox(height: 24),

              // 5. ── AI Practice Tools ───────────────────────────────────
              Text(
                'PRACTICE TOOLS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textDarkMuted
                        : AppColors.textLightMuted,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _toolCard(
                      context,
                      icon: Icons.style_rounded,
                      color: primary,
                      title: 'Swipe Flashcards',
                      subtitle: 'Tinder-style rapid drill with STAR guides',
                      cta: 'Start Swiping',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FlashcardsScreen())),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _toolCard(
                      context,
                      icon: Icons.code_rounded,
                      color: AppColors.success,
                      title: 'Code Sandbox',
                      subtitle: 'Write & run code with AI analysis',
                      cta: 'Open Editor',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CodeSandboxScreen())),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 6. ── My Interview Packs ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MY INTERVIEW PACKS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textDarkMuted
                            : AppColors.textLightMuted,
                        letterSpacing: 0.5),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PacksListScreen()));
                    },
                    child: Text(
                      'View All →',
                      style: TextStyle(
                          fontSize: 12,
                          color: primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              packsAsync.when(
                data: (packs) {
                  if (packs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: primary.withOpacity(0.15), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              size: 32, color: primary.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'No interview packs yet',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Analyze a job to create your first personalized pack',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textLightSecondary),
                          ),
                          const SizedBox(height: 14),
                          AppButton(
                            label: 'Analyze a Job',
                            icon: Icons.add_circle_outline,
                            width: double.infinity,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AnalyzeJobScreen()));
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: packs.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () {
                            ref
                                .read(activePackIdProvider.notifier)
                                .state = p.id;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PackDashboardScreen()));
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primary.withOpacity(0.2),
                                      secondary.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    p.company.isNotEmpty ? p.company[0] : 'C',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.company,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(
                                        '${p.role} • ${p.hiringProgram}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.textDarkSecondary
                                                : AppColors.textLightSecondary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${p.readinessPercentage}%',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success),
                                  ),
                                  Text(
                                    'Ready',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.textDarkMuted
                                            : AppColors.textLightMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator())),
                error: (e, _) =>
                    Center(child: Text('Error loading packs: $e')),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPackBanner(
      BuildContext context, Color primary, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.15), primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'GET STARTED',
              style: TextStyle(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready for your next interview?',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Analyze a job posting to generate a personalized interview pack with verified questions, study plan, and mock sessions.',
            style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
                height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AnalyzeJobScreen()));
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Analyze a Job',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withOpacity(0.6), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AnalyzeResumeScreen()));
                  },
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Upload Resume',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePackBanner(
    BuildContext context,
    WidgetRef ref,
    InterviewPackModel pack,
    AppThemeVariant variant,
    bool isDark,
    Color primary,
    Color secondary,
  ) {
    final readiness =
        (pack.readinessPercentage / 100.0).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () {
        ref.read(activePackIdProvider.notifier).state = pack.id;
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PackDashboardScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: variant.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pack.hiringProgram.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pack.daysRemaining}d left',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(pack.company,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text('${pack.role} • ${pack.location}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13)),
                const SizedBox(height: 18),
                // Metrics row
                Row(
                  children: [
                    _metricBox('Readiness', '${pack.readinessPercentage}%',
                        AppColors.success),
                    const SizedBox(width: 10),
                    _metricBox(
                        'Questions', '${pack.totalQuestions}', Colors.white70),
                    const SizedBox(width: 10),
                    _metricBox(
                        'Mastered', '${pack.masteredQuestions}', Colors.white70),
                  ],
                ),
                const SizedBox(height: 16),
                // Readiness progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Interview Readiness',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11),
                        ),
                        Text(
                          '${pack.readinessPercentage}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 6,
                      percent: readiness,
                      progressColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      barRadius: const Radius.circular(3),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Continue Prep →',
                            style: TextStyle(
                                color: primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String cta,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                    height: 1.3)),
            const SizedBox(height: 10),
            Text(cta,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.electricIndigo;
    }
  }
}

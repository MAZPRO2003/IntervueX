import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/views/jobs/analyze_job_screen.dart';
import 'package:intervuex_app/presentation/views/resumes/analyze_resume_screen.dart';
import 'package:intervuex_app/presentation/views/packs/pack_dashboard_screen.dart';
import 'package:intervuex_app/presentation/views/packs/packs_list_screen.dart';
import 'package:intervuex_app/presentation/views/questions/question_list_screen.dart';
import 'package:intervuex_app/presentation/views/study_plan/study_plan_screen.dart';
import 'package:intervuex_app/presentation/views/companies/companies_directory_screen.dart';
import 'package:intervuex_app/presentation/views/companies/company_tracks_sheet.dart';
import 'package:intervuex_app/presentation/providers/company_provider.dart';
import 'package:intervuex_app/data/models/pack_model.dart';
import 'package:intervuex_app/presentation/views/questions/flashcards_screen.dart';
import 'package:intervuex_app/presentation/views/questions/code_sandbox_screen.dart';
import 'package:intervuex_app/presentation/views/resumes/pdf_resume_risk_viewer_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(packsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricIndigo.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'InterVueX',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text('ONLINE', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(packsListProvider.notifier).loadPacks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.heroCardGradient : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricIndigo.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'AI PREPARATION COACH',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ready for your next interview?',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Analyze a job. Understand the process. Practice what matters.',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.electricIndigo,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyzeJobScreen()));
                            },
                            icon: const Icon(Icons.add_circle_outline, size: 16),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('+ ANALYZE A JOB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyzeResumeScreen()));
                            },
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('UPLOAD RESUME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Current Interview Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CURRENT TARGET INTERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                    icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.indigoLight),
                    label: const Text('Change Target', style: TextStyle(fontSize: 12, color: AppColors.indigoLight, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              packsAsync.when(
                data: (packs) {
                  final activeId = ref.watch(activePackIdProvider);
                  InterviewPackModel? targetPack;
                  if (activeId != null) {
                    try {
                      targetPack = packs.firstWhere((p) => p.id == activeId);
                    } catch (_) {
                      targetPack = null;
                    }
                  }

                  if (targetPack == null) {
                    return AppCard(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.electricIndigo.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.track_changes, size: 32, color: AppColors.indigoLight),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Target Interview Selected',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select your target company & hiring track to personalize your AI interview prep, questions, and readiness tracker.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Choose Target Interview',
                            icon: Icons.add_circle_outline,
                            width: double.infinity,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                            },
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  }

                  final readiness = (targetPack.readinessPercentage / 100.0).clamp(0.0, 1.0);

                  return AppCard(
                    onTap: () {
                      ref.read(activePackIdProvider.notifier).state = targetPack!.id;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PackDashboardScreen()));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(targetPack.company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(targetPack.hiringProgram, style: const TextStyle(fontSize: 13, color: AppColors.indigoLight, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.electricIndigo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${targetPack.daysRemaining} Days Left', style: const TextStyle(color: AppColors.indigoLight, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Interview Readiness', style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                            Text('${targetPack.readinessPercentage}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          lineHeight: 8,
                          percent: readiness,
                          progressColor: AppColors.success,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          barRadius: const Radius.circular(4),
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Continue Preparation',
                          icon: Icons.arrow_forward,
                          width: double.infinity,
                          onPressed: () {
                            ref.read(activePackIdProvider.notifier).state = targetPack!.id;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PackDashboardScreen()));
                          },
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                error: (e, s) => const SizedBox(),
              ),

              const SizedBox(height: 20),

              // 2.5 Explore Companies Carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('EXPLORE TOP COMPANIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                  TextButton(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                    },
                    child: const Text('View All (10+) ->', style: TextStyle(fontSize: 12, color: AppColors.indigoLight, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ref.watch(companiesListProvider).when(
                data: (companies) {
                  return SizedBox(
                    height: 136,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: companies.length,
                      itemBuilder: (context, cIdx) {
                        final comp = companies[cIdx];
                        final cColor = _parseColor(comp.colorHex);

                        return Container(
                          width: 160,
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
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          comp.shortName.length > 3 ? comp.shortName.substring(0, 3) : comp.shortName,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cColor),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.electricIndigo.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${comp.hiringPrograms.length} Tracks',
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.indigoLight),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  comp.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comp.category,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textDarkMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                error: (e, s) => const SizedBox(),
              ),

              const SizedBox(height: 20),

              // 2.8 Interactive AI Tools & Accelerators
              const Text('AI PRACTICE & RESUME TOOLS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Flashcards Card
                    SizedBox(
                      width: 170,
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardsScreen()));
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.style, color: AppColors.electricIndigo, size: 20),
                                SizedBox(width: 6),
                                Expanded(child: Text('Swipe Flashcards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            Spacer(),
                            Text('Tinder-style daily rapid drill with STAR guides.', style: TextStyle(fontSize: 10, color: AppColors.textDarkSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4),
                            Text('Swipe Practice ->', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Code Sandbox Card
                    SizedBox(
                      width: 170,
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CodeSandboxScreen()));
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.code, color: AppColors.success, size: 20),
                                SizedBox(width: 6),
                                Expanded(child: Text('Code Sandbox', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            Spacer(),
                            Text('Write & run Python/SQL code live with Big-O AI check.', style: TextStyle(fontSize: 10, color: AppColors.textDarkSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4),
                            Text('Open Sandbox ->', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // PDF Risk Inspector Card
                    SizedBox(
                      width: 170,
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfResumeRiskViewerScreen()));
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 20),
                                SizedBox(width: 6),
                                Expanded(child: Text('PDF Risk Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            Spacer(),
                            Text('Visual document risk overlay & ATS rewrite recommendations.', style: TextStyle(fontSize: 10, color: AppColors.textDarkSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4),
                            Text('Inspect Resume ->', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Today's Practice & Weak Areas
              Row(

                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionListScreen()));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt, color: AppColors.warning, size: 18),
                              SizedBox(width: 4),
                              Text("TODAY'S DRILL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('5 Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Scheduled for revision', style: TextStyle(fontSize: 11, color: AppColors.textDarkSecondary)),
                          const SizedBox(height: 10),
                          const Text('Start Practice ->', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigoLight)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlanScreen()));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                              SizedBox(width: 4),
                              Text("WEAK AREAS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _chip('SQL Joins'),
                              _chip('OOP Pillars'),
                              _chip('HR STAR'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text('Review Weak Areas ->', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigoLight)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. My Interview Packs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MY INTERVIEW PACKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PacksListScreen()));
                    },
                    child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.indigoLight, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              packsAsync.when(
                data: (packs) {
                  return Column(
                    children: packs.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () {
                            ref.read(activePackIdProvider.notifier).state = p.id;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PackDashboardScreen()));
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.electricIndigo.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    p.company.isNotEmpty ? p.company[0] : 'C',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigoLight),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.company, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('${p.role} • ${p.hiringProgram}', style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${p.readinessPercentage}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
                                  const Text('Ready', style: TextStyle(fontSize: 11, color: AppColors.textDarkMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Error loading packs: $e')),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.w600)),
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

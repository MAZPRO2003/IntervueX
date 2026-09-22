import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/data/models/study_plan_model.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/views/study_plan/daily_checkin_screen.dart';
import 'package:intervuex_app/presentation/views/questions/question_list_screen.dart';
import 'package:intervuex_app/presentation/views/mock/mock_interview_screen.dart';
import 'package:intervuex_app/presentation/providers/question_provider.dart';
import 'package:intervuex_app/data/services/api_service.dart';

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  void _openDayPractice(BuildContext context, WidgetRef ref, DayScheduleModel day) {
    if (day.dayNumber == 6 || day.title.toLowerCase().contains('mock')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewScreen()));
      return;
    }

    String targetCat = 'All';
    if (day.categoryFilter != null && day.categoryFilter!.isNotEmpty) {
      targetCat = day.categoryFilter!;
    } else if (day.dayNumber == 1 || day.title.toLowerCase().contains('oop')) {
      targetCat = 'OOP';
    } else if (day.dayNumber == 2 || day.title.toLowerCase().contains('sql')) {
      targetCat = 'SQL';
    } else if (day.dayNumber == 3 || day.title.toLowerCase().contains('project')) {
      targetCat = 'Project Based';
    } else if (day.dayNumber == 4 || day.title.toLowerCase().contains('coding')) {
      targetCat = 'Coding';
    } else if (day.dayNumber == 5 || day.title.toLowerCase().contains('hr')) {
      targetCat = 'HR';
    }

    ref.read(questionFilterProvider.notifier).state = QuestionFilterState(
      category: targetCat,
      onlyWeak: day.dayNumber == 7,
      onlySaved: false,
    );
    ref.read(questionsListProvider.notifier).loadQuestions();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionListScreen()));
  }

  void _openSpacedRevision(BuildContext context, WidgetRef ref, SpacedRevisionItemModel rev) {
    String queryText = rev.questionText;
    if (queryText.length > 20) {
      queryText = queryText.substring(0, 20);
    }
    ref.read(questionFilterProvider.notifier).state = QuestionFilterState(
      search: queryText,
      onlyWeak: false,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionListScreen()));
  }

  Future<void> _pickCalendarTargetDate(BuildContext context, WidgetRef ref) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      helpText: 'SELECT YOUR INTERVIEW DATE',
      confirmText: 'GENERATE PLAN',
    );

    if (picked != null) {
      final year = picked.year.toString().padLeft(4, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      final dateStr = '$year-$month-$day';

      try {
        await ApiService.instance.setTargetInterviewDate(packId, dateStr);
        ref.invalidate(activeStudyPlanProvider);
        ref.invalidate(activePackProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Study plan successfully recalculated for $dateStr!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update date: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyPlanAsync = ref.watch(activeStudyPlanProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparation Progress & Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Pick Interview Date Calendar',
            icon: Icon(Icons.calendar_month, color: primary),
            onPressed: () => _pickCalendarTargetDate(context, ref),
          ),
        ],
      ),
      body: studyPlanAsync.when(
        data: (plan) {
          if (plan == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.track_changes, size: 48, color: AppColors.indigoLight),
                    SizedBox(height: 16),
                    Text('No Target Interview Selected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Please choose a target company and hiring track to view your study plan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textDarkSecondary),
                    ),
                  ],
                ),
              ),
            );
          }
          final r = plan.readiness;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target Date & Calendar Switcher Header Card
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.calendar_today, color: primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TARGET INTERVIEW DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(
                              plan.targetInterviewDate != null && plan.targetInterviewDate!.isNotEmpty
                                  ? plan.targetInterviewDate!
                                  : 'Not set (Select below)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickCalendarTargetDate(context, ref),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Calendar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Daily Check-In & Task Carry Forward Banner
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyCheckinScreen()));
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primary.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(color: primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.playlist_add_check_circle, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Check-In & Carry Forward',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Track today\'s tasks & carried-forward items',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Check In →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 1. Personalized Readiness Card
                AppCard(
                  padding: const EdgeInsets.all(18),
                  gradient: isDark ? AppColors.darkCardGradient : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('OVERALL READINESS SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                          Text('${r.overallPercentage}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: LinearPercentIndicator(
                              padding: EdgeInsets.zero,
                              lineHeight: 10,
                              percent: r.overallPercentage / 100.0,
                              progressColor: AppColors.success,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              barRadius: const Radius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${plan.days.where((d) => d.isCompleted).length}/${plan.days.length} Days',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Next Best Action Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.recommend, color: primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NEXT BEST ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary)),
                                  const SizedBox(height: 2),
                                  Text(r.nextBestAction, style: const TextStyle(fontSize: 12, height: 1.35)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Text('Skill & Domain Breakdown:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      _skillBar('Technical & OOP', r.technicalScore, primary, isDark),
                      _skillBar('Resume Claims', r.resumeScore, AppColors.indigoLight, isDark),
                      _skillBar('Project Defense', r.projectScore, AppColors.cyanAccent, isDark),
                      _skillBar('Coding & DSA', r.codingScore, AppColors.warning, isDark),
                      _skillBar('SQL & Database', r.sqlDbScore, AppColors.danger, isDark),
                      _skillBar('HR & Behavioral', r.hrScore, AppColors.warning, isDark),
                      _skillBar('Company Knowledge', r.companyScore, AppColors.success, isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Spaced Revision Queue for Weak Questions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SPACED REVISION QUEUE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning, letterSpacing: 0.5)),
                    TextButton(
                      onPressed: () {
                        ref.read(questionFilterProvider.notifier).state = QuestionFilterState(onlyWeak: true);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionListScreen()));
                      },
                      child: const Text('Review Weak Questions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                ...plan.spacedRevisions.map((rev) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openSpacedRevision(context, ref, rev),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(rev.intervalStage, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rev.questionText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(rev.weakReason, style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.warning),
                        ],
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 24),

                // Dynamic Day-by-Day Roadmap
                Text('${plan.days.length}-DAY ADAPTIVE STUDY SCHEDULE', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                const SizedBox(height: 12),

                ...plan.days.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openDayPractice(context, ref, day),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'DAY ${day.dayNumber}: ${day.title.toUpperCase()}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textDarkMuted),
                                  const SizedBox(width: 4),
                                  Text('${day.estimatedMinutes}m', style: const TextStyle(fontSize: 12, color: AppColors.textDarkMuted)),
                                  const SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_ios, size: 12, color: primary),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: day.focusTopics.map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(t, style: const TextStyle(fontSize: 11)),
                            )).toList(),
                          ),
                          const SizedBox(height: 10),
                          ...day.recommendedTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () => _openDayPractice(context, ref, day),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      task,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(Icons.arrow_right, size: 16, color: primary),
                                ],
                              ),
                            ),
                          )),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openDayPractice(context, ref, day),
                              icon: Icon(
                                day.dayNumber == 6 ? Icons.mic : Icons.play_arrow,
                                size: 16,
                                color: primary,
                              ),
                              label: Text(
                                day.dayNumber == 6
                                    ? 'Start Voice AI Mock Simulation →'
                                    : 'Practice Day ${day.dayNumber} Questions (${day.title}) →',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _skillBar(String title, int score, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text('$score%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 6,
            percent: score / 100.0,
            progressColor: color,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            barRadius: const Radius.circular(3),
          ),
        ],
      ),
    );
  }
}

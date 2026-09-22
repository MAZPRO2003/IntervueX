import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/core/widgets/evidence_badge.dart';
import 'package:intervuex_app/data/models/pack_model.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/views/questions/question_list_screen.dart';
import 'package:intervuex_app/presentation/views/mock/mock_interview_screen.dart';
import 'package:intervuex_app/presentation/views/study_plan/daily_checkin_screen.dart';
import 'package:intervuex_app/presentation/views/study_plan/study_plan_screen.dart';
import 'package:intervuex_app/presentation/views/companies/companies_directory_screen.dart';

class PackDashboardScreen extends ConsumerStatefulWidget {
  const PackDashboardScreen({super.key});

  @override
  ConsumerState<PackDashboardScreen> createState() => _PackDashboardScreenState();
}

class _PackDashboardScreenState extends ConsumerState<PackDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final packAsync = ref.watch(activePackProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Pack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: packAsync.when(
        data: (pack) {
          if (pack == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.track_changes, size: 48, color: AppColors.indigoLight),
                    const SizedBox(height: 16),
                    const Text('No Target Interview Selected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Please choose a target company and hiring track to view your interview dashboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textDarkSecondary),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Choose Target Interview',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final processAsync = ref.watch(activePackProcessProvider);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Pack Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.electricIndigo.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.electricIndigo.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                pack.hiringProgram.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${pack.daysRemaining} Days Left',
                            style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(pack.company, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${pack.role} • ${pack.location}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _metricBox('Readiness', '${pack.readinessPercentage}%', AppColors.success),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBox('Questions', '${pack.totalQuestions}', AppColors.indigoLight),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBox('Mastered', '${pack.masteredQuestions}', AppColors.cyanAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Mock Interview',
                        icon: Icons.mic_rounded,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Question Bank',
                        icon: Icons.quiz_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionListScreen()));
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Daily Check-In',
                        icon: Icons.fact_check_outlined,
                        variant: AppButtonVariant.primary,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyCheckinScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Study Plan',
                        icon: Icons.calendar_month,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlanScreen()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 28),

                // 3. Visual Timeline UI
                processAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error loading process: $e')),
                  data: (process) {
                    if (process == null) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'REPORTED INTERVIEW TIMELINE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConfidenceBadge(confidence: process.overallConfidence),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        ...process.rounds.map((round) {
                          final isLast = process.rounds.last == round;
                          return _timelineStep(
                            context: context,
                            roundNum: round.roundNumber,
                            title: round.stageName,
                            subtitle: round.assessmentFormat,
                            topics: round.expectedTopics,
                            evidence: round.evidenceItems.isNotEmpty ? round.evidenceItems.first.label : 'AI GENERATED',
                            questions: round.sampleQuestions,
                            isLast: isLast,
                          );
                        }),
                        
                        const SizedBox(height: 20),

                        // 4. Evidence Transparency & Variations
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: AppColors.indigoLight),
                                  SizedBox(width: 6),
                                  Text('Evidence & Source Variations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                process.evidenceSummary,
                                style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sources Analyzed: IntervueX Data Network, AI Aggregation.',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textDarkMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        ],
      ),
    );
  }

  void _showSampleQuestionsSheet(
    BuildContext context,
    String roundTitle,
    List<SampleQuestionModel> questions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = questions.where((q) {
              if (searchQuery.isEmpty) return true;
              return q.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
                     q.answer.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.quiz_outlined, color: AppColors.electricIndigo, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sample Questions & Answers (${questions.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roundTitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.indigoLight, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search questions or answers...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No questions match your search',
                              style: TextStyle(color: AppColors.textDarkMuted, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final q = filtered[index];
                              final origIndex = questions.indexOf(q) + 1;
                              return _SampleQuestionItemCard(
                                index: origIndex,
                                question: q,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _timelineStep({
    required BuildContext context,
    required int roundNum,
    required String title,
    required String subtitle,
    required List<String> topics,
    required String evidence,
    required List<SampleQuestionModel> questions,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.electricIndigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.indigoLight, width: 2),
                ),
                child: Center(
                  child: Text('$roundNum', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.electricIndigo.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        EvidenceBadge(label: evidence),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: topics.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.electricIndigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.indigoLight, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                    if (questions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.help_outline, size: 14, color: AppColors.indigoLight),
                          const SizedBox(width: 4),
                          Text(
                            'Sample Questions (${questions.length})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...questions.take(3).map((q) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.indigoLight, fontSize: 12)),
                            Expanded(
                              child: Text(
                                q.question,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _showSampleQuestionsSheet(context, title, questions),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.electricIndigo.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.indigoLight.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View all ${questions.length} questions & answers',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.indigoLight),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleQuestionItemCard extends StatefulWidget {
  final int index;
  final SampleQuestionModel question;

  const _SampleQuestionItemCard({
    required this.index,
    required this.question,
  });

  @override
  State<_SampleQuestionItemCard> createState() => _SampleQuestionItemCardState();
}

class _SampleQuestionItemCardState extends State<_SampleQuestionItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricIndigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${widget.index}',
                  style: const TextStyle(
                    color: AppColors.indigoLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  q.category,
                  style: const TextStyle(fontSize: 10, color: AppColors.textDarkSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded ? Icons.visibility_off_outlined : Icons.lightbulb_outline,
                  size: 14,
                  color: AppColors.indigoLight,
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpanded ? 'Hide Answer' : 'View Sample Answer',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.indigoLight,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 14,
                  color: AppColors.indigoLight,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.electricIndigo.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DETAILED ANSWER & APPROACH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.indigoLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.answer,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  if (q.codeSnippet != null && q.codeSnippet!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        q.codeSnippet!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF38BDF8),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

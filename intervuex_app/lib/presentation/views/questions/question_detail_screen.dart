import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/core/widgets/evidence_badge.dart';
import 'package:intervuex_app/core/widgets/report_ai_modal.dart';
import 'package:intervuex_app/data/models/question_model.dart';
import 'package:intervuex_app/presentation/providers/language_provider.dart';
import 'package:intervuex_app/presentation/providers/question_provider.dart';
import 'package:intervuex_app/presentation/views/mock/mock_interview_screen.dart';
import 'package:intervuex_app/presentation/views/questions/code_sandbox_screen.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final QuestionModel question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final selectedLang = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String explanationText = switch (selectedLang) {
      ExplanationLanguage.tamil => q.howToAnswer.explanationTa.isNotEmpty
          ? q.howToAnswer.explanationTa
          : q.howToAnswer.explanationEn,
      ExplanationLanguage.hindi => q.howToAnswer.explanationHi.isNotEmpty
          ? q.howToAnswer.explanationHi
          : q.howToAnswer.explanationEn,
      ExplanationLanguage.english => q.howToAnswer.explanationEn,
    };

    final isVerified = q.verificationStatus.toUpperCase().contains('VERIFIED');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          q.company.isNotEmpty ? '${q.company} Interview' : 'Question Coaching',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, size: 20),
            tooltip: 'Report Content',
            onPressed: () {
              ReportAIModal.show(context, contentId: q.id, contentType: 'question');
            },
          ),
          IconButton(
            icon: Icon(q.isSaved ? Icons.star : Icons.star_border, color: q.isSaved ? AppColors.warning : null),
            onPressed: () {
              setState(() => q.isSaved = !q.isSaved);
              ref.read(questionsListProvider.notifier).toggleSave(q.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company & Round Sub-Header
            if (q.company.isNotEmpty || q.round.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.electricIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.electricIndigo.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: AppColors.indigoLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${q.company.toUpperCase()}${q.role.isNotEmpty ? ' • ${q.role}' : ''}${q.round.isNotEmpty ? ' • ${q.round}' : ''}${q.questionYear.isNotEmpty ? ' (${q.questionYear})' : ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Category & Difficulty Badges
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.electricIndigo.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    q.category.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight),
                  ),
                ),
                _badge(q.difficulty, AppColors.warning),
                _badge(isVerified ? 'VERIFIED ANSWER ✓' : 'RESEARCHED ANSWER ✓', AppColors.success),
                EvidenceBadge(label: q.evidenceLabel),
              ],
            ),
            const SizedBox(height: 12),

            // Question Text
            Text(
              q.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.35),
            ),
            if (q.frequencyEvidence != null) ...[
              const SizedBox(height: 8),
              Text(
                '🔥 ${q.frequencyEvidence}',
                style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ],

            if (q.askedByCompanies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: q.askedByCompanies.map((c) => _badge(c, AppColors.success)).toList(),
              ),
            ],

            const SizedBox(height: 18),

            // 1. Short Verbal Answer (Elevator Pitch)
            if (q.howToAnswer.shortAnswerEn.isNotEmpty) ...[
              const Text('SHORT INTERVIEW ANSWER (30-60 SECONDS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              AppCard(
                borderColor: AppColors.success.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Verbal Answer (${q.company.isNotEmpty ? q.company : 'Interview'})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${q.howToAnswer.shortAnswerEn}"',
                      style: const TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Language Selector & Detailed Explanation
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('EXPLANATION LANGUAGE:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                  const SizedBox(width: 12),
                  _langButton('English', ExplanationLanguage.english, selectedLang),
                  const SizedBox(width: 6),
                  _langButton('தமிழ்', ExplanationLanguage.tamil, selectedLang),
                  const SizedBox(width: 6),
                  _langButton('हिन्दी', ExplanationLanguage.hindi, selectedLang),
                ],
              ),
            ),
            const SizedBox(height: 10),

            AppCard(
              gradient: isDark ? AppColors.darkCardGradient : null,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                      SizedBox(width: 8),
                      Text('HOW SHOULD I ANSWER?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warning)),
                    ],
                  ),
                  if (q.howToAnswer.interviewerIntent.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Interviewer Intent:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                    const SizedBox(height: 4),
                    Text(
                      q.howToAnswer.interviewerIntent,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Text('Coaching & Technical Explanation:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                  const SizedBox(height: 4),
                  Text(
                    explanationText,
                    style: const TextStyle(fontSize: 13, height: 1.45),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Code / SQL / System Architecture Example
            if (q.howToAnswer.codeExample.isNotEmpty) ...[
              const Text('WORKING CODE / SOLUTION EXAMPLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (q.howToAnswer.complexity.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              q.howToAnswer.complexity,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        q.howToAnswer.codeExample,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFFE2E8F0), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 4. Interview Pro Tip
            if (q.howToAnswer.interviewTip.isNotEmpty) ...[
              AppCard(
                borderColor: AppColors.warning.withOpacity(0.4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('INTERVIEWER TIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                          const SizedBox(height: 4),
                          Text(q.howToAnswer.interviewTip, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Answer Structure
            if (q.howToAnswer.answerStructure.isNotEmpty) ...[
              const Text('ANSWER STRUCTURE (STEP-BY-STEP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: q.howToAnswer.answerStructure.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.indigoLight, size: 16),
                        const SizedBox(width: 10),
                        Expanded(child: Text(step, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 6. Likely Follow-ups (with AI Practice Follow-up label)
            if (q.followUpQuestions.isNotEmpty) ...[
              const Text('LIKELY INTERVIEWER FOLLOW-UPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: q.followUpQuestions.map((f) {
                    final isAiFollowup = f.startsWith('AI Practice Follow-up:');
                    final text = isAiFollowup ? f.replaceFirst('AI Practice Follow-up:', '').trim() : f;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_alt, color: AppColors.indigoLight, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                                children: [
                                  if (isAiFollowup)
                                    const TextSpan(
                                      text: '[AI Practice Follow-up] ',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.electricIndigo, fontSize: 11),
                                    ),
                                  TextSpan(text: text),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 7. Question & Answer Sources
            if (q.questionSources.isNotEmpty || q.answerSources.isNotEmpty) ...[
              const Text('SOURCES & VERIFICATION ATTRIBUTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (q.questionSources.isNotEmpty) ...[
                      const Text('📌 Question Source:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                      const SizedBox(height: 4),
                      ...q.questionSources.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${s.sourceName} (${s.sourceType})${s.sourceUrl.isNotEmpty ? ' - ${s.sourceUrl}' : ''}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary),
                        ),
                      )),
                      const SizedBox(height: 10),
                    ],
                    if (q.answerSources.isNotEmpty) ...[
                      const Text('📚 Answer Source:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                      const SizedBox(height: 4),
                      ...q.answerSources.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${s.sourceName} (${s.sourceType})${s.confidence != null ? ' [${s.confidence} Confidence]' : ''}${s.sourceUrl.isNotEmpty ? ' - ${s.sourceUrl}' : ''}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Practice in Mock',
                    icon: Icons.mic,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewScreen()));
                    },
                  ),
                ),
                if (q.category.toLowerCase().contains('coding') || q.category.toLowerCase().contains('sql')) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Code Sandbox',
                      icon: Icons.code,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CodeSandboxScreen()));
                      },
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: q.mastered ? 'Mastered ✓' : 'Mark Mastered',
                    variant: q.mastered ? AppButtonVariant.secondary : AppButtonVariant.outline,
                    onPressed: () {
                      setState(() => q.mastered = !q.mastered);
                      ref.read(questionsListProvider.notifier).toggleMastered(q.id);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _langButton(String label, ExplanationLanguage lang, ExplanationLanguage current) {
    final isSelected = lang == current;
    return InkWell(
      onTap: () => ref.read(languageProvider.notifier).setLanguage(lang),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.electricIndigo : const Color(0xFF475569)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textDarkSecondary,
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}


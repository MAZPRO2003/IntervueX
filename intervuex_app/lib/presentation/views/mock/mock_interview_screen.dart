import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/data/models/mock_model.dart';
import 'package:intervuex_app/presentation/providers/mock_provider.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final TextEditingController answerCtrl = TextEditingController();
  bool isVoiceRecording = false;
  String selectedMode = "Technical + HR";
  String selectedDifficulty = "Normal";

  final List<String> modes = [
    "Technical + HR",
    "Technical",
    "HR",
    "Project Based",
    "Coding",
  ];

  final List<String> difficulties = [
    "Easy",
    "Normal",
    "Hard",
    "Realistic",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final packId = ref.read(activePackIdProvider) ?? '';
      ref.read(mockSessionProvider.notifier).startSession(
        packId: packId,
        mode: selectedMode,
        difficulty: selectedDifficulty,
        totalTurns: 4,
      );
    });
  }

  @override
  void dispose() {
    answerCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = answerCtrl.text.trim();
    if (text.isEmpty) return;

    final session = ref.read(mockSessionProvider).value;
    if (session == null) return;

    ref.read(mockSessionProvider.notifier).submitAnswer(
      turnIndex: session.currentTurnIndex,
      answerText: text,
      isVoice: isVoiceRecording,
    );
    answerCtrl.clear();
    setState(() => isVoiceRecording = false);
  }

  void _simulateVoiceRecording() {
    setState(() => isVoiceRecording = !isVoiceRecording);
    if (isVoiceRecording && answerCtrl.text.isEmpty) {
      answerCtrl.text = "Hi, I am ready for the technical interview.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(mockSessionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Interview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Interview',
            onPressed: () {
              final packId = ref.read(activePackIdProvider) ?? '';
              ref.read(mockSessionProvider.notifier).startSession(
                packId: packId,
                mode: selectedMode,
                difficulty: selectedDifficulty,
                totalTurns: 4,
              );
            },
          ),
        ],
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (session.isCompleted) {
            return _buildCompletedView(session, isDark);
          }

          final activeTurn = session.turns.firstWhere(
            (t) => t.turnIndex == session.currentTurnIndex,
            orElse: () => session.turns.last,
          );

          return Column(
            children: [
              LinearProgressIndicator(
                value: session.currentTurnIndex / session.totalTurns,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                color: AppColors.electricIndigo,
                minHeight: 4,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('QUESTION ${session.currentTurnIndex} OF ${session.totalTurns}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.electricIndigo.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(activeTurn.questionCategory, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: session.turns.length,
                  itemBuilder: (context, idx) {
                    final t = session.turns[idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF1F5F9),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Interviewer (IntervueX AI)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                                    const SizedBox(height: 4),
                                    Text(t.interviewerQuestion, style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (t.candidateAnswer != null) ...[
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricIndigo.withOpacity(0.15),
                                    border: Border.all(color: AppColors.electricIndigo.withOpacity(0.4)),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('You (Candidate)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted)),
                                      const SizedBox(height: 4),
                                      Text(t.candidateAnswer!, style: const TextStyle(fontSize: 13, height: 1.4)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mic, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ],

                        if (t.evaluation != null) ...[
                          const SizedBox(height: 12),
                          _buildEvaluationCard(t.evaluation!, isDark),
                        ],

                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isVoiceRecording ? Icons.mic : Icons.mic_none,
                        color: isVoiceRecording ? AppColors.danger : AppColors.indigoLight,
                      ),
                      tooltip: 'Voice Mock Recording',
                      onPressed: _simulateVoiceRecording,
                    ),
                    Expanded(
                      child: TextField(
                        controller: answerCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Type or speak your answer...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.electricIndigo),
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEvaluationCard(AnswerEvaluationModel eval, bool isDark) {
    Color scoreColor = eval.overallScore >= 7.0
        ? AppColors.success
        : (eval.overallScore >= 4.0 ? AppColors.warning : AppColors.danger);

    return AppCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.electricIndigo.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI EVALUATION FEEDBACK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5)),
              Text('${eval.overallScore}/10', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: scoreColor)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _rubricItem('Accuracy', '${eval.technicalAccuracy}/10'),
              _rubricItem('Structure', '${eval.structure}/10'),
              _rubricItem('Clarity', '${eval.clarity}/10'),
              _rubricItem('Relevance', '${eval.relevance}/10'),
            ],
          ),

          if (eval.pacingFeedback != null && eval.pacingFeedback!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              eval.pacingFeedback!,
              style: TextStyle(
                fontSize: 12,
                color: eval.overallScore < 4.0 ? AppColors.danger : AppColors.indigoLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (eval.fillerWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '⚠️ Filler words detected: ${eval.fillerWords.join(", ")}',
              style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 6),

          const Text('What You Did Well:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
          ...eval.whatYouDidWell.map((w) => Text('• $w', style: const TextStyle(fontSize: 12))),

          const SizedBox(height: 6),
          const Text('How to Improve:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.electricIndigo)),
          ...eval.howToImprove.map((h) => Text('• $h', style: const TextStyle(fontSize: 12))),

          if (eval.whatYouShouldNotDo.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('WHAT YOU SHOULD NOT DO:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
            ...eval.whatYouShouldNotDo.map((item) => Text('• $item', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w500))),
          ],

          if (eval.whatCanTheyAskNext.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('What Can They Ask Next? (Predictive Follow-ups):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
            ...eval.whatCanTheyAskNext.map((f) => Text('→ $f', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
          ],
        ],
      ),
    );
  }

  Widget _rubricItem(String label, String score) {
    return Column(
      children: [
        Text(score, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDarkSecondary)),
      ],
    );
  }

  Widget _buildCompletedView(MockSessionModel session, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Mock Interview Completed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Average Evaluation Score: ${session.averageScore ?? 7.5}/10',
              style: const TextStyle(fontSize: 16, color: AppColors.success, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              session.finalFeedbackSummary ?? 'Great job completing your mock simulation.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textDarkSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Practice Again',
              icon: Icons.refresh,
              width: double.infinity,
              onPressed: () {
                final packId = ref.read(activePackIdProvider) ?? '';
                ref.read(mockSessionProvider.notifier).startSession(
                  packId: packId,
                  mode: selectedMode,
                  difficulty: selectedDifficulty,
                  totalTurns: 4,
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Pack Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

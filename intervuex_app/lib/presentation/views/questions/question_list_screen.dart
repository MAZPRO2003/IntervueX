import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/presentation/providers/question_provider.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/providers/leetcode_provider.dart';
import 'package:intervuex_app/data/models/leetcode_question_model.dart';
import 'package:intervuex_app/presentation/views/questions/question_detail_screen.dart';
import 'package:intervuex_app/presentation/views/mock/mock_interview_screen.dart';
import 'package:intervuex_app/presentation/views/companies/companies_directory_screen.dart';
import 'package:intervuex_app/presentation/views/questions/flashcards_screen.dart';
import 'package:intervuex_app/presentation/views/questions/code_sandbox_screen.dart';
import 'package:intervuex_app/data/services/api_service.dart';


class QuestionListScreen extends ConsumerStatefulWidget {
  const QuestionListScreen({super.key});

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  int activeTab = 0; // 0 = General Questions, 1 = LeetCode Questions

  final List<String> categories = [
    'All',
    'Most Asked',
    'OOP',
    'Project Based',
    'SQL',
    'Technical',
    'Coding',
    'HR',
    'Company Specific',
  ];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlStr) async {
    try {
      final Uri uri = Uri.parse(urlStr);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching URL $urlStr: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final activePackId = ref.watch(activePackIdProvider);
    final activePackAsync = ref.watch(activePackProvider);
    final questionsAsync = ref.watch(questionsListProvider);
    final leetcodeAsync = ref.watch(leetCodeQuestionsProvider);
    final filter = ref.watch(questionFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activePackId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Question Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business_center, size: 54, color: AppColors.indigoLight),
                const SizedBox(height: 16),
                const Text(
                  'No Target Company Selected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select a target company and hiring track to load company-specific interview questions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDarkSecondary),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Choose Target Company',
                  icon: Icons.add_circle_outline,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.style, color: AppColors.electricIndigo),
            tooltip: 'Swipe Flashcards',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.code, color: AppColors.success),
            tooltip: 'Code Execution Sandbox',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CodeSandboxScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.cyanAccent),
            tooltip: 'Refresh Question Set (100% Unique)',
            onPressed: () async {
              final packId = ref.read(activePackIdProvider);
              if (packId == null) return;
              final messenger = ScaffoldMessenger.of(context);
              try {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Generating fresh, 100% unique question set...'), duration: Duration(seconds: 1)),
                );
                await ApiService.instance.refreshQuestions(packId);
                ref.read(questionsListProvider.notifier).loadQuestions();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Question Bank updated with 100% unique questions!'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error refreshing questions: $e'), backgroundColor: AppColors.danger),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(filter.onlySaved ? Icons.star : Icons.star_border, color: filter.onlySaved ? AppColors.warning : null),
            tooltip: 'Show Saved Only',
            onPressed: () {
              ref.read(questionFilterProvider.notifier).state = filter.copyWith(onlySaved: !filter.onlySaved);
              ref.read(questionsListProvider.notifier).loadQuestions();
            },
          ),

          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: filter.difficulty != 'All' ? AppColors.electricIndigo : null),
            tooltip: 'Filter Difficulty (${filter.difficulty})',
            onSelected: (val) {
              ref.read(questionFilterProvider.notifier).state = filter.copyWith(difficulty: val);
              ref.read(questionsListProvider.notifier).loadQuestions();
              ref.read(leetCodeQuestionsProvider.notifier).loadLeetCodeQuestions();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'All', child: Text('All Difficulties')),
              const PopupMenuItem(value: 'Easy', child: Text('Easy')),
              const PopupMenuItem(value: 'Medium', child: Text('Medium')),
              const PopupMenuItem(value: 'Hard', child: Text('Hard')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Questions',
            onSelected: (val) {
              ref.read(questionFilterProvider.notifier).state = filter.copyWith(sortBy: val);
              ref.read(questionsListProvider.notifier).loadQuestions();
              ref.read(leetCodeQuestionsProvider.notifier).loadLeetCodeQuestions();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'Most Asked', child: Text('Sort: Most Asked')),
              const PopupMenuItem(value: 'Difficulty', child: Text('Sort: Difficulty')),
              const PopupMenuItem(value: 'Project Based', child: Text('Sort: Project Based')),
              const PopupMenuItem(value: 'JD Based', child: Text('Sort: JD Based')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 0. Active Target Company Banner
          activePackAsync.maybeWhen(
            data: (pack) {
              if (pack == null) return const SizedBox();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.electricIndigo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.electricIndigo.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.indigoLight, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target: ${pack.company} — ${pack.hiringProgram}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen()));
                      },
                      child: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox(),
          ),

          // 1. General vs LeetCode Sub-Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => activeTab = 0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: activeTab == 0 ? AppColors.electricIndigo : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'General Questions',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: activeTab == 0 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => activeTab = 1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: activeTab == 1 ? AppColors.electricIndigo : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'LeetCode Questions',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: activeTab == 1 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: activeTab == 0
                    ? 'Search questions, concepts, technologies...'
                    : 'Search LeetCode problems or topic tags...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          searchCtrl.clear();
                          ref.read(questionFilterProvider.notifier).state = filter.copyWith(search: '');
                          ref.read(questionsListProvider.notifier).loadQuestions();
                          ref.read(leetCodeQuestionsProvider.notifier).loadLeetCodeQuestions();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onSubmitted: (query) {
                ref.read(questionFilterProvider.notifier).state = filter.copyWith(search: query);
                if (activeTab == 0) {
                  ref.read(questionsListProvider.notifier).loadQuestions();
                } else {
                  ref.read(leetCodeQuestionsProvider.notifier).loadLeetCodeQuestions();
                }
              },
            ),
          ),

          // 3. Category Chips (Only for General Questions tab)
          if (activeTab == 0) ...[
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  final isSelected = filter.category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected,
                      selectedColor: AppColors.electricIndigo.withOpacity(0.2),
                      checkmarkColor: AppColors.indigoLight,
                      side: BorderSide(color: isSelected ? AppColors.electricIndigo : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                      onSelected: (_) {
                        ref.read(questionFilterProvider.notifier).state = filter.copyWith(category: cat);
                        ref.read(questionsListProvider.notifier).loadQuestions();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 4. Question List (General vs LeetCode)
          Expanded(
            child: activeTab == 0
                ? _buildGeneralQuestionsList(questionsAsync)
                : _buildLeetCodeQuestionsList(leetcodeAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralQuestionsList(AsyncValue questionsAsync) {
    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: AppColors.textDarkMuted),
                SizedBox(height: 12),
                Text('No matching questions found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Try adjusting filters or search terms.', style: TextStyle(color: AppColors.textDarkSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length + 1,
          itemBuilder: (context, idx) {
            if (idx == questions.length) {
              final notifier = ref.read(questionsListProvider.notifier);
              final isGenerating = notifier.isGeneratingMore;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.electricIndigo, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: isGenerating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.electricIndigo))
                      : const Icon(Icons.add, color: AppColors.electricIndigo),
                  label: Text(
                    isGenerating ? 'Generating 25 Unique Questions...' : 'Generate 25 More Questions (Semantic Deduplication)',
                    style: const TextStyle(color: AppColors.electricIndigo, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isGenerating
                      ? null
                      : () async {
                          setState(() {});
                          await ref.read(questionsListProvider.notifier).generateMore();
                          if (mounted) setState(() {});
                        },
                ),
              );
            }

            final q = questions[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuestionDetailScreen(question: q)),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.electricIndigo.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            q.category.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.indigoLight),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _difficultyBadge(q.difficulty),
                        const Spacer(),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            q.isSaved ? Icons.star : Icons.star_border,
                            size: 20,
                            color: q.isSaved ? AppColors.warning : AppColors.textDarkMuted,
                          ),
                          onPressed: () {
                            ref.read(questionsListProvider.notifier).toggleSave(q.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      q.question,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
                    ),
                    const SizedBox(height: 8),

                    if (q.frequencyEvidence != null) ...[
                      Text(
                        '🔥 ${q.frequencyEvidence}',
                        style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                    ],

                    if (q.askedByCompanies.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.business, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Asked by ${q.askedByCompanies.length} companies (e.g. ${q.askedByCompanies.first})',
                              style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          icon: const Icon(Icons.lightbulb_outline, size: 16),
                          label: const Text('How to Answer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => QuestionDetailScreen(question: q)),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.mic, size: 14),
                          label: const Text('Practice', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewScreen()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildLeetCodeQuestionsList(AsyncValue<List<LeetCodeQuestionModel>> leetcodeAsync) {
    return leetcodeAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code_off, size: 48, color: AppColors.textDarkMuted),
                SizedBox(height: 12),
                Text('No LeetCode problems found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Try searching or selecting another company.', style: TextStyle(color: AppColors.textDarkSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, idx) {
            final q = questions[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.code, size: 12, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('LEETCODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _difficultyBadge(q.difficulty),
                        const Spacer(),
                        if (q.frequency > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '🔥 ${q.frequency}% Freq',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(
                      q.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    const SizedBox(height: 8),

                    if (q.topics.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: q.topics.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.electricIndigo.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(fontSize: 11, color: AppColors.indigoLight, fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (q.acceptanceRate.isNotEmpty)
                          Text(
                            'Acceptance: ${q.acceptanceRate}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textDarkMuted),
                          )
                        else
                          const SizedBox(),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: const Text('Solve on LeetCode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _launchUrl(q.link),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading LeetCode problems: $e')),
    );
  }

  Widget _difficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = AppColors.success;
        break;
      case 'hard':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.warning;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

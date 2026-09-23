import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/data/models/question_model.dart';
import 'package:intervuex_app/data/models/leetcode_question_model.dart';
import 'package:intervuex_app/presentation/providers/question_provider.dart';
import 'package:intervuex_app/presentation/providers/leetcode_provider.dart';
import 'package:intervuex_app/data/services/api_service.dart';

class SandboxQuestionItem {
  final String id;
  final String title;
  final String difficulty;
  final String category;
  final List<String> topics;
  final String source; // 'Question Bank' or 'LeetCode'
  final String description;
  final String? codeExample;
  final String? complexity;
  final String? link;

  SandboxQuestionItem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.category,
    required this.topics,
    required this.source,
    required this.description,
    this.codeExample,
    this.complexity,
    this.link,
  });

  factory SandboxQuestionItem.fromQuestionModel(QuestionModel q) {
    return SandboxQuestionItem(
      id: q.id,
      title: q.question,
      difficulty: q.difficulty,
      category: q.category,
      topics: q.conceptsTested.isNotEmpty ? q.conceptsTested : [q.category],
      source: 'Question Bank',
      description: q.howToAnswer.explanationEn.isNotEmpty
          ? q.howToAnswer.explanationEn
          : (q.whyMatters.isNotEmpty ? q.whyMatters : q.question),
      codeExample: q.howToAnswer.codeExample,
      complexity: q.howToAnswer.complexity,
    );
  }

  factory SandboxQuestionItem.fromLeetCodeModel(LeetCodeQuestionModel q) {
    return SandboxQuestionItem(
      id: q.id,
      title: q.title,
      difficulty: q.difficulty,
      category: 'LeetCode',
      topics: q.topics,
      source: 'LeetCode',
      description: 'LeetCode Problem: ${q.title}. Company: ${q.company.isNotEmpty ? q.company : 'Top Tech Companies'}. Acceptance Rate: ${q.acceptanceRate}.',
      link: q.link,
    );
  }
}

class CodeSandboxScreen extends ConsumerStatefulWidget {
  final QuestionModel? initialQuestion;

  const CodeSandboxScreen({super.key, this.initialQuestion});

  @override
  ConsumerState<CodeSandboxScreen> createState() => _CodeSandboxScreenState();
}

class _CodeSandboxScreenState extends ConsumerState<CodeSandboxScreen> {
  SandboxQuestionItem? _selectedQuestion;
  String _selectedLanguage = 'Python 3';
  late CodeSyntaxController _codeController;
  final TextEditingController _searchCtrl = TextEditingController();

  String _filterDifficulty = 'All';
  String _filterSource = 'All';
  String _searchQuery = '';

  bool _isExecuting = false;
  Map<String, dynamic>? _executionResult;

  static const List<String> _languages = [
    'Python 3',
    'JavaScript',
    'Java',
    'PostgreSQL',
  ];

  static String _detectBestLanguage(SandboxQuestionItem item) {
    final fullText = '${item.title} ${item.category} ${item.topics.join(" ")} ${item.description}'.toLowerCase();

    if (fullText.contains('sql') ||
        fullText.contains('query') ||
        fullText.contains('queries') ||
        fullText.contains('select ') ||
        fullText.contains('database') ||
        fullText.contains('table') ||
        fullText.contains('postgres') ||
        fullText.contains('mysql') ||
        fullText.contains('join ') ||
        fullText.contains('group by') ||
        item.category.toLowerCase().contains('database') ||
        item.category.toLowerCase().contains('sql')) {
      return 'PostgreSQL';
    }

    if (fullText.contains('javascript') ||
        fullText.contains('js') ||
        fullText.contains('node') ||
        fullText.contains('react') ||
        fullText.contains('frontend') ||
        fullText.contains('dom') ||
        fullText.contains('async/await') ||
        fullText.contains('promise') ||
        item.category.toLowerCase().contains('javascript') ||
        item.category.toLowerCase().contains('frontend')) {
      return 'JavaScript';
    }

    if (fullText.contains('java ') ||
        fullText.contains('java8') ||
        fullText.contains('spring') ||
        fullText.contains('jvm') ||
        item.category.toLowerCase().contains('java')) {
      return 'Java';
    }

    return 'Python 3';
  }

  static String _getStarterCodeTemplate(String language, String questionTitle) {
    switch (language) {
      case 'PostgreSQL':
        return '-- PostgreSQL Query Solution for "$questionTitle"\n'
            '-- Write your SQL query below:\n\n'
            'SELECT *\n'
            'FROM table_name;\n';
      case 'JavaScript':
        return '// JavaScript Solution for "$questionTitle"\n'
            'function solution() {\n'
            '    // Write your solution here\n'
            '    return null;\n'
            '}\n';
      case 'Java':
        return '// Java Solution for "$questionTitle"\n'
            'public class Solution {\n'
            '    public static void main(String[] args) {\n'
            '        // Write your solution here\n'
            '    }\n'
            '}\n';
      case 'Python 3':
      default:
        return '# Python 3 Solution for "$questionTitle"\n'
            'def solution():\n'
            '    # Write your solution here\n'
            '    pass\n';
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeSyntaxController(
      language: _selectedLanguage,
      isDark: true,
    );
    if (widget.initialQuestion != null) {
      _selectedQuestion = SandboxQuestionItem.fromQuestionModel(widget.initialQuestion!);
      _selectedLanguage = _detectBestLanguage(_selectedQuestion!);
      _codeController.language = _selectedLanguage;
      if (_selectedQuestion!.codeExample != null && _selectedQuestion!.codeExample!.trim().isNotEmpty) {
        _codeController.text = _selectedQuestion!.codeExample!;
      } else {
        _codeController.text = _getStarterCodeTemplate(_selectedLanguage, _selectedQuestion!.title);
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectQuestion(SandboxQuestionItem item) {
    final detectedLang = _detectBestLanguage(item);
    setState(() {
      _selectedQuestion = item;
      _selectedLanguage = detectedLang;
      _codeController.language = detectedLang;
      _executionResult = null;
      if (item.codeExample != null && item.codeExample!.trim().isNotEmpty) {
        _codeController.text = item.codeExample!;
      } else {
        _codeController.text = _getStarterCodeTemplate(detectedLang, item.title);
      }
    });
  }

  void _insertSnippet(String snippet) {
    final text = _codeController.text;
    final selection = _codeController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, snippet);
    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
  }

  Future<void> _runCode() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isExecuting = true;
      _executionResult = null;
    });

    try {
      final langKey = _selectedLanguage.toLowerCase().contains('sql')
          ? 'sql'
          : _selectedLanguage.toLowerCase().contains('java') &&
                  !_selectedLanguage.toLowerCase().contains('javascript')
              ? 'java'
              : _selectedLanguage.toLowerCase().contains('javascript')
                  ? 'javascript'
                  : 'python';

      final res = await ApiService.instance.executeCode(
        code: _codeController.text,
        language: langKey,
        problemId: _selectedQuestion?.id,
      );

      setState(() {
        _executionResult = res;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error executing code: $e')),
      );
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.code_rounded, color: primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedQuestion == null ? 'Code Sandbox' : _selectedQuestion!.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedQuestion != null) ...[
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: Icon(Icons.swap_horiz, color: primary, size: 16),
              label: Text('Change Question', style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  _selectedQuestion = null;
                  _executionResult = null;
                });
              },
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13),
                icon: Icon(Icons.arrow_drop_down, color: primary),
                items: _languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedLanguage = val;
                      _codeController.language = val;
                      final text = _codeController.text;
                      if (text.isEmpty ||
                          text.startsWith('# Write your') ||
                          text.startsWith('# Python 3') ||
                          text.startsWith('-- PostgreSQL') ||
                          text.startsWith('// JavaScript') ||
                          text.startsWith('// Java')) {
                        _codeController.text = _getStarterCodeTemplate(_selectedLanguage, _selectedQuestion!.title);
                      }
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: _selectedQuestion == null
          ? _buildQuestionSelectionView(context)
          : _buildProblemSolvingView(context),
    );
  }

  // ─── STEP 1: QUESTION SELECTION VIEW ────────────────────────────────────────

  Widget _buildQuestionSelectionView(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final questionsAsync = ref.watch(questionsListProvider);
    final leetcodeAsync = ref.watch(leetCodeQuestionsProvider);

    List<SandboxQuestionItem> items = [];

    questionsAsync.whenData((qList) {
      for (final q in qList) {
        if (q.isCoding) {
          items.add(SandboxQuestionItem.fromQuestionModel(q));
        }
      }
    });

    leetcodeAsync.whenData((lcList) {
      for (final lc in lcList) {
        items.add(SandboxQuestionItem.fromLeetCodeModel(lc));
      }
    });

    // Apply local filters
    final filtered = items.where((item) {
      if (_filterDifficulty != 'All' && item.difficulty.toLowerCase() != _filterDifficulty.toLowerCase()) {
        return false;
      }
      if (_filterSource == 'Question Bank' && item.source != 'Question Bank') return false;
      if (_filterSource == 'LeetCode' && item.source != 'LeetCode') return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchTopic = item.topics.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchTopic) return false;
      }

      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title & sub
          Text(
            'Choose a Coding Question',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a problem to solve in the live interactive Code Sandbox.',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
          ),
          const SizedBox(height: 14),

          // Search bar
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search questions by title or topic...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
          ),
          const SizedBox(height: 12),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterDropdown('Difficulty', _filterDifficulty, ['All', 'Easy', 'Medium', 'Hard'], (val) {
                  setState(() => _filterDifficulty = val);
                }),
                const SizedBox(width: 8),
                _filterDropdown('Source', _filterSource, ['All', 'Question Bank', 'LeetCode'], (val) {
                  setState(() => _filterSource = val);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of coding questions
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.code_off, size: 48, color: AppColors.warning),
                        const SizedBox(height: 12),
                        const Text('No coding questions match your filter.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Try resetting search or selecting another company pack.', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
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
                                      color: (item.source == 'LeetCode' ? Colors.orange : primary).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.source.toUpperCase(),
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.source == 'LeetCode' ? Colors.orange : primary),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _difficultyBadge(item.difficulty),
                                  const Spacer(),
                                  Text(
                                    item.category,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Text(
                                item.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),

                              if (item.topics.isNotEmpty) ...[
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: item.topics.map((t) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                              ],

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                    label: const Text('Solve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () => _selectQuestion(item),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(String label, String currentVal, List<String> options, ValueChanged<String> onChanged) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: currentVal != 'All' ? primary : Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentVal != 'All' ? primary : (isDark ? Colors.white : Colors.black87)),
          icon: Icon(Icons.arrow_drop_down, color: currentVal != 'All' ? primary : Colors.grey, size: 18),
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text('$label: $opt'))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  // ─── STEP 2: PROBLEM SOLVING & CODE EDITOR VIEW ────────────────────────────

  Widget _buildProblemSolvingView(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _selectedQuestion!;

    return SafeArea(
      child: Column(
        children: [
          // Problem Statement Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _difficultyBadge(q.difficulty),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(q.source.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                    ),
                    const SizedBox(width: 8),
                    if (q.complexity != null && q.complexity!.isNotEmpty)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.timer_outlined, size: 13, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                q.complexity!,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  q.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(q.description, style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF334155))),
              ],
            ),
          ),

          // Language-Aware Code Editor Toolbar
          _buildToolbarForLanguage(isDark),

          // Real IDE Code Editor Surface with Line Numbers Gutter & Syntax Highlighting
          Expanded(
            child: RealCodeEditor(
              controller: _codeController,
              language: _selectedLanguage,
              isDark: isDark,
              onResetTemplate: () {
                setState(() {
                  _codeController.text = _getStarterCodeTemplate(_selectedLanguage, _selectedQuestion!.title);
                });
              },
            ),
          ),

          // Bottom Execution Bar & Output Drawer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: _isExecuting ? 'Executing...' : '▶ RUN CODE & TEST CASES',
                        isLoading: _isExecuting,
                        onPressed: _runCode,
                      ),
                    ),
                  ],
                ),

                if (_executionResult != null) ...[
                  const SizedBox(height: 12),
                  _buildExecutionResultsSheet(_executionResult!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarForLanguage(bool isDark) {
    final List<Widget> buttons = [
      _toolbarBtn('tab', () => _insertSnippet('    ')),
    ];

    if (_selectedLanguage == 'PostgreSQL') {
      buttons.addAll([
        _toolbarBtn('SELECT', () => _insertSnippet('SELECT ')),
        _toolbarBtn('FROM', () => _insertSnippet('FROM ')),
        _toolbarBtn('WHERE', () => _insertSnippet('WHERE ')),
        _toolbarBtn('JOIN', () => _insertSnippet('JOIN ')),
        _toolbarBtn('GROUP BY', () => _insertSnippet('GROUP BY ')),
        _toolbarBtn('ORDER BY', () => _insertSnippet('ORDER BY ')),
        _toolbarBtn('COUNT()', () => _insertSnippet('COUNT()')),
      ]);
    } else if (_selectedLanguage == 'JavaScript') {
      buttons.addAll([
        _toolbarBtn('const', () => _insertSnippet('const ')),
        _toolbarBtn('function', () => _insertSnippet('function ')),
        _toolbarBtn('return', () => _insertSnippet('return ')),
        _toolbarBtn('console.log', () => _insertSnippet('console.log()')),
        _toolbarBtn('=>', () => _insertSnippet(' => ')),
        _toolbarBtn('async/await', () => _insertSnippet('async ')),
      ]);
    } else if (_selectedLanguage == 'Java') {
      buttons.addAll([
        _toolbarBtn('public', () => _insertSnippet('public ')),
        _toolbarBtn('class', () => _insertSnippet('class ')),
        _toolbarBtn('return', () => _insertSnippet('return ')),
        _toolbarBtn('println', () => _insertSnippet('System.out.println();')),
        _toolbarBtn('int', () => _insertSnippet('int ')),
        _toolbarBtn('String', () => _insertSnippet('String ')),
      ]);
    } else {
      buttons.addAll([
        _toolbarBtn('def', () => _insertSnippet('def ')),
        _toolbarBtn('return', () => _insertSnippet('return ')),
        _toolbarBtn('for in', () => _insertSnippet('for i in range():')),
        _toolbarBtn('print()', () => _insertSnippet('print()')),
        _toolbarBtn('len()', () => _insertSnippet('len()')),
        _toolbarBtn('self', () => _insertSnippet('self')),
      ]);
    }

    return Container(
      color: isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: buttons),
      ),
    );
  }

  Widget _toolbarBtn(String label, VoidCallback onTap) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
          ),
          child: Text(
            label,
            style: GoogleFonts.firaCode(fontSize: 11, color: primary, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionResultsSheet(Map<String, dynamic> result) {
    final passedCount = result['tests_passed_count'] ?? 0;
    final totalCount = result['total_tests_count'] ?? 0;
    final success = result['success'] ?? false;
    final timeComp = result['time_complexity'] ?? 'O(N)';
    final spaceComp = result['space_complexity'] ?? 'O(1)';
    final critique = result['code_critique'] ?? '';
    final testResults = List<Map<String, dynamic>>.from(result['test_results'] ?? []);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (success ? AppColors.success : AppColors.danger).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(success ? Icons.check_circle : Icons.error, color: success ? AppColors.success : AppColors.danger, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        success ? 'PASSED ($passedCount/$totalCount Tests)' : 'FAILED ($passedCount/$totalCount Tests)',
                        style: TextStyle(color: success ? AppColors.success : AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${result['execution_time_ms'] ?? 0} ms',
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Big-O Complexity Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Time Complexity', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        Text(timeComp, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Space Complexity', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        Text(spaceComp, style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (critique.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '💡 AI Code Critique: $critique',
                  style: TextStyle(color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF334155), fontSize: 11, height: 1.3),
                ),
              ),
            ],

            const SizedBox(height: 10),
            Text('Test Cases Output:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),

            ...testResults.map((tc) {
              final tcPassed = tc['passed'] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tcPassed ? AppColors.success.withOpacity(0.3) : AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(tcPassed ? Icons.check : Icons.close, color: tcPassed ? AppColors.success : AppColors.danger, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Input: ${tc['input_val']} -> Output: ${tc['actual_output']}',
                        style: GoogleFonts.firaCode(fontSize: 11, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF475569)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
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

// ─── REAL IDE SYNTAX HIGHLIGHTING CONTROLLER ────────────────────────────────
class CodeSyntaxController extends TextEditingController {
  String language;
  final bool isDark;

  CodeSyntaxController({
    super.text,
    this.language = 'Python 3',
    this.isDark = true,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = GoogleFonts.firaCode(
      fontSize: 13,
      height: 1.45,
      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
    );

    final String textContent = text;
    if (textContent.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final spans = _parseSyntaxTokens(textContent, language, isDark, baseStyle);
    return TextSpan(style: baseStyle, children: spans);
  }

  static List<TextSpan> _parseSyntaxTokens(
    String code,
    String lang,
    bool isDark,
    TextStyle baseStyle,
  ) {
    final keywordColor = isDark ? const Color(0xFF569CD6) : const Color(0xFF005CC5);
    final stringColor = isDark ? const Color(0xFFCE9178) : const Color(0xFF032F62);
    final commentColor = isDark ? const Color(0xFF6A9955) : const Color(0xFF6A737D);
    final numberColor = isDark ? const Color(0xFFB5CEA8) : const Color(0xFF005CC5);
    final functionColor = isDark ? const Color(0xFFDCDCAA) : const Color(0xFF6F42C1);
    final sqlKeywordColor = isDark ? const Color(0xFFC586C0) : const Color(0xFFD73A49);

    final List<TextSpan> spans = [];

    RegExp tokenRegex;
    if (lang == 'PostgreSQL') {
      tokenRegex = RegExp(
        r'(--[^\n]*)|'
        r'("([^"\\]|\\.)*"|\x27([^\x27\\]|\\.)*\x27)|'
        r'(\b(?:SELECT|FROM|WHERE|JOIN|LEFT|RIGHT|INNER|OUTER|ON|GROUP|BY|ORDER|HAVING|LIMIT|OFFSET|INSERT|INTO|UPDATE|SET|DELETE|CREATE|TABLE|DROP|ALTER|AND|OR|NOT|IN|IS|NULL|AS|COUNT|SUM|AVG|MIN|MAX|DISTINCT|UNION|ALL|CASE|WHEN|THEN|ELSE|END)\b)|'
        r'(\b\d+(\.\d+)?\b)|'
        r'(\b[a-zA-Z_]\w*\b)',
        caseSensitive: false,
      );
    } else if (lang == 'JavaScript') {
      tokenRegex = RegExp(
        r'(\/\/[^\n]*|\/\*[\s\S]*?\*\/)|'
        r'("([^"\\]|\\.)*"|\x27([^\x27\\]|\\.)*\x27|`([^`\\]|\\.)*`)|'
        r'(\b(?:const|let|var|function|return|if|else|for|while|do|switch|case|break|continue|import|export|default|from|class|extends|new|this|async|await|try|catch|finally|throw|typeof|instanceof|void|yield|null|undefined|true|false)\b)|'
        r'(\b\d+(\.\d+)?\b)|'
        r'(\b[a-zA-Z_]\w*(?=\s*\())|'
        r'(\b[a-zA-Z_]\w*\b)',
      );
    } else if (lang == 'Java') {
      tokenRegex = RegExp(
        r'(\/\/[^\n]*|\/\*[\s\S]*?\*\/)|'
        r'("([^"\\]|\\.)*"|\x27([^\x27\\]|\\.)*\x27)|'
        r'(\b(?:public|private|protected|static|final|abstract|class|interface|extends|implements|void|int|double|float|long|boolean|char|byte|short|return|if|else|for|while|do|switch|case|break|continue|new|this|super|try|catch|finally|throw|throws|null|true|false)\b)|'
        r'(\b\d+(\.\d+)?\b)|'
        r'(\b[a-zA-Z_]\w*(?=\s*\())|'
        r'(\b[a-zA-Z_]\w*\b)',
      );
    } else {
      tokenRegex = RegExp(
        r'(#[^\n]*)|'
        r'("([^"\\]|\\.)*"|\x27([^\x27\\]|\\.)*\x27)|'
        r'(\b(?:def|return|if|elif|else|for|while|in|is|not|and|or|import|from|as|class|try|except|finally|raise|with|pass|break|continue|lambda|yield|global|nonlocal|assert|None|True|False|self)\b)|'
        r'(\b\d+(\.\d+)?\b)|'
        r'(\b[a-zA-Z_]\w*(?=\s*\())|'
        r'(\b[a-zA-Z_]\w*\b)',
      );
    }

    int lastIndex = 0;
    for (final Match match in tokenRegex.allMatches(code)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: code.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      final String token = match.group(0)!;

      if (lang == 'PostgreSQL') {
        if (match.group(1) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: commentColor, fontStyle: FontStyle.italic)));
        } else if (match.group(2) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: stringColor)));
        } else if (match.group(3) != null) {
          spans.add(TextSpan(text: token.toUpperCase(), style: baseStyle.copyWith(color: sqlKeywordColor, fontWeight: FontWeight.bold)));
        } else if (match.group(4) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: numberColor)));
        } else {
          spans.add(TextSpan(text: token, style: baseStyle));
        }
      } else {
        if (match.group(1) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: commentColor, fontStyle: FontStyle.italic)));
        } else if (match.group(2) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: stringColor)));
        } else if (match.group(3) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: keywordColor, fontWeight: FontWeight.bold)));
        } else if (match.group(4) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: numberColor)));
        } else if (match.group(5) != null) {
          spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: functionColor, fontWeight: FontWeight.w600)));
        } else {
          spans.add(TextSpan(text: token, style: baseStyle));
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < code.length) {
      spans.add(TextSpan(
        text: code.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }
}

// ─── REAL IDE CODE EDITOR WIDGET (LINE NUMBERS & STATUS BAR) ─────────────────
class RealCodeEditor extends StatefulWidget {
  final CodeSyntaxController controller;
  final String language;
  final bool isDark;
  final VoidCallback? onResetTemplate;

  const RealCodeEditor({
    super.key,
    required this.controller,
    required this.language,
    required this.isDark,
    this.onResetTemplate,
  });

  @override
  State<RealCodeEditor> createState() => _RealCodeEditorState();
}

class _RealCodeEditorState extends State<RealCodeEditor> {
  final ScrollController _scrollController = ScrollController();
  int _lineCount = 1;
  int _currentLine = 1;
  int _currentCol = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateEditorState);
    _updateEditorState();
  }

  @override
  void didUpdateWidget(covariant RealCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updateEditorState);
      widget.controller.addListener(_updateEditorState);
      _updateEditorState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateEditorState);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateEditorState() {
    final text = widget.controller.text;
    final lines = text.split('\n');
    final newCount = lines.isEmpty ? 1 : lines.length;

    final sel = widget.controller.selection;
    int line = 1;
    int col = 1;

    if (sel.isValid && sel.start >= 0 && sel.start <= text.length) {
      final sub = text.substring(0, sel.start);
      final subLines = sub.split('\n');
      line = subLines.length;
      col = subLines.last.length + 1;
    }

    if (mounted) {
      setState(() {
        _lineCount = newCount;
        _currentLine = line;
        _currentCol = col;
      });
    }
  }

  void _autoFormatCode() {
    final text = widget.controller.text;
    final lines = text.split('\n');
    final formattedLines = <String>[];
    for (final l in lines) {
      final trimmedRight = l.trimRight();
      formattedLines.add(trimmedRight);
    }
    widget.controller.text = formattedLines.join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code auto-formatted & trailing whitespace trimmed!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = widget.isDark;

    final editorBg = isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);
    final gutterBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9);
    final gutterText = isDark ? const Color(0xFF484F58) : const Color(0xFF94A3B8);
    final statusBarBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Column(
      children: [
        // Main Editor Surface with Line Numbers Gutter
        Expanded(
          child: Container(
            color: editorBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Numbers Gutter
                Container(
                  width: 44,
                  color: gutterBg,
                  padding: const EdgeInsets.only(top: 12, bottom: 12, right: 8),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_lineCount, (index) {
                        final lineNum = index + 1;
                        final isCurrent = lineNum == _currentLine;
                        return Container(
                          height: 18.85,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$lineNum',
                            style: GoogleFonts.firaCode(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? primary : gutterText,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Container(width: 1, color: borderColor),

                // Monospaced Syntax Editor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: TextField(
                      controller: widget.controller,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.firaCode(
                        fontSize: 13,
                        height: 1.45,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText: '// Write your code solution here...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // IDE Bottom Status Bar (Cursor position, stats, formatting controls)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusBarBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.language,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary),
                ),
              ),
              const SizedBox(width: 10),

              Text(
                'Ln $_currentLine, Col $_currentCol',
                style: GoogleFonts.firaCode(fontSize: 10, color: gutterText, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Text('•', style: TextStyle(fontSize: 10, color: gutterText)),
              const SizedBox(width: 8),

              Text(
                '$_lineCount lines (${widget.controller.text.length} chars)',
                style: GoogleFonts.firaCode(fontSize: 10, color: gutterText),
              ),

              const Spacer(),

              Tooltip(
                message: 'Auto-Format & Trim Spacing',
                child: InkWell(
                  onTap: _autoFormatCode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services_outlined, size: 13, color: primary),
                        const SizedBox(width: 4),
                        Text('Format', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Tooltip(
                message: 'Copy Code',
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard!'), duration: Duration(seconds: 1)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 12, color: primary),
                        const SizedBox(width: 4),
                        Text('Copy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                      ],
                    ),
                  ),
                ),
              ),

              if (widget.onResetTemplate != null) ...[
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Reset to Starter Code',
                  child: InkWell(
                    onTap: widget.onResetTemplate,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Icon(Icons.restart_alt, size: 14, color: AppColors.warning),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

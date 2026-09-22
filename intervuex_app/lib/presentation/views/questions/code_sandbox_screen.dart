import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/data/services/api_service.dart';

class CodeSandboxScreen extends ConsumerStatefulWidget {
  const CodeSandboxScreen({super.key});

  @override
  ConsumerState<CodeSandboxScreen> createState() => _CodeSandboxScreenState();
}

class _CodeSandboxScreenState extends ConsumerState<CodeSandboxScreen> {
  String _selectedLanguage = 'Python 3';
  late TextEditingController _codeController;
  bool _isExecuting = false;
  Map<String, dynamic>? _executionResult;

  static const List<String> _languages = [
    'Python 3',
    'JavaScript',
    'Java',
    'PostgreSQL',
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _insertSnippet(String snippet) {
    final text = _codeController.text;
    final selection = _codeController.selection;
    final newText = text.replaceRange(selection.start, selection.end, snippet);
    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + snippet.length),
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
        problemId: null,
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub Dark IDE style
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.code_rounded, color: primary, size: 20),
            const SizedBox(width: 8),
            const Text('Code Sandbox',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: const Color(0xFF161B22),
              style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              icon: Icon(Icons.arrow_drop_down, color: primary),
              underline: const SizedBox(),
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Code Editor Toolbar
            Container(
              color: const Color(0xFF161B22),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _toolbarBtn('tab', () => _insertSnippet('    ')),
                    _toolbarBtn('def', () => _insertSnippet('def ')),
                    _toolbarBtn('return', () => _insertSnippet('return ')),
                    _toolbarBtn('for', () => _insertSnippet('for i in range():')),
                    _toolbarBtn('print()', () => _insertSnippet('print()')),
                    _toolbarBtn('SELECT', () => _insertSnippet('SELECT ')),
                    _toolbarBtn('WHERE', () => _insertSnippet('WHERE ')),
                    _toolbarBtn('JOIN', () => _insertSnippet('JOIN ')),
                  ],
                ),
              ),
            ),

            // Monospaced Code Text Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF0D1117),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  style: GoogleFonts.firaCode(
                    fontSize: 13,
                    color: const Color(0xFFE6EDE3),
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '# Write your code here...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Bottom Execution Bar & Output Drawer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                border: Border(top: BorderSide(color: Color(0xFF30363D))),
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
      ),
    );
  }

  Widget _toolbarBtn(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Text(
            label,
            style: GoogleFonts.firaCode(fontSize: 11, color: const Color(0xFF58A6FF), fontWeight: FontWeight.bold),
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
                      color: const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Time Complexity', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        Text(timeComp, style: const TextStyle(color: AppColors.indigoLight, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21262D),
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
                  color: AppColors.electricIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.electricIndigo.withOpacity(0.3)),
                ),
                child: Text(
                  '💡 AI Code Critique: $critique',
                  style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 11, height: 1.3),
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Text('Test Cases Output:', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),

            ...testResults.map((tc) {
              final tcPassed = tc['passed'] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
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
                        style: GoogleFonts.firaCode(fontSize: 11, color: const Color(0xFF8B949E)),
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/data/services/api_service.dart';

final pdfRiskMapProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, resumeId) async {
  return await ApiService.instance.getResumeRiskMap(resumeId);
});

class PdfResumeRiskViewerScreen extends ConsumerStatefulWidget {
  final String? resumeId;
  const PdfResumeRiskViewerScreen({super.key, this.resumeId});

  @override
  ConsumerState<PdfResumeRiskViewerScreen> createState() => _PdfResumeRiskViewerScreenState();
}

class _PdfResumeRiskViewerScreenState extends ConsumerState<PdfResumeRiskViewerScreen> {
  String _selectedSeverityFilter = 'All';
  Map<String, dynamic>? _activeHighlight;

  @override
  Widget build(BuildContext context) {
    final riskMapAsync = ref.watch(pdfRiskMapProvider(widget.resumeId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 22),
            SizedBox(width: 8),
            Text('PDF Risk Highlights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: SafeArea(
        child: riskMapAsync.when(
          data: (data) {
            final highlights = List<Map<String, dynamic>>.from(data['risk_highlights'] ?? []);
            final filteredHighlights = _selectedSeverityFilter == 'All'
                ? highlights
                : highlights.where((h) => h['severity'] == _selectedSeverityFilter).toList();

            return Column(
              children: [
                // Top Control Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterPill('All', highlights.length),
                        const SizedBox(width: 6),
                        _filterPill('high_risk', highlights.where((h) => h['severity'] == 'high_risk').length, label: 'High Risk', color: AppColors.danger),
                        const SizedBox(width: 6),
                        _filterPill('medium_warning', highlights.where((h) => h['severity'] == 'medium_warning').length, label: 'Warnings', color: AppColors.warning),
                        const SizedBox(width: 6),
                        _filterPill('verified_strength', highlights.where((h) => h['severity'] == 'verified_strength').length, label: 'Strengths', color: AppColors.success),
                      ],
                    ),
                  ),
                ),

                // Simulated PDF Paper View Container
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // PDF Sheet Representation
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 520),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Resume Header
                              Text(data['candidate_name'] ?? 'Candidate Resume', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('${data['job_title'] ?? 'Software Engineer'} • ${data['location'] ?? 'Unknown Location'}', style: const TextStyle(fontSize: 11, color: AppColors.textDarkMuted)),
                              const Divider(height: 20),

                              Text('PROFESSIONAL EXPERIENCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 12),

                              // Render Highlighted Claims List
                              ...filteredHighlights.map((hl) {
                                final severity = hl['severity'] ?? 'medium_warning';
                                final color = _getSeverityColor(severity);
                                final isSelected = _activeHighlight?['id'] == hl['id'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _activeHighlight = hl;
                                    });
                                    _showRiskDetailsModal(context, hl);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(isSelected ? 0.22 : 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? color : color.withOpacity(0.4),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(_getSeverityIcon(severity), size: 16, color: color),
                                            const SizedBox(width: 6),
                                            Text(
                                              hl['flag_category'] ?? 'Risk Flag',
                                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            const Spacer(),
                                            const Text('Tap to inspect ->', style: TextStyle(fontSize: 10, color: AppColors.textDarkMuted)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '• "${hl['claim_text']}"',
                                          style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading risk highlights: $e')),
        ),
      ),
    );
  }

  Widget _filterPill(String severity, int count, {String label = 'All', Color color = AppColors.electricIndigo}) {
    final isSelected = _selectedSeverityFilter == severity;
    return ChoiceChip(
      selected: isSelected,
      label: Text('$label ($count)', style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedSeverityFilter = severity;
          });
        }
      },
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high_risk':
        return AppColors.danger;
      case 'medium_warning':
        return AppColors.warning;
      case 'verified_strength':
        return AppColors.success;
      default:
        return AppColors.electricIndigo;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'high_risk':
        return Icons.error;
      case 'medium_warning':
        return Icons.warning_amber;
      case 'verified_strength':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  void _showRiskDetailsModal(BuildContext context, Map<String, dynamic> hl) {
    final severity = hl['severity'] ?? 'medium_warning';
    final color = _getSeverityColor(severity);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category & Severity Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(_getSeverityIcon(severity), size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(hl['flag_category'] ?? 'Flagged Item', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Flagged Text
                const Text('FLAGGED RESUME BULLET:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted)),
                const SizedBox(height: 4),
                Text(
                  '"${hl['claim_text']}"',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                ),
                const SizedBox(height: 16),

                // Why Flagged
                const Text('WHY IT WAS FLAGGED BY ATS / RECRUITER:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                const SizedBox(height: 4),
                Text(hl['why_flagged'] ?? '', style: const TextStyle(fontSize: 13, height: 1.35)),
                const SizedBox(height: 16),

                // Interviewer Probe Question
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎯 EXPECTED INTERVIEWER PROBE QUESTION:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text(hl['interviewer_probe_question'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Suggested High Impact Rewrite
                const Text('✨ HIGH-IMPACT SUGGESTED REWRITE:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withOpacity(0.2)),
                  ),
                  child: SelectableText(
                    hl['suggested_rewrite'] ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35),
                  ),
                ),
                const SizedBox(height: 20),

                AppButton(
                  label: 'Close Inspector',
                  width: double.infinity,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class ReportAIModal extends StatefulWidget {
  final String contentId;
  final String contentType;

  const ReportAIModal({super.key, required this.contentId, required this.contentType});

  static Future<void> show(BuildContext context, {required String contentId, required String contentType}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportAIModal(contentId: contentId, contentType: contentType),
    );
  }

  @override
  State<ReportAIModal> createState() => _ReportAIModalState();
}

class _ReportAIModalState extends State<ReportAIModal> {
  String selectedReason = 'Incorrect / Inaccurate';
  final TextEditingController detailsCtrl = TextEditingController();
  bool isSubmitted = false;

  final List<String> reasons = [
    'Incorrect / Inaccurate',
    'Bad Translation (Tamil/Hindi)',
    'Duplicate Question',
    'Unsupported / Fabricated Claim',
    'Offensive or Inappropriate',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDarkElevated : Colors.white;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: isSubmitted
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
                const SizedBox(height: 12),
                const Text('Report Submitted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Thank you. We review all feedback to maintain rigorous quality.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Report AI Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help us improve IntervueX. Select why this content should be reviewed:',
                  style: TextStyle(fontSize: 13, color: AppColors.textDarkSecondary),
                ),
                const SizedBox(height: 16),
                ...reasons.map((r) => RadioListTile<String>(
                      title: Text(r, style: const TextStyle(fontSize: 14)),
                      value: r,
                      groupValue: selectedReason,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => selectedReason = val!),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Additional details (optional)...',
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Submit Report',
                  width: double.infinity,
                  onPressed: () {
                    setState(() => isSubmitted = true);
                  },
                ),
              ],
            ),
    );
  }
}

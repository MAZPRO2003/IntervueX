import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/data/services/api_service.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/providers/theme_provider.dart';
import 'package:intervuex_app/data/models/pack_model.dart';
import 'package:intervuex_app/presentation/views/resumes/pdf_resume_risk_viewer_screen.dart';


class AnalyzeResumeScreen extends ConsumerStatefulWidget {
  const AnalyzeResumeScreen({super.key});

  @override
  ConsumerState<AnalyzeResumeScreen> createState() => _AnalyzeResumeScreenState();
}

class _AnalyzeResumeScreenState extends ConsumerState<AnalyzeResumeScreen> {
  final TextEditingController textCtrl = TextEditingController();
  PlatformFile? pickedFile;
  bool isLoading = false;
  String? selectedJobId;
  String _selectedQFilter = 'All (50)';
  Map<String, dynamic>? analysisResult;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> _analyze() async {
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> res;
      Uint8List? fileBytes = pickedFile?.bytes;
      if (fileBytes == null && pickedFile?.path != null) {
        final f = io.File(pickedFile!.path!);
        if (await f.exists()) {
          fileBytes = await f.readAsBytes();
        }
      }

      if (fileBytes != null && fileBytes.isNotEmpty) {
        res = await ApiService.instance.analyzeResume(
          fileBytes: fileBytes,
          fileName: pickedFile!.name,
          jobId: selectedJobId,
        );
      } else {
        final txt = textCtrl.text.trim();
        if (txt.isEmpty) {
          throw Exception("Please upload a valid resume file or paste your resume text.");
        }
        res = await ApiService.instance.analyzeResume(
          rawText: txt,
          jobId: selectedJobId,
        );
      }

      setState(() {
        analysisResult = res;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      String errMsg = e.toString();
      // Extract clean server error detail if available
      if (errMsg.contains("DioException") || errMsg.contains("400")) {
        errMsg = "Unreadable File: Please upload a readable text PDF, DOCX, or paste resume text.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variant = ref.watch(themeVariantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume & Risk Analyzer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Parsing resume layout & extracting evidence...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: analysisResult == null ? _buildInput(isDark, variant) : _buildResult(isDark, variant),
            ),
    );
  }

  Widget _buildInput(bool isDark, AppThemeVariant variant) {
    final primary = variant.primary;
    final packsAsync = ref.watch(packsListProvider);
    final List<InterviewPackModel> packs = packsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Candidate Resume', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'IntervueX parses your actual resume to perform a 9-factor quality review, ATS score audit, and interview risk evidence detection.',
          style: TextStyle(fontSize: 13, color: AppColors.textDarkSecondary),
        ),
        const SizedBox(height: 16),

        // Optional Target Job Selection
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, size: 16, color: primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('TARGET JOB ALIGNMENT (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: selectedJobId,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                hint: const Text('None (Standalone Resume Quality Review)', style: TextStyle(fontSize: 13)),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None (Standalone Resume Quality Review)', style: TextStyle(fontSize: 13)),
                  ),
                  ...packs.map((p) => DropdownMenuItem<String?>(
                        value: p.id,
                        child: Text('${p.company} - ${p.hiringProgram}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedJobId = val;
                  });
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a target role/company to calculate exact Job Match % and Missing Skills list.',
                style: TextStyle(fontSize: 11, color: AppColors.textDarkMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(color: primary.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: primary.withOpacity(0.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.file_present_outlined, size: 40, color: primary),
                const SizedBox(height: 8),
                Text(
                  pickedFile != null ? pickedFile!.name : 'Click to Upload Resume (PDF / DOCX)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary),
                ),
                const SizedBox(height: 4),
                const Text('Supports PDF, Word DOCX, and Text', style: TextStyle(fontSize: 12, color: AppColors.textDarkMuted)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR PASTE TEXT', style: TextStyle(fontSize: 11, color: AppColors.textDarkMuted))),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),

        TextField(
          controller: textCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Paste Resume Text',
            hintText: 'Paste candidate summary, education, skills, projects, and work experience...',
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 20),
        AppButton(
          label: 'Analyze Resume & Detect Risks',
          icon: Icons.security,
          width: double.infinity,
          onPressed: _analyze,
        ),
      ],
    );
  }

  Widget _buildResult(bool isDark, AppThemeVariant variant) {
    final primary = variant.primary;
    final secondary = variant.light;
    final res = analysisResult!;
    final candidateName = res['candidate_name'] ?? 'Candidate Profile';
    final contactInfo = (res['contact_info'] as Map?)?.cast<String, dynamic>() ?? {};
    final isJobTargeted = res['is_job_targeted'] ?? false;
    final targetJobTitle = res['target_job_title'] ?? 'Target Job';
    final matchPct = res['overall_match_percentage'] ?? 0;
    
    // Scores & Quality Factors
    final qualityScore = res['overall_resume_quality'] ?? res['resume_strength_score'] ?? 80;
    final qualityBreakdown = (res['quality_breakdown'] as Map?)?.cast<String, dynamic>() ?? {};
    final atsScore = res['ats_score'] ?? qualityScore;
    final atsStrengths = List<String>.from(res['ats_strengths'] ?? []);
    final atsIssues = List<String>.from(res['ats_issues'] ?? []);
    final atsKeywordsFound = List<String>.from(res['ats_keywords_found'] ?? []);
    final atsKeywordsMissing = List<String>.from(res['ats_keywords_missing'] ?? []);

    // Feedback lists
    final strengths = List<String>.from(res['strengths'] ?? []);
    final weaknesses = List<String>.from(res['weaknesses'] ?? []);
    final recommendations = List<String>.from(res['recommendations'] ?? res['resume_improvements'] ?? []);

    final matchingSkills = List<String>.from(res['matching_skills'] ?? []);
    final missingSkills = List<String>.from(res['missing_skills'] ?? []);
    final categorizedSkills = res['categorized_skills'] as Map? ?? {};
    final projects = res['projects'] as List? ?? [];
    final risks = res['risks'] as List? ?? [];
    final whatToPrepare = res['what_to_prepare'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Candidate Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidateName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    '${contactInfo['email'] ?? 'No Email'} • ${contactInfo['phone'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => analysisResult = null),
              icon: const Icon(Icons.upload_file, size: 14),
              label: const Text('Re-Analyze', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. OVERALL RESUME QUALITY SCORE CARD (Transparent Multi-Factor Breakdown)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: variant.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: (qualityScore is num ? qualityScore.toDouble() : 75.0) / 100.0,
                          strokeWidth: 6,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$qualityScore',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OVERALL RESUME QUALITY SCORE',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (qualityScore is num && qualityScore >= 80)
                              ? 'Strong Competitive Resume'
                              : ((qualityScore is num && qualityScore >= 65) ? 'Good — Needs Quantifiable Polish' : 'Critical Formatting & Evidence Gaps'),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Multi-factor transparent audit derived from actual uploaded resume content.',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),
              const Text(
                'TRANSPARENT QUALITY FACTORS (10 METRICS)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),

              // 10-Factor Breakdown Grid
              _buildQualityFactorGrid(qualityBreakdown, isDark, variant),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. ATS COMPATIBILITY AUDIT CARD
        AppCard(
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.success.withOpacity(0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assessment_outlined, color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text('ATS COMPATIBILITY SCORE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('$atsScore/100', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 12),
              
              if (atsStrengths.isNotEmpty) ...[
                const Text('ATS Readability Strengths:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                const SizedBox(height: 4),
                ...atsStrengths.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 13, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
              ],

              if (atsIssues.isNotEmpty) ...[
                const Text('ATS Formatting & Parsing Warnings:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                const SizedBox(height: 4),
                ...atsIssues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(child: Text(issue, style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
              ],

              if (atsKeywordsFound.isNotEmpty) ...[
                const Text('Detected Technical Keywords:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: atsKeywordsFound.map((k) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(k, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],

              if (atsKeywordsMissing.isNotEmpty) ...[
                const Text('Missing Critical Role Keywords:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: atsKeywordsMissing.map((k) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(k, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. STRENGTHS, WEAKNESSES & RECOMMENDATIONS CARD
        if (strengths.isNotEmpty || weaknesses.isNotEmpty || recommendations.isNotEmpty) ...[
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (strengths.isNotEmpty) ...[
                  const Text('VERIFIED RESUME STRENGTHS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  ...strengths.map((st) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text(st, style: const TextStyle(fontSize: 12, height: 1.3))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                ],

                if (weaknesses.isNotEmpty) ...[
                  const Text('AREAS FOR IMPROVEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  ...weaknesses.map((wk) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(child: Text(wk, style: const TextStyle(fontSize: 12, height: 1.3))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                ],

                if (recommendations.isNotEmpty) ...[
                  const Text('ACTIONABLE RECOMMENDATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.info, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  ...recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rec, style: const TextStyle(fontSize: 12, height: 1.3))),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Target Job Alignment Banner (if target job selected)
        if (isJobTargeted) ...[
          AppCard(
            padding: const EdgeInsets.all(16),
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
                          const Text('TARGET JOB ALIGNMENT SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(targetJobTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: secondary)),
                        ],
                      ),
                    ),
                    Text('$matchPct%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: matchPct >= 75 ? AppColors.success : AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 12),
                if (matchingSkills.isNotEmpty) ...[
                  const Text('Matching Job Skills:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: matchingSkills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                if (missingSkills.isNotEmpty) ...[
                  const Text('Missing Required Skills:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: missingSkills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Categorized Technical Skills Inventory
        const Text('CATEGORIZED TECHNICAL SKILLS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categorizedSkills.entries.map((entry) {
              final cat = entry.key;
              final items = List<String>.from(entry.value);
              if (items.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondary)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: items.map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // 4. INTERVIEW RISK & EXAGGERATION DETECTOR (Ground Truth Evidence)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('INTERVIEW RISK & EXAGGERATION DETECTOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger, letterSpacing: 0.5)),
            TextButton.icon(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
              icon: const Icon(Icons.picture_as_pdf, size: 14, color: AppColors.danger),
              label: const Text('Visual PDF Map ->', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PdfResumeRiskViewerScreen(resumeId: res['id'] as String?)));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (risks.isEmpty)
          AppCard(
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('No unbacked claims or exaggeration risks detected in this resume!')),
              ],
            ),
          )
        else
          ...risks.map((risk) {
            final title = risk['title'] ?? risk['claimed_item'] ?? 'Potential Interview Risk';
            final level = risk['risk_level'] ?? 'Medium';
            final evidenceSource = risk['evidence_source'] ?? 'Resume Content';
            final evidenceText = risk['evidence_text'] ?? risk['claimed_item'] ?? '';
            final whyQuestioned = risk['why_questioned'] ?? risk['reason'] ?? '';
            final prepAdvice = risk['preparation_advice'] ?? '';
            final topics = risk['possible_questions'] as List? ?? risk['expected_grilling_topics'] as List? ?? [];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                borderColor: AppColors.danger.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                          child: Text('$level Risk', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Traceable Evidence Provenance
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.find_in_page_outlined, size: 12, color: secondary),
                              const SizedBox(width: 4),
                              Text('Source: $evidenceSource', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondary)),
                            ],
                          ),
                          if (evidenceText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '"$evidenceText"',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textDarkSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text('Why this may be questioned:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted)),
                    const SizedBox(height: 2),
                    Text(whyQuestioned, style: const TextStyle(fontSize: 12, height: 1.35)),
                    
                    if (topics.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Possible Interviewer Questions:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted)),
                      const SizedBox(height: 4),
                      ...topics.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: secondary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(t.toString(), style: const TextStyle(fontSize: 11, height: 1.3))),
                          ],
                        ),
                      )),
                    ],

                    if (prepAdvice.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('Preparation: $prepAdvice', style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 16),

        // Deep Project Claim Questions
        Text('PROJECT CLAIM FOLLOW-UP QUESTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondary, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        ...projects.map((proj) {
          final qList = proj['potential_questions'] as List? ?? [];
          final techList = List<String>.from(proj['technologies'] ?? []);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(proj['project_title'] ?? 'Project', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Claim: "${proj['claim_text']}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textDarkSecondary)),
                  if (techList.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: techList.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text('Technical Grilling Questions:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondary)),
                  const SizedBox(height: 6),
                  ...qList.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: secondary, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(q.toString(), style: const TextStyle(fontSize: 12, height: 1.3))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // What to prepare summary
        if (whatToPrepare.isNotEmpty) ...[
          const Text('WHAT YOU SHOULD PREPARE NEXT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: whatToPrepare.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.toString(), style: const TextStyle(fontSize: 12, height: 1.35))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 50 Resume Interview Questions Breakdown
        _build50ResumeQuestionsSection(res, isDark, variant),
      ],
    );
  }

  Widget _buildQualityFactorGrid(Map<String, dynamic> breakdown, bool isDark, AppThemeVariant variant) {
    final factors = [
      {'key': 'ats_compatibility', 'label': 'ATS Compatibility', 'icon': Icons.smart_toy_outlined},
      {'key': 'content_quality', 'label': 'Content Quality', 'icon': Icons.article_outlined},
      {'key': 'resume_structure', 'label': 'Resume Structure', 'icon': Icons.account_tree_outlined},
      {'key': 'skills_score', 'label': 'Skills Support', 'icon': Icons.psychology_outlined},
      {'key': 'experience_score', 'label': 'Experience Depth', 'icon': Icons.work_history_outlined},
      {'key': 'projects_score', 'label': 'Project Evidence', 'icon': Icons.folder_special_outlined},
      {'key': 'job_relevance', 'label': 'Job Alignment', 'icon': Icons.tune_outlined},
      {'key': 'readability', 'label': 'Readability', 'icon': Icons.visibility_outlined},
      {'key': 'formatting', 'label': 'Formatting', 'icon': Icons.space_dashboard_outlined},
      {'key': 'quantified_metrics', 'label': 'Impact Metrics', 'icon': Icons.assessment_outlined},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: factors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, idx) {
        final f = factors[idx];
        final val = (breakdown[f['key']] ?? 75) as int;
        final label = f['label'] as String;
        final icon = f['icon'] as IconData;

        Color valColor = Colors.white;
        if (val >= 80) {
          valColor = const Color(0xFF6EE7B7);
        } else if (val < 65) {
          valColor = const Color(0xFFFDE047);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 13, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$val%',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: valColor),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: val / 100.0,
                  backgroundColor: Colors.white24,
                  color: valColor,
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build50ResumeQuestionsSection(Map<String, dynamic> res, bool isDark, AppThemeVariant variant) {
    final primary = variant.primary;
    final secondary = variant.light;
    final rawQList = res['resume_questions'] as List? ?? [];
    if (rawQList.isEmpty) return const SizedBox.shrink();

    final categories = ['All (50)', 'Project Architecture', 'Async & Concurrency', 'Database & SQL', 'Security & Auth', 'DevOps & Cloud'];

    List<dynamic> filteredList = rawQList;
    if (_selectedQFilter != 'All (50)') {
      filteredList = rawQList.where((q) {
        final cat = q['category'].toString();
        return cat.toLowerCase().contains(_selectedQFilter.split(' ')[0].toLowerCase());
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('50 RESUME INTERVIEW QUESTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text('Questions based on your resume claims (${rawQList.length} Total)', style: const TextStyle(fontSize: 11, color: AppColors.textDarkMuted), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${rawQList.length} Qs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedQFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : null)),
                  selected: isSelected,
                  selectedColor: primary,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedQFilter = cat);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        ...filteredList.map((q) {
          final qText = q['question'] ?? 'Question';
          final qCat = q['category'] ?? 'General';
          final qClaim = q['targeted_claim'] ?? '';
          final qDiff = q['difficulty'] ?? 'Medium';
          final qPriority = q['priority'] ?? 'High Priority';
          final qAns = q['expected_answer_framework'] ?? '';
          final qEval = q['what_evaluators_look_for'] ?? '';

          Color badgeColor = primary;
          if (qDiff == 'High') badgeColor = AppColors.danger;
          if (qDiff == 'Low') badgeColor = AppColors.success;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8, bottom: 4),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(qDiff, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        qText.toString(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(qCat.toString(), style: TextStyle(fontSize: 10, color: secondary, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(qPriority.toString(), style: const TextStyle(fontSize: 10, color: AppColors.textDarkMuted), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                children: [
                  const Divider(),
                  if (qClaim.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Targeted Resume Claim: "$qClaim"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textDarkSecondary)),
                    const SizedBox(height: 8),
                  ],
                  const Text('Model Answer Framework:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                  const SizedBox(height: 4),
                  Text(qAns.toString(), style: const TextStyle(fontSize: 12, height: 1.35)),
                  const SizedBox(height: 8),
                  Text('What Evaluators Look For:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondary)),
                  const SizedBox(height: 4),
                  Text(qEval.toString(), style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary, height: 1.3)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

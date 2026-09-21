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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  Text('Analyzing resume claims & identifying risk points...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: analysisResult == null ? _buildInput(isDark) : _buildResult(isDark),
            ),
    );
  }

  Widget _buildInput(bool isDark) {
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
          'IntervueX parses your resume to detect project architecture claims, technical risk exaggerations, and target job alignment.',
          style: TextStyle(fontSize: 13, color: AppColors.textDarkSecondary),
        ),
        const SizedBox(height: 16),

        // Optional Target Job Selection
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.track_changes, size: 16, color: AppColors.electricIndigo),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('TARGET JOB ALIGNMENT (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.electricIndigo), overflow: TextOverflow.ellipsis),
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
              border: Border.all(color: AppColors.electricIndigo.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.electricIndigo.withOpacity(0.04),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.file_present_outlined, size: 40, color: AppColors.indigoLight),
                const SizedBox(height: 8),
                Text(
                  pickedFile != null ? pickedFile!.name : 'Click to Upload Resume (PDF / DOCX)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.auto_fix_high, size: 14),
              label: const Text('Load Sample Resume', style: TextStyle(fontSize: 12)),
              onPressed: () {
                textCtrl.text = "Alex Mercer\nEmail: alex.mercer@dev.io | Phone: +91 9876543210\nEducation: B.Tech Computer Science (2025), CGPA: 8.8\nSkills: Python, FastAPI, PostgreSQL, SQL, Docker, Redis, AWS, Git, Data Structures.\nProjects:\n1. Scalable Microservices Inventory Engine: Built asynchronous inventory API with FastAPI and PostgreSQL handling 10,000 requests/min.\n2. Real-time Pub/Sub Messaging Service: Implemented WebSockets with Redis pub/sub for instant notifications.";
              },
            ),
          ],
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

  Widget _buildResult(bool isDark) {
    final res = analysisResult!;
    final candidateName = res['candidate_name'] ?? 'Candidate Profile';
    final contactInfo = res['contact_info'] as Map? ?? {};
    final isJobTargeted = res['is_job_targeted'] ?? false;
    final targetJobTitle = res['target_job_title'] ?? 'Target Job';
    final matchPct = res['overall_match_percentage'] ?? 0;
    final strengthScore = res['resume_strength_score'] ?? 80;
    final matchingSkills = List<String>.from(res['matching_skills'] ?? []);
    final missingSkills = List<String>.from(res['missing_skills'] ?? []);
    final categorizedSkills = res['categorized_skills'] as Map? ?? {};
    final projects = res['projects'] as List? ?? [];
    final risks = res['risks'] as List? ?? [];
    final improvements = List<String>.from(res['resume_improvements'] ?? []);
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

        // Score Banner: Job Match vs Standalone Quality
        AppCard(
          padding: const EdgeInsets.all(16),
          child: isJobTargeted
              ? Column(
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
                              Text(targetJobTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
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
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RESUME TECHNICAL STRENGTH SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5)),
                              SizedBox(height: 2),
                              Text('Standalone Quality Review', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                            ],
                          ),
                        ),
                        Text('$strengthScore/100', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.electricIndigo)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.electricIndigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.indigoLight),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Standalone review evaluating formatting & claim depth. Select a Target Job on the input screen to view exact Job Match %.',
                              style: TextStyle(fontSize: 11, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 16),

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
                    Text(cat.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
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

        // Interview Risks & Exaggeration Detector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('INTERVIEW RISK & EXAGGERATION DETECTOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger, letterSpacing: 0.5)),
            TextButton.icon(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
              icon: const Icon(Icons.picture_as_pdf, size: 14, color: AppColors.danger),
              label: const Text('Visual PDF Map ->', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfResumeRiskViewerScreen()));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...risks.map((risk) {
          final level = risk['risk_level'] ?? 'Medium';
          final topics = risk['expected_grilling_topics'] as List? ?? [];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
                                risk['claimed_item'] ?? 'Claimed Item',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger),
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
                  const SizedBox(height: 6),
                  Text(risk['reason'] ?? '', style: const TextStyle(fontSize: 12, height: 1.35)),
                  const SizedBox(height: 8),
                  const Text('Expected Grilling Topics:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: topics.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(t.toString(), style: const TextStyle(fontSize: 11)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Deep Project Claim Questions
        const Text('PROJECT CLAIM FOLLOW-UP QUESTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5)),
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
                        decoration: BoxDecoration(color: AppColors.electricIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.electricIndigo)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text('4 Technical Grilling Questions:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
                  const SizedBox(height: 6),
                  ...qList.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.indigoLight, fontWeight: FontWeight.bold)),
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

        // Actionable Resume Improvements
        if (improvements.isNotEmpty) ...[
          const Text('ACTIONABLE RESUME IMPROVEMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          AppCard(
            borderColor: AppColors.warning.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: improvements.map((imp) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.build_circle_outlined, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(imp, style: const TextStyle(fontSize: 12, height: 1.35))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // What to prepare summary
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

        // 50 Resume Interview Questions Breakdown
        _build50ResumeQuestionsSection(res, isDark),
      ],
    );
  }

  Widget _build50ResumeQuestionsSection(Map<String, dynamic> res, bool isDark) {
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
                  const Text('50 RESUME INTERVIEW QUESTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.electricIndigo, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text('Questions based on your resume claims (${rawQList.length} Total)', style: const TextStyle(fontSize: 11, color: AppColors.textDarkMuted), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.electricIndigo.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${rawQList.length} Qs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.electricIndigo)),
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
                  selectedColor: AppColors.electricIndigo,
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

          Color badgeColor = AppColors.electricIndigo;
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
                        child: Text(qCat.toString(), style: const TextStyle(fontSize: 10, color: AppColors.indigoLight, fontWeight: FontWeight.w600)),
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
                  const Text('What Evaluators Look For:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight)),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/data/services/api_service.dart';
import 'package:intervuex_app/data/models/pack_model.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/views/packs/pack_dashboard_screen.dart';

class AnalyzeJobScreen extends ConsumerStatefulWidget {
  const AnalyzeJobScreen({super.key});

  @override
  ConsumerState<AnalyzeJobScreen> createState() => _AnalyzeJobScreenState();
}

class _AnalyzeJobScreenState extends ConsumerState<AnalyzeJobScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController urlCtrl = TextEditingController();
  final TextEditingController textCtrl = TextEditingController();

  PlatformFile? pickedFile;
  bool isLoading = false;
  String currentLoadingStep = "";
  String? urlError;

  final List<String> progressSteps = [
    "Reading the job description...",
    "Analyzing role & technical requirements...",
    "Identifying the hiring route & track...",
    "Researching verified interview experiences...",
    "Analyzing reported interview rounds...",
    "Ranking relevant questions with evidence...",
    "Building your IntervueX interview pack..."
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    urlCtrl.dispose();
    textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> _startAnalysis({String? overrideText}) async {
    setState(() {
      isLoading = true;
      urlError = null;
      currentLoadingStep = progressSteps[0];
    });

    Timer? stepTimer;
    int stepIdx = 0;
    stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!isLoading) {
        timer.cancel();
        return;
      }
      stepIdx = (stepIdx + 1) % progressSteps.length;
      setState(() {
        currentLoadingStep = progressSteps[stepIdx];
      });
    });

    try {
      Map<String, dynamic> jobRes;

      if (_tabController.index == 0 && overrideText == null) {
        final url = urlCtrl.text.trim();
        if (url.isEmpty) {
          throw Exception("Please enter a valid job URL.");
        }
        jobRes = await ApiService.instance.analyzeJob(url: url);
      } else if (_tabController.index == 1 || overrideText != null) {
        final text = overrideText ?? textCtrl.text.trim();
        if (text.isEmpty) {
          throw Exception("Please paste the job description text.");
        }
        jobRes = await ApiService.instance.analyzeJob(rawText: text);
      } else {
        if (pickedFile == null || pickedFile?.bytes == null) {
          throw Exception("Please select a PDF file.");
        }
        jobRes = await ApiService.instance.analyzeJob(
          fileBytes: pickedFile!.bytes,
          fileName: pickedFile!.name,
        );
      }

      final jobId = jobRes['id'];

      final packResult = await ApiService.instance.createInterviewPack(
        jobId: jobId,
        interviewDate: "2026-09-26",
        initialCount: 50,
      );

      final packModel = InterviewPackModel.fromJson(packResult['pack']);
      ref.read(packsListProvider.notifier).addOrUpdatePack(packModel);
      ref.read(activePackIdProvider.notifier).state = packModel.id;

      stepTimer.cancel();
      if (!mounted) return;
      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PackDashboardScreen()),
      );
    } catch (e) {
      stepTimer.cancel();
      if (!mounted) return;
      setState(() {
        isLoading = false;
        if (_tabController.index == 0) {
          urlError = "Unable to automatically read this job page.";
        }
      });
      if (_tabController.index != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze a Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: isLoading ? _buildLoadingView() : _buildInputView(isDark),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.electricIndigo.withOpacity(0.4), blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Analyzing Opportunity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                currentLoadingStep,
                key: ValueKey(currentLoadingStep),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.indigoLight, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'IntervueX is cross-referencing company hiring programs, candidate logs, and building your custom curriculum.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textDarkMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Provide Job Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'We will extract requirements, identify the hiring program (e.g. TCS Ninja vs Digital), and research reported rounds.',
            style: TextStyle(fontSize: 13, color: AppColors.textDarkSecondary),
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.electricIndigo,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.link, size: 18), text: 'Job URL'),
                Tab(icon: Icon(Icons.description_outlined, size: 18), text: 'Paste Text'),
                Tab(icon: Icon(Icons.upload_file, size: 18), text: 'Upload PDF'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Builder(
            builder: (context) {
              if (_tabController.index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Job Posting URL',
                        hintText: 'e.g. https://careers.tcs.com/jobs/system-engineer',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Supports LinkedIn, official company careers pages, and job boards without unauthorized scraping.',
                      style: TextStyle(fontSize: 12, color: AppColors.textDarkMuted),
                    ),
                    if (urlError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(urlError!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The job site requires authentication or blocked automated extraction. Choose an alternative to continue instantly:',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.paste, size: 14),
                                  label: const Text('Paste Job Description', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _tabController.animateTo(1),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.upload_file, size: 14),
                                  label: const Text('Upload PDF', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _tabController.animateTo(2),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh, size: 14),
                                  label: const Text('Try Again', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _startAnalysis(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              } else if (_tabController.index == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: textCtrl,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Paste Job Description',
                        hintText: 'Paste complete job description text, role expectations, and required skills here...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.auto_fix_high, size: 14),
                          label: const Text('Load Sample TCS NQT Ninja JD', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            textCtrl.text = "Tata Consultancy Services (TCS) NQT Hiring 2026 for Ninja Track.\nRole: Systems Engineer.\nRequirements: B.E./B.Tech/MCA freshers. Strong knowledge of Python or Java, Object Oriented Programming, SQL, Relational Database Management, and Data Structures. Responsibilities include building scalable enterprise microservices, writing clean unit tests, and debugging database bottlenecks.";
                          },
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    InkWell(
                      onTap: _pickPdf,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.electricIndigo.withOpacity(0.5), width: 1.5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.electricIndigo.withOpacity(0.04),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.indigoLight),
                            const SizedBox(height: 12),
                            Text(
                              pickedFile != null ? pickedFile!.name : 'Click to Upload Job Description PDF',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pickedFile != null ? '${(pickedFile!.size / 1024).toStringAsFixed(1)} KB' : 'Max size: 15MB',
                              style: const TextStyle(fontSize: 12, color: AppColors.textDarkMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 20),
          AppButton(
            label: 'Analyze Job & Build Pack',
            icon: Icons.bolt,
            width: double.infinity,
            onPressed: () => _startAnalysis(),
          ),
        ],
      ),
    );
  }
}

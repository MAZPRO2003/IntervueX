import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/pack_model.dart';
import '../../../data/services/api_service.dart';
import '../../providers/pack_provider.dart';
import '../packs/pack_dashboard_screen.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  final CompanyModel company;

  const CompanyProfileScreen({super.key, required this.company});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  bool isCreating = false;
  String? creatingTrackId;

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.electricIndigo;
    }
  }

  Future<void> _selectTrack(HiringProgramModel track) async {
    setState(() {
      isCreating = true;
      creatingTrackId = track.id;
    });

    try {
      final result = await ApiService.instance.selectCompanyTrack(
        companyId: widget.company.id,
        trackId: track.id,
      );

      final pack = InterviewPackModel.fromJson(result['pack']);
      ref.read(packsListProvider.notifier).addOrUpdatePack(pack);
      ref.read(activePackIdProvider.notifier).state = pack.id;

      if (!mounted) return;
      
      setState(() {
        isCreating = false;
        creatingTrackId = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PackDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isCreating = false;
        creatingTrackId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyColor = _parseColor(widget.company.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: companyColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: companyColor.withOpacity(0.35)),
                    ),
                    child: Center(
                      child: Text(
                        widget.company.shortName.length > 4 ? widget.company.shortName.substring(0, 3) : widget.company.shortName,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: companyColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.company.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.company.category,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'HIRING PROGRAMS & TRACKS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            
            // List of Programs
            if (widget.company.hiringPrograms.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  gradient: isDark ? AppColors.darkCardGradient : null,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Software Engineer',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Standard Engineering Track',
                                  style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Standard',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verified custom hiring tracks for ${widget.company.name} are being researched. You can immediately begin preparation with this foundational Software Engineer track.',
                        style: const TextStyle(fontSize: 14, height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TYPICAL INTERVIEW ROUNDS (3 ROUNDS)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      ...['Online Assessment (DSA & Cognitive Aptitude)', 'Core Technical Interview (Data Structures & System Concepts)', 'Managerial & Behavioral Fit Round'].asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: companyColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: companyColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      AppButton(
                        label: isCreating ? 'Generating Pack...' : 'Start Preparation Pack',
                        icon: Icons.rocket_launch,
                        isLoading: isCreating,
                        width: double.infinity,
                        onPressed: isCreating
                            ? null
                            : () => _selectTrack(
                                  HiringProgramModel(
                                    id: '${widget.company.shortName.toLowerCase()}_general',
                                    name: 'General SDE Track',
                                    role: 'Software Engineer',
                                    packageLpa: 'Standard LPA',
                                    difficulty: 'Medium',
                                    roundsCount: 3,
                                    overview: 'Standard technical rounds covering DSA, system logic, and behavioral interviews.',
                                    typicalRounds: [
                                      'Online Assessment (DSA & Cognitive Aptitude)',
                                      'Core Technical Interview (Data Structures & System Concepts)',
                                      'Managerial & Behavioral Fit Round'
                                    ],
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...widget.company.hiringPrograms.map((track) {
              final isThisCreating = isCreating && creatingTrackId == track.id;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  gradient: isDark ? AppColors.darkCardGradient : null,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.role,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Compensation: ${track.packageLpa}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              track.difficulty,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        track.overview,
                        style: const TextStyle(fontSize: 14, height: 1.45),
                      ),
                      
                      const SizedBox(height: 16),
                      Text(
                        'TYPICAL INTERVIEW ROUNDS (${track.roundsCount} ROUNDS)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.indigoLight, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      
                      ...List.generate(track.typicalRounds.length, (rIdx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: companyColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${rIdx + 1}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: companyColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  track.typicalRounds[rIdx],
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 20),
                      
                      AppButton(
                        label: isThisCreating ? 'Generating Pack...' : 'Start ${track.name} Prep',
                        icon: Icons.rocket_launch,
                        isLoading: isThisCreating,
                        width: double.infinity,
                        onPressed: isCreating ? null : () => _selectTrack(track),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

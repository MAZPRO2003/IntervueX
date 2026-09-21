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

class CompanyTracksSheet extends ConsumerStatefulWidget {
  final CompanyModel company;

  const CompanyTracksSheet({super.key, required this.company});

  static void show(BuildContext context, CompanyModel company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompanyTracksSheet(company: company),
    );
  }

  @override
  ConsumerState<CompanyTracksSheet> createState() => _CompanyTracksSheetState();
}

class _CompanyTracksSheetState extends ConsumerState<CompanyTracksSheet> {
  int selectedTrackIdx = 0;
  bool isCreating = false;

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

  List<HiringProgramModel> get _effectivePrograms {
    if (widget.company.hiringPrograms.isNotEmpty) {
      return widget.company.hiringPrograms;
    }
    return [
      HiringProgramModel(
        id: '${widget.company.shortName.toLowerCase()}_general',
        name: 'General SDE Track',
        role: 'Software Engineer',
        packageLpa: 'Standard LPA',
        difficulty: 'Medium',
        roundsCount: 3,
        overview: 'Standard technical rounds covering DSA, system logic, and behavioral interviews.',
        typicalRounds: [
          'Online Assessment',
          'Technical Interview',
          'HR Interview'
        ],
      )
    ];
  }

  Future<void> _selectTrack() async {
    final programs = _effectivePrograms;
    final safeIdx = selectedTrackIdx < programs.length ? selectedTrackIdx : 0;
    final track = programs[safeIdx];
    setState(() => isCreating = true);

    try {
      final result = await ApiService.instance.selectCompanyTrack(
        companyId: widget.company.id,
        trackId: track.id,
      );

      final pack = InterviewPackModel.fromJson(result['pack']);
      ref.read(packsListProvider.notifier).addOrUpdatePack(pack);
      ref.read(activePackIdProvider.notifier).state = pack.id;

      if (!mounted) return;
      setState(() => isCreating = false);
      Navigator.pop(context); // close bottom sheet

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PackDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyColor = _parseColor(widget.company.colorHex);
    final programs = _effectivePrograms;
    final safeIdx = selectedTrackIdx < programs.length ? selectedTrackIdx : 0;
    final track = programs[safeIdx];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: companyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: companyColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      widget.company.shortName.length > 4 ? widget.company.shortName.substring(0, 3) : widget.company.shortName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: companyColor),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.company.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.company.category,
                        style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECT HIRING PROGRAM / TRACK',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDarkMuted, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),

                  // Track Selection Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(programs.length, (idx) {
                      final p = programs[idx];
                      final isSelected = safeIdx == idx;
                      return ChoiceChip(
                        label: Text(p.name, style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        )),
                        selected: isSelected,
                        selectedColor: companyColor,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        onSelected: (_) => setState(() => selectedTrackIdx = idx),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Track Detail Card
                  AppCard(
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
                                  const SizedBox(height: 2),
                                  Text(
                                    'Compensation: ${track.packageLpa}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
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
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Text(
                          track.overview,
                          style: const TextStyle(fontSize: 13, height: 1.45),
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
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(top: 2),
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
                                    style: const TextStyle(fontSize: 13, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: AppButton(
              label: isCreating ? 'Generating Pack...' : 'Prepare for ${track.name}',
              icon: Icons.rocket_launch,
              isLoading: isCreating,
              width: double.infinity,
              onPressed: isCreating ? null : _selectTrack,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_card.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/views/packs/pack_dashboard_screen.dart';
import 'package:intervuex_app/presentation/views/jobs/analyze_job_screen.dart';
import 'package:intervuex_app/presentation/views/companies/companies_directory_screen.dart';

class PacksListScreen extends ConsumerWidget {
  const PacksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(packsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Interview Packs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.business_outlined),
            tooltip: 'Browse Companies',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Analyze a Job',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyzeJobScreen())),
          ),
        ],
      ),
      body: packsAsync.when(
        data: (packs) {
          if (packs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, size: 64, color: AppColors.textDarkMuted),
                    const SizedBox(height: 16),
                    const Text('No Interview Packs Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Choose from top companies or analyze your own job posting.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textDarkSecondary)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.business_outlined, size: 18),
                          label: const Text('Browse Companies'),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesDirectoryScreen())),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyzeJobScreen())),
                          child: const Text('+ Analyze JD'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packs.length,
            itemBuilder: (context, idx) {
              final p = packs[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () {
                    ref.read(activePackIdProvider.notifier).state = p.id;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PackDashboardScreen()));
                  },
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
                                Text(p.company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('${p.role} • ${p.hiringProgram}', style: const TextStyle(fontSize: 13, color: AppColors.indigoLight, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${p.readinessPercentage}% Ready',
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textDarkMuted),
                          const SizedBox(width: 4),
                          Text(p.location, style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                          const SizedBox(width: 16),
                          const Icon(Icons.quiz_outlined, size: 14, color: AppColors.textDarkMuted),
                          const SizedBox(width: 4),
                          Text('${p.totalQuestions} Questions', style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                          const Spacer(),
                          Text('${p.daysRemaining} days left', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
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
      ),
    );
  }
}

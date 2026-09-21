import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../providers/company_provider.dart';
import '../../../data/models/company_model.dart';
import '../../../data/services/api_service.dart';
import 'company_profile_screen.dart';

class CompaniesDirectoryScreen extends ConsumerStatefulWidget {
  const CompaniesDirectoryScreen({super.key});

  @override
  ConsumerState<CompaniesDirectoryScreen> createState() => _CompaniesDirectoryScreenState();
}

class _CompaniesDirectoryScreenState extends ConsumerState<CompaniesDirectoryScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  String selectedCategory = 'All';
  bool _isGenerating = false;

  final List<String> categories = [
    'All',
    'Product MNC',
    'IT Services & Consulting',
    'Product MNC / SaaS',
    'Consulting & Technology',
    'Fintech & Investment Banking',
    'Product / Consumer Tech',
    'Networking & Cloud',
    'Product MNC / E-Commerce'
  ];

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
  
  Future<void> _generateCompany() async {
    final query = searchCtrl.text.trim();
    if (query.isEmpty) return;
    
    setState(() => _isGenerating = true);
    try {
      await ApiService.instance.generateCompany(query);
      if (mounted) {
        ref.invalidate(companiesListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully generated profile for $query!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate company: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(companiesListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Hiring Companies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.travel_explore),
            tooltip: 'Discover Companies',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting discovery pipeline in background...')),
              );
              try {
                await ApiService.instance.startDiscovery(limit: 5);
              } catch (e) {
                // ignore
              }
            },
          ),
        ],
      ),
      body: companiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load companies: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(companiesListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allCompanies) {
          // Deduplicate companies by name, favoring entries with hiring programs
          final Map<String, CompanyModel> uniqueMap = {};
          for (final c in allCompanies) {
            final key = c.name.trim().toLowerCase();
            if (!uniqueMap.containsKey(key)) {
              uniqueMap[key] = c;
            } else {
              if (uniqueMap[key]!.hiringPrograms.isEmpty && c.hiringPrograms.isNotEmpty) {
                uniqueMap[key] = c;
              }
            }
          }
          final deduplicatedCompanies = uniqueMap.values.toList();

          final query = searchCtrl.text.trim().toLowerCase();
          final filtered = deduplicatedCompanies.where((c) {
            final matchesQuery = query.isEmpty ||
                c.name.toLowerCase().contains(query) ||
                c.shortName.toLowerCase().contains(query);
            final matchesCat = selectedCategory == 'All' || c.category.toLowerCase().contains(selectedCategory.toLowerCase());
            return matchesQuery && matchesCat;
          }).toList();

          return Column(
            children: [
              // Search & Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search companies (e.g. Amazon)...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        searchCtrl.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (searchCtrl.text.isNotEmpty && filtered.isEmpty) ...[
                          const SizedBox(width: 8),
                          _isGenerating
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _generateCompany,
                                  icon: const Icon(Icons.auto_awesome, size: 16),
                                  label: const Text('Generate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.electricIndigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat, style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              )),
                              selected: isSelected,
                              selectedColor: AppColors.electricIndigo,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              onSelected: (_) => setState(() => selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Companies List
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No companies match your search.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final comp = filtered[idx];
                          final cColor = _parseColor(comp.colorHex);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CompanyProfileScreen(company: comp)),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: cColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: cColor.withOpacity(0.35)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        comp.shortName.length > 4 ? comp.shortName.substring(0, 3) : comp.shortName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: cColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comp.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          comp.category,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          children: comp.hiringPrograms.take(2).map((p) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                p.name,
                                                style: const TextStyle(fontSize: 10, color: AppColors.textDarkMuted),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textDarkMuted),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

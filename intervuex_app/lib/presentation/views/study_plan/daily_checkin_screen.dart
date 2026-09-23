import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/data/services/api_service.dart';
import 'package:intervuex_app/presentation/providers/pack_provider.dart';
import 'package:intervuex_app/presentation/providers/theme_provider.dart';

class DailyCheckinScreen extends ConsumerStatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  ConsumerState<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends ConsumerState<DailyCheckinScreen> {
  bool isLoading = true;
  Map<String, dynamic>? checkinData;
  int? selectedDayNumber;

  @override
  void initState() {
    super.initState();
    _fetchCheckin();
  }

  Future<void> _fetchCheckin({int? targetDay}) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      setState(() => isLoading = true);
      final data = await ApiService.instance.getDailyCheckin(packId, dayNumber: targetDay ?? selectedDayNumber);
      setState(() {
        checkinData = data;
        selectedDayNumber = data['current_day_number'] ?? 1;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleTask(int dayNum, String task, bool currentlyCompleted) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) return;

    try {
      final res = await ApiService.instance.toggleTask(packId, dayNum, task, !currentlyCompleted);
      ref.invalidate(activeStudyPlanProvider);
      ref.invalidate(activePackProvider);
      ref.invalidate(packsListProvider);
      await _fetchCheckin(targetDay: dayNum);

      if (mounted) {
        final newScore = res['readiness_percentage'] ?? 0;
        final actionText = !currentlyCompleted ? 'completed' : 'uncompleted';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task $actionText! Interview Readiness is now $newScore%'),
            backgroundColor: !currentlyCompleted ? AppColors.success : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _completeDayCheckin(int dayNum) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) return;

    try {
      final res = await ApiService.instance.completeDay(packId, dayNum);
      ref.invalidate(activeStudyPlanProvider);
      ref.invalidate(activePackProvider);
      ref.invalidate(packsListProvider);
      
      final newScore = res['readiness_percentage'] ?? 0;

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.stars, color: AppColors.warning, size: 28),
              SizedBox(width: 10),
              Text('Day Completed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Awesome job! You finished Day $dayNum check-in tasks.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Readiness Increased: $newScore%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _uncompleteDayCheckin(dayNum);
              },
              child: const Text('Undo', style: TextStyle(color: AppColors.warning)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _fetchCheckin(targetDay: dayNum);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _uncompleteDayCheckin(int dayNum) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) return;

    try {
      final res = await ApiService.instance.uncompleteDay(packId, dayNum);
      ref.invalidate(activeStudyPlanProvider);
      ref.invalidate(activePackProvider);
      ref.invalidate(packsListProvider);
      await _fetchCheckin(targetDay: dayNum);

      if (mounted) {
        final newScore = res['readiness_percentage'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day $dayNum marked incomplete. Readiness score set to $newScore%'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to undo day completion: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePackId = ref.watch(activePackIdProvider);
    final variant = ref.watch(themeVariantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activePackId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Check-In')),
        body: const Center(child: Text('No active interview pack selected.')),
      );
    }

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Check-In')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = checkinData ?? {};
    final company = data['company'] ?? 'Target Company';
    final hiringProgram = data['hiring_program'] ?? '';
    final dayNum = data['current_day_number'] ?? 1;
    final totalDays = data['total_days'] ?? 7;
    final dayTitle = data['today_title'] ?? 'Day $dayNum Practice';
    final recTasks = List<String>.from(data['today_recommended_tasks'] ?? []);
    final compTasks = List<String>.from(data['today_completed_tasks'] ?? []);
    final carriedForward = List<Map<String, dynamic>>.from(
      (data['carried_forward_tasks'] as List? ?? []).map((e) => Map<String, dynamic>.from(e))
    );
    final readinessScore = data['readiness_percentage'] ?? 0;
    final isDayDone = data['is_day_completed'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In & Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Progress Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: variant.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: variant.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'DAY $dayNum CHECK-IN',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$readinessScore% Readiness',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(company, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  if (hiringProgram.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(hiringProgram, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    dayTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Day Selector Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalDays, (index) {
                  final dIndex = index + 1;
                  final isSelected = dIndex == dayNum;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('Day $dIndex'),
                      selected: isSelected,
                      selectedColor: variant.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          _fetchCheckin(targetDay: dIndex);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Carried-Forward Tasks Section (if any incomplete tasks exist from past days)
            if (carriedForward.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history_toggle_off, color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Incomplete Tasks Carried Forward',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tasks you didn\'t finish previously carry forward here. Tap to toggle completion status:',
                      style: TextStyle(fontSize: 11, color: AppColors.textDarkSecondary),
                    ),
                    const SizedBox(height: 10),
                    ...carriedForward.map((item) {
                      final taskText = item['task'] as String;
                      final fromDay = item['from_day'] as int;
                      final isChecked = compTasks.contains(taskText);

                      return CheckboxListTile(
                        value: isChecked,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(taskText, style: TextStyle(fontSize: 13, decoration: isChecked ? TextDecoration.lineThrough : null)),
                        subtitle: Text('Carried forward from Day $fromDay', style: const TextStyle(fontSize: 10, color: AppColors.warning)),
                        onChanged: (_) => _toggleTask(fromDay, taskText, isChecked),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3. Today's Scheduled Tasks List
            const Text(
              'Scheduled Tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Check off items as you complete them or uncheck to undo if clicked by mistake:',
              style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary),
            ),
            const SizedBox(height: 12),

            ...recTasks.map((task) {
              final isDone = compTasks.contains(task);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDone ? AppColors.success.withOpacity(0.5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: CheckboxListTile(
                  value: isDone,
                  activeColor: AppColors.success,
                  title: Text(
                    task,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.textDarkMuted : null,
                    ),
                  ),
                  onChanged: (_) => _toggleTask(dayNum, task, isDone),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 4. Complete / Undo Day Action Bar
            if (!isDayDone)
              AppButton(
                label: 'Complete Today\'s Check-In & Boost Readiness',
                icon: Icons.stars,
                width: double.infinity,
                variant: AppButtonVariant.primary,
                onPressed: () => _completeDayCheckin(dayNum),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Day $dayNum Completed ✓',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _uncompleteDayCheckin(dayNum),
                    icon: const Icon(Icons.undo, size: 16, color: AppColors.warning),
                    label: const Text('Undo', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

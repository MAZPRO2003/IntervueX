import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pack_model.dart';
import '../../data/models/study_plan_model.dart';
import '../../data/services/api_service.dart';

class PacksNotifier extends StateNotifier<AsyncValue<List<InterviewPackModel>>> {
  PacksNotifier() : super(const AsyncValue.loading()) {
    loadPacks();
  }

  Future<void> loadPacks() async {
    try {
      state = const AsyncValue.loading();
      final packs = await ApiService.instance.listPacks();
      state = AsyncValue.data(packs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addOrUpdatePack(InterviewPackModel pack) {
    state.whenData((list) {
      final updated = List<InterviewPackModel>.from(list);
      final idx = updated.indexWhere((p) => p.id == pack.id);
      if (idx >= 0) {
        updated[idx] = pack;
      } else {
        updated.insert(0, pack);
      }
      state = AsyncValue.data(updated);
    });
  }
}

final packsListProvider = StateNotifierProvider<PacksNotifier, AsyncValue<List<InterviewPackModel>>>((ref) {
  return PacksNotifier();
});

// Currently selected pack (null on initial login until user chooses a target)
final activePackIdProvider = StateProvider<String?>((ref) => null);

final activePackProvider = FutureProvider<InterviewPackModel?>((ref) async {
  final packId = ref.watch(activePackIdProvider);
  if (packId == null) return null;
  return await ApiService.instance.getPackDetails(packId);
});

final activePackProcessProvider = FutureProvider<InterviewProcessModel?>((ref) async {
  final packId = ref.watch(activePackIdProvider);
  if (packId == null) return null;
  return await ApiService.instance.getPackProcess(packId);
});

final activeStudyPlanProvider = FutureProvider<StudyPlanModel?>((ref) async {
  final packId = ref.watch(activePackIdProvider);
  if (packId == null) return null;
  return await ApiService.instance.getStudyPlan(packId);
});

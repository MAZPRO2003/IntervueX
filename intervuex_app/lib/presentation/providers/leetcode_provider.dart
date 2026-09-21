import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/leetcode_question_model.dart';
import '../../data/services/api_service.dart';
import 'pack_provider.dart';
import 'question_provider.dart';

class LeetCodeNotifier extends StateNotifier<AsyncValue<List<LeetCodeQuestionModel>>> {
  final Ref ref;

  LeetCodeNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadLeetCodeQuestions();
  }

  Future<void> loadLeetCodeQuestions() async {
    final packId = ref.watch(activePackIdProvider);
    if (packId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    final filter = ref.watch(questionFilterProvider);

    try {
      state = const AsyncValue.loading();
      final list = await ApiService.instance.getLeetCodeQuestions(
        packId,
        difficulty: filter.difficulty == 'All' ? null : filter.difficulty,
        search: filter.search,
        sortBy: filter.sortBy,
      );

      if (filter.sortBy == 'Difficulty') {
        const diffOrder = {'easy': 1, 'medium': 2, 'hard': 3};
        list.sort((a, b) {
          final aOrder = diffOrder[a.difficulty.toLowerCase()] ?? 4;
          final bOrder = diffOrder[b.difficulty.toLowerCase()] ?? 4;
          return aOrder.compareTo(bOrder);
        });
      }

      state = AsyncValue.data(list);

    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leetCodeQuestionsProvider = StateNotifierProvider<LeetCodeNotifier, AsyncValue<List<LeetCodeQuestionModel>>>((ref) {
  return LeetCodeNotifier(ref);
});

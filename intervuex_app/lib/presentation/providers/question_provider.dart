import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/question_model.dart';
import '../../data/services/api_service.dart';
import 'pack_provider.dart';

class QuestionFilterState {
  final String category;
  final String difficulty;
  final String priority;
  final String search;
  final String sortBy;
  final bool onlySaved;
  final bool onlyWeak;

  QuestionFilterState({
    this.category = 'All',
    this.difficulty = 'All',
    this.priority = 'All',
    this.search = '',
    this.sortBy = 'Most Asked',
    this.onlySaved = false,
    this.onlyWeak = false,
  });

  QuestionFilterState copyWith({
    String? category,
    String? difficulty,
    String? priority,
    String? search,
    String? sortBy,
    bool? onlySaved,
    bool? onlyWeak,
  }) {
    return QuestionFilterState(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      priority: priority ?? this.priority,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      onlySaved: onlySaved ?? this.onlySaved,
      onlyWeak: onlyWeak ?? this.onlyWeak,
    );
  }
}

final questionFilterProvider = StateProvider<QuestionFilterState>((ref) {
  return QuestionFilterState();
});

class QuestionsNotifier extends StateNotifier<AsyncValue<List<QuestionModel>>> {
  final Ref ref;

  QuestionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final packId = ref.watch(activePackIdProvider);
    if (packId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    final filter = ref.watch(questionFilterProvider);

    try {
      state = const AsyncValue.loading();
      final list = await ApiService.instance.getQuestions(
        packId,
        category: filter.category == 'All' ? null : filter.category,
        difficulty: filter.difficulty == 'All' ? null : filter.difficulty,
        priority: filter.priority == 'All' ? null : filter.priority,
        search: filter.search,
        onlySaved: filter.onlySaved,
        onlyWeak: filter.onlyWeak,
        sortBy: filter.sortBy,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleSave(String questionId) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) return;
    final isSaved = await ApiService.instance.toggleSaveQuestion(packId, questionId);
    state.whenData((list) {
      final updated = list.map((q) {
        if (q.id == questionId) {
          q.isSaved = isSaved;
        }
        return q;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }

  Future<void> toggleMastered(String questionId) async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null) return;
    final mastered = await ApiService.instance.toggleMasteredQuestion(packId, questionId);
    state.whenData((list) {
      final updated = list.map((q) {
        if (q.id == questionId) {
          q.mastered = mastered;
        }
        return q;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }

  bool isGeneratingMore = false;

  Future<void> generateMore() async {
    final packId = ref.read(activePackIdProvider);
    if (packId == null || isGeneratingMore) return;
    isGeneratingMore = true;
    try {
      final updatedList = await ApiService.instance.generateMoreQuestions(packId, count: 25);
      if (updatedList.isNotEmpty) {
        state = AsyncValue.data(updatedList);
      } else {
        await loadQuestions();
      }
    } catch (e) {
      await loadQuestions();
    } finally {
      isGeneratingMore = false;
    }
  }
}

final questionsListProvider = StateNotifierProvider<QuestionsNotifier, AsyncValue<List<QuestionModel>>>((ref) {
  return QuestionsNotifier(ref);
});

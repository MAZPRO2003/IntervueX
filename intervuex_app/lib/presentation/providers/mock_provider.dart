import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mock_model.dart';
import '../../data/services/api_service.dart';

class MockSessionNotifier extends StateNotifier<AsyncValue<MockSessionModel?>> {
  MockSessionNotifier() : super(const AsyncValue.data(null));

  Future<void> startSession({
    required String packId,
    String mode = "Technical + HR",
    String difficulty = "Normal",
    int totalTurns = 4,
  }) async {
    try {
      state = const AsyncValue.loading();
      final sess = await ApiService.instance.createMockSession(
        packId: packId,
        mode: mode,
        difficulty: difficulty,
        totalTurns: totalTurns,
      );
      state = AsyncValue.data(sess);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitAnswer({
    required int turnIndex,
    required String answerText,
    bool isVoice = false,
  }) async {
    final current = state.value;
    if (current == null) return;

    try {
      state = const AsyncValue.loading();
      final updated = await ApiService.instance.submitMockAnswer(
        sessionId: current.id,
        turnIndex: turnIndex,
        candidateAnswer: answerText,
        isVoice: isVoice,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final mockSessionProvider = StateNotifierProvider<MockSessionNotifier, AsyncValue<MockSessionModel?>>((ref) {
  return MockSessionNotifier();
});

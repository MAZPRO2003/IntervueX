class AnswerEvaluationModel {
  final int technicalAccuracy;
  final int completeness;
  final int relevance;
  final int structure;
  final int clarity;
  final double overallScore;
  final List<String> fillerWords;
  final String? pacingFeedback;
  final List<String> whatYouDidWell;
  final List<String> whatIsMissing;
  final List<String> howToImprove;
  final List<String> whatYouShouldNotDo;
  final String betterAnswerStructure;
  final List<String> whatCanTheyAskNext;

  AnswerEvaluationModel({
    required this.technicalAccuracy,
    required this.completeness,
    required this.relevance,
    required this.structure,
    required this.clarity,
    required this.overallScore,
    required this.fillerWords,
    this.pacingFeedback,
    required this.whatYouDidWell,
    required this.whatIsMissing,
    required this.howToImprove,
    required this.whatYouShouldNotDo,
    required this.betterAnswerStructure,
    required this.whatCanTheyAskNext,
  });

  factory AnswerEvaluationModel.fromJson(Map<String, dynamic> json) {
    return AnswerEvaluationModel(
      technicalAccuracy: json['technical_accuracy'] ?? 7,
      completeness: json['completeness'] ?? 7,
      relevance: json['relevance'] ?? 8,
      structure: json['structure'] ?? 7,
      clarity: json['clarity'] ?? 8,
      overallScore: (json['overall_score'] is num) ? (json['overall_score'] as num).toDouble() : 7.5,
      fillerWords: List<String>.from(json['filler_words'] ?? []),
      pacingFeedback: json['pacing_feedback'],
      whatYouDidWell: List<String>.from(json['what_you_did_well'] ?? []),
      whatIsMissing: List<String>.from(json['what_is_missing'] ?? []),
      howToImprove: List<String>.from(json['how_to_improve'] ?? []),
      whatYouShouldNotDo: List<String>.from(json['what_you_should_not_do'] ?? []),
      betterAnswerStructure: json['better_answer_structure'] ?? '',
      whatCanTheyAskNext: List<String>.from(json['what_can_they_ask_next'] ?? []),
    );
  }
}

class MockTurnModel {
  final int turnIndex;
  final String interviewerQuestion;
  final String questionCategory;
  String? candidateAnswer;
  AnswerEvaluationModel? evaluation;

  MockTurnModel({
    required this.turnIndex,
    required this.interviewerQuestion,
    required this.questionCategory,
    this.candidateAnswer,
    this.evaluation,
  });

  factory MockTurnModel.fromJson(Map<String, dynamic> json) {
    return MockTurnModel(
      turnIndex: json['turn_index'] ?? 1,
      interviewerQuestion: json['interviewer_question'] ?? '',
      questionCategory: json['question_category'] ?? 'Technical',
      candidateAnswer: json['candidate_answer'],
      evaluation: json['evaluation'] != null
          ? AnswerEvaluationModel.fromJson(json['evaluation'])
          : null,
    );
  }
}

class MockSessionModel {
  final String id;
  final String packId;
  final String mode;
  final String difficulty;
  final int totalTurns;
  int currentTurnIndex;
  bool isCompleted;
  List<MockTurnModel> turns;
  String? finalFeedbackSummary;
  double? averageScore;

  MockSessionModel({
    required this.id,
    required this.packId,
    required this.mode,
    required this.difficulty,
    required this.totalTurns,
    required this.currentTurnIndex,
    required this.isCompleted,
    required this.turns,
    this.finalFeedbackSummary,
    this.averageScore,
  });

  factory MockSessionModel.fromJson(Map<String, dynamic> json) {
    return MockSessionModel(
      id: json['id'] ?? '',
      packId: json['pack_id'] ?? '',
      mode: json['mode'] ?? 'Technical + HR',
      difficulty: json['difficulty'] ?? 'Normal',
      totalTurns: json['total_turns'] ?? 5,
      currentTurnIndex: json['current_turn_index'] ?? 1,
      isCompleted: json['is_completed'] ?? false,
      turns: (json['turns'] as List? ?? [])
          .map((t) => MockTurnModel.fromJson(t))
          .toList(),
      finalFeedbackSummary: json['final_feedback_summary'],
      averageScore: (json['average_score'] is num) ? (json['average_score'] as num).toDouble() : null,
    );
  }
}

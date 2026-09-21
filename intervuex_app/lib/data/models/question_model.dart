class SourceModel {
  final String sourceName;
  final String sourceUrl;
  final String sourceType;
  final String? confidence;

  SourceModel({
    required this.sourceName,
    required this.sourceUrl,
    required this.sourceType,
    this.confidence,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      sourceName: json['source_name'] ?? json['name'] ?? 'Interview Archive',
      sourceUrl: json['source_url'] ?? json['url'] ?? '',
      sourceType: json['source_type'] ?? 'Documentation',
      confidence: json['confidence'],
    );
  }
}

class HowToAnswerModel {
  final String interviewerIntent;
  final String explanationEn;
  final String explanationTa;
  final String explanationHi;
  final List<String> answerStructure;
  final List<String> keyPoints;
  final String naturalSampleAnswerEn;
  final String shortAnswerEn;
  final String codeExample;
  final String complexity;
  final String interviewTip;
  final List<String> whatToAvoid;
  final List<String> commonMistakes;

  HowToAnswerModel({
    required this.interviewerIntent,
    required this.explanationEn,
    required this.explanationTa,
    required this.explanationHi,
    required this.answerStructure,
    required this.keyPoints,
    required this.naturalSampleAnswerEn,
    required this.shortAnswerEn,
    required this.codeExample,
    required this.complexity,
    required this.interviewTip,
    required this.whatToAvoid,
    required this.commonMistakes,
  });

  factory HowToAnswerModel.fromJson(Map<String, dynamic> json) {
    return HowToAnswerModel(
      interviewerIntent: json['interviewer_intent'] ?? '',
      explanationEn: json['explanation_en'] ?? json['detailed_explanation'] ?? json['explanation'] ?? '',
      explanationTa: json['explanation_ta'] ?? '',
      explanationHi: json['explanation_hi'] ?? '',
      answerStructure: List<String>.from(json['answer_structure'] ?? []),
      keyPoints: List<String>.from(json['key_points'] ?? []),
      naturalSampleAnswerEn: json['natural_sample_answer_en'] ?? json['sample_answer'] ?? '',
      shortAnswerEn: json['short_answer_en'] ?? json['short_answer'] ?? json['interview_answer'] ?? '',
      codeExample: json['code_example'] ?? json['code'] ?? json['sql_query'] ?? json['example'] ?? '',
      complexity: json['complexity'] ?? '',
      interviewTip: json['interview_tip'] ?? '',
      whatToAvoid: List<String>.from(json['what_to_avoid'] ?? []),
      commonMistakes: List<String>.from(json['common_mistakes'] ?? []),
    );
  }
}

class QuestionModel {
  final String id;
  final String packId;
  final String question;
  final String company;
  final String hiringProgram;
  final String role;
  final String round;
  final String questionYear;
  final String category;
  final String difficulty;
  final String priority;
  final String questionType;
  final String verificationStatus;
  final String? frequencyEvidence;
  final String evidenceLabel;
  final String whyMatters;
  final String candidateRelevance;
  final List<String> conceptsTested;
  final List<String> expectedAnswerPoints;
  final HowToAnswerModel howToAnswer;
  final List<SourceModel> questionSources;
  final List<SourceModel> answerSources;
  final List<String> followUpQuestions;
  final List<String> relatedQuestions;
  final List<String> askedByCompanies;
  bool isSaved;
  bool mastered;
  bool needsRevision;

  QuestionModel({
    required this.id,
    required this.packId,
    required this.question,
    required this.company,
    required this.hiringProgram,
    required this.role,
    required this.round,
    required this.questionYear,
    required this.category,
    required this.difficulty,
    required this.priority,
    required this.questionType,
    required this.verificationStatus,
    this.frequencyEvidence,
    required this.evidenceLabel,
    required this.whyMatters,
    required this.candidateRelevance,
    required this.conceptsTested,
    required this.expectedAnswerPoints,
    required this.howToAnswer,
    required this.questionSources,
    required this.answerSources,
    required this.followUpQuestions,
    required this.relatedQuestions,
    required this.askedByCompanies,
    this.isSaved = false,
    this.mastered = false,
    this.needsRevision = false,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      packId: json['pack_id'] ?? '',
      question: json['question'] ?? json['question_text'] ?? '',
      company: json['company'] ?? '',
      hiringProgram: json['hiring_program'] ?? '',
      role: json['role'] ?? 'Software Engineer',
      round: json['round'] ?? 'Technical Round',
      questionYear: json['question_year'] ?? '2024-2025',
      category: json['category'] ?? 'Technical',
      difficulty: json['difficulty'] ?? 'Medium',
      priority: json['priority'] ?? 'High',
      questionType: json['question_type'] ?? 'SOURCED_QUESTION',
      verificationStatus: json['verification_status'] ?? 'ANSWER_VERIFIED',
      frequencyEvidence: json['frequency_evidence'],
      evidenceLabel: json['evidence_label'] ?? 'REPORTED BY CANDIDATES',
      whyMatters: json['why_matters'] ?? '',
      candidateRelevance: json['candidate_relevance'] ?? '',
      conceptsTested: List<String>.from(json['concepts_tested'] ?? []),
      expectedAnswerPoints: List<String>.from(json['expected_answer_points'] ?? []),
      howToAnswer: HowToAnswerModel.fromJson(json['how_to_answer'] ?? {}),
      questionSources: (json['question_sources'] as List? ?? [])
          .map((e) => SourceModel.fromJson(e))
          .toList(),
      answerSources: (json['answer_sources'] as List? ?? [])
          .map((e) => SourceModel.fromJson(e))
          .toList(),
      followUpQuestions: List<String>.from(json['follow_up_questions'] ?? []),
      relatedQuestions: List<String>.from(json['related_questions'] ?? []),
      askedByCompanies: List<String>.from(json['asked_by_companies'] ?? []),
      isSaved: json['is_saved'] ?? false,
      mastered: json['mastered'] ?? false,
      needsRevision: json['needs_revision'] ?? false,
    );
  }
}


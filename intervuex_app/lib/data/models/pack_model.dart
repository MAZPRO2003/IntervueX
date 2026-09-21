class EvidenceItemModel {
  final String label;
  final String sourceName;
  final String? sourceUrl;
  final String retrievedDate;
  final String confidence;
  final String summary;

  EvidenceItemModel({
    required this.label,
    required this.sourceName,
    this.sourceUrl,
    required this.retrievedDate,
    required this.confidence,
    required this.summary,
  });

  factory EvidenceItemModel.fromJson(Map<String, dynamic> json) {
    return EvidenceItemModel(
      label: json['label'] ?? 'REPORTED BY CANDIDATES',
      sourceName: json['source_name'] ?? 'Candidate Discussion',
      sourceUrl: json['source_url'],
      retrievedDate: json['retrieved_date'] ?? '2026',
      confidence: json['confidence'] ?? 'Medium',
      summary: json['summary'] ?? '',
    );
  }
}

class SampleQuestionModel {
  final String question;
  final String answer;
  final String category;
  final String? codeSnippet;

  SampleQuestionModel({
    required this.question,
    required this.answer,
    required this.category,
    this.codeSnippet,
  });

  factory SampleQuestionModel.fromJson(dynamic json) {
    if (json is String) {
      return SampleQuestionModel(
        question: json,
        answer: 'Comprehensive answer breakdown: Explain core concepts, algorithm logic, time/space complexity, and production edge cases for this topic.',
        category: 'Sample Question',
      );
    }
    if (json is Map<String, dynamic>) {
      return SampleQuestionModel(
        question: json['question'] ?? json['title'] ?? '',
        answer: json['answer'] ?? json['explanation'] ?? 'Comprehensive solution overview detailing key principles, trade-offs, and implementation guidelines.',
        category: json['category'] ?? 'Technical Focus',
        codeSnippet: json['code'] ?? json['code_snippet'],
      );
    }
    return SampleQuestionModel(
      question: json.toString(),
      answer: '',
      category: 'General',
    );
  }
}

class InterviewRoundModel {
  final int roundNumber;
  final String stageName;
  final String stageType;
  final String purpose;
  final List<String> expectedTopics;
  final String assessmentFormat;
  final String confidence;
  final List<EvidenceItemModel> evidenceItems;
  final List<String> likelyQuestionsPreview;
  final List<SampleQuestionModel> sampleQuestions;

  InterviewRoundModel({
    required this.roundNumber,
    required this.stageName,
    required this.stageType,
    required this.purpose,
    required this.expectedTopics,
    required this.assessmentFormat,
    required this.confidence,
    required this.evidenceItems,
    required this.likelyQuestionsPreview,
    required this.sampleQuestions,
  });

  factory InterviewRoundModel.fromJson(Map<String, dynamic> json) {
    final previews = List<String>.from(json['likely_questions_preview'] ?? []);
    final rawSamples = json['sample_questions'] as List? ?? [];

    final List<SampleQuestionModel> parsedSamples = rawSamples.isNotEmpty
        ? rawSamples.map((e) => SampleQuestionModel.fromJson(e)).toList()
        : previews.map((q) => SampleQuestionModel.fromJson(q)).toList();

    return InterviewRoundModel(
      roundNumber: json['round_number'] ?? 1,
      stageName: json['stage_name'] ?? 'Round 1',
      stageType: json['stage_type'] ?? 'Technical',
      purpose: json['purpose'] ?? '',
      expectedTopics: List<String>.from(json['expected_topics'] ?? []),
      assessmentFormat: json['assessment_format'] ?? 'Interview Round',
      confidence: json['confidence'] ?? 'High',
      evidenceItems: (json['evidence_items'] as List? ?? [])
          .map((e) => EvidenceItemModel.fromJson(e))
          .toList(),
      likelyQuestionsPreview: previews.isNotEmpty ? previews : parsedSamples.map((s) => s.question).toList(),
      sampleQuestions: parsedSamples,
    );
  }
}

class InterviewProcessModel {
  final String id;
  final String company;
  final String hiringProgram;
  final String role;
  final String experienceLevel;
  final String location;
  final int totalReportedStages;
  final List<InterviewRoundModel> rounds;
  final String overallConfidence;
  final String evidenceSummary;
  final String disclaimer;

  InterviewProcessModel({
    required this.id,
    required this.company,
    required this.hiringProgram,
    required this.role,
    required this.experienceLevel,
    required this.location,
    required this.totalReportedStages,
    required this.rounds,
    required this.overallConfidence,
    required this.evidenceSummary,
    required this.disclaimer,
  });

  factory InterviewProcessModel.fromJson(Map<String, dynamic> json) {
    return InterviewProcessModel(
      id: json['id'] ?? '',
      company: json['company'] ?? '',
      hiringProgram: json['hiring_program'] ?? 'Standard Hiring',
      role: json['role'] ?? 'Software Developer',
      experienceLevel: json['experience_level'] ?? 'Entry-Level',
      location: json['location'] ?? 'Hybrid',
      totalReportedStages: json['total_reported_stages'] ?? 3,
      rounds: (json['rounds'] as List? ?? [])
          .map((r) => InterviewRoundModel.fromJson(r))
          .toList(),
      overallConfidence: json['overall_confidence'] ?? 'High',
      evidenceSummary: json['evidence_summary'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}

class InterviewPackModel {
  final String id;
  final String? jobId;
  final String? resumeId;
  final String company;
  final String hiringProgram;
  final String role;
  final String location;
  final int readinessPercentage;
  final int daysRemaining;
  final String? interviewDate;
  final int totalQuestions;
  final int masteredQuestions;
  final int savedQuestions;
  final int weakQuestions;
  final String createdAt;

  InterviewPackModel({
    required this.id,
    this.jobId,
    this.resumeId,
    required this.company,
    required this.hiringProgram,
    required this.role,
    required this.location,
    required this.readinessPercentage,
    required this.daysRemaining,
    this.interviewDate,
    required this.totalQuestions,
    required this.masteredQuestions,
    required this.savedQuestions,
    required this.weakQuestions,
    required this.createdAt,
  });

  factory InterviewPackModel.fromJson(Map<String, dynamic> json) {
    return InterviewPackModel(
      id: json['id'] ?? '',
      jobId: json['job_id'],
      resumeId: json['resume_id'],
      company: json['company'] ?? 'TechCorp',
      hiringProgram: json['hiring_program'] ?? 'Standard Track',
      role: json['role'] ?? 'Software Engineer',
      location: json['location'] ?? 'Hybrid',
      readinessPercentage: json['readiness_percentage'] ?? 0,
      daysRemaining: json['days_remaining'] ?? 7,
      interviewDate: json['interview_date'],
      totalQuestions: json['total_questions'] ?? 50,
      masteredQuestions: json['mastered_questions'] ?? 0,
      savedQuestions: json['saved_questions'] ?? 0,
      weakQuestions: json['weak_questions'] ?? 0,
      createdAt: json['created_at'] ?? '2026-09-19',
    );
  }
}

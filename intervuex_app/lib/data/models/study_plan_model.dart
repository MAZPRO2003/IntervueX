class DayScheduleModel {
  final int dayNumber;
  final String title;
  final List<String> focusTopics;
  final List<String> recommendedTasks;
  final List<String> completedTasks;
  final String? categoryFilter;
  final int estimatedMinutes;
  bool isCompleted;

  DayScheduleModel({
    required this.dayNumber,
    required this.title,
    required this.focusTopics,
    required this.recommendedTasks,
    this.completedTasks = const [],
    this.categoryFilter,
    required this.estimatedMinutes,
    this.isCompleted = false,
  });

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    return DayScheduleModel(
      dayNumber: json['day_number'] ?? 1,
      title: json['title'] ?? 'Study Topic',
      focusTopics: List<String>.from(json['focus_topics'] ?? []),
      recommendedTasks: List<String>.from(json['recommended_tasks'] ?? []),
      completedTasks: List<String>.from(json['completed_tasks'] ?? []),
      categoryFilter: json['category_filter'],
      estimatedMinutes: json['estimated_minutes'] ?? 45,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class SpacedRevisionItemModel {
  final String id;
  final String questionId;
  final String questionText;
  final String category;
  final String weakReason;
  final String intervalStage;
  final String dueDate;
  bool isReviewed;

  SpacedRevisionItemModel({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.category,
    required this.weakReason,
    required this.intervalStage,
    required this.dueDate,
    this.isReviewed = false,
  });

  factory SpacedRevisionItemModel.fromJson(Map<String, dynamic> json) {
    return SpacedRevisionItemModel(
      id: json['id'] ?? '',
      questionId: json['question_id'] ?? '',
      questionText: json['question_text'] ?? '',
      category: json['category'] ?? 'General',
      weakReason: json['weak_reason'] ?? '',
      intervalStage: json['interval_stage'] ?? 'Tomorrow',
      dueDate: json['due_date'] ?? '2026-09-20',
      isReviewed: json['is_reviewed'] ?? false,
    );
  }
}

class ReadinessBreakdownModel {
  final int overallPercentage;
  final int technicalScore;
  final int sqlDbScore;
  final int resumeScore;
  final int projectScore;
  final int hrScore;
  final int codingScore;
  final int companyScore;
  final List<String> strongAreas;
  final List<String> weakAreas;
  final String nextBestAction;

  ReadinessBreakdownModel({
    required this.overallPercentage,
    required this.technicalScore,
    required this.sqlDbScore,
    required this.resumeScore,
    required this.projectScore,
    required this.hrScore,
    required this.codingScore,
    required this.companyScore,
    required this.strongAreas,
    required this.weakAreas,
    required this.nextBestAction,
  });

  factory ReadinessBreakdownModel.fromJson(Map<String, dynamic> json) {
    return ReadinessBreakdownModel(
      overallPercentage: json['overall_percentage'] ?? 70,
      technicalScore: json['technical_score'] ?? 80,
      sqlDbScore: json['sql_db_score'] ?? 65,
      resumeScore: json['resume_score'] ?? 75,
      projectScore: json['project_score'] ?? 70,
      hrScore: json['hr_score'] ?? 60,
      codingScore: json['coding_score'] ?? 65,
      companyScore: json['company_score'] ?? 70,
      strongAreas: List<String>.from(json['strong_areas'] ?? []),
      weakAreas: List<String>.from(json['weak_areas'] ?? []),
      nextBestAction: json['next_best_action'] ?? 'Continue practice questions.',
    );
  }
}

class StudyPlanModel {
  final String id;
  final String packId;
  final int durationDays;
  final String? interviewDate;
  final int daysRemaining;
  final List<DayScheduleModel> days;
  final List<SpacedRevisionItemModel> spacedRevisions;
  final ReadinessBreakdownModel readiness;

  StudyPlanModel({
    required this.id,
    required this.packId,
    required this.durationDays,
    this.interviewDate,
    required this.daysRemaining,
    required this.days,
    required this.spacedRevisions,
    required this.readiness,
  });

  String? get targetInterviewDate => interviewDate;

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanModel(
      id: json['id'] ?? '',
      packId: json['pack_id'] ?? '',
      durationDays: json['duration_days'] ?? 7,
      interviewDate: json['target_interview_date'] ?? json['interview_date'],
      daysRemaining: json['days_remaining'] ?? 7,
      days: (json['days'] as List? ?? [])
          .map((d) => DayScheduleModel.fromJson(d))
          .toList(),
      spacedRevisions: (json['spaced_revisions'] as List? ?? [])
          .map((s) => SpacedRevisionItemModel.fromJson(s))
          .toList(),
      readiness: ReadinessBreakdownModel.fromJson(json['readiness'] ?? {}),
    );
  }
}

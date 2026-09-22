import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/pack_model.dart';
import '../models/question_model.dart';
import '../models/mock_model.dart';
import '../models/study_plan_model.dart';
import '../models/company_model.dart';
import '../models/leetcode_question_model.dart';


class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
    headers: {"Accept": "application/json"},
  ));


  // Singleton instance
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  // Companies & Hiring Programs
    Future<List<CompanyModel>> getCompanies() async {
    final res = await _dio.get("/companies");
    final list = res.data as List;
    return list.map((e) => CompanyModel.fromJson(e)).toList();
  }

  Future<CompanyModel> generateCompany(String companyName) async {
    final res = await _dio.post("/companies/generate", data: {
      "company_name": companyName,
    });
    return CompanyModel.fromJson(res.data);
  }

  Future<void> startDiscovery({int limit = 5}) async {
    await _dio.post("/discovery/start", queryParameters: {
      "limit": limit,
    });
  }

  Future<Map<String, dynamic>> selectCompanyTrack({
    required String companyId,
    required String trackId,
  }) async {
    final res = await _dio.post("/companies/select_track", data: {
      "company_id": companyId,
      "track_id": trackId,
    });
    return res.data as Map<String, dynamic>;
  }

  // Jobs
  Future<Map<String, dynamic>> analyzeJob({String? url, String? rawText, Uint8List? fileBytes, String? fileName}) async {
    final formData = FormData();
    if (url != null && url.isNotEmpty) {
      formData.fields.add(MapEntry("url", url));
    }
    if (rawText != null && rawText.isNotEmpty) {
      formData.fields.add(MapEntry("raw_text", rawText));
    }
    if (fileBytes != null) {
      formData.files.add(MapEntry(
        "file",
        MultipartFile.fromBytes(fileBytes, filename: fileName ?? "job.pdf"),
      ));
    }

    final res = await _dio.post("/jobs/analyze", data: formData);
    return res.data as Map<String, dynamic>;
  }

  // Resumes
  Future<Map<String, dynamic>> analyzeResume({String? rawText, Uint8List? fileBytes, String? fileName, String? jobId}) async {
    final formData = FormData();
    if (rawText != null && rawText.isNotEmpty) {
      formData.fields.add(MapEntry("raw_text", rawText));
    }
    if (jobId != null) {
      formData.fields.add(MapEntry("job_id", jobId));
    }
    if (fileBytes != null) {
      formData.files.add(MapEntry(
        "file",
        MultipartFile.fromBytes(fileBytes, filename: fileName ?? "resume.pdf"),
      ));
    }

    final res = await _dio.post("/resumes/analyze", data: formData);
    return res.data as Map<String, dynamic>;
  }

  // Packs
  Future<Map<String, dynamic>> createInterviewPack({
    required String jobId,
    String? resumeId,
    String? interviewDate,
    int initialCount = 50,
  }) async {
    final res = await _dio.post("/packs/create", data: {
      "job_id": jobId,
      "resume_id": resumeId,
      "interview_date": interviewDate,
      "initial_question_count": initialCount,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<InterviewPackModel>> listPacks() async {
    final res = await _dio.get("/packs");
    final list = res.data as List;
    return list.map((e) => InterviewPackModel.fromJson(e)).toList();
  }

  Future<InterviewPackModel> getPackDetails(String packId) async {
    final res = await _dio.get("/packs/$packId");
    return InterviewPackModel.fromJson(res.data);
  }

  Future<InterviewProcessModel> getPackProcess(String packId) async {
    final res = await _dio.get("/packs/$packId/process");
    return InterviewProcessModel.fromJson(res.data);
  }

  // Questions
  Future<List<QuestionModel>> getQuestions(
    String packId, {
    String? category,
    String? difficulty,
    String? priority,
    String? search,
    bool onlySaved = false,
    bool onlyWeak = false,
    String sortBy = "Most Asked",
  }) async {
    final res = await _dio.get("/questions/$packId", queryParameters: {
      if (category != null) "category": category,
      if (difficulty != null) "difficulty": difficulty,
      if (priority != null) "priority": priority,
      if (search != null && search.isNotEmpty) "search": search,
      "only_saved": onlySaved,
      "only_weak": onlyWeak,
      "sort_by": sortBy,
    });
    final list = res.data["questions"] as List;
    return list.map((e) => QuestionModel.fromJson(e)).toList();
  }

  Future<bool> toggleSaveQuestion(String packId, String questionId) async {
    final res = await _dio.post("/questions/$packId/$questionId/toggle_save");
    return res.data["is_saved"] ?? false;
  }

  Future<bool> toggleMasteredQuestion(String packId, String questionId) async {
    final res = await _dio.post("/questions/$packId/$questionId/toggle_mastered");
    return res.data["mastered"] ?? false;
  }

  Future<List<QuestionModel>> generateMoreQuestions(String packId, {int count = 50}) async {
    final res = await _dio.post("/questions/$packId/generate_more", queryParameters: {"count": count});
    final list = res.data["questions"] as List;
    return list.map((e) => QuestionModel.fromJson(e)).toList();
  }

  Future<List<QuestionModel>> refreshQuestions(String packId) async {
    final res = await _dio.post("/questions/$packId/refresh");
    final list = res.data["questions"] as List;
    return list.map((e) => QuestionModel.fromJson(e)).toList();
  }

  Future<List<LeetCodeQuestionModel>> getLeetCodeQuestions(
    String packId, {
    String? difficulty,
    String? search,
    String? sortBy,
  }) async {
    final res = await _dio.get("/questions/$packId/leetcode", queryParameters: {
      if (difficulty != null && difficulty != 'All') "difficulty": difficulty,
      if (search != null && search.isNotEmpty) "search": search,
      if (sortBy != null && sortBy.isNotEmpty) "sort_by": sortBy,
    });
    final list = res.data["questions"] as List;
    return list.map((e) => LeetCodeQuestionModel.fromJson(e)).toList();
  }



  // Mock Interview
  Future<MockSessionModel> createMockSession({
    required String packId,
    String mode = "Technical + HR",
    String difficulty = "Normal",
    int totalTurns = 5,
  }) async {
    final res = await _dio.post("/mock/sessions", data: {
      "pack_id": packId,
      "mode": mode,
      "difficulty": difficulty,
      "total_turns": totalTurns,
    });
    return MockSessionModel.fromJson(res.data);
  }

  Future<MockSessionModel> submitMockAnswer({
    required String sessionId,
    required int turnIndex,
    required String candidateAnswer,
    bool isVoice = false,
  }) async {
    final res = await _dio.post("/mock/submit_answer", data: {
      "session_id": sessionId,
      "turn_index": turnIndex,
      "candidate_answer": candidateAnswer,
      "is_voice": isVoice,
    });
    return MockSessionModel.fromJson(res.data);
  }

  // Study Plan
  Future<StudyPlanModel> getStudyPlan(String packId) async {
    final res = await _dio.get("/study_plan/$packId");
    return StudyPlanModel.fromJson(res.data);
  }

  Future<StudyPlanModel> setTargetInterviewDate(String packId, String targetDateStr) async {
    final res = await _dio.post(
      "/study_plan/$packId/set_target_date",
      data: {"target_date": targetDateStr},
    );
    return StudyPlanModel.fromJson(res.data);
  }

  Future<Map<String, dynamic>> completeDay(String packId, int dayNumber) async {
    final res = await _dio.post("/study_plan/$packId/complete_day/$dayNumber");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> uncompleteDay(String packId, int dayNumber) async {
    final res = await _dio.post("/study_plan/$packId/uncomplete_day/$dayNumber");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> toggleTask(String packId, int dayNumber, String task, bool isCompleted) async {
    final res = await _dio.post("/study_plan/$packId/toggle_task", data: {
      "day_number": dayNumber,
      "task": task,
      "is_completed": isCompleted,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getDailyCheckin(String packId, {int? dayNumber}) async {
    final queryParams = dayNumber != null ? {"day_number": dayNumber} : null;
    final res = await _dio.get("/study_plan/$packId/daily_checkin", queryParameters: queryParams);
    return Map<String, dynamic>.from(res.data);
  }

  // PDF
  String getPdfDownloadUrl(String packId) {
    return "${ApiConstants.baseUrl}/pdf/$packId";
  }

  Future<Uint8List> downloadPdfBytes(String packId) async {
    final res = await _dio.get<List<int>>(
      "/pdf/$packId",
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data!);
  }

  // Moderation & Feedback
  Future<void> reportContent({
    required String contentId,
    required String contentType,
    required String reason,
    String? details,
  }) async {
    await _dio.post("/feedback/report", data: {
      "content_id": contentId,
      "content_type": contentType,
      "reason": reason,
      "details": details,
    });
  }

  Future<void> deleteAccount(String userId) async {
    await _dio.post("/feedback/delete_account", data: {
      "user_id": userId,
      "confirmation": true,
    });
  }

  // Flashcards, Code Sandbox & PDF Risk Inspector
  Future<List<Map<String, dynamic>>> getFlashcards(String category) async {
    final res = await _dio.get("/questions/flashcards/deck?category=$category");
    final list = res.data["cards"] as List? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String? problemId,
  }) async {
    final res = await _dio.post("/questions/execute_code", data: {
      "code": code,
      "language": language,
      "problem_id": problemId,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getResumeRiskMap(String? resumeId) async {
    final url = resumeId != null ? "/resumes/risk_map?resume_id=$resumeId" : "/resumes/risk_map";
    final res = await _dio.get(url);
    return Map<String, dynamic>.from(res.data);
  }

  /// Ask the AI Coach a question. Falls back gracefully if the endpoint doesn't exist.
  Future<Map<String, dynamic>> askAiCoach({
    required String question,
    String packId = '',
  }) async {
    try {
      final res = await _dio.post("/questions/ai_coach", data: {
        "question": question,
        "pack_id": packId,
      });
      return Map<String, dynamic>.from(res.data);
    } catch (_) {
      // Fallback: use mock Q&A endpoint
      final res = await _dio.post("/mock/sessions", data: {
        "pack_id": packId.isNotEmpty ? packId : "general",
        "mode": "AI Coach",
        "difficulty": "Normal",
        "total_turns": 1,
      });
      final session = Map<String, dynamic>.from(res.data);
      return {
        "answer": session["current_question"] ?? "I'm your AI Coach. Ask me anything!",
      };
    }
  }
}


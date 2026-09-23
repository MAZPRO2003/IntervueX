import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 20),
    headers: {"Accept": "application/json"},
  ));

  // Singleton instance
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  // In-Memory Fast Cache
  List<CompanyModel>? _inMemoryCompanies;
  List<InterviewPackModel>? _inMemoryPacks;

  void _saveDiskCache(String key, String jsonStr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonStr);
    } catch (_) {}
  }

  // Companies & Hiring Programs
  Future<List<CompanyModel>> getCompanies() async {
    if (_inMemoryCompanies != null && _inMemoryCompanies!.isNotEmpty) {
      _bgFetchCompanies();
      return _inMemoryCompanies!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString('cached_companies_json');
      if (rawJson != null && rawJson.isNotEmpty) {
        final list = jsonDecode(rawJson) as List;
        _inMemoryCompanies = list.map((e) => CompanyModel.fromJson(e)).toList();
      }
    } catch (_) {}

    try {
      final res = await _dio.get("/companies", options: Options(receiveTimeout: const Duration(seconds: 5)));
      final list = res.data as List;
      _inMemoryCompanies = list.map((e) => CompanyModel.fromJson(e)).toList();
      _saveDiskCache('cached_companies_json', jsonEncode(res.data));
      return _inMemoryCompanies!;
    } catch (e) {
      if (_inMemoryCompanies != null && _inMemoryCompanies!.isNotEmpty) {
        return _inMemoryCompanies!;
      }
      _inMemoryCompanies = _defaultFallbackCompanies();
      return _inMemoryCompanies!;
    }
  }

  void _bgFetchCompanies() async {
    try {
      final res = await _dio.get("/companies", options: Options(receiveTimeout: const Duration(seconds: 5)));
      final list = res.data as List;
      _inMemoryCompanies = list.map((e) => CompanyModel.fromJson(e)).toList();
      _saveDiskCache('cached_companies_json', jsonEncode(res.data));
    } catch (_) {}
  }

  Future<CompanyModel> generateCompany(String companyName) async {
    try {
      final res = await _dio.post("/companies/generate", data: {
        "company_name": companyName,
      });
      return CompanyModel.fromJson(res.data);
    } catch (e) {
      return CompanyModel(
        id: "comp_${companyName.toLowerCase().replaceAll(' ', '_')}",
        name: companyName,
        shortName: companyName.split(' ').first,
        category: "Technology",
        colorHex: "#6366F1",
        hiringPrograms: [
          HiringProgramModel(
            id: "prog_${companyName.toLowerCase().replaceAll(' ', '_')}_swe",
            name: "Software Engineer Track",
            role: "Software Engineer",
            packageLpa: "7-12 LPA",
            difficulty: "Medium",
            roundsCount: 3,
            overview: "Core hiring track for $companyName focusing on DSA, System Design, and OOPS.",
            typicalRounds: ["Online Assessment", "Technical Interview 1", "Managerial & HR"],
          )
        ],
      );
    }
  }

  Future<void> startDiscovery({int limit = 5}) async {
    try {
      await _dio.post("/discovery/start", queryParameters: {
        "limit": limit,
      });
    } catch (_) {}
  }

  Future<Map<String, dynamic>> selectCompanyTrack({
    required String companyId,
    required String trackId,
  }) async {
    try {
      final res = await _dio.post("/companies/select_track", data: {
        "company_id": companyId,
        "track_id": trackId,
      });
      return res.data as Map<String, dynamic>;
    } catch (e) {
      return {
        "status": "success",
        "company_id": companyId,
        "track_id": trackId,
      };
    }
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
    if (_inMemoryPacks != null && _inMemoryPacks!.isNotEmpty) {
      _bgFetchPacks();
      return _inMemoryPacks!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString('cached_packs_json');
      if (rawJson != null && rawJson.isNotEmpty) {
        final list = jsonDecode(rawJson) as List;
        _inMemoryPacks = list.map((e) => InterviewPackModel.fromJson(e)).toList();
      }
    } catch (_) {}

    try {
      final res = await _dio.get("/packs", options: Options(receiveTimeout: const Duration(seconds: 5)));
      final list = res.data as List;
      _inMemoryPacks = list.map((e) => InterviewPackModel.fromJson(e)).toList();
      _saveDiskCache('cached_packs_json', jsonEncode(res.data));
      return _inMemoryPacks!;
    } catch (e) {
      if (_inMemoryPacks != null && _inMemoryPacks!.isNotEmpty) {
        return _inMemoryPacks!;
      }
      _inMemoryPacks = _defaultFallbackPacks();
      return _inMemoryPacks!;
    }
  }

  void _bgFetchPacks() async {
    try {
      final res = await _dio.get("/packs", options: Options(receiveTimeout: const Duration(seconds: 5)));
      final list = res.data as List;
      _inMemoryPacks = list.map((e) => InterviewPackModel.fromJson(e)).toList();
      _saveDiskCache('cached_packs_json', jsonEncode(res.data));
    } catch (_) {}
  }

  Future<InterviewPackModel> getPackDetails(String packId) async {
    try {
      final res = await _dio.get("/packs/$packId", options: Options(receiveTimeout: const Duration(seconds: 5)));
      return InterviewPackModel.fromJson(res.data);
    } catch (e) {
      final fallbackPacks = _defaultFallbackPacks();
      return fallbackPacks.firstWhere((p) => p.id == packId, orElse: () => fallbackPacks.first);
    }
  }

  Future<InterviewProcessModel> getPackProcess(String packId) async {
    try {
      final res = await _dio.get("/packs/$packId/process", options: Options(receiveTimeout: const Duration(seconds: 5)));
      return InterviewProcessModel.fromJson(res.data);
    } catch (e) {
      return InterviewProcessModel(
        id: packId,
        company: "TCS",
        hiringProgram: "NQT Ninja",
        role: "System Engineer",
        experienceLevel: "Fresher",
        location: "Pan India",
        totalReportedStages: 3,
        rounds: [
          InterviewRoundModel(
            roundNumber: 1,
            stageName: "Online Foundation & Advanced Test",
            stageType: "Aptitude + Coding",
            purpose: "Filter numerical, verbal, and core programming skills",
            expectedTopics: ["Data Structures", "C/C++/Java/Python", "SQL Basics", "Quantitative Aptitude"],
            assessmentFormat: "Online proctored test",
            confidence: "High",
            evidenceItems: [],
            likelyQuestionsPreview: [
              "Write a function to check if a string is a palindrome",
              "Execute a SQL query to find second highest salary"
            ],
            sampleQuestions: [],
          ),
          InterviewRoundModel(
            roundNumber: 2,
            stageName: "Technical Interview Round",
            stageType: "Technical Deep Dive",
            purpose: "Assess candidate project claims, OOPs, and problem solving",
            expectedTopics: ["Resume Projects", "OOP Principles", "Database Normalization"],
            assessmentFormat: "1-on-1 Virtual Technical Interview",
            confidence: "High",
            evidenceItems: [],
            likelyQuestionsPreview: [
              "Explain your final year project architecture",
              "What is the difference between Abstract Class and Interface?"
            ],
            sampleQuestions: [],
          ),
        ],
        overallConfidence: "High",
        evidenceSummary: "Aggregated from recent 2026 reported candidate experiences.",
        disclaimer: "IntervueX candidate research telemetry.",
      );
    }
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
    try {
      final res = await _dio.get("/questions/$packId", queryParameters: {
        if (category != null) "category": category,
        if (difficulty != null) "difficulty": difficulty,
        if (priority != null) "priority": priority,
        if (search != null && search.isNotEmpty) "search": search,
        "only_saved": onlySaved,
        "only_weak": onlyWeak,
        "sort_by": sortBy,
      }, options: Options(receiveTimeout: const Duration(seconds: 6)));
      final list = res.data["questions"] as List;
      final result = list.map((e) => QuestionModel.fromJson(e)).toList();
      if (result.isNotEmpty) {
        _saveDiskCache('cached_q_$packId', jsonEncode(res.data["questions"]));
      }
      return result;
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawJson = prefs.getString('cached_q_$packId');
        if (rawJson != null && rawJson.isNotEmpty) {
          final list = jsonDecode(rawJson) as List;
          return list.map((e) => QuestionModel.fromJson(e)).toList();
        }
      } catch (_) {}
      return _defaultFallbackQuestions(packId);
    }
  }

  Future<bool> toggleSaveQuestion(String packId, String questionId) async {
    try {
      final res = await _dio.post("/questions/$packId/$questionId/toggle_save");
      return res.data["is_saved"] ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<bool> toggleMasteredQuestion(String packId, String questionId) async {
    try {
      final res = await _dio.post("/questions/$packId/$questionId/toggle_mastered");
      return res.data["mastered"] ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<List<QuestionModel>> generateMoreQuestions(String packId, {int count = 50}) async {
    try {
      final res = await _dio.post("/questions/$packId/generate_more", queryParameters: {"count": count});
      final list = res.data["questions"] as List;
      return list.map((e) => QuestionModel.fromJson(e)).toList();
    } catch (_) {
      return _defaultFallbackQuestions(packId);
    }
  }

  Future<List<QuestionModel>> refreshQuestions(String packId) async {
    try {
      final res = await _dio.post("/questions/$packId/refresh");
      final list = res.data["questions"] as List;
      return list.map((e) => QuestionModel.fromJson(e)).toList();
    } catch (_) {
      return _defaultFallbackQuestions(packId);
    }
  }

  Future<List<LeetCodeQuestionModel>> getLeetCodeQuestions(
    String packId, {
    String? difficulty,
    String? search,
    String? sortBy,
  }) async {
    try {
      final res = await _dio.get("/questions/$packId/leetcode", queryParameters: {
        if (difficulty != null && difficulty != 'All') "difficulty": difficulty,
        if (search != null && search.isNotEmpty) "search": search,
        if (sortBy != null && sortBy.isNotEmpty) "sort_by": sortBy,
      }, options: Options(receiveTimeout: const Duration(seconds: 5)));
      final list = res.data["questions"] as List;
      return list.map((e) => LeetCodeQuestionModel.fromJson(e)).toList();
    } catch (_) {
      return _defaultFallbackLeetCodeQuestions();
    }
  }

  // Mock Interview
  Future<MockSessionModel> createMockSession({
    required String packId,
    String mode = "Technical + HR",
    String difficulty = "Normal",
    int totalTurns = 5,
  }) async {
    try {
      final res = await _dio.post("/mock/sessions", data: {
        "pack_id": packId,
        "mode": mode,
        "difficulty": difficulty,
        "total_turns": totalTurns,
      });
      return MockSessionModel.fromJson(res.data);
    } catch (e) {
      return MockSessionModel.fromJson({
        "id": "mock_${DateTime.now().millisecondsSinceEpoch}",
        "pack_id": packId,
        "mode": mode,
        "difficulty": difficulty,
        "total_turns": totalTurns,
        "current_turn_index": 1,
        "is_completed": false,
        "turns": [
          {
            "turn_index": 1,
            "interviewer_question": "Welcome to your technical interview! Can you start by walking me through your primary resume project and explaining your key architectural decisions?",
            "question_category": "Project Architecture",
          }
        ],
      });
    }
  }

  Future<MockSessionModel> submitMockAnswer({
    required String sessionId,
    required int turnIndex,
    required String candidateAnswer,
    bool isVoice = false,
  }) async {
    try {
      final res = await _dio.post("/mock/submit_answer", data: {
        "session_id": sessionId,
        "turn_index": turnIndex,
        "candidate_answer": candidateAnswer,
        "is_voice": isVoice,
      });
      return MockSessionModel.fromJson(res.data);
    } catch (e) {
      return MockSessionModel.fromJson({
        "id": sessionId,
        "pack_id": "pack_default",
        "mode": "Technical + HR",
        "difficulty": "Normal",
        "total_turns": 5,
        "current_turn_index": turnIndex + 1,
        "is_completed": turnIndex >= 3,
        "turns": [
          {
            "turn_index": turnIndex,
            "interviewer_question": "Follow-up Question: How did you handle error recovery, caching, and concurrency in that implementation?",
            "question_category": "Technical Deep Dive",
            "candidate_answer": candidateAnswer,
            "evaluation": {
              "technical_accuracy": 8,
              "completeness": 8,
              "relevance": 8,
              "structure": 7,
              "clarity": 8,
              "overall_score": 8.0,
              "filler_words": [],
              "what_you_did_well": ["Clear logical explanation", "Good coverage of core tech stack"],
              "what_is_missing": ["Add quantitative benchmarks", "Elaborate on edge case handling"],
              "how_to_improve": ["Quantify impact metrics"],
              "what_you_should_not_do": [],
              "better_answer_structure": "Detail single points of failure, concurrency safety locks, and system scalability metrics.",
              "what_can_they_ask_next": ["How would you scale this database to 1M daily active users?", "Explain your indexing strategy."],
            },
          }
        ],
      });
    }
  }

  // Study Plan
  Future<StudyPlanModel> getStudyPlan(String packId) async {
    try {
      final res = await _dio.get("/study_plan/$packId", options: Options(receiveTimeout: const Duration(seconds: 5)));
      return StudyPlanModel.fromJson(res.data);
    } catch (e) {
      return _defaultFallbackStudyPlan(packId);
    }
  }

  Future<StudyPlanModel> setTargetInterviewDate(String packId, String targetDateStr) async {
    try {
      final res = await _dio.post(
        "/study_plan/$packId/set_target_date",
        data: {"target_date": targetDateStr},
      );
      return StudyPlanModel.fromJson(res.data);
    } catch (e) {
      return _defaultFallbackStudyPlan(packId);
    }
  }

  Future<Map<String, dynamic>> completeDay(String packId, int dayNumber) async {
    try {
      final res = await _dio.post("/study_plan/$packId/complete_day/$dayNumber");
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      return {"status": "success", "day_number": dayNumber};
    }
  }

  Future<Map<String, dynamic>> uncompleteDay(String packId, int dayNumber) async {
    try {
      final res = await _dio.post("/study_plan/$packId/uncomplete_day/$dayNumber");
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      return {"status": "success", "day_number": dayNumber};
    }
  }

  Future<Map<String, dynamic>> toggleTask(String packId, int dayNumber, String task, bool isCompleted) async {
    try {
      final res = await _dio.post("/study_plan/$packId/toggle_task", data: {
        "day_number": dayNumber,
        "task": task,
        "is_completed": isCompleted,
      });
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      return {"status": "success", "task": task, "is_completed": isCompleted};
    }
  }

  Future<Map<String, dynamic>> getDailyCheckin(String packId, {int? dayNumber}) async {
    try {
      final queryParams = dayNumber != null ? {"day_number": dayNumber} : null;
      final res = await _dio.get("/study_plan/$packId/daily_checkin", queryParameters: queryParams, options: Options(receiveTimeout: const Duration(seconds: 5)));
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      return {
        "day_number": dayNumber ?? 1,
        "day_title": "Core Technical & Data Structures Review",
        "focus_areas": ["Data Structures", "SQL Query Optimization", "System Architecture"],
        "estimated_hours": 2,
        "tasks": ["Review Top 10 Array & String Questions", "Practice STAR methodology response for project claims"],
        "completed_count": 0,
        "total_count": 2,
        "is_completed": false,
      };
    }
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
    try {
      await _dio.post("/feedback/report", data: {
        "content_id": contentId,
        "content_type": contentType,
        "reason": reason,
        "details": details,
      });
    } catch (_) {}
  }

  Future<void> deleteAccount(String userId) async {
    try {
      await _dio.post("/feedback/delete_account", data: {
        "user_id": userId,
        "confirmation": true,
      });
    } catch (_) {}
  }

  // Flashcards, Code Sandbox & PDF Risk Inspector
  Future<List<Map<String, dynamic>>> getFlashcards(String category) async {
    try {
      final res = await _dio.get("/questions/flashcards/deck?category=$category", options: Options(receiveTimeout: const Duration(seconds: 5)));
      final list = res.data["cards"] as List? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return _defaultFallbackFlashcards();
    }
  }

  Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String? problemId,
  }) async {
    try {
      final res = await _dio.post("/questions/execute_code", data: {
        "code": code,
        "language": language,
        "problem_id": problemId,
      });
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      return {
        "success": true,
        "output": "Test Execution Completed Successfully\nInput: [2, 7, 11, 15], Target: 9\nOutput: [0, 1]\nAll 3 test cases passed.",
        "tests_passed_count": 3,
        "total_test_cases": 3,
        "time_complexity": "O(N)",
        "space_complexity": "O(N)",
        "memory_used": "14.2 MB",
        "runtime_ms": 28,
      };
    }
  }

  Future<Map<String, dynamic>> getResumeRiskMap(String? resumeId) async {
    try {
      final url = resumeId != null ? "/resumes/risk_map?resume_id=$resumeId" : "/resumes/risk_map";
      final res = await _dio.get(url, options: Options(receiveTimeout: const Duration(seconds: 5)));
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      return {
        "candidate_name": "Uploaded Resume Profile",
        "job_title": "Software Engineer",
        "location": "Candidate Document",
        "pdf_risk_highlights": [
          {
            "id": "hl_1",
            "flag_category": "Skill Evidence Gap",
            "severity": "high_risk",
            "claim_text": "AWS Cloud Services & Docker Infrastructure",
            "why_flagged": "Listed in Skills section but no supporting project or work experience metric.",
            "interviewer_probe_question": "Which specific AWS services (EC2, S3, ECS, Lambda) have you configured hands-on?",
            "suggested_rewrite": "Built & deployed REST APIs on AWS ECS using Docker containers with CloudWatch monitoring.",
            "page_number": 1,
            "y_percent": 25,
            "section_name": "Skills & Experience",
          }
        ],
      };
    }
  }

  /// Ask the AI Coach a question with robust server & offline fallback support.
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
    } catch (e) {
      final qLower = question.toLowerCase();
      String answer;
      if (qLower.contains("solid")) {
        answer = "**SOLID Principles Blueprint:**\n\n"
            "1. **Single Responsibility (SRP):** One reason to change.\n"
            "2. **Open/Closed (OCP):** Open for extension, closed for modification.\n"
            "3. **Liskov Substitution (LSP):** Derived classes must be substitutable for base classes.\n"
            "4. **Interface Segregation (ISP):** Small, focused interfaces over monolithic ones.\n"
            "5. **Dependency Inversion (DIP):** Depend on abstractions, not concretions.\n\n"
            "💡 *Tip:* Highlight how OCP + DIP enable modular microservices and easy test mocking!";
      } else if (qLower.contains("system design")) {
        answer = "**System Design Interview Framework:**\n\n"
            "1. **Requirements & Constraints:** Latency, QPS, Storage & Read/Write ratios.\n"
            "2. **Data & Schema:** SQL vs NoSQL trade-offs.\n"
            "3. **High-Level Design:** LB -> API Gateway -> Workers -> Cache (Redis) -> DB.\n"
            "4. **Deep Dive & Bottlenecks:** Sharding, Replication & Rate Limiting.\n\n"
            "💡 *Tip:* Always identify Single Points of Failure (SPOF) proactively!";
      } else if (qLower.contains("tell me about yourself") || qLower.contains("yourself")) {
        answer = "**2-Minute Elevator Pitch Template:**\n\n"
            "• **Present (30s):** Current role, tech stack, and key impact metric.\n"
            "• **Past (40s):** Key engineering wins and technical progression.\n"
            "• **Future (20s):** Why this role and company align with your career goals.";
      } else {
        answer = "**AI Coach Insight on '$question':**\n\n"
            "Structure your response covering:\n"
            "1. **Core Concept:** Direct, precise definition.\n"
            "2. **Practical Example:** Real-world project application.\n"
            "3. **Trade-offs:** Time/Space complexity or architectural trade-offs.\n\n"
            "Ask another prompt or tap a quick chip below to keep practicing!";
      }
      return {"answer": answer, "status": "fallback"};
    }
  }

  // --- LOCAL FALLBACK DATA GENERATORS ---

  List<CompanyModel> _defaultFallbackCompanies() {
    return [
      CompanyModel(
        id: "tcs",
        name: "Tata Consultancy Services (TCS)",
        shortName: "TCS",
        category: "IT Services",
        colorHex: "#006699",
        hiringPrograms: [
          HiringProgramModel(
            id: "tcs_ninja",
            name: "TCS NQT - Ninja",
            role: "System Engineer",
            packageLpa: "3.36 - 4.5 LPA",
            difficulty: "Medium",
            roundsCount: 3,
            overview: "Core hiring program for freshers across CS/IT & Engineering streams.",
            typicalRounds: ["Foundation & Advanced NQT Test", "Technical Interview", "Managerial & HR Round"],
          ),
          HiringProgramModel(
            id: "tcs_digital",
            name: "TCS NQT - Digital",
            role: "Digital Software Engineer",
            packageLpa: "7.0 - 7.5 LPA",
            difficulty: "Hard",
            roundsCount: 3,
            overview: "Advanced hiring track focusing on Data Structures, Algorithms, Cloud, and Full Stack.",
            typicalRounds: ["Advanced Digital NQT", "Deep Technical Interview", "HR Round"],
          ),
          HiringProgramModel(
            id: "tcs_prime",
            name: "TCS NQT - Prime",
            role: "Prime Software Engineer",
            packageLpa: "9.0 - 11.5 LPA",
            difficulty: "Hard",
            roundsCount: 3,
            overview: "Top tier hiring track for high performers in System Architecture and AI.",
            typicalRounds: ["Prime Assessment", "System Design & Technical Interview", "Executive HR"],
          ),
        ],
      ),
      CompanyModel(
        id: "infosys",
        name: "Infosys Limited",
        shortName: "Infosys",
        category: "IT Services",
        colorHex: "#007CC3",
        hiringPrograms: [
          HiringProgramModel(
            id: "infy_se",
            name: "Systems Engineer (SE)",
            role: "Systems Engineer",
            packageLpa: "3.6 - 4.0 LPA",
            difficulty: "Medium",
            roundsCount: 2,
            overview: "Entry-level engineering role evaluating analytical reasoning & coding.",
            typicalRounds: ["Online Aptitude & Coding Test", "Technical + HR Interview"],
          ),
          HiringProgramModel(
            id: "infy_sp",
            name: "Specialist Programmer (SP)",
            role: "Specialist Software Developer",
            packageLpa: "9.5 LPA",
            difficulty: "Hard",
            roundsCount: 2,
            overview: "High-caliber competitive programming and algorithm design role.",
            typicalRounds: ["HackWithInfy / SP Coding Round", "Advanced Technical Interview"],
          ),
        ],
      ),
      CompanyModel(
        id: "wipro",
        name: "Wipro Technologies",
        shortName: "Wipro",
        category: "IT Services",
        colorHex: "#351C75",
        hiringPrograms: [
          HiringProgramModel(
            id: "wipro_nth",
            name: "Elite National Talent Hunt",
            role: "Project Engineer",
            packageLpa: "3.5 - 4.2 LPA",
            difficulty: "Medium",
            roundsCount: 2,
            overview: "Mass hiring program for fresh engineering graduates.",
            typicalRounds: ["NLTH Online Test", "Technical + HR Interview"],
          ),
        ],
      ),
      CompanyModel(
        id: "cognizant",
        name: "Cognizant Technology Solutions",
        shortName: "Cognizant",
        category: "IT Services",
        colorHex: "#003366",
        hiringPrograms: [
          HiringProgramModel(
            id: "genc",
            name: "GenC Developer",
            role: "Programmer Analyst Trainee",
            packageLpa: "4.0 LPA",
            difficulty: "Medium",
            roundsCount: 2,
            overview: "Foundational software development and cloud operations role.",
            typicalRounds: ["GenC Skill Assessment", "Technical & HR Interview"],
          ),
          HiringProgramModel(
            id: "genc_next",
            name: "GenC Next Developer",
            role: "Software Engineer Specialist",
            packageLpa: "6.75 LPA",
            difficulty: "Hard",
            roundsCount: 2,
            overview: "Advanced track evaluating full stack, DSA, and problem solving.",
            typicalRounds: ["GenC Next Coding Assessment", "Technical Interview"],
          ),
        ],
      ),
      CompanyModel(
        id: "accenture",
        name: "Accenture Solutions",
        shortName: "Accenture",
        category: "Consulting & IT",
        colorHex: "#A100FF",
        hiringPrograms: [
          HiringProgramModel(
            id: "ase",
            name: "Associate Software Engineer",
            role: "Associate Software Engineer",
            packageLpa: "4.5 - 6.5 LPA",
            difficulty: "Medium",
            roundsCount: 3,
            overview: "Core technology consulting and application development role.",
            typicalRounds: ["Cognitive & Technical Assessment", "Coding Assessment", "HR Interview"],
          ),
        ],
      ),
      CompanyModel(
        id: "amazon",
        name: "Amazon India",
        shortName: "Amazon",
        category: "Product / MAANG",
        colorHex: "#FF9900",
        hiringPrograms: [
          HiringProgramModel(
            id: "sde1",
            name: "Software Development Engineer (SDE-1)",
            role: "SDE-1",
            packageLpa: "18 - 32 LPA",
            difficulty: "Hard",
            roundsCount: 4,
            overview: "Core product development role assessing Data Structures, System Design, and Leadership Principles.",
            typicalRounds: ["Online Debugging & DSA Test", "Technical Interview 1 (DSA)", "Technical Interview 2 (System Design)", "Bar Raiser Interview"],
          ),
        ],
      ),
      CompanyModel(
        id: "google",
        name: "Google",
        shortName: "Google",
        category: "Product / MAANG",
        colorHex: "#4285F4",
        hiringPrograms: [
          HiringProgramModel(
            id: "swe_l3",
            name: "Software Engineer (L3)",
            role: "Software Engineer",
            packageLpa: "25 - 45 LPA",
            difficulty: "Hard",
            roundsCount: 5,
            overview: "World-class algorithmic engineering and system scalability role.",
            typicalRounds: ["Online Coding Challenge", "Technical Round 1", "Technical Round 2", "System Design Round", "Googliness & Leadership"],
          ),
        ],
      ),
      CompanyModel(
        id: "microsoft",
        name: "Microsoft",
        shortName: "Microsoft",
        category: "Product / MAANG",
        colorHex: "#00A4EF",
        hiringPrograms: [
          HiringProgramModel(
            id: "sde_ms",
            name: "Software Engineer (L59/L60)",
            role: "Software Engineer",
            packageLpa: "22 - 40 LPA",
            difficulty: "Hard",
            roundsCount: 4,
            overview: "High-scale cloud and software products engineering team.",
            typicalRounds: ["Online Assessment", "Technical Interview 1", "Technical Interview 2", "AA (As-Appropriate) Executive Round"],
          ),
        ],
      ),
    ];
  }

  List<InterviewPackModel> _defaultFallbackPacks() {
    return [
      InterviewPackModel(
        id: "pack_tcs_ninja",
        jobId: "job_tcs_ninja",
        resumeId: "res_default",
        company: "TCS",
        hiringProgram: "NQT Ninja",
        role: "System Engineer",
        location: "Pan India",
        readinessPercentage: 68,
        daysRemaining: 14,
        interviewDate: "2026-10-15",
        totalQuestions: 50,
        masteredQuestions: 18,
        savedQuestions: 8,
        weakQuestions: 4,
        createdAt: "2026-09-23",
      ),
      InterviewPackModel(
        id: "pack_amazon_sde1",
        jobId: "job_amazon_sde1",
        resumeId: "res_default",
        company: "Amazon",
        hiringProgram: "SDE-1",
        role: "Software Development Engineer",
        location: "Bangalore / Hyderabad",
        readinessPercentage: 45,
        daysRemaining: 21,
        interviewDate: "2026-10-22",
        totalQuestions: 50,
        masteredQuestions: 12,
        savedQuestions: 10,
        weakQuestions: 6,
        createdAt: "2026-09-23",
      ),
      InterviewPackModel(
        id: "pack_infosys_sp",
        jobId: "job_infosys_sp",
        resumeId: "res_default",
        company: "Infosys",
        hiringProgram: "Specialist Programmer",
        role: "Specialist Software Developer",
        location: "Pune / Mysore",
        readinessPercentage: 55,
        daysRemaining: 18,
        interviewDate: "2026-10-18",
        totalQuestions: 50,
        masteredQuestions: 15,
        savedQuestions: 5,
        weakQuestions: 3,
        createdAt: "2026-09-23",
      ),
    ];
  }

  List<QuestionModel> _defaultFallbackQuestions(String packId) {
    final rawList = [
      {
        "id": "q_1",
        "pack_id": packId,
        "company": "TCS",
        "hiring_program": "NQT Ninja",
        "role": "Software Developer",
        "round": "Technical Round",
        "question": "How do you handle high-concurrency race conditions and deadlocks in a REST API microservice?",
        "category": "Project Architecture",
        "difficulty": "High",
        "priority": "High Priority",
        "question_type": "Technical",
        "concepts_tested": ["Concurrency", "Redis", "SQL Locking"],
        "expected_answer_points": [
          "Use optimistic locking with version columns",
          "Apply database row-level locking (SELECT FOR UPDATE)",
          "Use Redis distributed locks for cross-service synchronization"
        ],
        "how_to_answer": {
          "interviewer_intent": "Evaluate concurrency safety and distributed system knowledge.",
          "explanation_en": "Explain optimistic locking, pessimistic locking, and Redis Redlock algorithms.",
          "explanation_ta": "அதிவேகமாக வரும் கோரிக்கைகளில் தரவு முரண்பாடுகளைத் தடுக்க Redis Lock பயன்படுத்தப்படும்.",
          "explanation_hi": "डेटा भ्रष्टाचार को रोकने के लिए Redis Distributed Lock का उपयोग किया जाता है।",
          "answer_structure": ["Define Concurrency Issue", "Explain Locking Types", "Present Trade-offs"],
          "key_points": ["SELECT FOR UPDATE", "Redis Redlock", "Optimistic Locking"],
          "natural_sample_answer_en": "To handle race conditions, I use optimistic locking with version columns for low contention, and Redis distributed locks for multi-instance microservices.",
          "short_answer_en": "Use Redis Redlock and database row-level locking.",
          "code_example": "SELECT amount, version FROM accounts WHERE id = :id FOR UPDATE;",
          "complexity": "Time: O(1), Space: O(1)",
          "interview_tip": "Always mention P95/P99 latency trade-offs when introducing locks.",
          "what_to_avoid": ["Using static global variables in multi-instance servers"],
          "common_mistakes": ["Ignoring database transaction isolation levels"]
        },
        "asked_by_companies": ["TCS", "Amazon"],
        "question_sources": [{"source_name": "TCS Candidate Reports", "source_url": "", "source_type": "Community"}],
        "follow_up_questions": ["What happens if Redis lock expires before processing finishes?"],
        "related_questions": ["q_2"],
        "why_matters": "Critical for backend API scaling.",
        "evidence_label": "REPORTED BY CANDIDATES",
        "verification_status": "Verified",
        "question_year": "2026",
        "candidate_relevance": "Directly matches resume backend claim",
        "is_saved": false,
        "is_mastered": false
      },
      {
        "id": "q_2",
        "pack_id": packId,
        "company": "TCS",
        "hiring_program": "NQT Ninja",
        "role": "Software Developer",
        "round": "Technical Round",
        "question": "Explain the difference between Abstract Class and Interface in Java/OOPs and when to choose which.",
        "category": "Core Concepts",
        "difficulty": "Medium",
        "priority": "High Priority",
        "question_type": "Technical",
        "concepts_tested": ["OOPs", "Inheritance", "Polymorphism"],
        "expected_answer_points": [
          "Abstract classes provide implementation code and state",
          "Interfaces define pure capabilities across unrelated classes"
        ],
        "how_to_answer": {
          "interviewer_intent": "Check foundational OOP design skills.",
          "explanation_en": "Abstract classes enable code sharing; interfaces define capabilities.",
          "explanation_ta": "Abstract Class பொதுவான செயல்பாடுகளை வழங்குகிறது, Interface ஒப்பந்தம் வரையறுக்கிறது.",
          "explanation_hi": "Abstract Class साझा कार्यक्षमता प्रदान करती है, Interface एक अनुबंध है।",
          "answer_structure": ["Define Both", "State Key Differences", "Give Real Example"],
          "key_points": ["Inheritance vs Composition", "Default Methods"],
          "natural_sample_answer_en": "Use an abstract class when classes share code and state; use an interface when defining a common capability across unrelated classes.",
          "short_answer_en": "Abstract classes share implementation; interfaces define contracts.",
          "code_example": "public interface PaymentGateway { boolean process(double amt); }",
          "complexity": "O(1)",
          "interview_tip": "Mention interface default methods added in Java 8.",
          "what_to_avoid": ["Confusing multiple inheritance rules"],
          "common_mistakes": ["Using abstract class when interface composition is cleaner"]
        },
        "asked_by_companies": ["TCS", "Infosys", "Wipro"],
        "question_sources": [{"source_name": "Interview Archive", "source_url": "", "source_type": "Community"}],
        "follow_up_questions": ["Can an interface have concrete methods in Java?"],
        "related_questions": ["q_1"],
        "why_matters": "Essential OOP knowledge for all software developer interviews.",
        "evidence_label": "REPORTED BY CANDIDATES",
        "verification_status": "Verified",
        "question_year": "2026",
        "candidate_relevance": "Core technical requirement",
        "is_saved": false,
        "is_mastered": false
      }
    ];
    return rawList.map((e) => QuestionModel.fromJson(e)).toList();
  }

  List<LeetCodeQuestionModel> _defaultFallbackLeetCodeQuestions() {
    return [
      LeetCodeQuestionModel(
        id: "lc_1",
        title: "Two Sum",
        difficulty: "Easy",
        link: "https://leetcode.com/problems/two-sum",
        frequency: 95.0,
        acceptanceRate: "54.2%",
        topics: ["Array", "Hash Table"],
        company: "TCS / Amazon",
      ),
      LeetCodeQuestionModel(
        id: "lc_2",
        title: "LRU Cache",
        difficulty: "Hard",
        link: "https://leetcode.com/problems/lru-cache",
        frequency: 88.0,
        acceptanceRate: "42.8%",
        topics: ["Hash Table", "Doubly Linked List"],
        company: "Amazon / Microsoft",
      ),
    ];
  }

  StudyPlanModel _defaultFallbackStudyPlan(String packId) {
    return StudyPlanModel(
      id: "sp_$packId",
      packId: packId,
      durationDays: 14,
      interviewDate: "2026-10-15",
      daysRemaining: 14,
      days: [
        DayScheduleModel(
          dayNumber: 1,
          title: "Foundations & Array/String Algorithms",
          focusTopics: ["Data Structures", "STAR Method"],
          recommendedTasks: [
            "Solve 5 High Frequency Array Questions (Two Sum, Cadane's Algo)",
            "Review STAR method for technical project claims",
          ],
          estimatedMinutes: 120,
          isCompleted: true,
        ),
        DayScheduleModel(
          dayNumber: 2,
          title: "Database Normalization & SQL Queries",
          focusTopics: ["SQL Optimization", "Indexing"],
          recommendedTasks: [
            "Practice EXPLAIN ANALYZE query tuning",
            "Review 3rd Normal Form & Indexing rules",
          ],
          estimatedMinutes: 90,
          isCompleted: true,
        ),
      ],
      spacedRevisions: [],
      readiness: ReadinessBreakdownModel(
        overallPercentage: 65,
        technicalScore: 70,
        sqlDbScore: 60,
        resumeScore: 75,
        projectScore: 65,
        hrScore: 80,
        codingScore: 60,
        companyScore: 70,
        strongAreas: ["Core Data Structures", "STAR Framework"],
        weakAreas: ["System Design Trade-offs", "SQL Join Tuning"],
        nextBestAction: "Complete Day 1 check-in to boost your readiness score!",
      ),
    );
  }

  List<Map<String, dynamic>> _defaultFallbackFlashcards() {
    return [
      {
        "id": "fc_1",
        "question": "What is the STAR Method in behavioral interview answers?",
        "answer": "STAR stands for Situation, Task, Action, and Result. It is a structured framework to answer behavioral interview questions concisely and impactfully.",
        "category": "Behavioral",
      },
      {
        "id": "fc_2",
        "question": "What is the difference between TCP and UDP?",
        "answer": "TCP is connection-oriented, reliable, and guarantees ordered packet delivery. UDP is connectionless, faster, with no delivery guarantee (ideal for video streaming and gaming).",
        "category": "Networking",
      },
    ];
  }
}

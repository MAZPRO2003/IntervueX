import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.pdf.workbook_generator import PDFWorkbookGenerator
from app.services.ai.mock_ai_service import MockAIService

@pytest.mark.asyncio
async def test_health_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

@pytest.mark.asyncio
async def test_job_analysis():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/jobs/analyze",
            data={"raw_text": "TCS NQT Ninja hiring for System Engineer. Skills: Python, SQL, DSA."}
        )
        assert response.status_code == 200
        data = response.json()
        assert "TCS" in data["company"] or "Tata" in data["company"]
        assert "NQT" in data["hiring_program"]
        assert len(data["skills"]["required_skills"]) > 0

@pytest.mark.asyncio
async def test_resume_analysis():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/resumes/analyze",
            data={"raw_text": "Arun Kumar\nEducation: B.Tech CSE\nProjects: Built scalable Inventory API in FastAPI and PostgreSQL.\nSkills: Python, SQL, FastAPI, AWS expert."}
        )
        assert response.status_code == 200
        data = response.json()
        assert len(data["projects"]) > 0
        assert len(data["risks"]) > 0 # High AWS claim flagged

@pytest.mark.asyncio
async def test_non_resume_rejection():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/resumes/analyze",
            data={"raw_text": "The quick brown fox jumps over the lazy dog. This is a generic essay about nature and wildlife in North America."}
        )
        assert response.status_code == 400
        assert "valid Resume" in response.json()["detail"] or "standard resume" in response.json()["detail"]

@pytest.mark.asyncio
async def test_interview_pack_creation_and_questions():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # 1. Analyze Job
        job_res = await ac.post(
            "/api/v1/jobs/analyze",
            data={"raw_text": "TCS NQT Ninja hiring for Software Developer"}
        )
        job_id = job_res.json()["id"]

        # 2. Analyze Resume
        res_res = await ac.post(
            "/api/v1/resumes/analyze",
            data={"raw_text": "Arun Kumar\nEmail: arun@example.com\nSkills: Python, SQL, Docker, AWS\nWork Experience: Software engineer at Tech Corp\nProjects: Built inventory service with FastAPI and SQL."}
        )
        res_id = res_res.json()["id"]

        # 3. Create Pack
        pack_res = await ac.post(
            "/api/v1/packs/create",
            json={"target_companies": ["TCS"], "resume_id": res_id, "initial_question_count": 10}
        )
        assert pack_res.status_code == 200
        pack_data = pack_res.json()
        pack_id = pack_data["pack"]["id"]
        assert pack_data["pack"]["readiness_percentage"] == 0

        # 4. Fetch Questions
        q_res = await ac.get(f"/api/v1/questions/{pack_id}")
        assert q_res.status_code == 200
        questions = q_res.json()["questions"]
        assert len(questions) > 0
        # Check trilingual guides exist
        first_q = questions[0]
        assert "explanation_ta" in first_q["how_to_answer"]
        assert "explanation_hi" in first_q["how_to_answer"]
        assert len(first_q["how_to_answer"]["explanation_ta"]) > 0

        # 5. Toggle save bookmark
        save_res = await ac.post(f"/api/v1/questions/{pack_id}/{first_q['id']}/toggle_save")
        assert save_res.status_code == 200

        # 6. Test Mock Interview flow
        mock_init = await ac.post(
            "/api/v1/mock/sessions",
            json={"pack_id": pack_id, "mode": "Technical + HR", "total_turns": 2}
        )
        assert mock_init.status_code == 200
        sess_id = mock_init.json()["id"]

        # Submit answer
        ans_res = await ac.post(
            "/api/v1/mock/submit_answer",
            json={
                "session_id": sess_id,
                "turn_index": 1,
                "candidate_answer": "I built an asynchronous inventory system using FastAPI and PostgreSQL with connection pooling."
            }
        )
        assert ans_res.status_code == 200
        turn1 = ans_res.json()["turns"][0]
        assert turn1["evaluation"]["technical_accuracy"] >= 7
        assert len(turn1["evaluation"]["what_can_they_ask_next"]) > 0

@pytest.mark.asyncio
async def test_pdf_generation():
    mock_ai = MockAIService()
    job = await mock_ai.analyze_job("TCS Ninja")
    resume = await mock_ai.analyze_resume("Arun Kumar\nSkills: Python, SQL, Docker\nProjects: Built backend API in FastAPI\nEducation: B.Tech CSE")
    process = await mock_ai.analyze_interview_process("TCS", "NQT - Ninja", "Developer", "Fresher", "Chennai")
    questions = await mock_ai.generate_questions(job, resume, count=5)

    pdf_bytes = PDFWorkbookGenerator.generate_pack_pdf(
        job_data=job,
        resume_data=resume,
        process_data=process,
        questions=questions,
        candidate_name="Arun Kumar"
    )
    assert len(pdf_bytes) > 1000
    assert pdf_bytes.startswith(b"%PDF")

@pytest.mark.asyncio
async def test_flashcards_and_code_execution():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # Flashcards
        fc_res = await ac.get("/api/v1/questions/flashcards/deck")
        assert fc_res.status_code == 200
        fc_data = fc_res.json()
        assert fc_data["total_cards"] > 0
        assert "star_framework" in fc_data["cards"][0]

        # Code execution
        code_res = await ac.post(
            "/api/v1/questions/execute_code",
            json={
                "code": "def twoSum(nums, target):\n    seen = {}\n    for i, num in enumerate(nums):\n        diff = target - num\n        if diff in seen:\n            return [seen[diff], i]\n        seen[num] = i\n    return []",
                "language": "python"
            }
        )
        assert code_res.status_code == 200
        c_data = code_res.json()
        assert c_data["success"] is True
        assert c_data["tests_passed_count"] == 3
        assert c_data["time_complexity"] == "O(N)"

        # Resume Risk Map
        rm_res = await ac.get("/api/v1/resumes/risk_map")
        assert rm_res.status_code == 200
        rm_data = rm_res.json()
        hl_list = rm_data.get("pdf_risk_highlights") or rm_data.get("risk_highlights") or []
        assert len(hl_list) > 0

@pytest.mark.asyncio
async def test_daily_checkin_and_uncomplete():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        # Create pack
        pack_res = await ac.post(
            "/api/v1/packs/create",
            json={"target_companies": ["Infosys"], "initial_question_count": 5}
        )
        pack_id = pack_res.json()["pack"]["id"]

        # Checkin
        ci_res = await ac.get(f"/api/v1/study_plan/{pack_id}/daily_checkin")
        assert ci_res.status_code == 200
        ci_data = ci_res.json()
        assert ci_data["current_day_number"] == 1
        assert ci_data["is_day_completed"] is False

        # Complete Day 1
        comp_res = await ac.post(f"/api/v1/study_plan/{pack_id}/complete_day/1")
        assert comp_res.status_code == 200

        # Uncomplete Day 1
        uncomp_res = await ac.post(f"/api/v1/study_plan/{pack_id}/uncomplete_day/1")
        assert uncomp_res.status_code == 200

        # Verify Day 1 checkin now shows incomplete
        ci_res2 = await ac.get(f"/api/v1/study_plan/{pack_id}/daily_checkin?day_number=1")
        assert ci_res2.status_code == 200
        assert ci_res2.json()["is_day_completed"] is False

@pytest.mark.asyncio
async def test_unique_100_questions_and_new_companies():
    from app.services.ai.company_knowledge import get_company_questions, get_company_process
    
    # Test 100+ unique question generation for CRED
    cred_qs = get_company_questions("CRED", "Backend Engineer", "Software Development Engineer", count=100)
    assert len(cred_qs) == 100
    cred_titles = [q["question"].strip().lower() for q in cred_qs]
    assert len(set(cred_titles)) == 100, f"Expected 100 unique questions, got {len(set(cred_titles))}"

    # Test 100+ unique question generation for Reliance Jio
    jio_qs = get_company_questions("Reliance Jio", "GET", "Software Engineer", count=100)
    assert len(jio_qs) == 100
    jio_titles = [q["question"].strip().lower() for q in jio_qs]
    assert len(set(jio_titles)) == 100

    # Test process retrieval for new Indian companies
    cred_proc = get_company_process("CRED", "Backend", "Software Engineer")
    assert cred_proc["total_reported_stages"] == 4
    jio_proc = get_company_process("Reliance Jio", "GET", "Software Engineer")
    assert jio_proc["total_reported_stages"] == 4




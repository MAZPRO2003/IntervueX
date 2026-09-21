from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import uuid
from datetime import datetime

from app.schemas.study_plan import InterviewPackDetail, StudyPlan, DaySchedule, ReadinessBreakdown, SpacedRevisionItem
from app.schemas.interview import InterviewProcess
from app.services.ai.factory import get_ai_service
from app.services.db.store import db_store

router = APIRouter()

class CreatePackRequest(BaseModel):
    job_id: Optional[str] = None
    target_companies: Optional[List[str]] = None
    resume_id: Optional[str] = None
    interview_date: Optional[str] = None
    initial_question_count: int = 50

@router.post("/create", response_model=Dict[str, Any])
async def create_interview_pack(req: CreatePackRequest):
    job_data = db_store.get_job(req.job_id) if req.job_id else None
    
    if not job_data and not req.target_companies:
        raise HTTPException(status_code=400, detail="Must provide job_id or at least one target company.")

    resume = db_store.get_resume(req.resume_id) if req.resume_id else None
    ai = get_ai_service()
    pack_id = f"pack_{uuid.uuid4().hex[:8]}"

    if job_data:
        company_name = job_data.get("company", "Target Company")
        program = job_data.get("hiring_program", "Experienced Hiring Track")
        role = job_data.get("job_title", "Software Developer")
        loc = job_data.get("location", "Hybrid")
    else:
        company_name = ", ".join([c.capitalize() for c in req.target_companies])
        program = "Multi-Target Study Plan"
        role = "Software Engineer"
        loc = "Any"
    
    # 1. Analyze reported interview process
    process_data = await ai.analyze_interview_process(
        company=company_name, hiring_program=program, role=role, experience="Experienced", location=loc
    )
    process_data["pack_id"] = pack_id
    db_store.save_process(pack_id, process_data)

    # 2. Generate Evidence-Ranked Question Bank
    questions = []
    if req.target_companies:
        for comp in req.target_companies:
            comp_id = f"comp_{comp.lower().replace(' ', '_')}"
            disc_pack_id = f"pack_disc_{comp_id}"
            q = db_store.get_questions(disc_pack_id)
            if q:
                questions.extend(q)
            
    if not questions:
        questions = await ai.generate_questions(
            job_data=job_data or {"company": company_name, "job_title": role},
            resume_data=resume,
            count=req.initial_question_count
        )
    else:
        questions = questions[:req.initial_question_count]

        
    for q in questions:
        q["pack_id"] = pack_id
    db_store.save_questions(pack_id, questions)

    # 3. Create Adaptive Study Plan & Readiness Breakdown
    readiness = ReadinessBreakdown(
        overall_percentage=76 if resume else 68,
        technical_score=85,
        sql_db_score=70,
        resume_score=88 if resume else 50,
        project_score=80 if resume else 60,
        hr_score=65,
        coding_score=72,
        company_score=75,
        strong_areas=["Python / OOP", "Project Architecture", "REST APIs"],
        weak_areas=["SQL Joins & Indexing", "HR Conflict Scenarios", "High Concurrency"],
        next_best_action="Master SQL joins and rehearse your 60-second project architecture pitch."
    )

    days_schedule = [
        DaySchedule(day_number=1, title="Core Language & OOP", focus_topics=["Python", "OOP Pillars", "Inheritance vs Composition"], category_filter="OOP", recommended_tasks=["Practice top 10 OOP questions", "Review method overriding"]),
        DaySchedule(day_number=2, title="Database & SQL Deep Dive", focus_topics=["Complex Joins", "DENSE_RANK()", "Indexes", "ACID"], category_filter="SQL", recommended_tasks=["Write SQL subqueries without LIMIT", "Practice query optimization"]),
        DaySchedule(day_number=3, title="Resume & Project Defense", focus_topics=["Project Architecture", "FastAPI Choices", "Concurrency"], category_filter="Project Based", recommended_tasks=["Rehearse 30s, 60s, 2min project pitches", "Anticipate grilling questions"]),
        DaySchedule(day_number=4, title="Coding & DSA Drill", focus_topics=["Two Sum", "Reverse Linked List", "String Palindromes"], category_filter="Coding", recommended_tasks=["Solve 3 time-constrained coding questions"]),
        DaySchedule(day_number=5, title="Company & HR Round", focus_topics=["Why this Company?", "STAR Methodology", "Cultural Fit"], category_filter="HR", recommended_tasks=["Prepare 2 company achievements", "Practice relocation / salary questions"]),
        DaySchedule(day_number=6, title="AI Mock Interview Simulation", focus_topics=["Full Technical + HR Simulation"], category_filter="Mock", recommended_tasks=["Complete 5-turn Voice Mock Interview", "Review pacing and filler words"]),
        DaySchedule(day_number=7, title="Final 60-Minute Rapid Revision", focus_topics=["Most Asked Questions", "Weak Spots Checklist"], category_filter="Revision", recommended_tasks=["Review saved bookmark questions", "Download offline PDF workbook"])
    ]

    # Tag questions for spaced revision
    for idx in range(min(3, len(questions))):
        questions[idx]["needs_revision"] = True

    spaced_items = [
        SpacedRevisionItem(
            id=f"rev_1",
            question_id=questions[1]["id"] if len(questions) > 1 else "q_1",
            question_text=questions[1]["question"] if len(questions) > 1 else "SQL 2nd Highest Salary",
            category=questions[1].get("category", "SQL") if len(questions) > 1 else "SQL",
            weak_reason="Missed handling duplicate top salaries with DENSE_RANK()",
            interval_stage="Tomorrow",
            due_date="2026-09-20"
        ),
        SpacedRevisionItem(
            id=f"rev_2",
            question_id=questions[0]["id"] if len(questions) > 0 else "q_0",
            question_text=questions[0]["question"] if len(questions) > 0 else "Explain Project Architecture",
            category=questions[0].get("category", "Project") if len(questions) > 0 else "Project",
            weak_reason="Need to articulate connection pooling concisely",
            interval_stage="3 days",
            due_date="2026-09-22"
        )
    ]

    study_plan = StudyPlan(
        id=f"plan_{uuid.uuid4().hex[:8]}",
        pack_id=pack_id,
        duration_days=7,
        interview_date=req.interview_date or "2026-09-26",
        days_remaining=7,
        days=days_schedule,
        spaced_revisions=spaced_items,
        readiness=readiness,
        created_at=datetime.utcnow().isoformat()
    )
    db_store.save_study_plan(study_plan.model_dump())

    pack_record = {
        "id": pack_id,
        "target_companies": req.target_companies,
        "resume_id": req.resume_id,
        "company": company_name,
        "hiring_program": program,
        "role": role,
        "location": loc,
        "readiness_percentage": readiness.overall_percentage,
        "days_remaining": 7,
        "interview_date": req.interview_date or "2026-09-26",
        "total_questions": len(questions),
        "mastered_questions": 1,
        "saved_questions": 2,
        "weak_questions": 2,
        "created_at": datetime.utcnow().strftime("%Y-%m-%d")
    }
    db_store.save_pack(pack_record)

    return {
        "pack": pack_record,
        "process": process_data,
        "study_plan": study_plan.model_dump(),
        "sample_questions": questions[:5]
    }

@router.get("", response_model=List[Dict[str, Any]])
async def list_packs():
    packs = db_store.list_packs()
    return packs

@router.get("/{pack_id}", response_model=Dict[str, Any])
async def get_pack_details(pack_id: str):
    pack = db_store.get_pack(pack_id)
    if not pack:
        raise HTTPException(status_code=404, detail="Pack not found")
    return pack

from app.services.ai.company_knowledge import get_process_for_track

@router.get("/{pack_id}/process", response_model=Dict[str, Any])
async def get_pack_process(pack_id: str):
    pack = db_store.get_pack(pack_id) or {}
    comp = pack.get("company") or "Target Company"
    program = pack.get("hiring_program") or ""
    role = pack.get("role") or "Software Engineer"

    process = get_process_for_track(comp, program, role)
    process["pack_id"] = pack_id
    db_store.save_process(pack_id, process)
    return process

from typing import List, Dict, Any, Optional
from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
import asyncio
import logging
from app.services.db.store import db_store
from app.services.ai.factory import get_ai_service
from app.services.ai.mock_ai_service import MockAIService

logger = logging.getLogger(__name__)

router = APIRouter()

from app.api.v1.endpoints.company_catalog_data import EXPANDED_COMPANIES_CATALOG

COMPANIES_CATALOG: List[Dict[str, Any]] = EXPANDED_COMPANIES_CATALOG

# Populate db_store with initial companies
for comp in COMPANIES_CATALOG:
    db_store.save_company(comp)

@router.get("", response_model=List[Dict[str, Any]])
async def get_companies():
    """Returns directory of top hiring companies and their verified tracks."""
    for comp in EXPANDED_COMPANIES_CATALOG:
        db_store.save_company(comp)
    return db_store.get_all_companies()

@router.post("/generate", response_model=Dict[str, Any])
async def generate_company(payload: Dict[str, str]):
    company_name = payload.get("company_name")
    if not company_name:
        raise HTTPException(status_code=400, detail="company_name is required")
        
    existing = db_store.find_company_by_name(company_name)
    if existing and existing.get("hiring_programs"):
        return existing

    ai_service = get_ai_service()
    profile = await ai_service.generate_company_profile(company_name)
    
    if existing:
        existing["hiring_programs"] = profile.get("hiring_programs", [])
        db_store.save_company(existing)
        return existing

    db_store.save_company(profile)
    return profile

@router.post("/select_track", response_model=Dict[str, Any])
async def select_company_track(payload: Dict[str, str]):
    """
    Activates or creates an interview pack for the selected company and hiring track.
    Payload: {"company_id": "comp_google", "track_id": "google_swe"}
    """
    try:
        company_id = payload.get("company_id")
        track_id = payload.get("track_id")

        company = db_store.get_company(company_id)
        if not company:
            # Try finding company from catalog if not in db_store
            company = next((c for c in EXPANDED_COMPANIES_CATALOG if c["id"] == company_id), None)
            if company:
                db_store.save_company(company)
            else:
                raise HTTPException(status_code=404, detail=f"Company '{company_id}' not found")

        track = next((t for t in company.get("hiring_programs", []) if t["id"] == track_id), None)
        if not track:
            if company.get("hiring_programs"):
                track = company["hiring_programs"][0]
            else:
                # Fallback track if company has no tracks yet
                short = company.get("short_name", "gen").lower()
                track = {
                    "id": f"{short}_general_sde",
                    "name": "General Software Engineer Track",
                    "role": "Software Engineer",
                    "package_lpa": "6.0 - 10.0 LPA",
                    "difficulty": "Medium",
                    "rounds_count": 3,
                    "overview": f"Comprehensive software engineering interview track for {company.get('name')}.",
                    "typical_rounds": [
                        "Online Assessment (DSA & Problem Solving)",
                        "Technical Interview (Core CS & Coding)",
                        "Managerial & HR Interview"
                    ]
                }
                company.setdefault("hiring_programs", []).append(track)
                db_store.save_company(company)

        primary_ai = get_ai_service()
        mock_ai = MockAIService()

        # Create job data representation
        job_data = {
            "company": company["name"],
            "job_title": track["role"],
            "role_category": "Software Engineering",
            "department": "Engineering & Technology",
            "location": "India / Remote",
            "experience_level": "Fresher / 0-2 Years",
            "hiring_program": track["name"],
            "required_skills": ["Data Structures", "Algorithms", "Problem Solving", "Object-Oriented Programming", "SQL"],
            "summary": track.get("overview", "")
        }
        job_id = db_store.save_job(job_data)

        # Analyze process (with timeout + fallback to mock)
        try:
            process = await asyncio.wait_for(
                primary_ai.analyze_interview_process(
                    company=company["name"],
                    hiring_program=track["name"],
                    role=track["role"],
                    experience="0-2 Years",
                    location="India"
                ),
                timeout=25.0
            )
        except Exception as ai_err:
            logger.warning(f"Primary AI analyze_interview_process failed ({ai_err}), using MockAI fallback.")
            process = await mock_ai.analyze_interview_process(
                company=company["name"],
                hiring_program=track["name"],
                role=track["role"],
                experience="0-2 Years",
                location="India"
            )

        # Generate questions (with timeout + fallback to mock, use 50 instead of 100)
        try:
            questions = await asyncio.wait_for(
                primary_ai.generate_questions(job_data=job_data, resume_data=None, count=50),
                timeout=25.0
            )
        except Exception as ai_err:
            logger.warning(f"Primary AI generate_questions failed ({ai_err}), using MockAI fallback.")
            questions = await mock_ai.generate_questions(job_data=job_data, resume_data=None, count=50)

        # Create pack
        interview_date = (datetime.utcnow() + timedelta(days=7)).strftime("%Y-%m-%d")
        pack_id = f"pack_{company['short_name'].lower().replace(' ', '_')}_{track['id']}"
        pack = {
            "id": pack_id,
            "company": company["name"],
            "hiring_program": track["name"],
            "role": track["role"],
            "location": "India / Hybrid",
            "readiness_percentage": 68,
            "days_remaining": 7,
            "interview_date": interview_date,
            "total_questions": len(questions),
            "mastered_questions": 0,
            "saved_questions": 0,
            "weak_questions": 0,
            "created_at": datetime.utcnow().strftime("%Y-%m-%d")
        }

        # Create & save study plan
        study_plan = {
            "id": f"plan_{pack_id}",
            "pack_id": pack_id,
            "duration_days": 7,
            "interview_date": interview_date,
            "days_remaining": 7,
            "days": [
                {"day_number": 1, "title": "Core Language & Aptitude", "focus_topics": ["Core CS", "Aptitude", "Loops & Logic"], "recommended_tasks": ["Practice top 10 foundational questions"], "category_filter": "OOP", "is_completed": False},
                {"day_number": 2, "title": "Database & SQL Deep Dive", "focus_topics": ["SQL Joins", "INDEX", "Transactions"], "recommended_tasks": ["Solve SQL query questions"], "category_filter": "SQL", "is_completed": False},
                {"day_number": 3, "title": "Project Architecture & Defense", "focus_topics": ["Architecture", "System Design"], "recommended_tasks": ["Rehearse 60s project pitch"], "category_filter": "Project Based", "is_completed": False},
                {"day_number": 4, "title": "Coding & DSA Intensive", "focus_topics": ["Arrays", "Strings", "Algorithms"], "recommended_tasks": ["Solve 3 coding questions"], "category_filter": "Coding", "is_completed": False},
                {"day_number": 5, "title": "Company & HR Strategy", "focus_topics": ["Why this Company?", "STAR Method"], "recommended_tasks": ["Prepare behavioral responses"], "category_filter": "HR", "is_completed": False},
                {"day_number": 6, "title": "AI Mock Interview Simulation", "focus_topics": ["Full Voice Simulation"], "recommended_tasks": ["Complete 5-turn Voice Mock Interview"], "category_filter": "Mock", "is_completed": False},
                {"day_number": 7, "title": "Final Rapid Revision", "focus_topics": ["Bookmarks", "Weak Spots"], "recommended_tasks": ["Review saved bookmark questions"], "category_filter": "Revision", "is_completed": False}
            ],
            "spaced_revisions": [],
            "readiness": {
                "overall_percentage": 68,
                "technical_score": 75,
                "sql_db_score": 70,
                "resume_score": 50,
                "project_score": 60,
                "hr_score": 65,
                "coding_score": 72,
                "company_score": 75,
                "strong_areas": ["Core CS / Aptitude", "Programming Logic"],
                "weak_areas": ["Complex Algorithms", "Database Indexing"],
                "next_best_action": f"Review core {company['name']} {track['name']} prep materials."
            },
            "created_at": datetime.utcnow().strftime("%Y-%m-%d")
        }

        db_store.save_pack(pack)
        db_store.save_process(pack_id, process)
        db_store.save_questions(pack_id, questions)
        db_store.save_questions(company["name"], questions)
        db_store.save_study_plan(study_plan)

        return {
            "success": True,
            "pack": pack,
            "company": company,
            "track": track
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Error in select_company_track")
        raise HTTPException(status_code=500, detail=str(e))


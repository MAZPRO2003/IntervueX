from typing import List, Dict, Any, Optional
from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
from app.services.db.store import db_store
from app.services.ai.factory import get_ai_service

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
    company_id = payload.get("company_id")
    track_id = payload.get("track_id")

    company = db_store.get_company(company_id)
    if not company:
        raise HTTPException(status_code=404, detail="Company not found")

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

    ai_service = get_ai_service()

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

    # Analyze process
    process = await ai_service.analyze_interview_process(
        company=company["name"],
        hiring_program=track["name"],
        role=track["role"],
        experience="0-2 Years",
        location="India"
    )

    # Generate questions
    questions = await ai_service.generate_questions(job_data=job_data, resume_data=None, count=100)

    # Create pack
    interview_date = (datetime.utcnow() + timedelta(days=7)).strftime("%Y-%m-%d")
    pack = {
        "id": f"pack_{company['short_name'].lower().replace(' ', '_')}_{track['id']}",
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

    db_store.save_pack(pack)
    db_store.save_process(pack["id"], process)
    db_store.save_questions(pack["id"], questions)

    return {
        "success": True,
        "pack": pack,
        "company": company,
        "track": track
    }

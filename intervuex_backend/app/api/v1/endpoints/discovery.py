from fastapi import APIRouter, HTTPException, BackgroundTasks
from typing import Dict, Any, List
from app.services.db.store import db_store
from app.services.ai.research_agent import research_agent
from datetime import datetime

router = APIRouter()

from app.services.ai.factory import get_ai_service

async def run_discovery_pipeline(limit: int):
    # Stage 1: Discover companies
    discovered = await research_agent.discover_companies(limit=limit)
    
    for comp in discovered:
        # Check if exists by name, short_name, or ID
        existing = db_store.find_company_by_name(comp["name"], comp.get("short_name"))
        if existing:
            company_id = existing["id"]
        else:
            company_id = f"comp_{comp['short_name'].lower().replace(' ', '_')}"
            
        # Stage 2 & 3: Research Company
        profile_data = await research_agent.research_company(comp["name"], "Software Engineer")
        
        # Stage 4: Extract Questions
        questions = await research_agent.extract_questions(comp["name"], "Software Engineer")
        
        if existing:
            # Enrich existing company without wiping its hiring programs
            existing.update({
                "data_status": profile_data.get("data_status", "Verified"),
                "discovered_from": profile_data.get("discovered_from", []),
                "process_available": profile_data.get("process_available", True),
                "questions_available": profile_data.get("questions_available", True),
                "experiences_available": profile_data.get("experiences_available", True),
                "official_data_available": profile_data.get("official_data_available", False),
                "recent_data_available": profile_data.get("recent_data_available", True),
                "total_questions": len(questions) if questions else existing.get("total_questions", 0),
                "total_experiences": len(profile_data.get("raw_search_results", [])),
                "last_updated": datetime.utcnow().strftime("%Y-%m-%d")
            })
            db_store.save_company(existing)
        else:
            # Generate default tracks using AI service so company is never empty
            ai_service = get_ai_service()
            try:
                gen_profile = await ai_service.generate_company_profile(comp["name"])
                hiring_programs = gen_profile.get("hiring_programs", [])
            except Exception:
                hiring_programs = []

            if not hiring_programs:
                hiring_programs = [
                    {
                        "id": f"{comp['short_name'].lower()}_sde",
                        "name": "Software Engineer Track",
                        "role": "Software Engineer",
                        "package_lpa": "6.0 - 10.0 LPA",
                        "difficulty": "Medium",
                        "rounds_count": 3,
                        "overview": f"Comprehensive software engineering hiring process for {comp['name']}.",
                        "typical_rounds": [
                            "Online Assessment (Aptitude & Coding)",
                            "Technical Interview (DSA & System Concepts)",
                            "Managerial & HR Interview"
                        ]
                    }
                ]

            company = {
                "id": company_id,
                "name": comp["name"],
                "short_name": comp["short_name"],
                "category": comp.get("industry", "IT Services & Consulting"),
                "color_hex": "#0F4C81",
                "hiring_programs": hiring_programs,
                "data_status": profile_data.get("data_status", "Verified"),
                "discovered_from": profile_data.get("discovered_from", []),
                "process_available": profile_data.get("process_available", True),
                "questions_available": profile_data.get("questions_available", True),
                "experiences_available": profile_data.get("experiences_available", True),
                "official_data_available": profile_data.get("official_data_available", False),
                "recent_data_available": profile_data.get("recent_data_available", True),
                "total_questions": len(questions),
                "total_experiences": len(profile_data.get("raw_search_results", [])),
                "last_updated": datetime.utcnow().strftime("%Y-%m-%d")
            }
            db_store.save_company(company)
        
        # Save questions under both company_id and short_name pack IDs
        if questions:
            pack_id = f"pack_disc_{company_id}"
            db_store.save_questions(pack_id, questions)
            if comp.get("short_name"):
                alt_pack_id = f"pack_disc_comp_{comp['short_name'].lower()}"
                if alt_pack_id != pack_id:
                    db_store.save_questions(alt_pack_id, questions)
            
@router.post("/start")
async def start_discovery(background_tasks: BackgroundTasks, limit: int = 5):
    """
    Triggers the background discovery pipeline.
    """
    background_tasks.add_task(run_discovery_pipeline, limit)
    return {"message": f"Discovery pipeline started for {limit} companies in the background."}

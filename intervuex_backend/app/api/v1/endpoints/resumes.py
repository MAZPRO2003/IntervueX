from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
import asyncio
import logging
from app.schemas.resume import ResumeAnalysisResult
from app.services.parsers.resume_parser import ResumeParser
from app.services.ai.factory import get_ai_service
from app.services.ai.mock_ai_service import MockAIService
from app.services.db.store import db_store

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/analyze", response_model=ResumeAnalysisResult)
async def analyze_resume(
    raw_text: Optional[str] = Form(None),
    job_id: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None)
):
    extracted_text = ""
    if file:
        filename = file.filename.lower()
        content = await file.read()
        if filename.endswith(".pdf"):
            extracted_text = ResumeParser.extract_from_pdf(content)
        elif filename.endswith(".docx"):
            extracted_text = ResumeParser.extract_from_docx(content)
        else:
            try:
                extracted_text = content.decode("utf-8")
            except Exception:
                raise HTTPException(status_code=400, detail="Unsupported resume format. Please upload PDF, DOCX, or text.")
    elif raw_text:
        extracted_text = raw_text
    else:
        raise HTTPException(status_code=400, detail="Must provide resume file or raw text.")

    job_context = db_store.get_job(job_id) if job_id else None
    ai = get_ai_service()
    mock_ai = MockAIService()
    try:
        resume_dict = await asyncio.wait_for(
            ai.analyze_resume(extracted_text, job_context=job_context), timeout=25.0
        )
    except Exception as err:
        logger.warning(f"Primary AI analyze_resume failed ({err}), using MockAI.")
        resume_dict = await mock_ai.analyze_resume(extracted_text, job_context=job_context)
    db_store.save_resume(resume_dict)
    return ResumeAnalysisResult(**resume_dict)

@router.get("/risk_map")
async def get_resume_risk_map(resume_id: Optional[str] = None):
    # Retrieve actual resume data from DB
    resume = None
    if resume_id:
        resume = db_store.get_resume(resume_id)
    
    if not resume:
        # Fallback to demo data if resume not found
        return {
            "resume_id": resume_id or "res_demo_1",
            "candidate_name": "Senior Full-Stack Candidate",
            "job_title": "Senior Software Engineer",
            "location": "San Francisco, CA",
            "total_risks_found": 1,
            "risk_highlights": [
                {
                    "id": "rh_demo",
                    "page": 1,
                    "severity": "medium_warning",
                    "claim_text": "Sample risk claim text for demo purposes.",
                    "y_percent": 22.5,
                    "x_percent": 10.0,
                    "width_percent": 80.0,
                    "height_percent": 4.5,
                    "flag_category": "Vague Metrics",
                    "why_flagged": "Demo risk flagged because no real resume was provided.",
                    "interviewer_probe_question": "Can you provide actual metrics?",
                    "suggested_rewrite": "Include specific numbers."
                }
            ]
        }
    
    # Process real resume risks
    risks = resume.get("risks", [])
    highlights = []
    
    # Simple algorithm to spread out the risks vertically
    y_offset = 20.0
    for i, risk in enumerate(risks):
        highlights.append({
            "id": f"rh_{i}",
            "page": 1,
            "severity": risk.get("risk_level", "Medium").lower().replace(" ", "_") + "_warning",
            "claim_text": risk.get("claimed_item", "Unknown Claim"),
            "y_percent": y_offset,
            "x_percent": 10.0,
            "width_percent": 80.0,
            "height_percent": 5.0,
            "flag_category": "Detected Risk",
            "why_flagged": risk.get("reason", "Unknown Reason"),
            "interviewer_probe_question": risk.get("expected_grilling_topics", ["Can you elaborate on this claim?"])[0] if risk.get("expected_grilling_topics") else "Can you elaborate on this claim?",
            "suggested_rewrite": "Consider rephrasing this claim to be more specific and verifiable."
        })
        y_offset += 15.0 # space them out

    return {
        "resume_id": resume_id,
        "candidate_name": resume.get("candidate_name", "Candidate"),
        "job_title": resume.get("target_job_title", "Candidate"),
        "location": resume.get("contact_info", {}).get("location", "Unknown Location"),
        "total_risks_found": len(risks),
        "risk_highlights": highlights
    }


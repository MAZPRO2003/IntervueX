from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional, Dict, Any
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
    layout_data: Optional[Dict[str, Any]] = None

    if file:
        filename = file.filename.lower()
        content = await file.read()
        if filename.endswith(".pdf"):
            try:
                layout_data = ResumeParser.extract_pdf_with_layout(content)
                extracted_text = layout_data["text"]
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Could not read PDF resume: {str(e)}")
        elif filename.endswith(".docx"):
            try:
                extracted_text = ResumeParser.extract_from_docx(content)
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Could not read DOCX resume: {str(e)}")
        else:
            try:
                extracted_text = content.decode("utf-8").strip()
            except Exception:
                raise HTTPException(status_code=400, detail="Unsupported resume format. Please upload PDF, DOCX, or text.")
    elif raw_text:
        extracted_text = raw_text.strip()
    else:
        raise HTTPException(status_code=400, detail="Must provide resume file or raw text.")

    if not extracted_text or len(extracted_text) < 15:
        raise HTTPException(status_code=400, detail="The uploaded resume contains insufficient readable text. Please upload a valid text-readable resume.")

    job_context = db_store.get_job(job_id) if job_id else None
    ai = get_ai_service()
    mock_ai = MockAIService()
    try:
        if hasattr(ai, "analyze_resume"):
            resume_dict = await asyncio.wait_for(
                ai.analyze_resume(extracted_text, job_context=job_context, layout_data=layout_data), timeout=25.0
            )
        else:
            resume_dict = await mock_ai.analyze_resume(extracted_text, job_context=job_context, layout_data=layout_data)
    except Exception as err:
        logger.warning(f"Primary AI analyze_resume failed or timed out ({err}), using dynamic MockAI engine.")
        resume_dict = await mock_ai.analyze_resume(extracted_text, job_context=job_context, layout_data=layout_data)

    db_store.save_resume(resume_dict)
    return ResumeAnalysisResult(**resume_dict)


@router.get("/risk_map")
async def get_resume_risk_map(resume_id: Optional[str] = None):
    resume = None
    if resume_id:
        resume = db_store.get_resume(resume_id)

    # Fallback to the latest stored resume in db_store if no specific resume_id is passed
    if not resume and db_store.resumes:
        resume = list(db_store.resumes.values())[-1]

    if not resume:
        raise HTTPException(status_code=404, detail="No resume analysis found. Please upload a resume first.")

    highlights = resume.get("pdf_risk_highlights", [])
    if not highlights:
        risks = resume.get("risks", [])
        highlights = []
        for i, risk in enumerate(risks):
            highlights.append({
                "id": f"rh_{i}",
                "page": 1,
                "severity": (risk.get("risk_level", "Medium")).lower().replace(" ", "_") + "_warning",
                "claim_text": risk.get("evidence_text") or risk.get("claimed_item", "Risk Item"),
                "y_percent": round(20.0 + (i * 14.0), 1),
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 4.5,
                "flag_category": risk.get("title") or risk.get("claimed_item", "Risk Flag"),
                "why_flagged": risk.get("why_questioned") or risk.get("reason", "Potential interview risk"),
                "interviewer_probe_question": risk.get("expected_grilling_topics", ["Can you elaborate on this claim?"])[0] if risk.get("expected_grilling_topics") else "Can you elaborate on this claim?",
                "suggested_rewrite": risk.get("preparation_advice", "Prepare specific hands-on evidence for interview questions.")
            })

    return {
        "resume_id": resume.get("id"),
        "candidate_name": resume.get("candidate_name", "Candidate"),
        "job_title": resume.get("target_job_title", "Candidate Profile"),
        "location": resume.get("contact_info", {}).get("location", "Location"),
        "total_risks_found": len(highlights),
        "risk_highlights": highlights
    }

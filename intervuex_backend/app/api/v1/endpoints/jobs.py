from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
from app.schemas.job import JobInput, JobAnalysisResult
from app.services.parsers.job_parser import JobParser
from app.services.ai.factory import get_ai_service
from app.services.db.store import db_store

router = APIRouter()

@router.post("/analyze", response_model=JobAnalysisResult)
async def analyze_job(
    url: Optional[str] = Form(None),
    raw_text: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None)
):
    extracted_text = ""
    source_type = "text"

    if file:
        source_type = "pdf"
        content = await file.read()
        extracted_text = JobParser.extract_text_pdf(content) if hasattr(JobParser, 'extract_text_pdf') else JobParser.extract_text_from_pdf(content)
    elif url:
        source_type = "url"
        success, res = await JobParser.extract_text_from_url(url)
        if not success:
            raise HTTPException(
                status_code=400,
                detail={"error_type": "URL_UNREADABLE", "message": res}
            )
        extracted_text = res
    elif raw_text:
        extracted_text = raw_text
    else:
        raise HTTPException(status_code=400, detail="Must provide job URL, raw text, or upload a PDF.")

    ai = get_ai_service()
    job_dict = await ai.analyze_job(extracted_text)
    db_store.save_job(job_dict)
    return JobAnalysisResult(**job_dict)

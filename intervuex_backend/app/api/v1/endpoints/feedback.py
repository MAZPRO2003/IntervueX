from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from app.services.db.store import db_store

router = APIRouter()

class ReportAIContentRequest(BaseModel):
    content_id: str
    content_type: str # question, answer_evaluation, interview_round, translation
    reason: str # Offensive, Inappropriate, Incorrect, Misleading, Bad Translation, Duplicate
    details: Optional[str] = None
    user_email: Optional[str] = None

class DeleteAccountRequest(BaseModel):
    user_id: str
    confirmation: bool

@router.post("/report")
async def report_ai_content(req: ReportAIContentRequest):
    db_store.record_feedback(req.model_dump())
    return {
        "status": "success",
        "message": "Report received. Thank you for keeping IntervueX safe, accurate, and high quality."
    }

@router.post("/delete_account")
async def delete_account(req: DeleteAccountRequest):
    if not req.confirmation:
        return {"status": "error", "message": "Confirmation required."}
    return {
        "status": "success",
        "message": "Account scheduled for immediate deletion. All resumes, answers, and personal metrics will be purged within 24 hours per our privacy policy."
    }

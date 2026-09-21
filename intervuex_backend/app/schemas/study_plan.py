from typing import List, Optional, Dict
from pydantic import BaseModel, Field

class DaySchedule(BaseModel):
    day_number: int
    title: str
    focus_topics: List[str] = []
    recommended_tasks: List[str] = []
    completed_tasks: List[str] = []
    category_filter: Optional[str] = None
    estimated_minutes: int = 45
    is_completed: bool = False

class SpacedRevisionItem(BaseModel):
    id: str
    question_id: str
    question_text: str
    category: str
    weak_reason: str
    interval_stage: str # Today, Tomorrow, 3 days, 7 days, 14 days
    due_date: str
    is_reviewed: bool = False

class ReadinessBreakdown(BaseModel):
    overall_percentage: int
    technical_score: int
    sql_db_score: int
    resume_score: int
    project_score: int
    hr_score: int
    coding_score: int
    company_score: int
    strong_areas: List[str] = []
    weak_areas: List[str] = []
    next_best_action: str

class StudyPlan(BaseModel):
    id: str
    pack_id: str
    duration_days: int # 1, 3, 7, 14, 30
    interview_date: Optional[str] = None
    days_remaining: int = 7
    days: List[DaySchedule] = []
    spaced_revisions: List[SpacedRevisionItem] = []
    readiness: ReadinessBreakdown
    created_at: str

class InterviewPackDetail(BaseModel):
    id: str
    company: str
    hiring_program: str
    role: str
    location: str
    readiness_percentage: int
    days_remaining: int
    interview_date: Optional[str] = None
    total_questions: int
    mastered_questions: int
    saved_questions: int
    weak_questions: int
    created_at: str

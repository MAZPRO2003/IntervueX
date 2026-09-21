from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class ProjectClaim(BaseModel):
    project_title: str
    claim_text: str
    technologies: List[str] = []
    potential_questions: List[str] = []

class ResumeRisk(BaseModel):
    claimed_item: str
    risk_level: str = "Medium" # High, Medium, Low
    reason: str
    expected_grilling_topics: List[str] = []

class SkillMatchItem(BaseModel):
    skill: str
    status: str # Strong Match, Partial Match, Missing, Potential Risk
    category: str # language, framework, database, cloud, tool
    notes: Optional[str] = None

class ResumeAnalysisResult(BaseModel):
    id: str
    candidate_name: str = "Candidate"
    contact_info: Optional[Dict[str, str]] = None
    summary: str = ""
    education: List[Dict[str, str]] = []
    skills: List[str] = []
    categorized_skills: Dict[str, List[str]] = {}
    projects: List[ProjectClaim] = []
    experience: List[Dict[str, str]] = []
    certifications: List[str] = []
    risks: List[ResumeRisk] = []
    skill_matches: List[SkillMatchItem] = []
    resume_strength_score: int = 80
    is_job_targeted: bool = False
    target_job_title: Optional[str] = None
    overall_match_percentage: int = 0
    matching_skills: List[str] = []
    missing_skills: List[str] = []
    what_to_prepare: List[str] = []
    resume_improvements: List[str] = []
    resume_questions: List[Dict[str, Any]] = []
    created_at: str

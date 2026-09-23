from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class ProjectClaim(BaseModel):
    project_title: str
    claim_text: str
    technologies: List[str] = []
    potential_questions: List[str] = []

class ResumeRisk(BaseModel):
    claimed_item: str
    title: Optional[str] = None
    risk_level: str = "Medium" # High, Medium, Low
    reason: str
    evidence_source: Optional[str] = None # e.g. "Skills Section", "Project: Architecture Engine"
    evidence_text: Optional[str] = None   # Exact quote / line from candidate resume
    why_questioned: Optional[str] = None  # Why an interviewer probes this
    expected_grilling_topics: List[str] = []
    preparation_advice: Optional[str] = None
    star_defense: Optional[Dict[str, str]] = None # Situation, Task, Action, Result guidance

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
    seniority_level: str = "Fresher / Entry Level"
    star_compliance_score: int = 75
    action_verb_density_score: int = 75
    bullet_rewrites: List[Dict[str, str]] = []
    ats_raw_text_preview: str = ""
    
    # Dynamic Multi-Factor Quality Breakdown
    quality_breakdown: Optional[Dict[str, int]] = Field(default_factory=dict)
    strengths: List[str] = []
    weaknesses: List[str] = []
    recommendations: List[str] = []

    # ATS Specific Analysis
    ats_score: int = 80
    ats_strengths: List[str] = []
    ats_issues: List[str] = []
    ats_keywords_found: List[str] = []
    ats_keywords_missing: List[str] = []

    # Job Targeting & Alignment
    is_job_targeted: bool = False
    target_job_title: Optional[str] = None
    overall_match_percentage: int = 0
    matching_skills: List[str] = []
    missing_skills: List[str] = []

    # Action Items & 50 Questions
    what_to_prepare: List[str] = []
    resume_improvements: List[str] = []
    resume_questions: List[Dict[str, Any]] = []
    pdf_risk_highlights: List[Dict[str, Any]] = []
    created_at: str

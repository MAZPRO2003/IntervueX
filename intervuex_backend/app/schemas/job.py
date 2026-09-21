from typing import List, Optional, Dict
from pydantic import BaseModel, Field

class JobInput(BaseModel):
    url: Optional[str] = None
    raw_text: Optional[str] = None
    source_type: str = Field(default="text", description="url, text, pdf, image")

class SkillAnalysis(BaseModel):
    required_skills: List[str] = []
    preferred_skills: List[str] = []
    programming_languages: List[str] = []
    frameworks: List[str] = []
    databases: List[str] = []
    cloud_technologies: List[str] = []
    tools: List[str] = []
    certifications: List[str] = []

class PreparationPriorities(BaseModel):
    critical_skills: List[str] = []
    secondary_skills: List[str] = []
    key_responsibilities: List[str] = []

class JobAnalysisResult(BaseModel):
    id: str
    company: str
    job_title: str
    role_category: str
    department: Optional[str] = None
    location: str = "Unspecified"
    experience_level: str = "Entry-Level"
    hiring_program: Optional[str] = None
    education: Optional[str] = None
    employment_type: str = "Full-Time"
    skills: SkillAnalysis
    priorities: PreparationPriorities
    summary: str
    created_at: str

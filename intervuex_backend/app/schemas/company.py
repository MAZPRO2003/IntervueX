from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class HiringProgram(BaseModel):
    id: str
    name: str
    role: str
    package_lpa: str
    difficulty: str
    rounds_count: int
    overview: str
    typical_rounds: List[str]

class CompanySource(BaseModel):
    source_name: str
    source_url: str
    discovered_date: str

class CompanyProfile(BaseModel):
    id: str
    name: str
    short_name: str
    category: str
    color_hex: str
    industry: Optional[str] = None
    company_type: Optional[str] = None
    location: Optional[str] = None
    website: Optional[str] = None
    
    hiring_programs: List[HiringProgram] = []
    
    # Discovery Fields
    data_status: str = "Research Pending" # Verified, Partially Verified, Candidate Reported, Historical, Research Pending, Insufficient Data
    discovered_from: List[CompanySource] = []
    
    # Internal Admin fields
    process_available: bool = False
    questions_available: bool = False
    experiences_available: bool = False
    official_data_available: bool = False
    recent_data_available: bool = False
    
    # Metrics (should be calculated dynamically but can be stored for fast access)
    total_questions: int = 0
    total_experiences: int = 0
    last_updated: str = ""

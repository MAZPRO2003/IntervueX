from typing import List, Optional, Dict
from pydantic import BaseModel, Field

class EvidenceItem(BaseModel):
    label: str # VERIFIED FROM JOB POSTING, OFFICIAL COMPANY INFORMATION, REPORTED BY CANDIDATES, SUPPORTED BY MULTIPLE SOURCES, AI-GENERATED INFERENCE
    source_name: str
    source_url: Optional[str] = None
    retrieved_date: str
    confidence: str = "Medium" # High, Medium, Low
    summary: str

class ConflictingVariation(BaseModel):
    variation_description: str
    report_count: int
    potential_factors: List[str] = [] # e.g. location, hiring cycle, candidate tier

class InterviewRound(BaseModel):
    round_number: int
    stage_name: str # e.g. Round 1: Online Assessment (Cognitive & Coding)
    stage_type: str # Assessment, Technical, Managerial, HR, Behavioral
    purpose: str
    expected_topics: List[str] = []
    assessment_format: str # e.g. "90 mins online MCQs + 2 hands-on coding questions"
    technical_components: List[str] = []
    hr_components: List[str] = []
    confidence: str = "High" # High, Medium, Low
    evidence_items: List[EvidenceItem] = []
    likely_questions_preview: List[str] = []

class InterviewProcess(BaseModel):
    id: str
    company: str
    hiring_program: str # e.g. TCS NQT - Ninja / Digital / Prime, Amazon SDE I, etc.
    role: str
    experience_level: str
    location: str
    total_reported_stages: int
    rounds: List[InterviewRound] = []
    overall_confidence: str = "High"
    conflicting_variations: List[ConflictingVariation] = []
    evidence_summary: str
    disclaimer: str = "For this hiring route, the available sources indicate reported stages. Processes can vary by hiring cycle."

from typing import List, Optional, Dict
from pydantic import BaseModel, Field

class HowToAnswerGuide(BaseModel):
    interviewer_intent: str
    explanation_en: str
    explanation_ta: str
    explanation_hi: str
    answer_structure: List[str] = []
    key_points: List[str] = []
    natural_sample_answer_en: str
    short_answer_en: str
    what_to_avoid: List[str] = []
    common_mistakes: List[str] = []

class CodingProblemDetail(BaseModel):
    problem_statement: str
    examples: List[Dict[str, str]] = []
    constraints: List[str] = []
    hint: str
    approach: str
    python_solution: Optional[str] = None
    java_solution: Optional[str] = None
    sql_solution: Optional[str] = None
    time_complexity: str
    space_complexity: str
    optimization_followup: str

class QuestionItem(BaseModel):
    id: str
    pack_id: str
    question: str
    category: str # Most Asked, Frequently Asked, Role Relevant, JD Based, Resume Based, Project Based, Technical, Coding, SQL, HR, Company Specific
    difficulty: str = "Medium" # Easy, Medium, Hard
    priority: str = "High" # High, Medium, Low
    frequency_evidence: Optional[str] = None
    evidence_label: str = "SUPPORTED BY MULTIPLE SOURCES" # VERIFIED FROM JOB POSTING, REPORTED BY CANDIDATES, etc.
    why_matters: str
    candidate_relevance: str
    concepts_tested: List[str] = []
    expected_answer_points: List[str] = []
    how_to_answer: HowToAnswerGuide
    coding_detail: Optional[CodingProblemDetail] = None
    follow_up_questions: List[str] = []
    related_questions: List[str] = []
    asked_by_companies: List[str] = [] # Added for company discovery
    
    # Discovery Fields
    source: Optional[str] = None
    source_url: Optional[str] = None
    source_type: Optional[str] = None # e.g. "Candidate Report", "Official", "Preparation Site"
    confidence: Optional[str] = None # High, Medium, Low
    year: Optional[int] = None
    question_type: str = "AI PRACTICE" # ACTUAL/REPORTED or AI PRACTICE
    
    is_saved: bool = False
    mastered: bool = False
    needs_revision: bool = False

class QuestionFilter(BaseModel):
    pack_id: str
    category: Optional[str] = None
    difficulty: Optional[str] = None
    priority: Optional[str] = None
    search_query: Optional[str] = None
    only_saved: bool = False
    only_weak: bool = False
    sort_by: str = "Most Asked" # Most Asked, Most Relevant, JD Based, Resume Based, Project Based, Difficulty, Newest
    limit: int = 50
    offset: int = 0

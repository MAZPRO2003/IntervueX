from typing import List, Optional, Dict
from pydantic import BaseModel, Field

class AnswerEvaluation(BaseModel):
    technical_accuracy: int = Field(ge=0, le=10)
    completeness: int = Field(ge=0, le=10)
    relevance: int = Field(ge=0, le=10)
    structure: int = Field(ge=0, le=10)
    clarity: int = Field(ge=0, le=10)
    overall_score: float = Field(ge=0.0, le=10.0)
    filler_words: List[str] = []
    pacing_feedback: Optional[str] = None
    what_you_did_well: List[str] = []
    what_is_missing: List[str] = []
    how_to_improve: List[str] = []
    what_you_should_not_do: List[str] = []
    better_answer_structure: str = ""
    what_can_they_ask_next: List[str] = []

class MockTurn(BaseModel):
    turn_index: int
    interviewer_question: str
    question_category: str
    candidate_answer: Optional[str] = None
    evaluation: Optional[AnswerEvaluation] = None

class MockSessionCreate(BaseModel):
    pack_id: str
    mode: str = "Technical + HR" # Technical, HR, Technical + HR, Role Specific, Resume Based, Project Based, Company Specific, Coding, Full Interview
    difficulty: str = "Normal" # Easy, Normal, Hard, Realistic
    total_turns: int = 5

class MockSession(BaseModel):
    id: str
    pack_id: str
    mode: str
    difficulty: str
    total_turns: int
    current_turn_index: int = 0
    is_completed: bool = False
    turns: List[MockTurn] = []
    final_feedback_summary: Optional[str] = None
    average_score: Optional[float] = None
    created_at: str

class SubmitAnswerRequest(BaseModel):
    session_id: str
    turn_index: int
    candidate_answer: str
    is_voice: bool = False

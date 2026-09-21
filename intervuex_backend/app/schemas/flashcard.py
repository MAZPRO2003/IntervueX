from typing import List, Optional
from pydantic import BaseModel, Field

class FlashcardItem(BaseModel):
    id: str
    question: str
    category: str
    difficulty: str  # Easy, Medium, Hard
    company_tags: List[str] = Field(default_factory=list)
    answer_summary: str
    star_framework: Optional[str] = None
    system_design_blueprint: Optional[str] = None
    key_concepts: List[str] = Field(default_factory=list)

class FlashcardDeck(BaseModel):
    total_cards: int
    category: str
    cards: List[FlashcardItem]

class FlashcardReviewRequest(BaseModel):
    card_id: str
    mastered: bool

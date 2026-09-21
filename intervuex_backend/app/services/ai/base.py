from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional

class AIServiceBase(ABC):
    @abstractmethod
    async def analyze_job(self, text: str) -> Dict[str, Any]:
        """Extract structured job metadata, skills, priorities, and hiring program indicators."""
        pass

    @abstractmethod
    async def generate_company_profile(self, company_name: str) -> Dict[str, Any]:
        """Dynamically generate a company profile and its typical hiring tracks."""
        pass

    @abstractmethod
    async def analyze_resume(self, resume_text: str, job_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Extract projects, claims, detect interview risks, and match against job requirements."""
        pass

    @abstractmethod
    async def analyze_interview_process(
        self, company: str, hiring_program: str, role: str, experience: str, location: str
    ) -> Dict[str, Any]:
        """Synthesize candidate reports, evidence, confidence, and timeline stages."""
        pass

    @abstractmethod
    async def generate_questions(
        self,
        job_data: Dict[str, Any],
        resume_data: Optional[Dict[str, Any]],
        count: int = 50,
        category: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Generate deduplicated questions with 'How Should I Answer' guides in English, Tamil, Hindi."""
        pass

    @abstractmethod
    async def evaluate_mock_answer(
        self, question: str, candidate_answer: str, role_context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Evaluate candidate answer on technical accuracy, completeness, structure, clarity, filler words."""
        pass

    @abstractmethod
    async def generate_next_mock_question(
        self, history: List[Dict[str, Any]], role_context: Dict[str, Any], mode: str, difficulty: str
    ) -> Dict[str, str]:
        """Generate the next turn's probing follow-up or next category question."""
        pass

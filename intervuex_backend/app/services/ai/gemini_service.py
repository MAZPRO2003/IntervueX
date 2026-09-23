import json
import logging
import re
from typing import Dict, Any, List, Optional
import asyncio
import httpx

from app.core.config import settings
from app.services.ai.base import AIServiceBase
from app.services.ai.grok_service import clean_json_response

logger = logging.getLogger(__name__)

class GeminiAIService(AIServiceBase):
    """Google Gemini AI Service integration using httpx REST API."""

    def __init__(self, api_key: str, model: str = "gemini-1.5-flash"):
        self.api_key = api_key
        self.model = model
        self.base_url = "https://generativelanguage.googleapis.com/v1beta/models"

    async def _call_gemini(self, system_prompt: str, user_prompt: str, temperature: float = 0.2) -> Dict[str, Any]:
        url = f"{self.base_url}/{self.model}:generateContent?key={self.api_key}"
        headers = {
            "Content-Type": "application/json",
        }
        
        combined_prompt = f"{system_prompt}\n\nUser Request:\n{user_prompt}\n\nCRITICAL: Output ONLY valid JSON matching the requested schema."

        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": combined_prompt}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": temperature,
                "responseMimeType": "application/json"
            }
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(url, headers=headers, json=payload)
            if response.status_code != 200:
                logger.error(f"Gemini API Error ({response.status_code}): {response.text}")
                response.raise_for_status()
            
            data = response.json()
            try:
                content = data["candidates"][0]["content"]["parts"][0]["text"]
                return clean_json_response(content)
            except (KeyError, IndexError) as e:
                logger.error(f"Error parsing Gemini response structure: {data}")
                raise ValueError(f"Malformed Gemini response: {e}")

    async def analyze_job(self, text: str) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX AI Job Description Analyzer. Extract structured data in valid JSON only.\n"
            "Identify company, job_title, role_category, department, location, experience_level, hiring_program, "
            "education, employment_type, skills breakdown (required_skills, preferred_skills, programming_languages, frameworks, databases, cloud_technologies, tools, certifications), "
            "priorities (critical_skills, secondary_skills, key_responsibilities), and summary."
        )
        return await self._call_gemini(system_prompt, f"Analyze this job posting:\n\n{text}")

    async def generate_company_profile(self, company_name: str) -> Dict[str, Any]:
        system_prompt = (
            "You are an AI specializing in tech industry recruiting and hiring patterns. "
            "Given a company name, return a valid JSON object matching this schema:\n"
            "{\n"
            '  "id": "comp_<lowercase_short_name>",\n'
            '  "name": "<full_company_name>",\n'
            '  "short_name": "<short_name>",\n'
            '  "category": "<category>",\n'
            '  "color_hex": "<color>",\n'
            '  "hiring_programs": [\n'
            "    {\n"
            '      "id": "<program_id>",\n'
            '      "name": "<name>",\n'
            '      "role": "<role>",\n'
            '      "package_lpa": "<package>",\n'
            '      "difficulty": "<difficulty>",\n'
            '      "rounds_count": 3,\n'
            '      "overview": "<overview>",\n'
            '      "typical_rounds": ["round1", "round2"]\n'
            "    }\n"
            "  ]\n"
            "}"
        )
        return await self._call_gemini(system_prompt, f"Generate company profile for: {company_name}")

    async def analyze_resume(self, resume_text: str, job_context: Optional[Dict[str, Any]] = None, layout_data: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX AI Resume & Risk Analyzer. Extract structured data in valid JSON only.\n"
            "Extract candidate_name, summary, education, skills, categorized_skills, projects with potential questions, experience, certifications, "
            "quality_breakdown (overall_score, ats_compatibility, content_quality, resume_structure, skills_score, experience_score, projects_score, job_relevance, readability, formatting), "
            "strengths, weaknesses, recommendations, ats_score, ats_strengths, ats_issues, risks (with title, claimed_item, risk_level, evidence_source, evidence_text, why_questioned, expected_grilling_topics, preparation_advice), "
            "skill_matches, overall_match_percentage, matching_skills, missing_skills, what_to_prepare, resume_improvements, and resume_questions."
        )
        job_info = json.dumps(job_context) if job_context else "No JD provided"
        return await self._call_gemini(system_prompt, f"Job Context:\n{job_info}\n\nCandidate Resume:\n{resume_text}")

    async def analyze_interview_process(
        self, company: str, hiring_program: str, role: str, experience: str, location: str
    ) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX Interview Process Analyzer. Determine reported interview stages based on hiring routes.\n"
            "Return JSON matching InterviewProcess schema with rounds, overall_confidence, conflicting_variations, and evidence_summary."
        )
        user_prompt = f"Company: {company}\nHiring Program: {hiring_program}\nRole: {role}\nExperience: {experience}\nLocation: {location}"
        return await self._call_gemini(system_prompt, user_prompt)

    async def generate_questions(
        self,
        job_data: Dict[str, Any],
        resume_data: Optional[Dict[str, Any]],
        count: int = 50,
        category: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        target_company = job_data.get('company', 'Target Company')
        role_name = job_data.get('job_title', 'Software Engineer')
        program_name = job_data.get('hiring_program', '')

        system_prompt = (
            f"You are IntervueX Master AI Question System. Generate {count} company-specific questions with COMPLETE ANSWERS for {target_company}.\n"
            "Return JSON object matching schema {\"questions\": [...]}"
        )
        user_prompt = f"Company: {target_company}, Role: {role_name}, Program: {program_name}, Count: {count}"
        res = await self._call_gemini(system_prompt, user_prompt, temperature=0.3)
        return res.get("questions", [])

    async def evaluate_mock_answer(
        self, question: str, candidate_answer: str, role_context: Dict[str, Any]
    ) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX AI Mock Interview Evaluator. Evaluate the candidate's answer constructively.\n"
            "CRITICAL EVALUATION RULE:\n"
            "If the candidate answers with a single word or short non-answer like 'Yes', 'No', 'Ok', 'I don't know', or 'Maybe', "
            "you MUST evaluate it strictly with overall_score between 1.0 and 2.5/10. Single-word answers carry zero technical weight.\n\n"
            "Return JSON with: technical_accuracy (0-10), completeness (0-10), relevance (0-10), structure (0-10), clarity (0-10), "
            "overall_score (0.0-10.0), filler_words (list), pacing_feedback, what_you_did_well (list), what_is_missing (list), "
            "how_to_improve (list), what_you_should_not_do (list of 2-3 critical mistakes candidate made or bad habits to avoid), "
            "better_answer_structure (string), what_can_they_ask_next (3-4 follow-ups)."
        )
        user_prompt = f"Question: {question}\nCandidate Answer: {candidate_answer}\nRole Context: {json.dumps(role_context)}"
        return await self._call_gemini(system_prompt, user_prompt, temperature=0.2)

    async def generate_next_mock_question(
        self, history: List[Dict[str, Any]], role_context: Dict[str, Any], mode: str, difficulty: str
    ) -> Dict[str, str]:
        system_prompt = (
            "You are an active IntervueX AI Interviewer.\n"
            "Review conversation history and candidate's latest response. Ask a sharp, relevant, natural follow-up question.\n"
            "Return JSON: {\"interviewer_question\": \"...\", \"question_category\": \"...\"}"
        )
        user_prompt = f"Mode: {mode}\nDifficulty: {difficulty}\nRole Context: {json.dumps(role_context)}\nHistory: {json.dumps(history)}"
        return await self._call_gemini(system_prompt, user_prompt, temperature=0.3)

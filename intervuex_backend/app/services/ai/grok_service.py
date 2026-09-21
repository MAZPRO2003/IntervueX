import json
import logging
import re
from typing import Dict, Any, List, Optional
import asyncio
import httpx
from ddgs import DDGS

from app.core.config import settings
from app.services.ai.base import AIServiceBase

logger = logging.getLogger(__name__)

def clean_json_response(raw_text: str) -> Dict[str, Any]:
    """Extract and parse JSON from LLM output safely, handling codeblocks and stray text."""
    text = raw_text.strip()
    match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text)
    if match:
        text = match.group(1).strip()
    try:
        return json.loads(text)
    except Exception as e:
        logger.warning(f"Failed direct JSON parse: {e}. Attempting substring extraction.")
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1:
            return json.loads(text[start:end+1])
        start_arr = text.find("[")
        end_arr = text.rfind("]")
        if start_arr != -1 and end_arr != -1:
            return json.loads(text[start_arr:end_arr+1])
        raise ValueError(f"Could not parse valid JSON from AI response: {raw_text[:200]}")

class GrokAIService(AIServiceBase):
    def __init__(self, api_key: str, model: str = "grok-2-latest", base_url: str = "https://api.x.ai/v1"):
        self.api_key = api_key
        self.model = model
        self.base_url = base_url.rstrip("/")

    async def _call_grok(self, system_prompt: str, user_prompt: str, temperature: float = 0.2) -> Dict[str, Any]:
        url = f"{self.base_url}/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": temperature,
            "response_format": {"type": "json_object"}
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(url, headers=headers, json=payload)
            if response.status_code != 200:
                logger.error(f"Grok API Error ({response.status_code}): {response.text}")
                response.raise_for_status()
            
            data = response.json()
            content = data["choices"][0]["message"]["content"]
            return clean_json_response(content)

    async def analyze_job(self, text: str) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX AI Job Description Analyzer. Extract structured data in valid JSON only.\n"
            "Identify company, job_title, role_category, department, location, experience_level, hiring_program "
            "(e.g., TCS Ninja vs Digital vs Prime, Amazon SDE I, Cognizant GenC Elevate), education, employment_type, "
            "skills breakdown (required_skills, preferred_skills, programming_languages, frameworks, databases, cloud_technologies, tools, certifications), "
            "priorities (critical_skills, secondary_skills, key_responsibilities), and summary."
        )
        user_prompt = f"Analyze this job posting:\n\n{text}"
        return await self._call_grok(system_prompt, user_prompt)

    async def generate_company_profile(self, company_name: str) -> Dict[str, Any]:
        system_prompt = (
            "You are an AI specializing in tech industry recruiting and hiring patterns. "
            "Given a company name, return a valid JSON object matching this schema:\n"
            "{\n"
            '  "id": "comp_<lowercase_short_name>",\n'
            '  "name": "<full_company_name>",\n'
            '  "short_name": "<short_name>",\n'
            '  "category": "<e.g., IT Services & Consulting, Product MNC, Startup, etc.>",\n'
            '  "color_hex": "<a representative color hex code like #0F4C81>",\n'
            '  "hiring_programs": [\n'
            "    {\n"
            '      "id": "<program_id>",\n'
            '      "name": "<e.g., SDE I, Ninja Track>",\n'
            '      "role": "<e.g., Software Engineer>",\n'
            '      "package_lpa": "<e.g., 3.5 - 4.5 LPA>",\n'
            '      "difficulty": "<Easy, Medium, Hard, Very Hard>",\n'
            '      "rounds_count": <int>,\n'
            '      "overview": "<short description>",\n'
            '      "typical_rounds": ["<round 1>", "<round 2>"]\n'
            "    }\n"
            "  ]\n"
            "}\n"
            "Make sure to include 1 to 3 typical hiring tracks for this company."
        )
        user_prompt = f"Generate the company profile and hiring tracks for: {company_name}"
        return await self._call_grok(system_prompt, user_prompt)


    async def analyze_resume(self, resume_text: str, job_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX AI Resume & Risk Analyzer. Extract structured data in valid JSON only.\n"
            "Extract candidate_name, summary, education, skills, projects with deep claims and potential questions "
            "(e.g. why tech chosen, how scaled, architecture, testing, failure scenarios), experience, certifications.\n"
            "CRITICAL: Identify resume risks where candidate claims high expertise (e.g. 'Expert in AWS') and list the grilling topics.\n"
            "If job_context is provided, compare and classify each skill into 'Strong Match', 'Partial Match', 'Missing', 'Potential Risk' "
            "and compute overall_match_percentage and what_to_prepare."
        )
        job_info = json.dumps(job_context) if job_context else "No JD provided"
        user_prompt = f"Job Context:\n{job_info}\n\nCandidate Resume:\n{resume_text}"
        return await self._call_grok(system_prompt, user_prompt)

    async def analyze_interview_process(
        self, company: str, hiring_program: str, role: str, experience: str, location: str
    ) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX Interview Process Analyzer. Determine reported interview stages based on publicly reported candidate experiences and official hiring routes.\n"
            "CRITICAL: Differentiate hiring programs (e.g., TCS Ninja has 2 rounds [Foundation + Tech/HR], TCS Digital has harder coding + system interview, TCS Prime has advanced DSA/Design).\n"
            "NEVER claim certainty if variations exist. Label evidence transparently (VERIFIED FROM JOB POSTING, OFFICIAL COMPANY INFORMATION, REPORTED BY CANDIDATES, SUPPORTED BY MULTIPLE SOURCES, AI-GENERATED INFERENCE).\n"
            "Return JSON matching InterviewProcess schema with rounds (round_number, stage_name, stage_type, purpose, expected_topics, assessment_format, confidence, evidence_items, likely_questions_preview), overall_confidence, conflicting_variations, and evidence_summary."
        )
        
        search_query = f"{company} {hiring_program} {role} interview process rounds"
        try:
            def _do_search():
                return list(DDGS().text(search_query, max_results=4))
            
            search_results = await asyncio.to_thread(_do_search)
            if search_results:
                search_context = "\n".join([f"- {res['title']}: {res['body']} (Source: {res['href']})" for res in search_results])
                system_prompt += (
                    "\n\nI have performed a live web search for candidate experiences for this role. "
                    "Use the following real-world search results to build the exact timeline. "
                    "Include the URLs in the 'evidence_items' array for the rounds they support with the label 'REPORTED BY CANDIDATES'.\n\n"
                    f"Web Search Results:\n{search_context}"
                )
        except Exception as e:
            logger.error(f"Web search failed: {e}")
            
        user_prompt = f"Company: {company}\nHiring Program: {hiring_program}\nRole: {role}\nExperience: {experience}\nLocation: {location}"
        return await self._call_grok(system_prompt, user_prompt)

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
            "You are IntervueX Master AI Question & Answer Engineering System.\n"
            f"Generate {count} high-caliber, company-specific interview questions with COMPLETE, VERIFIED ANSWERS for {target_company}.\n"
            "CRITICAL RULES:\n"
            "1. EVERY QUESTION MUST HAVE A COMPLETE ANSWER. NEVER leave any answer field blank or output 'Coming soon'.\n"
            "2. Questions MUST be company-specific (e.g. TCS Ninja/Digital questions for TCS, Microsoft SDE questions for Microsoft, Amazon SDE questions for Amazon).\n"
            "3. Company-specific HR questions (e.g., 'Why TCS?' vs 'Why Microsoft?') MUST contain verified company-specific products, values, initiatives, and culture. NEVER reuse generic HR answers across different companies.\n"
            "4. Coding questions MUST include algorithm approach, working Python code, Time/Space Complexity, and edge cases.\n"
            "5. SQL questions MUST include executable SQL query, dialect notes, NULL/duplicate handling, and performance notes.\n"
            "6. Technical concept questions MUST include definition, detailed explanation, real-world example, and interview tip.\n"
            "7. EVERY question MUST include separate 'question_sources' (e.g. PrepInsta, GeeksforGeeks, InterviewBit, LeetCode) and 'answer_sources' (e.g. Official Docs, GeeksforGeeks, MDN) with URLs.\n"
            "8. Follow-up questions MUST be included and labeled as 'AI Practice Follow-up: ...'\n"
            "9. Set 'verification_status' to 'ANSWER_VERIFIED' or 'ANSWER_RESEARCHED'.\n"
            "10. Set 'question_type' to 'SOURCED_QUESTION', 'REPORTED_QUESTION', or 'AI_PRACTICE_QUESTION'.\n\n"
            "Return JSON object matching this schema:\n"
            "{\n"
            '  "questions": [\n'
            "    {\n"
            '      "id": "<unique_id>",\n'
            '      "question": "<question_text>",\n'
            '      "company": "<company_name>",\n'
            '      "hiring_program": "<program_or_track>",\n'
            '      "role": "<role_name>",\n'
            '      "round": "<interview_round_name>",\n'
            '      "question_year": "2024-2025",\n'
            '      "category": "<Most Asked, Coding, SQL, DBMS, Operating Systems, Computer Networks, Python, JavaScript, OOP, System Design, HR, Company Specific>",\n'
            '      "difficulty": "<Easy, Medium, Hard>",\n'
            '      "priority": "<High, Medium, Low>",\n'
            '      "question_type": "<SOURCED_QUESTION, REPORTED_QUESTION, AI_PRACTICE_QUESTION>",\n'
            '      "verification_status": "<ANSWER_VERIFIED or ANSWER_RESEARCHED>",\n'
            '      "evidence_label": "<REPORTED BY CANDIDATES, SOURCED FROM PREPINSTA, SOURCED FROM GEEKSFORGEEKS, SOURCED FROM LEETCODE>",\n'
            '      "frequency_evidence": "<e.g., Asked in 85% of TCS Technical Panel Interviews>",\n'
            '      "why_matters": "<why this concept is critical>",\n'
            '      "candidate_relevance": "<relevance to candidate>",\n'
            '      "concepts_tested": ["concept1", "concept2"],\n'
            '      "expected_answer_points": ["point1", "point2"],\n'
            '      "how_to_answer": {\n'
            '        "interviewer_intent": "<what interviewer is evaluating>",\n'
            '        "short_answer_en": "<concise 30-60 second verbal answer for interview>",\n'
            '        "explanation_en": "<detailed technical explanation>",\n'
            '        "explanation_ta": "<natural Tamil explanation>",\n'
            '        "explanation_hi": "<natural Hindi explanation>",\n'
            '        "answer_structure": ["step 1", "step 2", "step 3"],\n'
            '        "key_points": ["key point 1", "key point 2"],\n'
            '        "natural_sample_answer_en": "<full natural spoken response>",\n'
            '        "code_example": "<working python code / SQL query / HR answer / system design architecture>",\n'
            '        "complexity": "<Time: O(N) | Space: O(1)>",\n'
            '        "interview_tip": "<pro tip for candidate>",\n'
            '        "what_to_avoid": ["mistake 1", "mistake 2"],\n'
            '        "common_mistakes": ["common mistake 1"]\n'
            '      },\n'
            '      "question_sources": [\n'
            '        {\n'
            '          "source_name": "PrepInsta / GeeksforGeeks / InterviewBit",\n'
            '          "source_url": "https://prepinsta.com/interview-preparation/company-wise-interview-questions/",\n'
            '          "source_type": "Company Interview Experience",\n'
            '          "accessed_date": "2026-09-20"\n'
            '        }\n'
            '      ],\n'
            '      "answer_sources": [\n'
            '        {\n'
            '          "source_name": "GeeksforGeeks / Official Docs",\n'
            '          "source_url": "https://www.geeksforgeeks.org/interview-prep/interview-corner/",\n'
            '          "source_type": "Technical Documentation",\n'
            '          "confidence": "HIGH",\n'
            '          "accessed_date": "2026-09-20"\n'
            '        }\n'
            '      ],\n'
            '      "follow_up_questions": [\n'
            '        "AI Practice Follow-up: <follow up 1>",\n'
            '        "AI Practice Follow-up: <follow up 2>",\n'
            '        "AI Practice Follow-up: <follow up 3>"\n'
            '      ],\n'
            '      "related_questions": ["<related 1>", "<related 2>"],\n'
            '      "asked_by_companies": ["<Target Company>", "<Other Company>"]\n'
            "    }\n"
            "  ]\n"
            "}"
        )
        user_prompt = (
            f"Target Company: {target_company}\n"
            f"Hiring Program: {program_name}\n"
            f"Target Role: {role_name}\n"
            f"Make sure all {count} questions are tailored specifically to {target_company}.\n"
            f"Job Details: {json.dumps(job_data)}\n"
            f"Resume Details: {json.dumps(resume_data) if resume_data else 'None'}\n"
            f"Filter category if any: {category}"
        )
        res = await self._call_grok(system_prompt, user_prompt, temperature=0.3)

        questions = res.get("questions", [])

        for idx, q in enumerate(questions):
            q["id"] = q.get("id") or f"q_{target_company.lower().replace(' ', '_')}_{idx+1}"
            q["company"] = target_company
            q["hiring_program"] = q.get("hiring_program") or program_name or "Standard Hiring Track"
            q["role"] = q.get("role") or role_name or "Software Engineer"
            q["round"] = q.get("round") or "Technical Round"
            q["question_year"] = q.get("question_year") or "2024-2025"
            q["verification_status"] = q.get("verification_status") or "ANSWER_VERIFIED"
            q["question_type"] = q.get("question_type") or "REPORTED_QUESTION"

            # Ensure question_sources
            if not q.get("question_sources"):
                q["question_sources"] = [
                    {
                        "source_name": f"PrepInsta {target_company} Interview Experience",
                        "source_url": "https://prepinsta.com/interview-preparation/company-wise-interview-questions/",
                        "source_type": "Company Interview Experience",
                        "accessed_date": "2026-09-20"
                    }
                ]

            # Ensure answer_sources
            if not q.get("answer_sources"):
                q["answer_sources"] = [
                    {
                        "source_name": "GeeksforGeeks / Official Technical Documentation",
                        "source_url": "https://www.geeksforgeeks.org/interview-prep/interview-corner/",
                        "source_type": "Technical Documentation",
                        "confidence": "HIGH",
                        "accessed_date": "2026-09-20"
                    }
                ]

            # Ensure how_to_answer structure
            hta = q.get("how_to_answer", {})
            if not hta.get("short_answer_en"):
                hta["short_answer_en"] = hta.get("explanation_en", "")[:250] or f"Core concept response for {q.get('question')}."
            if not hta.get("explanation_en"):
                hta["explanation_en"] = hta.get("short_answer_en", "")
            q["how_to_answer"] = hta

            # Ensure follow_up_questions have AI Practice Follow-up prefix
            fu = q.get("follow_up_questions", [])
            q["follow_up_questions"] = [
                f if f.startswith("AI Practice Follow-up:") else f"AI Practice Follow-up: {f}"
                for f in fu
            ]

        return questions



    async def evaluate_mock_answer(
        self, question: str, candidate_answer: str, role_context: Dict[str, Any]
    ) -> Dict[str, Any]:
        system_prompt = (
            "You are IntervueX AI Mock Interview Evaluator. Evaluate the candidate's spoken or written answer honestly and constructively.\n"
            "CRITICAL EVALUATION RULE:\n"
            "If the candidate answers with a single word or short non-answer like 'Yes', 'No', 'Ok', 'I don't know', or 'Maybe', "
            "you MUST evaluate it strictly with overall_score between 1.0 and 2.5/10. Single-word answers carry zero technical weight.\n\n"
            "Output JSON with: technical_accuracy (0-10), completeness (0-10), relevance (0-10), structure (0-10), clarity (0-10), "
            "overall_score (0.0-10.0), filler_words (detected filler words like 'um', 'uh', 'like', 'you know'), pacing_feedback, "
            "what_you_did_well (list), what_is_missing (list), how_to_improve (list), what_you_should_not_do (list of 2-3 critical mistakes candidate made or bad habits to avoid), "
            "better_answer_structure (string), what_can_they_ask_next (3-4 tough follow-up questions probing the gaps in this specific answer)."
        )
        user_prompt = (
            f"Target Role Context: {json.dumps(role_context)}\n"
            f"Interview Question: {question}\n"
            f"Candidate Answer: {candidate_answer}"
        )
        return await self._call_grok(system_prompt, user_prompt, temperature=0.2)

    async def generate_next_mock_question(
        self, history: List[Dict[str, Any]], role_context: Dict[str, Any], mode: str, difficulty: str
    ) -> Dict[str, str]:
        system_prompt = (
            "You are an active IntervueX AI Interviewer conducting a realistic interview.\n"
            "Review the dialogue history. Based on the candidate's previous answer and missing points, generate the next question.\n"
            "Output JSON with: {\"interviewer_question\": \"...\", \"question_category\": \"...\"}.\n"
            "If the candidate's previous response was weak or left out critical details, probe deeper with a sharp follow-up. Otherwise proceed to the next stage."
        )
        user_prompt = (
            f"Mode: {mode}\nDifficulty: {difficulty}\nRole Context: {json.dumps(role_context)}\n"
            f"Conversation History: {json.dumps(history)}"
        )
        return await self._call_grok(system_prompt, user_prompt, temperature=0.3)

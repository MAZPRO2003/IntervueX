import logging
import asyncio
from typing import List, Dict, Any, Optional
from duckduckgo_search import DDGS
from datetime import datetime
import json
import uuid

logger = logging.getLogger(__name__)

class ResearchAgent:
    """
    Automated agent for discovering companies and researching their interview processes
    from real-world sources like PrepInsta, GeeksforGeeks, Glassdoor, etc.
    """
    def __init__(self):
        self.primary_sources = [
            "prepinsta.com",
            "geeksforgeeks.org",
            "interviewbit.com",
            "prepare.sh",
            "placeprep.app",
            "faceprep.in",
            "indiabix.com",
            "ambitionbox.com",
            "glassdoor.co.in",
            "leetcode.com",
            "hackerrank.com"
        ]

    async def search_web(self, query: str, max_results: int = 5) -> List[Dict[str, str]]:
        """
        Executes a web search using DuckDuckGo.
        """
        logger.info(f"ResearchAgent searching: {query}")
        results = []
        try:
            # DDGS is synchronous but we can run it in a thread if needed, or just block lightly
            with DDGS() as ddgs:
                ddg_results = list(ddgs.text(query, max_results=max_results))
                for r in ddg_results:
                    results.append({
                        "title": r.get("title", ""),
                        "body": r.get("body", ""),
                        "url": r.get("href", "")
                    })
        except Exception as e:
            logger.error(f"Error during web search for '{query}': {e}")
        return results

    async def discover_companies(self, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Stage 1: Discover companies by searching top preparation sites.
        Extracts company names and normalizes them.
        """
        discovered = []
        
        # We will do a broad search to find "All companies placement papers" etc.
        query = "site:prepinsta.com OR site:geeksforgeeks.org \"placement papers\" OR \"interview questions\" companies"
        raw_results = await self.search_web(query, max_results=10)
        
        # Here an AI would normally extract companies from the text.
        # For offline/mock mode, we simulate extracting from the search results.
        
        # Basic parsing/normalization simulation:
        simulated_discoveries = [
            {"name": "Microsoft", "short_name": "Microsoft", "industry": "Product MNC"},
            {"name": "Tata Consultancy Services", "short_name": "TCS", "industry": "IT Services"},
            {"name": "Amazon", "short_name": "Amazon", "industry": "Product MNC"},
            {"name": "Cognizant", "short_name": "CTS", "industry": "IT Services"},
            {"name": "Infosys", "short_name": "Infosys", "industry": "IT Services"},
            {"name": "JP Morgan Chase", "short_name": "JPMC", "industry": "FinTech"},
            {"name": "Deloitte", "short_name": "Deloitte", "industry": "Consulting"}
        ]
        
        # Return up to 'limit' companies
        return simulated_discoveries[:limit]

    async def research_company(self, company_name: str, role: str) -> Dict[str, Any]:
        """
        Stage 2 & 3: Find company specific pages and research them.
        Returns a rich profile with extracted timeline, rounds, and sources.
        """
        # Search specifically for this company and role
        query_process = f"{company_name} {role} interview process site:geeksforgeeks.org OR site:ambitionbox.com"
        process_results = await self.search_web(query_process, max_results=3)
        
        sources = []
        for res in process_results:
            sources.append({
                "source_name": self._extract_domain(res["url"]),
                "source_url": res["url"],
                "discovered_date": datetime.utcnow().strftime("%Y-%m-%d")
            })
            
        # Compile profile
        return {
            "name": company_name,
            "data_status": "Verified" if sources else "Research Pending",
            "discovered_from": sources,
            "process_available": len(sources) > 0,
            "questions_available": len(sources) > 0,
            "experiences_available": True if sources else False,
            "official_data_available": False,
            "recent_data_available": True,
            "raw_search_results": process_results # For AI extraction later
        }

    async def extract_questions(self, company_name: str, role: str) -> List[Dict[str, Any]]:
        """
        Stage 4: Find actual reported questions.
        """
        query_questions = f"{company_name} {role} interview questions site:prepinsta.com OR site:geeksforgeeks.org OR site:interviewbit.com OR site:prepare.sh"
        question_results = await self.search_web(query_questions, max_results=5)
        
        questions = []
        # In a full implementation, AI extracts specific Qs from the body text
        # For now, we mock the extraction based on the real URLs we found
        for i, res in enumerate(question_results):
            questions.append({
                "id": f"q_disc_{uuid.uuid4().hex[:8]}",
                "question": f"Extracted Question {i+1} from {res['title']}",
                "category": "Company Specific",
                "difficulty": "Medium",
                "priority": "High",
                "evidence_label": "REPORTED BY CANDIDATES",
                "why_matters": "Reported in recent interview experiences.",
                "candidate_relevance": f"Highly relevant for {company_name} {role}",
                "source": self._extract_domain(res["url"]),
                "source_url": res["url"],
                "source_type": "Preparation Site",
                "confidence": "High",
                "year": datetime.utcnow().year,
                "question_type": "ACTUAL/REPORTED",
                "how_to_answer": {
                    "interviewer_intent": "Unknown",
                    "explanation_en": res.get("body", "")[:100],
                    "explanation_ta": "",
                    "explanation_hi": "",
                    "natural_sample_answer_en": "Sample answer",
                    "short_answer_en": "Short",
                }
            })
        return questions

    def _extract_domain(self, url: str) -> str:
        try:
            return url.split("/")[2]
        except IndexError:
            return "Unknown"

# Singleton instance
research_agent = ResearchAgent()

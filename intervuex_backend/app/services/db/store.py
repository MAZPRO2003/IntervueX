import logging
import json
import os
import re
from typing import Dict, Any, List, Optional
from datetime import datetime
import uuid

logger = logging.getLogger(__name__)

def _clean_question_title(text: str) -> str:
    if not text:
        return ""
    cleaned = re.sub(r"^\[[^\]]+\]\s*", "", text).strip()
    cleaned = re.sub(r"\s*\[[^\]]+\]$", "", cleaned).strip()
    return cleaned

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data")
os.makedirs(DATA_DIR, exist_ok=True)

class DataStore:
    """
    Unified storage manager with local JSON persistence for core datasets.
    """
    def __init__(self):
        self.jobs: Dict[str, Dict[str, Any]] = {}
        self.resumes: Dict[str, Dict[str, Any]] = {}
        self.packs: Dict[str, Dict[str, Any]] = {}
        self.processes: Dict[str, Dict[str, Any]] = {}
        self.questions: Dict[str, List[Dict[str, Any]]] = {} # company_name -> list of questions
        self.mock_sessions: Dict[str, Dict[str, Any]] = {}
        self.study_plans: Dict[str, Dict[str, Any]] = {}
        self.feedback_reports: List[Dict[str, Any]] = []
        
        # New models for discovery
        self.companies: Dict[str, Dict[str, Any]] = {}
        self.source_registry: Dict[str, Dict[str, Any]] = {}

        self._load_data()

    COMPANY_ALIASES = {
        "comp_cts": "comp_cognizant",
    }

    def _load_data(self):
        companies_file = os.path.join(DATA_DIR, "companies.json")
        if os.path.exists(companies_file):
            try:
                with open(companies_file, "r") as f:
                    self.companies = json.load(f)
                # Cleanup any duplicate comp_cts if comp_cognizant exists
                if "comp_cts" in self.companies and "comp_cognizant" in self.companies:
                    cts = self.companies.pop("comp_cts")
                    cognizant = self.companies["comp_cognizant"]
                    for k, v in cts.items():
                        if k not in cognizant or not cognizant[k]:
                            cognizant[k] = v
                    self._save_companies()
            except Exception as e:
                logger.error(f"Failed to load companies: {e}")

        sources_file = os.path.join(DATA_DIR, "sources.json")
        if os.path.exists(sources_file):
            try:
                with open(sources_file, "r") as f:
                    self.source_registry = json.load(f)
            except Exception as e:
                logger.error(f"Failed to load sources: {e}")

        questions_file = os.path.join(DATA_DIR, "questions.json")
        if os.path.exists(questions_file):
            try:
                with open(questions_file, "r") as f:
                    self.questions = json.load(f)
            except Exception as e:
                logger.error(f"Failed to load questions: {e}")

    def _save_companies(self):
        with open(os.path.join(DATA_DIR, "companies.json"), "w") as f:
            json.dump(self.companies, f, indent=2)

    def _save_sources(self):
        with open(os.path.join(DATA_DIR, "sources.json"), "w") as f:
            json.dump(self.source_registry, f, indent=2)

    def _save_questions_db(self):
        with open(os.path.join(DATA_DIR, "questions.json"), "w") as f:
            json.dump(self.questions, f, indent=2)

    def get_all_companies(self) -> List[Dict[str, Any]]:
        return list(self.companies.values())

    def get_company(self, company_id: str) -> Optional[Dict[str, Any]]:
        target_id = self.COMPANY_ALIASES.get(company_id, company_id)
        return self.companies.get(target_id) or self.companies.get(company_id)

    def find_company_by_name(self, name: str, short_name: Optional[str] = None) -> Optional[Dict[str, Any]]:
        clean_name = (name or "").strip().lower()
        clean_short = (short_name or "").strip().lower()
        
        for comp in self.companies.values():
            c_name = comp.get("name", "").strip().lower()
            c_short = comp.get("short_name", "").strip().lower()
            c_id = comp.get("id", "").strip().lower()
            
            # Exact or alias matches
            if clean_name and (c_name == clean_name or c_short == clean_name or c_id == clean_name):
                return comp
            if clean_short and (c_short == clean_short or c_name == clean_short or c_id == clean_short):
                return comp
            # Substring / partial matches (e.g. "Cognizant" vs "Cognizant Technology Solutions")
            if clean_name and (clean_name in c_name or c_name in clean_name):
                return comp
            if clean_short and (clean_short in c_short or c_short in clean_short):
                return comp
        return None

    def save_company(self, company: Dict[str, Any]):
        comp_id = company["id"]
        # Check alias
        target_id = self.COMPANY_ALIASES.get(comp_id, comp_id)
        company["id"] = target_id

        # Check if already exists under matching name/short_name
        existing = self.find_company_by_name(company.get("name", ""), company.get("short_name"))
        if existing and existing["id"] != target_id:
            # Merge into existing company to avoid creating duplicate stubs
            if not company.get("hiring_programs") and existing.get("hiring_programs"):
                company["hiring_programs"] = existing["hiring_programs"]
            if not company.get("category") and existing.get("category"):
                company["category"] = existing["category"]
            if not company.get("color_hex") and existing.get("color_hex"):
                company["color_hex"] = existing["color_hex"]
            existing.update(company)
            self.companies[existing["id"]] = existing
            self._save_companies()
            return

        # Preserve hiring_programs if updating with empty programs
        if target_id in self.companies:
            existing_progs = self.companies[target_id].get("hiring_programs", [])
            if existing_progs and not company.get("hiring_programs"):
                company["hiring_programs"] = existing_progs

        self.companies[target_id] = company
        self._save_companies()

    def save_source(self, source: Dict[str, Any]):
        self.source_registry[source["id"]] = source
        self._save_sources()

    def get_sources(self) -> List[Dict[str, Any]]:
        return list(self.source_registry.values())

    def save_job(self, job_data: Dict[str, Any]) -> str:
        job_id = job_data.get("id") or f"job_{uuid.uuid4().hex[:8]}"
        job_data["id"] = job_id
        self.jobs[job_id] = job_data
        return job_id

    def get_job(self, job_id: str) -> Optional[Dict[str, Any]]:
        return self.jobs.get(job_id)

    def save_resume(self, resume_data: Dict[str, Any]) -> str:
        res_id = resume_data.get("id") or f"res_{uuid.uuid4().hex[:8]}"
        resume_data["id"] = res_id
        self.resumes[res_id] = resume_data
        return res_id

    def get_resume(self, res_id: str) -> Optional[Dict[str, Any]]:
        return self.resumes.get(res_id)

    def save_pack(self, pack: Dict[str, Any]) -> str:
        pack_id = pack.get("id") or f"pack_{uuid.uuid4().hex[:8]}"
        pack["id"] = pack_id
        self.packs[pack_id] = pack
        return pack_id

    def get_pack(self, pack_id: str) -> Optional[Dict[str, Any]]:
        return self.packs.get(pack_id)

    def list_packs(self) -> List[Dict[str, Any]]:
        return list(self.packs.values())

    def save_process(self, pack_id: str, process_data: Dict[str, Any]):
        self.processes[pack_id] = process_data

    def get_process(self, pack_id: str) -> Optional[Dict[str, Any]]:
        return self.processes.get(pack_id)

    def save_questions(self, company_name: str, questions: List[Dict[str, Any]]):
        company_key = company_name.lower().strip()
        self.questions[company_key] = questions
        self._save_questions_db()

    def get_questions(self, company_name: str) -> List[Dict[str, Any]]:
        company_key = company_name.lower().strip()
        qs = self.questions.get(company_key, [])
        if not qs:
            if "cognizant" in company_key:
                qs = self.questions.get(company_key.replace("cognizant", "cts"), [])
            elif "cts" in company_key:
                qs = self.questions.get(company_key.replace("cts", "cognizant"), [])

        if qs and len(qs) > 0:
            first = qs[0]
            if not first.get("question_sources") or not first.get("answer_sources") or not first.get("verification_status"):
                # Discard stale schema without dual sources and verification status
                return []

        for q in qs:
            if "question" in q and q["question"]:
                q["question"] = _clean_question_title(q["question"])

        return qs


    def toggle_save_question(self, company_name: str, question_id: str) -> bool:
        company_key = company_name.lower().strip()
        qs = self.questions.get(company_key, [])
        for q in qs:
            if q.get("id") == question_id:
                q["is_saved"] = not q.get("is_saved", False)
                self._save_questions_db()
                return q["is_saved"]
        return False

    def toggle_mastered_question(self, company_name: str, question_id: str) -> bool:
        company_key = company_name.lower().strip()
        qs = self.questions.get(company_key, [])
        for q in qs:
            if q.get("id") == question_id:
                q["mastered"] = not q.get("mastered", False)
                self._save_questions_db()
                return q["mastered"]
        return False

    def save_mock_session(self, session: Dict[str, Any]):
        self.mock_sessions[session["id"]] = session

    def get_mock_session(self, session_id: str) -> Optional[Dict[str, Any]]:
        return self.mock_sessions.get(session_id)

    def save_study_plan(self, plan: Dict[str, Any]):
        self.study_plans[plan["pack_id"]] = plan

    def get_study_plan(self, pack_id: str) -> Optional[Dict[str, Any]]:
        return self.study_plans.get(pack_id)

    def record_feedback(self, report: Dict[str, Any]):
        report["timestamp"] = datetime.utcnow().isoformat()
        self.feedback_reports.append(report)

db_store = DataStore()

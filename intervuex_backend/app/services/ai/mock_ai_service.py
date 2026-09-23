import uuid
import re
from datetime import datetime
from typing import Dict, Any, List, Optional
from app.services.ai.base import AIServiceBase
from app.services.ai.company_knowledge import get_company_questions, get_process_for_track



class MockAIService(AIServiceBase):
    """High-fidelity local fallback service for development and testing."""

    async def analyze_job(self, text: str) -> Dict[str, Any]:
        text_lower = text.lower()

        # 1. Company Extraction
        company = "TechCorp Global"
        if "hcltech" in text_lower or "hcl" in text_lower:
            company = "HCLTech"
        elif "cognizant" in text_lower:
            company = "Cognizant"
        elif "tcs" in text_lower or "tata consultancy" in text_lower:
            company = "Tata Consultancy Services"
        elif "infosys" in text_lower:
            company = "Infosys"
        elif "wipro" in text_lower:
            company = "Wipro"
        elif "accenture" in text_lower:
            company = "Accenture"
        elif "amazon" in text_lower or "aws" in text_lower:
            company = "Amazon"
        elif "google" in text_lower:
            company = "Google"
        elif "microsoft" in text_lower:
            company = "Microsoft"
        else:
            m_comp = re.search(r'Company(?:\s*Domain)?:?\s*([A-Za-z0-9\s]+)', text)
            if m_comp:
                extracted = m_comp.group(1).strip().title()
                if extracted.lower() not in ["www", "http", "https", "com", "in", "org"]:
                    company = extracted

        # 2. Role Title Extraction
        role = "Software Developer"
        m_role = re.search(r'(?:Role Title|Job Title|Position):?\s*([^\n\r]+)', text)
        if m_role:
            role = m_role.group(1).strip()
            role = re.sub(r'[^a-zA-Z0-9\s/\-\(\)]', '', role).strip()
        elif "python" in text_lower and ("developer" in text_lower or "engineer" in text_lower):
            role = "Python Software Developer"
        elif "genai" in text_lower or "generative ai" in text_lower:
            role = "GenAI Automation Test Lead / Architect"
        elif "architect" in text_lower:
            role = "Test / Solutions Architect"
        elif "lead" in text_lower:
            role = "Technical Lead Engineer"
        elif "ninja" in text_lower:
            role = "System Engineer (Ninja)"
        elif "digital" in text_lower:
            role = "Digital Software Engineer"
        elif "engineer" in text_lower:
            role = "Software Engineer"


        # 3. Hiring Program Extraction
        is_ninja = "ninja" in text_lower
        is_digital = "digital" in text_lower
        is_prime = "prime" in text_lower
        
        program = f"{company} Experienced Hiring"
        if is_ninja:
            program = "NQT - Ninja"
        elif is_digital:
            program = "NQT - Digital"
        elif is_prime:
            program = "NQT - Prime"
        elif "genai" in text_lower or "architect" in text_lower:
            program = f"{company} GenAI & Quality Engineering Architecture Track"

        # 4. Skills Extraction
        skill_catalog = [
            "Generative AI", "Prompt Engineering", "RAG Frameworks", "LLMs", "Test Automation", 
            "STLC", "Quality Engineering", "Python", "Java", "C++", "JavaScript", "TypeScript", 
            "Selenium", "Playwright", "Cypress", "PyTest", "JUnit", "SQL", "PostgreSQL", 
            "Docker", "Kubernetes", "Kafka", "AWS", "Azure", "GCP", "CI/CD", "Git", "REST API"
        ]
        extracted_req = []
        for sk in skill_catalog:
            pattern = r'\b' + re.escape(sk.upper()) + r'\b'
            if re.search(pattern, text.upper()):
                extracted_req.append(sk)

        if not extracted_req:
            extracted_req = ["Generative AI", "Test Automation", "Prompt Engineering", "Python", "STLC Quality Engineering"]

        exp_level = "Lead / Senior (8+ Years)" if ("lead" in text_lower or "architect" in text_lower or "14+" in text_lower) else "Mid-Senior (3 - 7 Years)"

        return {
            "id": f"job_{uuid.uuid4().hex[:8]}",
            "company": company,
            "job_title": role,
            "role_category": "GenAI & Quality Engineering Architecture",
            "department": "Technology & Engineering",
            "location": "Charlotte, NC / India / Hybrid",
            "experience_level": exp_level,
            "hiring_program": program,
            "education": "B.E. / B.Tech / M.Tech / MCA Computer Science",
            "employment_type": "Full-Time",
            "skills": {
                "required_skills": extracted_req[:8],
                "preferred_skills": ["Synthetic Data Generation", "Model Fine-Tuning", "Agentic AI", "Docker"],
                "programming_languages": [s for s in extracted_req if s in ["Python", "Java", "TypeScript", "C++"]] or ["Python", "Java"],
                "frameworks": [s for s in extracted_req if s in ["RAG Frameworks", "PyTest", "Selenium", "Playwright", "Cypress"]] or ["RAG Frameworks", "PyTest"],
                "databases": ["PostgreSQL", "Vector DBs (Chroma/FAISS)"],
                "cloud_technologies": ["AWS", "Azure GenAI Services"],
                "tools": ["Git", "GitHub Actions", "Docker", "Postman"],
                "certifications": ["AWS Certified AI Practitioner", "Generative AI Specialist"]
            },
            "priorities": {
                "critical_skills": [f"{extracted_req[0]} Implementation" if extracted_req else "GenAI Test Architecture", "Automated STLC Quality Pipeline", "Enterprise Framework Design"],
                "secondary_skills": ["RAG Vector Index Optimization", "Prompt Injection & Safety Verification"],
                "key_responsibilities": [
                    "Drive Generative AI adoption across the Software Testing Lifecycle (STLC).",
                    "Architect AI-assisted UI & API test automation and synthetic test data generation frameworks.",
                    "Lead RAG retrieval-augmented generation and model evaluation pipelines for quality engineering."
                ]
            },
            "summary": f"High-impact role at {company} within the {program} for leading GenAI quality engineering and automation architecture.",
            "created_at": "2026-09-20"
        }


    async def analyze_resume(self, resume_text: str, job_context: Optional[Dict[str, Any]] = None, layout_data: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        text_clean = (resume_text or "").strip()
        lines = [l.strip() for l in text_clean.splitlines() if l.strip()]

        if not text_clean or len(lines) < 2:
            raise ValueError("Resume contains insufficient text for analysis. Please upload a valid text-based resume.")

        # 1. Dynamic Candidate Name Extraction
        candidate_name = ""
        for line in lines[:6]:
            lower_line = line.lower()
            if any(w in lower_line for w in ["email", "@", "phone", "+", "resume", "curriculum", "page", "http", "github", "linkedin", "address"]):
                continue
            cleaned = re.sub(r'[^a-zA-Z\s\.]', '', line).strip()
            words = cleaned.split()
            if 2 <= len(words) <= 4 and len(cleaned) <= 35 and not any(kw in lower_line for kw in ["education", "skills", "projects", "experience"]):
                candidate_name = cleaned.title()
                break
        
        if not candidate_name:
            candidate_name = "Candidate Profile"

        # 2. Dynamic Skills Extraction
        known_skills = [
            "Python", "Java", "C++", "C#", "JavaScript", "TypeScript", "React", "Angular", "Vue", "Flutter",
            "FastAPI", "Django", "Flask", "Node.js", "Express", "Spring Boot", "SQL", "PostgreSQL", "MySQL",
            "MongoDB", "Redis", "Docker", "Kubernetes", "AWS", "Azure", "GCP", "Git", "HTML/CSS", "HTML", "CSS",
            "REST API", "Microservices", "Data Structures", "Algorithms", "DSA", "Linux", "Machine Learning",
            "Deep Learning", "TensorFlow", "PyTorch", "Pandas", "NumPy", "OOP", "Kafka", "GraphQL", "CI/CD"
        ]
        extracted_skills = []
        text_upper = text_clean.upper()
        for s in known_skills:
            pattern = r'\b' + re.escape(s.upper()) + r'\b'
            if re.search(pattern, text_upper):
                if s == "HTML" or s == "CSS":
                    if "HTML/CSS" not in extracted_skills:
                        extracted_skills.append("HTML/CSS")
                elif s not in extracted_skills:
                    extracted_skills.append(s)

        if not extracted_skills:
            extracted_skills = ["Software Development", "Problem Solving", "Object-Oriented Programming", "SQL", "Git"]

        # 3. Dynamic Projects & Experience Section Extraction
        extracted_projects = []
        in_projects = False
        proj_lines = []
        experience_lines = []
        in_experience = False

        for line in lines:
            ll = line.lower()
            if any(h in ll for h in ["projects", "project work", "academic projects", "key projects"]):
                in_projects = True
                in_experience = False
                continue
            if any(h in ll for h in ["experience", "work history", "employment", "professional experience"]):
                in_experience = True
                in_projects = False
                continue
            if any(h in ll for h in ["education", "skills", "certifications"]):
                in_projects = False
                in_experience = False

            if in_projects and len(line) > 10:
                proj_lines.append(line)
            if in_experience and len(line) > 10:
                experience_lines.append(line)

        if proj_lines:
            for idx, pline in enumerate(proj_lines[:4], 1):
                clean_title = pline.split(":")[0].split("-")[0].strip()
                clean_title = re.sub(r'^\d+[\.\)]\s*', '', clean_title).strip()
                if len(clean_title) > 50 or len(clean_title) < 3:
                    clean_title = f"Project #{idx}"
                matched_tech = [s for s in extracted_skills if s.upper() in pline.upper()][:4] or extracted_skills[:2]
                extracted_projects.append({
                    "project_title": clean_title,
                    "claim_text": pline[:180],
                    "technologies": matched_tech,
                    "potential_questions": [
                        f"Walk me through the design and architecture of '{clean_title}'.",
                        f"What specific individual contributions did you make to '{clean_title}'?",
                        f"Why did you choose {matched_tech[0] if matched_tech else 'these tools'} for '{clean_title}' over alternative approaches?",
                        f"How did you handle error conditions, testing, and edge cases in '{clean_title}'?"
                    ]
                })

        if not extracted_projects:
            top_techs = extracted_skills[:3]
            extracted_projects = [
                {
                    "project_title": "Primary Technical Application",
                    "claim_text": f"Built software solution utilizing {', '.join(top_techs)}.",
                    "technologies": top_techs,
                    "potential_questions": [
                        "Walk me through the architecture of your primary project.",
                        "How did you handle API response latency and database connection pooling?",
                        "What would happen if your application experiences a sudden 10x traffic surge?"
                    ]
                }
            ]

        # 4. Dynamic Traceable Risk & Exaggeration Detector
        # CRITICAL RULE: Every risk MUST be based on evidence present in candidate's resume!
        extracted_risks = []

        # Risk Type A: Skills listed in Skills section but unsupported by Project/Experience text
        project_and_exp_text = (" ".join(proj_lines) + " " + " ".join(experience_lines)).upper()
        for skill in extracted_skills:
            if skill.upper() in ["HTML", "CSS", "GIT", "PROBLEM SOLVING", "SOFTWARE DEVELOPMENT", "OOP"]:
                continue
            # Check if skill appears in project/exp text
            if skill.upper() not in project_and_exp_text:
                is_high_risk = skill.upper() in ["AWS", "KUBERNETES", "DOCKER", "REACT", "PYTORCH", "FLUTTER"]
                extracted_risks.append({
                    "title": f"Skill '{skill}' Listed Without Supporting Project Evidence",
                    "claimed_item": skill,
                    "risk_level": "High" if is_high_risk else "Medium",
                    "evidence_source": "Skills Section",
                    "evidence_text": f"'{skill}' listed under Technical Skills section",
                    "why_questioned": f"'{skill}' is explicitly listed as a technical skill, but no projects or work experiences explain how you applied {skill}.",
                    "reason": f"'{skill}' is explicitly listed under Skills, but no project or work experience in the resume details how you used {skill}.",
                    "expected_grilling_topics": [
                        f"Which specific features of {skill} have you used hands-on?",
                        f"How did you apply {skill} in a real project?",
                        f"What problems or bugs did you solve using {skill}?"
                    ],
                    "preparation_advice": f"Be prepared to detail your hands-on experience with {skill} or clarify your familiarity level."
                })

        # Risk Type B: Projects making high claims without metrics
        for proj in extracted_projects:
            c_text = proj["claim_text"]
            if not any(char.isdigit() for char in c_text) and len(c_text) > 30:
                extracted_risks.append({
                    "title": f"Architectural Claim Requires Quantitative Metrics: {proj['project_title']}",
                    "claimed_item": proj["project_title"],
                    "risk_level": "Medium",
                    "evidence_source": f"Project: {proj['project_title']}",
                    "evidence_text": f"\"{c_text}\"",
                    "why_questioned": f"The description for '{proj['project_title']}' outlines technical scope but lacks quantifiable metrics (e.g. latency, QPS, user count).",
                    "reason": f"Project '{proj['project_title']}' makes architecture claims without specific quantitative metrics or impact measurements.",
                    "expected_grilling_topics": proj["potential_questions"],
                    "preparation_advice": "Prepare specific metrics (e.g. API response time in ms, database size, test coverage %) for interview follow-ups."
                })

        if not extracted_risks:
            extracted_risks.append({
                "title": "Technical Deep Dive Readiness",
                "claimed_item": extracted_skills[0] if extracted_skills else "Core Technical Skills",
                "risk_level": "Medium",
                "evidence_source": "Skills & Experience Section",
                "evidence_text": f"Technical profile featuring {', '.join(extracted_skills[:3])}",
                "why_questioned": "Interviewers will expect deep domain mastery and live coding/whiteboarding for claimed core skills.",
                "reason": f"Interviewers will probe core architectural design patterns, edge case handling, and failure recovery for {extracted_skills[0]}.",
                "expected_grilling_topics": ["SOLID Principles & Design Patterns", "Database Connection Pooling", "API Error Handling Strategy"],
                "preparation_advice": "Rehearse a 2-minute architectural breakdown of your primary technical project."
            })

        # Limit to top 5 most relevant risks
        extracted_risks = extracted_risks[:5]

        # 5. Dynamic Section & Contact Info Parsing
        edu_lines = [l for l in lines if any(e in l.lower() for e in ["b.tech", "b.e", "b.s", "m.tech", "degree", "university", "college", "gpa", "cgpa", "bachelor", "master"])]
        edu_degree = edu_lines[0] if edu_lines else "Bachelor's Degree in Computer Science / Technology"

        email_match = re.search(r'[\w\.-]+@[\w\.-]+\.\w+', text_clean)
        phone_match = re.search(r'\+?\d[\d\s-]{8,}\d', text_clean)
        contact_info = {
            "name": candidate_name,
            "email": email_match.group(0) if email_match else "Provided in Resume",
            "phone": phone_match.group(0) if phone_match else "Provided in Resume",
            "location": "Remote / Local"
        }

        # Categorized Skills
        languages = [s for s in extracted_skills if s in ["Python", "Java", "C++", "C#", "JavaScript", "TypeScript", "HTML/CSS", "HTML", "CSS"]]
        frameworks = [s for s in extracted_skills if s in ["FastAPI", "Django", "Flask", "Node.js", "Express", "Spring Boot", "React", "Angular", "Vue", "Flutter"]]
        databases = [s for s in extracted_skills if s in ["SQL", "PostgreSQL", "MySQL", "MongoDB", "Redis"]]
        cloud_devops = [s for s in extracted_skills if s in ["AWS", "Azure", "GCP", "Docker", "Kubernetes", "Git", "Linux", "CI/CD"]]
        core_cs = [s for s in extracted_skills if s in ["Data Structures", "Algorithms", "DSA", "Microservices", "REST API", "OOP", "Machine Learning", "Deep Learning", "TensorFlow", "PyTorch", "Pandas", "NumPy", "Kafka", "GraphQL"]]

        categorized_skills = {
            "Programming Languages": languages or ["Python", "JavaScript"],
            "Frameworks & Libraries": frameworks or ["FastAPI / Node.js"],
            "Databases & Storage": databases or ["SQL / Relational DB"],
            "Cloud & DevOps": cloud_devops or ["Git / Linux"],
            "Core Concepts": core_cs or ["Object-Oriented Programming", "REST APIs"]
        }

        # 6. Job Fit Analysis
        is_job_targeted = False
        target_job_title = None
        overall_match_percentage = 0
        matching_skills = []
        missing_skills = []
        skill_matches = []

        if job_context and isinstance(job_context, dict):
            is_job_targeted = True
            comp = job_context.get("company", "Target Company")
            role = job_context.get("job_title", "Software Engineer")
            target_job_title = f"{comp} - {role}"

            job_skills_data = job_context.get("skills", {})
            req_skills = job_skills_data.get("required_skills", []) + job_skills_data.get("programming_languages", [])
            req_skills = list(dict.fromkeys(req_skills))

            if not req_skills:
                req_skills = ["Python", "SQL", "Data Structures", "OOP"]

            for req in req_skills:
                if any(req.lower() in es.lower() or es.lower() in req.lower() for es in extracted_skills):
                    matching_skills.append(req)
                    skill_matches.append({"skill": req, "status": "Strong Match", "category": "Required Skill", "notes": "Present on resume"})
                else:
                    missing_skills.append(req)
                    skill_matches.append({"skill": req, "status": "Missing", "category": "Required Skill", "notes": "Not explicitly listed on resume"})

            overall_match_percentage = int((len(matching_skills) / max(1, len(req_skills))) * 100)
        else:
            for s in extracted_skills[:5]:
                skill_matches.append({"skill": s, "status": "Strong Match", "category": "Technical Skill", "notes": "Verified candidate claim"})

        # 7. Dynamic Multi-Factor Quality Breakdown (0 - 100)
        has_metrics = any(char in text_clean for char in ["%", "ms", "k", "QPS", "reduced", "increased", "optimized"])
        has_standard_headers = any(h in text_clean.lower() for h in ["skills", "projects", "education", "experience"])
        
        ats_comp = min(98, max(55, 70 + (10 if "skills" in text_clean.lower() else 0) + (10 if has_standard_headers else -10) + (5 if len(extracted_skills) >= 4 else 0)))
        content_qual = min(98, max(50, 68 + (12 if has_metrics else 0) + (10 if len(lines) >= 20 else -10)))
        structure_score = min(98, max(60, 72 + (10 if proj_lines else 0) + (10 if edu_lines else 0) + (8 if email_match else 0)))
        skills_score = min(98, max(45, 50 + len(extracted_skills) * 4))
        exp_score = min(98, max(50, 65 + len(experience_lines) * 5))
        proj_score = min(98, max(50, 65 + len(extracted_projects) * 8))
        job_rel = overall_match_percentage if is_job_targeted else min(95, max(65, 70 + len(extracted_skills) * 2))
        readability_score = min(98, max(60, 80 + (10 if 15 <= len(lines) <= 90 else -10)))
        formatting_score = min(98, max(65, 78 + (10 if has_standard_headers else 0)))

        overall_quality_score = int(
            (ats_comp + content_qual + structure_score + skills_score + exp_score + proj_score + job_rel + readability_score + formatting_score) / 9
        )

        quality_breakdown = {
            "overall_score": overall_quality_score,
            "ats_compatibility": ats_comp,
            "content_quality": content_qual,
            "resume_structure": structure_score,
            "skills_score": skills_score,
            "experience_score": exp_score,
            "projects_score": proj_score,
            "job_relevance": job_rel,
            "readability": readability_score,
            "formatting": formatting_score
        }

        # Strengths & Weaknesses
        strengths = [
            f"Strong technical keyword representation covering {', '.join(extracted_skills[:3])}.",
            "Clean standard section organization allowing easy recruiter scan.",
            f"Clear project breakdowns highlighting technical implementations."
        ]
        weaknesses = []
        if not has_metrics:
            weaknesses.append("Lack of quantifiable impact metrics (e.g. latency, throughput, % efficiency gain) in project descriptions.")
        if len(extracted_risks) > 2:
            weaknesses.append("Several technical skills are listed without explicit project or work experience support.")
        if not weaknesses:
            weaknesses.append("Can further expand on production engineering practices like unit testing and CI/CD pipelines.")

        recommendations = [
            "Add quantifiable impact numbers (e.g. 'Optimized DB queries reducing response time by 40%') to strengthen claim credibility.",
            "Integrate missing target role keywords into your work experience bullet points.",
            "Be prepared to defend all standalone technical skills with real-world implementation examples."
        ]

        # ATS Analysis Details
        ats_strengths = [
            "Standard section titles (Skills, Projects, Education) detected.",
            f"Extracted {len(extracted_skills)} technical keywords compatible with ATS indexers.",
            "Clean text flow without unparsable graphic artifacts."
        ]
        ats_issues = []
        if missing_skills:
            ats_issues.append(f"Missing required role keywords: {', '.join(missing_skills[:3])}.")
        if not has_metrics:
            ats_issues.append("Project bullets lack numerical metrics, lowering ATS context score.")

        # 8. Dynamic PDF Risk Highlights Mapping
        pdf_highlights = []
        page_lines = layout_data.get("page_lines", []) if layout_data else []

        for i, risk in enumerate(extracted_risks):
            e_text = risk.get("evidence_text", "").lower()
            c_item = risk.get("claimed_item", "").lower()
            matched_page = 1
            matched_y = 20.0 + (i * 14.0)
            matched_snippet = risk.get("evidence_text") or risk.get("claimed_item")

            if page_lines:
                for pl in page_lines:
                    line_lower = pl["line"].lower()
                    if c_item in line_lower or (len(e_text) > 4 and e_text in line_lower):
                        matched_page = pl["page"]
                        matched_y = pl["y_percent"]
                        matched_snippet = pl["line"]
                        break

            pdf_highlights.append({
                "id": f"rh_{i}",
                "page": matched_page,
                "severity": risk["risk_level"].lower().replace(" ", "_") + "_warning",
                "claim_text": matched_snippet,
                "y_percent": matched_y,
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 4.5,
                "flag_category": risk["title"],
                "why_flagged": risk["why_questioned"],
                "interviewer_probe_question": risk["expected_grilling_topics"][0] if risk["expected_grilling_topics"] else "Can you elaborate on this claim?",
                "suggested_rewrite": risk["preparation_advice"]
            })

        # 50 Resume Interview Questions
        resume_50_questions = self._generate_50_resume_questions(
            candidate_name=candidate_name,
            skills=extracted_skills,
            projects=extracted_projects,
            risks=extracted_risks
        )

        return {
            "id": f"res_{uuid.uuid4().hex[:8]}",
            "candidate_name": candidate_name,
            "contact_info": contact_info,
            "summary": f"Technical Candidate specializing in {', '.join(extracted_skills[:4])}.",
            "education": [
                {"degree": edu_degree, "institution": "University / Institute", "year": "Recent", "score": "First Class"}
            ],
            "skills": extracted_skills,
            "categorized_skills": categorized_skills,
            "projects": extracted_projects,
            "experience": [
                {"role": "Software Developer / Engineer", "company": "Technical Projects & Development", "duration": "Recent", "highlights": f"Hands-on development using {', '.join(extracted_skills[:3])}."}
            ],
            "certifications": ["Verified Resume Technical Profile"],
            "risks": extracted_risks,
            "overall_resume_quality": overall_quality_score,
            "resume_strength_score": overall_quality_score,
            "quality_breakdown": quality_breakdown,
            "strengths": strengths,
            "weaknesses": weaknesses,
            "recommendations": recommendations,
            "ats_score": ats_comp,
            "ats_strengths": ats_strengths,
            "ats_issues": ats_issues,
            "ats_keywords_found": extracted_skills,
            "ats_keywords_missing": missing_skills,
            "is_job_targeted": is_job_targeted,
            "target_job_title": target_job_title,
            "overall_match_percentage": overall_match_percentage,
            "matching_skills": matching_skills,
            "missing_skills": missing_skills,
            "what_to_prepare": [
                f"Prepare detailed technical architectural pitches for projects built with {', '.join(extracted_skills[:3])}.",
                "Harden core Object-Oriented Programming (OOP) and SQL Query execution skills.",
                "Rehearse live whiteboarding and failure scenario responses for claims listed on your resume."
            ],
            "resume_improvements": recommendations,
            "resume_questions": resume_50_questions,
            "pdf_risk_highlights": pdf_highlights,
            "created_at": datetime.utcnow().strftime("%Y-%m-%d")
        }

    def _generate_50_resume_questions(
        self, candidate_name: str, skills: List[str], projects: List[Dict[str, Any]], risks: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        questions = []
        q_id = 1

        top_skills = skills[:5] if skills else ["Python", "SQL", "FastAPI", "Docker", "Git"]
        s1 = top_skills[0] if len(top_skills) > 0 else "Python"
        s2 = top_skills[1] if len(top_skills) > 1 else "SQL"
        s3 = top_skills[2] if len(top_skills) > 2 else "REST API"

        proj1_title = projects[0]["project_title"] if projects else "Primary Full-Stack Project"
        proj1_claim = projects[0]["claim_text"] if projects else "Developed technical project."

        proj2_title = projects[1]["project_title"] if len(projects) > 1 else "Backend Microservices Engine"
        proj2_claim = projects[1]["claim_text"] if len(projects) > 1 else "Built backend services."

        # Category 1: Project Architecture & Claims (15 Questions)
        project_q_templates = [
            (f"Walk me through the high-level architecture of '{proj1_title}'. Why did you choose {s1} for it?", "Project Architecture", proj1_claim, "Medium", "Explain component separation, API routes, database models, and rationale for framework choice."),
            (f"In '{proj1_title}', how did you handle concurrent user requests and database connection pooling?", "Concurrency & Scalability", proj1_claim, "High", "Explain connection pool size limits, async database drivers, and thread vs event loop execution."),
            (f"What error handling and fallback mechanisms were implemented in '{proj1_title}' if the database is unreachable?", "Resilience & Error Handling", proj1_claim, "Medium", "Describe try-except catch blocks, 500 status code responses, logging, and retry backoff strategy."),
            (f"How did you secure sensitive API endpoints and user credentials in '{proj1_title}'?", "Security & Auth", proj1_claim, "High", "Explain password hashing (Bcrypt/Argon2), JWT token expiration, and HTTPS/SSL transport security."),
            (f"If '{proj1_title}' receives 10x its current traffic, where will the primary bottleneck occur?", "System Bottlenecks", proj1_claim, "High", "Identify database I/O bottlenecks, table index usage, and horizontal vs vertical scaling strategy."),
            (f"In '{proj1_title}', how did you validate incoming API request payloads before processing?", "Data Validation", proj1_claim, "Low", "Describe schema validation (Pydantic/DTOs), HTTP 422 Unprocessable Entity responses, and field sanitization."),
            (f"How did you structure database migrations when adding new tables to '{proj1_title}'?", "Database Schema", proj1_claim, "Medium", "Explain Alembic/Flyway migration scripts, version control for DB schemas, and zero-downtime column additions."),
            (f"Did you write automated tests for '{proj1_title}'? What test coverage strategy did you follow?", "Testing & QA", proj1_claim, "Medium", "Describe PyTest/Unit tests, API route test clients, mocking database calls, and assertion checks."),
            (f"Walk me through the design of '{proj2_title}'. What was your specific individual contribution?", "Project Contribution", proj2_claim, "Medium", "Articulate individual responsibilities, code modules written, and team collaboration workflow."),
            (f"In '{proj2_title}', how did you handle cache invalidation or stale data when updates occurred?", "Caching Strategy", proj2_claim, "High", "Explain Redis cache keys, TTL (Time-To-Live) expiration, and Write-Through vs Cache-Aside strategies."),
            (f"What key technical trade-off did you make during the development of '{proj2_title}'?", "Technical Trade-offs", proj2_claim, "High", "Discuss trade-offs between simplicity vs scalability, SQL normalization vs denormalization, or sync vs async I/O."),
            (f"How did you manage application configuration and environment variables (.env files) in production?", "DevOps & Config", proj2_claim, "Low", "Explain environment variable injection, secret managers, and avoiding hardcoded secrets in Git."),
            (f"In '{proj1_title}', how did you ensure database transactions were atomic during multi-table writes?", "Transactions & ACID", proj1_claim, "High", "Explain BEGIN/COMMIT/ROLLBACK, ACID atomicity, and handling exceptions mid-transaction."),
            (f"How did you optimize API response latency in '{proj1_title}' for data heavy endpoints?", "Performance Tuning", proj1_claim, "High", "Discuss SQL query indexing, payload pagination (LIMIT/OFFSET or cursor), and payload compression."),
            (f"What containerization or deployment pipeline was used for '{proj1_title}'?", "Deployment & CI/CD", proj1_claim, "Medium", "Describe Dockerfile instructions, image optimization, and GitHub Actions / CI/CD automated deployment.")
        ]

        for q, cat, claim, diff, ans in project_q_templates:
            questions.append({
                "id": f"q_res_{q_id}",
                "question": q,
                "category": cat,
                "targeted_claim": claim,
                "difficulty": diff,
                "priority": "High Priority",
                "expected_answer_framework": ans,
                "what_evaluators_look_for": "Technical depth, hands-on architectural understanding, and clarity of trade-offs."
            })
            q_id += 1

        # Category 2: Technical Skills Claims & Edge-Case Probing (15 Questions)
        skills_q_templates = [
            (f"Your resume lists proficiency in {s1}. How does memory management and garbage collection work in {s1}?", "Core Language Mechanics", f"Claim: {s1} Proficiency", "High", f"Explain reference counting, garbage collection algorithms, and object lifecycle in {s1}."),
            (f"Explain the difference between synchronous execution and asynchronous event loops in {s1}.", "Async & Concurrency", f"Claim: {s1} Proficiency", "Medium", "Contrast single-threaded event loops (epoll) vs multi-threaded blocking I/O models."),
            (f"Your resume highlights {s2}. What is the difference between WHERE and HAVING clauses in {s2}?", "Database & SQL", f"Claim: {s2} Skills", "Low", "Explain that WHERE filters raw rows before aggregation, while HAVING filters aggregated GROUP BY results."),
            (f"How do B-Tree indexes work in {s2}, and when would an index hurt query performance?", "SQL Indexing", f"Claim: {s2} Skills", "High", "Explain B-Tree search O(log N), composite indexes, and write overhead during INSERT/UPDATE operations."),
            (f"Explain the difference between INNER JOIN, LEFT JOIN, and FULL OUTER JOIN in {s2}.", "SQL Joins", f"Claim: {s2} Skills", "Medium", "Detail matching row return vs NULL padding for unmatched rows across tables."),
            (f"How do window functions like ROW_NUMBER() and RANK() differ from GROUP BY in {s2}?", "Advanced SQL", f"Claim: {s2} Skills", "High", "Explain that window functions calculate values across row partitions without collapsing rows."),
            (f"Your resume mentions {s3}. What is the difference between PUT and PATCH HTTP methods in REST APIs?", "REST API Design", f"Claim: {s3} API Skills", "Low", "PUT replaces the entire resource representation; PATCH applies partial modifications to specified fields."),
            (f"What are idempotent HTTP methods, and why is POST not considered idempotent?", "API Architecture", f"Claim: {s3} API Skills", "Medium", "Idempotent methods yield identical server state on multiple identical calls. POST creates new resources each time."),
            (f"How do you handle authentication statelessness using JWT (JSON Web Tokens)?", "Security & Auth", "Claim: Web Security", "Medium", "Explain Header.Payload.Signature structure, secret key validation, and short-lived access tokens with refresh tokens."),
            (f"What is CORS (Cross-Origin Resource Sharing), and how do you configure it safely?", "Web Security", "Claim: Web Architecture", "Low", "Explain browser origin security policies, preflight OPTIONS requests, and restricting Access-Control-Allow-Origin headers."),
            (f"Explain the SOLID principles of Object-Oriented Design. Which principle do you apply most frequently?", "OOP Design", "Claim: Object-Oriented Design", "Medium", "Detail Single Responsibility, Open-Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion."),
            (f"What is the difference between Abstract Classes and Interfaces in Object-Oriented Programming?", "OOP Concepts", "Claim: OOP Core", "Low", "Abstract classes support state and default implementations; Interfaces enforce pure method contracts."),
            (f"How does Git rebase differ from Git merge, and when should you avoid rebasing?", "Version Control", "Claim: Git Proficiency", "Medium", "Git merge creates a commit combining branches; Git rebase rewrites commit history linearly. Avoid rebasing shared public branches."),
            (f"Explain the difference between process memory overhead and thread memory overhead.", "Operating Systems", "Claim: System Concepts", "High", "Processes have separate virtual address spaces (heavy); Threads share the process address space (lightweight)."),
            (f"What is the time complexity of searching in a Hash Table vs a Balanced Binary Search Tree?", "Data Structures", "Claim: Data Structures", "Medium", "Hash Table search is O(1) average / O(N) worst case; Balanced BST (AVL/Red-Black) is guaranteed O(log N).")
        ]

        for q, cat, claim, diff, ans in skills_q_templates:
            questions.append({
                "id": f"q_res_{q_id}",
                "question": q,
                "category": cat,
                "targeted_claim": claim,
                "difficulty": diff,
                "priority": "High Priority",
                "expected_answer_framework": ans,
                "what_evaluators_look_for": "Core technical knowledge, accuracy, and clear articulation of fundamentals."
            })
            q_id += 1

        # Category 3: Exaggeration & High-Risk Claim Defense (10 Questions)
        risk_q_templates = [
            ("Your resume claims Cloud Expertise (AWS/GCP). Explain IAM Roles vs IAM Users vs IAM Policies.", "Cloud Security Risk", "Claim: Cloud Expertise", "High", "IAM Users are long-term credentials; Roles grant temporary permissions via STS; Policies specify JSON permissions."),
            ("How do VPC Public Subnets and Private Subnets differ, and how does a private instance access the internet?", "Cloud Networking Risk", "Claim: AWS/Cloud", "High", "Public subnets have direct Internet Gateway routes; Private subnets route outbound traffic via a NAT Gateway in a public subnet."),
            ("Your resume claims Docker & Containerization. How do multi-stage Docker builds reduce image size?", "Docker Optimization", "Claim: Production Docker", "Medium", "Separate build dependencies (compilers, SDKs) from the final slim runtime stage (alpine/distroless)."),
            ("How do Docker volume mounts differ from bind mounts, and which is preferred for production persistence?", "Docker Storage", "Claim: Docker Storage", "Medium", "Volumes are managed by Docker in host storage (/var/lib/docker) for production; Bind mounts map explicit host paths."),
            ("Your resume lists Microservices architecture. How do microservices handle distributed transactions without 2PC?", "Microservices Risk", "Claim: Microservices", "High", "Explain the Saga Pattern (Choreography/Orchestration) using compensating transactions to rollback multi-service steps."),
            ("How do you prevent Cascading Failures across microservices when a downstream dependency is slow?", "Resilience Patterns", "Claim: Microservices", "High", "Implement Circuit Breaker patterns (Resilience4j/Hystrix), bulkhead isolation, and aggressive request timeouts."),
            ("Your resume claims Database Optimization. How do transaction isolation levels (Read Committed vs Repeatable Read) work?", "Database Risk", "Claim: DB Tuning", "High", "Read Committed prevents Dirty Reads; Repeatable Read prevents Non-Repeatable Reads using MVCC snapshot isolation."),
            ("What is the N+1 Query Problem in ORMs (Hibernate/SQLAlchemy), and how do you resolve it?", "ORM Performance Risk", "Claim: ORM Usage", "High", "N+1 occurs when fetching child relations in a loop. Resolve using JOIN FETCH or eager eager loading."),
            ("Your resume claims High-Throughput APIs. How do you implement Rate Limiting to prevent API abuse?", "API Security Risk", "Claim: API Scaling", "Medium", "Implement Token Bucket or Leaky Bucket algorithms in API Gateways or Redis sliding window logs."),
            ("Your resume lists Redis / In-Memory Caching. What happens when Redis memory is full under maxmemory limit?", "Caching Risk", "Claim: Redis Caching", "High", "Explain eviction policies: volatile-lru, allkeys-lru, noeviction (returns error), and Redis persistence (RDB/AOF).")
        ]

        for q, cat, claim, diff, ans in risk_q_templates:
            questions.append({
                "id": f"q_res_{q_id}",
                "question": q,
                "category": cat,
                "targeted_claim": claim,
                "difficulty": diff,
                "priority": "Critical Grilling Point",
                "expected_answer_framework": ans,
                "what_evaluators_look_for": "Verifying whether resume claims reflect hands-on production experience or superficial tutorial knowledge."
            })
            q_id += 1

        # Category 4: Experience, Behavioral & Pitch Questions (10 Questions)
        behavioral_q_templates = [
            ("Walk me through a 2-minute architectural pitch of the single best project on your resume.", "Architectural Pitch", "Resume Summary", "Medium", "State problem statement, tech stack choice, key individual contribution, and quantifiable outcome."),
            ("Describe a critical production bug or technical roadblock you faced in your project. How did you resolve it?", "Problem Solving", "Work / Project History", "Medium", "Use STAR method: Situation, Task, Action (debugging tools used), and Result (prevention added)."),
            ("How did you handle technical disagreements or code review feedback with team members?", "Collaboration", "Teamwork Experience", "Low", "Focus on objective data, performance benchmarks, constructive discussion, and alignment with project goals."),
            ("Why did you select the specific database (SQL vs NoSQL) for your main resume project?", "Design Decisions", "Project Architecture", "Medium", "Explain data structure requirements, relational integrity vs schema flexibility, and query patterns."),
            ("How did you ensure security against SQL Injection and XSS (Cross-Site Scripting) in your web applications?", "Application Security", "Web Security", "Medium", "Parameterized SQL queries / ORMs prevent SQL Injection; Escaping output HTML and Content Security Policy (CSP) prevent XSS."),
            ("What was the most complex debugging session you conducted, and what tools (profilers, logs) did you use?", "Debugging Skills", "Technical Execution", "High", "Detail log analysis, browser DevTools / APM profilers, reproducing edge cases, and root cause verification."),
            ("If you had an extra month to work on your resume project, what architectural improvements would you make?", "Refactoring & Vision", "Project Defense", "Medium", "Discuss adding automated CI/CD pipelines, caching layers, container orchestration, or enhanced test coverage."),
            ("How do you stay updated with modern software engineering practices and new framework updates?", "Continuous Learning", "Professional Growth", "Low", "Mention tech blogs, reading official documentation, open-source repositories, and building side projects."),
            ("Describe how you break down a complex requirement or user story into small, testable tasks.", "Agile & Planning", "Workflow Execution", "Low", "Detail requirement analysis, API spec definition, DB schema modeling, modular coding, and unit test verification."),
            ("Why are you a strong fit for this target engineering role based on the experience on your resume?", "Role Alignment", "Resume Overview", "Medium", "Synthesize your core technical skills, hands-on project delivery, and eagerness to contribute to production software.")
        ]

        for q, cat, claim, diff, ans in behavioral_q_templates:
            questions.append({
                "id": f"q_res_{q_id}",
                "question": q,
                "category": cat,
                "targeted_claim": claim,
                "difficulty": diff,
                "priority": "Core Behavioral",
                "expected_answer_framework": ans,
                "what_evaluators_look_for": "Communication clarity, technical maturity, problem-solving mindset, and authenticity."
            })
            q_id += 1

        return questions

    async def generate_company_profile(self, company_name: str) -> Dict[str, Any]:
        short_name = company_name.split()[0][:6]
        return {
            "id": f"comp_{short_name.lower()}",
            "name": company_name,
            "short_name": short_name,
            "category": "Technology Company",
            "color_hex": "#1F4388",
            "hiring_programs": [
                {
                    "id": f"{short_name.lower()}_sde",
                    "name": "Software Engineer",
                    "role": "Software Engineer",
                    "package_lpa": "5.0 - 8.0 LPA",
                    "difficulty": "Medium",
                    "rounds_count": 3,
                    "overview": f"Standard software engineering hiring track for {company_name}.",
                    "typical_rounds": [
                        "Online Coding Assessment",
                        "Technical Interview",
                        "HR Interview"
                    ]
                }
            ]
        }

    async def analyze_interview_process(
        self, company: str, hiring_program: str, role: str, experience: str, location: str
    ) -> Dict[str, Any]:
        return get_process_for_track(company, hiring_program, role, experience, location)

    async def generate_questions(
        self,
        job_data: Dict[str, Any],
        resume_data: Optional[Dict[str, Any]],
        count: int = 50,
        category: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        company_name = job_data.get("company", "TechCorp Global")
        hiring_program = job_data.get("hiring_program", "")
        role = job_data.get("job_title", "Software Engineer")
        return get_company_questions(company_name, hiring_program, role, count=count)


    async def evaluate_mock_answer(
        self, question: str, candidate_answer: str, role_context: Dict[str, Any]
    ) -> Dict[str, Any]:
        words = candidate_answer.split()
        word_count = len(words)
        lower_ans = candidate_answer.lower()

        # Extensive technical & domain keyword extractor
        tech_keywords = [
            "python", "java", "c++", "cpp", "c", "c#", ".net", "go", "golang", "rust", "swift", "kotlin",
            "javascript", "typescript", "php", "ruby", "scala", "r", "html", "css", "react", "vue", "angular",
            "svelte", "next.js", "node", "express", "django", "fastapi", "flask", "spring", "flutter", "dart",
            "sql", "postgresql", "mysql", "sqlite", "mongodb", "redis", "kafka", "docker", "kubernetes",
            "aws", "gcp", "azure", "git", "rest", "graphql", "microservices", "ci/cd", "machine learning",
            "ml", "ai", "pytorch", "tensorflow", "dsa", "algo", "data structure", "leetcode", "system design",
            "oop", "testing", "async", "concurrency", "thread", "index", "cache", "state", "security", "auth"
        ]

        found_techs = [t.title() for t in tech_keywords if re.search(r"\b" + re.escape(t) + r"\b", lower_ans)]
        
        # Filler word scanner
        fillers = []
        for f in ["um", "uh", "like", "you know", "actually", "basically", "so yeah"]:
            if f in lower_ans:
                fillers.append(f)

        # 1. NON-ANSWER / ONE-WORD / YES-NO DETECTOR (CRITICAL REQUIREMENT)
        non_answer_triggers = [
            "yes", "no", "ok", "okay", "yeah", "nope", "idk", "i don't know", "dont know", "nah",
            "maybe", "sure", "no idea", "fine", "nothing", "pass", "nil", "none", "good", "bad"
        ]
        is_single_word_non_answer = (lower_ans in non_answer_triggers) or (
            word_count <= 2 and not found_techs and lower_ans not in ["hi", "hello", "hey", "ready"]
        )

        if is_single_word_non_answer:
            return {
                "technical_accuracy": 2,
                "completeness": 1,
                "relevance": 2,
                "structure": 1,
                "clarity": 4,
                "overall_score": 2.0,
                "filler_words": fillers,
                "pacing_feedback": f"CRITICAL EVALUATION FAILURE: Answering with '{candidate_answer}' is inadequate for a technical interview. Interviewers expect detailed explanations, architecture, or code.",
                "what_you_did_well": [
                    "Responded to the prompt, but single-word answers carry zero technical weight."
                ],
                "what_is_missing": [
                    f"Failed to provide any technical explanation or reasoning for '{candidate_answer}'.",
                    "Omitted key concepts, data structures, frameworks, or project examples."
                ],
                "how_to_improve": [
                    "NEVER answer technical interview questions with a simple 'Yes', 'No', or one-word response.",
                    "Always structure your response: Technical Definition -> Implementation Strategy -> Concrete Example."
                ],
                "what_you_should_not_do": [
                    f"DO NOT give single-word answers like '{candidate_answer}' in an interview.",
                    "DO NOT skip explaining your technical reasoning or engineering choices.",
                    "DO NOT assume the interviewer knows your background without explicitly stating your tools and approaches."
                ],
                "better_answer_structure": "I would approach this requirement by first evaluating the core constraints... Then, I would choose Python/SQL to implement... This guarantees scalability and reliability.",
                "what_can_they_ask_next": [
                    "Can you elaborate on your technical background and what engineering projects you have built?",
                    "What specific programming languages and frameworks do you use day-to-day?",
                    "How would you solve a complex technical problem step-by-step?"
                ]
            }

        is_greeting = any(g in lower_ans for g in ["hi", "hello", "hey", "good morning", "good afternoon", "ready"])

        if is_greeting and word_count <= 8 and not found_techs:
            return {
                "technical_accuracy": 6,
                "completeness": 5,
                "relevance": 8,
                "structure": 7,
                "clarity": 9,
                "overall_score": 6.8,
                "filler_words": fillers,
                "pacing_feedback": "Friendly opening! Next, follow up with a 30-60 second introduction of your tech stack.",
                "what_you_did_well": [
                    "Polite and professional interview opening.",
                    "Engaged ready for the technical assessment."
                ],
                "what_is_missing": [
                    "Follow up your greeting with your primary tech stack (e.g. Python, Flutter, SQL, C++).",
                    "Mention your key engineering background or project experience."
                ],
                "how_to_improve": [
                    "Structure your self-introduction as: Greeting -> Core Tech Stack -> Key Project -> Objective."
                ],
                "what_you_should_not_do": [
                    "DO NOT stop at just a greeting like 'Hi'.",
                    "DO NOT wait for the interviewer to prompt you before introducing your core tech stack (e.g., Python, SQL, Flutter).",
                    "DO NOT leave your introduction vague without highlighting a specific project."
                ],
                "better_answer_structure": "Hi! I am a Software Engineer specializing in backend APIs and data structures. I recently built a real-time web platform.",
                "what_can_they_ask_next": [
                    "What programming languages and frameworks are you most proficient in?",
                    "Can you walk me through the architecture of your most recent project?",
                    "How do you approach solving complex algorithmic problems?"
                ]
            }

        # Extract project/domain phrase if user mentions building or working on something
        project_match = re.search(r"(?:built|created|developed|worked on|made|designed|using|with)\s+([a-zA-Z0-9\s\-]{4,30})", lower_ans)
        extracted_domain = project_match.group(1).strip().title() if project_match else None

        if found_techs or extracted_domain:
            tech_str = ", ".join(found_techs[:3]) if found_techs else (extracted_domain or "your highlighted project")
            accuracy = 8 if (len(found_techs) >= 2 or word_count >= 20) else 7
            completeness = 8 if word_count >= 25 else 6
            structure = 8 if any(w in lower_ans for w in ["first", "because", "implemented", "used", "designed", "built"]) else 7
            clarity = 8 if len(fillers) <= 1 else 6
            relevance = 9

            overall = round((accuracy + completeness + structure + clarity + relevance) / 5.0, 1)

            main_topic = found_techs[0] if found_techs else tech_str

            return {
                "technical_accuracy": accuracy,
                "completeness": completeness,
                "relevance": relevance,
                "structure": structure,
                "clarity": clarity,
                "overall_score": overall,
                "filler_words": fillers,
                "pacing_feedback": "Good technical depth! Keep spoken responses structured between 60 and 90 seconds." if word_count > 25 else f"Concise response regarding {main_topic}; elaborate on your architecture choices.",
                "what_you_did_well": [
                    f"Relevant technical reference to {tech_str} in your answer.",
                    "Demonstrated practical software engineering awareness."
                ],
                "what_is_missing": [
                    f"Could provide specific performance metrics or edge-case handling for {main_topic}.",
                    "Did not detail failure recovery or test automation."
                ],
                "how_to_improve": [
                    f"Anchor your answer in a specific production scenario using {main_topic}.",
                    "Follow the structure: Problem -> Technical Action -> Trade-off -> Result."
                ],
                "what_you_should_not_do": [
                    f"DO NOT present your {main_topic} solution without explaining edge-case handling.",
                    "DO NOT use generic terms without specifying exact tools, frameworks, or database schemas.",
                    "DO NOT rush your explanation without discussing failure recovery mechanisms."
                ],
                "better_answer_structure": f"In my recent work, I utilized {main_topic} to address the requirements. First, I structured the data flow... Second, I optimized execution... This ensured high performance under peak load.",
                "what_can_they_ask_next": [
                    f"How would you scale your {main_topic} setup if user traffic increased 10x?",
                    f"What architectural trade-offs made you choose {main_topic} over alternative solutions?",
                    f"How do you debug production bottlenecks in your {main_topic} environment?"
                ]
            }
        else:
            accuracy = 6
            completeness = 5 if word_count >= 20 else 4
            structure = 5
            clarity = 7 if len(fillers) <= 1 else 5
            relevance = 6 if word_count >= 10 else 4

            overall = round((accuracy + completeness + structure + clarity + relevance) / 5.0, 1)

            snippet = candidate_answer[:30] + "..." if len(candidate_answer) > 30 else candidate_answer

            return {
                "technical_accuracy": accuracy,
                "completeness": completeness,
                "relevance": relevance,
                "structure": structure,
                "clarity": clarity,
                "overall_score": overall,
                "filler_words": fillers,
                "pacing_feedback": f"Responded to prompt ('{snippet}'). Incorporate specific technical tools, data structures, or frameworks.",
                "what_you_did_well": [
                    "Responded directly to the interviewer.",
                    "Maintained a conversational tone."
                ],
                "what_is_missing": [
                    "Lacks specific technical vocabulary (e.g. data structures, APIs, database design).",
                    "No concrete production project example mentioned."
                ],
                "how_to_improve": [
                    "Mention specific tools, algorithms, or design patterns you used.",
                    "Use STAR format: Situation -> Task -> Technical Action -> Outcome."
                ],
                "what_you_should_not_do": [
                    "DO NOT give vague responses without naming specific languages or frameworks.",
                    "DO NOT skip describing the technical architecture or project details.",
                    "DO NOT omit trade-off discussions when asked how you solved an engineering problem."
                ],
                "better_answer_structure": "I addressed this requirement by designing a modular architecture. I selected core tech for data persistence, applied optimization to reduce latency, and achieved robust system performance.",
                "what_can_they_ask_next": [
                    "What primary programming languages and tools do you use day-to-day?",
                    "Can you describe a complex technical bug you diagnosed and fixed?",
                    "How do you approach learning a new technology or framework quickly?"
                ]
            }

    async def generate_next_mock_question(
        self, history: List[Dict[str, Any]], role_context: Dict[str, Any], mode: str, difficulty: str
    ) -> Dict[str, str]:
        last_answer = history[-1]["answer"] if history else ""
        lower_ans = last_answer.lower()
        words = lower_ans.split()

        # Check for greeting first
        if any(g in lower_ans for g in ["hi", "hello", "hey", "ready"]) and len(words) <= 8:
            return {
                "interviewer_question": "Welcome to your IntervueX AI Technical Interview! To kick off, walk me through your engineering background: What is your primary tech stack, and what was the architecture of your recent project?",
                "question_category": "Technical Introduction"
            }

        # 1. Broad domain map (100+ topics)
        domain_questions = {
            "c++": ("C++ & Systems", f"You mentioned C++ ('{last_answer[:50]}...'). How do you manage memory allocation, smart pointers (unique_ptr vs shared_ptr), and prevent dangling pointers or buffer overflows?"),
            "cpp": ("C++ & Systems", f"Following up on C++ ('{last_answer[:50]}...'): How do RAII principles and move semantics optimize performance in memory-constrained applications?"),
            "c": ("C Programming", f"Regarding your C experience ('{last_answer[:50]}...'): How do stack vs heap memory allocation work under the hood, and how do you handle pointer arithmetic safely?"),
            "java": ("Java & Core OOP", f"Building on your Java background ('{last_answer[:50]}...'): How does the JVM Garbage Collector work, and what is the difference between abstract classes and interfaces in system design?"),
            "python": ("Python Core & Async", f"You highlighted Python ('{last_answer[:50]}...'): How does the Global Interpreter Lock (GIL) impact concurrency, and when do you choose multiprocessing over asyncio?"),
            "django": ("Django Web Framework", f"Regarding Django ('{last_answer[:50]}...'): How do you optimize ORM queries to eliminate N+1 query problems and structure custom middleware?"),
            "fastapi": ("FastAPI & Microservices", f"Following up on FastAPI ('{last_answer[:50]}...'): How do Pydantic schemas enforce request validation, and how do async endpoint handlers improve throughput?"),
            "javascript": ("JavaScript & Event Loop", f"You mentioned JavaScript ('{last_answer[:50]}...'): Can you explain the Event Loop, call stack, microtask queue, and how Promises execute under the hood?"),
            "typescript": ("TypeScript & Types", f"Regarding TypeScript ('{last_answer[:50]}...'): How do generics, union types, and interface contracts improve reliability during compile-time verification?"),
            "react": ("React & UI Architecture", f"Building on your React experience ('{last_answer[:50]}...'): How does the Virtual DOM reconciliation algorithm work, and how do you optimize rendering with custom hooks?"),
            "flutter": ("Flutter & Mobile", f"You highlighted Flutter ('{last_answer[:50]}...'): How do you manage application state (Riverpod / Provider / BLoC) and optimize widget tree rebuilds for 60fps performance?"),
            "dart": ("Dart Specs", f"Regarding Dart ('{last_answer[:50]}...'): How do Dart isolates handle concurrent processing without shared memory, and how does sound null safety protect apps?"),
            "node": ("Node.js Backend", f"Following up on Node.js ('{last_answer[:50]}...'): How does the single-threaded event loop handle non-blocking I/O operations and prevent thread pool starvation?"),
            "sql": ("SQL & Relational Databases", f"You mentioned SQL ('{last_answer[:50]}...'): How do B-Tree indexes accelerate query execution, and how do you write complex JOIN queries using window functions like ROW_NUMBER()?"),
            "postgres": ("PostgreSQL Engine", f"Building on PostgreSQL ('{last_answer[:50]}...'): How do MVCC transaction isolation levels work, and how do you diagnose slow queries using EXPLAIN ANALYZE?"),
            "mysql": ("MySQL Storage", f"Regarding MySQL ('{last_answer[:50]}...'): What is the architectural difference between InnoDB and MyISAM engines, and how do transaction locks operate?"),
            "mongo": ("MongoDB NoSQL", f"You highlighted MongoDB ('{last_answer[:50]}...'): How do document data models differ from relational schemas, and how do you construct aggregation pipelines?"),
            "redis": ("Redis Caching", f"Following up on Redis ('{last_answer[:50]}...'): How do you configure caching patterns (Cache-Aside, Write-Through) and manage key eviction policies under high memory pressure?"),
            "kafka": ("Kafka Streaming", f"Regarding Apache Kafka ('{last_answer[:50]}...'): How do topic partitions, consumer groups, and offset commits guarantee message ordering and fault tolerance?"),
            "docker": ("Docker Containerization", f"Building on Docker ('{last_answer[:50]}...'): How do multi-stage Dockerfiles minimize container footprint, and how do you isolate network bridges between containers?"),
            "kubernetes": ("Kubernetes", f"You mentioned Kubernetes ('{last_answer[:50]}...'): How do Pods, Ingress controllers, and Horizontal Pod Autoscalers maintain application availability under peak loads?"),
            "aws": ("AWS Cloud", f"Regarding AWS ('{last_answer[:50]}...'): How do you architect a secure VPC with public/private subnets, IAM least privilege policies, and S3 bucket security?"),
            "machine learning": ("Machine Learning", f"Building on your ML work ('{last_answer[:50]}...'): How do you detect and mitigate overfitting, handle imbalanced datasets, and evaluate model F1 scores?"),
            "ml": ("Machine Learning & Data", f"Following up on Machine Learning ('{last_answer[:50]}...'): What feature scaling and model selection techniques do you apply prior to training production pipelines?"),
            "ai": ("AI & LLMs", f"You mentioned AI ('{last_answer[:50]}...'): How do Retrieval-Augmented Generation (RAG), vector embeddings, and prompt engineering enhance accuracy in domain-specific tasks?"),
            "pytorch": ("PyTorch Deep Learning", f"Regarding PyTorch ('{last_answer[:50]}...'): How does autograd manage backpropagation graphs, and how do you optimize custom GPU DataLoader pipelines?"),
            "tensorflow": ("TensorFlow", f"Building on TensorFlow ('{last_answer[:50]}...'): How do static vs dynamic computation graphs differ, and how do you apply transfer learning on pre-trained models?"),
            "dsa": ("Algorithms & DSA", f"Following up on DSA ('{last_answer[:50]}...'): How do you evaluate Time and Space complexity trade-offs, and when would you choose a Graph or Trie over a Hash Map?"),
            "leetcode": ("Algorithmic Strategy", f"Regarding problem solving ('{last_answer[:50]}...'): What is your step-by-step strategy for identifying algorithmic patterns (Sliding Window, Dynamic Programming, Two Pointers)?"),
            "git": ("Git Version Control", f"You mentioned Git ('{last_answer[:50]}...'): What is the core structural difference between git merge and git rebase, and how do you resolve merge conflicts safely?"),
            "security": ("App Security", f"Building on Security ('{last_answer[:50]}...'): How do you protect application endpoints against OWASP threats like SQL Injection, XSS, and CSRF?"),
            "auth": ("Authentication", f"Following up on Authentication ('{last_answer[:50]}...'): How do JWT tokens compare to session-based auth, and how do you implement secure refresh token rotation?"),
            "microservices": ("Distributed Systems", f"Regarding Microservices ('{last_answer[:50]}...'): How do you manage distributed transactions (Saga pattern), service discovery, and circuit breaking in microservices?"),
            "system design": ("System Architecture", f"Building on System Design ('{last_answer[:50]}...'): How do you approach load balancing, database sharding, and CDN static asset caching for 1M+ daily active users?"),
            "api": ("API Engineering", f"You highlighted APIs ('{last_answer[:50]}...'): What RESTful design principles (idempotency, HTTP status codes, rate limiting) do you follow when building scalable public APIs?"),
        }

        # Sort domain keys by length descending so longer keys (e.g. "c++", "machine learning") match before shorter keys ("c", "ml")
        sorted_domains = sorted(domain_questions.items(), key=lambda x: len(x[0]), reverse=True)

        for key, (cat, q_text) in sorted_domains:
            pattern = r"\b" + re.escape(key) + (r"\b" if key[-1].isalnum() else "")
            if re.search(pattern, lower_ans):
                return {
                    "interviewer_question": q_text,
                    "question_category": cat
                }

        # 2. Match project / domain phrase if user describes building something specific
        proj_match = re.search(r"(?:built|created|developed|worked on|made|designed|using|with)\s+([a-zA-Z0-9\s\-]{4,35})", lower_ans)
        if proj_match:
            project_name = proj_match.group(1).strip()
            return {
                "interviewer_question": f"You mentioned working on your '{project_name}' ('{last_answer[:55]}...'). Walk me through the technical architecture: What database schema did you design, and how did you structure your API endpoints?",
                "question_category": "Project Architecture & Design"
            }

        # 3. Dynamic fallback quoting candidate's exact response
        snippet = last_answer[:45] + "..." if len(last_answer) > 45 else last_answer
        words_len = len(words)

        if words_len > 15:
            return {
                "interviewer_question": f"Thanks for explaining that ('{snippet}'). In a production environment, suppose system throughput spikes by 10x and latency increases. What is your diagnostic workflow to isolate and fix the bottleneck?",
                "question_category": "System Reliability & Optimization"
            }
        elif words_len > 5:
            return {
                "interviewer_question": f"Building on your point ('{snippet}'): Can you detail the specific technical tools, programming languages, or algorithms you used to implement this solution?",
                "question_category": "Technical Implementation"
            }
        else:
            return {
                "interviewer_question": f"You mentioned '{last_answer}'. To probe deeper: What primary programming languages, frameworks, or database systems have you used in your engineering projects?",
                "question_category": "Core Engineering Stack"
            }



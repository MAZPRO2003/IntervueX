from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
from app.schemas.resume import ResumeAnalysisResult
from app.services.parsers.resume_parser import ResumeParser
from app.services.ai.factory import get_ai_service
from app.services.db.store import db_store

router = APIRouter()

@router.post("/analyze", response_model=ResumeAnalysisResult)
async def analyze_resume(
    raw_text: Optional[str] = Form(None),
    job_id: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None)
):
    extracted_text = ""
    if file:
        filename = file.filename.lower()
        content = await file.read()
        if filename.endswith(".pdf"):
            extracted_text = ResumeParser.extract_from_pdf(content)
        elif filename.endswith(".docx"):
            extracted_text = ResumeParser.extract_from_docx(content)
        else:
            try:
                extracted_text = content.decode("utf-8")
            except Exception:
                raise HTTPException(status_code=400, detail="Unsupported resume format. Please upload PDF, DOCX, or text.")
    elif raw_text:
        extracted_text = raw_text
    else:
        raise HTTPException(status_code=400, detail="Must provide resume file or raw text.")

    job_context = db_store.get_job(job_id) if job_id else None
    ai = get_ai_service()
    resume_dict = await ai.analyze_resume(extracted_text, job_context=job_context)
    db_store.save_resume(resume_dict)
    return ResumeAnalysisResult(**resume_dict)

@router.get("/risk_map")
async def get_resume_risk_map(resume_id: Optional[str] = None):
    # Generates structured risk highlight overlays for PDF visual inspector
    return {
        "resume_id": resume_id or "res_demo_1",
        "candidate_name": "Senior Full-Stack Candidate",
        "total_risks_found": 5,
        "risk_highlights": [
            {
                "id": "rh_1",
                "page": 1,
                "severity": "high_risk", # high_risk, medium_warning, verified_strength
                "claim_text": "Architected real-time microservices handling millions of users.",
                "y_percent": 22.5,
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 4.5,
                "flag_category": "Vague Metrics",
                "why_flagged": "Claims 'millions of users' without specifying requests per second (RPS), database QPS, or infrastructure topology.",
                "interviewer_probe_question": "What was your actual peak RPS during high-traffic events, and how did your DB connection pool handle it?",
                "suggested_rewrite": "Architected Python/FastAPI microservices processing 45,000 requests/sec with Redis caching, reducing DB load by 72%."
            },
            {
                "id": "rh_2",
                "page": 1,
                "severity": "high_risk",
                "claim_text": "Expert in Kubernetes, Docker, Terraform, Kafka, Postgres, Redis, GraphQL, AWS, GCP, PyTorch.",
                "y_percent": 38.0,
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 5.0,
                "flag_category": "Buzzword Stuffing",
                "why_flagged": "Lists 10 disparate infrastructure and ML technologies without attaching production achievements to each.",
                "interviewer_probe_question": "How did you manage Kafka partition rebalancing under consumer failures in your Kubernetes cluster?",
                "suggested_rewrite": "Managed 12-node EKS Kubernetes cluster running Kafka stream consumers processing 2TB daily log telemetry."
            },
            {
                "id": "rh_3",
                "page": 1,
                "severity": "medium_warning",
                "claim_text": "Optimized database queries for improved performance.",
                "y_percent": 54.0,
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 4.0,
                "flag_category": "Missing Impact",
                "why_flagged": "Vague improvement claim without quantifiable latency or execution time metrics.",
                "interviewer_probe_question": "Which specific query or index did you optimize, and what was the latency before and after?",
                "suggested_rewrite": "Added B-Tree composite index on (user_id, created_at), reducing P99 API response latency from 680ms to 42ms."
            },
            {
                "id": "rh_4",
                "page": 1,
                "severity": "verified_strength",
                "claim_text": "Reduced CI/CD build pipeline execution time from 28 minutes to 4.5 minutes using Docker layer caching.",
                "y_percent": 68.0,
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 4.5,
                "flag_category": "Quantified Achievement",
                "why_flagged": "High quality bullet point with clear metric baseline and method used.",
                "interviewer_probe_question": "How did you configure multi-stage Docker build caches in your GitHub Actions runner pool?",
                "suggested_rewrite": "Keep exact wording - excellent production impact showcase."
            },
            {
                "id": "rh_5",
                "page": 1,
                "severity": "medium_warning",
                "claim_text": "Led a team of engineers to deliver product features on time.",
                "y_percent": 82.0,
                "x_percent": 10.0,
                "width_percent": 80.0,
                "height_percent": 4.0,
                "flag_category": "Unclear Scope",
                "why_flagged": "Does not specify team size, project scope, sprint methodology, or engineering deliverables.",
                "interviewer_probe_question": "How many direct reports did you lead, and how did you manage sprint scope creep?",
                "suggested_rewrite": "Led a cross-functional squad of 5 engineers delivering 4 major releases using 2-week Agile sprints."
            }
        ]
    }


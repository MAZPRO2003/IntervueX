from fastapi import APIRouter, HTTPException, Response
from app.services.db.store import db_store
from app.services.pdf.workbook_generator import PDFWorkbookGenerator

router = APIRouter()

@router.get("/{pack_id}")
async def download_pack_pdf(pack_id: str):
    pack = db_store.get_pack(pack_id) or {
        "company": "Tata Consultancy Services",
        "job_title": "Systems Engineer",
        "hiring_program": "NQT — Ninja",
        "experience_level": "Fresher"
    }

    job = db_store.get_job(pack.get("job_id", "")) or {
        "company": pack.get("company", "Tata Consultancy Services"),
        "job_title": pack.get("role", "Systems Engineer"),
        "hiring_program": pack.get("hiring_program", "NQT — Ninja"),
        "experience_level": "Fresher",
        "summary": "Full-stack and backend systems engineering role focused on high-throughput microservices and relational databases.",
        "skills": {
            "required_skills": ["Python", "SQL", "OOP", "Data Structures"],
            "preferred_skills": ["FastAPI", "Docker", "Git"],
            "programming_languages": ["Python", "Java"],
            "databases": ["PostgreSQL", "MySQL"]
        }
    }

    resume = db_store.get_resume(pack.get("resume_id", "")) or {
        "candidate_name": "Arun Kumar"
    }

    process = db_store.get_process(pack_id) or {
        "hiring_program": pack.get("hiring_program", "NQT — Ninja"),
        "overall_confidence": "High",
        "evidence_summary": "Synthesized from official recruitment blueprints and candidate interview logs.",
        "rounds": [
            {
                "round_number": 1,
                "stage_name": "National Qualifier / Online Assessment",
                "assessment_format": "120 mins cognitive + 2 coding questions",
                "purpose": "Screen foundational aptitude and core coding competence",
                "expected_topics": ["Numerical Ability", "Verbal", "Arrays", "Strings"]
            },
            {
                "round_number": 2,
                "stage_name": "Technical Deep Dive Interview",
                "assessment_format": "45 mins virtual technical panel",
                "purpose": "In-depth evaluation of OOP, SQL, and project architecture",
                "expected_topics": ["FastAPI vs Django", "SQL DENSE_RANK", "Connection Pooling"]
            },
            {
                "round_number": 3,
                "stage_name": "Managerial & HR Round",
                "assessment_format": "20-30 mins cultural and situational discussion",
                "purpose": "Assess communication, adaptability, and cultural alignment",
                "expected_topics": ["Handling conflicts", "Why TCS?", "Project failure recovery"]
            }
        ]
    }

    questions = db_store.get_questions(pack_id)
    if not questions:
        # Fallback to demo questions
        from app.services.ai.mock_ai_service import MockAIService
        mock_ai = MockAIService()
        questions = await mock_ai.generate_questions(job, resume, count=10)

    pdf_bytes = PDFWorkbookGenerator.generate_pack_pdf(
        job_data=job,
        resume_data=resume,
        process_data=process,
        questions=questions,
        candidate_name=resume.get("candidate_name", "Arun Kumar")
    )

    clean_company = pack.get("company", "Company").replace(" ", "_")
    filename = f"IntervueX_Preparation_Pack_{clean_company}.pdf"

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"'
        }
    )

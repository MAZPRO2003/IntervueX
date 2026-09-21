from fastapi import APIRouter
from app.api.v1.endpoints import jobs, resumes, packs, questions, mock, study_plan, pdf, feedback, companies, discovery

api_router = APIRouter()
api_router.include_router(companies.router, prefix="/companies", tags=["Companies & Tracks"])
api_router.include_router(discovery.router, prefix="/discovery", tags=["Discovery"])
api_router.include_router(jobs.router, prefix="/jobs", tags=["Jobs"])
api_router.include_router(resumes.router, prefix="/resumes", tags=["Resumes"])
api_router.include_router(packs.router, prefix="/packs", tags=["Interview Packs"])
api_router.include_router(questions.router, prefix="/questions", tags=["Questions"])
api_router.include_router(mock.router, prefix="/mock", tags=["Mock Interview"])
api_router.include_router(study_plan.router, prefix="/study_plan", tags=["Study Plan"])
api_router.include_router(pdf.router, prefix="/pdf", tags=["PDF Workbook"])
api_router.include_router(feedback.router, prefix="/feedback", tags=["Feedback & Moderation"])

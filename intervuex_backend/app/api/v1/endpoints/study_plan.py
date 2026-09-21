from fastapi import APIRouter, HTTPException
from typing import Dict, Any, List, Optional
from datetime import date, timedelta, datetime
from pydantic import BaseModel

from app.services.db.store import db_store
from app.schemas.study_plan import StudyPlan

router = APIRouter()

class SetTargetDateRequest(BaseModel):
    target_date: str # YYYY-MM-DD format

def build_dynamic_day_schedule(total_days: int, start_date: Optional[date] = None) -> List[Dict[str, Any]]:
    if not start_date:
        start_date = date.today()

    total_days = max(1, min(60, total_days))

    curriculum = [
        {
            "title": "Core Language & OOP Pillars",
            "focus": ["Python / C++ Core", "OOP Pillars", "Inheritance vs Composition"],
            "tasks": ["Practice top 10 OOP questions", "Review method overriding & abstraction"],
            "category": "OOP"
        },
        {
            "title": "Database Architecture & SQL Deep Dive",
            "focus": ["Complex Joins", "DENSE_RANK()", "B-Tree Indexes", "ACID Transactions"],
            "tasks": ["Write SQL subqueries & JOINs", "Practice query execution plan optimization"],
            "category": "SQL"
        },
        {
            "title": "Resume Claims & Project Architecture Defense",
            "focus": ["Project Architecture", "Framework Choices", "Concurrency & Threading"],
            "tasks": ["Rehearse 30s, 60s, 2min project pitches", "Anticipate resume grilling questions"],
            "category": "Project Based"
        },
        {
            "title": "Coding & DSA Intensive Drill",
            "focus": ["Arrays & Strings", "Two Pointers", "Sliding Window", "Trees & Graphs"],
            "tasks": ["Solve 5 time-constrained coding questions", "Analyze Big-O complexity"],
            "category": "Coding"
        },
        {
            "title": "Company Values & HR Round Strategy",
            "focus": ["Why this Company?", "STAR Behavioral Method", "Cultural Alignment"],
            "tasks": ["Prepare 2 company project achievements", "Practice relocation & salary negotiation questions"],
            "category": "HR"
        },
        {
            "title": "AI Mock Interview Voice Simulation",
            "focus": ["Full Technical + HR 5-Turn Simulation"],
            "tasks": ["Complete 5-turn Voice Mock Interview", "Review pacing and filler word warnings"],
            "category": "Mock"
        },
        {
            "title": "Final Rapid Revision & Bookmarks",
            "focus": ["Most Asked Questions", "Spaced Revision Checklist", "Bookmarks"],
            "tasks": ["Review saved bookmark questions", "Complete final rapid revision drill"],
            "category": "Revision"
        }
    ]

    days = []
    for i in range(total_days):
        day_num = i + 1
        day_date = start_date + timedelta(days=i)
        date_fmt = day_date.strftime("%b %d")

        if total_days == 1:
            days.append({
                "day_number": 1,
                "title": f"1-Day Rapid Intensive Revision ({date_fmt})",
                "focus_topics": ["OOP", "SQL", "Projects", "Mock Interview"],
                "recommended_tasks": ["Practice top 10 Most Asked Questions", "Complete 5-turn AI Mock Interview"],
                "category_filter": "OOP",
                "estimated_minutes": 60,
                "is_completed": False
            })
        else:
            mod_idx = int((i / (total_days - 1)) * (len(curriculum) - 1)) if total_days > 1 else 0
            mod = curriculum[mod_idx]
            days.append({
                "day_number": day_num,
                "title": f"{mod['title']} ({date_fmt})",
                "focus_topics": mod["focus"],
                "recommended_tasks": mod["tasks"],
                "category_filter": mod["category"],
                "estimated_minutes": 45 if day_num < total_days else 60,
                "is_completed": False
            })

    return days



class ToggleTaskRequest(BaseModel):
    day_number: int
    task: str
    is_completed: bool

def recalculate_readiness_and_sync(pack_id: str) -> int:
    plan = db_store.get_study_plan(pack_id)
    if not plan:
        return 0

    pack = db_store.get_pack(pack_id)
    company_name = pack.get("company", "Target Company") if pack else "Target Company"

    days = plan.get("days", [])
    total_days = max(1, len(days))
    completed_days = sum(1 for d in days if d.get("is_completed"))

    total_tasks = 0
    completed_tasks = 0
    for d in days:
        tasks = d.get("recommended_tasks", [])
        c_tasks = d.get("completed_tasks", [])
        total_tasks += len(tasks)
        completed_tasks += len(c_tasks)

    questions = db_store.get_questions(company_name)
    mastered_count = sum(1 for q in questions if q.get("mastered", False))
    total_qs = max(1, len(questions))

    days_ratio = (completed_days / total_days)
    task_ratio = (completed_tasks / max(1, total_tasks)) if total_tasks > 0 else 0
    mastery_ratio = (mastered_count / total_qs)

    if completed_days == 0 and completed_tasks == 0 and mastered_count == 0:
        overall = 0
    else:
        overall = int((days_ratio * 70) + (task_ratio * 20) + (mastery_ratio * 10))
        overall = min(100, max(1, overall))

    plan["readiness"] = plan.get("readiness", {})
    plan["readiness"]["overall_percentage"] = overall
    plan["readiness"]["technical_score"] = min(100, int(overall * 1.05)) if overall > 0 else 0
    plan["readiness"]["sql_db_score"] = min(100, int(overall * 0.95)) if overall > 0 else 0
    plan["readiness"]["resume_score"] = min(100, int(overall * 1.1)) if overall > 0 else 0
    plan["readiness"]["project_score"] = overall
    plan["readiness"]["coding_score"] = min(100, int(overall * 0.98)) if overall > 0 else 0
    plan["readiness"]["hr_score"] = overall
    plan["readiness"]["company_score"] = min(100, int(overall * 1.02)) if overall > 0 else 0

    if completed_days > 0 or completed_tasks > 0:
        plan["readiness"]["next_best_action"] = f"Great progress! Complete Day {min(total_days, completed_days + 1)} tasks."
    else:
        plan["readiness"]["next_best_action"] = "Complete Day 1 check-in tasks to kickstart your preparation!"

    db_store.save_study_plan(plan)

    if pack:
        pack["readiness_percentage"] = overall
        pack["mastered_questions"] = mastered_count
        db_store.save_pack(pack)

    return overall


@router.get("/{pack_id}", response_model=StudyPlan)
async def get_study_plan(pack_id: str):
    plan = db_store.get_study_plan(pack_id)
    company_name = "Target Company"
    pack = db_store.get_pack(pack_id)
    if pack and pack.get("company"):
        company_name = pack.get("company")

    if not plan:
        target_date_str = pack.get("interview_date", "2026-09-27") if pack else "2026-09-27"
        try:
            target_dt = date.fromisoformat(target_date_str)
        except ValueError:
            target_dt = date.today() + timedelta(days=7)
            target_date_str = target_dt.isoformat()

        days_remaining = max(1, (target_dt - date.today()).days)

        default_days = build_dynamic_day_schedule(days_remaining, start_date=date.today())

        plan = {
            "id": f"plan_{pack_id}",
            "pack_id": pack_id,
            "duration_days": days_remaining,
            "interview_date": target_date_str,
            "days_remaining": days_remaining,
            "days": default_days,
            "spaced_revisions": [],
            "readiness": {
                "overall_percentage": 68,
                "technical_score": 70,
                "sql_db_score": 65,
                "resume_score": 75,
                "project_score": 68,
                "hr_score": 68,
                "coding_score": 67,
                "company_score": 70,
                "strong_areas": ["Ready to start"],
                "weak_areas": ["Needs assessment"],
                "next_best_action": "Complete Day 1 tasks to kickstart your preparation!"
            },
            "created_at": date.today().isoformat()
        }
        db_store.save_study_plan(plan)

    recalculate_readiness_and_sync(pack_id)
    plan = db_store.get_study_plan(pack_id)

    questions = db_store.get_questions(company_name)
    needs_review = [q for q in questions if not q.get("mastered") and q.get("is_saved")]
    if not needs_review:
        needs_review = [q for q in questions if not q.get("mastered")]

    revisions = []
    today_str = date.today().isoformat()
    for i, q in enumerate(needs_review[:3]):
        revisions.append({
            "id": f"rev_{q['id']}",
            "question_id": q["id"],
            "question_text": q.get("question", "Unknown Question"),
            "category": q.get("category", "General"),
            "weak_reason": "Needs review before interview",
            "interval_stage": "Due Today" if i == 0 else "Tomorrow",
            "due_date": today_str,
            "is_reviewed": False
        })
    plan["spaced_revisions"] = revisions
    return StudyPlan(**(plan or {}))

@router.post("/{pack_id}/set_target_date", response_model=StudyPlan)
async def set_target_date(pack_id: str, req: SetTargetDateRequest):
    plan = db_store.get_study_plan(pack_id)
    pack = db_store.get_pack(pack_id)

    try:
        target_dt = date.fromisoformat(req.target_date)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    today = date.today()
    days_diff = (target_dt - today).days
    days_remaining = max(1, days_diff)

    new_days = build_dynamic_day_schedule(days_remaining, start_date=today)

    if not plan:
        plan = {
            "id": f"plan_{pack_id}",
            "pack_id": pack_id,
            "readiness": {"overall_percentage": 0, "technical_score": 0, "sql_db_score": 0, "resume_score": 0, "project_score": 0, "hr_score": 0, "coding_score": 0, "company_score": 0, "strong_areas": [], "weak_areas": [], "next_best_action": f"Start your {days_remaining}-day plan!"},
            "created_at": today.isoformat()
        }

    plan["duration_days"] = days_remaining
    plan["days_remaining"] = days_remaining
    plan["interview_date"] = req.target_date
    plan["days"] = new_days
    db_store.save_study_plan(plan)

    if pack:
        pack["days_remaining"] = days_remaining
        pack["interview_date"] = req.target_date
        db_store.save_pack(pack)

    recalculate_readiness_and_sync(pack_id)
    updated_plan = db_store.get_study_plan(pack_id) or plan
    return StudyPlan(**updated_plan)

@router.post("/{pack_id}/complete_day/{day_number}")
async def complete_day(pack_id: str, day_number: int):
    plan = db_store.get_study_plan(pack_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Study plan not found.")
    for d in plan.get("days", []):
        if d.get("day_number") == day_number:
            d["is_completed"] = True
            rec = d.get("recommended_tasks", [])
            d["completed_tasks"] = list(dict.fromkeys(rec))
            break
    db_store.save_study_plan(plan)
    new_score = recalculate_readiness_and_sync(pack_id)
    return {"message": f"Day {day_number} marked completed.", "readiness_percentage": new_score, "study_plan": db_store.get_study_plan(pack_id)}

@router.post("/{pack_id}/uncomplete_day/{day_number}")
async def uncomplete_day(pack_id: str, day_number: int):
    plan = db_store.get_study_plan(pack_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Study plan not found.")
    for d in plan.get("days", []):
        if d.get("day_number") == day_number:
            d["is_completed"] = False
            break
    db_store.save_study_plan(plan)
    new_score = recalculate_readiness_and_sync(pack_id)
    return {"message": f"Day {day_number} marked incomplete.", "readiness_percentage": new_score, "study_plan": db_store.get_study_plan(pack_id)}

@router.post("/{pack_id}/toggle_task")
async def toggle_task(pack_id: str, req: ToggleTaskRequest):
    plan = db_store.get_study_plan(pack_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Study plan not found.")

    for d in plan.get("days", []):
        if d.get("day_number") == req.day_number:
            c_tasks = d.get("completed_tasks", [])
            if req.is_completed and req.task not in c_tasks:
                c_tasks.append(req.task)
            elif not req.is_completed and req.task in c_tasks:
                c_tasks.remove(req.task)
            d["completed_tasks"] = c_tasks

            rec_tasks = d.get("recommended_tasks", [])
            if rec_tasks and all(t in c_tasks for t in rec_tasks):
                d["is_completed"] = True
            elif not req.is_completed:
                d["is_completed"] = False
            break

    db_store.save_study_plan(plan)
    new_score = recalculate_readiness_and_sync(pack_id)
    return {"message": "Task updated.", "readiness_percentage": new_score, "study_plan": db_store.get_study_plan(pack_id)}

@router.get("/{pack_id}/daily_checkin")
async def get_daily_checkin(pack_id: str, day_number: Optional[int] = None):
    plan = db_store.get_study_plan(pack_id)
    pack = db_store.get_pack(pack_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Study plan not found.")

    days = plan.get("days", [])
    total_days = len(days)

    if day_number is not None and 1 <= day_number <= total_days:
        target_day_num = day_number
    else:
        target_day_num = 1
        for d in days:
            if not d.get("is_completed"):
                target_day_num = d.get("day_number", 1)
                break
        else:
            target_day_num = max(1, total_days)

    today_day = next((d for d in days if d.get("day_number") == target_day_num), days[0] if days else {})
    rec_tasks = today_day.get("recommended_tasks", [])
    comp_tasks = today_day.get("completed_tasks", [])

    # Identify uncompleted tasks carried forward from previous days
    carried_forward = []
    for d in days:
        if d.get("day_number") < target_day_num:
            d_num = d.get("day_number")
            d_rec = d.get("recommended_tasks", [])
            d_comp = d.get("completed_tasks", [])
            for t in d_rec:
                if t not in d_comp:
                    carried_forward.append({
                        "task": t,
                        "from_day": d_num,
                        "day_title": d.get("title", f"Day {d_num}")
                    })

    readiness = recalculate_readiness_and_sync(pack_id)

    return {
        "pack_id": pack_id,
        "company": pack.get("company", "Target Company") if pack else "Target Company",
        "hiring_program": pack.get("hiring_program", "") if pack else "",
        "current_day_number": target_day_num,
        "total_days": total_days,
        "today_title": today_day.get("title", f"Day {target_day_num}"),
        "today_focus_topics": today_day.get("focus_topics", []),
        "today_recommended_tasks": rec_tasks,
        "today_completed_tasks": comp_tasks,
        "carried_forward_tasks": carried_forward,
        "readiness_percentage": readiness,
        "is_day_completed": today_day.get("is_completed", False)
    }

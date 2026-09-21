from fastapi import APIRouter, HTTPException
from typing import Dict, Any
import uuid
from datetime import datetime

from app.schemas.mock import MockSessionCreate, MockSession, MockTurn, SubmitAnswerRequest, AnswerEvaluation
from app.services.db.store import db_store
from app.services.ai.factory import get_ai_service

router = APIRouter()

@router.post("/sessions", response_model=MockSession)
async def create_mock_session(req: MockSessionCreate):
    session_id = f"mock_{uuid.uuid4().hex[:8]}"
    pack = db_store.get_pack(req.pack_id) or {"role": "Software Engineer", "company": "TechCorp"}

    # Initial opening question based on mode
    opening_q = "Tell me about yourself, your engineering projects, and why you are targeting this role."
    opening_cat = "HR / Opening"
    if req.mode == "Technical":
        opening_q = "Walk me through your most complex technical project: what was the architecture and your primary technical contribution?"
        opening_cat = "Technical / Architecture"
    elif req.mode == "Coding":
        opening_q = "How would you design an algorithm to find the longest substring without repeating characters in O(N) time?"
        opening_cat = "Coding / DSA"

    first_turn = MockTurn(
        turn_index=1,
        interviewer_question=opening_q,
        question_category=opening_cat
    )

    session = MockSession(
        id=session_id,
        pack_id=req.pack_id,
        mode=req.mode,
        difficulty=req.difficulty,
        total_turns=req.total_turns,
        current_turn_index=1,
        is_completed=False,
        turns=[first_turn],
        created_at=datetime.utcnow().isoformat()
    )
    db_store.save_mock_session(session.model_dump())
    return session

@router.get("/sessions/{session_id}", response_model=MockSession)
async def get_mock_session(session_id: str):
    sess = db_store.get_mock_session(session_id)
    if not sess:
        raise HTTPException(status_code=404, detail="Mock session not found.")
    return MockSession(**sess)

@router.post("/submit_answer", response_model=MockSession)
async def submit_mock_answer(req: SubmitAnswerRequest):
    sess_dict = db_store.get_mock_session(req.session_id)
    if not sess_dict:
        raise HTTPException(status_code=404, detail="Mock session not found.")

    session = MockSession(**sess_dict)
    if session.is_completed:
        return session

    # Find the active turn
    current_turn = None
    for t in session.turns:
        if t.turn_index == req.turn_index:
            current_turn = t
            break

    if not current_turn:
        raise HTTPException(status_code=400, detail="Invalid turn index.")

    current_turn.candidate_answer = req.candidate_answer

    ai = get_ai_service()
    pack = db_store.get_pack(session.pack_id) or {"role": "Software Engineer", "company": "TechCorp"}

    # 1. Evaluate Candidate Answer
    eval_dict = await ai.evaluate_mock_answer(
        question=current_turn.interviewer_question,
        candidate_answer=req.candidate_answer,
        role_context=pack
    )
    current_turn.evaluation = AnswerEvaluation(**eval_dict)

    # 2. Check if we should advance to next question or complete
    if session.current_turn_index >= session.total_turns:
        session.is_completed = True
        scores = [t.evaluation.overall_score for t in session.turns if t.evaluation]
        avg = round(sum(scores) / len(scores), 1) if scores else 7.5
        session.average_score = avg
        session.final_feedback_summary = (
            f"Mock Interview Completed! Average Score: {avg}/10. "
            "You demonstrated solid technical vocabulary. Prioritize concise answers (60-90s) "
            "and focus on handling edge cases under pressure."
        )
    else:
        # Generate next dynamic question
        next_turn_idx = session.current_turn_index + 1
        history = [
            {"question": t.interviewer_question, "answer": t.candidate_answer}
            for t in session.turns if t.candidate_answer
        ]
        next_q_data = await ai.generate_next_mock_question(
            history=history,
            role_context=pack,
            mode=session.mode,
            difficulty=session.difficulty
        )
        new_turn = MockTurn(
            turn_index=next_turn_idx,
            interviewer_question=next_q_data.get("interviewer_question", "Next question."),
            question_category=next_q_data.get("question_category", "Technical")
        )
        session.turns.append(new_turn)
        session.current_turn_index = next_turn_idx

    db_store.save_mock_session(session.model_dump())
    return session

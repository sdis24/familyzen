from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import models
from ..dependencies import get_db, authorize_user_for_family

router = APIRouter(prefix="/families/{family_id}/assistant", tags=["Assistant"])

@router.post("/suggest-plan", response_model=dict)
def suggest_plan(
    family_id: int,
    db: Session = Depends(get_db),
    member: models.FamilyMember = Depends(authorize_user_for_family),
):
    # RÃ©cupÃ©ration simple (placeholder) : Ã  adapter si vous avez due_date etc.
    tasks = db.query(models.Task).filter(
        models.Task.family_id == family_id,
        models.Task.done == False
    ).all()
    events = db.query(models.Event).filter(
        models.Event.family_id == family_id
    ).all()

    suggestions = []
    if tasks:
        suggestions.append({
            "type": "task_reminder",
            "message": f"Vous avez {len(tasks)} tÃ¢che(s) Ã  faire.",
            "tasks": [{"id": t.id, "title": t.title} for t in tasks[:5]],
        })
    if events:
        suggestions.append({
            "type": "event_reminder",
            "message": f"{len(events)} Ã©vÃ©nement(s) Ã  venir.",
            "events": [{"id": e.id, "title": e.title, "start": e.start} for e in events[:5]],
        })

    return {"suggestions": suggestions}

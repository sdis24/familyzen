from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/ping")
def ping():
    return {"ok": True}

@app.post("/families/{family_id}/assistant/suggest-plan")
def suggest_plan(family_id: int):
    # RÃ©ponse ASCII simple pour Ã©viter tout souci d'encodage
    payload = {
        "suggestions": [
            {"type": "task_reminder", "message": "No data â€” backend OK"}
        ],
        "family_id": family_id
    }
    return JSONResponse(payload)

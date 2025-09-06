from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173", "http://localhost:5174", "http://127.0.0.1:5174"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/ping")
def ping():
    return {"ok": True}

@app.post("/families/{family_id}/assistant/suggest-plan")
def suggest_plan(family_id: int):
    # Réponse ASCII simple pour éviter tout souci d'encodage
    payload = {
        "suggestions": [
            {"type": "task_reminder", "message": "No data — backend OK"}
        ],
        "family_id": family_id
    }
    return JSONResponse(payload)
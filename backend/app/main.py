# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI(title="FamilyZen API", version="0.1.0")

# CORS permissif pour tests / front public
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # à restreindre plus tard si besoin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Page d’accueil simple (évite le "Not Found" à la racine)
@app.get("/", include_in_schema=False)
def root():
    return {"service": "FamilyZen backend", "status": "ok"}

# Healthcheck rapide
@app.get("/ping")
def ping():
    return {"ok": True}

# Démo : la route utilisée par ton front
@app.post("/families/{family_id}/assistant/suggest-plan")
def suggest_plan(family_id: int):
    payload = {
        "suggestions": [
            {"type": "task_reminder", "message": "No data — backend OK"}
        ],
        "family_id": family_id,
    }
    # Force l’UTF-8 pour éviter le “â€”” dans le front
    return JSONResponse(payload, media_type="application/json; charset=utf-8")

<#
.SYNOPSIS
    Installe/recâble la route Assistant (backend) + page Assistant (frontend) dans un projet FamilyZen.
.PARAMETER ProjectRoot
    Chemin racine de votre projet (contenant les dossiers backend/ et frontend/).
#>

param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectRoot
)

function Ensure-Dir($path) {
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

# Contenus embarqués (assistant.py, AssistantPage.tsx)
$AssistantPy = @'
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
    # Récupération simple (placeholder) : à adapter si vous avez due_date etc.
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
            "message": f"Vous avez {len(tasks)} tâche(s) à faire.",
            "tasks": [{"id": t.id, "title": t.title} for t in tasks[:5]],
        })
    if events:
        suggestions.append({
            "type": "event_reminder",
            "message": f"{len(events)} événement(s) à venir.",
            "events": [{"id": e.id, "title": e.title, "start": e.start} for e in events[:5]],
        })

    return {"suggestions": suggestions}
'@

$AssistantPageTsx = @'
import { useState } from "react";
import api from "../lib/api";
import { useFamilyStore } from "../store/family";

export default function AssistantPage() {
  const [suggestions, setSuggestions] = useState<any[]>([]);
  const { selectedFamily } = useFamilyStore();

  const fetchSuggestions = async () => {
    if (!selectedFamily) return;
    try {
      const res = await api.post(`/families/${selectedFamily.id}/assistant/suggest-plan`);
      setSuggestions(res.data.suggestions || []);
    } catch (error) {
      console.error("Erreur lors de la récupération des suggestions", error);
    }
  };

  return (
    <div className="bg-familyzen-light dark:bg-familyzen-dark min-h-screen p-6">
      <h1 className="text-2xl font-bold mb-6 text-familyzen-primary dark:text-familyzen-accent">
        Assistant FamilyZen
      </h1>

      <div className="mb-6">
        <button
          onClick={fetchSuggestions}
          className="px-4 py-2 bg-familyzen-primary text-white rounded-md hover:bg-opacity-90"
        >
          💡 Suggérer un plan
        </button>
      </div>

      {suggestions.length > 0 ? (
        <div className="space-y-4">
          {suggestions.map((s, idx) => (
            <div key={idx} className="bg-white dark:bg-gray-700 p-4 rounded-lg">
              <p className="font-medium text-familyzen-primary dark:text-familyzen-accent">
                {s.message}
              </p>
              {s.type === "task_reminder" && s.tasks?.length > 0 && (
                <ul className="mt-2 list-disc ml-5 text-gray-700 dark:text-gray-200">
                  {s.tasks.map((t: any) => <li key={t.id}>{t.title}</li>)}
                </ul>
              )}
              {s.type === "event_reminder" && s.events?.length > 0 && (
                <ul className="mt-2 list-disc ml-5 text-gray-700 dark:text-gray-200">
                  {s.events.map((e: any) => (
                    <li key={e.id}>
                      {e.title} — {new Date(e.start).toLocaleString("fr-FR")}
                    </li>
                  ))}
                </ul>
              )}
            </div>
          ))}
        </div>
      ) : (
        <p className="text-gray-500 dark:text-gray-400">Aucune suggestion pour l’instant.</p>
      )}
    </div>
  );
}
'@

# Dossiers cibles
$BackendRoutes = Join-Path $ProjectRoot "backend\app\routes"
$FrontendPages  = Join-Path $ProjectRoot "frontend\src\pages"
Ensure-Dir $BackendRoutes
Ensure-Dir $FrontendPages

# 1) Écrire les fichiers
$assistantPyPath = Join-Path $BackendRoutes "assistant.py"
$assistantTsxPath = Join-Path $FrontendPages "AssistantPage.tsx"
Set-Content -Path $assistantPyPath -Value $AssistantPy -Encoding UTF8
Set-Content -Path $assistantTsxPath -Value $AssistantPageTsx -Encoding UTF8

Write-Host "[OK] Écrit : $assistantPyPath"
Write-Host "[OK] Écrit : $assistantTsxPath"

# 2) Essayer d'ajouter l'import/route dans backend/app/main.py
$MainPath = Join-Path $ProjectRoot "backend\app\main.py"
if (Test-Path $MainPath) {
    $main = Get-Content -Path $MainPath -Raw

    if ($main -notmatch "assistant\.router") {
        if ($main -notmatch "from \.routes import assistant") {
            $main = "from .routes import assistant`r`n" + $main
        }
        $main += "`r`napp.include_router(assistant.router)`r`n"
        Set-Content -Path $MainPath -Value $main -Encoding UTF8
        Write-Host "[OK] main.py mis à jour (import + include_router)."
    } else {
        Write-Host "[OK] main.py déjà configuré pour 'assistant'."
    }
} else {
    # Générer un main minimal si absent
    $mainMinimal = @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import assistant

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(assistant.router)

@app.get("/")
def root():
    return {"message": "FamilyZen API (minimal) avec Assistant"}
'@
    Ensure-Dir (Split-Path $MainPath)
    Set-Content -Path $MainPath -Value $mainMinimal -Encoding UTF8
    Write-Host "[OK] main.py minimal créé."
}

Write-Host "`nTerminé. Relancez votre backend et ouvrez /frontend sur la page Assistant."
FamilyZen – correctif d’intégration Assistant

Contenu :
- backend/app/routes/assistant.py
- frontend/src/pages/AssistantPage.tsx
- scripts/setup_familyzen_fixed.ps1

Utilisation du script :
1) Ouvrez Windows PowerShell dans le dossier racine de VOTRE projet.
2) Exécutez :
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   powershell -ExecutionPolicy Bypass -File .\scripts\setup_familyzen_fixed.ps1 -ProjectRoot .

Le script crée/écrase les fichiers ci-dessus et tente d’ajouter l’inclusion du routeur
dans backend/app/main.py. S’il n’existe pas, un main minimal est généré.
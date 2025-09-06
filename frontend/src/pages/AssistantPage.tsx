import { useEffect, useState } from "react";

const API = import.meta.env.VITE_API_URL || "/api";

export default function AssistantPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const callApi = async () => {
    setLoading(true); setErr(null);
    try {
      const res = await fetch(`${API}/families/1/assistant/suggest-plan`, { method: "POST" });
      const text = await res.text();
      if (!res.ok) throw new Error(text || `HTTP ${res.status}`);
      const json = text ? JSON.parse(text) : null;
      setData(json);
    } catch (e: any) {
      setErr(e?.message ?? "Erreur inconnue");
      setData(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { callApi(); }, []);

  return (
    <div>
      <h2>Assistant</h2>
      <p>Appel de <code>POST /families/1/assistant/suggest-plan</code></p>
      <button onClick={callApi} disabled={loading}>
        {loading ? "Chargement..." : "Relancer l'appel"}
      </button>
      {err && <p style={{ color: "crimson" }}>Erreur: {err}</p>}
      <pre style={{ background: "#f4f4f4", padding: 12, marginTop: 12 }}>
        {JSON.stringify(data, null, 2)}
      </pre>
    </div>
  );
}

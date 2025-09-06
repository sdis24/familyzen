import { Routes, Route, Link } from "react-router-dom";
import AssistantPage from "./pages/AssistantPage";

export default function App() {
  return (
    <div style={{ padding: 16, fontFamily: "system-ui, sans-serif" }}>
      <header style={{ marginBottom: 16, display: "flex", gap: 12 }}>
        <h1 style={{ margin: 0, fontSize: 20 }}>FamilyZen</h1>
        <nav><Link to="/">Assistant</Link></nav>
      </header>
      <Routes>
        <Route path="/" element={<AssistantPage />} />
      </Routes>
    </div>
  );
}

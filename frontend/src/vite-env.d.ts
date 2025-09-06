/// <reference types="vite/client" />

// On déclare explicitement la variable d'env qu'on utilise
interface ImportMetaEnv {
  readonly VITE_API_URL?: string;
}
interface ImportMeta {
  readonly env: ImportMetaEnv;
}

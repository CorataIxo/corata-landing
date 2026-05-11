# Corata Landing

> **Trabajo de Fin de Grado — Documentación técnica**

Landing page de **Corata · The Talent Integrity Stack**.

Página de captación de leads y presentación del producto. Construida con Astro (salida estática) y desplegada en Vercel. Se comunica con el backend REST para registrar solicitudes de acceso anticipado desde el formulario de la sección CTA.

---

## Stack

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| Astro | 6.1 | Framework de sitio estático |
| Tailwind CSS | 4.2 | Estilos utilitarios |
| Supabase | 2.49 | Autenticación (páginas /registro y /login) |
| Vercel adapter | 10 | Despliegue en Vercel |

---

## Prerrequisitos

- Node.js >= 20
- El backend `corata-backend` corriendo en local para el formulario de leads

---

## Setup

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar variables de entorno
cp .env.example .env
# Edita .env con tus valores de Supabase y la URL del backend
```

---

## Variables de entorno

| Variable | Ejemplo | Descripción |
|----------|---------|-------------|
| `PUBLIC_SUPABASE_URL` | `https://xxx.supabase.co` | URL del proyecto Supabase |
| `PUBLIC_SUPABASE_ANON_KEY` | `eyJ...` | Clave anónima de Supabase |
| `PUBLIC_API_URL` | `http://localhost:3000` | URL base del backend REST (sin trailing slash) |

**`PUBLIC_API_URL` en producción**: cambia a la URL del backend desplegado (ej. `https://api.corata.io`).

---

## Comandos

```bash
npm run dev       # Servidor de desarrollo en http://localhost:4321
npm run build     # Compila el sitio estático en dist/
npm run preview   # Previsualiza el build antes de desplegar
```

---

## Estructura

```
src/
├── components/
│   ├── sections/         # Secciones de la landing (Hero, CtaBand, etc.)
│   └── ui/
│       ├── LeadForm.astro   # Formulario de captura → POST /api/leads
│       └── ...
├── pages/
│   ├── index.astro       # Página principal
│   ├── registro.astro    # Alta con Supabase Auth
│   └── login.astro       # Login con Supabase Auth
├── lib/supabase/         # Cliente Supabase (server + browser)
└── styles/global.css     # Variables de diseño y estilos globales
```

---

## Formulario de leads

El componente `LeadForm.astro` envía un `POST /api/leads` al backend con `{ name, email, source: "landing" }`.

```
Usuario rellena el form
        ↓
fetch() → POST {PUBLIC_API_URL}/api/leads
        ↓
  ¿ok? → muestra estado de éxito + link a /registro
  ¿error 400? → muestra mensaje de validación
  ¿error red? → muestra "Error de conexión"
```

Para que funcione en desarrollo, el backend debe estar corriendo:

```bash
# En la carpeta corata-backend:
npm run db:up      # levanta Postgres
npm run dev        # arranca la API en localhost:3000
```

---

## Despliegue

El sitio se despliega en Vercel. En el panel de Vercel, configurar las variables de entorno de producción (las mismas que en `.env.example` pero con valores reales).

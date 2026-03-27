// Cliente para el navegador — úsalo en <script> de componentes Astro
// o en islas de React/Vue/Svelte en el futuro.
import { createBrowserClient } from '@supabase/ssr';
import type { Database } from './types';

export const supabase = createBrowserClient<Database>(
  import.meta.env.PUBLIC_SUPABASE_URL,
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY
);

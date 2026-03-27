// Cliente para el servidor — úsalo en el frontmatter de páginas SSR
// y en los endpoints de src/pages/api/.
// Crea una instancia nueva por cada request (nunca reutilices entre requests).
import { createServerClient } from '@supabase/ssr';
import type { AstroCookies } from 'astro';
import type { Database } from './types';

export function createSupabaseServerClient(request: Request, cookies: AstroCookies) {
  return createServerClient<Database>(
    import.meta.env.PUBLIC_SUPABASE_URL,
    import.meta.env.PUBLIC_SUPABASE_ANON_KEY,
    {
      cookies: {
        getAll() {
          const header = request.headers.get('cookie') ?? '';
          if (!header) return [];
          return header.split(';').flatMap(pair => {
            const trimmed = pair.trim();
            const eq = trimmed.indexOf('=');
            if (eq === -1) return [];
            return [{ name: trimmed.slice(0, eq).trim(), value: trimmed.slice(eq + 1).trim() }];
          });
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookies.set(name, value, options as Parameters<typeof cookies.set>[2]);
          });
        },
      },
    }
  );
}

// Helper: devuelve la sesión activa o null
export async function getSession(request: Request, cookies: AstroCookies) {
  const supabase = createSupabaseServerClient(request, cookies);
  const { data: { session } } = await supabase.auth.getSession();
  return session;
}

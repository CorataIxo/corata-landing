// @ts-check
import { defineConfig } from 'astro/config';
import node from '@astrojs/node';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  // hybrid: las páginas son estáticas por defecto.
  // Añade `export const prerender = false` a las que necesiten SSR (auth, dashboard…)
  output: 'static',
  adapter: node({ mode: 'standalone' }),
  vite: {
    plugins: [tailwindcss()]
  }
});

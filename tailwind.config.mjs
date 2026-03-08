/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,sss,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        corataTeal: '#4A8B8B',
        corataDark: '#1A1A1A',
        corataBg: '#F8F9FA',
        corataRed: '#C56D66',
        corataYellow: '#D4B483',
      },
      borderRadius: {
        'corata': '1rem',
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui'],
      }
    },
  },
  plugins: [],
}
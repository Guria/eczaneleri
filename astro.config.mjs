// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  // Production origin. Makes canonical and hreflang URLs absolute for SEO.
  site: "https://eczane.apphane.dev",
  i18n: {
    defaultLocale: 'tr',
    locales: ['tr', 'en', 'ru', 'de'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
  server: {
    host: true,
    allowedHosts: ['apphane.exe.xyz'],
  },
  // Cookieless PostHog needs a same-origin ingest proxy so the server can
  // hash IP+user-agent. Same proxy in production via public/_worker.js.
  vite: {
    server: {
      proxy: {
        '/ingest': {
          target: 'https://eu.i.posthog.com',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/ingest/, ''),
        },
      },
    },
  },
});

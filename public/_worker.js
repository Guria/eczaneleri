// Cloudflare Pages advanced-mode worker (copied to dist/ by Astro).
// Serves static assets as usual and reverse-proxies /ingest/* to PostHog EU
// for cookieless tracking — the server-side IP+UA hash requires it.
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.startsWith("/ingest/")) {
      const target = new URL(request.url);
      target.hostname = "eu.i.posthog.com";
      target.pathname = url.pathname.slice("/ingest".length);
      return fetch(new Request(target, request));
    }
    return env.ASSETS.fetch(request);
  },
};

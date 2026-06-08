const CACHE_NAME = "purple-post-v2";
const STATIC_ASSETS = [ "/manifest.json", "/appicon.svg", "/applogo.png" ];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) =>
      Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      )
    )
  );
  self.clients.claim();
});

function isHtmlNavigation(request) {
  if (request.mode === "navigate") return true;

  const accept = request.headers.get("accept") || "";
  return accept.includes("text/html");
}

function isCacheableAsset(url) {
  return url.pathname.startsWith("/assets/") || STATIC_ASSETS.includes(url.pathname);
}

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;

  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;

  // Never intercept HTML — avoids stale pages/importmaps breaking Turbo and buttons after deploys.
  if (isHtmlNavigation(event.request)) return;

  if (!isCacheableAsset(url)) return;

  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) return cached;

      return fetch(event.request).then((response) => {
        if (response.ok) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      });
    })
  );
});

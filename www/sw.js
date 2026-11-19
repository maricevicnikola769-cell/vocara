// Voćara service worker: čuva aplikaciju za rad bez interneta
const CACHE = 'vocara-v23';
const FILES = ['./', './index.html', './manifest.json', './qrcode.min.js', './firebase-app-compat.js', './firebase-auth-compat.js', './firebase-firestore-compat.js',
  './icons/icon-192.png', './icons/icon-512.png', './icons/maskable-512.png', './icons/icon-180.png'];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const u = e.request.url;
  if (!u.startsWith(self.location.origin) && !u.includes('fonts.g')) return;
  if (e.request.mode === 'navigate') {
    e.respondWith(fetch(e.request).then(res => { const c = res.clone(); caches.open(CACHE).then(x => x.put('./index.html', c)); return res; }).catch(() => caches.match('./index.html')));
    return;
  }
  e.respondWith(
    caches.match(e.request).then(hit => hit || fetch(e.request).then(res => {
      if (res.ok && (e.request.url.startsWith(self.location.origin) || e.request.url.includes('fonts.g'))) {
        const copy = res.clone(); caches.open(CACHE).then(c => c.put(e.request, copy));
      }
      return res;
    }).catch(() => caches.match('./index.html')))
  );
});

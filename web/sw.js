// Wheat Wars offline cache. Bump VERSION when any file changes.
const VERSION='ww-2.2.1';
const FILES=['./','./index.html','./manifest.webmanifest','./icon-180.png','./icon-192.png','./icon-512.png','./icon-maskable-512.png',
 './previous/index.html','./previous/version.txt'];
const MAIN=['./','./index.html'];
// Install: fetch every file straight from the network (cache:'reload' bypasses the HTTP cache).
self.addEventListener('install',e=>{e.waitUntil(caches.open(VERSION).then(c=>Promise.all(FILES.map(f=>
  fetch(new Request(f,{cache:'reload'})).then(r=>{if(!r.ok)throw new Error(f+' '+r.status);return c.put(f,r);})))).then(()=>self.skipWaiting()));});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==VERSION).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',e=>{const req=e.request;if(req.method!=='GET')return;
  const url=new URL(req.url);if(url.origin!==location.origin)return;
  if(/\.mp4$/i.test(url.pathname))return; // video streams with range requests: leave it to the network
  const scope=new URL('./',self.registration.scope).pathname,rel=url.pathname.slice(scope.length);
  const isMain=rel===''||rel==='index.html';
  if(req.mode==='navigate'){
    // Network-first for pages: always fresh online, cached copy offline. Each page caches under its own key,
    // so opening the previous version never overwrites the main game.
    const key=isMain?'./index.html':'./'+(rel.endsWith('/')?rel+'index.html':rel);
    e.respondWith(fetch(req,{cache:'no-cache'}).then(res=>{
      if(res.ok){const a=res.clone(),b=isMain?res.clone():null;caches.open(VERSION).then(c=>{c.put(key,a);if(b)c.put('./',b);});}
      return res;}).catch(()=>caches.match(key).then(r=>r||caches.match('./index.html'))));
    return;}
  // Other assets: cache-first, fill cache on miss.
  e.respondWith(caches.match(req,{ignoreSearch:true}).then(r=>r||fetch(req).then(res=>{
    if(res.ok){const c=res.clone();caches.open(VERSION).then(ca=>ca.put(req,c));}
    return res;})));});

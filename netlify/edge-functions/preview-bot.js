// Edge Function para interceptar bots sociales y servir meta tags optimizados
// API: /catalogs/public/owner/{id} → { data: [{ name, owner: { name, photoURL } }, ...] }

function extractOriginalUrl(proxyUrl) {
  if (!proxyUrl || typeof proxyUrl !== 'string') return proxyUrl;
  let originalUrl = proxyUrl;
  try {
    const urlObj = new URL(proxyUrl);
    if (urlObj.searchParams.has('url')) {
      originalUrl = decodeURIComponent(urlObj.searchParams.get('url'));
    }
  } catch (e) {}
  if (typeof originalUrl === 'string') {
    originalUrl = originalUrl.replace(/^http:\/\//i, 'https://');
  }
  return originalUrl;
}

export default async (request, context) => {
  const url = new URL(request.url);
  const userAgent = (request.headers.get('user-agent') || '').toLowerCase();
  const pathname = url.pathname;

  const socialBots = [
    'facebookexternalhit', 'facebot', 'twitterbot', 'whatsapp',
    'linkedinbot', 'slackbot', 'discordbot', 'telegrambot',
    'googlebot', 'prerender',
  ];
  const isSocialBot = socialBots.some(bot => userAgent.includes(bot));

  if (!isSocialBot) return context.next();

  const pathSegments = pathname.split('/').filter(Boolean);
  const commerceId = pathSegments[0];

  if (!commerceId || commerceId.includes('.') || commerceId.startsWith('_') || commerceId.startsWith('.')) return context.next();

  const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidPattern.test(commerceId)) return context.next();

  const API_URL = Deno.env.get('API_URL') || 'https://menucom-api.onrender.com';

  async function fetchWithTimeout(fetchUrl, timeoutMs = 15000) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    try {
      return await fetch(fetchUrl, { signal: controller.signal });
    } finally {
      clearTimeout(timeout);
    }
  }

  try {
    let title = 'MenuCom';
    let description = 'Consulta nuestro catálogo de productos y servicios';
    let imageUrl = 'https://menu-comerce.netlify.app/default-image.png';

    const catalogResponse = await fetchWithTimeout(`${API_URL}/catalogs/public/owner/${commerceId}`);

    if (catalogResponse.ok) {
      const body = await catalogResponse.json();
      const catalogs = body?.data;
      if (Array.isArray(catalogs) && catalogs.length > 0) {
        const owner = catalogs[0].owner;
        title = owner?.name || catalogs[0].name || title;
        imageUrl = extractOriginalUrl(owner?.photoURL) || extractOriginalUrl(catalogs[0].coverImageUrl) || imageUrl;
        description = catalogs.map(c => c.name).filter(Boolean).join(', ') || description;
      }
    } else {
      const userResponse = await fetchWithTimeout(`${API_URL}/user/user/${commerceId}`);
      if (userResponse.ok) {
        const user = await userResponse.json();
        title = user.name || title;
        imageUrl = extractOriginalUrl(user.photoURL) || imageUrl;
        const roleEndpoint = user.role === 'clothes' ? 'wardrobe' : 'menu';
        const legacyResponse = await fetchWithTimeout(`${API_URL}/${roleEndpoint}/bydining/${commerceId}`);
        if (legacyResponse.ok) {
          const legacyData = await legacyResponse.json();
          if (Array.isArray(legacyData.listmenu) && legacyData.listmenu.length > 0) {
            description = legacyData.listmenu.map(m => m.description).filter(Boolean).join(', ') || description;
          }
        }
      }
    }

    const sanitize = (str) => {
      if (!str) return '';
      return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
    };

    const safeTitle = sanitize(title);
    const safeDescription = sanitize(description);

    const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta property="og:title" content="${safeTitle}" />
  <meta property="og:description" content="${safeDescription}" />
  <meta property="og:image" content="${imageUrl}" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:url" content="${request.url}" />
  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="MenuCom" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="${safeTitle}" />
  <meta name="twitter:description" content="${safeDescription}" />
  <meta name="twitter:image" content="${imageUrl}" />
  <title>${safeTitle}</title>
</head>
<body>
  <h1>${safeTitle}</h1>
  <p>${safeDescription}</p>
  <img src="${imageUrl}" alt="${safeTitle}" style="max-width: 300px;" />
</body>
</html>`;

    return new Response(html, {
      status: 200,
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    });

  } catch (error) {
    console.error('[edge-preview] Error:', error.message);
    return context.next();
  }
};

export const config = {
  path: "/*",
  excludedPath: ["/.netlify/*", "/*.css", "/*.js", "/*.png", "/*.jpg", "/*.jpeg", "/*.gif", "/*.svg", "/*.ico", "/*.woff", "/*.woff2", "/*.ttf", "/*.eot"]
};

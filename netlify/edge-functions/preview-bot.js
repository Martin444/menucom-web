// Edge Function para interceptar bots sociales y servir meta tags optimizados
// Se ejecuta en el Edge (Deno runtime) ANTES de los redirects

console.log('[edge-preview] Función cargada');

/**
 * Extrae la URL original de una URL de proxy y fuerza HTTPS
 */
function extractOriginalUrl(proxyUrl) {
  if (!proxyUrl || typeof proxyUrl !== 'string') return proxyUrl;
  
  let originalUrl = proxyUrl;
  
  try {
    const urlObj = new URL(proxyUrl);
    if (urlObj.searchParams.has('url')) {
      originalUrl = decodeURIComponent(urlObj.searchParams.get('url'));
    }
  } catch (e) {
    // No es una URL válida, devolver tal cual
  }
  
  // Forzar HTTPS incluso si no es proxy
  if (typeof originalUrl === 'string') {
    originalUrl = originalUrl.replace(/^http:\/\//i, 'https://');
  }
  
  return originalUrl;
}

export default async (request, context) => {
  const url = new URL(request.url);
  const userAgent = request.headers.get('user-agent') || '';
  const pathname = url.pathname;
  
  console.log('[edge-preview] Request:', pathname, 'UA:', userAgent.substring(0, 50));
  
  // Detectar bots sociales
  const socialBots = [
    'facebookexternalhit',
    'Facebot',
    'Twitterbot',
    'WhatsApp',
    'LinkedInBot',
    'Slackbot',
    'Discordbot',
    'TelegramBot',
    'Googlebot',
    'Prerender',
  ];
  
  const isSocialBot = socialBots.some(bot => 
    userAgent.toLowerCase().includes(bot.toLowerCase())
  );
  
  console.log('[edge-preview] Is social bot:', isSocialBot);
  
  // Si NO es un bot social, dejar que Netlify sirva normalmente
  if (!isSocialBot) {
    console.log('[edge-preview] Not a bot, passing through');
    return context.next();
  }
  
  // Es un bot social: extraer el ID del commerce de la URL
  const pathSegments = pathname.split('/').filter(Boolean);
  const commerceId = pathSegments[0];
  
  console.log('[edge-preview] Commerce ID:', commerceId);
  
  if (!commerceId) {
    console.log('[edge-preview] No commerce ID, passing through');
    return context.next();
  }
  
  // Validar formato UUID (8-4-4-4-12 caracteres hexadecimales)
  const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidPattern.test(commerceId)) {
    console.log('[edge-preview] Not a UUID, passing through');
    return context.next();
  }
  
  console.log('[edge-preview] Valid UUID detected, fetching data...');
  
  // Fetch data del commerce desde la API
  const API_URL = Deno.env.get('API_URL') || 'https://menucom-api.onrender.com';
  
  // Helper para fetch con timeout (Render cold start puede tardar)
  async function fetchWithTimeout(fetchUrl, options = {}, timeoutMs = 15000) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const response = await fetch(fetchUrl, {
        ...options,
        signal: controller.signal,
      });
      return response;
    } finally {
      clearTimeout(timeout);
    }
  }
  
  try {
    // 1. Intentar obtener el catálogo público por owner (sin auth)
    console.log('[edge-preview] Fetching:', `${API_URL}/catalogs/public/owner/${commerceId}`);
    const catalogResponse = await fetchWithTimeout(`${API_URL}/catalogs/public/owner/${commerceId}`);
    
    console.log('[edge-preview] Catalog response status:', catalogResponse.status);
    
    let title = 'MenuCom';
    let description = 'Consulta nuestro catálogo de productos y servicios';
    let imageUrl = 'https://menu-comerce.netlify.app/default-image.png';
    let found = false;

    if (catalogResponse.ok) {
        const data = await catalogResponse.json();
        console.log('[edge-preview] Catalog data received:', JSON.stringify(data).substring(0, 200));
        const catalog = data.data || data;
        title = catalog.name || 'Menú comercial';
        description = catalog.description || 'Consulta nuestro catálogo de productos y servicios';
        imageUrl = extractOriginalUrl(catalog.coverImageUrl) || imageUrl;
        found = true;
        console.log('[edge-preview] Catalog found:', title);
    } else {
        console.log('[edge-preview] Catalog not found, trying user...');
        // 2. Fallback: Intentar obtener el usuario (Arquitectura Antigua)
        const userResponse = await fetchWithTimeout(`${API_URL}/user/user/${commerceId}`);
        
        console.log('[edge-preview] User response status:', userResponse.status);
        
        if (userResponse.ok) {
            const user = await userResponse.json();
            title = user.name || 'MenuCom';
            
            // Intentar obtener descripción de menú/wardrobe legado
            const roleEndpoint = user.role === 'clothes' ? 'wardrobe' : 'menu';
            const legacyResponse = await fetchWithTimeout(`${API_URL}/${roleEndpoint}/bydining/${commerceId}`);
            
            if (legacyResponse.ok) {
                const legacyData = await legacyResponse.json();
                if (Array.isArray(legacyData.listmenu) && legacyData.listmenu.length > 0) {
                    description = legacyData.listmenu.map(m => m.description).filter(Boolean).join(', ');
                }
            }
            
            imageUrl = extractOriginalUrl(user.photoURL) || imageUrl;
            found = true;
            console.log('[edge-preview] User found:', title);
        }
    }

    if (!found) {
        console.log('[edge-preview] No data found, passing through');
        return context.next();
    }
    
    // Sanitizar valores para evitar XSS en meta tags
    const sanitize = (str) => {
      if (!str) return '';
      return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
    };
    
    const safeTitle = sanitize(title);
    const safeDescription = sanitize(description);
    const safeUrl = request.url;
    
    console.log('[edge-preview] Returning HTML with OG tags for:', safeTitle);
    
    // Construir HTML con Open Graph tags
    const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta property="og:title" content="${safeTitle}" />
  <meta property="og:description" content="${safeDescription}" />
  <meta property="og:image" content="${imageUrl}" />
  <meta property="og:url" content="${safeUrl}" />
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
        'Cache-Control': 'public, max-age=3600',
      },
    });
    
  } catch (error) {
    console.error('[edge-preview] Error:', error.message);
    // En caso de error, dejar que Netlify sirva la SPA normalmente
    return context.next();
  }
};

export const config = {
  path: "/*",
  excludedPath: ["/.netlify/*", "/*.css", "/*.js", "/*.png", "/*.jpg", "/*.jpeg", "/*.gif", "/*.svg", "/*.ico", "/*.woff", "/*.woff2", "/*.ttf", "/*.eot"]
};

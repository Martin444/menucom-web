// Edge Function para interceptar bots sociales y servir meta tags optimizados
// Se ejecuta en el Edge (Deno runtime) ANTES de los redirects

/**
 * Extrae la URL original de una URL de proxy y fuerza HTTPS
 * Ejemplo: http://...herokuapp.com/api/image-proxy/image?url=http%3A%2F%2Fres.cloudinary.com%2F...
 * Retorna: https://res.cloudinary.com/...
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
  
  console.log('[edge-preview] URL:', url.pathname);
  console.log('[edge-preview] User-Agent:', userAgent);
  
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
  ];
  
  const isSocialBot = socialBots.some(bot => 
    userAgent.toLowerCase().includes(bot.toLowerCase())
  );
  
  // Si NO es un bot social, dejar que Netlify sirva normalmente
  if (!isSocialBot) {
    console.log('[edge-preview] Usuario normal, pasando al siguiente handler');
    return context.next();
  }
  
  // Es un bot social: extraer el ID del commerce de la URL
  const pathSegments = url.pathname.split('/').filter(Boolean);
  const commerceId = pathSegments[0];
  
  // Validar que no sea un archivo estático o ruta del sistema
  const isSystemFile = commerceId.includes('.') || // archivos con extensión
                       commerceId === 'robots.txt' ||
                       commerceId === 'sitemap.xml' ||
                       commerceId === 'favicon.ico' ||
                       commerceId.startsWith('_') ||
                       commerceId.startsWith('.');
  
  if (!commerceId || isSystemFile) {
    console.log('[edge-preview] No es un commerce ID válido:', commerceId);
    return context.next();
  }
  
  // Validar formato UUID (8-4-4-4-12 caracteres hexadecimales)
  const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidPattern.test(commerceId)) {
    console.log('[edge-preview] No es un UUID válido:', commerceId);
    return context.next();
  }
  
  console.log('[edge-preview] Bot social detectado, commerce ID:', commerceId);
  
  // Fetch data del commerce desde la API
  const API_URL = Deno.env.get('API_URL') || 'https://menucom-api.onrender.com';
  
  try {
    // 1. Intentar obtener el catálogo directamente (Nueva Arquitectura)
    console.log('[edge-preview] Buscando catálogo:', commerceId);
    const catalogResponse = await fetch(`${API_URL}/catalogs/${commerceId}`);
    
    let title = 'MenuCom';
    let description = 'Consulta nuestro catálogo de productos y servicios';
    let imageUrl = 'https://menu-comerce.netlify.app/default-image.png';
    let found = false;

    if (catalogResponse.ok) {
        const catalog = await catalogResponse.json();
        title = catalog.name || 'Menú comercial';
        description = catalog.description || 'Consulta nuestro catálogo de productos y servicios';
        imageUrl = extractOriginalUrl(catalog.coverImageUrl) || imageUrl;
        found = true;
        console.log('[edge-preview] Catálogo encontrado:', title);
    } else {
        console.log('[edge-preview] Catálogo no encontrado (status: ' + catalogResponse.status + '), intentando fallback con usuario...');
        
        // 2. Fallback: Intentar obtener el usuario (Arquitectura Antigua)
        const userResponse = await fetch(`${API_URL}/user/user/${commerceId}`);
        
        if (userResponse.ok) {
            const user = await userResponse.json();
            title = user.name || 'MenuCom';
            console.log('[edge-preview] Usuario obtenido:', title);
            
            // Intentar obtener descripción de menú/wardrobe legado
            const roleEndpoint = user.role === 'clothes' ? 'wardrobe' : 'menu';
            const legacyResponse = await fetch(`${API_URL}/${roleEndpoint}/bydining/${commerceId}`);
            
            if (legacyResponse.ok) {
                const legacyData = await legacyResponse.json();
                if (Array.isArray(legacyData.listmenu) && legacyData.listmenu.length > 0) {
                    description = legacyData.listmenu.map(m => m.description).filter(Boolean).join(', ');
                }
            }
            
            imageUrl = extractOriginalUrl(user.photoURL) || imageUrl;
            found = true;
        }
    }

    if (!found) {
        console.warn('[edge-preview] No se encontró información para:', commerceId);
        return context.next();
    }
    
    // Construir HTML con Open Graph tags
    const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta property="og:title" content="${title}" />
  <meta property="og:description" content="${description}" />
  <meta property="og:image" content="${imageUrl}" />
  <meta property="og:url" content="${request.url}" />
  <meta property="og:type" content="website" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="${title}" />
  <meta name="twitter:description" content="${description}" />
  <meta name="twitter:image" content="${imageUrl}" />
  <title>${title}</title>
</head>
<body>
  <h1>${title}</h1>
  <p>${description}</p>
  <img src="${imageUrl}" alt="${title}" style="max-width: 300px;" />
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
    console.error('[edge-preview] Error:', error);
    return context.next();
  }
};

export const config = {
  // Solo aplicar a rutas que parecen UUIDs (8-4-4-4-12 caracteres)
  path: "/:id",
};

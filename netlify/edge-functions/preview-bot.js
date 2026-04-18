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
  const API_URL = Deno.env.get('API_URL') || 'https://menucom-api-60e608ae2f99.herokuapp.com';
  
  try {
    // 1. Primero obtener datos del usuario/owner
    const userResponse = await fetch(`${API_URL}/user/user/${commerceId}`);
    
    if (!userResponse.ok) {
      console.error('[edge-preview] Error obteniendo usuario:', userResponse.status);
      return context.next();
    }
    
    const user = await userResponse.json();
    console.log('[edge-preview] Usuario obtenido:', user.name, 'Role:', user.role);
    
    // 2. Según el role, obtener menú o wardrobe
    let description = 'Catálogo de productos';
    let dataResponse;
    
    if (user.role === 'clothes') {
      // Es wardrobe
      console.log('[edge-preview] Obteniendo wardrobe...');
      dataResponse = await fetch(`${API_URL}/wardrobe/bydining/${commerceId}`);
      
      if (dataResponse.ok) {
        const data = await dataResponse.json();
        if (Array.isArray(data.listmenu) && data.listmenu.length > 0) {
          description = data.listmenu.map(m => m.description).filter(Boolean).join(', ');
        }
      } else {
        console.error('[edge-preview] Error obteniendo wardrobe:', dataResponse.status);
      }
    } else {
      // Es menú
      console.log('[edge-preview] Obteniendo menú...');
      dataResponse = await fetch(`${API_URL}/menu/bydining/${commerceId}`);
      
      if (dataResponse.ok) {
        const data = await dataResponse.json();
        if (Array.isArray(data.listmenu) && data.listmenu.length > 0) {
          description = data.listmenu.map(m => m.description).filter(Boolean).join(', ');
        }
      } else {
        console.error('[edge-preview] Error obteniendo menú:', dataResponse.status);
      }
    }
    
    // Extraer información del owner
    const owner = {
      name: user.name || 'MenuCom',
      photoURL: user.photoURL || '',
      description: description
    };
    
    // ✅ Extraer URL original de la imagen (decodificar proxy)
    const originalPhotoURL = extractOriginalUrl(owner.photoURL);
    
    console.log('[edge-preview] Original photoURL:', owner.photoURL);
    console.log('[edge-preview] Extracted photoURL:', originalPhotoURL);
    console.log('[edge-preview] Type:', user.role === 'clothes' ? 'wardrobe' : 'menu');
    console.log('[edge-preview] Owner name:', owner.name);
    console.log('[edge-preview] Description:', description);
    
    // Construir HTML con Open Graph tags
    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta property="og:title" content="${owner.name || 'MenuCom'}" />
  <meta property="og:description" content="${description}" />
  <meta property="og:image" content="${originalPhotoURL}" />
  <meta property="og:url" content="${request.url}" />
  <meta property="og:type" content="website" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="${owner.name || 'MenuCom'}" />
  <meta name="twitter:description" content="${description}" />
  <meta name="twitter:image" content="${originalPhotoURL}" />
  <title>${owner.name || 'MenuCom'}</title>
</head>
<body>
  <h1>${owner.name || 'MenuCom'}</h1>
  <p>${description}</p>
  <img src="${originalPhotoURL}" alt="${owner.name || 'MenuCom'}" style="max-width: 300px;" />
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

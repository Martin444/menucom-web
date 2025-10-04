// Edge Function para interceptar bots sociales y servir meta tags optimizados
// Se ejecuta en el Edge (Deno runtime) ANTES de los redirects

/**
 * Extrae la URL original de una URL de proxy
 * Ejemplo: http://...herokuapp.com/api/image-proxy/image?url=http%3A%2F%2Fres.cloudinary.com%2F...
 * Retorna: https://res.cloudinary.com/...
 */
function extractOriginalUrl(proxyUrl) {
  if (!proxyUrl) return '';
  
  try {
    // Si la URL contiene "image-proxy", extraer el parámetro 'url'
    if (proxyUrl.includes('image-proxy')) {
      const urlObj = new URL(proxyUrl);
      const originalUrl = urlObj.searchParams.get('url');
      
      if (originalUrl) {
        // Decodificar la URL
        const decoded = decodeURIComponent(originalUrl);
        
        // Forzar HTTPS si es HTTP
        if (decoded.startsWith('http://')) {
          return decoded.replace('http://', 'https://');
        }
        
        return decoded;
      }
    }
    
    // Si no es proxy, forzar HTTPS si es necesario
    if (proxyUrl.startsWith('http://')) {
      return proxyUrl.replace('http://', 'https://');
    }
    
    return proxyUrl;
  } catch (error) {
    console.error('[extractOriginalUrl] Error:', error);
    return proxyUrl;
  }
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
  
  if (!commerceId) {
    console.log('[edge-preview] No se encontró commerce ID');
    return context.next();
  }
  
  console.log('[edge-preview] Bot social detectado, commerce ID:', commerceId);
  
  // Fetch data del commerce desde la API
  const API_URL = Deno.env.get('API_URL') || 'https://menucom-api-60e608ae2f99.herokuapp.com';
  
  try {
    const apiResponse = await fetch(`${API_URL}/api/menu/get-items-menu/${commerceId}`);
    
    if (!apiResponse.ok) {
      console.error('[edge-preview] Error API:', apiResponse.status);
      return context.next();
    }
    
    const data = await apiResponse.json();
    const owner = data.owner || {};
    
    // ✅ Extraer URL original de la imagen (decodificar proxy)
    const originalPhotoURL = extractOriginalUrl(owner.photoURL);
    
    console.log('[edge-preview] Original photoURL:', owner.photoURL);
    console.log('[edge-preview] Extracted photoURL:', originalPhotoURL);
    
    // Construir HTML con Open Graph tags
    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta property="og:title" content="${owner.name || 'MenuCom'}" />
  <meta property="og:description" content="${owner.description || 'Catálogo de productos'}" />
  <meta property="og:image" content="${originalPhotoURL}" />
  <meta property="og:url" content="${request.url}" />
  <meta property="og:type" content="website" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="${owner.name || 'MenuCom'}" />
  <meta name="twitter:description" content="${owner.description || 'Catálogo de productos'}" />
  <meta name="twitter:image" content="${originalPhotoURL}" />
  <title>${owner.name || 'MenuCom'}</title>
</head>
<body>
  <h1>${owner.name || 'MenuCom'}</h1>
  <p>${owner.description || 'Catálogo de productos'}</p>
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

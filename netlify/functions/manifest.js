// Netlify Function: Manifest.json dinámico por comercio
// Sirve un manifest.json personalizado con nombre, logo y color del comercio.
// Se llama desde index.html como: /.netlify/functions/manifest?id={commerceId}
// O como: /manifest.json?id={commerceId} (via redirect en netlify.toml)

const DEFAULT_MANIFEST = {
  id: '/',
  name: 'Menucom Catalogo',
  short_name: 'Menucom',
  description: 'Catalogo para clientes CSM',
  start_url: '/',
  scope: '/',
  display: 'standalone',
  background_color: '#FFFFFF',
  theme_color: '#CEDDFE',
  orientation: 'portrait-primary',
  prefer_related_applications: false,
  categories: ['business', 'shopping'],
  icons: [
    { src: '/icons/menucom-192.png', sizes: '192x192', type: 'image/png' },
    { src: '/icons/menucom-512.png', sizes: '512x512', type: 'image/png' },
    { src: '/icons/menucom-maskable-192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
    { src: '/icons/menucom-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
  ],
};

const API_URL = process.env.API_URL || 'https://menucom-api.onrender.com';

// Helper para fetch con timeout (Render cold start puede tardar)
async function fetchWithTimeout(url, timeoutMs = 15000) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } finally {
    clearTimeout(timeout);
  }
}

function extractOriginalUrl(proxyUrl) {
  if (!proxyUrl || typeof proxyUrl !== 'string') return proxyUrl;
  let originalUrl = proxyUrl;
  try {
    const urlObj = new URL(proxyUrl);
    if (urlObj.searchParams.has('url')) {
      originalUrl = decodeURIComponent(urlObj.searchParams.get('url'));
    }
  } catch (e) { }
  if (typeof originalUrl === 'string') {
    originalUrl = originalUrl.replace(/^http:\/\//i, 'https://');
  }
  return originalUrl;
}

function isCloudinaryUrl(url) {
  return url && typeof url === 'string' && url.includes('res.cloudinary.com');
}

function transformCloudinaryUrl(url, width, height) {
  return url.replace(
    '/upload/',
    `/upload/c_fill,w_${width},h_${height},q_auto,f_png/`
  );
}

function buildIcons(coverImageUrl) {
  const icons = [];

  if (coverImageUrl) {
    if (isCloudinaryUrl(coverImageUrl)) {
      icons.push(
        { src: transformCloudinaryUrl(coverImageUrl, 192, 192), sizes: '192x192', type: 'image/png', purpose: 'any' },
        { src: transformCloudinaryUrl(coverImageUrl, 512, 512), sizes: '512x512', type: 'image/png', purpose: 'any' },
        { src: transformCloudinaryUrl(coverImageUrl, 192, 192), sizes: '192x192', type: 'image/png', purpose: 'maskable' },
        { src: transformCloudinaryUrl(coverImageUrl, 512, 512), sizes: '512x512', type: 'image/png', purpose: 'maskable' },
      );
    } else {
      icons.push(
        { src: coverImageUrl, sizes: '192x192', type: 'image/png', purpose: 'any' },
        { src: coverImageUrl, sizes: '512x512', type: 'image/png', purpose: 'any' },
      );
    }
  } else {
    icons.push(
      { src: '/icons/menucom-192.png', sizes: '192x192', type: 'image/png' },
      { src: '/icons/menucom-512.png', sizes: '512x512', type: 'image/png' },
      { src: '/icons/menucom-maskable-192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
      { src: '/icons/menucom-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
    );
  }

  return icons;
}

exports.handler = async (event) => {
  // Extraer ID de query string o path
  const id = event.queryStringParameters?.id || event.path?.split('/').pop();
  
  // Headers CORS y caché
  const headers = {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  // Manejar preflight OPTIONS
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }

  // Si no hay ID o el ID es "manifest", devolver manifest por defecto
  if (!id || id === 'manifest' || id === '') {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(DEFAULT_MANIFEST),
    };
  }

  try {
    const response = await fetchWithTimeout(`${API_URL}/catalogs/public/owner/${id}`);
    if (!response.ok) {
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify(DEFAULT_MANIFEST),
      };
    }

    const body = await response.json();
    const catalogs = body?.data;
    let name = 'Menucom Catalogo';
    let description = 'Catalogo para clientes CSM';
    let imageUrl = null;
    let catalogSettings = null;

    if (Array.isArray(catalogs) && catalogs.length > 0) {
      const owner = catalogs[0].owner;
      name = owner?.name || catalogs[0].name || name;
      imageUrl = extractOriginalUrl(owner?.photoURL) || extractOriginalUrl(catalogs[0].coverImageUrl);
      description = catalogs.map(c => c.name).filter(Boolean).join(', ') || description;
      catalogSettings = catalogs[0].settings;
    }

    let themeColor = '#CEDDFE';
    let backgroundColor = '#FFFFFF';
    if (catalogSettings && typeof catalogSettings === 'object') {
      themeColor = catalogSettings.themeColor || catalogSettings.primaryColor || themeColor;
      backgroundColor = catalogSettings.backgroundColor || backgroundColor;
    }

    const manifest = {
      id: '/' + id + '/',
      name: name,
      short_name: name.length > 12 ? name.substring(0, 12) : name,
      description: description,
      start_url: '/' + id + '/',
      scope: '/' + id + '/',
      display: 'standalone',
      background_color: backgroundColor,
      theme_color: themeColor,
      orientation: 'portrait-primary',
      prefer_related_applications: false,
      categories: ['business', 'shopping'],
      icons: buildIcons(imageUrl),
    };

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(manifest),
    };
  } catch (error) {
    console.error('[manifest] Error:', error);
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(DEFAULT_MANIFEST),
    };
  }
};

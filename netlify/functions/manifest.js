// Netlify Function: Manifest.json dinámico por comercio
// Sirve un manifest.json personalizado con nombre, logo y color del comercio.
// Se llama desde index.html como: /.netlify/functions/manifest?id={commerceId}

const DEFAULT_MANIFEST = {
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
    { src: 'icons/menucom-192.png', sizes: '192x192', type: 'image/png' },
    { src: 'icons/menucom-512.png', sizes: '512x512', type: 'image/png' },
    { src: 'icons/menucom-maskable-192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
    { src: 'icons/menucom-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
  ],
};

const API_URL = process.env.API_URL || 'https://menucom-api.onrender.com';

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

function buildIcons(coverImageUrl) {
  const icons = [];

  if (coverImageUrl) {
    icons.push(
      { src: coverImageUrl, sizes: '192x192', type: 'image/png', purpose: 'any' },
      { src: coverImageUrl, sizes: '512x512', type: 'image/png', purpose: 'any' },
    );
  }

  icons.push(
    { src: 'icons/menucom-192.png', sizes: '192x192', type: 'image/png' },
    { src: 'icons/menucom-512.png', sizes: '512x512', type: 'image/png' },
    { src: 'icons/menucom-maskable-192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
    { src: 'icons/menucom-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
  );

  return icons;
}

exports.handler = async (event) => {
  const id = event.queryStringParameters?.id || event.path?.split('/').pop();
  const origin = event.headers?.origin || event.headers?.referer || '';

  if (!id || id === 'manifest') {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      },
      body: JSON.stringify(DEFAULT_MANIFEST),
    };
  }

  try {
    const response = await fetch(`${API_URL}/catalogs/${id}`);
    if (!response.ok) {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
        body: JSON.stringify(DEFAULT_MANIFEST),
      };
    }

    const catalog = await response.json();
    const name = catalog.name || 'Menucom Catalogo';
    const description = catalog.description || 'Catalogo para clientes CSM';
    const imageUrl = extractOriginalUrl(catalog.coverImageUrl);

    // Intentar extraer theme_color del settings del catálogo
    let themeColor = '#CEDDFE';
    let backgroundColor = '#FFFFFF';
    if (catalog.settings && typeof catalog.settings === 'object') {
      themeColor = catalog.settings.themeColor || catalog.settings.primaryColor || themeColor;
      backgroundColor = catalog.settings.backgroundColor || backgroundColor;
    }

    const manifest = {
      name: name,
      short_name: name.length > 12 ? name.substring(0, 12) : name,
      description: description,
      start_url: '/',
      scope: '/',
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
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      },
      body: JSON.stringify(manifest),
    };
  } catch (error) {
    console.error('[manifest] Error:', error);
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      },
      body: JSON.stringify(DEFAULT_MANIFEST),
    };
  }
};

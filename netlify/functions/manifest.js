// Netlify Function: Proxy del manifest.json dinámico por comercio
// Delega la generación al backend: /catalogs/public/commerce/{id}/manifest
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

async function fetchWithTimeout(url, timeoutMs = 15000) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(url, { signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

exports.handler = async (event) => {
  const id = event.queryStringParameters?.id || event.path?.split('/').pop();
  
  const headers = {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }

  if (!id || id === 'manifest' || id === '') {
    return { statusCode: 200, headers, body: JSON.stringify(DEFAULT_MANIFEST) };
  }

  try {
    const response = await fetchWithTimeout(`${API_URL}/catalogs/public/commerce/${id}/manifest`);
    if (!response.ok) {
      return { statusCode: 200, headers, body: JSON.stringify(DEFAULT_MANIFEST) };
    }

    const manifest = await response.json();

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(manifest),
    };
  } catch (error) {
    console.error('[manifest] Error:', error);
    return { statusCode: 200, headers, body: JSON.stringify(DEFAULT_MANIFEST) };
  }
};

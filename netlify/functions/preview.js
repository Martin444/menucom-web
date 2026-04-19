
const SOCIAL_BOTS = [
	/facebookexternalhit/i,
    /Prerender/i,
	/Twitterbot/i,
	/WhatsApp/i,
	/linkedinbot/i,
	/Slackbot-LinkExpanding/i,
	/TelegramBot/i,
	/Discordbot/i,
	/Googlebot/i,
];

function isSocialBot(userAgent) {
	return SOCIAL_BOTS.some((regex) => regex.test(userAgent));
}

// Helper para decodificar la URL proxy (adaptado de RobustNetworkImage._extractOriginalUrl)
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
		// Forzar https incluso si no es proxy
		if (typeof originalUrl === 'string') {
				originalUrl = originalUrl.replace(/^http:\/\//i, 'https://');
		}
		return originalUrl;
}

// Helper para generar HTML
function buildHtml({
	title = 'MenuCom',
	description = 'Catálogo de productos',
	image = 'https://menu-comerce.netlify.app/default-image.png',
	url = 'https://menu-comerce.netlify.app/',
	body = '',
	pre = '',
}) {
	return `
<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>${title}</title>
	<meta property="og:title" content="${title}" />
	<meta property="og:description" content="${description}" />
	<meta property="og:image" content="${image}" />
	<meta property="og:url" content="${url}" />
	<meta property="og:type" content="website" />
	<meta property="og:site_name" content="MenuCom" />
	<meta name="twitter:title" content="${title}" />
	<meta name="twitter:description" content="${description}" />
	<meta name="twitter:image" content="${image}" />
	<meta name="twitter:card" content="summary_large_image" />
</head>
<body>
	<h1>${title}</h1>
	<p>${description}</p>
	${body}
	${pre ? `<pre>${pre}</pre>` : ''}
</body>
</html>
	`;
}

exports.handler = async (event) => {

			const userAgent = event.headers['user-agent'] || '';
			console.log('[preview] User-Agent:', userAgent);
            console.log('[preview] Headers:', event.headers);
			
		// Si no es un bot social, servir index.html directamente desde el filesystem
		// Esto mantiene la URL original y permite que Flutter lea el ID correctamente
		if (!isSocialBot(userAgent)) {
			console.log('[preview] No es un bot social, sirviendo index.html con URL original');
			
			const path = require('path');
			const fs = require('fs');
			
			// Ruta al index.html relativa a la función
			// En Netlify Functions, __dirname apunta a /.netlify/functions-internal/
			// El HTML público está en la raíz del sitio desplegado
			const indexPath = path.join(__dirname, '../../index.html');
			
			try {
				const indexHtml = fs.readFileSync(indexPath, 'utf8');
				
				console.log('[preview] Index.html leído correctamente, size:', indexHtml.length);
				console.log('[preview] Path original preservado:', event.path);
				
				return {
					statusCode: 200,
					headers: {
						'Content-Type': 'text/html; charset=utf-8',
						'Cache-Control': 'no-cache',
					},
					body: indexHtml,
				};
			} catch (error) {
				console.error('[preview] ERROR leyendo index.html:', error.message);
				console.error('[preview] Intentó leer de:', indexPath);
				
				// Fallback: devolver un HTML básico que redirige a root
				return {
					statusCode: 302,
					headers: {
						'Location': '/',
						'Cache-Control': 'no-cache',
					},
				};
			}
		}			const API_URL = process.env.API_URL || 'https://menucom-api.onrender.com';
			console.log('[preview] API_URL:', API_URL);

			let id = null;
			let idSource = '';
			if (event.queryStringParameters && event.queryStringParameters.id) {
				id = event.queryStringParameters.id;
				idSource = 'query';
			} else {
				const pathParts = event.path.split('/');
				id = pathParts.pop() || pathParts.pop();
				idSource = 'path';
			}

			if (!id || id.trim() === '') {
				console.warn('[preview] No se encontró un id válido.');
				return {
					statusCode: 200,
					headers: { 'Content-Type': 'text/html' },
					body: buildHtml({ title: 'MenuCom', description: 'No se encontró el recurso.' })
				};
			}

			try {
				// 1. Intentar obtener el catálogo (Nueva Arquitectura)
				console.log('[preview] Buscando catálogo:', id);
				const catalogResponse = await fetch(`${API_URL}/catalogs/${id}`);
				
				let title = 'MenuCom';
				let description = 'Consulta nuestro catálogo de productos';
				let imageUrl = 'https://menu-comerce.netlify.app/default-image.png';
				let found = false;

				if (catalogResponse.ok) {
					const catalog = await catalogResponse.json();
					title = catalog.name || 'Menú comercial';
					description = catalog.description || description;
					imageUrl = extractOriginalUrl(catalog.coverImageUrl) || imageUrl;
					found = true;
				} else {
					console.log('[preview] Catálogo no encontrado, intentando usuario...');
					// 2. Fallback: Usuario (Arquitectura Antigua)
					const userResponse = await fetch(`${API_URL}/user/user/${id}`);
					if (userResponse.ok) {
						const user = await userResponse.json();
						title = user.name || 'MenuCom';
						imageUrl = extractOriginalUrl(user.photoURL) || imageUrl;
						
						const roleEndpoint = user.role === 'clothes' ? 'wardrobe' : 'menu';
						const legacyResponse = await fetch(`${API_URL}/${roleEndpoint}/bydining/${id}`);
						if (legacyResponse.ok) {
							const legacyData = await legacyResponse.json();
							if (Array.isArray(legacyData.listmenu) && legacyData.listmenu.length > 0) {
								description = legacyData.listmenu.map(m => m.description).filter(Boolean).join(', ');
							}
						}
						found = true;
					}
				}

				if (!found) {
					return {
						statusCode: 200,
						headers: { 'Content-Type': 'text/html' },
						body: buildHtml({ title: 'MenuCom', description: 'Recurso no encontrado.' })
					};
				}

				return {
					statusCode: 200,
					headers: {
						'Cache-Control': 'no-cache, no-store, must-revalidate',
						'Content-Type': 'text/html',
					},
					body: buildHtml({
						title,
						description,
						image: imageUrl,
						url: `https://menu-comerce.netlify.app/${id}`,
						body: `<p>${description}</p><img src="${imageUrl}" alt="${title}" style="max-width:300px" />`
					}),
				};
			} catch (error) {
				console.error('[preview] Error general:', error);
				return {
					statusCode: 200,
					headers: { 'Content-Type': 'text/html' },
					body: buildHtml({ title: 'MenuCom', description: 'Error temporal.' })
				};
			}
		};

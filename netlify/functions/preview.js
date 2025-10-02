
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
		}			const API_URL = process.env.API_URL || 'https://menucom-api-60e608ae2f99.herokuapp.com';
			console.log('[preview] API_URL:', API_URL);

						let id = null;
						let idSource = '';
						if (event.queryStringParameters && event.queryStringParameters.id) {
								id = event.queryStringParameters.id;
								idSource = 'query';
								console.log('[preview] ID por query:', id);
						} else {
								const pathParts = event.path.split('/');
								id = pathParts.pop() || pathParts.pop();
								idSource = 'path';
								console.log('[preview] ID por path:', id);
						}
						// Validar que el id exista y sea string no vacío
						if (!id || typeof id !== 'string' || id.trim() === '') {
								console.warn('[preview] No se encontró un id válido. Source:', idSource);
								const fallbackHtml = buildHtml({
									title: 'MenuCom',
									description: 'No se encontró el recurso solicitado.',
									image: 'https://menu-comerce.netlify.app/default-image.png',
									url: 'https://menu-comerce.netlify.app/',
									body: '<p>No se encontró el recurso solicitado.</p>',
								});
								return {
									statusCode: 200,
									headers: {
										'Cache-Control': 'no-cache, no-store, must-revalidate',
										'Content-Type': 'text/html',
									},
									body: fallbackHtml,
								};
						}


			let apiUrluser = `${API_URL}/user/user/${id}`;
			let apiUrlmenu = `${API_URL}/menu/bydining/${id}`;
			let apiUrlward = `${API_URL}/wardrobe/bydining/${id}`;

			console.log('[preview] apiUrluser:', apiUrluser);
			console.log('[preview] apiUrlmenu:', apiUrlmenu);
			console.log('[preview] apiUrlward:', apiUrlward);

			try {
				// 1. Obtener usuario
				const responseUser = await fetch(apiUrluser);
				if (!responseUser.ok) {
					const textUser = await responseUser.text();
					console.error('[preview] Error response user:', textUser);
					return {
						statusCode: responseUser.status,
						body: `No se encontró el usuario. Backend response: ${textUser}`,
					};
				}
				const user = await responseUser.json();
				console.log('[preview] Data recibida user:', user);

				let data = null;
				let html = '';

	               // 2. Según el role, obtener menú o wardrobe
	               // Decodificar la URL de la foto del usuario si existe
	               const safeUserPhotoUrl = extractOriginalUrl(user.photoURL) || 'https://menu-comerce.netlify.app/default-image.png';

	               if (user.role === 'clothes') {
	                                       const responseWard = await fetch(apiUrlward);
	                                       if (!responseWard.ok) {
	                                               const textWard = await responseWard.text();
	                                               console.error('[preview] Error response wardrobe:', textWard);
	                                               html = buildHtml({
	                                                 title: user.name || 'MenuCom',
	                                                 description: 'Catálogo de productos',
	                                                 image: safeUserPhotoUrl,
	                                                 url: `https://menu-comerce.netlify.app/${id}`,
	                                                 body: `<p>No se encontró el wardrobe.</p>`,
	                                                 body: `<p>No se encontró el wardrobe.</p><img src="${safeUserPhotoUrl}" alt="Imagen del comercio" />`,
	                                               });
	                                       } else {
	                                               data = await responseWard.json();
	                                               let descriptions = 'Catálogo de productos';
	                                               if (Array.isArray(data.listmenu) && data.listmenu.length > 0) {
	                                                       descriptions = data.listmenu.map(m => m.description).filter(Boolean).join(', ');
	                                               }
	                                               // La imagen siempre viene del usuario, no de la respuesta del wardrobe.
	                                               const imageUrl = extractOriginalUrl(user.photoURL) || 'https://menu-comerce.netlify.app/default-image.png';
	                                               html = buildHtml({
	                                                 title: user.name || 'MenuCom',
	                                                 description: descriptions,
	                                                 image: imageUrl,
	                                                 url: `https://menu-comerce.netlify.app/${id}`,
	                                                 body: `<p>${descriptions || ''}</p><img src="${imageUrl}" alt="Imagen del comercio" />`,
	                                                 pre: JSON.stringify(data, null, 2),
	                                               });
	                                       }
				} else {
					const responseMenu = await fetch(apiUrlmenu);
					if (!responseMenu.ok) {
						const textMenu = await responseMenu.text();
						console.error('[preview] Error response menu:', textMenu);
						return {
							statusCode: responseMenu.status,
							body: `No se encontró el recurso menu. Backend response: ${textMenu}`,
						};
					}
										data = await responseMenu.json();
										console.log('[preview] Data recibida menu:', data);
										// La imagen y el título principal vienen del objeto 'user', no de la respuesta del menú.
										// La respuesta del menú ('data') se usa para la descripción.
										const imageUrl = extractOriginalUrl(user.photoURL) || 'https://menu-comerce.netlify.app/default-image.png';
										const description = Array.isArray(data.listmenu) ? data.listmenu.map(m => m.description).filter(Boolean).join(', ') : 'Catálogo de productos';

	                                       html = buildHtml({
	                                         title: user.name || 'MenuCom',
	                                         description: description,
	                                         image: imageUrl,
	                                         url: `https://menu-comerce.netlify.app/${id}`,
	                                         body: `<p>${description || ''}</p><img src="${imageUrl}" alt="Imagen del comercio" />`,
	                                         pre: JSON.stringify(data, null, 2),
	                                       });
				}

				return {
					statusCode: 200,
					headers: {
						'Cache-Control': 'no-cache, no-store, must-revalidate',
						'Content-Type': 'text/html',
					},
					body: html,
				};
			} catch (error) {
				console.error('[preview] Error general:', error);
				// Fallback HTML genérico con metatags
								const fallbackHtml = buildHtml({
									title: 'MenuCom',
									description: 'No se encontró el recurso solicitado.',
									image: 'https://menu-comerce.netlify.app/default-image.png',
									url: 'https://menu-comerce.netlify.app/',
									body: '<p>No se encontró el recurso solicitado.</p>',
								});
								return {
									statusCode: 200,
									headers: {
										'Cache-Control': 'no-cache, no-store, must-revalidate',
										'Content-Type': 'text/html',
									},
									body: fallbackHtml,
								};
			}
		};

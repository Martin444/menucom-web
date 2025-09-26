
const SOCIAL_BOTS = [
	/facebookexternalhit/i,
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

exports.handler = async (event) => {

			const userAgent = event.headers['user-agent'] || '';
			console.log('[preview] User-Agent:', userAgent);
			if (!isSocialBot(userAgent)) {
				console.log('[preview] No es un bot social, ignorando.');
				return {
					statusCode: 404,
					body: 'Not a social bot',
				};
			}

			const API_URL = process.env.API_URL || 'https://menucom-api-60e608ae2f99.herokuapp.com';
			console.log('[preview] API_URL:', API_URL);

			let id = null;
			if (event.queryStringParameters && event.queryStringParameters.id) {
				id = event.queryStringParameters.id;
				console.log('[preview] ID por query:', id);
			} else {
				const pathParts = event.path.split('/');
				id = pathParts.pop() || pathParts.pop();
				console.log('[preview] ID por path:', id);
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
				if (user.role === 'clothes') {
					const responseWard = await fetch(apiUrlward);
					if (!responseWard.ok) {
						const textWard = await responseWard.text();
						console.error('[preview] Error response wardrobe:', textWard);
						return {
							statusCode: responseWard.status,
							body: `No se encontró el recurso wardrobe. Backend response: ${textWard}`,
						};
					}
					data = await responseWard.json();
					console.log('[preview] Data recibida wardrobe:', data);

					// Construir descripción con todos los descriptions de listmenu
					let descriptions = '';
					if (Array.isArray(data.listmenu) && data.listmenu.length > 0) {
						descriptions = data.listmenu.map(m => m.description).filter(Boolean).join(', ');
					}

					html = `
						<!DOCTYPE html>
						<html lang=\"es\">
						<head>
							<meta charset=\"UTF-8\">
							<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
							<title>${user.name || 'MenuCom'}</title>
							<meta property=\"og:title\" content=\"${user.name || ''}\" />
							<meta property=\"og:description\" content=\"${descriptions}\" />
							<meta property=\"og:image\" content=\"${user.photoURL || ''}\" />
							<meta property=\"og:url\" content=\"https://menu-comerce.netlify.app/${id}\" />
							<meta name=\"twitter:card\" content=\"summary_large_image\" />
						</head>
						<body>
							<h1>${user.name || ''}</h1>
							<p>${descriptions}</p>
							<img src=\"${user.photoURL || ''}\" alt=\"Imagen del comercio\" />
						</body>
						</html>
					`;
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

					html = `
						<!DOCTYPE html>
						<html lang=\"es\">
						<head>
							<meta charset=\"UTF-8\">
							<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
							<title>${data.nombre || 'MenuCom'}</title>
							<meta property=\"og:title\" content=\"${data.nombre || ''}\" />
							<meta property=\"og:description\" content=\"${data.descripcion || ''}\" />
							<meta property=\"og:image\" content=\"${data.imagen || ''}\" />
							<meta property=\"og:url\" content=\"https://menu-comerce.netlify.app/${id}\" />
							<meta name=\"twitter:card\" content=\"summary_large_image\" />
						</head>
						<body>
							<h1>${data.nombre || ''}</h1>
							<p>${data.descripcion || ''}</p>
							<img src=\"${data.imagen || ''}\" alt=\"Imagen del comercio\" />
						</body>
						</html>
					`;
				}

				return {
					statusCode: 200,
					headers: {
						'Content-Type': 'text/html',
					},
					body: html,
				};
			} catch (error) {
				console.error('[preview] Error general:', error);
				return {
					statusCode: 500,
					body: 'Error general en preview: ' + error.message,
				};
			}
		};

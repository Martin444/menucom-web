
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
	if (!isSocialBot(userAgent)) {
		return {
			statusCode: 404,
			body: 'Not a social bot',
		};
	}

	// Obtener la base URL de la API desde variables de entorno Netlify
	const API_URL = process.env.API_URL || 'https://menucom-api-60e608ae2f99.herokuapp.com';

	// Extraer el ID del menú o wardrobe desde la URL
	const pathParts = event.path.split('/');
	const id = pathParts.pop() || pathParts.pop();
	let apiUrl = '';
	if (event.path.includes('wardrobe')) {
		apiUrl = `${API_URL}/api/wardrobe/${id}`;
	} else {
		apiUrl = `${API_URL}/api/menu/${id}`;
	}

	try {
		const response = await fetch(apiUrl);
		if (!response.ok) {
			throw new Error('No se encontró el recurso');
		}
		const data = await response.json();

		const html = `
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

		return {
			statusCode: 200,
			headers: {
				'Content-Type': 'text/html',
			},
			body: html,
		};
	} catch (error) {
		return {
			statusCode: 500,
			body: 'Error al obtener datos: ' + error.message,
		};
	}
};

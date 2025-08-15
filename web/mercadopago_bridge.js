// Simple bridge to interact with MercadoPago.js V2 from Flutter Web via `package:js` or `dart:js`.
// Exposes window.mpInit(publicKey, locale), window.mpCreateCardForm(options), and window.mpCheckout(preferenceId, options)

(function () {
  // Hold instance in window to reuse
  let mpInstance = null;

  function ensureMP() {
    if (!window.MercadoPago) {
      throw new Error('MercadoPago.js V2 not loaded');
    }
  }

  // Initialize MercadoPago instance
  window.mpInit = function (publicKey, locale) {
    ensureMP();
    mpInstance = new window.MercadoPago(publicKey, { locale: locale || 'es-AR' });
    return true;
  };

  // Create checkout brick (preferred approach)
  window.mpCheckout = async function (preferenceId, options) {
    ensureMP();
    if (!mpInstance) throw new Error('Call mpInit(publicKey) before mpCheckout');

    const cfg = Object.assign({
      container: 'mp-checkout-container',
    }, options || {});

    const containerId = cfg.container;
    // Build settings for wallet brick: move known keys to proper places
    const { container, ...rest } = cfg; // remove container from settings
    const settings = Object.assign({}, rest, {
      initialization: Object.assign({}, rest.initialization || {}, {
        preferenceId: preferenceId,
      }),
    });

    const bricksBuilder = mpInstance.bricks();
    if (!bricksBuilder) throw new Error('Bricks builder not available');

    const result = await bricksBuilder.create('wallet', containerId, settings);
    return !!result;
  };

  // Expose card form creation for advanced flows
  window.mpCreateCardForm = function (options) {
    ensureMP();
    if (!mpInstance) throw new Error('Call mpInit(publicKey) before mpCreateCardForm');

    const cardForm = mpInstance.cardForm(options || {});
    return !!cardForm;
  };
})();

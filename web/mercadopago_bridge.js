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
  try { console.log('[MP_BRIDGE] mpInit ok', { locale, hasInstance: !!mpInstance }); } catch (_) {}
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

    try { console.log('[MP_BRIDGE] mpCheckout called', { containerId, settings }); } catch (_) {}

    // Ensure container exists; retry a few times if needed
    const ensureContainer = () => !!document.getElementById(containerId);
    if (!ensureContainer()) {
      try { console.warn('[MP_BRIDGE] Container not found initially', containerId); } catch (_) {}
      await new Promise((resolve) => setTimeout(resolve, 50));
    }
    if (!ensureContainer()) {
      try { console.warn('[MP_BRIDGE] Container still missing', containerId); } catch (_) {}
      await new Promise((resolve) => requestAnimationFrame(resolve));
    }
    if (!ensureContainer()) {
      try { console.error('[MP_BRIDGE] Container not found, aborting', containerId); } catch (_) {}
      throw new Error(`[Checkout Bricks error] Could not find the Brick container ID '${containerId}'.`);
    }

    const result = await bricksBuilder.create('wallet', containerId, settings);
    try { console.log('[MP_BRIDGE] bricks.create result', !!result); } catch (_) {}
    return !!result;
  };

  // Alternative with explicit containerId to avoid issues passing objects from Dart
  window.mpCheckout2 = async function (preferenceId, containerId, settings) {
    ensureMP();
    if (!mpInstance) throw new Error('Call mpInit(publicKey) before mpCheckout2');

    const cfgSettings = Object.assign({}, settings || {});
    cfgSettings.initialization = Object.assign({}, cfgSettings.initialization || {}, {
      preferenceId: preferenceId,
    });

    const bricksBuilder = mpInstance.bricks();
    if (!bricksBuilder) throw new Error('Bricks builder not available');

    try { console.log('[MP_BRIDGE] mpCheckout2 called', { containerId, cfgSettings }); } catch (_) {}

    const ensureContainer = () => !!document.getElementById(containerId);
    if (!ensureContainer()) {
      try { console.warn('[MP_BRIDGE] (2) Container not found initially', containerId); } catch (_) {}
      await new Promise((resolve) => setTimeout(resolve, 50));
    }
    if (!ensureContainer()) {
      try { console.warn('[MP_BRIDGE] (2) Container still missing', containerId); } catch (_) {}
      await new Promise((resolve) => requestAnimationFrame(resolve));
    }
    if (!ensureContainer()) {
      try { console.error('[MP_BRIDGE] (2) Container not found, aborting', containerId); } catch (_) {}
      throw new Error(`[Checkout Bricks error] Could not find the Brick container ID '${containerId}'.`);
    }

    const result = await bricksBuilder.create('wallet', containerId, cfgSettings);
    try { console.log('[MP_BRIDGE] (2) bricks.create result', !!result); } catch (_) {}
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

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
    try {
      mpInstance = new window.MercadoPago(publicKey, { locale: locale || 'es-AR' });
      
      // Verify the instance was created successfully
      if (!mpInstance) {
        throw new Error('Failed to create MercadoPago instance');
      }
      
      // Check if the public key is valid (basic validation)
      if (!publicKey || publicKey.trim() === '' || publicKey === 'undefined') {
        throw new Error('Invalid or missing MercadoPago public key');
      }
      
      try { console.log('[MP_BRIDGE] mpInit ok', { locale, publicKey: publicKey.substring(0, 8) + '...', hasInstance: !!mpInstance }); } catch (_) {}
      return true;
    } catch (error) {
      try { console.error('[MP_BRIDGE] Error in mpInit:', error.message, error); } catch (_) {}
      throw error;
    }
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
    try {
      ensureMP();
      if (!mpInstance) throw new Error('Call mpInit(publicKey) before mpCheckout2');

      // Validate preferenceId
      if (!preferenceId || preferenceId.trim() === '') {
        throw new Error('PreferenceId is required and cannot be empty');
      }

      const cfgSettings = Object.assign({}, settings || {});
      cfgSettings.initialization = Object.assign({}, cfgSettings.initialization || {}, {
        preferenceId: preferenceId,
      });

      const bricksBuilder = mpInstance.bricks();
      if (!bricksBuilder) throw new Error('Bricks builder not available');

      try { console.log('[MP_BRIDGE] mpCheckout2 called', { preferenceId, containerId, cfgSettings }); } catch (_) {}

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

      // Add error handling for brick creation
      const result = await bricksBuilder.create('wallet', containerId, cfgSettings);
      try { console.log('[MP_BRIDGE] (2) bricks.create result', result); } catch (_) {}
      
      if (!result) {
        throw new Error('Failed to create MercadoPago wallet brick');
      }
      
      return !!result;
    } catch (error) {
      try { 
        console.error('[MP_BRIDGE] Error in mpCheckout2:', error.message, error); 
        // Show error to user
        const container = document.getElementById(containerId);
        if (container) {
          container.innerHTML = `
            <div style="padding: 20px; text-align: center; color: #d32f2f; border: 1px solid #d32f2f; border-radius: 8px; margin: 10px;">
              <h3>Error en el procesamiento del pago</h3>
              <p>Error: ${error.message}</p>
              <p>Por favor, intenta nuevamente o contacta con soporte.</p>
            </div>
          `;
        }
      } catch (_) {}
      throw error;
    }
  };

  // Expose card form creation for advanced flows
  window.mpCreateCardForm = function (options) {
    ensureMP();
    if (!mpInstance) throw new Error('Call mpInit(publicKey) before mpCreateCardForm');

    const cardForm = mpInstance.cardForm(options || {});
    return !!cardForm;
  };
})();

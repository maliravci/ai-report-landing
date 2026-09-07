(function () {
  'use strict';

  const config = window.REPORT_DRAFTER_ANALYTICS || {};
  const measurementId = String(config.measurementId || '').trim();
  const consentCookie = 'reportdrafter_analytics_consent';
  const consentMaxAgeSeconds = 60 * 60 * 24 * 180;
  const consentRegionEndpoint = '/_consent/region';
  let analyticsAllowed = false;

  if (!/^G-[A-Z0-9]+$/.test(measurementId)) return;

  function getConsent() {
    const match = document.cookie.match(new RegExp('(?:^|; )' + consentCookie + '=([^;]*)'));
    const value = match && match[1];
    return value === 'granted' || value === 'denied' ? value : null;
  }

  function saveConsent(value) {
    const secure = window.location.protocol === 'https:' ? '; Secure' : '';
    const hostname = window.location.hostname;
    const domain = hostname === 'reportdrafter.com' || hostname.endsWith('.reportdrafter.com')
      ? '; Domain=.reportdrafter.com'
      : '';
    document.cookie = consentCookie + '=' + value + '; Path=/; Max-Age=' + consentMaxAgeSeconds + '; SameSite=Lax' + domain + secure;
  }

  function clearConsent() {
    const secure = window.location.protocol === 'https:' ? '; Secure' : '';
    const hostname = window.location.hostname;
    const domain = hostname === 'reportdrafter.com' || hostname.endsWith('.reportdrafter.com')
      ? '; Domain=.reportdrafter.com'
      : '';
    document.cookie = consentCookie + '=; Path=/; Max-Age=0; SameSite=Lax' + domain + secure;
  }

  function updateAnalyticsConsent(value) {
    analyticsAllowed = value === 'granted';
    window['ga-disable-' + measurementId] = !analyticsAllowed;
    if (!window.gtag) return;
    window.gtag('consent', 'update', {
      analytics_storage: value,
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
    });
  }

  function loadAnalytics() {
    if (window.__reportDrafterAnalyticsLoaded) return;
    window.__reportDrafterAnalyticsLoaded = true;
    window.dataLayer = window.dataLayer || [];
    window.gtag = window.gtag || function () { window.dataLayer.push(arguments); };
    window.gtag('js', new Date());
    window.gtag('consent', 'default', {
      analytics_storage: 'denied',
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      wait_for_update: 500,
    });
    window.gtag('config', measurementId, { send_page_view: false });

    const script = document.createElement('script');
    script.async = true;
    script.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(measurementId);
    document.head.appendChild(script);

  }

  function trackPageView() {
    window.gtag('event', 'page_view', {
      page_path: window.location.pathname,
      page_title: document.title,
    });
  }

  function addConsentBanner() {
    const banner = document.createElement('section');
    banner.className = 'analytics-consent';
    banner.setAttribute('role', 'dialog');
    banner.setAttribute('aria-label', 'Analytics preferences');
    const pagePrefix = window.location.pathname.indexOf('/pages/') >= 0 ? '' : 'pages/';
    const copy = document.createElement('div');
    const title = document.createElement('strong');
    const description = document.createElement('p');
    const privacyLink = document.createElement('a');
    title.textContent = 'Help improve Report Drafter';
    description.textContent = 'Allow optional usage analytics so we can improve the pages and tools people find useful. We never send document content, uploaded files, or account details. ';
    privacyLink.href = pagePrefix + 'privacy.html';
    privacyLink.textContent = 'Privacy policy';
    description.appendChild(privacyLink);
    copy.appendChild(title);
    copy.appendChild(description);

    const actions = document.createElement('div');
    actions.className = 'analytics-consent__actions';
    const decline = document.createElement('button');
    const accept = document.createElement('button');
    decline.type = 'button';
    decline.className = 'btn btn-ghost btn-sm';
    decline.textContent = 'Decline';
    accept.type = 'button';
    accept.className = 'btn btn-primary btn-sm';
    accept.textContent = 'Allow analytics';
    decline.addEventListener('click', function () {
      saveConsent('denied');
      updateAnalyticsConsent('denied');
      banner.remove();
    });
    accept.addEventListener('click', function () {
      saveConsent('granted');
      updateAnalyticsConsent('granted');
      loadAnalytics();
      updateAnalyticsConsent('granted');
      trackPageView();
      banner.remove();
    });
    actions.appendChild(decline);
    actions.appendChild(accept);
    banner.appendChild(copy);
    banner.appendChild(actions);
    document.body.appendChild(banner);
  }

  function addPreferencesControl() {
    if (document.querySelector('[data-analytics-preferences]')) return;
    const footer = document.querySelector('.footer-bottom');
    if (!footer) return;
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'analytics-preferences-link';
    button.dataset.analyticsPreferences = 'true';
    button.textContent = 'Privacy settings';
    button.addEventListener('click', function () {
      clearConsent();
      updateAnalyticsConsent('denied');
      addConsentBanner();
    });
    footer.appendChild(button);
  }

  function trackCtaClicks() {
    document.querySelectorAll('a[href*="app.reportdrafter.com"]').forEach(function (link) {
      link.addEventListener('click', function () {
        if (!analyticsAllowed || !window.gtag) return;
        const href = link.getAttribute('href') || '';
        const destination = href.indexOf('/signup') >= 0 ? 'signup' : href.indexOf('/login') >= 0 ? 'login' : 'app';
        window.gtag('event', 'landing_cta_click', { destination: destination });
      });
    });
  }

  trackCtaClicks();
  fetch(consentRegionEndpoint, { credentials: 'same-origin', cache: 'no-store' })
    .then(function (response) { return response.ok ? response.json() : null; })
    .then(function (region) {
      // Unknown region or a failed edge lookup must fail closed. Treat it like
      // a consent-required region rather than loading a third-party tag early.
      const requiresConsent = !region || typeof region.requiresConsent !== 'boolean'
        ? true
        : region.requiresConsent;
      if (!requiresConsent) {
        addPreferencesControl();
        updateAnalyticsConsent('granted');
        loadAnalytics();
        updateAnalyticsConsent('granted');
        trackPageView();
        return;
      }

      addPreferencesControl();
      const savedConsent = getConsent();
      if (savedConsent === 'granted') {
        // Reissue older host-only choices for the shared ReportDrafter domain.
        saveConsent(savedConsent);
        updateAnalyticsConsent('granted');
        loadAnalytics();
        updateAnalyticsConsent('granted');
        trackPageView();
      } else if (savedConsent === 'denied') {
        // A prior refusal is sufficient; do not create a tag request or
        // repeatedly interrupt the visitor with the banner.
        updateAnalyticsConsent('denied');
      } else {
        addConsentBanner();
      }
    })
    .catch(function () {
      // Network failures are privacy-sensitive: show the choice and wait.
      addPreferencesControl();
      const savedConsent = getConsent();
      if (savedConsent === 'granted') {
        updateAnalyticsConsent('granted');
        loadAnalytics();
        updateAnalyticsConsent('granted');
        trackPageView();
      } else if (!savedConsent) {
        addConsentBanner();
      }
    });
}());

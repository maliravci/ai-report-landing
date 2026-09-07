/** ReportDrafter marketing site interactions */
(function () {
  'use strict';

  const navbar = document.getElementById('navbar');
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  const progress = document.createElement('div');
  progress.className = 'scroll-progress';
  progress.setAttribute('aria-hidden', 'true');
  progress.innerHTML = '<span></span>';
  document.body.prepend(progress);
  const progressBar = progress.firstElementChild;

  const updateScrollState = function () {
    const scrollTop = window.scrollY;
    const available = document.documentElement.scrollHeight - window.innerHeight;
    const percentage = available > 0 ? Math.min(100, (scrollTop / available) * 100) : 0;

    if (navbar) navbar.classList.toggle('scrolled', scrollTop > 18);
    if (progressBar) progressBar.style.transform = 'scaleX(' + (percentage / 100) + ')';
  };

  let scrollQueued = false;
  window.addEventListener('scroll', function () {
    if (scrollQueued) return;
    scrollQueued = true;
    window.requestAnimationFrame(function () {
      updateScrollState();
      scrollQueued = false;
    });
  }, { passive: true });
  updateScrollState();

  if (navToggle && navLinks) {
    const mobileActions = document.createElement('li');
    mobileActions.className = 'mobile-menu-actions';
    mobileActions.setAttribute('aria-label', 'Account actions');

    [
      ['Sign in', 'https://app.reportdrafter.com/login', 'mobile-menu-action mobile-menu-action-outline'],
      ['Start free', 'https://app.reportdrafter.com/signup', 'mobile-menu-action mobile-menu-action-primary']
    ].forEach(function (definition) {
      const action = document.createElement('a');
      action.textContent = definition[0];
      action.href = definition[1];
      action.className = definition[2];
      mobileActions.appendChild(action);
    });
    navLinks.appendChild(mobileActions);

    const closeMenu = function () {
      navLinks.classList.remove('open');
      navToggle.classList.remove('is-open');
      navToggle.setAttribute('aria-expanded', 'false');
    };

    navToggle.addEventListener('click', function () {
      const open = navLinks.classList.toggle('open');
      navToggle.classList.toggle('is-open', open);
      navToggle.setAttribute('aria-expanded', String(open));
    });
    navLinks.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', closeMenu);
    });
    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') closeMenu();
    });
  }

  const revealGroups = [
    '.section-intro', '.copy-block', '.context-visual', '.review-visual',
    '.workspace-visual', '.path-grid > div', '.final-cta .container'
  ];
  const staggerGroups = [
    '.workflow-line article', '.capability-grid article', '.context-files > div',
    '.workspace-metrics > div'
  ];
  const revealItems = [];

  revealGroups.forEach(function (selector) {
    document.querySelectorAll(selector).forEach(function (element) {
      element.classList.add('reveal');
      revealItems.push(element);
    });
  });
  staggerGroups.forEach(function (selector) {
    document.querySelectorAll(selector).forEach(function (element, index) {
      element.classList.add('reveal');
      element.style.setProperty('--reveal-delay', Math.min(index, 5) * 80 + 'ms');
      revealItems.push(element);
    });
  });

  if (reducedMotion || !('IntersectionObserver' in window)) {
    revealItems.forEach(function (element) { element.classList.add('is-visible'); });
  } else {
    const revealObserver = new IntersectionObserver(function (entries, observer) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0.12 });
    revealItems.forEach(function (element) { revealObserver.observe(element); });
  }

  const navAnchors = Array.from(document.querySelectorAll('.nav-links a[href^="#"]'));
  const sections = navAnchors.map(function (anchor) {
    return document.querySelector(anchor.getAttribute('href'));
  }).filter(Boolean);

  if ('IntersectionObserver' in window && sections.length) {
    const sectionObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        navAnchors.forEach(function (anchor) {
          anchor.classList.toggle('active', anchor.getAttribute('href') === '#' + entry.target.id);
        });
      });
    }, { rootMargin: '-28% 0px -62% 0px', threshold: 0 });
    sections.forEach(function (section) { sectionObserver.observe(section); });
  }

  if (!reducedMotion) {
    const productStage = document.querySelector('.product-stage');
    if (productStage && window.matchMedia('(min-width: 1051px)').matches) {
      window.addEventListener('mousemove', function (event) {
        const x = (event.clientX / window.innerWidth - 0.5) * 2;
        const y = (event.clientY / window.innerHeight - 0.5) * 2;
        productStage.style.setProperty('--tilt-x', (-y * 1.2) + 'deg');
        productStage.style.setProperty('--tilt-y', (-3 + x * 1.2) + 'deg');
      }, { passive: true });
    }
  }

  document.querySelectorAll('.js-year').forEach(function (element) {
    element.textContent = String(new Date().getFullYear());
  });

  const contactForm = document.getElementById('contactForm');
  if (contactForm) {
    contactForm.addEventListener('submit', function (event) {
      event.preventDefault();
      const name = contactForm.elements.name;
      const email = contactForm.elements.email;
      const message = contactForm.elements.message;
      const status = document.getElementById('formStatus');
      const fields = [name, email, message];
      let valid = true;

      fields.forEach(function (field) {
        const error = document.getElementById('error-' + field.name);
        const messageText = field.value.trim() ? '' : 'Please complete this field.';
        if (error) error.textContent = messageText;
        field.setAttribute('aria-invalid', messageText ? 'true' : 'false');
        if (messageText) valid = false;
      });

      if (email.value.trim() && !email.validity.valid) {
        const error = document.getElementById('error-email');
        if (error) error.textContent = 'Please enter a valid email address.';
        email.setAttribute('aria-invalid', 'true');
        valid = false;
      }

      if (!valid) {
        if (status) status.textContent = 'Please check the highlighted fields.';
        return;
      }

      if (status) status.textContent = 'Thanks — your message is ready to be sent. The contact form endpoint still needs to be connected.';
    });
  }
}());

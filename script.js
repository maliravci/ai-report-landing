/**
 * ReportDrafter — Landing Page Scripts
 *
 * Handles:
 *  - Navbar scroll effect
 *  - Mobile menu toggle
 *  - Scroll-triggered fade-in animations
 *  - Smooth scroll for anchor links
 *  - FAQ accordion
 *  - Back-to-top button
 *  - Floating CTA
 *  - Active nav link highlight
 */

(function () {
  'use strict';

  // --- Navbar scroll effect ---
  const navbar = document.getElementById('navbar');

  function handleScroll() {
    if (!navbar) {
      return;
    }

    if (window.scrollY > 20) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  }

  window.addEventListener('scroll', handleScroll, { passive: true });
  handleScroll(); // initial check

  // --- Mobile menu toggle ---
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');

  if (navToggle && navLinks) {
    navToggle.setAttribute('aria-expanded', 'false');

    function closeNavMenu() {
      navLinks.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
    }

    navToggle.addEventListener('click', function () {
      let isOpen = navLinks.classList.toggle('open');
      navToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });

    // Close menu when a link is clicked
    navLinks.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        closeNavMenu();
      });
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') {
        closeNavMenu();
      }
    });
  }

  // --- Scroll-triggered fade-in animations ---
  // Add .fade-in class to animatable elements
  const animatableSelectors = [
    '.feature-card',
    '.step',
    '.platform-card',
    '.confidence-content',
    '.confidence-visual',
    '.cta-card',
    '.testimonial-card',
    '.pricing-card',
    '.faq-item',
  ];

  animatableSelectors.forEach(function (selector) {
    document.querySelectorAll(selector).forEach(function (el) {
      el.classList.add('fade-in');
    });
  });

  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15, rootMargin: '0px 0px -40px 0px' }
    );

    document.querySelectorAll('.fade-in').forEach(function (el) {
      observer.observe(el);
    });
  } else {
    document.querySelectorAll('.fade-in').forEach(function (el) {
      el.classList.add('visible');
    });
  }

  // --- Stagger animation for grid items ---
  document.querySelectorAll('.features-grid, .platform-cards').forEach(function (grid) {
    const children = grid.querySelectorAll('.fade-in');
    children.forEach(function (child, i) {
      child.style.transitionDelay = i * 100 + 'ms';
    });
  });

  // Steps stagger
  document.querySelectorAll('.steps .step.fade-in').forEach(function (step, i) {
    step.style.transitionDelay = i * 120 + 'ms';
  });

  // Testimonials + pricing stagger
  ['testimonials-grid', 'pricing-grid'].forEach(function (cls) {
    const grid = document.querySelector('.' + cls);
    if (!grid) { return; }
    grid.querySelectorAll('.fade-in').forEach(function (card, i) {
      card.style.transitionDelay = i * 100 + 'ms';
    });
  });

  // --- FAQ accordion ---
  document.querySelectorAll('.faq-question').forEach(function (btn) {
    btn.addEventListener('click', function () {
      const expanded = this.getAttribute('aria-expanded') === 'true';
      const answer = this.nextElementSibling;

      // Collapse all others
      document.querySelectorAll('.faq-question').forEach(function (other) {
        other.setAttribute('aria-expanded', 'false');
        const otherAnswer = other.nextElementSibling;
        if (otherAnswer) { otherAnswer.hidden = true; }
      });

      // Toggle clicked item
      if (!expanded) {
        this.setAttribute('aria-expanded', 'true');
        if (answer) { answer.hidden = false; }
      }
    });
  });

  // --- Back to top ---
  const backToTop = document.getElementById('backToTop');

  function updateBackToTop() {
    if (!backToTop) { return; }
    if (window.scrollY > 400) {
      backToTop.classList.add('visible');
    } else {
      backToTop.classList.remove('visible');
    }
  }

  if (backToTop) {
    backToTop.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  // --- Floating CTA ---
  const floatingCta = document.getElementById('floatingCta');
  const heroSection = document.querySelector('.hero');

  function updateFloatingCta() {
    if (!floatingCta || !heroSection) { return; }
    const heroBottom = heroSection.getBoundingClientRect().bottom;
    if (heroBottom < 0) {
      floatingCta.classList.add('visible');
      floatingCta.setAttribute('aria-hidden', 'false');
      if (backToTop) { backToTop.classList.add('cta-offset'); }
    } else {
      floatingCta.classList.remove('visible');
      floatingCta.setAttribute('aria-hidden', 'true');
      if (backToTop) { backToTop.classList.remove('cta-offset'); }
    }
  }

  // --- Active nav link on scroll ---
  const navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');
  const navIds = new Set();
  navAnchors.forEach(function (a) {
    navIds.add(a.getAttribute('href').slice(1));
  });
  const navSections = Array.from(
    document.querySelectorAll('main > section[id], main > div[id]')
  ).filter(function (sec) { return navIds.has(sec.id); });

  function updateActiveNav() {
    if (!navAnchors.length) { return; }
    const scrollMid = window.scrollY + window.innerHeight / 3;
    let current = '';
    navSections.forEach(function (sec) {
      if (sec.offsetTop <= scrollMid) { current = sec.id; }
    });
    navAnchors.forEach(function (a) {
      const hash = a.getAttribute('href').slice(1);
      if (hash === current) {
        a.classList.add('active');
      } else {
        a.classList.remove('active');
      }
    });
  }

  // Throttle scroll updates via requestAnimationFrame
  let scrollTicking = false;

  window.addEventListener('scroll', function () {
    if (!scrollTicking) {
      requestAnimationFrame(function () {
        updateBackToTop();
        updateFloatingCta();
        updateActiveNav();
        scrollTicking = false;
      });
      scrollTicking = true;
    }
  }, { passive: true });

  updateBackToTop();
  updateFloatingCta();
  updateActiveNav();

  // --- Dynamic year ---
  const currentYear = new Date().getFullYear();
  document.querySelectorAll('.js-year').forEach(function (el) {
    el.textContent = currentYear;
  });

  // --- Dynamic hero NAV date ---
  const heroNavDate = document.getElementById('heroNavDate');
  if (heroNavDate) {
    heroNavDate.textContent = new Date().toISOString().slice(0, 10);
  }

  // --- Contact form validation (contact page) ---
  const contactForm = document.getElementById('contactForm');
  const formStatus = document.getElementById('formStatus');
  const contactSubmit = document.getElementById('contactSubmit');

  if (contactForm && formStatus && contactSubmit) {
    const submitDefaultHtml = contactSubmit.innerHTML;

    function showFormError(id, message) {
      const errorEl = document.getElementById('error-' + id);
      const field = contactForm.elements[id];
      if (errorEl) {
        errorEl.textContent = message;
      }
      if (field) {
        field.setAttribute('aria-invalid', 'true');
      }
    }

    function resetFormErrors() {
      contactForm.querySelectorAll('.field-error').forEach(function (el) {
        el.textContent = '';
      });
      contactForm.querySelectorAll('[aria-invalid]').forEach(function (el) {
        el.removeAttribute('aria-invalid');
      });
      formStatus.textContent = '';
      formStatus.className = 'form-status';
    }

    contactForm.addEventListener('submit', function (event) {
      event.preventDefault();
      resetFormErrors();

      const name = contactForm.elements.name;
      const email = contactForm.elements.email;
      const message = contactForm.elements.message;
      let isValid = true;

      if (!name || !name.value.trim()) {
        showFormError('name', 'Please enter your name.');
        isValid = false;
      }

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())) {
        showFormError('email', 'Please enter a valid email address.');
        isValid = false;
      }

      if (!message || !message.value.trim()) {
        showFormError('message', 'Please enter a message.');
        isValid = false;
      }

      if (!isValid) {
        const firstInvalid = contactForm.querySelector('[aria-invalid="true"]');
        if (firstInvalid) { firstInvalid.focus(); }
        return;
      }

      contactSubmit.disabled = true;
      contactSubmit.textContent = 'Sending…';

      setTimeout(function () {
        formStatus.className = 'form-status success';
        formStatus.textContent = 'Thank you! We\'ll be in touch within 1 business day.';
        contactForm.reset();
        contactSubmit.disabled = false;
        contactSubmit.innerHTML = submitDefaultHtml;
      }, 800);
    });
  }
})();

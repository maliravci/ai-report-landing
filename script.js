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
    navToggle.addEventListener('click', function () {
      navLinks.classList.toggle('open');
    });

    // Close menu when a link is clicked
    navLinks.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        navLinks.classList.remove('open');
      });
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
    var observer = new IntersectionObserver(
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
    var children = grid.querySelectorAll('.fade-in');
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
    var grid = document.querySelector('.' + cls);
    if (!grid) { return; }
    grid.querySelectorAll('.fade-in').forEach(function (card, i) {
      card.style.transitionDelay = i * 100 + 'ms';
    });
  });

  // --- FAQ accordion ---
  document.querySelectorAll('.faq-question').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var expanded = this.getAttribute('aria-expanded') === 'true';
      var answer = this.nextElementSibling;

      // Collapse all others
      document.querySelectorAll('.faq-question').forEach(function (other) {
        other.setAttribute('aria-expanded', 'false');
        var otherAnswer = other.nextElementSibling;
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
  var backToTop = document.getElementById('backToTop');

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
  var floatingCta = document.getElementById('floatingCta');
  var heroSection = document.querySelector('.hero');

  function updateFloatingCta() {
    if (!floatingCta || !heroSection) { return; }
    var heroBottom = heroSection.getBoundingClientRect().bottom;
    if (heroBottom < 0) {
      floatingCta.classList.add('visible');
      floatingCta.setAttribute('aria-hidden', 'false');
    } else {
      floatingCta.classList.remove('visible');
      floatingCta.setAttribute('aria-hidden', 'true');
    }
  }

  // --- Active nav link on scroll ---
  var navSections = Array.from(
    document.querySelectorAll('main > section[id], main > div[id]')
  );
  var navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');

  function updateActiveNav() {
    if (!navAnchors.length) { return; }
    var scrollMid = window.scrollY + window.innerHeight / 3;
    var current = '';
    navSections.forEach(function (sec) {
      if (sec.offsetTop <= scrollMid) { current = sec.id; }
    });
    navAnchors.forEach(function (a) {
      var hash = a.getAttribute('href').slice(1);
      if (hash === current) {
        a.classList.add('active');
      } else {
        a.classList.remove('active');
      }
    });
  }

  window.addEventListener('scroll', function () {
    updateBackToTop();
    updateFloatingCta();
    updateActiveNav();
  }, { passive: true });

  updateBackToTop();
  updateFloatingCta();
  updateActiveNav();
})();

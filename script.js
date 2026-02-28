/**
 * ReportDrafter — Landing Page Scripts
 *
 * Handles:
 *  - Navbar scroll effect
 *  - Mobile menu toggle
 *  - Scroll-triggered fade-in animations
 *  - Smooth scroll for anchor links
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
})();

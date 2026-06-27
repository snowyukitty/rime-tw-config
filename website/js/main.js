/* 正體輸入 Lab — interactions. Vanilla JS, no deps. */
(function () {
  'use strict';

  /* ---- sticky nav shadow ---- */
  var nav = document.getElementById('nav');
  var onScroll = function () {
    nav.classList.toggle('is-stuck', window.scrollY > 12);
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---- mobile menu ---- */
  var burger = document.getElementById('burger');
  var links = document.getElementById('navLinks');
  burger.addEventListener('click', function () {
    links.classList.toggle('open');
  });
  links.addEventListener('click', function (e) {
    if (e.target.tagName === 'A') links.classList.remove('open');
  });

  /* ---- tabs ---- */
  var tabs = document.querySelectorAll('.tab');
  tabs.forEach(function (tab) {
    tab.addEventListener('click', function () {
      var id = tab.getAttribute('data-tab');
      document.querySelectorAll('.tab').forEach(function (t) { t.classList.remove('is-active'); });
      document.querySelectorAll('.tab-panel').forEach(function (p) { p.classList.remove('is-active'); });
      tab.classList.add('is-active');
      var panel = document.getElementById(id);
      if (panel) panel.classList.add('is-active');
    });
  });

  /* ---- scroll reveal ---- */
  var revealTargets = [
    '.vcard', '.verdict-line', '.tabs', '.glyph-hero',
    '.layer', '.glyph-table-wrap', '.callout', '.kcol', '.step', '.band__inner'
  ];
  var els = [];
  revealTargets.forEach(function (sel) {
    document.querySelectorAll(sel).forEach(function (el) { els.push(el); });
  });
  els.forEach(function (el, i) {
    el.classList.add('reveal');
    el.style.transitionDelay = (Math.min(i % 6, 5) * 70) + 'ms';
  });
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('in');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    els.forEach(function (el) { io.observe(el); });
  } else {
    els.forEach(function (el) { el.classList.add('in'); });
  }

  /* ---- count-up stats ---- */
  var counters = document.querySelectorAll('.stat__num');
  var runCounter = function (el) {
    var target = parseInt(el.getAttribute('data-count'), 10) || 0;
    var suffix = el.getAttribute('data-suffix') || '';
    var dur = 1200, start = null;
    var step = function (ts) {
      if (!start) start = ts;
      var p = Math.min((ts - start) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = Math.round(target * eased) + suffix;
      if (p < 1) requestAnimationFrame(step);
      else el.textContent = target + suffix;
    };
    requestAnimationFrame(step);
  };
  if ('IntersectionObserver' in window) {
    var co = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          runCounter(entry.target);
          co.unobserve(entry.target);
        }
      });
    }, { threshold: 0.6 });
    counters.forEach(function (el) { co.observe(el); });
  } else {
    counters.forEach(function (el) {
      el.textContent = (el.getAttribute('data-count') || '0') + (el.getAttribute('data-suffix') || '');
    });
  }

  /* ---- active nav link on scroll ---- */
  var sections = ['verdict', 'compare', 'glyph', 'roadmap'].map(function (id) {
    return document.getElementById(id);
  }).filter(Boolean);
  var navAnchors = {};
  document.querySelectorAll('.nav__links a').forEach(function (a) {
    var href = a.getAttribute('href');
    if (href && href.indexOf('#') === 0) navAnchors[href.slice(1)] = a;
  });
  if ('IntersectionObserver' in window && sections.length) {
    var so = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          Object.keys(navAnchors).forEach(function (k) {
            navAnchors[k].style.color = '';
          });
          var active = navAnchors[entry.target.id];
          if (active) active.style.color = 'var(--teal)';
        }
      });
    }, { threshold: 0.4 });
    sections.forEach(function (s) { so.observe(s); });
  }
})();

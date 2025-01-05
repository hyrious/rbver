// ==UserScript==
// @name rbver
// @namespace Violentmonkey Scripts
// @match https://ruby-doc.org/*
// @match https://docs.ruby-lang.org/*
// @grant none
// ==/UserScript==
(async function () {
  const r = await fetch('https://hyrious.me/rbver/versions.json');
  const j = await r.json();
  const $ = x => document.querySelector(x);
  const $$ = x => [...document.querySelectorAll(x)];
  const klass = $('h1.class, h1.module').textContent.trim().split(/\s+/g).pop();
  const c = $$('[id^="public-class-"] > .method-detail');
  const i = $$('[id^="public-instance-"] > .method-detail');
  const append = (div, sel, text) => {
    // May use ':nth-last-child(1 of .method-heading)' if the browser is modern enough.
    const xs = div.querySelectorAll(sel);
    xs.item(xs.length - 1).after(text);
  };
  for (const div of c) {
    const name = decodeURIComponent(div.id.replace(/^method-c-|-method$/, '').split('-').map(e => {
      return /^[0-9A-F]{2}$/.test(e) ? '%' + e : e;
    }).join(''));
    const ver = j[klass] && j[klass].c && j[klass].c[name];
    if (ver) {
      const text = document.createTextNode('since ' + String(ver + 100).split('').join('.'));
      append(div, '.method-heading', text);
    }
  }
  for (const div of i) {
    const name = decodeURIComponent(div.id.replace(/^method-i-|-method$/, '').split('-').map(e => {
      return /^[0-9A-F]{2}$/.test(e) ? '%' + e : e;
    }).join(''));
    const ver = j[klass] && j[klass].i && j[klass].i[name];
    if (ver) {
      const text = document.createTextNode('since ' + String(ver + 100).split('').join('.'));
      append(div, '.method-heading', text);
    }
  }
})();

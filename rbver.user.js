// ==UserScript==
// @name rbver
// @namespace Violentmonkey Scripts
// @match https://ruby-doc.org/*
// @grant none
// ==/UserScript==
(async function(){
  const r = await fetch('https://hyrious.me/rbver/versions.json');
  const j = await r.json();
  const $ = x => document.querySelector(x);
  const $$ = x => [...document.querySelectorAll(x)];
  const klass = $('h1.class, h1.module').textContent;
  const c = $$('#public-class-method-details > .method-detail');
  const i = $$('#public-instance-method-details > .method-detail');
  for (const div of c) {
    const name = decodeURIComponent(div.id.replace(/-method$/, '').split('-').map(e => {
      return /^[0-9A-F]{2}$/.test(e) ? '%' + e : e;
    }).join(''));
    const ver = j[klass] && j[klass].c && j[klass].c[name];
    if (ver) {
      const text = document.createTextNode('since ' + String(ver + 100).split('').join('.'));
      div.querySelector('.method-heading').after(text);
    }
  }
  for (const div of i) {
    const name = decodeURIComponent(div.id.replace(/-method$/, '').split('-').map(e => {
      return /^[0-9A-F]{2}$/.test(e) ? '%' + e : e;
    }).join(''));
    const ver = j[klass] && j[klass].i && j[klass].i[name];
    if (ver) {
      const text = document.createTextNode('since ' + String(ver + 100).split('').join('.'));
      div.querySelector('.method-heading').after(text);
    }
  }
})();

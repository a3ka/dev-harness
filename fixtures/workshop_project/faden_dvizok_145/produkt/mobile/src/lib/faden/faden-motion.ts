// ЭТАЛОН-ФОРМА ПРОДУКТА батареи 145 (fixtures/.../produkt/): механический
// TS-порт оригинала faden-motion.js 1.3 — образец исполнимой формы И-1
// (ESM .ts без импортов, node type-stripping, экспорт createInstance).
// Реальный порт пишет implementer в mobile/src/lib/faden/faden-motion.ts;
// эта копия — честная основа стаб-матрицы A-оси (копируется и мутируется
// стабами: пустой компонент, тавтологические тесты, тест без вызова порта).
const __clock = { v: 0 };
const __performance = { now: () => __clock.v };
const __raf = () => 0;
function __elem() {
  return { style: { setProperty() {} }, setAttribute() {}, appendChild() {}, removeAttribute() {}, childNodes: [], innerHTML: '' };
}
const __document = { createElementNS: () => __elem(), createElement: () => __elem() };

const F = (function () {
  'use strict';
  var DEG = Math.PI / 180;
  /* Canonical Faden: thread 'M72 26A30 30 0 1 0 66 70', dot at (76,66) r=11, check 'M64 68L74 78L92 56'. */
  var CANON = { cx: 49, cy: 45.3, R: 30, sx: 0, g: 7.7, w: 95.5, dotA: 37.5, dotRho: 34, dotScale: 1, dotOpacity: 1, stroke: 12, bead: -1, check: 0, tone: 'accent' };
  var CHECK = 'M64 68L74 78L92 56', CHECK_LEN = 64;
  var STATES = ['idle', 'listening', 'understanding', 'speaking', 'working', 'waiting', 'needs_action', 'ready', 'done', 'uncertain', 'error'];
  var LABEL = { idle: 'Was möchten Sie klären?', listening: 'Ich höre zu.', understanding: 'Ich ordne Ihre Angaben ein.', speaking: 'Spricht', working: 'Ich kümmere mich darum.', waiting: 'Wir warten auf eine Rückmeldung.', needs_action: 'Ihre Rückmeldung nötig', ready: 'Bereit.', done: 'Erledigt.', uncertain: 'Der Ausgang ist noch nicht bekannt.', error: 'Keine Verbindung' };   /* D 2.2.5.1: canonical catalogue texts (ia115.voice.* / ia115.agent.* / ui.mission.group.needs_user / state.G06; speaking = PROPOSED) */
  var TONE = { idle: 'accent', listening: 'accent', understanding: 'accent', speaking: 'accent', working: 'accent', waiting: 'muted', needs_action: 'warm', ready: 'accent', done: 'accent', uncertain: 'muted', error: 'danger' };
  /* Emotional modifier: changes speed, amplitude, curvature and timing only — never the semantic colour. */
  var EMOTIONS = {
    neutral:    { speed: 1,    amp: 1,   w: 0,  symmetric: false, open: 0,    settle: 1 },
    empathetic: { speed: 0.75, amp: 0.8, w: -4, symmetric: false, open: 0,    settle: 1.25 },
    reassuring: { speed: 1,    amp: 0.8, w: 0,  symmetric: true,  open: 0,    settle: 0.8 },
    careful:    { speed: 0.7,  amp: 0.6, w: -2, symmetric: true,  open: 0,    settle: 1.2 },
    positive:   { speed: 1.1,  amp: 1,   w: 6,  symmetric: false, open: 0.02, settle: 0.75 }
  };
  /* Size tier = how much of the motion survives (AdaptiveAgentStage): full/large/medium rich, compact simplified, mini status only.
     Motion 1.2: the host may draw the figure at any px between the tiers (continuous adaptive presence); the tier only selects how much motion survives. */
  var TIERS = { tab: { amp: 0, deform: 0, drift: 0, px: 28 }, full: { amp: 1, deform: 1, drift: 1, px: 288 }, large: { amp: 1, deform: 1, drift: 1, px: 232 }, medium: { amp: 1, deform: 1, drift: 1, px: 160 }, compact: { amp: 0.6, deform: 0.5, drift: 0, px: 96 }, mini: { amp: 0.5, deform: 0, drift: 0, px: 28 } };   /* px = size-presence-* tokens */
  /* Timing table (ms). */
  var TIMING = {
    transition: 320, ease: 'cubic-bezier(0.2, 0.7, 0.2, 1)',
    listeningAttack: 80, listeningRelease: 220, listeningAmplitude: [1.0, 1.25],
    speakingAttack: 60, speakingRelease: 240, speakingAmplitude: [1.0, 1.15], speakingCurvature: 0.03,
    understandingGather: 600, needsActionHandover: 400, readySettle: 400, positiveOpen: 300,
    done: 650, doneDotTravel: 260, doneCheckDraw: 390,
    workingLoop: 2400, idleDrift: [9000, 13000], uncertainDrift: 7000, errorStop: 0,
    reducedMotion: 'no loops; static characteristic pose per state; done = final form at once',
    /* 1.3 · conversation pilot (D 2.3 tokens): */
    morph: 450, morphEase: 'cubic-bezier(0.32, 0.72, 0, 1)', pressLong: 500, primeAttack: 500,
    voiceEndpoint: 1200, voiceSilenceHint: 8000, voiceAutoPause: 30000, waveStep: 66, waveBars: 28,
    adaptiveGap: 64, adaptiveMin: 96, slotMini: 28
  };
  var VERSION = '1.3';
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
  function easeOut(t) { t = clamp(t, 0, 1); return 1 - Math.pow(1 - t, 3); }
  function easeInOut(t) { t = clamp(t, 0, 1); return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }
  function mix(a, b, t) { return a + (b - a) * t; }

  /* Target pose of a state at time `t` (ms since the state began), with the modifier, tier and live inputs applied.
     Pure: the same inputs give the same pose — what the static keyframes, the previews and the exports are rendered from. */
  function pose(state, o) {
    o = o || {};
    var t = o.t || 0, em = EMOTIONS[o.emotion] || EMOTIONS.neutral, tier = TIERS[o.size] || TIERS.large, rm = !!o.reducedMotion;
    var prime = clamp(o.prime || 0, 0, 1);   /* 1.3: anticipation while the agent button is held */
    var amp = clamp(o.amplitude == null ? (rm ? 0.5 : 0) : o.amplitude, 0, 1) * em.amp * tier.amp;
    var env = clamp(o.envelope == null ? (rm ? 0.6 : 0) : o.envelope, 0, 1) * em.amp * tier.amp;
    var d = tier.deform, drift = rm ? 0 : tier.drift, speed = em.speed;
    var p = { cx: CANON.cx, cy: CANON.cy, R: CANON.R, sx: em.open * d, g: CANON.g, w: CANON.w + em.w * d, dotA: CANON.dotA, dotRho: CANON.dotRho, dotScale: 1, dotOpacity: 1, stroke: CANON.stroke, bead: -1, check: 0, tone: TONE[state] || 'accent', label: LABEL[state] || '' };
    var k = t * speed, u;
    switch (state) {
      case 'idle':   /* present, not busy: an almost invisible change of tension — not breathing */
        p.sx += 0.012 * d * drift * Math.sin(2 * Math.PI * k / TIMING.idleDrift[0]);
        p.g += 1.2 * d * drift * Math.sin(2 * Math.PI * k / TIMING.idleDrift[1]);
        break;
      case 'listening':   /* the dot receives the signal; the arc opens slightly towards the user (down) */
        p.w += 6 * d; p.g += (em.symmetric ? 0 : 6) * d;
        p.dotScale = 1 + 0.25 * amp; p.dotRho += 3 * amp * d; p.dotA -= 4 * amp;
        break;
      case 'understanding':   /* one short gather: the arc collects, the dot approaches the thread end as if connecting */
        u = rm ? 1 : clamp(k / TIMING.understandingGather, 0, 1);
        var gather = Math.sin(Math.PI * u);           /* 0 → 1 → 0 */
        p.R = CANON.R * (1 - 0.04 * gather * d); p.w -= 6 * gather * d;
        p.dotA = mix(CANON.dotA, 50, gather); p.dotScale = 1 - 0.08 * gather;
        if (u >= 1) { p.w -= 3 * d; p.dotA = 40; }       /* holds slightly collected until the host moves on (→ working) */
        if (rm) { p.w = CANON.w - 4 * d; p.dotA = 46; p.R = CANON.R * (1 - 0.02 * d); }
        break;
      case 'speaking':   /* the Faden initiates: curvature and dot move together with the prosody envelope */
        p.w += 8 * env * d; p.R = CANON.R * (1 + TIMING.speakingCurvature * env * d);
        p.dotA -= 10 * env; p.dotScale = 1 + 0.15 * env; p.dotRho += 2 * env * d;
        break;
      case 'working':   /* a secondary bead travels the thread and back — work, not a spinner */
        if (!rm) { u = (k % TIMING.workingLoop) / TIMING.workingLoop; p.bead = easeInOut(u < 0.5 ? u * 2 : 2 - u * 2); }
        else p.bead = 0.35;
        break;
      case 'waiting':   /* work done, waiting for the insurer: almost still, muted and slightly smaller dot */
        p.dotOpacity = 0.45; p.dotScale = 0.9;
        break;
      case 'needs_action':   /* one controlled handover: the dot steps towards the gap, then rests — no pulsing */
        u = rm ? 1 : easeOut(k / TIMING.needsActionHandover);
        p.dotA = mix(CANON.dotA, 16, u); p.dotRho = mix(CANON.dotRho, 36, u) ;
        break;
      case 'ready':   /* settles into the canonical, symmetric form */
        u = rm ? 1 : easeOut(k / (TIMING.readySettle * em.settle));
        p.dotScale = mix(0.92, 1, u);
        break;
      case 'done':   /* C → the dot travels to the thread end → the line resolves → the check appears → stable */
        if (rm) { p.check = 1; p.dotOpacity = 0; p.dotA = 55.5; p.dotRho = CANON.R; break; }
        var a = easeOut(k / TIMING.doneDotTravel), c = easeOut((k - TIMING.doneDotTravel * 0.8) / TIMING.doneCheckDraw);
        p.dotA = mix(CANON.dotA, 55.5, a); p.dotRho = mix(CANON.dotRho, CANON.R, a); p.dotScale = mix(1, 0.55, a);
        p.check = c; p.dotOpacity = 1 - c;
        break;
      case 'uncertain':   /* a small controlled asymmetry, muted dot, no alarm */
        p.g += 6 * d; p.sx -= 0.04 * d; p.dotOpacity = 0.6;
        p.dotA += 2 * d * drift * Math.sin(2 * Math.PI * k / TIMING.uncertainDrift);
        break;
      case 'error':   /* movement stops, red state, stable form */
        break;
    }
    if (em.symmetric) p.g = CANON.g;
    /* 1.3 · prime (tab button held): the arc opens towards the user like listening, the dot grows — UI feedback, independent of the tier */
    if (prime > 0) { p.w += 8 * prime; p.g += 4 * prime; p.dotScale *= 1 + 0.15 * prime; p.dotRho += 2 * prime; }
    return p;
  }
  function pt(p, a, rho) { var rx = (rho == null ? p.R : rho) * (1 + p.sx), ry = (rho == null ? p.R : rho) * (1 - p.sx); return [p.cx + rx * Math.cos(a * DEG), p.cy + ry * Math.sin(a * DEG)]; }
  function r2(v) { return Math.round(v * 100) / 100; }
  /* The thread as an SVG path (elliptical arc, large-arc, counter-clockwise), from the pose. */
  function path(p) {
    var a0 = p.g - p.w / 2, a1 = p.g + p.w / 2, P0 = pt(p, a0), P1 = pt(p, a1);
    return 'M' + r2(P0[0]) + ' ' + r2(P0[1]) + 'A' + r2(p.R * (1 + p.sx)) + ' ' + r2(p.R * (1 - p.sx)) + ' 0 1 0 ' + r2(P1[0]) + ' ' + r2(P1[1]);
  }
  function dotXY(p) { var rho = p.dotRho * p.R / CANON.R; return pt({ cx: p.cx, cy: p.cy, R: rho, sx: p.sx }, p.dotA); }
  function beadXY(p) { var a0 = p.g - p.w / 2 + 360, a1 = p.g + p.w / 2; return pt(p, a1 + p.bead * (a0 - a1)); }
  /* Semantic colours = the system's tokens (ink / accent / warm / danger / ink-muted; on a card: on-card / on-card-muted / danger-on-card). */
  function colors(theme, surface) {
    if (theme === 'css') return surface === 'card'
      ? { thread: 'var(--on-card)', accent: 'var(--accent)', warm: 'var(--warm)', danger: 'var(--danger-on-card)', muted: 'var(--on-card-muted)' }
      : surface === 'voice'   /* 1.3: the mark inside the voice bar (inverse pill) */
      ? { thread: 'var(--on-voice)', accent: 'var(--accent)', warm: 'var(--warm)', danger: 'var(--danger)', muted: 'var(--on-voice-muted)' }
      : { thread: 'var(--ink)', accent: 'var(--accent)', warm: 'var(--warm)', danger: 'var(--danger)', muted: 'var(--ink-muted)' };   /* inside the design system: the tokens decide */
    if (surface === 'card') return { thread: '#121211', accent: '#d6f75a', warm: '#ff7f45', danger: '#b42318', muted: '#5b5b55' };
    return theme === 'light'
      ? { thread: '#121211', accent: '#d6f75a', warm: '#ff7f45', danger: '#b42318', muted: '#5f5e58' }
      : { thread: '#f2f1ec', accent: '#d6f75a', warm: '#ff7f45', danger: '#ff6b6b', muted: '#a6a69f' };
  }
  /* Static SVG of a pose (keyframe export, SSR fallback). */
  function svg(p, o) {
    o = o || {}; var col = colors(o.theme, o.surface), fill = col[p.tone] || col.accent, size = o.px || 96, d = dotXY(p);
    var parts = ['<path d="' + path(p) + '" fill="none" stroke="' + col.thread + '" stroke-width="' + r2(p.stroke) + '" stroke-linecap="round"/>'];
    if (p.bead >= 0) { var b = beadXY(p); parts.push('<circle cx="' + r2(b[0]) + '" cy="' + r2(b[1]) + '" r="5" fill="' + col.accent + '"/>'); }
    if (p.check > 0) parts.push('<path d="' + CHECK + '" fill="none" stroke="' + col.accent + '" stroke-width="12" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="' + CHECK_LEN + '" stroke-dashoffset="' + r2(CHECK_LEN * (1 - p.check)) + '"/>');
    if (p.dotOpacity > 0.01) parts.push('<circle cx="' + r2(d[0]) + '" cy="' + r2(d[1]) + '" r="' + r2(11 * p.dotScale) + '" fill="' + fill + '" opacity="' + r2(p.dotOpacity) + '"/>');
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="' + size + '" height="' + size + '" role="img" aria-label="Complior, ' + (o.label || p.label || '') + '">' + parts.join('') + '</svg>';
  }

  /* Live instance: smooths the current pose towards the target pose, runs one-shot sequences and loops, honours reduced motion. */
  function mount(el, o) {
    o = Object.assign({ state: 'idle', emotion: 'neutral', size: 'large', theme: 'dark', surface: 'ground', reducedMotion: false, amplitude: 0, envelope: 0, autoplay: true }, o || {});
    var NS = 'http://www.w3.org/2000/svg', root = __document.createElementNS(NS, 'svg');
    root.setAttribute('viewBox', '0 0 96 96'); root.setAttribute('role', 'img'); root.setAttribute('focusable', 'false');
    var thread = __document.createElementNS(NS, 'path'), bead = __document.createElementNS(NS, 'circle'), check = __document.createElementNS(NS, 'path'), dot = __document.createElementNS(NS, 'circle');
    thread.setAttribute('fill', 'none'); thread.setAttribute('stroke-linecap', 'round');
    check.setAttribute('d', CHECK); check.setAttribute('fill', 'none'); check.setAttribute('stroke-width', '12'); check.setAttribute('stroke-linecap', 'round'); check.setAttribute('stroke-linejoin', 'round'); check.setAttribute('stroke-dasharray', String(CHECK_LEN));
    bead.setAttribute('r', '5');
    root.appendChild(thread); root.appendChild(bead); root.appendChild(check); root.appendChild(dot);
    el.innerHTML = ''; el.appendChild(root);
    var cur = Object.assign({}, CANON, { label: '' }), started = __performance.now(), last = started, raf = null, smoothAmp = 0, smoothEnv = 0, smoothPrime = 0, inst;
    var NUM = ['R', 'sx', 'g', 'w', 'dotA', 'dotRho', 'dotScale', 'dotOpacity', 'stroke', 'check'];
    function render(p) {
      var col = colors(o.theme, o.surface), d = dotXY(p), px = TIERS[o.size] ? TIERS[o.size].px : 160;
      root.setAttribute('width', px); root.setAttribute('height', px); root.setAttribute('aria-label', 'Complior, ' + (p.label || LABEL[o.state] || ''));
      thread.setAttribute('d', path(p)); thread.style.stroke = col.thread; thread.setAttribute('stroke-width', r2(p.stroke));
      dot.setAttribute('cx', r2(d[0])); dot.setAttribute('cy', r2(d[1])); dot.setAttribute('r', r2(11 * p.dotScale)); dot.style.fill = col[p.tone] || col.accent; dot.setAttribute('opacity', r2(p.dotOpacity));
      if (p.bead >= 0) { var b = beadXY(p); bead.setAttribute('cx', r2(b[0])); bead.setAttribute('cy', r2(b[1])); bead.style.fill = col.accent; bead.setAttribute('opacity', '1'); } else bead.setAttribute('opacity', '0');
      check.style.stroke = col.accent; check.setAttribute('stroke-dashoffset', r2(CHECK_LEN * (1 - p.check))); check.setAttribute('opacity', p.check > 0 ? '1' : '0');
    }
    function step(now) {
      var dt = Math.min(64, now - last); last = now;
      var em = EMOTIONS[o.emotion] || EMOTIONS.neutral;
      /* input smoothing: attack / release (listening dot, speaking envelope) */
      var ta = o.state === 'speaking' ? TIMING.speakingAttack : TIMING.listeningAttack, tr = o.state === 'speaking' ? TIMING.speakingRelease : TIMING.listeningRelease;
      var kA = 1 - Math.exp(-dt / ta), kR = 1 - Math.exp(-dt / tr);
      smoothAmp += (o.amplitude - smoothAmp) * (o.amplitude > smoothAmp ? kA : kR);
      smoothEnv += (o.envelope - smoothEnv) * (o.envelope > smoothEnv ? kA : kR);
      /* 1.3: prime follows the host value with primeAttack (no jump when the press starts / ends) */
      var kP = o.reducedMotion ? 1 : 1 - Math.exp(-dt / (TIMING.primeAttack / 3)); smoothPrime += ((o.prime || 0) - smoothPrime) * kP;
      var target = pose(o.state, { t: now - started, emotion: o.emotion, size: o.size, reducedMotion: o.reducedMotion, amplitude: o.size === 'tab' ? 0 : smoothAmp, envelope: o.size === 'tab' ? 0 : smoothEnv, prime: smoothPrime });
      /* pose smoothing: the structural parameters ease with the transition time (× emotion speed), the live ones follow at once */
      var tau = o.reducedMotion ? 1 : (TIMING.transition / 3) / em.speed, kS = 1 - Math.exp(-dt / tau);
      NUM.forEach(function (key) {
        var live = (o.state === 'listening' || o.state === 'speaking') && (key === 'dotScale' || key === 'dotA' || key === 'dotRho' || key === 'w' || key === 'R');
        var kk = live ? Math.min(1, kS * 2.2) : kS;
        if (o.state === 'done' || o.state === 'understanding' || o.state === 'needs_action' || o.state === 'ready') kk = Math.min(1, kS * 1.6);
        cur[key] = o.reducedMotion ? target[key] : cur[key] + (target[key] - cur[key]) * kk;
      });
      cur.bead = target.bead; cur.tone = target.tone; cur.label = target.label; cur.cx = target.cx; cur.cy = target.cy;
      render(cur);
      if (o.autoplay) raf = __raf(step);
    }
    inst = {
      el: root,
      /* host API: set({ state, emotion, size, theme, surface, amplitude, envelope, reducedMotion, prime }) — 1.3: prime 0–1 (agent button held), size 'tab' */
      set: function (patch) {
        var restart = patch.state !== undefined && patch.state !== o.state;
        Object.assign(o, patch);
        if (restart) started = __performance.now();
        if (!o.autoplay) step(__performance.now());
      },
      /* deterministic rendering for exports / tests: advance the clock by dt ms */
      tick: function (dt) { last = last + 0; var now = last + dt; step(now); return cur; },
      reset: function (ms) { started = __performance.now() - (ms || 0); last = started; cur = Object.assign({}, CANON, { label: '' }); smoothAmp = 0; smoothEnv = 0; smoothPrime = 0; },
      pose: function () { return Object.assign({}, cur); },
      options: function () { return Object.assign({}, o); },
      destroy: function () { if (raf) __raf(raf); raf = null; el.innerHTML = ''; }
    };
    if (o.autoplay) raf = __raf(step); else render(cur);
    return inst;
  }

  /* ---------------- 1.3 · conversation pilot: pure functions (deterministic; the app ports them 1:1) ---------------- */
  /* cubic-bezier(x1, y1, x2, y2) → f(x) (Newton + bisection; same solver as the motion lab) */
  function bezier(x1, y1, x2, y2) {
    function A(a, b) { return 1 - 3 * b + 3 * a; } function B(a, b) { return 3 * b - 6 * a; } function C(a) { return 3 * a; }
    function calc(t, a, b) { return ((A(a, b) * t + B(a, b)) * t + C(a)) * t; } function slope(t, a, b) { return 3 * A(a, b) * t * t + 2 * B(a, b) * t + C(a); }
    return function (x) {
      if (x <= 0) return 0; if (x >= 1) return 1;
      var t = x; for (var i = 0; i < 8; i++) { var s = slope(t, x1, x2); if (Math.abs(s) < 1e-6) break; t -= (calc(t, x1, x2) - x) / s; }
      if (t < 0 || t > 1 || Math.abs(calc(t, x1, x2) - x) > 1e-4) { var lo = 0, hi = 1; t = x; for (var j = 0; j < 30; j++) { var v = calc(t, x1, x2); if (Math.abs(v - x) < 1e-6) break; if (v < x) lo = t; else hi = t; t = (lo + hi) / 2; } }
      return calc(t, y1, y2);
    };
  }
  var EASE_MORPH = bezier(0.32, 0.72, 0, 1);
  /* the tier a figure size belongs to (how much motion survives); `docked` = in the top bar */
  function tierFor(s, docked) { return docked || s < 60 ? 'mini' : s >= 240 ? 'full' : s >= 200 ? 'large' : s >= 120 ? 'medium' : 'compact'; }
  /* morph(from, to, t, o): the figure box ({x, y, s}: top-left and side in px) between two rects — button → stage, stage → top bar,
     stage → button. t ms since the trigger; o.duration (motion-morph 450) · o.delay · o.reducedMotion (→ the end box at once).
     Interrupted mid-way: start a new morph from the returned box (the host keeps the last box). */
  function morph(from, to, t, o) {
    o = o || {};
    var dur = o.duration == null ? TIMING.morph : o.duration, u = o.reducedMotion || dur <= 0 ? 1 : clamp((t - (o.delay || 0)) / dur, 0, 1), k = EASE_MORPH(u);
    var box = { x: mix(from.x, to.x, k), y: mix(from.y, to.y, k), s: mix(from.s, to.s, k), u: u, k: k };
    box.tier = tierFor(box.s, o.docked);
    return box;
  }
  /* adaptive(o): the adaptive conversation rule (D 2.2.6) as a pure function. H screen height, T top bar (+ safe area), A actions panel
     (composer / voice bar / CTA + keyboard + safe area), C content of the work area (thread, cards), cap = largest size the moment allows
     (voice: 288 Vollbild · 232 first reply · 160 facts; text: 96), docked = the host says work has begun. Returns the presence height P,
     the figure size S and whether the presence lives in the top bar. Keyboard open → A grows → P shrinks → docks: one rule, no extra animation.
     o.fit (1.3, conversation inside the chat): the stage takes only what the figure needs (S + gap) and gives the rest (`rest`) back to
     the thread above the current turn — the chat stays visible; without fit the stage fills P (conversation layer «über dem Chat»). */
  function adaptive(o) {
    var gap = o.gap == null ? TIMING.adaptiveGap : o.gap, min = o.min == null ? TIMING.adaptiveMin : o.min;
    var Pfree = Math.max(0, (o.H || 844) - (o.T || 60) - (o.A || 0) - (o.C || 0));
    var docked = !!o.docked || (Pfree - gap < min);
    var S = docked ? TIMING.slotMini : Math.max(min, Math.min(o.cap == null ? 288 : o.cap, Pfree - gap));
    var P = docked ? 0 : (o.fit ? Math.min(Pfree, S + gap) : Pfree);
    return { Pfree: Pfree, P: P, S: S, rest: Pfree - P, docked: docked, tier: tierFor(S, docked) };
  }
  /* voiceBars(samples, o): the bars of the voice bar — the USER's voice (the mark shows the AGENT). samples: microphone amplitude 0–1 at
     60 Hz, oldest first. One bar per waveStep (66 ms = 4 frames): the newest bar on the right, older bars scroll left. Bar = max of its
     window, lifted (^0.8) so quiet speech still shows; silence = 0 (the bar draws its 4 px floor). o.n (28), o.step (frames per bar, 4). */
  function voiceBars(samples, o) {
    o = o || {}; var n = o.n || TIMING.waveBars, step = o.step || Math.round(TIMING.waveStep / (1000 / 60)), out = [], len = samples.length;
    for (var j = 0; j < n; j++) {
      var end = len - (n - 1 - j) * step, start = end - step, m = 0;
      for (var i = Math.max(0, start); i < end; i++) if (i >= 0 && samples[i] > m) m = samples[i];
      out.push(end <= 0 ? 0 : Math.round(Math.pow(clamp(m, 0, 1), 0.8) * 1000) / 1000);
    }
    return out;
  }
  return {  VERSION: VERSION, STATES: STATES, EMOTIONS: EMOTIONS, TIERS: TIERS, TIMING: TIMING, CANON: CANON, LABEL: LABEL, TONE: TONE, pose: pose, path: path, svg: svg, mount: mount, colors: colors, dotXY: dotXY, CHECK: CHECK,
    morph: morph, adaptive: adaptive, voiceBars: voiceBars, tierFor: tierFor, bezier: bezier  };
})();

export const CompliorFaden = F;
export const VERSION = F.VERSION;
export const STATES = F.STATES;
export const EMOTIONS = F.EMOTIONS;
export const TIERS = F.TIERS;
export const TIMING = F.TIMING;
export const CANON = F.CANON;
export const LABEL = F.LABEL;
export const TONE = F.TONE;
export const CHECK = F.CHECK;
export const pose = F.pose;
export const path = F.path;
export const svg = F.svg;
export const colors = F.colors;
export const dotXY = F.dotXY;
export const morph = F.morph;
export const adaptive = F.adaptive;
export const voiceBars = F.voiceBars;
export const tierFor = F.tierFor;
export const bezier = F.bezier;

export interface FadenInstance {
  set(patch: Record<string, unknown>): void;
  advanceTime(dtMs: number): void;
  tick(dtMs: number): unknown;
  pose(): Record<string, unknown>;
  reset(ms?: number): void;
  options(): Record<string, unknown>;
}

export function createInstance(o: Record<string, unknown> = {}): FadenInstance {
  __clock.v = 0;
  const el = __elem();
  const inst = F.mount(el, Object.assign({ autoplay: false }, o));
  return {
    set: (p) => inst.set(p),
    advanceTime: (dt) => { __clock.v += dt; },
    tick: (dt) => inst.tick(dt),
    pose: () => inst.pose(),
    reset: (ms) => inst.reset(ms),
    options: () => inst.options(),
  };
}

// Токены движения D 2.4 «Gespräch · финал 2» — единый источник чисел UI-движения.
// Значения — побайтово из docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json
// пакета Complior-D24-Gespraech-Final2 (оракул закреплён sha256 в source.json
// батареи 145; второй набор вручную изобретённых имён запрещён — STRUCTURE.md §6).
// Модуль — данные без импортов и без вычислений: исполним чистым node
// (type-stripping) и потребляется компонентами продукта напрямую.
export const MOTION_TOKENS: Record<string, string> = {
  "motion-fast": "150ms",
  "motion-base": "250ms",
  "motion-slow": "400ms",
  "ease-standard": "cubic-bezier(0.2, 0.7, 0.2, 1)",
  "motion-cycle": "2400ms",
  "motion-none": "0ms",
  "motion-stagger": "60ms",
  "faden-transition": "320ms",
  "faden-listen-attack": "80ms",
  "faden-listen-release": "220ms",
  "faden-speak-attack": "60ms",
  "faden-speak-release": "240ms",
  "faden-gather": "600ms",
  "faden-handover": "400ms",
  "faden-settle": "400ms",
  "faden-done-dot": "260ms",
  "faden-done-check": "390ms",
  "faden-done": "650ms",
  "faden-idle-drift-a": "9000ms",
  "faden-idle-drift-b": "13000ms",
  "faden-uncertain-drift": "7000ms",
  "ease-faden-out": "cubic-bezier(0.33, 1, 0.68, 1)",
  "ease-faden-loop": "cubic-bezier(0.65, 0, 0.35, 1)",
  "motion-morph": "450ms",
  "ease-morph": "cubic-bezier(0.32, 0.72, 0, 1)",
  "press-long": "500ms",
  "voice-endpoint": "1200ms",
  "voice-silence-hint": "8000ms",
  "voice-autopause": "30000ms",
  "wave-step": "66ms",
  "motion-stagger-tight": "30ms",
};

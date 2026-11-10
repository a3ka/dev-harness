#!/usr/bin/env node
// Контракт 143 (mob-ci-razdelenie): fail-closed агрегат required-проверки
// android-e2e. Единственный вход — toJSON(needs) workflow (результаты И
// outputs каждой задачи: selection, digest каждой экранной задачи, identity
// сборки) плюс env идентичности прогона. Зелёный rc 0 ТОЛЬКО при ОДНОВРЕМЕННО:
//   selector success ∧ quality success ∧ build success ∧ selection валидна ∧
//   |selected| > 0 ∧ selected ⊆ зарегистрированных worker-задач ∧
//   каждая selected — success ∧ исполненные экранные задачи = ожидаемой
//   выборке (лишняя зелёная задача без записи в selection — отказ) ∧
//   невыбранная — ровно skipped с объявленной причиной исключения ∧
//   digest APK каждой выбранной задачи = digest сборки ∧ run-identity тот же.
// Любое иное состояние — rc 1 с ИМЕНОВАННОЙ причиной; пустой needs/JSON не
// принимается как «все пустое — все молодцы» (all([]) != true).
"use strict";
const fs = require("fs");

function otkaz(imya, detal) {
  process.stdout.write(`AGREGAT_OTKAZ: ${imya}${detal ? " — " + detal : ""}\n`);
  process.exit(1);
}

const args = process.argv.slice(2);
let needsF = null;
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--needs") { needsF = args[i + 1]; i++; }
}
if (!needsF) otkaz("NET_VHODA", "нужен --needs <toJSON(needs)>");
let needs;
try { needs = JSON.parse(fs.readFileSync(needsF, "utf8")); }
catch (e) { otkaz("NEEDS_NE_JSON", String(e.message || e)); }
if (!needs || typeof needs !== "object" || Array.isArray(needs) || Object.keys(needs).length === 0) {
  otkaz("PUSTOJ_NEEDS", "пустой needs не является всеобщим успехом");
}

// служебные задачи агрегата
const SLUZHEBNYE = ["select-screens", "quality", "build-apk"];
for (const j of SLUZHEBNYE) {
  const r = needs[j] && needs[j].result;
  if (r !== "success") otkaz("SLUZHEBNAYA_NE_ZELENA", `${j}=${r || "отсутствует"}`);
}
const selectorOut = (needs["select-screens"].outputs && needs["select-screens"].outputs.selection) || null;
let sel = null;
if (selectorOut) {
  try { sel = JSON.parse(selectorOut); }
  catch (e) { otkaz("SELECTION_NE_JSON", String(e.message || e)); }
}

// реестр экранных задач = needs минус служебные минус сам агрегат
const rabotniki = Object.keys(needs).filter((j) => !SLUZHEBNYE.includes(j) && j !== "android-e2e" && j !== "mobile-regression-signal");

if (!sel) otkaz("SELECTION_OTSUTSTVUET", "select-screens не опубликовал selection");
// v3: the same required entrypoint checks every matrix child, not just the parent job.
if (Object.prototype.hasOwnProperty.call(sel, "matrix")) {
  const path = require("path");
  const evidenceArg = args.indexOf("--evidence");
  if (evidenceArg < 0 || !args[evidenceArg + 1]) otkaz("CHILD_EVIDENCE_OTKAZ", "NET_VHODA");
  const evidence = args[evidenceArg + 1];
  const matrixOutput = needs["select-screens"].outputs?.matrix;
  if ((matrixOutput === undefined ? "" : matrixOutput) !== sel.matrix) otkaz("MATRIX_NE_SELECTION");
  if (!Array.isArray(sel.selected) || !Array.isArray(sel.excluded) || !sel.selected.length) otkaz("PUSTOJ_NABOR");
  const legacy = ["e2e-splash", "e2e-first-run", "e2e-erstinformation", "e2e-start", "e2e-pilot"];
  const build = needs["build-apk"].outputs || {};
  const attempt = process.env.GITHUB_RUN_ATTEMPT;
  if (!attempt || !build.apk_sha256 || !build.artifact_name || !build.run_id) otkaz("CHILD_EVIDENCE_OTKAZ", "NET_IDENTICHNOSTI");
  for (const name of legacy) {
    const job = needs[name];
    if (!job) otkaz("LEGACY_NEEDS_OTSUTSTVUET", name);
    const chosen = sel.selected.some((e) => e.job === name);
    if (chosen) {
      if (job.result !== "success" || job.outputs?.apk_sha256 !== build.apk_sha256 ||
          job.outputs?.artifact_name !== build.artifact_name || job.outputs?.run_id !== build.run_id) otkaz("LEGACY_OTKAZ", name);
    } else if (job.result !== "skipped" || !sel.excluded.some((e) => e.job === name && e.reason)) otkaz("LEGACY_SKIP_OTKAZ", name);
  }
  let matrix;
  try { matrix = sel.matrix === "" ? {include: []} : JSON.parse(sel.matrix); }
  catch (e) { otkaz("MATRIX_NE_JSON", e.message); }
  const chosen = sel.selected.filter((e) => e.job === "e2e-screen").map((e) => e.id);
  const fromMatrix = matrix.include?.map((e) => e.screen.id);
  if (!Array.isArray(fromMatrix) || new Set(chosen).size !== chosen.length ||
      JSON.stringify(chosen.slice().sort()) !== JSON.stringify(fromMatrix.slice().sort())) otkaz("MATRIX_NE_SELECTION");
  if (needs["e2e-screen"]?.result !== (chosen.length ? "success" : "skipped")) otkaz("MATRIX_PARENT_OTKAZ");
  const expected = new Set(chosen.map((id) => `screen-evidence-${id}-${build.run_id}-${attempt}`));
  let actual;
  try { actual = fs.readdirSync(evidence); }
  catch (e) { otkaz("CHILD_EVIDENCE_OTKAZ", e.message); }
  if (expected.size !== actual.length || actual.some((name) => !expected.has(name))) otkaz("CHILD_EVIDENCE_OTKAZ", "PEREPIS_DETEJ");
  for (const id of chosen) {
    try {
      const proof = JSON.parse(fs.readFileSync(path.join(evidence, `screen-evidence-${id}-${build.run_id}-${attempt}`, "result.json"), "utf8"));
      if (proof.screen_id !== id || proof.status !== "success" || proof.apk_sha256 !== build.apk_sha256 ||
          proof.artifact_name !== build.artifact_name || proof.run_id !== build.run_id ||
          proof.run_attempt !== attempt) otkaz("CHILD_EVIDENCE_OTKAZ", "CHUZHOJ_REZULTAT_" + id);
    } catch (e) { otkaz("CHILD_EVIDENCE_OTKAZ", "NET_DOKAZATELSTVA_" + id); }
  }
  process.stdout.write("CHILD_EVIDENCE_OK\n");
  process.exit(0);
}
if (!Array.isArray(sel.selected) || !Array.isArray(sel.excluded)) otkaz("SELECTION_NE_VALIDNA", "нет selected/excluded");
if (sel.selected.length === 0) otkaz("PUSTOJ_NABOR", "пустой selected при success selector — не принимается");
const vybrannyeJoby = new Set();
for (const s of sel.selected) {
  if (!s || !s.job || !s.reason) otkaz("SELECTION_NE_VALIDNA", "запись без job/reason");
  vybrannyeJoby.add(s.job);
}
for (const j of vybrannyeJoby) {
  if (!rabotniki.includes(j)) otkaz("VNE_REESTRA", `${j} нет среди зарегистрированных задач`);
}

// каждая выбранная — ровно success; digest/identity — от той же сборки
const buildOut = (needs["build-apk"].outputs && needs["build-apk"].outputs) || {};
const apkSha = buildOut.apk_sha256 || null;
const artefakt = buildOut.artifact_name || null;
const runId = buildOut.run_id || null;
if (!apkSha || !artefakt || !runId) otkaz("SBORKA_BEZ_IDENTICHNOSTI", "нет apk_sha256/artifact_name/run_id");
for (const j of vybrannyeJoby) {
  const r = needs[j] && needs[j].result;
  if (r !== "success") otkaz("VYBRANNAYA_NE_USPEH", `${j}=${r || "отсутствует"}`);
  const o = (needs[j] && needs[j].outputs) || {};
  if (o.apk_sha256 !== apkSha) otkaz("APK_DIGEST_RASKHOZHDENIE", `${j}: ${o.apk_sha256 || "нет"} ≠ ${apkSha}`);
  if (o.artifact_name !== artefakt) otkaz("CHUZHOJ_ARTEFAKT", `${j}: ${o.artifact_name || "нет"} ≠ ${artefakt}`);
  if (o.run_id !== runId) otkaz("STARYJ_ARTEFAKT", `${j}: run ${o.run_id || "нет"} ≠ ${runId}`);
}

// исполненные экранные задачи = выборке; невыбранные — ровно skipped с причиной
const iskljuchennye = new Map((sel.excluded || []).map((e) => [e.job, e.reason || ""]));
for (const j of rabotniki) {
  const r = needs[j] && needs[j].result;
  if (vybrannyeJoby.has(j)) continue;
  if (r === "success") otkaz("LISHNIJ_RABOTNIK", `${j} исполнен успехом, но не в selection`);
  if (r !== "skipped") otkaz("NE_VYBRAN_NE_SKIP", `${j}=${r}`);
  if (!iskljuchennye.has(j)) otkaz("SKIP_BEZ_PRICHINY", `${j} пропущен без записи в excluded`);
}

process.stdout.write(`AGREGAT_OK: selected=${[...vybrannyeJoby].sort().join(",")} digest=${apkSha.slice(0, 12)}…\n`);

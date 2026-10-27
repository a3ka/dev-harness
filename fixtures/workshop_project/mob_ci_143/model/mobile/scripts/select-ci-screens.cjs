#!/usr/bin/env node
// Контракт 143 (mob-ci-razdelenie): селектор затронутых экранов.
// Единственный источник карты — mobile/ci-screens.json (схема 1).
// Режимы: pull_request / push (diff base...head), merge_group (диапазон
// группы), schedule / dispatch (полный набор без diff).
// Diff: СНАЧАЛА git (merge-base, --name-status -z -M, NUL-safe: обе стороны
// rename, delete, type-change); при недоступности git/base — gh api
// pulls/N/files с постраничным чтением и сверкой полноты по changed_files
// (fail-closed на усечение). Ошибка получения входа — rc 1 с именем,
// НИКОГДА selected=[] с success.
// Выбор: development(base ∪ head) ∪ affected(diff, map_base ∪ map_head);
// сужение карты/снятие статуса/удаление записи самим PR — POLICY_CHANGE →
// полный набор union-карты; общий слой → полный набор (COMMON_CHANGE);
// пустой первичный результат → EMPTY_SELECTION_FALLBACK (полный набор,
// rc 0, причина в selection.json); пустой/недоступный реестр — rc 1.
// Структурная инвентаризация: новый pack (mobile/e2e-*/), новый флоу
// (mobile/.maestro/*.yaml) или новый маршрут (mobile/src/app/**), не
// зарегистрированные в карте, — rc 1 INVENTAR_KARTY (не тихое исключение).
// Прочий неизвестный продуктовый путь — полный набор + именованная заметка
// UNKNOWN_PATH (rc 0): ошибка карты видна, но прогон не сужается.
"use strict";
const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

function fail(name, detail) {
  process.stderr.write(`VYBOR_OTKAZ: ${name}${detail ? ": " + detail : ""}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const a = { mode: null, base: null, head: null, pr: null, out: null, repo: "." };
  for (let i = 0; i < argv.length; i++) {
    const k = argv[i];
    const v = argv[i + 1];
    if (k === "--mode") { a.mode = v; i++; }
    else if (k === "--base-sha") { a.base = v; i++; }
    else if (k === "--head-sha") { a.head = v; i++; }
    else if (k === "--pr") { a.pr = v; i++; }
    else if (k === "--out") { a.out = v; i++; }
    else if (k === "--repo") { a.repo = v; i++; }
    else fail("NEIZVESTNYJ_ARGUMENT", k);
  }
  if (!["pull_request", "push", "merge_group", "schedule", "dispatch"].includes(a.mode)) {
    fail("REZHIM", `mode=${a.mode}`);
  }
  if (!a.out) a.out = "selection.json";
  return a;
}

const args = parseArgs(process.argv.slice(2));
const MAP_REL = "mobile/ci-screens.json";

function razberiKartu(raw, label) {
  let m;
  try { m = JSON.parse(raw); }
  catch (e) { return { oshibka: "KARTA_NE_JSON", label }; }
  if (m.schema !== 1) return { oshibka: "SKHEMA_KARTY", label, schema: m.schema };
  const ekranov = Array.isArray(m.ekrany) ? m.ekrany : [];
  const integ = m.integracija || null;
  const zapisi = ekranov.map((e) => ({
    id: e.id, job: e.job, status: e.status, puti: e.puti || [],
    pack: e.pack || null, flows: e.flows || [], integration: false,
  }));
  if (integ) zapisi.push({
    id: integ.id, job: integ.job, status: integ.status, puti: integ.puti || [],
    pack: null, flows: integ.fiksirovannyj_nabor || [], integration: true,
  });
  for (const z of zapisi) {
    if (!z.id || !z.job) return { oshibka: "SKHEMA_KARTY", label };
    if (!["approved", "in-development"].includes(z.status)) {
      return { oshibka: "SKHEMA_KARTY", label, status: z.status };
    }
  }
  if (zapisi.length === 0) return { oshibka: "PUSTOJ_REESTR", label };
  return { zapisi, shared: (m.shared && m.shared.puti) || [], sha: crypto.createHash("sha256").update(raw, "utf8").digest("hex") };
}

function readMap(fromDir, label) {
  let raw;
  try { raw = fs.readFileSync(path.join(fromDir, MAP_REL), "utf8"); }
  catch (e) { return { oshibka: label === "head" ? "KARTA_OTSUTSTVUET" : null, net: true }; }
  return razberiKartu(raw, label);
}

// карта head обязательна; карта base — из git (show <base>:карта), отсутствие
// = карта молода (политика от нуля), иная ошибка чтения/разбора — именованный отказ
const headMap = readMap(args.repo, "head");
if (headMap.oshibka) fail(headMap.oshibka, `map head: ${headMap.label || ""} ${headMap.status || ""}`);
let baseMap = { zapisi: [], shared: [], sha: null };
let baseEst = false;
if (args.mode !== "schedule" && args.mode !== "dispatch") {
  let baseRaw = null;
  try {
    baseRaw = execFileSync("git", ["-C", args.repo, "show", `${args.base}:${MAP_REL}`], { stdio: ["ignore", "pipe", "pipe"], maxBuffer: 16 * 1024 * 1024 }).toString("utf8");
  } catch (e) { /* карты на base нет — политика от нуля */ }
  if (baseRaw !== null) {
    const bm = razberiKartu(baseRaw, "base");
    if (bm.oshibka) fail(bm.oshibka, `map base${bm.status ? " status=" + bm.status : ""}`);
    baseMap = bm;
    baseEst = true;
  }
}

function gitDiffZ(base, head) {
  // merge-base; -z NUL-safe; -M rename detection; --name-status даёт
  // A/C/D/R/T со старым и новым именем (R/C: старое новое до статуса).
  let mb;
  try {
    mb = execFileSync("git", ["-C", args.repo, "merge-base", base, head], { stdio: ["ignore", "pipe", "pipe"] }).toString().trim();
  } catch (e) { return { net: true, prichina: "NET_BAZY" }; }
  try {
    const out = execFileSync("git", ["-C", args.repo, "diff", "--name-status", "-z", "-M", `${mb}...${head}`], { maxBuffer: 64 * 1024 * 1024 });
    return { z: out };
  } catch (e) { return { net: true, prichina: "OSIBKA_DIFFA" }; }
}

function parseZ(buf) {
  // -z поток: записи NUL-разделены; R/C несут СТАТУС\0OLD\0NEW
  const parts = buf.toString("utf8").split("\0");
  const zapisi = [];
  let i = 0;
  while (i < parts.length) {
    if (parts[i] === "") { i++; continue; }
    const st = parts[i];
    if (st.startsWith("R") || st.startsWith("C")) {
      zapisi.push({ status: st[0], old: parts[i + 1], nov: parts[i + 2] });
      i += 3;
    } else {
      zapisi.push({ status: st[0], old: parts[i + 1], nov: parts[i + 1] });
      i += 2;
    }
  }
  return zapisi;
}

function apiFiles(pr) {
  // gh api постранично; полнота по changed_files (вкл. документированный
  // потолок 3000 — усечение недоказуемо полным ⇒ USECHENIE_API)
  let pull;
  try {
    pull = JSON.parse(execFileSync("gh", ["api", `repos/${process.env.GITHUB_REPOSITORY || "o/r"}/pulls/${pr}`]).toString());
  } catch (e) { return { net: true, prichina: "NET_BAZY" }; }
  const vsego = typeof pull.changed_files === "number" ? pull.changed_files : null;
  const polucheno = [];
  for (let page = 1; page <= 50; page++) {
    let str;
    try { str = execFileSync("gh", ["api", `repos/${process.env.GITHUB_REPOSITORY || "o/r"}/pulls/${pr}/files?per_page=100&page=${page}`]).toString(); }
    catch (e) { return { net: true, prichina: "OSIBKA_DIFFA" }; }
    const chunk = JSON.parse(str);
    if (!Array.isArray(chunk)) return { net: true, prichina: "OSIBKA_DIFFA" };
    for (const f of chunk) {
      const st = f.status === "renamed" || f.status === "copied" ? "R" :
        f.status === "added" ? "A" : f.status === "removed" ? "D" :
        f.status === "changed" ? "T" : "M";
      polucheno.push({ status: st, old: f.previous_filename || f.filename, nov: f.filename });
    }
    if (chunk.length < 100) break;
  }
  if (vsego !== null && (polucheno.length !== vsego || vsego >= 3000)) {
    return { net: true, prichina: "USECHENIE_API", polucheno: polucheno.length, vsego };
  }
  return { zapisi: polucheno };
}

let diffZapisi = null;
let diffIstochnik = null;
let diffOshibka = null;
if (args.mode === "schedule" || args.mode === "dispatch") {
  diffZapisi = [];
  diffIstochnik = "none";
} else {
  const g = gitDiffZ(args.base, args.head);
  if (!g.net) { diffZapisi = parseZ(g.z); diffIstochnik = "git"; }
  else {
    diffOshibka = g.prichina;
    if (args.mode === "pull_request" && args.pr) {
      const api = apiFiles(args.pr);
      if (!api.net) { diffZapisi = api.zapisi; diffIstochnik = "gh-api"; diffOshibka = null; }
      else { fail(api.prichina, `api: polucheno=${api.polucheno ?? "?"} vsego=${api.vsego ?? "?"}; git: ${diffOshibka}`); }
    } else fail(g.prichina, "git");
  }
}

// --- карта union и изменение политики --------------------------------------
function kartaPodpis(map) {
  return JSON.stringify(map.zapisi.map((z) => [z.id, z.job, z.status, z.puti, z.pack, z.flows])) + "|" + JSON.stringify(map.shared);
}
const unionZapisi = [];
const poId = new Map();
for (const src of [baseMap, headMap]) {
  for (const z of src.zapisi) {
    if (!poId.has(z.id)) { poId.set(z.id, { ...z }); unionZapisi.push(poId.get(z.id)); }
    else {
      const b = poId.get(z.id);
      // union путей base ∪ head: сужение не исключает экран из проверки PR
      b.puti = Array.from(new Set([...b.puti, ...z.puti]));
      b.flows = Array.from(new Set([...b.flows, ...z.flows]));
      if (b.pack !== z.pack) b.pack = b.pack || z.pack;
      if (b.status !== z.status) b.status = "in-development";
    }
  }
}
const unionShared = Array.from(new Set([...baseMap.shared, ...headMap.shared]));
// сужение политики — только если карта на base СУЩЕСТВОВАЛА: первое
// появление карты не является сужением (политика от нуля)
const policyChange = baseEst && kartaPodpis(baseMap) !== kartaPodpis(headMap);

// ночь/предрелиз — полный набор без diff
const rezhimPolnyj = args.mode === "schedule" || args.mode === "dispatch";

// --- сопоставление путей ----------------------------------------------------
function pokryvaet(prefiks, p) {
  if (!prefiks) return false;
  if (prefiks.endsWith("/")) return p === prefiks.slice(0, -1) || p.startsWith(prefiks);
  return p === prefiks || p.startsWith(prefiks + "/");
}
function vladelec(p) {
  const vl = [];
  for (const z of unionZapisi) {
    const korni = [...z.puti, ...(z.pack ? [z.pack] : []), ...z.flows];
    if (korni.some((k) => pokryvaet(k, p))) vl.push(z.id);
  }
  return vl;
}
function obshchij(p) { return unionShared.some((k) => pokryvaet(k, p)); }

const STRUKTURA_RE = [/^mobile\/e2e-[^/]+\//, /^mobile\/\.maestro\/[^/]+\.yaml$/, /^mobile\/src\/app\//];
const VNUTRI_PRODUKTA = /^(mobile\/|\.github\/workflows\/mobile\.yml$)/;

const selected = new Map();
const notes = [];
let fullSet = policyChange || rezhimPolnyj;
let policyPrichina = policyChange ? ["POLICY_CHANGE"] : (rezhimPolnyj ? ["FULL_SET_REZHIM"] : []);
if (policyChange) notes.push("POLICY_CHANGE: карта base ≠ карта head — полный набор union-карты");
if (rezhimPolnyj) notes.push("FULL_SET_REZHIM: schedule/dispatch — полный набор approved");

for (const z of unionZapisi) {
  if (z.status === "in-development") selected.set(z.id, "DEVELOPMENT");
}

const vladeniyaPotokov = new Map();
for (const z of diffZapisi) {
  for (const p of [z.old, z.nov]) {
    if (!p) continue;
    if (obshchij(p)) {
      fullSet = true;
      if (!policyPrichina.includes("COMMON_CHANGE")) policyPrichina.push("COMMON_CHANGE");
      notes.push(`COMMON_CHANGE: ${p}`);
      continue;
    }
    const vl = vladelec(p);
    if (vl.length) {
      for (const id of vl) if (!selected.has(id)) selected.set(id, "AFFECTED");
      // флоу обязан иметь ровно одного владельца-исполнителя
      if (/^mobile\/\.maestro\/[^/]+\.yaml$/.test(p)) {
        const pred = vladeniyaPotokov.get(p) || new Set();
        vl.forEach((x) => pred.add(x));
        vladeniyaPotokov.set(p, pred);
      }
      continue;
    }
    if (STRUKTURA_RE.some((re) => re.test(p))) {
      // новый pack / новый флоу / новый маршрут без записи в карте — инвентарь
      fail("INVENTAR_KARTY", p);
    }
    if (VNUTRI_PRODUKTA.test(p)) {
      fullSet = true;
      notes.push(`UNKNOWN_PATH: ${p}`);
      if (!policyPrichina.includes("UNKNOWN_PATH")) policyPrichina.push("UNKNOWN_PATH");
    }
    // путь вне продукта (docs/, README, .gitignore…) — не сужает и не расширяет
  }
}

// флоу в diff мог быть известен карте как путь экрана — единственность
for (const [p, vl] of vladeniyaPotokov) {
  if (vl.size > 1) fail("INVENTAR_KARTY", `поток ${p} заявлен ${vl.size} владельцами: ${[...vl].join(",")}`);
}

if (fullSet) {
  for (const z of unionZapisi) selected.set(z.id, selected.get(z.id) || policyPrichina[0]);
} else if (selected.size === 0) {
  fullSet = true;
  for (const z of unionZapisi) selected.set(z.id, "EMPTY_SELECTION_FALLBACK");
  notes.push("EMPTY_SELECTION_FALLBACK: пустой первичный результат — консервативно полный набор");
}


const vyhody = {};
const selectedSpisok = [];
const excluded = [];
for (const z of unionZapisi) {
  const est = selected.get(z.id);
  vyhody[z.job] = est ? "true" : "false";
  (est ? selectedSpisok : excluded).push({ id: z.id, job: z.job, reason: est || "NOT_SELECTED" });
}

const sel = {
  mode: args.mode,
  base: args.base, head: args.head,
  karta_sha256: { base: baseMap.sha, head: headMap.sha },
  diff_istochnik: diffIstochnik,
  izmenenija: diffZapisi.map((z) => ({ status: z.status, old: z.old, nov: z.nov })),
  policy_change: policyChange,
  full_set: fullSet,
  prichiny: policyPrichina,
  selected: selectedSpisok,
  excluded,
  notes,
};
fs.writeFileSync(args.out, JSON.stringify(sel, null, 2) + "\n");
for (const [job, v] of Object.entries(vyhody)) {
  process.stdout.write(`VYHOD ${job}=${v}\n`);
  if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, `${job}=${v}\n`);
}
process.stdout.write(`VYBOROK ${selectedSpisok.length} iz ${unionZapisi.length}\n`);

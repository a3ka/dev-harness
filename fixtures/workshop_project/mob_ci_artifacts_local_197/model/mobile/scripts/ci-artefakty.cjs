#!/usr/bin/env node
// 197 (канон, contracts/197-mob-ci-artefakty-lokalno.md): локальный транспорт
// CI-артефактов Complior-mob. ЕДИНСТВЕННЫЙ источник грамматики пути
//   <koren>/<run_id>-<run_attempt>/<imja>/
// koren = env CI_ARTEFAKTY_KOREN, по умолчанию /var/lib/ci-artifacts/Complior-mob
// (корень и очистка — предмет 196; env-override существует для замкнутого
// replay батареи и станционной настройки, workflow его НЕ задаёт).
//
// Глаголы (замкнутый набор):
//   zapis   --imja M --chto P            записать P (файл или каталог) в свой
//                                        run-контекст; P обязан существовать
//   chtenie (--imja M | --shablon G) --kuda D [--run-id R --run-attempt T]
//                                        прочитать в D; пара --run-id/--run-attempt
//                                        (оба или ни один) задаёт контекст
//                                        ПРОДЮСЕРА (APK сборки переживает
//                                        выборочный повтор работника)
//
// Выход: rc 0 — успех; rc 2 — именованный отказ ARTEFAKT_OTKAZ: <причина>
// (fail-closed: успехом не считается молчаливый фолбэк; пустое чтение
// ТОЧНОГО имени и отсутствующий каталог run'а — отказ). ЕДИНСТВЕННОЕ
// исключение (197 v+1, слово владельца 2026-11-16): пустой выбор ШАБЛОНА —
// rc 0, строка CHTENIE_PUSTO и ПУСТОЙ созданный --kuda (семантика
// actions/download-artifact с pattern); строгость ожидаемого множества
// держит потребитель — ci-aggregate.cjs сверяет выбранные экраны с
// evidence-каталогом ровно.

'use strict';

const fs = require('fs');
const path = require('path');

const KOREN_PO_UMOLCHANIJU = '/var/lib/ci-artifacts/Complior-mob';
const RE_IMJA = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;
const RE_SHABLON = /^[A-Za-z0-9][A-Za-z0-9._*-]*$/;
const RE_CHISLO = /^[0-9]+$/;

function otkaz(prichina) {
  console.error('ARTEFAKT_OTKAZ: ' + prichina);
  process.exit(2);
}

function argumenty(argv) {
  // argv[2] — глагол, далее --klyuch znachenie парами; повтор ключа — отказ.
  const izvestno = new Set(['--imja', '--chto', '--kuda', '--shablon', '--run-id', '--run-attempt']);
  const rezultat = { glagol: argv[2], parametry: {} };
  if (rezultat.glagol !== 'zapis' && rezultat.glagol !== 'chtenie') {
    otkaz('GLAGOL_NEIZVESTEN: ' + String(rezultat.glagol));
  }
  for (let i = 3; i < argv.length; i += 2) {
    const kljuch = argv[i];
    if (!izvestno.has(kljuch)) otkaz('KLJUCH_NEIZVESTEN: ' + String(kljuch));
    if (i + 1 >= argv.length) otkaz('KLJUCH_BEZ_ZNACHENIJA: ' + kljuch);
    if (kljuch in rezultat.parametry) otkaz('KLJUCH_POVTORJAETSJA: ' + kljuch);
    rezultat.parametry[kljuch] = argv[i + 1];
  }
  return rezultat;
}

function kontekst_runa(parametry, vlastnyj) {
  // vlastnyj=true: только собственные GITHUB_RUN_ID/GITHUB_RUN_ATTEMPT,
  // продюсерские аргументы у писателя — отказ (интерфейс закрыт).
  if (vlastnyj) {
    if ('--run-id' in parametry || '--run-attempt' in parametry) {
      otkaz('PISATEL_S_RUN_ARGUMENTOM');
    }
    return { id: process.env.GITHUB_RUN_ID, popytka: process.env.GITHUB_RUN_ATTEMPT };
  }
  const estId = '--run-id' in parametry;
  const estPopytka = '--run-attempt' in parametry;
  if (estId !== estPopytka) otkaz('NEPOLNAJA_IDENTIFIKACIJA_RUNA');
  if (estId) {
    return { id: parametry['--run-id'], popytka: parametry['--run-attempt'] };
  }
  return { id: process.env.GITHUB_RUN_ID, popytka: process.env.GITHUB_RUN_ATTEMPT };
}

function proverka_konteksta(k) {
  if (!RE_CHISLO.test(String(k.id || '')) || !RE_CHISLO.test(String(k.popytka || ''))) {
    otkaz('RUN_KONTSEKST_NECHISLOVYJ: ' + JSON.stringify({ id: k.id, popytka: k.popytka }));
  }
}

function koren() {
  const rezultat = process.env.CI_ARTEFAKTY_KOREN || KOREN_PO_UMOLCHANIJU;
  if (!path.isAbsolute(rezultat)) otkaz('KOREN_NE_ABSOLJUTNYJ: ' + rezultat);
  return path.resolve(rezultat);
}

function katalog_artefakta(k, imja) {
  const baza = path.resolve(koren(), k.id + '-' + k.popytka, imja);
  // Двойной страж: даже если алфавит имени пропущен, выход за корень невозможен.
  const otnositelno = path.relative(koren(), baza);
  if (otnositelno.startsWith('..') || path.isAbsolute(otnositelno)) {
    otkaz('VYHOD_ZA_KOREN: ' + baza);
  }
  return baza;
}

function skopirovat(istochnik, naznachenie) {
  const stat = fs.lstatSync(istochnik);
  if (stat.isDirectory()) {
    fs.mkdirSync(naznachenie, { recursive: true });
    for (const imja of fs.readdirSync(istochnik)) {
      skopirovat(path.join(istochnik, imja), path.join(naznachenie, imja));
    }
  } else if (stat.isFile()) {
    fs.mkdirSync(path.dirname(naznachenie), { recursive: true });
    fs.copyFileSync(istochnik, naznachenie);
  } else {
    otkaz('ISTOCHNIK_NE_FAIJ_NI_KATALOG: ' + istochnik);
  }
}

function glob_v_regex(shablon) {
  // '*' — любой набор символов КРОМЕ '/' (имя — один сегмент каталога).
  const ekran = shablon.replace(/[.+^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '[^/]*');
  return new RegExp('^' + ekran + '$');
}

function main() {
  const { glagol, parametry: p } = argumenty(process.argv);
  const baza = koren();

  if (glagol === 'zapis') {
    const imja = p['--imja'];
    const chto = p['--chto'];
    if (!imja || !RE_IMJA.test(imja) || imja.includes('/')) otkaz('IMJA_VNE_ALFAVITA: ' + String(imja));
    if (!chto) otkaz('NET_ISTOCHNIKA');
    const k = kontekst_runa(p, true);
    proverka_konteksta(k);
    if (!fs.existsSync(chto)) otkaz('ISTOCHNIK_OTSTUTSTVUET: ' + chto);
    // <imja>/ — ВСЕГДА каталог: файл кладётся внутрь под своим именем,
    // каталог — содержимым (семантика upload/download-artifact: артефакт =
    // множество файлов, чтение получает их в --kuda верхним уровнем).
    const naznachenie = katalog_artefakta(k, imja);
    const stat = fs.lstatSync(chto);
    if (stat.isDirectory()) {
      skopirovat(chto, naznachenie);
    } else if (stat.isFile()) {
      skopirovat(chto, path.join(naznachenie, path.basename(chto)));
    } else {
      otkaz('ISTOCHNIK_NE_FAIJ_NI_KATALOG: ' + chto);
    }
    console.log('ZAPIS ' + path.relative(baza, naznachenie));
    return;
  }

  // chtenie
  const kuda = p['--kuda'];
  if (!kuda) otkaz('NET_NAZNACHENIJA');
  if (path.isAbsolute(kuda) || kuda.split('/').includes('..')) otkaz('NAZNACHENIE_VNE_RABOCHEGO_KATALOGA: ' + kuda);
  const k = kontekst_runa(p, false);
  proverka_konteksta(k);
  const katalog_runa = path.resolve(baza, k.id + '-' + k.popytka);
  if (!fs.existsSync(katalog_runa) || !fs.statSync(katalog_runa).isDirectory()) {
    otkaz('KATALOG_RUNA_OTSTUTSTVUET: ' + path.relative(baza, katalog_runa));
  }

  if ('--imja' in p) {
    if ('--shablon' in p) otkaz('IMJA_I_SHABLON_ODNOVREMENNO');
    const imja = p['--imja'];
    if (!RE_IMJA.test(imja) || imja.includes('/')) otkaz('IMJA_VNE_ALFAVITA: ' + String(imja));
    const istochnik = katalog_artefakta(k, imja);
    if (!fs.existsSync(istochnik) || !fs.statSync(istochnik).isDirectory()) {
      otkaz('CHTENIE_OTSTUTSTVUET: ' + path.relative(baza, istochnik));
    }
    skopirovat(istochnik, kuda);
    console.log('CHTENIE ' + path.relative(baza, istochnik));
    return;
  }

  const shablon = p['--shablon'];
  if (!shablon) otkaz('NET_IMENI_NI_SHABLONA');
  if (!RE_SHABLON.test(shablon) || shablon.includes('/')) otkaz('SHABLON_VNE_ALFAVITA: ' + String(shablon));
  const regex = glob_v_regex(shablon);
  const sovpadenija = fs.readdirSync(katalog_runa)
    .filter((imja) => imja.includes('*') === false && regex.test(imja) && fs.statSync(path.join(katalog_runa, imja)).isDirectory())
    .sort();
  if (sovpadenija.length === 0) {
    // 197 v+1 (слово владельца 2026-11-16 «197 v+1 — да»): пустой выбор
    // шаблона — НЕ отказ: PR без новых экранов даёт пустую matrix, читатель
    // screen-evidence-* честно собирает ноль детей (mob#180: rc 2 краснил
    // required android-e2e на каждом таком PR). Точное имя и каталог run'а
    // остаются fail-closed.
    fs.mkdirSync(kuda, { recursive: true });
    console.log('CHTENIE_PUSTO: ' + shablon);
    return;
  }
  for (const imja of sovpadenija) {
    skopirovat(path.join(katalog_runa, imja), path.join(kuda, imja));
  }
  console.log('CHTENIE_PO_SHABLONU ' + sovpadenija.length + ': ' + sovpadenija.join(', '));
}

main();

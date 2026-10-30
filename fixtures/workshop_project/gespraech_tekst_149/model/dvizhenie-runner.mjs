// Раннер численной приёмки движения 149 (node, без зависимостей).
// Судит машину текст-чата против ПИННОВАННОЙ спеки дизайнера
// (motion-spec-gespraech.json): планы переходов меню→Schreiben (GA-T30),
// плашка→тема (GA-T32) и Beenden→текст (GA-T37) обязаны совпадать с
// треками сцен (задержки/длительности/кривые/УД) ПОЛНОСТЬЮ; фон чата
// закрывает меню до построения чата; морф пилюля→поле и Leiste→поле —
// токеном морфа на кривой морфа; вопрос Complior раньше чипов; поле
// ввода растёт до потолка строк и прокручивается. Таймлайн T32 (задержки
// отметки/вопроса/чипов) берётся из СОБЫТИЙ пиннованной спеки — машина
// получает его параметром. Отчёт — jest-формы (--json --outputFile);
// одиночное правило — аргументом --pravilo (для клеток батареи).
// Коды возврата: 0 — все правила зелены; 1 — правило красно; 2 — нечем
// судить (нет файла/модуля, кривой JSON).
import { readFileSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

function arg(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1] : null;
}

const putMashiny = arg('--machine');
const putSpecy = arg('--spec');
const pravilo = arg('--pravilo');
const outputFile = arg('--outputFile');
if (!putMashiny || !putSpecy) {
  console.error('CLI: dvizhenie-runner.mjs --machine chat-machine.ts ' +
                '--spec spec.json [--pravilo id] [--json] ' +
                '[--outputFile put]');
  process.exit(2);
}

let spec;
let mashinaModul;
try {
  spec = JSON.parse(readFileSync(putSpecy, 'utf8'));
  mashinaModul = await import(pathToFileURL(putMashiny).href);
} catch (e) {
  console.error('Runner: не читается вход — ' + e);
  process.exit(2);
}

const T = {};
for (const t of spec.tokens) {
  const m = /^([0-9.]+)ms$/.exec(t.value);
  T[t.name] = m ? Number(m[1]) : null;
}
const TEMY = { 'ease-standard': 'ease-standard', 'ease-morph': 'ease-morph',
               'linear': 'linear' };

function scena(id) {
  const s = spec.scenes.filter((x) => x.id === id)[0];
  if (!s) {
    throw new Error('нет сцены ' + id);
  }
  return s;
}
// ожидаемые треки спеки: МУЛЬТИМНОЖЕСТВО ключей элемент+свойство →
// список (задержка/длит/кривая/УД): сцены T30/T37 несут ДВА трека
// #morph|opacity (слой появляется в нуле и уходит на морф-минус-быстрый)
function kartaSceny(id) {
  const karta = new Map();
  for (const t of scena(id).tracks) {
    const kljuch = t.element + '|' + t.property;
    if (!karta.has(kljuch)) {
      karta.set(kljuch, []);
    }
    karta.get(kljuch).push({
      delayMs: t.delay.ms,
      durationMs: t.duration.ms,
      curve: TEMY[t.curve.token] || t.curve.token,
      reducedMs: t.reduced_duration_ms,
    });
  }
  return karta;
}

function soglaseny(plany, karta, polnota) {
  const ostatok = new Map();
  for (const [k, spisok] of karta) {
    ostatok.set(k, spisok.slice());
  }
  const net = [];
  for (const p of plany) {
    const kljuch = p.element + '|' + p.property;
    const spisok = ostatok.get(kljuch) || [];
    const i = spisok.findIndex((e) => e.delayMs === p.delayMs
        && e.durationMs === p.durationMs && e.curve === p.curve
        && e.reducedMs === p.reducedMs);
    if (i < 0) {
      net.push(kljuch + ' план=' +
               [p.delayMs, p.durationMs, p.curve, p.reducedMs].join('/') +
               (spisok.length
                ? ' спека=' + spisok.map((e) => [e.delayMs, e.durationMs,
                    e.curve, e.reducedMs].join('/')).join(' | ')
                : ' нет в спеке'));
    } else {
      spisok.splice(i, 1);
    }
  }
  if (polnota) {
    for (const [k, spisok] of ostatok) {
      for (const e of spisok) {
        net.push('неполнота: ' + k + ' нет плана на ' +
                 [e.delayMs, e.durationMs, e.curve, e.reducedMs].join('/'));
      }
    }
  }
  return net;
}

// таймлайн GA-T32 из СОБЫТИЙ спеки: отметка/вопрос/чипы (единый источник
// задержек сцены; машина их не изобретает — получает параметром)
function vremenaT32() {
  const sob = scena('GA-T32').events;
  const po = {};
  for (const s of sob) {
    po[s.element] = s.at.ms;
  }
  for (const k of ['#b-mk', '#b-a', '#b-qr']) {
    if (!(k in po)) {
      throw new Error('нет события ' + k + ' в GA-T32');
    }
  }
  return { otmetka: po['#b-mk'], vopros: po['#b-a'], chipy: po['#b-qr'] };
}

const TK = { motionFast: T['motion-fast'], motionBase: T['motion-base'],
             motionMorph: T['motion-morph'] };

function plany(m) {
  return { t30: m.planT30(), t32: m.planT32(vremenaT32()), t37: m.planT37() };
}

function trek(pl, element, property) {
  return pl.filter((p) => p.element === element && p.property === property)[0];
}

function pravila(mashinaFn) {
  const m = mashinaFn(TK);
  const P = plany(m);
  const pravilaS = {};

  pravilaS['plan-t30'] = () => {
    const net = soglaseny(P.t30, kartaSceny('GA-T30'), true);
    if (net.length) {
      throw new Error('план T30 расходится со спекой: ' + net.join('; '));
    }
    return 'план меню→Schreiben == треки GA-T30';
  };

  pravilaS['t30-fon-do-chata'] = () => {
    const fon = P.t30.filter((p) => p.element === '#gnd'
                             && p.property === 'opacity')[0];
    const koncyFona = fon.delayMs + fon.durationMs;
    const nachala = P.t30.filter((p) => p.element.startsWith('.L-chat2'))
      .map((p) => p.delayMs);
    if (!nachala.length || nachala.some((d) => d < koncyFona)) {
      throw new Error('чат строится до того, как фон закрыл меню: фон к ' +
                      koncyFona + ', чат с ' + Math.min.apply(null, nachala));
    }
    return 'непрозрачный фон закрывает меню ДО построения чата';
  };

  pravilaS['t30-morf-pilulja-pole'] = () => {
    const mesta = P.t30.filter((p) => p.element === '#morph'
                               && ['left', 'top', 'w', 'h'].includes(
                                   p.property));
    if (mesta.length !== 4) {
      throw new Error('морф пилюля→поле не четыре трека: ' + mesta.length);
    }
    for (const p of mesta) {
      if (p.durationMs !== T['motion-morph'] || p.curve !== 'ease-morph'
          || p.reducedMs !== 0) {
        throw new Error('морф не motion-morph/ease-morph/УД-0: ' +
                        [p.property, p.durationMs, p.curve,
                         p.reducedMs].join('/'));
      }
    }
    const pole = trek(P.t30, '.L-chat2 .p-chatcomp-field', 'opacity');
    const uhod = P.t30.filter((p) => p.element === '#morph'
                              && p.property === 'opacity'
                              && p.delayMs === T['motion-morph']
                                         - T['motion-fast'])[0];
    if (!pole || pole.delayMs !== T['motion-morph'] - T['motion-fast']) {
      throw new Error('поле встаёт не на морф-минус-быстрый');
    }
    if (!uhod || uhod.delayMs + uhod.durationMs !== T['motion-morph']) {
      throw new Error('слой морфа уходит не к концу морфа');
    }
    return 'морф пилюля→поле: motion-morph ease-morph УД-0; поле на месте';
  };

  pravilaS['t30-temy-posle-polja'] = () => {
    const temy = trek(P.t30, '.L-chat2 .p-topics', 'opacity');
    const pole = trek(P.t30, '.L-chat2 .p-chatcomp-field', 'opacity');
    if (!temy || temy.delayMs !== T['motion-morph']) {
      throw new Error('темы-строка не на морфе: ' +
                      (temy ? temy.delayMs : 'нет трека'));
    }
    if (!pole || !(pole.delayMs + pole.durationMs <= temy.delayMs)) {
      throw new Error('темы-строка появляется раньше поля');
    }
    return 'темы-пилюли над полем — после поля, на морфе';
  };

  pravilaS['plan-t32'] = () => {
    const net = soglaseny(P.t32, kartaSceny('GA-T32'), true);
    if (net.length) {
      throw new Error('план T32 расходится со спекой: ' + net.join('; '));
    }
    return 'план плашка→тема == треки GA-T32';
  };

  pravilaS['t32-vopros-ranshe-chipov'] = () => {
    const vopros = trek(P.t32, '#b-a', 'reveal');
    const chipy = trek(P.t32, '#b-qr', 'opacity');
    if (!vopros || !chipy || !(vopros.delayMs < chipy.delayMs)) {
      throw new Error('вопрос Complior не раньше чипов: ' +
                      (vopros && chipy
                       ? vopros.delayMs + ' против ' + chipy.delayMs
                       : 'нет треков'));
    }
    // чипы и «Lieber erzählen?» — ОДИН элемент (приходят вместе)
    const vmeste = P.t32.filter((p) => p.element === '#b-qr');
    if (vmeste.length !== 2) {
      throw new Error('чипы не одним элементом: ' + vmeste.length);
    }
    return 'вопрос раньше; чипы и «Lieber erzählen?» вместе';
  };

  pravilaS['plan-t37'] = () => {
    const net = soglaseny(P.t37, kartaSceny('GA-T37'), true);
    if (net.length) {
      throw new Error('план T37 расходится со спекой: ' + net.join('; '));
    }
    return 'план Beenden→текст == треки GA-T37';
  };

  pravilaS['t37-leista-v-pole'] = () => {
    const mesta = P.t37.filter((p) => p.element === '#morph'
                               && ['left', 'top', 'w', 'h'].includes(
                                   p.property));
    if (mesta.length !== 4) {
      throw new Error('морф Leiste→поле не четыре трека: ' + mesta.length);
    }
    for (const p of mesta) {
      if (p.durationMs !== T['motion-morph'] || p.curve !== 'ease-morph'
          || p.reducedMs !== 0) {
        throw new Error('морф не motion-morph/ease-morph/УД-0: ' +
                        [p.property, p.durationMs, p.curve,
                         p.reducedMs].join('/'));
      }
    }
    const pole = trek(P.t37, '#a-text .p-chatcomp-field', 'opacity');
    const stroka = trek(P.t37, '#b-end', 'opacity');
    if (!pole || pole.delayMs !== T['motion-morph'] - T['motion-fast']) {
      throw new Error('поле встаёт не на морф-минус-быстрый');
    }
    if (!stroka || stroka.delayMs !== T['motion-morph']) {
      throw new Error('строка «Weiter im Anliegen» не на морфе');
    }
    return 'морф Leiste→поле; строка продолжения — после морфа';
  };

  pravilaS['ud-bez-poljota'] = () => {
    for (const imja of ['t30', 't32', 't37']) {
      for (const p of P[imja]) {
        const vidimo = p.property === 'opacity' || p.property === 'bg';
        if (vidimo ? p.reducedMs > T['motion-fast'] : p.reducedMs !== 0) {
          throw new Error('УД нарушен (' + imja + '): ' + p.element + '|' +
                          p.property + ' reducedMs=' + p.reducedMs);
        }
      }
    }
    return 'УД: перемещение/морф 0, видимое не дольше motion-fast';
  };

  pravilaS['pole-shest-strok'] = () => {
    const potolok = m.poleStrokMaksimum();
    if (potolok !== 6) {
      throw new Error('потолок поля не шесть строк: ' + potolok);
    }
    for (let n = 1; n <= potolok + 1; n++) {
      if (m.poleRastjot(n) !== (n <= potolok)) {
        throw new Error('рост поля неверен на ' + n + ' строках');
      }
      if (m.poleSkrolluet(n) !== (n > potolok)) {
        throw new Error('прокрутка поля неверна на ' + n + ' строках');
      }
    }
    return 'поле растёт до потолка строк, дальше — прокрутка';
  };

  return pravilaS;
}

let mashinaFn;
if (typeof mashinaModul.createChatMachine !== 'function') {
  console.error('Runner: в модуле машины нет createChatMachine');
  process.exit(2);
}
mashinaFn = mashinaModul.createChatMachine;

const P = pravila(mashinaFn);
const imena = pravilo ? [pravilo] : Object.keys(P);
if (pravilo && !(pravilo in P)) {
  console.error('Runner: нет правила ' + pravilo);
  process.exit(2);
}

const rezultaty = [];
let proshli = 0;
for (const imja of imena) {
  let status = 'passed';
  let soobshenie = '';
  try {
    soobshenie = P[imja]();
    proshli += 1;
  } catch (e) {
    status = 'failed';
    soobshenie = String(e.message || e);
  }
  rezultaty.push({ title: imja + ' — ' + soobshenie, status,
                   failureMessages: status === 'failed' ? [soobshenie] : [] });
}

const otchet = {
  numTotalTests: rezultaty.length,
  numPassedTests: proshli,
  numFailedTests: rezultaty.length - proshli,
  success: proshli === rezultaty.length,
  testResults: [{
    name: putMashiny,
    status: proshli === rezultaty.length ? 'passed' : 'failed',
    assertionResults: rezultaty,
  }],
};

if (outputFile) {
  otchet.launchMs = Date.now();
  writeFileSync(outputFile, JSON.stringify(otchet, null, 1));
} else {
  for (const r of rezultaty) {
    console.log((r.status === 'passed' ? 'PASS ' : 'FAIL ') + r.title);
  }
  console.log('Tests: ' + proshli + ' passed, ' +
              (rezultaty.length - proshli) + ' failed, ' +
              rezultaty.length + ' total');
}
process.exit(proshli === rezultaty.length ? 0 : 1);

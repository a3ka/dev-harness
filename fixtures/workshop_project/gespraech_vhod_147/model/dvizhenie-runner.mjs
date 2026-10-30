// Раннер численной приёмки движения 147 (node, без зависимостей).
// Судит машину вход-меню против ПИННОВАННОЙ спеки дизайнера
// (motion-spec-gespraech.json): план открытия/закрытия/удержания машины
// обязан совпадать с треками сцен GA-T28/GA-T31/GA-T35 (задержки/
// длительности/кривые/УД), «Sprechen» первым, меню читается к 300 мс,
// press-long 500 мс. Отчёт — jest-формы (--json --outputFile);
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
  console.error('CLI: dvizhenie-runner.mjs --machine menu-machine.ts ' +
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

// ожидаемые треки спеки: ключ элемент+свойство -> задержка/длит/кривая/УД
function kartaSceny(id) {
  const karta = new Map();
  for (const t of scena(id).tracks) {
    karta.set(t.element + '|' + t.property, {
      delayMs: t.delay.ms,
      durationMs: t.duration.ms,
      curve: TEMY[t.curve.token] || t.curve.token,
      reducedMs: t.reduced_duration_ms,
    });
  }
  return karta;
}

function soglaseny(plany, karta, polnota) {
  const net = [];
  for (const p of plany) {
    const e = karta.get(p.element + '|' + p.property);
    if (!e || e.delayMs !== p.delayMs || e.durationMs !== p.durationMs
        || e.curve !== p.curve || e.reducedMs !== p.reducedMs) {
      net.push(p.element + '|' + p.property + ' план=' +
               [p.delayMs, p.durationMs, p.curve, p.reducedMs].join('/') +
               (e ? ' спека=' + [e.delayMs, e.durationMs, e.curve,
                                  e.reducedMs].join('/') : ' нет в спеке'));
    }
  }
  if (polnota && plany.length !== karta.size) {
    net.push('неполнота: план ' + plany.length + ' треков, спека ' +
             karta.size);
  }
  return net;
}

const TK = { motionFast: T['motion-fast'], motionBase: T['motion-base'],
             staggerTight: T['motion-stagger-tight'],
             pressLong: T['press-long'] };

function pravila(mashinaFn) {
  const m = mashinaFn(TK, false);
  const mr = mashinaFn(TK, true);
  const pill = (i) => '.ga-dial .p-dial-list > li:nth-child(' + i + ')';
  const pravilaS = {};

  pravilaS['plan-open-t28'] = () => {
    const net = soglaseny(m.planOpen(), kartaSceny('GA-T28'), true);
    if (net.length) {
      throw new Error('план открытия расходится со спекой T28: ' +
                      net.join('; '));
    }
    return 'план открытия == треки GA-T28';
  };

  pravilaS['sprechen-pervym'] = () => {
    const z = m.planOpen()
      .filter((p) => p.property === 'opacity' && p.element.includes('li:'))
      .map((p) => p.delayMs);
    const vozr = z.every((v, i) => i === 0 || v > z[i - 1]);
    if (!vozr || z.length !== 4) {
      throw new Error('задержки пилюль не возрастают: ' + z.join(','));
    }
    const pervyj = m.planOpen().filter((p) => p.element === pill(1)
                                       && p.property === 'opacity')[0];
    const vtoroj = m.planOpen().filter((p) => p.element === pill(2)
                                       && p.property === 'opacity')[0];
    if (!pervyj || !vtoroj || !(pervyj.delayMs < vtoroj.delayMs)) {
      throw new Error('«Sprechen» (первая пилюля) не первая по задержке');
    }
    return 'пилюли сверху вниз, «Sprechen» первым';
  };

  pravilaS['menja-k-300'] = () => {
    const koncy = m.planOpen()
      .filter((p) => p.property === 'opacity' && p.element.includes('li:'))
      .map((p) => p.delayMs + p.durationMs);
    const posl = Math.max.apply(null, koncy);
    if (!(posl > 0) || posl > 300) {
      throw new Error('последняя пилюля видна к ' + posl +
                      ' (норма — не позже 300)');
    }
    return 'последняя пилюля видна к ' + posl;
  };

  pravilaS['znak-morf-250'] = () => {
    const morf = m.planOpen().filter((p) => p.element === '#mkg');
    if (morf.length !== 4) {
      throw new Error('морф знака не четыре трека: ' + morf.length);
    }
    for (const p of morf) {
      if (p.durationMs !== T['motion-base'] || p.curve !== 'ease-morph'
          || p.reducedMs !== 0) {
        throw new Error('морф не motion-base/ease-morph/УД-0: ' +
                        [p.property, p.durationMs, p.curve,
                         p.reducedMs].join('/'));
      }
    }
    return 'морф камешек → вопрос: motion-base ease-morph, УД 0';
  };

  pravilaS['press-long-500'] = () => {
    const hold = m.planHold()[0];
    if (!hold || hold.to !== 1.06 || hold.durationMs !== T['press-long']
        || hold.curve !== 'linear') {
      throw new Error('press-long не 500 linear 1 → 1.06');
    }
    if (m.holdResult(T['press-long'] - 1) !== 'menu'
        || m.holdResult(T['press-long']) !== 'voice') {
      throw new Error('отпускание до 500 — не касание-меню');
    }
    const net = soglaseny(m.planHold().concat(m.planVoice()),
                        kartaSceny('GA-T35'), true);
    if (net.length) {
      throw new Error('план голоса расходится с GA-T35: ' + net.join('; '));
    }
    return 'удержание 500 → голос; раньше — меню';
  };

  pravilaS['plan-close-t31'] = () => {
    const net = soglaseny(m.planClose(), kartaSceny('GA-T31'), true);
    if (net.length) {
      throw new Error('план закрытия расходится со спекой T31: ' +
                      net.join('; '));
    }
    return 'план закрытия == треки GA-T31';
  };

  pravilaS['ud-bez-poljota'] = () => {
    for (const p of mr.planOpen()) {
      const vidimo = p.property === 'opacity';
      if (vidimo ? p.reducedMs > T['motion-fast'] : p.reducedMs !== 0) {
        throw new Error('УД нарушен: ' + p.element + '|' + p.property +
                        ' reducedMs=' + p.reducedMs);
      }
    }
    return 'УД: перемещение/морф 0, видимое не дольше motion-fast';
  };

  return pravilaS;
}

let mashinaFn;
if (typeof mashinaModul.createMenuMachine !== 'function') {
  console.error('Runner: в модуле машины нет createMenuMachine');
  process.exit(2);
}
mashinaFn = mashinaModul.createMenuMachine;

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

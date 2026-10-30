// Обёртка численной приёмки движения пачки gespraech-tekst (контракт 149).
// Вызывается валидатором 132 v3 фактическим argv из корня репо:
//   node mobile/e2e-gespraech-tekst/dvizhenie.mjs --json \
//        --outputFile mobile/e2e-gespraech-tekst/jest-otchet.json gespraech
// Запускает продуктовый jest (npm --prefix mobile test, канон-сьют
// src/features/conversation/__tests__/gespraech-tekst.test.ts) и
// кладёт отчёт jest-формы по указанному пути ОТ КОРНЯ репо (валидатор
// судит форму/свежесть/полноту отчёта; origin отчёта — живой jest).
// Чисел внутри скобок в тексте нет: литералы цветов/размеров в пачке
// запрещены (шаблон 132), аудит судит классом — в том числе функции.
// Коды возврата — коды jest: ноль — все тесты зелены.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const SDVIG_ARGV = 2;
const NECHEM_PROVERJAT = 2;
const JEDINICA = 1;

const argv = process.argv.slice(SDVIG_ARGV);
const i = argv.indexOf('--outputFile');
const estJSON = argv.includes('--json');
if (!estJSON || i < 0 || i + JEDINICA >= argv.length) {
  console.error('CLI: dvizhenie.mjs --json --outputFile <путь> [шаблон]');
  process.exit(NECHEM_PROVERJAT);
}
const koren = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const otchet = resolve(koren, argv[i + JEDINICA]);
const zaFlagami = argv.slice(i + JEDINICA + JEDINICA);
const shablon = zaFlagami.filter((a) => !a.startsWith('--'));
const r = spawnSync('npm', ['--prefix', 'mobile', 'test', '--',
                            '--ci', '--runInBand', '--json',
                            '--outputFile', otchet].concat(shablon),
                    { cwd: koren, stdio: 'inherit' });
if (r.error) {
  console.error('dvizhenie: jest не запущен — ' + r.error);
  process.exit(NECHEM_PROVERJAT);
}
const kod = r.status ?? JEDINICA;
process.exit(kod);

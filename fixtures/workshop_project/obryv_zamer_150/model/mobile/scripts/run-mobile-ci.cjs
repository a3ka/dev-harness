'use strict';
// 150 — модель lane-раннера продукта (форма 163: закрытый словарь lanes,
// КАЖДЫЙ lane-вызов workflow — однострочный `npm run ci:<lane>`). Привязка
// lane zamer закрыта: фиксированный argv без eval/произвольного
// shell-параметра — spawn bash mobile/scripts/zamer_obryva.sh + ДОСЛОВНАЯ
// передача остальных аргументов шага (start/sbor --ekran/--ns/--serial/
// --spool/--out). Батарея 150 судит привязку по канонической строке словаря
// (model/kanon/lane-zamer.txt); остальное содержимое файла — зона 163.
const { spawnSync } = require('node:child_process');
const lanes = {
  zamer: ['bash', ['mobile/scripts/zamer_obryva.sh']],
};
if (process.argv[2] === '--list') {
  console.log(Object.keys(lanes).join('\n'));
  process.exit(0);
}
const lane = process.argv[2] === '--lane' ? process.argv[3] : undefined;
if (!Object.hasOwn(lanes, lane)) {
  console.error('LANE_UNKNOWN');
  process.exit(1);
}
const [cmd, args] = lanes[lane];
const result = spawnSync(cmd, args.concat(process.argv.slice(4)), { stdio: 'inherit' });
process.exit(result.status ?? 1);

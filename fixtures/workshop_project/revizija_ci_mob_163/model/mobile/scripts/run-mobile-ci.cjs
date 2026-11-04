'use strict';
const { spawnSync } = require('node:child_process');
const lanes = {
  quality: ['bash', ['mobile/scripts/ci-quality.sh']],
  'e2e-splash': ['bash', ['mobile/scripts/ci-e2e-splash.sh']],
  'e2e-cloud': ['bash', ['mobile/scripts/ci-e2e-cloud.sh']],
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
const result = spawnSync(cmd, args, { stdio: 'inherit' });
process.exit(result.status ?? 1);

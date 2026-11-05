#!/usr/bin/env node
'use strict';
// One child owns one isolated AVD, installs the verified APK, and emits its own evidence.
const fs = require('fs');
const path = require('path');
const {spawn, spawnSync} = require('child_process');
const args = process.argv.slice(2);
function option(name) { const i = args.indexOf(name); if (i < 0 || !args[i + 1]) throw Error('NET_' + name); return args[i + 1]; }
function run(command, argv, opts = {}) {
  const r = spawnSync(command, argv, {stdio: 'inherit', ...opts});
  if (r.error || r.status !== 0) throw Error('OTKAZ_' + command + ': ' + (r.error?.message || r.status));
}
(async () => {
  const id = option('--id'), pack = option('--pack'), flow = option('--flow'), port = Number(option('--port'));
  if (!/^[a-z0-9-]+$/.test(id) || !Number.isInteger(port) || port < 1024 || port > 65534 || port % 2 ||
      !/^mobile\/e2e-[a-z0-9-]+\/$/.test(pack) || !/^mobile\/\.maestro\/[a-z0-9-]+\.yaml$/.test(flow) ||
      !fs.statSync(pack).isDirectory() || !fs.statSync(flow).isFile()) throw Error('INVALID_SCREEN_INPUT');
  const {APK_FILE, APK_SHA256, APK_ARTIFACT_NAME, GITHUB_RUN_ID, GITHUB_RUN_ATTEMPT, ANDROID_AVD_HOME} = process.env;
  if (![APK_FILE, APK_SHA256, APK_ARTIFACT_NAME, GITHUB_RUN_ID, GITHUB_RUN_ATTEMPT, ANDROID_AVD_HOME].every(Boolean)) throw Error('NET_IDENTICHNOSTI');
  const serial = `emulator-${port}`, avd = `ci143-${id}-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}`;
  const evidence = path.join('mobile/screen-evidence', id);
  fs.mkdirSync(evidence, {recursive: true});
  let emulator;
  async function boot() {
    emulator = spawn('emulator', ['-avd', avd, '-port', String(port), '-no-window', '-no-audio', '-no-boot-anim', '-no-snapshot', '-gpu', 'swiftshader_indirect'], {stdio: 'ignore'});
    run('adb', ['-s', serial, 'wait-for-device']);
    let ready = false;
    for (let i = 0; i < 130; i++) {
      const r = spawnSync('adb', ['-s', serial, 'shell', 'getprop', 'sys.boot_completed'], {encoding: 'utf8'});
      if (r.status === 0 && r.stdout.trim() === '1') { ready = true; break; }
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
    if (!ready) throw Error('AVD_BOOT_TIMEOUT');
    run('adb', ['-s', serial, 'install', '-r', APK_FILE]);
  }
  function maestro() {
    const r = spawnSync('maestro', ['--device', serial, 'test', flow], {encoding: 'utf8'});
    if (r.stdout) process.stdout.write(r.stdout);
    if (r.stderr) process.stderr.write(r.stderr);
    return r;
  }
  try {
    fs.mkdirSync(ANDROID_AVD_HOME, {recursive: true});
    const avdm = process.env.ANDROID_HOME ? path.join(process.env.ANDROID_HOME, 'cmdline-tools/latest/bin/avdmanager') : 'avdmanager';
    run(avdm, ['create', 'avd', '-n', avd, '-k', 'system-images;android-36;google_apis;x86_64', '-d', 'pixel_7', '--force'], {input: 'no\n', stdio: ['pipe', 'inherit', 'inherit']});
    await boot();
    let test = maestro();
    if (test.status !== 0 && /device offline|device .*not found|DeviceServerDiedException/i.test((test.stderr || '') + (test.stdout || ''))) {
      process.stderr.write('SCREEN_ADB_TRANSPORT_RETRY: ' + id + '\n');
      run('adb', ['-s', serial, 'emu', 'kill']);
      emulator.kill();
      await boot();
      test = maestro();
    }
    if (test.error || test.status !== 0) throw Error('MAESTRO_OTKAZ: ' + (test.error?.message || test.status));
    fs.writeFileSync(path.join(evidence, 'result.json'), JSON.stringify({screen_id: id, status: 'success', apk_sha256: APK_SHA256, artifact_name: APK_ARTIFACT_NAME, run_id: GITHUB_RUN_ID, run_attempt: GITHUB_RUN_ATTEMPT}) + '\n');
  } finally {
    if (emulator) { spawnSync('adb', ['-s', serial, 'emu', 'kill']); emulator.kill(); }
  }
})().catch(e => {console.error('SCREEN_RUN_OTKAZ: ' + e.message); process.exitCode = 1;});

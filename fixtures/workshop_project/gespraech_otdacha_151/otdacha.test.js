// Executed under the actual product jest-expo preset; never read expectations from subject files.
const H = require('expo-haptics');
const rows = require('../../../oracle.json').haptics;
const { patternFor, playHaptic } = require('./index');

jest.mock('expo-haptics', () => ({
  AndroidHaptics: { Virtual_Key: 'virtual-key', Context_Click: 'context-click',
    Long_Press: 'long-press', Clock_Tick: 'clock-tick', Reject: 'reject', Confirm: 'confirm' },
  ImpactFeedbackStyle: { Light: 'light', Medium: 'medium' },
  NotificationFeedbackType: { Warning: 'warning', Success: 'success', Error: 'error' },
  impactAsync: jest.fn(async () => {}), selectionAsync: jest.fn(async () => {}),
  notificationAsync: jest.fn(async () => {}), performAndroidHapticsAsync: jest.fn(async () => {}),
}), { virtual: true });

const ios = {
  'impactOccurred(.light)': ['impactAsync', 'light'],
  'impactOccurred(.medium)': ['impactAsync', 'medium'],
  selection: ['selectionAsync'],
  'notificationOccurred(.warning)': ['notificationAsync', 'warning'],
  'notificationOccurred(.success)': ['notificationAsync', 'success'],
  'notificationOccurred(.error)': ['notificationAsync', 'error'],
};
const android = {
  VIRTUAL_KEY: ['performAndroidHapticsAsync', 'virtual-key'],
  CONTEXT_CLICK: ['performAndroidHapticsAsync', 'context-click'],
  LONG_PRESS: ['performAndroidHapticsAsync', 'long-press'],
  CLOCK_TICK: ['performAndroidHapticsAsync', 'clock-tick'],
  REJECT: ['performAndroidHapticsAsync', 'reject'],
  CONFIRM: ['performAndroidHapticsAsync', 'confirm'],
};
const methods = ['impactAsync', 'selectionAsync', 'notificationAsync', 'performAndroidHapticsAsync'];

for (const [scene, at, iosPattern, androidPattern] of rows) {
  // Every row has its own witness: repeated R2/R3 scenes are distinguished by timestamp.
  for (const platform of ['ios', 'android']) {
    const expected = platform === 'ios' ? ios[iosPattern] : android[androidPattern];
    const id = `${platform.toUpperCase()}_${scene.replaceAll('-', '_')}_${at}`;
    test(`PATTERN_${id}`, () => {
      expect(patternFor(scene, at)).toEqual({ ios: iosPattern, android: androidPattern });
    });
    for (const enabled of [false, true]) for (const vibrationEnabled of [false, true])
      for (const quietMode of [false, true]) {
        const key = `${id}_E${+enabled}_V${+vibrationEnabled}_Q${+quietMode}`;
        test(`EMIT_${key}`, async () => {
          jest.useFakeTimers();
          try {
            methods.forEach(method => H[method].mockClear());
            await playHaptic(scene, at, { platform, enabled, vibrationEnabled, quietMode });
            await jest.runOnlyPendingTimersAsync();
            expect(jest.getTimerCount()).toBe(0);
            const calls = methods.flatMap(method => H[method].mock.calls.map(args => [method, ...args]));
            expect(calls).toEqual(enabled && vibrationEnabled && !quietMode ? [expected] : []);
          } finally {
            jest.useRealTimers();
          }
        });
      }
  }
}
for (const [scene, at] of [['GA-UNKNOWN', 0], ['', 0], ['GA-T28', -1], ['GA-T35', 0]]) {
  test(`UNKNOWN_${scene || 'EMPTY'}_${at}`, async () => {
    jest.useFakeTimers();
    try {
      methods.forEach(method => H[method].mockClear());
      expect(patternFor(scene, at)).toBeNull();
      await playHaptic(scene, at, { platform: 'android', enabled: true, vibrationEnabled: true, quietMode: false });
      await jest.runOnlyPendingTimersAsync();
      expect(jest.getTimerCount()).toBe(0);
      expect(methods.flatMap(method => H[method].mock.calls)).toEqual([]);
    } finally {
      jest.useRealTimers();
    }
  });
}

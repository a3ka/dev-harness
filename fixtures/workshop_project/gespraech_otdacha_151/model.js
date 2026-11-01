// Control implementation only; never copied to the product.
const Haptics = require('expo-haptics');
const rows = require('../../../oracle.json').haptics;

function patternFor(scene, at) {
  const row = rows.find(([id, time]) => id === scene && time === at);
  return row ? { ios: row[2], android: row[3] } : null;
}

async function playHaptic(scene, at, policy) {
  if (policy.enabled !== true || policy.vibrationEnabled !== true || policy.quietMode !== false) return;
  const pattern = patternFor(scene, at);
  if (!pattern) return;
  if (policy.platform === 'android') {
    const types = {
      VIRTUAL_KEY: Haptics.AndroidHaptics.Virtual_Key,
      CONTEXT_CLICK: Haptics.AndroidHaptics.Context_Click,
      LONG_PRESS: Haptics.AndroidHaptics.Long_Press,
      CLOCK_TICK: Haptics.AndroidHaptics.Clock_Tick,
      REJECT: Haptics.AndroidHaptics.Reject,
      CONFIRM: Haptics.AndroidHaptics.Confirm,
    };
    await Haptics.performAndroidHapticsAsync(types[pattern.android]);
  } else if (policy.platform === 'ios') {
    if (pattern.ios === 'selection') await Haptics.selectionAsync();
    else if (pattern.ios === 'impactOccurred(.light)')
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    else if (pattern.ios === 'impactOccurred(.medium)')
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    else {
      const types = {
        'notificationOccurred(.warning)': Haptics.NotificationFeedbackType.Warning,
        'notificationOccurred(.success)': Haptics.NotificationFeedbackType.Success,
        'notificationOccurred(.error)': Haptics.NotificationFeedbackType.Error,
      };
      await Haptics.notificationAsync(types[pattern.ios]);
    }
  }
}
module.exports = { patternFor, playHaptic };

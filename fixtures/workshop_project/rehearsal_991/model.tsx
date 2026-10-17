import { useState } from 'react';
import { Pressable, Text, View } from 'react-native';

// Test-only executable countermodels; never copied to a delivery branch.
const mode = process.env.REHEARSAL_991_MODEL;
let previousCompletion = false;

export function StartScreen() {
  const [completed, setCompleted] = useState(
    mode === 'premature' || (mode === 'sticky' && previousCompletion),
  );
  function press() {
    if (mode === 'noop') return;
    previousCompletion = true;
    setCompleted(true);
  }
  return (
    <View testID="start-screen">
      <Pressable accessibilityRole="button" onPress={press} testID="rehearsal-start">
        <Text>Prüfung starten</Text>
      </Pressable>
      {completed && <Text>Prüfung abgeschlossen</Text>}
    </View>
  );
}

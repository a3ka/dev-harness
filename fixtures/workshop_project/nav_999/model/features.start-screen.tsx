// Эталон 999: миграция каркаса 991 на токены D2.2.5.1 (STRUCTURE.md §6:
// миграция literal styles входит в CMP-MOB-002). Поведение и тест-семантика
// 991 (rehearsal/start-screen RNTL) сохранены дословно; палитра — из theme/.
import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../theme/context';

export function StartScreen() {
  const [completed, setCompleted] = useState(false);
  const { tokens } = useTheme();
  return (
    <SafeAreaView style={[styles.safeArea, { backgroundColor: tokens.ground }]}>
      <View style={styles.content} testID="start-screen">
        <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
          Complior
        </Text>
        <Text style={[styles.subtitle, { color: tokens.ink }]}>Mobile — Grundgerüst</Text>
        <Pressable
          accessibilityRole="button"
          onPress={() => setCompleted(true)}
          style={[styles.button, { backgroundColor: tokens.primary }]}
          testID="rehearsal-start"
        >
          <Text style={[styles.buttonText, { color: tokens['on-primary'] }]}>Prüfung starten</Text>
        </Pressable>
        {completed && <Text style={[styles.completion, { color: tokens.ink }]}>Prüfung abgeschlossen</Text>}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingHorizontal: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: '600',
  },
  subtitle: {
    fontSize: 16,
  },
  button: {
    marginTop: 16,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
  },
  buttonText: {
    fontSize: 16,
  },
  completion: {
    fontSize: 16,
  },
});

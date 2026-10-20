// 111 (CMP-MOB-005): First-Run по D2.2.5.1 — бренд-презентация перед F03.01
// (First-Run.png / First-Run.html): wordmark, promise (ui.first_run.promise),
// CTA «Anmelden oder Konto erstellen» (ui.first_run.enter_f03). Палитра —
// ТОЛЬКО токены theme/ (проекция D2.2.5.1), литеральных hex-цветов нет;
// safe-area — настоящий react-native-safe-area-context (прецедент tab-shell,
// start-screen). Экран не знает навигации/транспорта: вход в F03.01 — порт
// onEnter (F03.A01); testID first-run-continue сохранён — замороженная семья
// 995 и Maestro start/rehearsal ждут его на «/» и не переписываются.
import React from 'react';
import { Image, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { uiCopyDe } from '@/i18n/ui-copy';
import { useTheme } from '@/theme/context';
import { Button } from '@/ui/button';

export interface FirstRunScreenProps {
  readonly onEnter: () => void;
  readonly testID?: string;
}

export function FirstRunScreen({ onEnter, testID }: FirstRunScreenProps) {
  const { tokens } = useTheme();
  return (
    <SafeAreaView
      style={[styles.safe, { backgroundColor: tokens.ground }]}
      testID={testID ?? 'first-run-safe-area'}
    >
      <Image
        accessibilityLabel="complior"
        accessibilityRole="image"
        source={require('../../../assets/images/wordmark-dark.png')}
        style={styles.wordmark}
        testID="first-run-wordmark"
      />
      <Text style={[styles.promise, { color: tokens.ink }]} testID="first-run-promise">
        {uiCopyDe['ui.first_run.promise'].text}
      </Text>
      <Button
        label={uiCopyDe['ui.first_run.enter_f03'].text}
        onPress={onEnter}
        testID="first-run-continue"
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  wordmark: { height: 22, marginTop: 20, resizeMode: 'contain' },
  promise: {
    fontSize: 28,
    fontWeight: '500',
    lineHeight: 32,
    marginTop: 32,
    paddingHorizontal: 16,
    textAlign: 'center',
  },
});

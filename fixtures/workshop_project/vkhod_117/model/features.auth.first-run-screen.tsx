// 117 v2 (эталон architect): First-Run по First-Run.png / First-Run.html
// (артборд 390×844, класс p-astage is-stage-1): сверху по центру wordmark
// (высота 22, ink схемы через tintColor — растр wordmark-dark.png 111 тот же,
// в светлой схеме перекрашен в ink светлой схемы), крупный знак канона (растр
// splash-sign-<схема>.png — тот же файл, что судит SPLASH_SIGN_RASTER;
// 181×173 — ширина знака артборда), заголовок ui.first_run.promise (.title,
// ink), подзаголовок артборда (.body-sm, ink-muted), CTA ui.first_run.enter_f03
// — Button primary size lg во всю ширину с полями 16 внизу кадра, под ней
// футер «Versicherung. Erledigt.» (.caption, ink-muted). Палитра — только
// токены схемы; testID 111/995 сохранены.
import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { uiCopyDe } from '@/i18n/ui-copy';
import { useTheme } from '@/theme/context';
import { Button } from '@/ui/button';

// Тексты артборда без ключа каталога (meta copy-keys First-Run.html несёт
// только promise и enter_f03): подзаголовок — литерал артборда (вопрос
// владельцу, копия-синька CMP-MOB-089); футер — brand asset brand.tagline.
const FIRST_RUN_SUBLINE =
  'Ein Brief, ein Schaden, ein neues Auto – sagen Sie es. Complior liest, erklärt, vergleicht und erledigt. Sie bestätigen nur, was wirklich zählt.';
const BRAND_TAGLINE = 'Versicherung. Erledigt.';

const SIGN = {
  dark: require('../../../assets/images/splash-sign-dark.png'),
  light: require('../../../assets/images/splash-sign-light.png'),
} as const;

export interface FirstRunScreenProps {
  readonly onEnter: () => void;
  readonly testID?: string;
}

export function FirstRunScreen({ onEnter, testID }: FirstRunScreenProps) {
  const { scheme, tokens } = useTheme();
  return (
    <SafeAreaView
      style={[styles.safe, { backgroundColor: tokens.ground }]}
      testID={testID ?? 'first-run-safe-area'}
    >
      <View style={styles.top}>
        <Image
          accessibilityLabel="complior"
          accessibilityRole="image"
          source={require('../../../assets/images/wordmark-dark.png')}
          style={[styles.wordmark, { tintColor: tokens.ink }]}
          testID="first-run-wordmark"
        />
      </View>
      <View style={styles.presence}>
        <Image
          accessibilityElementsHidden
          importantForAccessibility="no"
          source={SIGN[scheme]}
          style={styles.sign}
          testID="first-run-sign"
        />
      </View>
      <View style={styles.work}>
        <Text style={[styles.promise, { color: tokens.ink }]} testID="first-run-promise">
          {uiCopyDe['ui.first_run.promise'].text}
        </Text>
        <Text style={[styles.subline, { color: tokens['ink-muted'] }]} testID="first-run-subline">
          {FIRST_RUN_SUBLINE}
        </Text>
      </View>
      <View style={styles.actions}>
        <Button
          block
          label={uiCopyDe['ui.first_run.enter_f03'].text}
          onPress={onEnter}
          size="lg"
          testID="first-run-continue"
        />
        <Text style={[styles.tagline, { color: tokens['ink-muted'] }]} testID="first-run-tagline">
          {BRAND_TAGLINE}
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  top: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 60,
    paddingHorizontal: 16,
    paddingTop: 20,
  },
  wordmark: {
    height: 22,
    aspectRatio: 143 / 52.08,
    resizeMode: 'contain',
  },
  presence: {
    alignItems: 'center',
    flexBasis: '36%',
    justifyContent: 'center',
    paddingBottom: 16,
    paddingHorizontal: 16,
    paddingTop: 24,
  },
  sign: { height: 173, width: 181 },
  work: {
    flex: 1,
    paddingBottom: 16,
    paddingHorizontal: 16,
  },
  promise: {
    fontSize: 28,
    fontWeight: '500',
    lineHeight: 32,
    textAlign: 'center',
  },
  subline: {
    fontSize: 15,
    fontWeight: '400',
    lineHeight: 20,
    marginTop: 8,
    textAlign: 'center',
  },
  actions: {
    gap: 8,
    paddingBottom: 16,
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  tagline: {
    fontSize: 13,
    fontWeight: '500',
    lineHeight: 18,
    marginTop: 8,
    textAlign: 'center',
  },
});

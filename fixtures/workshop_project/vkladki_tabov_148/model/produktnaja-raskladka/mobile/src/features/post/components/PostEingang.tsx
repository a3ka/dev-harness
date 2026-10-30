// 148 vkladki-tabov (GA-04): контент вкладки Post — фильтры
// Alle/Eingegangen/Gesendet (каталог ui.post.filter.*), действие «An
// Complior schicken» (ui.post.send_to_complior) и список сообщений
// (данные мока, как заголовки Vorgänge). Прокручивается под
// таб-лейсте (GA-09); касания ≥ 44 pt (правило проходимости 132).
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { uiCopyDe } from '../../../i18n/ui-copy';
import { useTheme } from '../../../theme/context';

export interface PostEingangProps {
  readonly filtr?: 'all' | 'received' | 'sent';
  readonly onFiltr?: (filtr: 'all' | 'received' | 'sent') => void;
  readonly onNachricht?: (id: string) => void;
  readonly onSchicken?: () => void;
}

const FILTR_KEYS: Readonly<Record<'all' | 'received' | 'sent', string>> = {
  all: 'ui.post.filter.all',
  received: 'ui.post.filter.received',
  sent: 'ui.post.filter.sent',
};

const SOOBSCHENIJA: readonly { id: string; titel: string; meta: string }[] = [
  { id: 'post-soobschenie-rechtsschutz', titel: 'Rechtsschutz', meta: 'gesendet von Complior' },
];

export function PostEingang({ filtr = 'all', onFiltr, onNachricht, onSchicken }: PostEingangProps) {
  const { tokens } = useTheme();
  return (
    <ScrollView contentContainerStyle={styles.spisok} testID="post-spisok">
      {/* Заголовок вкладки по макету GA-04: имя вкладки из каталога. */}
      <Text accessibilityRole="header" style={[styles.zagolovok, { color: tokens.ink }]}>
        {uiCopyDe['ia115.nav.POST'].text}
      </Text>
      <View style={styles.chipy} testID="post-filtry">
        {(Object.keys(FILTR_KEYS) as ('all' | 'received' | 'sent')[]).map((f) => (
          <Pressable
            key={f}
            accessibilityRole="button"
            accessibilityState={{ selected: filtr === f }}
            onPress={() => onFiltr?.(f)}
            style={[styles.chip, filtr === f && styles.chipVybrana]}
            testID={`post-filtr-${f === 'all' ? 'alle' : f === 'received' ? 'vhodjaschie' : 'otpravlennye'}`}
          >
            <Text style={[styles.chipText, { color: tokens.ink }]}>
              {uiCopyDe[FILTR_KEYS[f]].text}
            </Text>
          </Pressable>
        ))}
      </View>
      <Pressable
        accessibilityRole="button"
        onPress={onSchicken}
        style={styles.dejstvie}
        testID="post-napisat-complior"
      >
        <Text style={[styles.dejstvieText, { color: tokens['on-card'] }]}>
          {uiCopyDe['ui.post.send_to_complior'].text}
        </Text>
      </Pressable>
      {SOOBSCHENIJA.map((s) => (
        <Pressable
          key={s.id}
          accessibilityRole="button"
          onPress={() => onNachricht?.(s.id)}
          style={styles.soobschenie}
          testID={s.id}
        >
          <Text style={[styles.soobschenieTitel, { color: tokens.ink }]}>{s.titel}</Text>
          <Text style={[styles.soobschenieMeta, { color: tokens.ink }]}>{s.meta}</Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  spisok: { gap: 8, paddingBottom: 96 },
  zagolovok: { fontSize: 24, fontWeight: '600' },
  chipy: { flexDirection: 'row', gap: 4 },
  chip: { alignItems: 'center', justifyContent: 'center', minHeight: 44, paddingHorizontal: 12 },
  chipVybrana: { opacity: 1 },
  chipText: { fontSize: 14, fontWeight: '600' },
  dejstvie: { alignItems: 'center', justifyContent: 'center', minHeight: 44 },
  dejstvieText: { fontSize: 15, fontWeight: '600' },
  soobschenie: { justifyContent: 'center', minHeight: 44 },
  soobschenieTitel: { fontSize: 15, fontWeight: '600' },
  soobschenieMeta: { fontSize: 13 },
});

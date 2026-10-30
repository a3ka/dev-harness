// 148 vkladki-tabov (GA-02/GA-09): контент вкладки Vorgänge — список
// Vorgänge по группам «In Arbeit» / «Warten auf Antwort» и хвост «Alle
// erledigten Vorgänge». Прокручивается ПОД таб-лейсте (GA-09 «die
// Tab-Leiste bleibt, der Inhalt läuft darunter» — оверлей в TabShell);
// строки — касание ≥ 44 pt высотой строки (правило проходимости 132:
// визуальная строка 26 pt, цель касания — строка целиком). Заголовок
// вкладки — имя вкладки + подзаголовок (каталог ui-copy); данные —
// UI-фикстура model/vkladki-dannye (SYNTHETIC).
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';
import { uiCopyDe } from '../../../i18n/ui-copy';
import { ThemeContext } from '../../../theme/context';
import { VORGAENGE_SPISENOK, type VorgangGruppa, type VorgangRow } from '../model/vkladki-dannye';

const GROUP_KEYS: Readonly<Record<VorgangGruppa, string>> = {
  working: 'ui.vorgaenge.group.working',
  waiting: 'ui.vorgaenge.group.waiting',
};

const GRUPPY: readonly VorgangGruppa[] = ['working', 'waiting'];

export interface VorgaengeListeProps {
  readonly vorgaenge?: readonly VorgangRow[];
  readonly onVorgang?: (id: string) => void;
  readonly onAlleErledigte?: () => void;
}

export function VorgaengeListe({
  vorgaenge = VORGAENGE_SPISENOK,
  onVorgang,
  onAlleErledigte,
}: VorgaengeListeProps) {
  return (
    <ThemeContext.Consumer>
      {({ tokens }) => (
        <ScrollView contentContainerStyle={styles.spisok} testID="vorgaenge-spisok">
          {/* Заголовок вкладки по макету GA-02: имя вкладки (каталог
              ia117.nav.VORGAENGE) + подзаголовок ui.vorgaenge.subtitle. */}
          <Text accessibilityRole="header" style={[styles.zagolovok, { color: tokens.ink }]}>
            {uiCopyDe['ia117.nav.VORGAENGE'].text}
          </Text>
          <Text style={[styles.podzagolovok, { color: tokens.ink }]}>
            {uiCopyDe['ui.vorgaenge.subtitle'].text}
          </Text>
          {GRUPPY.map((gruppa) => (
            <React.Fragment key={gruppa}>
              <Text
                accessibilityRole="header"
                style={[styles.gruppa, { color: tokens.ink }]}
                testID={`vorgaenge-gruppa-${gruppa}`}
              >
                {uiCopyDe[GROUP_KEYS[gruppa]].text}
              </Text>
              {vorgaenge
                .filter((v) => v.group === gruppa)
                .map((v) => (
                  <Pressable
                    key={v.id}
                    accessibilityRole="button"
                    onPress={() => onVorgang?.(v.id)}
                    style={styles.stroka}
                    testID={v.id}
                  >
                    <Text style={[styles.strokaText, { color: tokens.ink }]}>{v.title}</Text>
                  </Pressable>
                ))}
            </React.Fragment>
          ))}
          <Pressable
            accessibilityRole="button"
            onPress={onAlleErledigte}
            style={styles.hvost}
            testID="vorgaenge-vse-sdelannye"
          >
            <Text style={[styles.hvostText, { color: tokens.ink }]}>
              {uiCopyDe['ui.mission.all_done'].text}
            </Text>
          </Pressable>
        </ScrollView>
      )}
    </ThemeContext.Consumer>
  );
}

const styles = StyleSheet.create({
  spisok: { gap: 8, paddingBottom: 96 },
  zagolovok: { fontSize: 24, fontWeight: '600' },
  podzagolovok: { fontSize: 13, marginBottom: 4 },
  gruppa: { fontSize: 17, fontWeight: '600', marginTop: 8 },
  stroka: { minHeight: 44, justifyContent: 'center' },
  strokaText: { fontSize: 15 },
  hvost: { alignItems: 'center', justifyContent: 'center', minHeight: 44, marginTop: 8 },
  hvostText: { fontSize: 15, fontWeight: '600' },
});

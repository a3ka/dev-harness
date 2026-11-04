// 148 vkladki-tabov (GA-03), v+1 — пакет D24-Kompakt-1.1: контент
// вкладки Schutz — сводка защиты: заголовок вкладки (ia115.nav.SCHUTZ),
// карточки сводки «Verträge»/«Beitrag / Monat» (proposed.schutz.stat.*),
// Notice «Lücke: Berufsunfähigkeit …» с действием «Optionen ansehen»
// (proposed.protection.status.gap, fixture.schutz.02,
// proposed.schutz.gap.action — каталогизированы пакетом 1.1, маска
// кадра снята: зона судится сверкой), раздел «Bereiche»
// (proposed.schutz.section.areas) и пять строк областей (данные мока).
// Прокручивается под таб-лейсте (GA-09); касания — зоны hw/hh ≥ 44
// (манифест 1.1; видимые рамки меньше — расширение невидимо).
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { uiCopyDe } from '../../../i18n/ui-copy';
import { useTheme } from '../../../theme/context';

export interface SchutzUebersichtProps {
  readonly onBereich?: (bereich: string) => void;
}

const BEREICHE: readonly { id: string; titel: string; podtitel: string; status: string }[] = [
  { id: 'mobilitaet', titel: 'Mobilität', podtitel: 'Kfz-Versicherung · Vollkasko', status: 'Bestätigt' },
  { id: 'wohnen', titel: 'Wohnen', podtitel: 'Hausrat · Haftpflicht', status: 'Bestätigt' },
  { id: 'gesundheit', titel: 'Gesundheit', podtitel: 'Berufsunfähigkeit', status: 'Lücke' },
  { id: 'recht', titel: 'Recht', podtitel: 'Kein Vertrag bekannt', status: 'Unklar' },
  { id: 'familie', titel: 'Familie', podtitel: 'Noch nicht besprochen', status: 'Unklar' },
];

export function SchutzUebersicht({ onBereich }: SchutzUebersichtProps) {
  const { tokens } = useTheme();
  return (
    <ScrollView contentContainerStyle={styles.spisok} testID="schutz-spisok">
      {/* Заголовок вкладки по макету GA-03: имя вкладки из каталога. */}
      <Text accessibilityRole="header" style={[styles.zagolovok, { color: tokens.ink }]}>
        {uiCopyDe['ia115.nav.SCHUTZ'].text}
      </Text>
      <Pressable
        accessibilityRole="button"
        onPress={() => onBereich?.('svod')}
        style={styles.kartochka}
        testID="schutz-svod"
      >
        <Text style={[styles.kartochkaTitel, { color: tokens.ink }]}>
          {uiCopyDe['proposed.schutz.section.areas'].text}
        </Text>
      </Pressable>
      <View style={styles.statRjad}>
        <Pressable
          accessibilityRole="button"
          onPress={() => onBereich?.('vertraege')}
          style={styles.statKartochka}
          testID="schutz-stat-vertraege"
        >
          <Text style={[styles.statTitel, { color: tokens.ink }]}>
            {uiCopyDe['proposed.schutz.stat.contracts'].text}
          </Text>
        </Pressable>
        <Pressable
          accessibilityRole="button"
          onPress={() => onBereich?.('beitrag')}
          style={styles.statKartochka}
          testID="schutz-stat-beitrag"
        >
          <Text style={[styles.statTitel, { color: tokens.ink }]}>
            {uiCopyDe['proposed.schutz.stat.premium'].text}
          </Text>
        </Pressable>
      </View>
      {/* Notice (v+1): ключи каталога 1.1, зона судится сверкой кадра. */}
      <View style={styles.notice} testID="schutz-notice">
        <Text style={[styles.noticeTitel, { color: tokens.ink }]}>
          {uiCopyDe['proposed.protection.status.gap'].text}
        </Text>
        <Text style={[styles.noticeTekst, { color: tokens.ink }]}>
          {uiCopyDe['fixture.schutz.02'].text}
        </Text>
        <Pressable
          accessibilityRole="button"
          onPress={() => onBereich?.('optionen')}
          style={styles.noticeKnopka}
          testID="schutz-optionen"
        >
          <Text style={[styles.noticeKnopkaTekst, { color: tokens.ink }]}>
            {uiCopyDe['proposed.schutz.gap.action'].text}
          </Text>
        </Pressable>
      </View>
      {BEREICHE.map((b) => (
        <Pressable
          key={b.id}
          accessibilityRole="button"
          onPress={() => onBereich?.(b.id)}
          style={styles.stroka}
          testID={`schutz-oblast-${b.id}`}
        >
          <Text style={[styles.strokaTitel, { color: tokens.ink }]}>{b.titel}</Text>
          <Text style={[styles.strokaPodtitel, { color: tokens.ink }]}>
            {b.podtitel} · {b.status}
          </Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  spisok: { gap: 8, paddingBottom: 96 },
  zagolovok: { fontSize: 24, fontWeight: '600' },
  kartochka: { justifyContent: 'center', minHeight: 54 },
  kartochkaTitel: { fontSize: 17, fontWeight: '600' },
  statRjad: { flexDirection: 'row', gap: 12 },
  statKartochka: { flex: 1, justifyContent: 'center', minHeight: 112 },
  statTitel: { fontSize: 15, fontWeight: '600' },
  notice: { gap: 6, paddingBottom: 4 },
  noticeTitel: { fontSize: 15, fontWeight: '600' },
  noticeTekst: { fontSize: 13 },
  noticeKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 },
  noticeKnopkaTekst: { fontSize: 15, fontWeight: '600' },
  stroka: { justifyContent: 'center', minHeight: 54 },
  strokaTitel: { fontSize: 15, fontWeight: '600' },
  strokaPodtitel: { fontSize: 13 },
});

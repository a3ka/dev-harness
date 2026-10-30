// 148 vkladki-tabov (GA-03): контент вкладки Schutz — сводка защиты:
// заголовок вкладки по макету (ia115.nav.SCHUTZ), строки областей
// (Mobilität/Wohnen — данные мока, как заголовки Vorgänge) и карточки
// сводки. Прокручивается под таб-лейсте (GA-09); касание строк ≥ 44 pt.
// ВНИМАНИЕ (копи-пробел, замер пачки 148): тексты Notice «Lücke:
// Berufsunfähigkeit …» и его действия «Optionen ansehen» не имеют
// ключа ни в BrokerOS_UI_Copy_DE, ни в proposed-копии D 2.4 — зона
// уведомления НЕ реализуется до каталогизации (кадр GA-03 судит
// сверка; зона объявлена в контракте 148 §НЕ ЗАЩИЩАЕТ, вопрос копии —
// владельцу через оркестратора).
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';
import { uiCopyDe } from '../../../i18n/ui-copy';
import { useTheme } from '../../../theme/context';

export interface SchutzUebersichtProps {
  readonly onBereich?: (bereich: string) => void;
}

const BEREICHE: readonly { id: string; titel: string; podtitel: string }[] = [
  { id: 'mobilitaet', titel: 'Mobilität', podtitel: 'Kfz-Versicherung · Vollkasko' },
  { id: 'wohnen', titel: 'Wohnen', podtitel: 'Hausrat · Haftpflicht' },
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
        onPress={() => onBereich?.('vertraege')}
        style={styles.kartochka}
        testID="schutz-kartochka-vertraege"
      >
        <Text style={[styles.kartochkaTitel, { color: tokens.ink }]}>
          {uiCopyDe['frame.F19.01.title'].text}
        </Text>
      </Pressable>
      {BEREICHE.map((b) => (
        <Pressable
          key={b.id}
          accessibilityRole="button"
          onPress={() => onBereich?.(b.id)}
          style={styles.stroka}
          testID={`schutz-stroka-${b.id}`}
        >
          <Text style={[styles.strokaTitel, { color: tokens.ink }]}>{b.titel}</Text>
          <Text style={[styles.strokaPodtitel, { color: tokens.ink }]}>{b.podtitel}</Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  spisok: { gap: 8, paddingBottom: 96 },
  zagolovok: { fontSize: 24, fontWeight: '600' },
  kartochka: { justifyContent: 'center', minHeight: 56 },
  kartochkaTitel: { fontSize: 17, fontWeight: '600' },
  stroka: { justifyContent: 'center', minHeight: 44 },
  strokaTitel: { fontSize: 15, fontWeight: '600' },
  strokaPodtitel: { fontSize: 13 },
});

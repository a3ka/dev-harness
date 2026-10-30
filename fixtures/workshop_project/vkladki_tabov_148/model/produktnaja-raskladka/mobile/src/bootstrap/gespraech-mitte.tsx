// 148 vkladki-tabov (D 2.4): центральная кнопка «Gespräch» (Mitte) для
// таб-бара TabShell — слот `mitte` между вкладками vorgaenge и schutz
// (GA-02/03/04/09). Знак — FadenSign tiers «tab» 28 px (движок 145,
// mobile/src/lib/faden); статус Mitte — «In Arbeit» (GA-02/04/09) либо
// бейдж «Ihre Rückmeldung nötig» (GA-03), ключи каталога slice-1
// ui.vorgaenge.group.working / needs_you; a11y-имя — база
// proposed.gespraech.tab.a11y + статус. Роль — button, НЕ tab-роль
// (замороженная грамматика 999 держит роль вкладки ровно для четырёх
// канонических секций TAB_ORDER; Mitte — кнопка действия): до контракта
// меню 147 нажатие даёт видимый отклик — переключение статуса/бейджа
// (мок-цель по zamenjaet, нарезка D 2.4).
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { FadenSign } from '../lib/faden/FadenSign';
import { uiCopyDe } from '../i18n/ui-copy';

/** Состояние Mitte: рабочая фаза знака (GA-02/04/09) или «нужен ответ»
 * (GA-03, бейдж). Отображается на состоянии знака 145 и статусном
 * тексте; алфавит замкнут грамматикой состояний знака. */
export type GespraechMitteStatus = 'working' | 'needs_action';

export interface GespraechMitteProps {
  readonly status?: GespraechMitteStatus;
  readonly reducedMotion?: boolean;
  readonly theme?: string;
  readonly onPress?: () => void;
}

const STATUS_KEYS: Readonly<Record<GespraechMitteStatus, string>> = {
  working: 'ui.vorgaenge.group.working',
  needs_action: 'ui.vorgaenge.group.needs_you',
};

export function GespraechMitte({
  status = 'working',
  reducedMotion,
  theme,
  onPress,
}: GespraechMitteProps) {
  const statusText = uiCopyDe[STATUS_KEYS[status]].text;
  const baseA11y = uiCopyDe['proposed.gespraech.tab.a11y'].text;
  return (
    <Pressable
      accessibilityLabel={`${baseA11y} – ${statusText}`}
      accessibilityRole="button"
      onPress={onPress}
      style={styles.mitte}
      testID="gespraech-mitte"
    >
      {status === 'needs_action' ? (
        <View style={styles.badgeWrap}>
          <Text style={styles.badgeText} testID="gespraech-mitte-badge">
            {statusText}
          </Text>
        </View>
      ) : null}
      <FadenSign
        forceReducedMotion={reducedMotion}
        size="tab"
        state={status}
        theme={theme}
      />
      <Text style={styles.label} testID="gespraech-mitte-label">
        {uiCopyDe['proposed.gespraech.tab'].text}
      </Text>
      {status === 'working' ? (
        <Text style={styles.status} testID="gespraech-mitte-status">
          {statusText}
        </Text>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  mitte: {
    alignItems: 'center',
    gap: 2,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  badgeWrap: {
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  badgeText: { fontSize: 10 },
  label: { fontSize: 12 },
  status: { fontSize: 10 },
});

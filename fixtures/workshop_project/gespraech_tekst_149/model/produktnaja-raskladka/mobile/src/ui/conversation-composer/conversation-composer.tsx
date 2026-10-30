// Композер разговора (контракт 149, референс-раскладка; зона
// mobile/src/ui/conversation-composer/, база 108 CMP-MOB-004).
//
// Поверхность 108 (ConversationComposer для Start F04.07) сохранена
// БАЙТ В БАЙТ (замороженные пробы 108 не трогаются, контракт 149
// §Пересечения); правка этого контракта — ДОБАВЛЕНИЕ ChatComposer
// (CHANGELOG D 2.4 «Помещается всегда»): поле растёт до ШЕСТИ строк и
// прокручивается (потолок/рост/прокрутка — интерфейс машины
// chat-machine.ts: poleStrokMaksimum/poleRastjot/poleSkrolluet,
// единственный источник числа), микрофон primary — видимая кнопка
// голоса в поле, «+» вложения и «Nachricht senden» появляется с
// текстом. testID — грамматика проходимости пачки (gespraech-*).
import React, { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import { createChatMachine } from '../../features/conversation/chat-machine';
import { katalogKopii } from '../../features/conversation/chat-kopija';
import { uiCopyDe } from '../../i18n/ui-copy';
import { useTheme } from '../../theme/context';

export interface ConversationComposerProps {
  readonly onFocusInput?: () => void;
  readonly testID?: string;
  /** Контролируемое значение черновика (composition root). */
  readonly value?: string;
  /** Изменение черновика через контролируемый порт. */
  readonly onChangeText?: (next: string) => void;
}

export function ConversationComposer({
  onFocusInput,
  testID = 'start-composer',
  value,
  onChangeText,
}: ConversationComposerProps) {
  const { tokens } = useTheme();
  const [internalDraft, setInternalDraft] = useState('');
  const controlled = value !== undefined && onChangeText !== undefined;
  const draft = controlled ? (value as string) : internalDraft;
  const handleChange = (next: string) => {
    if (controlled) {
      (onChangeText as (next: string) => void)(next);
    } else {
      setInternalDraft(next);
    }
  };
  return (
    <View testID={testID} style={[styles.composer, { borderColor: tokens.panel }]}>
      <Text style={[styles.label, { color: tokens.ink }]}>{uiCopyDe['frame.F04.07.title'].text}</Text>
      <Text style={[styles.hint, { color: tokens.ink }]}>{uiCopyDe['frame.F04.07.body'].text}</Text>
      <TextInput
        accessibilityLabel={uiCopyDe['action.F04.A01'].text}
        onChangeText={handleChange}
        onFocus={onFocusInput}
        style={[styles.input, { borderColor: tokens.ink, color: tokens.ink }]}
        testID="start-composer-input"
        value={draft}
      />
    </View>
  );
}

// --- ChatComposer (контракт 149, GA-13/17) --------------------------------

// Структурная константа потолка — из машины (И-4); токены движения для
// потолка не читаются, передаются нулевые.
const mashina = createChatMachine(
  { motionFast: 0, motionBase: 0, motionMorph: 0 });
const STROK_MAKSIMUM = mashina.poleStrokMaksimum();
const VYSOTA_STROKI = 20;

export interface ChatComposerProps {
  /** Черновик (контролируемый порт композиции, прецедент 108 круг 2). */
  readonly value?: string;
  readonly onChangeText?: (next: string) => void;
  /** Кнопка голоса в поле (микрофон primary, GA-13). */
  readonly onGolos?: () => void;
  /** Вложения Foto/Brief-Dokument (GA-18/19). */
  readonly onVlozhit?: () => void;
  /** Отправка — доступна только с текстом. */
  readonly onOtpravit?: (tekst: string) => void;
  readonly testID?: string;
}

export function ChatComposer({
  value,
  onChangeText,
  onGolos,
  onVlozhit,
  onOtpravit,
  testID = 'gespraech-kompozer',
}: ChatComposerProps) {
  const { tokens } = useTheme();
  const [internal, setInternal] = useState('');
  const upravlyaemyj = value !== undefined && onChangeText !== undefined;
  const draft = upravlyaemyj ? (value as string) : internal;
  const stavi = (next: string) => {
    if (upravlyaemyj) {
      (onChangeText as (n: string) => void)(next);
    } else {
      setInternal(next);
    }
  };
  // строки черновика: рост до потолка включительно, за потолком —
  // фиксированная высота и прокрутка (машина, единственный источник)
  const stroki = draft === '' ? 1 : draft.split('\n').length;
  const skrolluet = mashina.poleSkrolluet(stroki);
  const pole = (
    <TextInput
      accessibilityLabel={katalogKopii['action.F04.A01'].text}
      multiline
      onChangeText={stavi}
      style={[
        styles.pole,
        { borderColor: tokens.ink, color: tokens.ink },
        { minHeight: Math.min(stroki, STROK_MAKSIMUM) * VYSOTA_STROKI },
        { maxHeight: STROK_MAKSIMUM * VYSOTA_STROKI },
      ]}
      testID="gespraech-pole"
      value={draft}
    />
  );
  return (
    <View testID={testID} style={[styles.kompozer, { borderColor: tokens.panel }]}>
      <Pressable
        accessibilityLabel={katalogKopii['action.F05.A02'].text}
        accessibilityRole="button"
        onPress={onVlozhit}
        style={({ pressed }) => [
          styles.knopka, { opacity: pressed ? 0.7 : 1 },
        ]}
        testID="gespraech-vlozhit"
      >
        <Text style={{ color: tokens.ink }}>+</Text>
      </Pressable>
      {skrolluet ? (
        <ScrollView
          nestedScrollEnabled
          scrollEnabled
          style={styles.skroll}
          testID="gespraech-pole-skroll"
        >
          {pole}
        </ScrollView>
      ) : (
        <View style={styles.pole_obolochka} testID="gespraech-pole-obolochka">
          {pole}
        </View>
      )}
      <Pressable
        accessibilityLabel={katalogKopii['ia115.entry.speak'].text}
        accessibilityRole="button"
        onPress={onGolos}
        style={({ pressed }) => [
          styles.knopka, styles.knopka_golosa, { opacity: pressed ? 0.7 : 1 },
        ]}
        testID="gespraech-mikrofon"
      >
        <Text style={{ color: tokens.ink }}>
          {katalogKopii['ia115.entry.speak'].text}
        </Text>
      </Pressable>
      {draft !== '' ? (
        <Pressable
          accessibilityLabel={katalogKopii['action.F05.A01'].text}
          accessibilityRole="button"
          onPress={() => onOtpravit?.(draft)}
          style={({ pressed }) => [
            styles.knopka, { opacity: pressed ? 0.7 : 1 },
          ]}
          testID="gespraech-otpravit"
        >
          <Text style={{ color: tokens.ink }}>
            {katalogKopii['action.F05.A01'].text}
          </Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  composer: { borderRadius: 12, borderWidth: 1, gap: 8, padding: 12 },
  label: { fontSize: 14, fontWeight: '600' },
  hint: { fontSize: 12 },
  input: { borderWidth: 1, borderRadius: 8, minHeight: 40, paddingHorizontal: 8 },
  kompozer: {
    borderRadius: 12,
    borderWidth: 1,
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: 8,
    padding: 8,
  },
  pole: { borderRadius: 8, borderWidth: 1, flex: 1, paddingHorizontal: 8 },
  pole_obolochka: { flex: 1 },
  skroll: { flex: 1 },
  knopka: {
    alignItems: 'center',
    borderRadius: 8,
    justifyContent: 'center',
    minHeight: 44,
    minWidth: 44,
    paddingHorizontal: 8,
  },
  knopka_golosa: { borderWidth: 1 },
});

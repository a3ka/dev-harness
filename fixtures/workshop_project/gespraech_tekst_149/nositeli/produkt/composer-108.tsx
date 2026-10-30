// CMP-MOB-004: ConversationComposer (ui/conversation-composer). Единый
// композер Start (F04.07): один ввод, черновик живёт в состоянии и НЕ
// теряется при смене окружающих пропсов (Maestro: написать → вернуться →
// продолжить; mission_id и черновик сохранены). Каналы не создают
// конкурирующую Mission: композер только держит текст, отправка —
// navigate F05.01 через onWrite.
//
// CMP-MOB-004 (108, круг 2): поднятие черновика выше слота start —
// composition root пробрасывает контролируемое `value`/`onChangeText`.
// Когда оба заданы — режим controlled; при отсутствии хотя бы одного —
// внутренний useState (обратная совместимость: проба 108 не нарушает
// неизменную форму StartScreen).
import React, { useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';

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

const styles = StyleSheet.create({
  composer: { borderRadius: 12, borderWidth: 1, gap: 8, padding: 12 },
  label: { fontSize: 14, fontWeight: '600' },
  hint: { fontSize: 12 },
  input: { borderWidth: 1, borderRadius: 8, minHeight: 40, paddingHorizontal: 8 },
});

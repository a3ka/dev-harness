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
//
// CMP-MOB-005 (116): порты действий F05.A01/A02/A03 — ОПЦИОНАЛЬНЫЕ.
// Без них композер байт-в-байт поверхность 108 (семья start_108 зелена
// без правок). С ними: «Nachricht senden» (onSend), «Dokument hinzufügen»
// (onAttach), «Neues Thema» (onNewTopic) — verbatim каталог; текст и
// вложения остаются в ОДНОЙ Mission, черновик не теряется ни на одном
// пути (attach/offline/новая тема), input сохраняет testID 108.
import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

import { uiCopyDe } from '../../i18n/ui-copy';
import { useTheme } from '../../theme/context';

export interface ConversationComposerProps {
  readonly onFocusInput?: () => void;
  readonly testID?: string;
  /** Контролируемое значение черновика (composition root). */
  readonly value?: string;
  /** Изменение черновика через контролируемый порт. */
  readonly onChangeText?: (next: string) => void;
  /** F05.A01 «Nachricht senden» — порт отправки (116). */
  readonly onSend?: () => void;
  /** F05.A02 «Dokument hinzufügen» — порт выбора вложения (116). */
  readonly onAttach?: () => void;
  /** F05.A03 «Neues Thema» — порт нового intent (116). */
  readonly onNewTopic?: () => void;
}

export function ConversationComposer({
  onFocusInput,
  testID = 'start-composer',
  value,
  onChangeText,
  onSend,
  onAttach,
  onNewTopic,
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
      {onSend ? (
        <Pressable
          testID="composer-send"
          onPress={onSend}
          style={[styles.action, { borderColor: tokens.panel }]}
          accessibilityRole="button"
        >
          <Text style={{ color: tokens.ink }}>{uiCopyDe['action.F05.A01'].text}</Text>
        </Pressable>
      ) : null}
      {onAttach ? (
        <Pressable
          testID="composer-attach"
          onPress={onAttach}
          style={[styles.action, { borderColor: tokens.panel }]}
          accessibilityRole="button"
        >
          <Text style={{ color: tokens.ink }}>{uiCopyDe['action.F05.A02'].text}</Text>
        </Pressable>
      ) : null}
      {onNewTopic ? (
        <Pressable
          testID="composer-new-topic"
          onPress={onNewTopic}
          style={[styles.action, { borderColor: tokens.panel }]}
          accessibilityRole="button"
        >
          <Text style={{ color: tokens.ink }}>{uiCopyDe['action.F05.A03'].text}</Text>
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
  action: { borderWidth: 1, borderRadius: 8, paddingVertical: 6, paddingHorizontal: 10, alignSelf: 'flex-start' },
});

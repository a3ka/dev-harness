// CMP-MOB-005 (116): беседа — текст и вложения в ОДНОЙ Mission без потери
// черновика. F05.01 — последний meaningful exchange в canvas; F05.02 —
// вторичная история (не основной контейнер); F05.07 — неотправленный
// черновик (queued_offline НЕ называется доставленным); attachment_pending
// НЕ называется прочитанным; already_accepted не создаёт дубль; F05.A03
// новая тема — отдельный intent БЕЗ переноса приватного контекста старой
// Mission; отозванный источник не открывается из старого exchange.
// Экран — presentation-порт: не знает транспорта; данные и эффекты
// приходят через props (composition root / on* порты).
// 116 r5 (арбитраж 0259fb00): черновик переживает ремоунт (вкладки) через
// хранилище модуля draftStore; состояния composer без PNG рендерят СВОИ
// блоки mission_* (testID по манифесту sostojanija_bez_png, className —
// токены D2.2.5.1 манифеста, текст — каталог uiCopyDe, не литералы).
import React, { useCallback, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { uiCopyDe } from '@/i18n/ui-copy';
import { useTheme } from '@/theme/context';
import { ConversationComposer } from '@/ui/conversation-composer/conversation-composer';

export type TurnSendState =
  | 'sent'
  | 'queued_offline'
  | 'interrupted'
  | 'attachment_pending'
  | 'already_accepted';

export interface ConversationTurnData {
  readonly key: string;
  readonly role: 'user' | 'agent';
  readonly text: string;
  readonly sendState?: TurnSendState;
  readonly sourceRef?: string;
  readonly sourceState?: 'available' | 'revoked';
}

export interface AttachmentView {
  readonly attachmentId: string;
  readonly name: string;
  readonly state: 'attachment_pending' | 'uploaded';
}

export interface OutgoingMessage {
  readonly mission_id: string;
  readonly client_message_id: string;
  readonly text: string;
  readonly attachment_ids: readonly string[];
}

export type SendStatus = 'accepted' | 'already_accepted' | 'queued_offline';
export type UploadStatus = 'uploaded' | 'failed';

export interface ConversationScreenProps {
  readonly missionId: string;
  readonly turns: readonly ConversationTurnData[];
  readonly responseState?: 'idle' | 'interrupted';
  readonly draftValue?: string;
  readonly draftOnChange?: (next: string) => void;
  readonly onSendMessage?: (message: OutgoingMessage) => Promise<SendStatus>;
  readonly onAttach?: () => { attachmentId: string; name: string };
  readonly onCompleteUpload?: (attachmentId: string) => Promise<UploadStatus>;
  readonly onNewTopic?: () => Promise<string>;
  readonly testID?: string;
}

// Суффикс чипа вложения из компонентов D2.2.5.1 (attachment state
// 'reading'); в каталоге BrokerOS_UI_Copy_DE строки нет — слово владельца
// для кадров без PNG.
const CHIP_LESET_SUFFIX = ' · wird gelesen';

let clientMessageSeq = 0;

// Черновик переживает контролируемый ремоунт (смена вкладки): хранилище
// модуля, а не только локальный state.
let draftStore = '';

export function ConversationScreen({
  missionId,
  turns,
  responseState = 'idle',
  draftValue,
  draftOnChange,
  onSendMessage,
  onAttach,
  onCompleteUpload,
  onNewTopic,
  testID = 'conversation',
}: ConversationScreenProps) {
  const { tokens } = useTheme();
  const [mission, setMission] = useState(missionId);
  const [localTurns, setLocalTurns] = useState<ConversationTurnData[]>([]);
  const [attachments, setAttachments] = useState<AttachmentView[]>([]);
  const [internalDraft, setInternalDraft] = useState(draftStore);
  const [draftUndelivered, setDraftUndelivered] = useState(false);
  const [acceptedNotice, setAcceptedNotice] = useState(false);
  const controlled = draftValue !== undefined && draftOnChange !== undefined;
  const draft = controlled ? (draftValue as string) : internalDraft;

  const visibleTurns = mission === missionId ? [...turns, ...localTurns] : localTurns;

  const handleDraft = useCallback(
    (next: string) => {
      draftStore = next;
      if (controlled) {
        (draftOnChange as (next: string) => void)(next);
      } else {
        setInternalDraft(next);
      }
    },
    [controlled, draftOnChange],
  );

  const handleSend = useCallback(async () => {
    if (!onSendMessage) return;
    const attachmentIds = attachments
      .filter((a) => a.state === 'uploaded')
      .map((a) => a.attachmentId);
    clientMessageSeq += 1;
    const status = await onSendMessage({
      mission_id: mission,
      client_message_id: `MSG-LOCAL-${clientMessageSeq}`,
      text: draft,
      attachment_ids: attachmentIds,
    });
    if (status === 'accepted') {
      setLocalTurns((prev) => [
        ...prev,
        { key: `local-${mission}-${clientMessageSeq}`, role: 'user', text: draft, sendState: 'sent' },
      ]);
      handleDraft('');
      setDraftUndelivered(false);
      setAcceptedNotice(false);
    } else if (status === 'already_accepted') {
      // Сообщение уже на сервере (повтор того же client_message_id):
      // дубль НЕ создаётся; черновик снят — он уже доставлен.
      handleDraft('');
      setDraftUndelivered(false);
      setAcceptedNotice(true);
    } else if (status === 'queued_offline') {
      // F05.07: черновик СОХРАНЁН и не назван доставленным.
      setDraftUndelivered(true);
    }
  }, [attachments, draft, handleDraft, mission, onSendMessage]);

  const handleAttach = useCallback(() => {
    if (!onAttach) return;
    const picked = onAttach();
    setAttachments((prev) => [
      ...prev,
      { attachmentId: picked.attachmentId, name: picked.name, state: 'attachment_pending' },
    ]);
  }, [onAttach]);

  const handleCompleteUpload = useCallback(
    async (attachmentId: string) => {
      if (!onCompleteUpload) return;
      const status = await onCompleteUpload(attachmentId);
      if (status === 'uploaded') {
        setAttachments((prev) =>
          prev.map((a) => (a.attachmentId === attachmentId ? { ...a, state: 'uploaded' } : a)),
        );
      }
      // 'failed' / незавершённый completeUpload: вложение ОСТАЁТСЯ
      // attachment_pending; повтор не создаёт вторую запись (map по id).
    },
    [onCompleteUpload],
  );

  const handleNewTopic = useCallback(async () => {
    if (!onNewTopic) return;
    const nextMission = await onNewTopic();
    setMission(nextMission);
    setLocalTurns([]);
    setAttachments([]);
    handleDraft('');
    setDraftUndelivered(false);
    setAcceptedNotice(false);
  }, [handleDraft, onNewTopic]);

  return (
    <View testID={testID} style={[styles.screen, { backgroundColor: tokens.ground }]}>
      <View testID="conversation-canvas">
        <Text style={[styles.frameTitle, { color: tokens.ink }]}>
          {uiCopyDe['frame.F05.01.title'].text}
        </Text>
        <Text style={[styles.frameBody, { color: tokens.ink }]}>
          {uiCopyDe['frame.F05.01.body'].text}
        </Text>
        <Text testID="mission-chip" style={[styles.chip, { color: tokens.ink, borderColor: tokens.panel }]}>
          {mission}
        </Text>
      </View>
      {responseState === 'interrupted' ? null : !draftUndelivered && !acceptedNotice ? (
        <View testID="mission_frame_f05_07" className="panel on-card line ink-muted">
          <Text style={{ color: tokens.ink }}>{uiCopyDe['frame.F05.07.title'].text}</Text>
          <Text style={{ color: tokens.ink }}>{uiCopyDe['frame.F05.07.body'].text}</Text>
        </View>
      ) : null}
      {draftUndelivered ? (
        <View testID="mission_queued_offline" className="warm on-warm panel">
          <Text style={{ color: tokens.ink }}>{uiCopyDe['state.G06.title'].text}</Text>
          <Pressable
            testID="mission_offline_retry"
            onPress={() => {
              void handleSend();
            }}
          >
            <Text style={{ color: tokens.ink }}>{uiCopyDe['global.retry'].text}</Text>
          </Pressable>
        </View>
      ) : null}
      {acceptedNotice ? (
        <View testID="mission_already_accepted" className="calm on-calm panel">
          <Text style={{ color: tokens.ink }}>{uiCopyDe['frame.F05.02.title'].text}</Text>
          <Pressable
            onPress={() => {
              void handleSend();
            }}
          >
            <Text style={{ color: tokens.ink }}>{uiCopyDe['action.F05.A01'].text}</Text>
          </Pressable>
        </View>
      ) : null}
      <View testID="conversation-transcript">
        <Text style={[styles.frameTitle, { color: tokens.ink }]}>
          {uiCopyDe['frame.F05.02.title'].text}
        </Text>
        {visibleTurns.map((turn) => (
          <View key={turn.key} testID="conversation-turn">
            <Text testID="turn-role" style={{ color: tokens.ink }}>
              {turn.role}
            </Text>
            <Text testID="turn-text" style={{ color: tokens.ink }}>
              {turn.text}
            </Text>
            {turn.sendState ? (
              <Text testID="turn-send-state" style={{ color: tokens.ink }}>
                {turn.sendState}
              </Text>
            ) : null}
            {turn.sourceRef ? (
              <View testID="turn-source">
                <Text testID="turn-source-ref" style={{ color: tokens.ink }}>
                  {`${turn.sourceRef}:${turn.sourceState ?? 'available'}`}
                </Text>
                {turn.sourceState !== 'revoked' ? (
                  <Pressable testID="fact-source-open" onPress={() => {}}>
                    <Text style={{ color: tokens.ink }}>
                      {uiCopyDe['frame.F05.06.body'].text}
                    </Text>
                  </Pressable>
                ) : null}
              </View>
            ) : null}
          </View>
        ))}
        {responseState === 'interrupted' ? (
          <View testID="mission_response_interrupted" className="panel ink line">
            <Text style={{ color: tokens.ink }}>{uiCopyDe['frame.F05.05.title'].text}</Text>
            <Text style={{ color: tokens.ink }}>{uiCopyDe['frame.F05.05.body'].text}</Text>
            <Text testID="response-state-token" style={{ color: tokens.ink }}>
              interrupted
            </Text>
          </View>
        ) : null}
      </View>
      <View testID="attachment-list">
        {attachments.map((a) => (
          <View key={a.attachmentId} testID="attachment-item">
            <Text testID="attachment-name" style={{ color: tokens.ink }}>
              {a.name}
            </Text>
            <Text testID="attachment-state" style={{ color: tokens.ink }}>
              {a.state}
            </Text>
            {a.state === 'attachment_pending' ? (
              <Text testID="mission_chip_wird_gelesen" style={{ color: tokens.ink }}>
                {a.name + CHIP_LESET_SUFFIX}
              </Text>
            ) : null}
            {a.state === 'attachment_pending' ? (
              <Pressable
                testID={`attachment-complete-${a.attachmentId}`}
                onPress={() => {
                  void handleCompleteUpload(a.attachmentId);
                }}
              >
                <Text style={{ color: tokens.ink }}>
                  {uiCopyDe['action.F05.A02'].text}
                </Text>
              </Pressable>
            ) : null}
          </View>
        ))}
      </View>
      <ConversationComposer
        onChangeText={handleDraft}
        value={draft}
        onNewTopic={() => {
          void handleNewTopic();
        }}
        onSend={() => {
          void handleSend();
        }}
        onAttach={handleAttach}
      />
      <Text testID="queued-offline-notice">
        {draftUndelivered ? uiCopyDe['frame.F05.07.body'].text : ''}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, gap: 12, padding: 16 },
  frameTitle: { fontSize: 16, fontWeight: '600' },
  frameBody: { fontSize: 14 },
  chip: { fontSize: 12, borderWidth: 1, borderRadius: 8, paddingHorizontal: 8, paddingVertical: 2 },
});

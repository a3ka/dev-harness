// CMP-MOB-004: Start — Personal Agent и адаптивное рабочее пространство.
// F04.01/F04.02/F04.03 — спокойное присутствие / ожидание ввода / Listening
// (UI-состояние, не wire-значение); F04.06 — продолжение той же Mission;
// F04.07 — единый ConversationComposer. Порты-инъекция по прецеденту
// tab-shell (999): экран не знает транспорта, композиция подаёт missions
// (listMissions) и состояние аватара снаружи.
//
// Правила предмета (issue #8):
//  - пустой Start показывает присутствие и ОДИН композер, не список пустых
//    групп; присутствие не заменяется списком дел; не более ОДНОЙ
//    контекстной карточки; MissionResumeBrief, не KPI-дашборд (F04.V01/V02);
//  - F04.A01/F04.A02 — client navigation без authoritative effect: нажатие
//    даёт ТОЛЬКО свой эффект; каналы не создают конкурирующую Mission;
//  - F04.A02 не запрашивает микрофон/voice session до W2/capability;
//    Listening — чистое UI-состояние (F04.03), не новый wire enum;
//  - F04.A03 открывает доступное дело из listMissions (ACL фильтрует до
//    сериализации): дело исчезло из items — прежнее содержание brief и
//    resume убраны, без остаточных приватных строк;
//  - F04.V03: unavailable показывается честно и не выглядит работающим
//    процессом, контекст (brief/черновик/действия) сохраняется;
//  - F04.V04: reduced motion сохраняет действия и устойчивые слоты карточек;
//  - новых немецких формулировок не вводится (copy signoff CMP-MOB-089).
import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { MissionBrief } from '@/api/api-client';
import { uiCopyDe } from '@/i18n/ui-copy';
import { AgentPresence, type AvatarState } from '@/ui/agent-presence/agent-presence';
import { ConversationComposer } from '@/ui/conversation-composer/conversation-composer';
import { useTheme } from '../../theme/context';

type UiState = 'CALM' | 'INPUT' | 'LISTENING';

export interface StartScreenProps {
  /** Снимок listMissions (ACL-фильтрован); null — операция недоступна. */
  readonly missions: readonly MissionBrief[] | null;
  readonly avatarState?: AvatarState;
  readonly reducedMotion?: boolean;
  readonly onWrite?: () => void;
  readonly onTalk?: () => void;
  readonly onResume?: (missionId: string) => void;
  /** Запрещённый наблюдатель: микрофон не запрашивается до W2/capability. */
  readonly onMicrophoneRequested?: () => void;
}

const FRAME_ID: Record<UiState, string> = {
  CALM: 'F04.01',
  INPUT: 'F04.02',
  LISTENING: 'F04.03',
};

const FRAME_COPY: Record<UiState, { title: string; body: string }> = {
  CALM: { title: 'frame.F04.01.title', body: 'frame.F04.01.body' },
  INPUT: { title: 'frame.F04.02.title', body: 'frame.F04.02.body' },
  LISTENING: { title: 'frame.F04.03.title', body: 'frame.F04.03.body' },
};

function StartScreenImpl({
  missions,
  avatarState = 'idle',
  reducedMotion = false,
  onWrite,
  onTalk,
  onResume,
  onMicrophoneRequested,
}: StartScreenProps) {
  const { tokens } = useTheme();
  const [uiState, setUiState] = useState<UiState>('CALM');
  const available = missions ?? [];
  const continuable = available.length > 0 ? available[0] : null;

  const write = () => {
    // F04.A01 → F05.01: только навигация; из Listening возвращаемся к тексту.
    if (uiState === 'LISTENING') setUiState('INPUT');
    onWrite?.();
  };
  const talk = () => {
    // F04.A02 → F06.01: навигация + UI-состояние Listening; микрофон и
    // voice session НЕ запускаются до W2/capability (порт-наблюдатель
    // onMicrophoneRequested никогда не вызывается).
    setUiState('LISTENING');
    onTalk?.();
  };
  const resume = () => {
    // F04.A03: открытие доступного дела; только свой эффект.
    if (continuable) onResume?.(continuable.mission_id);
  };

  const copy = uiCopyDe[FRAME_COPY[uiState].title];
  const body = uiCopyDe[FRAME_COPY[uiState].body];

  return (
    <View testID="start-screen" style={styles.screen}>
      <AgentPresence state={avatarState} />

      <View testID={`start-frame-${FRAME_ID[uiState]}`} style={styles.frame}>
        <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
          {copy.text}
        </Text>
        <Text style={[styles.body, { color: tokens.ink }]}>{body.text}</Text>
      </View>

      {/* Ровно один композер; список пустых групп не рендерится никогда. */}
      <ConversationComposer onFocusInput={() => setUiState('INPUT')} />

      {/* F04.V01: не более одной контекстной карточки — только resume-brief. */}
      {continuable ? (
        <View testID="start-contextual-card" style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}>
          <View testID="start-resume-brief">
            <Text accessibilityRole="header" style={[styles.subtle, { color: tokens['on-card'] }]}>
              {uiCopyDe['frame.F04.06.title'].text}
            </Text>
            <Text style={[styles.body, { color: tokens['on-card'] }]}>
              {uiCopyDe['frame.F04.06.body'].text}
            </Text>
            <Text testID="start-brief-mission-id" style={[styles.mono, { color: tokens['on-card'] }]}>
              {continuable.mission_id}
            </Text>
            <Text testID="start-brief-state" style={[styles.mono, { color: tokens['on-card'] }]}>
              {continuable.state}
            </Text>
            <Text testID="start-brief-updated-at" style={[styles.mono, { color: tokens['on-card'] }]}>
              {continuable.updated_at}
            </Text>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel={uiCopyDe['action.F04.A03'].text}
              onPress={resume}
              style={[styles.cta, { backgroundColor: tokens.primary }]}
              testID="start-action-resume"
            >
              <Text style={[styles.ctaLabel, { color: tokens['on-primary'] }]}>
                {uiCopyDe['action.F04.A03'].text}
              </Text>
            </Pressable>
          </View>
        </View>
      ) : null}

      <View style={styles.channels}>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={uiCopyDe['action.F04.A01'].text}
          onPress={write}
          style={[styles.cta, { backgroundColor: tokens.primary }]}
          testID="start-action-write"
        >
          <Text style={[styles.ctaLabel, { color: tokens['on-primary'] }]}>
            {uiCopyDe['action.F04.A01'].text}
          </Text>
        </Pressable>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={uiCopyDe['action.F04.A02'].text}
          onPress={talk}
          style={[styles.cta, { backgroundColor: tokens.primary }]}
          testID="start-action-talk"
        >
          <Text style={[styles.ctaLabel, { color: tokens['on-primary'] }]}>
            {uiCopyDe['action.F04.A02'].text}
          </Text>
        </Pressable>
      </View>
      {/* reducedMotion принимается экраном; действия и слоты карточек
          сохраняются в обоих режимах (F04.V04) — testIDs неизменны. */}
      <Text testID={reducedMotion ? 'start-motion-reduced' : 'start-motion-full'}>
        {reducedMotion ? 'reduced' : 'full'}
      </Text>
    </View>
  );
}

export const StartScreen = React.memo(StartScreenImpl);

const styles = StyleSheet.create({
  screen: { flex: 1, gap: 12, padding: 16 },
  frame: { gap: 4 },
  title: { fontSize: 20, fontWeight: '600' },
  body: { fontSize: 14 },
  subtle: { fontSize: 16, fontWeight: '600' },
  mono: { fontSize: 12 },
  card: { borderRadius: 12, borderWidth: 1, padding: 12 },
  channels: { flexDirection: 'row', gap: 8 },
  cta: { borderRadius: 8, paddingHorizontal: 16, paddingVertical: 10 },
  ctaLabel: { fontSize: 14 },
});

// CMP-MOB-003: Erstinformation — F02.03 (ответственный маклер и документ),
// F02.05 (чтение точной версии), F02.08 (состояние выдачи и Nachweis).
// Порты-инъекция по прецеденту tab-shell (999): экран не знает транспорта,
// тесты и bootstrap подают gate-снимок и disclosure-payload через ApiClient.
// Правила предмета (issue #7 / erstinformation_route UX1.14):
//  - открытие PDF (F02.A02) — чтение, НЕ подтверждение и НЕ mandate;
//  - явное подтверждение текущей версии → acknowledgeDisclosure; результат
//    наблюдается ПОСЛЕ завершения Promise операции, затем gate перечитывается
//    (recheck) — и при успешном current-ack, и при ушедшей версии;
//  - CURRENT_CONFIRMED доказывается ПОЛНОСТЬЮ: состояние сервера ∧ REQUIRED
//    ∧ тот же документ ∧ пригодное evidence ∧ ТОЧНОЕ равенство версий;
//  - getDisclosureGate потребляется только при W1a admission: W0 не
//    показывает continue;
//  - delivered без подтверждения сервером не обозначается подписью.
import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import type {
  AcknowledgeDisclosureResult,
  Admission,
  DeliveryState,
  DisclosureGateSnapshot,
} from '@/api/api-client';
import { Button } from '@/ui/button';
import { Notice } from '@/ui/notice';
import { uiCopyDe } from '@/i18n/ui-copy';
import { useTheme } from '@/theme/context';

export interface DisclosurePayload {
  readonly disclosure_ref: string;
  readonly document_ref: string;
  readonly version: number;
  readonly responsible_entity: string;
  readonly source_ref: string;
}

export interface ErstinformationProps {
  /** Снимок gate; null — snapshot отсутствует, экран уходит в безопасный fallback. */
  readonly gate: DisclosureGateSnapshot | null;
  readonly disclosure: DisclosurePayload;
  readonly admission?: Admission;
  readonly onAcknowledge?: (
    disclosureRef: string,
    version: number,
  ) => void | Promise<AcknowledgeDisclosureResult | void>;
  readonly onRecheck?: () => void;
  readonly onOpenDocument?: (documentRef: string, version: number) => void;
  readonly onContinue?: () => void;
}

const NOTICE_KEY_BY_STATE: Readonly<Record<string, string>> = {
  CHECKING: 'disclosure.checking',
  PENDING: 'disclosure.pending',
  FAILED: 'disclosure.failed',
  OUTDATED: 'disclosure.updated',
  MISSING: 'disclosure.missing',
  UNKNOWN: 'disclosure.checking',
};

/** Отсутствующий snapshot: ничего не утверждает, никаких действий не предлагает. */
const ABSENT_GATE: DisclosureGateSnapshot = {
  applicability: 'UNKNOWN',
  required_document_id: '',
  required_document_version: -1,
  responsible_entity_id: '',
  delivery_state: 'UNKNOWN',
  delivery_evidence_ref: null,
  checked_at: '',
};

function ErstinformationImpl({
  gate,
  disclosure,
  admission = 'W0',
  onAcknowledge,
  onRecheck,
  onOpenDocument,
  onContinue,
}: ErstinformationProps) {
  const { tokens } = useTheme();
  const snapshot: DisclosureGateSnapshot = gate ?? ABSENT_GATE;
  const [viewing, setViewing] = useState<{ ref: string; version: number } | null>(null);

  const gateForDocument =
    snapshot.applicability === 'REQUIRED' &&
    snapshot.required_document_id === disclosure.document_ref;
  const evidenceUsable =
    snapshot.delivery_evidence_ref !== null &&
    snapshot.delivery_evidence_ref.length > 0 &&
    snapshot.checked_at.length > 0;
  const versionEqual = disclosure.version === snapshot.required_document_version;
  // CURRENT_CONFIRMED доказывается полностью: состояние сервера, тот же документ,
  // применимость REQUIRED, пригодное evidence и ТОЧНОЕ равенство версий
  // (не «меньше»: payload новее требуемого — тоже не доказательство).
  const confirmed =
    snapshot.delivery_state === 'CURRENT_CONFIRMED' &&
    gateForDocument &&
    evidenceUsable &&
    versionEqual;
  // Недоказуемый CURRENT_CONFIRMED — это OUTDATED (disclosure.updated), не подтверждение.
  const effective: DeliveryState =
    snapshot.delivery_state === 'CURRENT_CONFIRMED' && !confirmed
      ? 'OUTDATED'
      : snapshot.delivery_state;

  // Подтверждение предлагается по состоянию сервера (гонка: версия может уйти
  // во время незавершённого ack — это закрывается recheck после завершения).
  const confirmEnabled = snapshot.delivery_state === 'CURRENT_CONFIRMED' && snapshot.applicability === 'REQUIRED';
  const continueVisible = admission === 'W1A' && confirmed;

  const openDocument = () => {
    // Чтение документа не подтверждает выдачу: onAcknowledge здесь не вызывается.
    onOpenDocument?.(disclosure.document_ref, disclosure.version);
    // F02.05 держит версию ОТКРЫТИЯ: смена payload во время чтения не подменяет надпись.
    setViewing({ ref: disclosure.document_ref, version: disclosure.version });
  };

  const confirm = () => {
    // Явное подтверждение: результат ack наблюдается после завершения Promise
    // операции ApiClient; по завершении (успех или устаревшая версия) gate
    // перечитывается — issue #7 «после ack перечитать текущее evidence».
    void Promise.resolve(
      onAcknowledge?.(disclosure.disclosure_ref, disclosure.version),
    ).finally(() => {
      onRecheck?.();
    });
  };

  if (viewing) {
    return (
      <View testID="erstinfo-frame-F02.05" style={styles.frame}>
        <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
          {uiCopyDe['frame.F02.05.title'].text}
        </Text>
        <Text style={[styles.body, { color: tokens.ink }]}>{uiCopyDe['frame.F02.05.body'].text}</Text>
        <Text testID="erstinfo-document-ref" style={[styles.mono, { color: tokens.ink }]}>
          {viewing.ref}
        </Text>
        {/* Точная версия ОТКРЫТОГО документа (pin на момент открытия), не требуемая. */}
        <Text testID="erstinfo-document-version" style={[styles.mono, { color: tokens.ink }]}>
          {`Version ${viewing.version}`}
        </Text>
        <Pressable
          accessibilityRole="button"
          testID="erstinfo-back"
          onPress={() => setViewing(null)}
        >
          <Text style={[styles.link, { color: tokens.ink }]}>{uiCopyDe['global.back'].text}</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <View testID="erstinfo-frame-F02.03" style={styles.frame}>
      <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
        {uiCopyDe['frame.F02.03.title'].text}
      </Text>
      <Text style={[styles.body, { color: tokens.ink }]}>{uiCopyDe['frame.F02.03.body'].text}</Text>

      <View testID="erstinfo-responsible-entity" style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}>
        <Text style={[styles.mono, { color: tokens['on-card'] }]}>{disclosure.responsible_entity}</Text>
        <Text style={[styles.mono, { color: tokens['on-card'] }]}>{snapshot.responsible_entity_id}</Text>
        <Text testID="erstinfo-checked-at" style={[styles.mono, { color: tokens['on-card'] }]}>
          {snapshot.checked_at}
        </Text>
      </View>

      <View testID="erstinfo-document-card" style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}>
        <Text testID="erstinfo-document-ref" style={[styles.mono, { color: tokens['on-card'] }]}>
          {disclosure.document_ref}
        </Text>
        <Text style={[styles.mono, { color: tokens['on-card'] }]}>
          {`Version ${disclosure.version}`}
        </Text>
        <Text testID="erstinfo-source-ref" style={[styles.mono, { color: tokens['on-card'] }]}>
          {disclosure.source_ref}
        </Text>
        <Button
          label={uiCopyDe['action.F02.A02'].text}
          onPress={openDocument}
          variant="secondary"
          testID="erstinfo-open-document"
        />
      </View>

      <View testID="erstinfo-frame-F02.08" style={styles.frame}>
        <Text accessibilityRole="header" style={[styles.subtle, { color: tokens.ink }]}>
          {uiCopyDe['frame.F02.08.title'].text}
        </Text>
        <Text style={[styles.body, { color: tokens.ink }]}>{uiCopyDe['frame.F02.08.body'].text}</Text>

        {snapshot.applicability === 'NOT_REQUIRED' ? (
          <Notice testID="erstinfo-notice-disclosure.not_applicable">
            {uiCopyDe['disclosure.not_applicable'].text}
          </Notice>
        ) : effective === 'CURRENT_CONFIRMED' ? (
          <View
            testID="erstinfo-evidence"
            style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}
          >
            <Text testID="erstinfo-evidence-ref" style={[styles.mono, { color: tokens['on-card'] }]}>
              {snapshot.delivery_evidence_ref}
            </Text>
            <Text testID="erstinfo-evidence-checked-at" style={[styles.mono, { color: tokens['on-card'] }]}>
              {snapshot.checked_at}
            </Text>
          </View>
        ) : (
          <Notice testID={`erstinfo-notice-${NOTICE_KEY_BY_STATE[effective]}`}>
            {uiCopyDe[NOTICE_KEY_BY_STATE[effective]].text}
          </Notice>
        )}

        {effective === 'FAILED' ? (
          <Button
            label={uiCopyDe['disclosure.retry'].text}
            onPress={() => onRecheck?.()}
            variant="secondary"
            testID="erstinfo-retry"
          />
        ) : null}

        {confirmEnabled ? (
          <Button
            label="acknowledge"
            onPress={confirm}
            variant="primary"
            testID="erstinfo-confirm"
          />
        ) : null}

        {continueVisible ? (
          <Button
            label={uiCopyDe['action.F02.A01'].text}
            onPress={() => onContinue?.()}
            variant="primary"
            testID="erstinfo-continue"
          />
        ) : null}
      </View>
    </View>
  );
}

export const Erstinformation = React.memo(ErstinformationImpl);

const styles = StyleSheet.create({
  frame: { gap: 12, paddingVertical: 8 },
  card: { borderRadius: 8, borderWidth: 1, padding: 12, gap: 4 },
  title: { fontSize: 22, fontWeight: '600' },
  subtle: { fontSize: 18, fontWeight: '600' },
  body: { fontSize: 15, lineHeight: 22 },
  mono: { fontFamily: 'monospace', fontSize: 13 },
  link: { fontSize: 15, paddingVertical: 8 },
});

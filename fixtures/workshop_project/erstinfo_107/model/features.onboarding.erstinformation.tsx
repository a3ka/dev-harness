// CMP-MOB-003: Erstinformation — F02.03 (ответственный маклер и документ),
// F02.05 (чтение точной версии), F02.08 (состояние выдачи и Nachweis).
// Порты-инъекция по прецеденту tab-shell (999): экран не знает транспорта,
// тесты и bootstrap подают gate-снимок и disclosure- payload через ApiClient.
// Правила предмета (issue #7 / erstinformation_route UX1.14):
//  - открытие PDF (F02.A02) — чтение, НЕ подтверждение и НЕ mandate;
//  - явное подтверждение текущей версии → acknowledgeDisclosure;
//  - ack версии N при требуемой N+1 не открывает gate/continue и перечитывает evidence;
//  - getDisclosureGate потребляется только при W1a admission: W0 не показывает continue;
//  - delivered без подтверждения сервером (не CURRENT_CONFIRMED) не обозначается подписью.
import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import type {
  Admission,
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
  readonly gate: DisclosureGateSnapshot;
  readonly disclosure: DisclosurePayload;
  readonly admission?: Admission;
  readonly onAcknowledge?: (disclosureRef: string, version: number) => void;
  readonly onRecheck?: () => void;
  readonly onOpenDocument?: (documentRef: string, version: number) => void;
  readonly onContinue?: () => void;
}

const NOTICE_KEY_BY_STATE: Readonly<Record<string, string>> = {
  CHECKING: 'disclosure.checking',
  PENDING: 'disclosure.pending',
  FAILED: 'disclosure.failed',
  OUTDATED: 'disclosure.updated',
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
  const [viewingDocument, setViewingDocument] = useState(false);

  const versionStale = disclosure.version < gate.required_document_version;
  // CURRENT_CONFIRMED доказывается только совпадением версии с требуемой:
  // старая версия при подтверждённом состоянии сервера — это OUTDATED
  // (disclosure.updated), не подтверждение.
  const effective: DeliveryState =
    gate.delivery_state === 'CURRENT_CONFIRMED' && versionStale
      ? 'OUTDATED'
      : gate.delivery_state;

  const confirmEnabled = gate.delivery_state === 'CURRENT_CONFIRMED';
  const continueVisible =
    admission === 'W1A' && effective === 'CURRENT_CONFIRMED' && !versionStale;

  const openDocument = () => {
    // Чтение документа не подтверждает выдачу: onAcknowledge здесь не вызывается.
    onOpenDocument?.(disclosure.document_ref, disclosure.version);
    setViewingDocument(true);
  };

  const confirm = () => {
    onAcknowledge?.(disclosure.disclosure_ref, disclosure.version);
    if (versionStale) {
      // ack устаревшей версии: никакого continue, перечитать текущее evidence.
      onRecheck?.();
    }
  };

  if (viewingDocument) {
    return (
      <View testID="erstinfo-frame-F02.05" style={styles.frame}>
        <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
          {uiCopyDe['frame.F02.05.title'].text}
        </Text>
        <Text style={[styles.body, { color: tokens.ink }]}>{uiCopyDe['frame.F02.05.body'].text}</Text>
        <Text testID="erstinfo-document-ref" style={[styles.mono, { color: tokens.ink }]}>
          {disclosure.document_ref}
        </Text>
        {/* Точная версия открытого документа, а не требуемая: F02.05 exact-version. */}
        <Text testID="erstinfo-document-version" style={[styles.mono, { color: tokens.ink }]}>
          {`Version ${disclosure.version}`}
        </Text>
        <Pressable
          accessibilityRole="button"
          testID="erstinfo-back"
          onPress={() => setViewingDocument(false)}
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
        <Text style={[styles.mono, { color: tokens['on-card'] }]}>{gate.responsible_entity_id}</Text>
        <Text testID="erstinfo-checked-at" style={[styles.mono, { color: tokens['on-card'] }]}>
          {gate.checked_at}
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

        {effective === 'CURRENT_CONFIRMED' ? (
          <View
            testID="erstinfo-evidence"
            style={[styles.card, { backgroundColor: tokens.card, borderColor: tokens.panel }]}
          >
            <Text testID="erstinfo-evidence-ref" style={[styles.mono, { color: tokens['on-card'] }]}>
              {gate.delivery_evidence_ref ?? ''}
            </Text>
            <Text testID="erstinfo-evidence-checked-at" style={[styles.mono, { color: tokens['on-card'] }]}>
              {gate.checked_at}
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
  frame: { gap: 10, paddingVertical: 8 },
  card: { borderRadius: 12, borderWidth: 1, paddingHorizontal: 14, paddingVertical: 10, gap: 4 },
  title: { fontSize: 22, fontWeight: '600' },
  subtle: { fontSize: 18, fontWeight: '600' },
  body: { fontSize: 14 },
  mono: { fontSize: 13 },
  link: { fontSize: 14, paddingVertical: 6 },
});

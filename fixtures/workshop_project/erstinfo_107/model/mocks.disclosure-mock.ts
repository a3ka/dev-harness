/**
 * CMP-MOB-003: синтетические сценарии Erstinformation для mock ApiClient.
 *
 * Грамматика состояний/версий — единственный источник
 * `@/api/api-client` (DeliveryState); значения фиксированы и совпадают
 * побайтово с оракулом проб (fixtures/workshop_project/erstinfo_107/source.json,
 * разделы delivery_states/versions/fixed). Все evidence-строки несут
 * SYNTHETIC-маркер по прецеденту mocks/runtime.ts: mock не доказывает
 * реальную доставку Erstinformation (статус плана issue #7).
 */
import type {
  AcknowledgeDisclosureResult,
  DisclosureGateSnapshot,
} from '@/api/api-client';

export const FIXED = {
  disclosure_ref: 'disc-erst-001',
  document_ref: 'doc-erstinformation',
  responsible_entity: 'Makler Meier GmbH',
  responsible_entity_id: 're-001',
  source_ref: 'source://broker-portal/erstinformation',
  evidence_ref: 'evidence://delivery/8f3a',
  checked_at: '2026-10-19T12:00:00Z',
} as const;

const DISCLOSURE_VERSION = 2;
const REQUIRED_VERSION = 3;

/** Ключ сценария: <STATE>_<EQ|STALE>; EQ — версия совпадает с требуемой,
 * STALE — disclosure.version < required_document_version (N против N+1). */
export function gateFor(state: string, axis: 'EQ' | 'STALE'): DisclosureGateSnapshot {
  const required = axis === 'EQ' ? DISCLOSURE_VERSION : REQUIRED_VERSION;
  const confirmed = state === 'CURRENT_CONFIRMED';
  return {
    applicability: 'REQUIRED',
    required_document_id: FIXED.document_ref,
    required_document_version: required,
    responsible_entity_id: FIXED.responsible_entity_id,
    delivery_state: state as DisclosureGateSnapshot['delivery_state'],
    delivery_evidence_ref: confirmed ? FIXED.evidence_ref : null,
    checked_at: FIXED.checked_at,
  };
}

let lastAck: { disclosure_ref: string; version: number } | null = null;

export function acknowledgeMock(
  disclosureRef: string,
  version: number,
): AcknowledgeDisclosureResult {
  // Mock не создаёт ServiceMandate и не открывает gate: подтверждение —
  // только запись факта подтверждённой версии; SYNTHETIC-маркер в evidence.
  lastAck = { disclosure_ref: disclosureRef, version };
  return {
    disclosure_ref: disclosureRef,
    version,
    accepted: true,
    evidence_ref: `SYNTHETIC:${FIXED.evidence_ref}`,
  };
}

export function gateMock(): DisclosureGateSnapshot {
  const snap = gateFor('CURRENT_CONFIRMED', 'EQ');
  return lastAck ? { ...snap, checked_at: snap.checked_at } : snap;
}

export function lastAcknowledged(): { disclosure_ref: string; version: number } | null {
  return lastAck;
}

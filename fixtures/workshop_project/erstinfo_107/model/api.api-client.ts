/**
 * ApiClient — public interface based on OpenAPI 5.8.2.
 *
 * getSession / getDisclosure return values whose TypeScript shape derives from
 * `api/mock-5_8.json#components/schemas/Session` and `#/components/schemas/Disclosure`.
 * Types are sourced explicitly here so ESLint and TypeScript agree; production code
 * never sees `unknown` / `any`.
 *
 * `execute` is intentionally absent from this seam: business commands are routed
 * through dedicated action screens, not a generic transport call.
 *
 * CMP-MOB-003: шов расширяется операциями acknowledgeDisclosure и
 * getDisclosureGate (OpenAPI 5.8.2; грамматика состояний —
 * docs/ux/01_UX_Source_of_Truth/BrokerOS_Mobile_Design_Data.json
 * #ux_refinements_v1_14/contracts/erstinformation_route). Грамматика
 * delivery/applicability живёт здесь в одном месте; потребители (экран
 * F02, mock, пробы) несут её побайтово из этого модуля.
 */
import type { Session, Disclosure } from './generated/api-5_8';

/** Состояния выдачи Erstinformation (erstinformation_route.delivery_values,
 * подмножество F02.08 screen_flow.states). */
export type DeliveryState =
  | 'CHECKING'
  | 'PENDING'
  | 'FAILED'
  | 'OUTDATED'
  | 'CURRENT_CONFIRMED';

/** Применимость выдачи к текущему бизнес-шагу; решается серверной политикой. */
export type Applicability = 'REQUIRED' | 'NOT_REQUIRED' | 'UNKNOWN';

/** Admission-волна шага: getDisclosureGate потребляется только при W1a. */
export type Admission = 'W0' | 'W1A';

/** Снимок гейта выдачи (UXB22 snapshot_required, клиентское подмножество). */
export interface DisclosureGateSnapshot {
  readonly applicability: Applicability;
  readonly required_document_id: string;
  readonly required_document_version: number;
  readonly responsible_entity_id: string;
  readonly delivery_state: DeliveryState;
  readonly delivery_evidence_ref: string | null;
  readonly checked_at: string;
}

/** Результат явного подтверждения текущей версии. */
export interface AcknowledgeDisclosureResult {
  readonly disclosure_ref: string;
  readonly version: number;
  readonly accepted: boolean;
  readonly evidence_ref: string | null;
}

export interface ApiClient {
  /** READ: current session, including effective disclosures and locale. */
  getSession(): Promise<Session>;
  /** READ: idempotent disclosure payload for the given disclosure id. */
  getDisclosure(disclosureId: string): Promise<Disclosure>;
  /** COMMAND: явное подтверждение текущей версии Erstinformation/AI Notice;
   * открытие PDF этому не эквивалентно. */
  acknowledgeDisclosure(disclosureRef: string, version: number): Promise<AcknowledgeDisclosureResult>;
  /** READ: gate-снимок применимости/версии/evidence; применяется только
   * при W1a admission, W0 чтение/ack не снимает более поздний gate. */
  getDisclosureGate(): Promise<DisclosureGateSnapshot>;
}

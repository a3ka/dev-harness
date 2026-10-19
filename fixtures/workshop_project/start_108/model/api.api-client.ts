/**
 * ApiClient — public interface based on OpenAPI 5.8.2.
 *
 * CMP-MOB-004: шов расширяется операцией listMissions (W0) и клиентскими
 * типами проекции MissionBrief/MissionPage/MissionState. Типы объявлены
 * ЗДЕСЬ одним местом (generated/ — read-only); потребители (экран, mock,
 * пробы) не переизобретают перечней.
 *
 * `execute` is intentionally absent from this seam: business commands are routed
 * through dedicated action screens, not a generic transport call.
 */
import type { Session, Disclosure } from './generated/api-5_8';

/** Legacy presentation state v2 (OpenAPI 5.8.2 MissionSnapshot.state).
 * Listening — UI-состояние экрана, НЕ значение wire-перечня. */
export type MissionState =
  | 'RECEIVED'
  | 'WORKING'
  | 'NEEDS_INFORMATION'
  | 'ADVISER_REVIEW'
  | 'NEEDS_APPROVAL'
  | 'WAITING_EXTERNAL'
  | 'COMPLETED'
  | 'PARTIAL'
  | 'BLOCKED'
  | 'CANCELLED';

/** Клиентская проекция дела для Start (MissionResumeBrief). */
export interface MissionBrief {
  readonly mission_id: string;
  readonly state: MissionState;
  readonly updated_at: string;
}

/** Страница listMissions (OpenAPI MissionPage, клиентская проекция). */
export interface MissionPage {
  readonly items: readonly MissionBrief[];
  readonly next_cursor?: string;
}

export interface ApiClient {
  /** READ: current session, including effective disclosures and locale. */
  getSession(): Promise<Session>;
  /** READ: idempotent disclosure payload for the given disclosure id. */
  getDisclosure(disclosureId: string): Promise<Disclosure>;
  /** READ: ACL-filtered list of missions of the current context (W0). */
  listMissions(contextRef?: string): Promise<MissionPage>;
}

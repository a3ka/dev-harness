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
 * CMP-MOB-004 (108): шов расширяется операцией listMissions (W0) и клиентскими
 * типами проекции MissionBrief/MissionPage/MissionState. Типы объявлены ЗДЕСЬ
 * одним местом (generated/ — read-only); потребители (экран, mock, пробы) не
 * переизобретают перечней.
 *
 * CMP-MOB-005 (116): операции беседы F05 (W0, mock до CMP-BCK-009/010/011/
 * 014/015): listMessages/postMessage (одна Mission), createUpload/
 * completeUpload (выбор ≠ загрузка ≠ обработка), listDocuments (источники
 * F05.06), createIntent (новая тема — отдельный intent). Статусы
 * send/upload — клиентская проекция wire-значений; attachment_pending не
 * означает прочитанный файл, queued_offline не означает доставку.
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

/** Сообщение беседы (listMessages/postMessage, клиентская проекция F05). */
export interface ConversationMessage {
  readonly mission_id: string;
  readonly client_message_id: string;
  readonly role: 'user' | 'agent';
  readonly text: string;
  readonly attachment_ids: readonly string[];
}

/** Страница listMessages. */
export interface MessagePage {
  readonly items: readonly ConversationMessage[];
  readonly next_cursor?: string;
}

/** Результат postMessage: повтор того же client_message_id — уже принято. */
export type PostMessageStatus = 'accepted' | 'already_accepted' | 'queued_offline';

/** Вложение: выбрано (attachment_pending) ≠ байты доставлены (uploaded). */
export interface UploadDescriptor {
  readonly upload_id: string;
  readonly mission_id: string;
  readonly file_name: string;
  readonly state: 'attachment_pending' | 'uploaded';
}

export interface DocumentRef {
  readonly document_id: string;
  readonly source_state: 'available' | 'revoked';
}

export interface NewIntent {
  readonly intent_id: string;
  readonly mission_id: string;
}

export interface ApiClient {
  /** READ: current session, including effective disclosures and locale. */
  getSession(): Promise<Session>;
  /** READ: idempotent disclosure payload for the given disclosure id. */
  getDisclosure(disclosureId: string): Promise<Disclosure>;
  /** READ: ACL-filtered list of missions of the current context (W0). */
  listMissions(contextRef?: string): Promise<MissionPage>;
  /** READ: сообщения одной Mission (F05.02 — вторичная история). */
  listMessages(missionId: string): Promise<MessagePage>;
  /** WRITE: сообщение в той же Mission; idempotent по client_message_id. */
  postMessage(message: ConversationMessage): Promise<PostMessageStatus>;
  /** WRITE: выбор вложения — создаёт upload, байты ещё не доставлены. */
  createUpload(missionId: string, fileName: string): Promise<UploadDescriptor>;
  /** WRITE: завершение передачи bytes; не означает принятие evidence. */
  completeUpload(uploadId: string): Promise<UploadDescriptor>;
  /** READ: документы-источники (F05.06 FactCard, отзыв доступа). */
  listDocuments(missionId: string): Promise<readonly DocumentRef[]>;
  /** WRITE: новая тема — отдельный intent без переноса приватного контекста. */
  createIntent(topic: string): Promise<NewIntent>;
}

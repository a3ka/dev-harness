/**
 * CMP-MOB-005 (116): mock-сценарии беседы (features F05) для расширенного
 * mock ApiClient (`mocks/runtime.ts`). Грамматика оракула —
 * BrokerOS_Mobile_Design_Data.json#features/F05: mission_id 'MIS-CAR-01',
 * send_state ∈ {draft, queued_offline, attachment_pending,
 * already_accepted}, response_state ∈ {idle, interrupted}, source_refs
 * 'DOC-VEH-01:p1'. Ответы mock — SYNTHETIC по построению (прецедент
 * 995/107/108): реальная выдача CMP-BCK-009/010/011/014/015 этим файлом
 * не заявляется.
 */
import type {
  ConversationMessage,
  DocumentRef,
  MessagePage,
  MissionBrief,
  UploadDescriptor,
} from '@/api/api-client';

export const CONVERSATION_MISSION_ID = 'MIS-CAR-01';
export const NEW_TOPIC_MISSION_ID = 'MIS-NEW-42';
export const BASELINE_TURN_TEXT = 'Я купила автомобиль.';
export const BASELINE_SOURCE_REF = 'DOC-VEH-01:p1';
export const PICKED_FILE_NAME = 'fahrschein.pdf';

export type SendScenario = 'accepted' | 'already_accepted' | 'queued_offline';
export type UploadScenario = 'uploaded' | 'failed';
export type SourceScenario = 'available' | 'revoked';

export const baselineMessages = (): readonly ConversationMessage[] => [
  {
    mission_id: CONVERSATION_MISSION_ID,
    client_message_id: 'MSG-DEMO-01',
    role: 'user',
    text: BASELINE_TURN_TEXT,
    attachment_ids: ['DOC-VEH-01'],
  },
];

export const baselineDocuments = (source: SourceScenario): readonly DocumentRef[] => [
  { document_id: 'DOC-VEH-01', source_state: source },
];

export const messagePage = (): MessagePage => ({ items: baselineMessages() });

export const missionBrief = (missionId: string): MissionBrief => ({
  mission_id: missionId,
  state: 'WORKING',
  updated_at: '2026-10-09T12:00:00Z',
});

export const uploadDescriptor = (
  uploadId: string,
  state: UploadDescriptor['state'],
): UploadDescriptor => ({
  upload_id: uploadId,
  mission_id: CONVERSATION_MISSION_ID,
  file_name: PICKED_FILE_NAME,
  state,
});

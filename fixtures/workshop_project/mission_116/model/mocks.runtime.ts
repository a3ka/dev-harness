/**
 * Mock composition for the pilot — selected by Metro/Jest resolver alias
 * `@pilot/runtime → <this file>` when EXPO_PUBLIC_API_MODE is unset or 'mock'.
 *
 * Demo AuthProvider is intentionally co-located with the mock ApiClient here, NOT
 * exported from `src/auth/`: the seam keeps real identity plumbing separate from
 * synthetic verification values. The `Demo` label surfaces in welcome and is part
 * of the cognitive-only check; evidence strings carry `SYNTHETIC` to make mock
 * states distinguishable in diagnostic logs without exposing the verification value.
 *
 * The bootstrap module is rejected at evaluation time when EXPO_PUBLIC_API_MODE
 * holds an unsupported value, satisfying the `UNKNOWN_MODE → PILOT_API_MODE_UNSUPPORTED`
 * contract; default-offline and `http` runs never enter this file.
 *
 * CMP-MOB-004 (108): mock ApiClient расширен операцией listMissions —
 * сценарии из `@/mocks/start-mock` (presence × state). До CMP-BCK-008/009
 * реальные HTTP-операции отсутствуют: mock остаётся SYNTHETIC-источником
 * и НЕ заявляется доказательством реальной выдачи.
 *
 * CMP-MOB-005 (116): mock ApiClient расширен операциями беседы F05 —
 * listMessages/postMessage/createUpload/completeUpload/listDocuments/
 * createIntent (сценарии `@/mocks/conversation-mock`). Реальные
 * HTTP-операции CMP-BCK-009/010/011/014/015 отсутствуют; статус
 * NOT_RUN→PASS заявляется только с evidence соответствующего SWITCH.
 */
import type { Disclosure, Session, Locale } from '@/api/generated/api-5_8';
import type { ApiClient, MissionPage } from '@/api/api-client';
import type { AuthProvider } from '@/auth/auth-provider';
import { PILOT_DEMO_CODE } from './demo-code';
import pilotResponses from './pilot-responses.json';
import { missionsSnapshot } from './start-mock';
import {
  CONVERSATION_MISSION_ID,
  NEW_TOPIC_MISSION_ID,
  baselineDocuments,
  messagePage,
  uploadDescriptor,
} from './conversation-mock';

const mode = process.env.EXPO_PUBLIC_API_MODE;

if (mode !== undefined && mode !== '' && mode !== 'mock') {
  throw new Error('PILOT_API_MODE_UNSUPPORTED');
}

const SESSION_FIXTURE: Session = {
  ...pilotResponses.getSession,
  locale: pilotResponses.getSession.locale as Locale,
};

const DISCLOSURE_FIXTURE: Disclosure = {
  ...pilotResponses.getDisclosure,
};

const begin: AuthProvider['begin'] = async (email) => ({
  challenge: email,
  evidence: 'SYNTHETIC',
});

const verify: AuthProvider['verify'] = async (_challenge, code) => {
  if (code === PILOT_DEMO_CODE) {
    return { status: 'authenticated', evidence: 'SYNTHETIC' };
  }
  return { status: 'invalid', evidence: 'SYNTHETIC' };
};

const resend: AuthProvider['resend'] = async () => ({
  confirmed: true,
  evidence: 'SYNTHETIC',
});

const recover: AuthProvider['recover'] = async () => ({
  status: 'unavailable',
  evidence: 'SYNTHETIC',
});

const demoAuthProvider: AuthProvider = { begin, verify, resend, recover };

const getSession: ApiClient['getSession'] = async () => SESSION_FIXTURE;
const getDisclosure: ApiClient['getDisclosure'] = async (_id) => DISCLOSURE_FIXTURE;
const listMissions: ApiClient['listMissions'] = async () =>
  ({ items: missionsSnapshot().items }) as MissionPage;

const listMessages: ApiClient['listMessages'] = async () => messagePage();

const postMessage: ApiClient['postMessage'] = async (message) => {
  if (message.mission_id === CONVERSATION_MISSION_ID) {
    return 'accepted';
  }
  return 'queued_offline';
};

const createUpload: ApiClient['createUpload'] = async (_missionId, fileName) =>
  uploadDescriptor(`UPL-${fileName}`, 'attachment_pending');

const completeUpload: ApiClient['completeUpload'] = async (uploadId) =>
  uploadDescriptor(uploadId, 'uploaded');

const listDocuments: ApiClient['listDocuments'] = async () =>
  baselineDocuments('available');

const createIntent: ApiClient['createIntent'] = async () => ({
  intent_id: 'INT-NEW-01',
  mission_id: NEW_TOPIC_MISSION_ID,
});

const mockApiClient: ApiClient = {
  getSession,
  getDisclosure,
  listMissions,
  listMessages,
  postMessage,
  createUpload,
  completeUpload,
  listDocuments,
  createIntent,
};

export const runtime: { auth: AuthProvider; api: ApiClient } = {
  auth: demoAuthProvider,
  api: mockApiClient,
};

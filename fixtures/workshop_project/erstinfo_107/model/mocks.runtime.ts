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
 * CMP-MOB-003: mock ApiClient расширен операциями acknowledgeDisclosure и
 * getDisclosureGate (сценарии mocks/disclosure-mock.ts); mock не доказывает
 * реальную доставку — SYNTHETIC-маркер сохранён.
 */
import type { Disclosure, Session, Locale } from '@/api/generated/api-5_8';
import type { ApiClient } from '@/api/api-client';
import type { AuthProvider } from '@/auth/auth-provider';
import { PILOT_DEMO_CODE } from './demo-code';
import pilotResponses from './pilot-responses.json';
import { acknowledgeMock, gateMock } from './disclosure-mock';

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
const acknowledgeDisclosure: ApiClient['acknowledgeDisclosure'] = async (ref, version) =>
  acknowledgeMock(ref, version);
const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => gateMock();

const mockApiClient: ApiClient = {
  getSession,
  getDisclosure,
  acknowledgeDisclosure,
  getDisclosureGate,
};

export const runtime: { auth: AuthProvider; api: ApiClient } = {
  auth: demoAuthProvider,
  api: mockApiClient,
};

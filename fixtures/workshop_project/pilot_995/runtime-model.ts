// Interactive countermodel only; never a product runtime.
import values from './runtime-values.json';
const mutant = process.env.PILOT_995_MODEL;
const mode = process.env.EXPO_PUBLIC_API_MODE || 'mock';
if (!['mock', 'http'].includes(mode) && mutant !== 'ignore-mode') {
  throw Error('PILOT_API_MODE_UNSUPPORTED');
}
export const runtime = {
  auth: {
    begin: async (email: string) => ({
      challenge: email,
      status: mode === 'http' && mutant !== 'http-demo' ? 'unavailable' : undefined,
      evidence: 'SYNTHETIC',
    }),
    verify: async (_challenge: string, code: string) => ({
      status: (mutant === 'any-code' || (mutant === 'env-code'
        ? process.env.PILOT_DEMO_CODE === undefined || code === process.env.PILOT_DEMO_CODE
        : code === 'synthetic-verification-value')) ? 'authenticated' : 'invalid',
      evidence: 'SYNTHETIC',
    }),
    resend: async () => ({ confirmed: true, evidence: 'SYNTHETIC' }),
    recover: async () => ({ status: 'unavailable', evidence: 'SYNTHETIC' }),
  },
  api: {
    getSession: async () => mutant === 'wrong-session' ? { ...values.getSession, principal_ref: 42 } : values.getSession,
    getDisclosure: async () => mutant === 'wrong-disclosure' ? { ...values.getDisclosure, acknowledged: 'false' } : values.getDisclosure,
    execute: async () => undefined,
  },
};

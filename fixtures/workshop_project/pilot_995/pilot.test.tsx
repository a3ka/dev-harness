import React from 'react';
import { act, fireEvent, render, screen, userEvent, within } from '@testing-library/react-native';
import { PilotApp } from '../pilot-app';
import source from './source.json';

// Public composition seam, not a replacement for ApiClient/AuthProvider internals.
const text = (key: keyof typeof source.copy) => source.copy[key];
const secret = ['synthetic', 'verification', 'value'].join('-');
interface Reply { status?: string; confirmed?: boolean; evidence: string; retryAfterSeconds?: number }
const deferred = () => Promise.withResolvers<Reply>();
const click = async (id: string) => fireEvent.press(screen.getByTestId(id));
function ports() {
  return {
    auth: {
      begin: jest.fn(async (email: string) => ({ challenge: email, evidence: 'SYNTHETIC' })),
      verify: jest.fn(async (_challenge: string, code: string): Promise<Reply> => ({ status: code === secret ? 'authenticated' : 'invalid', evidence: 'SYNTHETIC' })),
      resend: jest.fn(async (): Promise<Reply> => ({ confirmed: true, evidence: 'SYNTHETIC' })),
      recover: jest.fn(async () => ({ status: 'unavailable', evidence: 'SYNTHETIC' })),
    },
    api: {
      getSession: jest.fn(async () => source.session),
      getDisclosure: jest.fn(async () => source.disclosure),
      execute: jest.fn(async () => { throw Error('995 BUSINESS_COMMAND_FORBIDDEN'); }),
    },
    entry: { source: 'DIRECT', onboarding: 'unknown', pendingIntent: null as null | { actionId: string; commandId: string } },
  };
}
async function start(p = ports()) {
  await render(<PilotApp {...p} />);
  await click('first-run-continue');
  expect(screen.getByText(text('frame.F03.01.title'))).toBeOnTheScreen();
  await fireEvent.changeText(screen.getByTestId('auth-email'), 'one@example.invalid');
  await click('auth-demo-entry');
  expect(screen.getByText(text('frame.F03.02.title'))).toBeOnTheScreen();
  return p;
}
async function verify(code = secret) {
  await fireEvent.changeText(screen.getByTestId('auth-code'), code);
  await click('auth-verify');
}
function noStart() { expect(screen.queryByTestId('protected-start')).toBeNull(); }
function noCommit(p: { api: { execute: jest.Mock } }) { expect(p.api.execute).not.toHaveBeenCalled(); }

describe('995 pilot', () => {
  for (const state of ['unknown', 'incomplete']) it(`DIRECT_${state}`, async () => {
    const p = ports(); p.entry.onboarding = state;
    await start(p); await verify();
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
    expect(screen.getByText(text('frame.F02.01.body'))).toBeOnTheScreen();
    expect(screen.getByText('Demo')).toBeOnTheScreen(); noStart();
    expect(p.auth.begin).toHaveBeenCalledWith('one@example.invalid');
    expect(p.auth.verify).toHaveBeenCalledWith('one@example.invalid', secret);
    expect(p.api.getSession).toHaveBeenCalledTimes(1);
    expect(p.api.getDisclosure).toHaveBeenCalled(); noCommit(p);
  });
  it('INVALID_CODE', async () => {
    const p = await start(); await verify('not-the-demo-value');
    expect(screen.getByTestId('auth-invalid')).toBeOnTheScreen();
    expect(screen.queryByTestId('F02.01')).toBeNull(); noStart();
    expect(p.api.getSession).not.toHaveBeenCalled(); noCommit(p);
  });
  it('RESEND_UNCONFIRMED', async () => {
    const p = ports(); const pending = deferred(); p.auth.resend.mockImplementation(() => pending.promise);
    await start(p); await userEvent.press(screen.getByTestId('auth-resend'));
    expect(screen.queryByText(text('ui.auth.code_resend_sent'))).toBeNull();
    expect(screen.queryByTestId('auth-cooldown')).toBeNull();
    await act(async () => pending.resolve({ confirmed: false, evidence: 'SYNTHETIC' }));
    expect(screen.queryByText(text('ui.auth.code_resend_sent'))).toBeNull();
    await verify(); expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });
  it('RESEND_CONFIRMED', async () => {
    const p = await start(); await click('auth-resend');
    expect(screen.getByText(text('ui.auth.code_resend_sent'))).toBeOnTheScreen();
    expect(screen.getByText('SYNTHETIC')).toBeOnTheScreen();
    expect(screen.queryByTestId('auth-cooldown')).toBeNull();
    expect(p.auth.resend).toHaveBeenCalledWith('one@example.invalid');
  });
  it('RESEND_COOLDOWN', async () => {
    const p = ports(); p.auth.resend.mockResolvedValue({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 17 });
    await start(p); await click('auth-resend');
    expect(within(screen.getByTestId('auth-cooldown')).getByText(text('ui.auth.code_resend_wait').replace('{seconds}', '17'))).toBeOnTheScreen();
    expect(screen.getByText('SYNTHETIC')).toBeOnTheScreen();
  });
  it('EMAIL_STALE', async () => {
    const p = ports(); const pending = deferred(); p.auth.verify.mockImplementationOnce(() => pending.promise);
    await start(p); await fireEvent.changeText(screen.getByTestId('auth-code'), secret);
    await userEvent.press(screen.getByTestId('auth-verify')); await click('auth-change-email');
    await fireEvent.changeText(screen.getByTestId('auth-email'), 'two@example.invalid'); await click('auth-demo-entry');
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    expect(screen.queryByTestId('F02.01')).toBeNull(); expect(p.api.getSession).not.toHaveBeenCalled();
    await verify(); expect(p.auth.verify).toHaveBeenLastCalledWith('two@example.invalid', secret);
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });
  it('RECOVERY_A07', async () => {
    const p = await start(); await click('auth-no-access');
    const recovery = screen.getByTestId('F03.04');
    expect(within(recovery).getByTestId('recovery-A07')).toBeOnTheScreen();
    expect(within(recovery).getByRole('header', { name: text('frame.F03.04.title') })).toBeOnTheScreen();
    await click('auth-recover'); expect(p.auth.recover).toHaveBeenCalled();
    expect(screen.queryByTestId('recovery-success')).toBeNull(); noCommit(p);
    await click('auth-return'); expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
  });
  for (const status of ['stale', 'revoked', 'missing_scope']) it(`AUTH_${status}`, async () => {
    const p = ports(); p.auth.verify.mockResolvedValue({ status, evidence: 'SYNTHETIC' });
    await start(p); await verify(); noStart(); expect(screen.queryByTestId('F02.01')).toBeNull();
    expect(p.api.getSession).not.toHaveBeenCalled(); noCommit(p);
    await click('auth-no-access'); await click('auth-recover'); noCommit(p);
    expect(screen.queryByTestId('recovery-success')).toBeNull();
  });
  it('SECRET', async () => {
    const logs: unknown[][] = [];
    const spies = (['log','info','warn','error','debug'] as const).map(k => jest.spyOn(console, k).mockImplementation((...args) => { logs.push(args); }));
    try {
      await start(); await verify();
      expect(JSON.stringify(logs)).not.toContain(secret);
      expect(screen.queryByText(secret)).toBeNull();
      expect(screen.queryByTestId('auth-code')).toBeNull();
    } finally { spies.forEach(s => s.mockRestore()); }
  });
  it('REPLAY', async () => {
    const p = ports(); p.entry.pendingIntent = { actionId: 'F01.A01', commandId: 'synthetic-command' };
    await start(p); await verify(); noCommit(p);
    await screen.unmount(); await render(<PilotApp {...p} />); noCommit(p);
    expect(screen.queryByTestId('invitation-accepted')).toBeNull();
  });
  it('DEFAULT_OFFLINE', async () => {
    const original = global.fetch;
    const originalMode = process.env.EXPO_PUBLIC_API_MODE;
    global.fetch = jest.fn(async () => { throw Error('995 HTTP_UNAVAILABLE'); });
    delete process.env.EXPO_PUBLIC_API_MODE;
    try {
      await render(<PilotApp />); await click('first-run-continue');
      await fireEvent.changeText(screen.getByTestId('auth-email'), 'demo@example.invalid'); await click('auth-demo-entry');
      expect(screen.getByTestId('auth-code')).toBeOnTheScreen();
      expect(screen.getByText('Demo')).toBeOnTheScreen();
      expect(global.fetch).not.toHaveBeenCalled();
    } finally {
      global.fetch = original;
      if (originalMode === undefined) delete process.env.EXPO_PUBLIC_API_MODE;
      else process.env.EXPO_PUBLIC_API_MODE = originalMode;
    }
  });
});

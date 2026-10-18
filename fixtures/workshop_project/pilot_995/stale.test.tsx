import React from 'react';
import { act, fireEvent, render, screen } from '@testing-library/react-native';
import { PilotApp } from '../pilot-app';
import source from './source.json';

// Отложенные результаты СТАРОГО challenge не применяются после смены e-mail
// (995, круг 1 ревьюера B1). Порты — deferred-наблюдатели: тестируется отгружаемая
// композиция, управляется только момент разрешения await. Адреса .invalid,
// код — synthetic credential frozen-семьи.
const secret = ['synthetic', 'verification', 'value'].join('-');
const click = async (id: string) => fireEvent.press(screen.getByTestId(id));
function ports() {
  return {
    auth: {
      begin: jest.fn(async (email: string) => ({ challenge: email, evidence: 'SYNTHETIC' })),
      verify: jest.fn(async (_c: string, code: string) => ({ status: code === secret ? 'authenticated' : 'invalid', evidence: 'SYNTHETIC' })),
      resend: jest.fn(async () => ({ confirmed: true, evidence: 'SYNTHETIC' })),
      recover: jest.fn(async () => ({ status: 'unavailable', evidence: 'SYNTHETIC' })),
    },
    api: {
      getSession: jest.fn(async () => source.session as never),
      getDisclosure: jest.fn(async () => source.disclosure as never),
    },
  };
}
async function toCode(email: string) {
  await fireEvent.changeText(screen.getByTestId('auth-email'), email);
  await click('auth-demo-entry');
}

describe('995 stale', () => {
  it('REV_STALE_RESEND', async () => {
    const p = ports();
    const pending = Promise.withResolvers<{ confirmed: boolean; evidence: string; retryAfterSeconds?: number }>();
    p.auth.resend.mockImplementationOnce(() => pending.promise);
    await render(<PilotApp auth={p.auth as never} api={p.api as never} />);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await click('auth-resend');
    await click('auth-change-email');
    await toCode('two@example.invalid');
    expect(p.auth.resend).toHaveBeenCalledWith('one@example.invalid');
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    expect(screen.queryByText(source.copy['ui.auth.code_resend_sent'])).toBeNull();
    expect(screen.queryByTestId('auth-cooldown')).toBeNull();
  });
  it('REV_STALE_SESSION', async () => {
    const p = ports();
    const pending = Promise.withResolvers<never>();
    p.api.getSession.mockImplementationOnce(() => pending.promise);
    await render(<PilotApp auth={p.auth as never} api={p.api as never} />);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await fireEvent.changeText(screen.getByTestId('auth-code'), secret);
    await click('auth-verify');
    expect(p.api.getSession).toHaveBeenCalledTimes(1);
    await click('auth-change-email');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve(source.session as never));
    expect(screen.queryByTestId('F02.01')).toBeNull();
  });
});

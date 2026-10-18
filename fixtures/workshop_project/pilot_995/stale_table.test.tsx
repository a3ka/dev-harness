import React from 'react';
import { act, cleanup, fireEvent, render, screen } from '@testing-library/react-native';
import { PilotApp } from '../pilot-app';
import source from './source.json';

// Stale/гонки как ТАБЛИЦА ПЕРЕХОДОВ (995, круг 2 ревьюера B1′: поколенческий
// страж был только на пути «E-Mail ändern»). Для каждого асинхронного порта
// (begin, verify, resend, getSession, recover) × каждого достижимого перехода
// экранного автомата (смена e-mail, возврат handleReturn, повторный begin,
// resend, unmount/remount): отложенный ответ ПРЕДЫДУЩЕГО поколения, пришедший
// после перехода, не меняет UI/состояние. Порты — deferred-наблюдатели над
// ОТГРУЖАЕМОЙ композицией (реальный '../pilot-app', как stale.test.tsx);
// адреса .invalid, код — synthetic credential frozen-семьи. Ячейки
// *_RETURN/BEGIN_REBEGIN красные на C без поколенческого стража на
// handleReturn/handleDemoEntry; LIVE_* — живой контроль против вечно-красноты.
// Недостижимые пары (begin pending держит e-mail-кадр: нет change-email/
// return/resend; recover pending держит F03.04: нет change-email/resend) в
// таблицу не входят — их переходы физически отсутствуют в автомате.
const secret = ['synthetic', 'verification', 'value'].join('-');
const click = async (id: string) => fireEvent.press(screen.getByTestId(id));
type Reply = { status?: string; confirmed?: boolean; evidence: string; retryAfterSeconds?: number };
interface TestPorts {
  auth: {
    begin: (email: string) => Promise<{ challenge: string; evidence: string }>;
    verify: (challenge: string, code: string) => Promise<Reply>;
    resend: () => Promise<Reply>;
    recover: () => Promise<Reply>;
  };
  api: {
    getSession: () => Promise<never>;
    getDisclosure: () => Promise<never>;
  };
}
function ports(): TestPorts {
  return {
    auth: {
      begin: jest.fn(async (email: string) => ({ challenge: email, evidence: 'SYNTHETIC' })),
      verify: jest.fn(async (_c: string, code: string): Promise<Reply> => ({ status: code === secret ? 'authenticated' : 'invalid', evidence: 'SYNTHETIC' })),
      resend: jest.fn(async (): Promise<Reply> => ({ confirmed: true, evidence: 'SYNTHETIC' })),
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
  await act(async () => {
    click('auth-demo-entry');
  });
}
async function enterSecret() {
  await fireEvent.changeText(screen.getByTestId('auth-code'), secret);
}
const noF02 = () => expect(screen.queryByTestId('F02.01')).toBeNull();
const noResendNotice = () => {
  expect(screen.queryByText(source.copy['ui.auth.code_resend_sent'])).toBeNull();
  expect(screen.queryByTestId('auth-cooldown')).toBeNull();
};
const mount = (p: TestPorts) =>
  render(<PilotApp auth={p.auth as never} api={p.api as never} />);

afterEach(cleanup);
describe('995 stale table', () => {
  // ---------- порт begin ----------
  it('995 table BEGIN_REBEGIN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<{ challenge: string; evidence: string }>();
    p.auth.begin.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve({ challenge: 'one@example.invalid', evidence: 'SYNTHETIC' }));
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.auth.verify).toHaveBeenLastCalledWith('two@example.invalid', secret);
  });

  it('995 table BEGIN_UNMOUNT', async () => {
    const p = ports();
    const pending = Promise.withResolvers<{ challenge: string; evidence: string }>();
    p.auth.begin.mockImplementationOnce(() => pending.promise);
    const view = await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await view.unmount();
    await act(async () => pending.resolve({ challenge: 'one@example.invalid', evidence: 'SYNTHETIC' }));
    await mount(p);
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    noF02();
  });

  // ---------- порт verify ----------
  it('995 table VERIFY_CHANGE_EMAIL', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.verify.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await click('auth-change-email');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    noF02();
    expect(p.api.getSession).not.toHaveBeenCalled();
  });

  it('995 table VERIFY_RETURN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.verify.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.begin).toHaveBeenLastCalledWith('two@example.invalid');
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    noF02();
    expect(p.api.getSession).not.toHaveBeenCalled();
  });

  it('995 table VERIFY_RESEND', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.verify.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await act(async () => {
      click('auth-resend');
    });
    expect(screen.getByText(source.copy['ui.auth.code_resend_sent'])).toBeOnTheScreen();
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    // resend не меняет поколение: тот же активный challenge — вход применим.
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });

  it('995 table VERIFY_REBEGIN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.verify.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await click('auth-change-email');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    noF02();
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.auth.verify).toHaveBeenLastCalledWith('two@example.invalid', secret);
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });

  it('995 table VERIFY_UNMOUNT', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.verify.mockImplementationOnce(() => pending.promise);
    const view = await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await view.unmount();
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    await mount(p);
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    noF02();
  });

  // ---------- порт resend ----------
  it('995 table RESEND_CHANGE_EMAIL', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.resend.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    await click('auth-change-email');
    await toCode('two@example.invalid');
    expect(p.auth.resend).toHaveBeenCalledWith('one@example.invalid');
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    noResendNotice();
    noF02();
  });

  it('995 table RESEND_RETURN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.resend.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.resend).toHaveBeenCalledWith('one@example.invalid');
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    noResendNotice();
    noF02();
  });

  it('995 table RESEND_RESEND', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.resend.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    await act(async () => {
      click('auth-resend');
    });
    expect(screen.getByText(source.copy['ui.auth.code_resend_sent'])).toBeOnTheScreen();
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    expect(screen.getByText(source.copy['ui.auth.code_resend_sent'])).toBeOnTheScreen();
  });

  it('995 table RESEND_REBEGIN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.resend.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    await click('auth-change-email');
    await toCode('two@example.invalid');
    expect(p.auth.begin).toHaveBeenLastCalledWith('two@example.invalid');
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    noResendNotice();
    noF02();
  });

  it('995 table RESEND_UNMOUNT', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.resend.mockImplementationOnce(() => pending.promise);
    const view = await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    await view.unmount();
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    await mount(p);
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    noF02();
  });

  // ---------- порт getSession ----------
  it('995 table GETSESSION_CHANGE_EMAIL', async () => {
    const p = ports();
    const pending = Promise.withResolvers<never>();
    p.api.getSession.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.api.getSession).toHaveBeenCalledTimes(1);
    await click('auth-change-email');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve(source.session as never));
    noF02();
  });

  it('995 table GETSESSION_RETURN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<never>();
    p.api.getSession.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.api.getSession).toHaveBeenCalledTimes(1);
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve(source.session as never));
    noF02();
  });

  it('995 table GETSESSION_RESEND', async () => {
    const p = ports();
    const pending = Promise.withResolvers<never>();
    p.api.getSession.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await act(async () => {
      click('auth-resend');
    });
    expect(screen.getByText(source.copy['ui.auth.code_resend_sent'])).toBeOnTheScreen();
    await act(async () => pending.resolve(source.session as never));
    // resend не менял поколение: тот же challenge — welcome применим.
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });

  it('995 table GETSESSION_REBEGIN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<never>();
    p.api.getSession.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await click('auth-change-email');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve(source.session as never));
    noF02();
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.auth.verify).toHaveBeenLastCalledWith('two@example.invalid', secret);
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });

  it('995 table GETSESSION_UNMOUNT', async () => {
    const p = ports();
    const pending = Promise.withResolvers<never>();
    p.api.getSession.mockImplementationOnce(() => pending.promise);
    const view = await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    await view.unmount();
    await act(async () => pending.resolve(source.session as never));
    await mount(p);
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    noF02();
  });

  // ---------- порт recover ----------
  it('995 table RECOVER_RETURN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.recover.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await click('auth-no-access');
    await act(async () => {
      click('auth-recover');
    });
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.begin).toHaveBeenLastCalledWith('two@example.invalid');
    await act(async () => pending.resolve({ status: 'unavailable', evidence: 'SYNTHETIC' }));
    noF02();
    noResendNotice();
  });

  it('995 table RECOVER_REBEGIN', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.recover.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await click('auth-no-access');
    await act(async () => {
      click('auth-recover');
    });
    await click('auth-return');
    await toCode('two@example.invalid');
    await act(async () => pending.resolve({ status: 'unavailable', evidence: 'SYNTHETIC' }));
    noF02();
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.auth.verify).toHaveBeenLastCalledWith('two@example.invalid', secret);
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });

  it('995 table RECOVER_UNMOUNT', async () => {
    const p = ports();
    const pending = Promise.withResolvers<Reply>();
    p.auth.recover.mockImplementationOnce(() => pending.promise);
    const view = await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await click('auth-no-access');
    await act(async () => {
      click('auth-recover');
    });
    await view.unmount();
    await act(async () => pending.resolve({ status: 'unavailable', evidence: 'SYNTHETIC' }));
    await mount(p);
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    noF02();
  });

  // ---------- живые контроли ----------
  it('995 table LIVE_RESEND_NOTICE', async () => {
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    expect(screen.getByText(source.copy['ui.auth.code_resend_sent'])).toBeOnTheScreen();
  });

  it('995 table LIVE_VERIFY_WELCOME', async () => {
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await act(async () => {
      click('auth-verify');
    });
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });
});

import React from 'react';
import { act, cleanup, fireEvent, render, screen } from '@testing-library/react-native';
import { PilotApp } from '../pilot-app';
import source from './source.json';

// Stale/перенос состояния как ИСЧЕРПЫВАЮЩАЯ ТАБЛИЦА ПЕРЕХОДОВ (995, круг 3:
// adversary A1 VERIFY_NO_ACCESS + reviewer B1″ перенос записанного состояния).
// Перечисление ПО КОДУ shipped pilot-app.tsx (e44dfd09): 10 обработчиков
// (handleFirstRunContinue, handleEmailChange, handleCodeChange, handleDemoEntry,
// handleVerify, handleResend, handleChangeEmail, handleNoAccess, handleRecover,
// handleReturn), 7 вызовов setFrame, 8 вызовов setFlow — полный перечень несёт
// ячейка-сторож SENTRY_HANDLERS: обработчик вне таблицы = красный.
// Переходы, отменяющие/заменяющие challenge: handleDemoEntry (re-begin),
// handleChangeEmail, handleReturn, handleNoAccess; не отменяющие (ячейки
// «состояние challenge не меняется»): FIRST_RUN_KEEP, EMAIL_CHANGE_PENDING_KEEP,
// CODE_CHANGE_KEEP_CHALLENGE, RECOVER_NO_SUCCESS. Порты в полёте: begin, verify,
// resend, getSession/getDisclosure, recover. Недостижимые пары (begin pending
// держит e-mail-кадр — нет change-email/return/no-access; recover pending держит
// F03.04 — нет no-access/change-email; unavailable-кадр не имеет выхода) в
// таблицу не входят — переходы физически отсутствуют в автомате.
// Атрибуция по Н-39: ячейка краснеет от сброса/бампа ТОГО обработчика, на чьём
// окне её наблюдаемая стоит. VERIFY_NO_ACCESS/GETSESSION_NO_ACCESS — окно
// handleNoAccess (между no-access и следующим стражем нет перехода);
// BEGIN_REBEGIN — окно handleDemoEntry; *_CHANGE_EMAIL_EARLY — окно
// handleChangeEmail (resolve ДО re-begin). handleReturn динамически маскирован:
// auth-return рендерится только в RecoveryFrame, recovery достижим только через
// handleNoAccess (чей сброс уже очистил flow), recovery-кадр не пишет состояние
// challenge (recover не касается flow), а возврат к code обязан пройти
// handleDemoEntry со сбросом ДО порта — ОДИНОЧНОЕ удаление resetChallenge() из
// handleReturn динамически ненаблюдаемо (измерено adversary микро-круга:
// mut-return проходит все динамические ячейки 36/36). Поэтому обязанность
// «каждый отменяющий обработчик вызывает общий reset-хелпер» несёт СТАТИЧЕСКОЕ
// звено RESET_CHALLENGE_CALLS; RETURN_GUARD_EARLY остаётся динамическим
// контролем пары no-access+return. RECORD_* переносят УЖЕ ПРИМЕНЁННОЕ состояние
// (sent/cooldown/invalid/code) старого challenge через no-access→return→re-begin
// (пути rev3-carry ревьюера круга 3); LIVE_* — живой контроль против
// вечно-красноты. Порты — deferred-наблюдатели над ОТГРУЖАЕМОЙ композицией
// (реальный '../pilot-app', как stale.test.tsx); адреса .invalid, код —
// synthetic credential frozen-семьи.
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

  // ---------- ячейка-сторож: исчерпывающий перечень автомата ----------
  it('995 table SENTRY_HANDLERS', () => {
    // Статический перечень shipped pilot-app.tsx: все handle*-обработчики и
    // каждый вызов setFrame/setFlow. Обработчик вне таблицы (по имени) либо
    // setFlow/setFrame вне известной функции — КРАСНЫЙ (мутант «новый
    // обработчик с setFlow вне таблицы»). resetChallenge — единственный
    // разрешённый не-handle владелец состояния (reset-хелпер фикса).
    const fs = require('fs');
    const path = require('path');
    const text = fs.readFileSync(path.join(__dirname, '..', 'pilot-app.tsx'), 'utf8');
    const known = [
      'handleFirstRunContinue', 'handleEmailChange', 'handleCodeChange', 'handleDemoEntry',
      'handleVerify', 'handleResend', 'handleChangeEmail', 'handleNoAccess',
      'handleRecover', 'handleReturn',
    ];
    const owners = [...known, 'resetChallenge'];
    const defs: string[] = [];
    const sites: { line: number; owner: string; call: string }[] = [];
    let owner = '';
    text.split('\n').forEach((line, index) => {
      const def = line.match(/const (handle\w+) = useCallback/);
      if (def) { defs.push(def[1]); owner = def[1]; return; }
      const helper = line.match(/const (resetChallenge) = useCallback/);
      if (helper) { owner = helper[1]; return; }
      const call = line.match(/(setFrame|setFlow)\(/);
      if (call) sites.push({ line: index + 1, owner, call: call[1] });
    });
    const missing = known.filter((name) => !defs.includes(name));
    const extra = defs.filter((name) => !known.includes(name));
    expect({ missing, extra }).toEqual({ missing: [], extra: [] });
    const stray = sites.filter((site) => !owners.includes(site.owner));
    expect(stray).toEqual([]);
    expect(sites.length).toBeGreaterThan(0);
  });

  // ---------- статическое звено reset-хелпера (микро-круг: mut-return) ----------
  it('995 table RESET_CHALLENGE_CALLS', () => {
    // Одиночное удаление resetChallenge() из handleReturn динамически
    // ненаблюдаемо (доказательство структурной маскировки — шапка файла),
    // поэтому обязанность «отменяющий обработчик вызывает общий reset-хелпер»
    // проверяется по shipped pilot-app.tsx в стиле SENTRY_HANDLERS: внутри
    // тела КАЖДОГО из четырёх отменяющих обработчиков обязан стоять прямой
    // вызов resetChallenge();. Краснеет именованно — RESET_CHALLENGE_CALL_MISSING:
    // <handler> по одному на каждый singleton-мутант (Н-39: свой вход — своё
    // предъявление).
    const fs = require('fs');
    const path = require('path');
    const text = fs.readFileSync(path.join(__dirname, '..', 'pilot-app.tsx'), 'utf8');
    const cancellers = ['handleDemoEntry', 'handleChangeEmail', 'handleNoAccess', 'handleReturn'];
    let owner = '';
    let helper = false;
    const defs: string[] = [];
    const calls: Record<string, number> = {};
    text.split('\n').forEach((line) => {
      const def = line.match(/const (handle\w+) = useCallback/);
      if (def) { defs.push(def[1]); owner = def[1]; return; }
      if (/const resetChallenge = useCallback/.test(line)) { owner = 'resetChallenge'; helper = true; return; }
      if (/^  \}, \[/.test(line)) { owner = ''; return; }
      if (owner && /^\s*resetChallenge\(\);/.test(line)) calls[owner] = (calls[owner] ?? 0) + 1;
    });
    const violations: string[] = [];
    if (!helper) violations.push('RESET_CHALLENGE_HELPER_ABSENT');
    cancellers.filter((name) => !defs.includes(name))
      .forEach((name) => violations.push(`RESET_HANDLER_MISSING:${name}`));
    cancellers.filter((name) => !(calls[name] >= 1))
      .forEach((name) => violations.push(`RESET_CHALLENGE_CALL_MISSING:${name}`));
    expect(violations).toEqual([]);
  });

  // ---------- переход handleNoAccess: окно до следующего стража ----------
  it('995 table VERIFY_NO_ACCESS', async () => {
    // A1 (adversary круг 3): отложенный verify старого поколения авторизует
    // поверх F03.04 — handleNoAccess не поднимал поколение на e44dfd09.
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
    expect(screen.getByTestId('F03.04')).toBeOnTheScreen();
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    expect(screen.getByTestId('F03.04')).toBeOnTheScreen();
    noF02();
    expect(p.api.getSession).not.toHaveBeenCalled();
  });

  it('995 table GETSESSION_NO_ACCESS', async () => {
    // A1, вторая await-точка (:124): api в полёте × no-access — welcome
    // не применяется из recovery.
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
    expect(screen.getByTestId('F03.04')).toBeOnTheScreen();
    await act(async () => pending.resolve(source.session as never));
    expect(screen.getByTestId('F03.04')).toBeOnTheScreen();
    noF02();
  });

  it('995 table RESEND_NO_ACCESS', async () => {
    // Deferred resend применяется в окне no-access (resolve ДО return) —
    // подтверждение/cooldown старого challenge не доживают до нового.
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
    await act(async () => pending.resolve({ confirmed: true, evidence: 'SYNTHETIC' }));
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.resend).toHaveBeenLastCalledWith('one@example.invalid');
    noResendNotice();
    noF02();
  });

  // ---------- перенос УЖЕ ПРИМЕНЁННОГО состояния (B1″, пути rev3-carry) ----------
  it('995 table RECORD_NOACCESS_RETURN_SENT', async () => {
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    expect(screen.getByText(source.copy['ui.auth.code_resend_sent'])).toBeOnTheScreen();
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.begin).toHaveBeenLastCalledWith('two@example.invalid');
    expect(p.auth.resend).toHaveBeenCalledTimes(1);
    noResendNotice();
  });

  it('995 table RECORD_NOACCESS_RETURN_COOLDOWN', async () => {
    const p = ports();
    p.auth.resend.mockImplementationOnce(async () => ({ confirmed: true, evidence: 'SYNTHETIC', retryAfterSeconds: 30 }));
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await act(async () => {
      click('auth-resend');
    });
    expect(screen.getByTestId('auth-cooldown')).toBeOnTheScreen();
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.resend).toHaveBeenCalledTimes(1);
    expect(screen.queryByTestId('auth-cooldown')).toBeNull();
  });

  it('995 table RECORD_NOACCESS_RETURN_INVALID', async () => {
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await fireEvent.changeText(screen.getByTestId('auth-code'), 'wrong-code');
    await act(async () => {
      click('auth-verify');
    });
    expect(screen.getByTestId('auth-invalid')).toBeOnTheScreen();
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(p.auth.verify).toHaveBeenCalledTimes(1);
    expect(screen.queryByTestId('auth-invalid')).toBeNull();
  });

  it('995 table RECORD_NOACCESS_RETURN_CODE', async () => {
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await enterSecret();
    await click('auth-no-access');
    await click('auth-return');
    await toCode('two@example.invalid');
    expect(screen.getByTestId('auth-code').props.value).toBe('');
  });

  // ---------- изолированные окна handleChangeEmail/handleReturn (resolve ДО re-begin) ----------
  it('995 table VERIFY_CHANGE_EMAIL_EARLY', async () => {
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
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
    noF02();
    expect(p.api.getSession).not.toHaveBeenCalled();
  });

  // Примечание Н-39: изолированного resend-окна change-email НЕТ — результат
  // resend пишет только состояние code-кадра, в e-mail-кадре ненаблюдаем;
  // класс держит RESEND_CHANGE_EMAIL (regression, resolve после re-begin).

  it('995 table RETURN_GUARD_EARLY', async () => {
    // Окно handleReturn (resolve после return, ДО re-begin). На e44dfd09
    // return поднимает поколение — зелёная; краснеет только при потере
    // стража return И отсутствии более раннего стража no-access.
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
    await act(async () => pending.resolve({ status: 'authenticated', evidence: 'SYNTHETIC' }));
    expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
    noF02();
    expect(p.api.getSession).not.toHaveBeenCalled();
  });

  // ---------- обработчики, НЕ отменяющие challenge: состояние не меняется ----------
  it('995 table FIRST_RUN_KEEP', async () => {
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
    noF02();
    noResendNotice();
  });

  it('995 table EMAIL_CHANGE_PENDING_KEEP', async () => {
    // Печать e-mail не отменяет pending begin: результат применяется.
    const p = ports();
    const pending = Promise.withResolvers<{ challenge: string; evidence: string }>();
    p.auth.begin.mockImplementationOnce(() => pending.promise);
    await mount(p);
    await click('first-run-continue');
    await fireEvent.changeText(screen.getByTestId('auth-email'), 'one@example.invalid');
    await act(async () => {
      click('auth-demo-entry');
    });
    await fireEvent.changeText(screen.getByTestId('auth-email'), 'two@example.invalid');
    await act(async () => pending.resolve({ challenge: 'one@example.invalid', evidence: 'SYNTHETIC' }));
    expect(screen.getByTestId('auth-code')).toBeOnTheScreen();
  });

  it('995 table CODE_CHANGE_KEEP_CHALLENGE', async () => {
    // Печать кода гасит invalid (осознанно, :95), но challenge жив:
    // verify уходит тому же challenge.
    const p = ports();
    await mount(p);
    await click('first-run-continue');
    await toCode('one@example.invalid');
    await fireEvent.changeText(screen.getByTestId('auth-code'), 'wrong-code');
    await act(async () => {
      click('auth-verify');
    });
    expect(screen.getByTestId('auth-invalid')).toBeOnTheScreen();
    await fireEvent.changeText(screen.getByTestId('auth-code'), secret);
    expect(screen.queryByTestId('auth-invalid')).toBeNull();
    await act(async () => {
      click('auth-verify');
    });
    expect(p.auth.verify).toHaveBeenLastCalledWith('one@example.invalid', secret);
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });

  it('995 table RECOVER_NO_SUCCESS', async () => {
    // Инв. 4: восстановление без capability не объявляет успеха — recovery
    // остаётся recovery при любом ответе recover.
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
    await act(async () => pending.resolve({ status: 'confirmed', evidence: 'SYNTHETIC' }));
    expect(screen.getByTestId('F03.04')).toBeOnTheScreen();
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

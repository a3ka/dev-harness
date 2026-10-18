import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';
import expected from './runtime-values.json';

// Load after the process mode is set, through the shipped route, with NO DI props.
const click = async (id: string) => fireEvent.press(screen.getByTestId(id));
async function begin() {
  const Root = require('../../app/index').default;
  await render(<Root />);
  await click('first-run-continue');
  await fireEvent.changeText(screen.getByTestId('auth-email'), 'demo@example.invalid');
  await click('auth-demo-entry');
}
async function verify(code: string) {
  await fireEvent.changeText(screen.getByTestId('auth-code'), code);
  await click('auth-verify');
}
const demoCode = () => process.env.PILOT_DEMO_CODE!;

describe('995 runtime', () => {
  it('SHIPPED_INVALID', async () => {
    await begin();
    await verify(demoCode() + '-invalid');
    expect(screen.getByTestId('auth-invalid')).toBeOnTheScreen();
    expect(screen.queryByTestId('F02.01')).toBeNull();
    expect(screen.queryByTestId('protected-start')).toBeNull();
    // The same shipped challenge still permits the real synthetic credential.
    await verify(demoCode());
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });
  for (const name of ['SHIPPED_VALID', 'DEFAULT_VALID']) it(name, async () => {
    await begin(); await verify(demoCode());
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
    expect(screen.getByText('Demo')).toBeOnTheScreen();
    expect(screen.queryByTestId('auth-code')).toBeNull();
  });
  it('HTTP_UNAVAILABLE', async () => {
    const original = global.fetch;
    global.fetch = jest.fn(async () => { throw Error('HTTP_UNAVAILABLE'); });
    try {
      await begin();
      if (screen.queryByTestId('auth-code')) await verify(demoCode());
      expect(screen.getByTestId('auth-unavailable')).toBeOnTheScreen();
      expect(screen.queryByTestId('F02.01')).toBeNull();
      expect(screen.queryByTestId('protected-start')).toBeNull();
    } finally { global.fetch = original; }
  });
  it('UNKNOWN_MODE', async () => {
    // Bootstrap may reject at module evaluation or at render; both are configuration errors.
    await expect((async () => { const Root = require('../../app/index').default; await render(<Root />); })())
      .rejects.toThrow('PILOT_API_MODE_UNSUPPORTED');
  });
  it('RUNTIME_RESPONSES', async () => {
    const { runtime } = require('@pilot/runtime');
    // Call-through observers, not fake ports: app and returned data remain the subject's.
    const beginSpy = jest.spyOn(runtime.auth, 'begin');
    const verifySpy = jest.spyOn(runtime.auth, 'verify');
    const session = jest.spyOn(runtime.api, 'getSession');
    const disclosure = jest.spyOn(runtime.api, 'getDisclosure');
    try {
      await begin(); await verify(demoCode());
      expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
      expect(beginSpy).toHaveBeenCalledWith('demo@example.invalid');
      expect(verifySpy).toHaveBeenCalled();
      expect(session).toHaveBeenCalled();
      expect(disclosure).toHaveBeenCalled();
      for (const call of session.mock.results) {
        expect(call.type).toBe('return');
        expect(await call.value).toEqual(expected.getSession);
      }
      for (const call of disclosure.mock.results) {
        expect(call.type).toBe('return');
        expect(await call.value).toEqual(expected.getDisclosure);
      }
    } finally { jest.restoreAllMocks(); }
  });
});

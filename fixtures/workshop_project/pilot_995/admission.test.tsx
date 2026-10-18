import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';

// Admission invariant (995, круг 1 адверсария): аутентификация iff введённый код
// равен единственной отгруженной синтетической credential. Отрицательные проверки
// не делят один литерал: каждый независимый неверный код — собственный кейс,
// включая константы, которые этот харнесс никогда не отгружал. Загружается
// настоящий root route БЕЗ props, как runtime.test.tsx.
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
const demoCode = () => 'synthetic-verification-value';

describe('995 admission', () => {
  const wrongCodes: ReadonlyArray<readonly [string, string]> = [
    ['ADMISSION_FOREIGN_CONSTANT', 'adversary-bypass-code'],
    ['ADMISSION_EMPTY', ''],
    ['ADMISSION_PREFIX', demoCode().slice(0, -1)],
    ['ADMISSION_CASE_FLIP', demoCode().toUpperCase()],
  ];
  for (const [name, code] of wrongCodes) it(name, async () => {
    await begin();
    await verify(code);
    expect(screen.getByTestId('auth-invalid')).toBeOnTheScreen();
    expect(screen.queryByTestId('F02.01')).toBeNull();
    expect(screen.queryByTestId('protected-start')).toBeNull();
    // Тот же живой challenge принимает настоящую credential: отказ выше —
    // свойство значения кода, а не мёртвый поток.
    await verify(demoCode());
    expect(screen.getByTestId('F02.01')).toBeOnTheScreen();
  });
});

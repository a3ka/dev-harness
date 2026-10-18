import React from 'react';
import { act, cleanup, fireEvent, render, screen } from '@testing-library/react-native';

// Admission invariant as a GENERATED FAMILY (995, круг 2 адверсария: допуск
// проверялся перечнем литералов). Семейство мутаций эталонного кода строится
// детерминированно из самого эталона: удаление/замена/вставка в КАЖДОЙ
// позиции символа из замкнутого алфавита классов, все префиксные усечения,
// регистр, NFC/NFD, пустая/однобуквенная строки, иной код той же длины.
// Инвариант: authenticated iff code === PILOT_DEMO_CODE. Загружается
// настоящий root route БЕЗ props (mock runtime), ОДИН jest-запуск на всё
// семейство; количество мутаций каждого класса входит в имя assertion и
// сверяется пробой с независимым генератором (ASSERTION_SET_MISMATCH).
// Значения мутаций никогда не попадают в сообщения: только класс#индекс.
const CODE = 'synthetic-verification-value';
const click = async (id: string) => fireEvent.press(screen.getByTestId(id));

// Замкнутый алфавит классов: один представитель на класс.
const REPS: ReadonlyArray<readonly [string, string]> = [
  ['ASCII_UPPER', 'X'],
  ['ASCII_PUNCT', '%'],
  ['SPACE', ' '],
  ['TAB', '\t'],
  ['NEWLINE', '\n'],
  ['CONTROL', '\u0000'],
  ['ZWSP', '\u200B'],
  ['ZWNJ', '\u200C'],
  ['ZWJ', '\u200D'],
  ['WJ', '\u2060'],
  ['BOM', '\uFEFF'],
  ['NBSP', '\u00A0'],
  ['COMBINING', '\u0301'],
  ['FULLWIDTH', '\uFF41'],
];
const NFC_A = '\u00E1';
const NFD_A = 'a\u0301';

function buildFamily(): ReadonlyArray<readonly [string, readonly string[]]> {
  const groups: Array<[string, readonly string[]]> = [];
  const del: string[] = [];
  for (let i = 0; i < CODE.length; i++) del.push(CODE.slice(0, i) + CODE.slice(i + 1));
  groups.push(['DELETE', del]);
  const sub: string[] = [];
  for (let i = 0; i < CODE.length; i++)
    for (const [, ch] of REPS) sub.push(CODE.slice(0, i) + ch + CODE.slice(i + 1));
  groups.push(['SUBSTITUTE', sub]);
  const ins: string[] = [];
  for (let i = 0; i <= CODE.length; i++)
    for (const [, ch] of REPS) ins.push(CODE.slice(0, i) + ch + CODE.slice(i));
  groups.push(['INSERT', ins]);
  const trunc: string[] = [];
  for (let n = 1; n < CODE.length; n++) trunc.push(CODE.slice(0, n));
  groups.push(['TRUNCATE', trunc]);
  // toLowerCase(CODE) === CODE — тождество, в семейство не входит.
  groups.push(['CASE', [CODE.toUpperCase(), CODE[0].toUpperCase() + CODE.slice(1)]]);
  groups.push(['EDGE', ['', 'x', [...CODE].reverse().join('')]]);
  const a = CODE.indexOf('a');
  groups.push([
    'NORMALIZE',
    [CODE.slice(0, a) + NFC_A + CODE.slice(a + 1), CODE.slice(0, a) + NFD_A + CODE.slice(a + 1)],
  ]);
  return groups;
}

async function beginSession() {
  const Root = require('../../app/index').default;
  await render(<Root />);
  await click('first-run-continue');
  await fireEvent.changeText(screen.getByTestId('auth-email'), 'demo@example.invalid');
  await act(async () => {
    click('auth-demo-entry');
  });
}

type Outcome = 'rejected' | 'admitted' | 'silent';
async function submit(code: string): Promise<Outcome> {
  await fireEvent.changeText(screen.getByTestId('auth-code'), code);
  await act(async () => {
    click('auth-verify');
  });
  if (screen.queryByTestId('F02.01')) return 'admitted';
  if (screen.queryByTestId('auth-invalid')) return 'rejected';
  return 'silent';
}

jest.setTimeout(300000);
afterEach(cleanup);

describe('995 admission family', () => {
  const groups = buildFamily();
  for (const [cls, codes] of groups)
    it(
      `995 family ${cls}[${codes.length}]`,
      async () => {
        await beginSession();
        const violations: string[] = [];
        for (let i = 0; i < codes.length; i++) {
          const outcome = await submit(codes[i]);
          if (outcome !== 'rejected') violations.push(`${cls}#${i}:${outcome}`);
          if (outcome === 'admitted') break; // кадр ушёл в F02 — дальнейшие подачи невозможны
        }
        if (violations.length)
          throw new Error(`ADMITTED_OR_SILENT ${violations.slice(0, 20).join(', ')}`);
      },
      300000,
    );

  it(
    '995 family LIVE_TRUE_CODE[1]',
    async () => {
      await beginSession();
      const outcome = await submit(CODE);
      if (outcome !== 'admitted')
        throw new Error(`LIVE_TRUE_CODE: honest credential outcome=${outcome}`);
    },
    60000,
  );
});

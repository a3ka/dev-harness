#!/usr/bin/env python3
"""Стаб 145 (produkt-форма): ТАВТОЛОГИЧЕСКИЕ/МЁРТВЫЕ обязательные тесты — арбитраж Astra A.5.

Движковый тест заменён тавтологией expect(1).toBe(1); знаковый — ассертами в
НЕДОСТИЖИМОМ блоке (if (false) {…}). При живом честном движке и компоненте
«наличие файлов» (a02) зелено — но значимость обязательных артефактов
уничтожена. По арбитражу оба отклоняются ОБЩИМ сравнением полного исполняемого
артефакта: клетка a03 (байты движкового теста ≠ канону) и клетка a05 (байты
знакового теста ≠ канону) — TEST_IZMENEN, именованный отказ с sha256.
Привязка Н-39: a03-jest-dvizhok-kanon + a05-jest-znak-celesnost."""
import pathlib
import shutil
import sys

cel = pathlib.Path(sys.argv[1])
bat = pathlib.Path(__file__).resolve().parents[1]
cel = cel / 'produkt'
shutil.copytree(bat / 'produkt', cel)
tavtologia = "// фиктивный тест пробы\n describe('faden', () => { it('проба', () => { expect(1).toBe(1); }); });\n"
(cel / 'mobile/src/ui/faden/__tests__/faden-motion.test.ts').write_text(tavtologia, encoding='utf-8')
mertvyje = """// фиктивный знаковый тест пробы: ассерты в недостижимом блоке (арбитраж A.5)
import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { FadenSign } from '../FadenSign';
import { pose, path } from '../faden-motion.ts';

describe('FadenSign (проба)', () => {
  it('ассерты в недостижимом блоке', () => {
    let provereno = false;
    if (false) {
      const znak = screen.queryByTestId('faden-sign-thread');
      expect(znak).not.toBeNull();
      expect(znak && znak.props.d).toBe(path(pose('idle', { t: 0 })));
      provereno = true;
    }
    expect(provereno).toBe(false);
  });
});
"""
(cel / 'mobile/src/ui/faden/__tests__/faden-sign.test.tsx').write_text(mertvyje, encoding='utf-8')

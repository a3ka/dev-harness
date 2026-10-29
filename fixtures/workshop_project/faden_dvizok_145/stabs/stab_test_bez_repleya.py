#!/usr/bin/env python3
"""Стаб 145 (produkt-форма): движковый тест БЕЗ РЕПЛЕЯ — арбитраж Astra A.5
(две проверки options() из вердикта критика 2/2 — обход, прошедший 45/45).

«Честно выглядящий» тест: читает docs-оракул, проверяет sha256-пины, дважды
зовёт options() — и ЗЕЛЁНЫЙ, потому что НЕ реплеит ни одной из 21 сцены/6680
строк. По арбитражу отклоняется общим сравнением полного исполняемого
артефакта: клетка a03 — байты движкового теста ≠ канону (TEST_IZMENEN,
именованный отказ с sha256). Привязка Н-39: a03-jest-dvizhok-kanon."""
import pathlib
import shutil
import sys

cel = pathlib.Path(sys.argv[1])
bat = pathlib.Path(__file__).resolve().parents[1]
cel = cel / 'produkt'
shutil.copytree(bat / 'produkt', cel)
test = '''// фиктивный движковый тест пробы: оракул без реплея (арбитраж A.5)
import { readFileSync } from 'fs';
import { createHash } from 'crypto';
import { createInstance } from '../faden-motion.ts';

const ORAKUL_DIR = process.env.FADEN_ORAKUL_DIR || process.cwd() + '/../docs/ux/04_Gespraech_D24/motion';
const PINY: Record<string, string> = {
  'faden-poses-gespraech.json': '9763fdc06b0c0a3c3138f7abac57bf5efbc714403f53d221c3b7c8d225c4f002',
  'input-tracks.json': '40e068c92e01e12676254ff40ae6315ad3474c76602d0dfb84cdd00975314b94',
  'motion-spec-gespraech.json': '064d7821428f425d431fbd1efd65cbec37263bb62ef974924746a07e769cd318',
};

describe('faden-motion (без реплея)', () => {
  it('оракул: sha256 пинов', () => {
    for (const imja of Object.keys(PINY)) {
      const hesh = createHash('sha256').update(readFileSync(ORAKUL_DIR + '/' + imja)).digest('hex');
      expect(hesh).toBe(PINY[imja]);
    }
  });
  it('options(): set(amplitude:0.5) меняет опции', () => {
    const inst = createInstance({ autoplay: false });
    inst.set({ amplitude: 0.5 });
    expect(inst.options().amplitude).toBe(0.5);
  });
  it('options(): set(state:waiting) меняет опции', () => {
    const inst = createInstance({ autoplay: false });
    inst.set({ state: 'waiting' });
    expect(inst.options().state).toBe('waiting');
  });
});
'''
(cel / 'mobile/src/ui/faden/__tests__/faden-motion.test.ts').write_text(test, encoding='utf-8')

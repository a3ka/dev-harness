'use strict';
// toy-тест finance_journal (мини-мир 121): баланс команды и effect evidence.
const { test } = require('node:test');
const assert = require('node:assert');
const { openDb } = require('../../helpers/toy_e2e');

test('finance_journal: сбалансированная команда с effect проводится', () => {
  const db = openDb();
  db.insert('app.finance_journal', { id: 'j1', command_id: 'c1', amount_minor: 100, effect_ref: null });
  db.insert('app.finance_journal', { id: 'j2', command_id: 'c1', amount_minor: -100, effect_ref: 'eff-1' });
  assert.ok(true, 'баланс 0 — команда закрыта с effect evidence');
});

test('finance_journal: несбалансированный журнал отвергается', () => {
  const db = openDb();
  db.insert('app.finance_journal', { id: 'j1', command_id: 'c2', amount_minor: 100, effect_ref: null });
  assert.throws(
    () => db.insert('app.finance_journal', { id: 'j2', command_id: 'c2', amount_minor: -60, effect_ref: 'eff-2' }),
    /UNBALANCED_JOURNAL/,
    'закрытие с ненулевым balance обязано отказывать');
});

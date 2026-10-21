'use strict';
// toy-тест immutable (мини-мир 121): guard_immutable отвергает UPDATE/DELETE
// document_version/approval; разрешённый переход — новая версия (generated_columns).
const { test } = require('node:test');
const assert = require('node:assert');
const { openDb } = require('../../helpers/toy_e2e');

test('immutable: guard_immutable отвергает UPDATE/DELETE document_version и approval', () => {
  const db = openDb();
  db.insert('app.document_version', { id: 'v1', document_id: 'd1', scope_id: 'A' });
  db.insert('app.approval', { id: 'a1', document_version_id: 'v1', decision: 'APPROVED' });
  assert.throws(() => db.update('app.document_version', 'v1', { document_id: 'd2' }), /GUARD_IMMUTABLE/,
    'UPDATE document_version обязан отвергаться');
  assert.throws(() => db.delete('app.approval', 'a1'), /GUARD_IMMUTABLE/,
    'DELETE approval обязан отвергаться');
});

test('immutable: положительный переход — INSERT новой версии с generated columns разрешён', () => {
  const db = openDb();
  db.insert('app.document_version', { id: 'v1', document_id: 'd1', scope_id: 'A' });
  db.insert('app.document_version', { id: 'v2', document_id: 'd1', scope_id: 'A', generated_columns: { minor: 100 } });
  db.setScope('A');
  const rows = db.select('app.document_version');
  assert.equal(rows.length, 2, 'новая document_version вставляется без отказа guard_immutable');
});

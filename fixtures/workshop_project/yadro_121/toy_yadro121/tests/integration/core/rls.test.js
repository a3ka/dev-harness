'use strict';
// toy-тест rls (мини-мир 121): ИСПОЛНЯЕТ операторы toy_pg под runtime-ролью.
// Маркеры пина: FORCE ROW LEVEL SECURITY, has_scope_access, bypassrls, brokeros_api.
const { test } = require('node:test');
const assert = require('node:assert');
const { openDb } = require('../../helpers/toy_e2e');

test('rls: FORCE ROW LEVEL SECURITY держит и владельца; brokeros_api без bypassrls', () => {
  const db = openDb();
  db.insert('app.document_version', { id: 'v1', document_id: 'd1', scope_id: 'A' });
  db.insert('app.document_version', { id: 'v2', document_id: 'd1', scope_id: 'B' });
  db.setScope('A');
  db.setRole('toy_owner');
  assert.equal(db.select('app.document_version').length, 1,
    'FORCE ROW LEVEL SECURITY: владелец видит только строки своего scope (app.has_scope_access)');
  db.setRole('brokeros_api');
  assert.equal(db.select('app.document_version').length, 1,
    'брокерос api видит только свой scope');
  const attr = db.roleAttr('brokeros_api');
  assert.equal(attr.bypassrls, false, 'runtime-роль brokeros_api не имеет bypassrls');
});

test('rls: чужой scope не виден ни владельцу (FORCE), ни роли', () => {
  const db = openDb();
  db.insert('app.document_version', { id: 'v1', scope_id: 'A' });
  db.insert('app.document_version', { id: 'v2', scope_id: 'B' });
  db.setScope('A');
  for (const role of ['toy_owner', 'brokeros_api']) {
    db.setRole(role);
    const got = db.select('app.document_version');
    assert.ok(got.every((r) => r.scope_id === 'A'), 'scope B утёк для ' + role);
  }
});

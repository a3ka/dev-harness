'use strict';
// toy-тест admin_audit (мини-мир 121): control.runtime_admin_audit,
// ADMIN_AUDIT_CONTEXT_REQUIRED, actor_principal_id, redaction secret_locator.
const { test } = require('node:test');
const assert = require('node:assert');
const { openDb } = require('../../helpers/toy_e2e');

test('runtime_admin_audit: без контекста отказ ADMIN_AUDIT_CONTEXT_REQUIRED', () => {
  const db = openDb();
  assert.throws(
    () => db.adminCommand({ command: 'UPDATE provider_connection SET enabled = NOT enabled', actor: 'p1', metadata: { enabled: false } }),
    /ADMIN_AUDIT_CONTEXT_REQUIRED/,
    'админ-команда без контекста обязана отказывать');
});

test('runtime_admin_audit: с контекстом пишется actor_principal_id и редаксируется secret_locator', () => {
  const db = openDb();
  const row = db.adminCommand({
    command: 'UPDATE provider_connection SET enabled = NOT enabled',
    actor: 'toy-principal-1',
    context: 'ctx-1',
    metadata: { enabled: false, secret_locator: 's3://x', account_reference: 'acc-1' },
  });
  assert.equal(row.actor_principal_id, 'toy-principal-1');
  assert.equal(row.metadata.secret_locator, '<redacted>');
  assert.equal(row.metadata.account_reference, '<redacted>');
  assert.equal(row.metadata.enabled, false);
  assert.throws(() => db.update('control.runtime_admin_audit', row.id, { command: 'x' }), /AUDIT_APPEND_ONLY/);
});

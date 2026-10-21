'use strict';
// Поведенческий мини-движок «БД» мини-мира 121 (fixtures/workshop_project/
// yadro_121/toy_yadro121). НЕ PostgreSQL: исполняет ЗАКРЫТУЮ грамматику
// toy-миграций и энфорсит свойства ядра кодом — RLS/FORCE, guard_immutable,
// баланс finance_journal, контекст runtime_admin_audit. Тесты test:core
// ИСПОЛНЯют операторы движка и КРАСНЕЮТ на повреждении свойства —
// мутационные пробы батареи выключают ровно один флаг ниже.
// Анкеры мутаций (НЕ менять, привязка в yadro_oracle.sh и pin_yadro121.json):
//   «FORCE_RLS_DEFAULT = true», «IMMUTABLE_GUARD = true»,
//   «JOURNAL_BALANCE = true», «AUDIT_CONTEXT_REQUIRED = true».
const fs = require('node:fs');
const path = require('node:path');

const FORCE_RLS_DEFAULT = true;
const IMMUTABLE_GUARD = true;
const JOURNAL_BALANCE = true;
const AUDIT_CONTEXT_REQUIRED = true;

class SqlError extends Error {
  constructor(sqlstate, message) {
    super(message + ' [SQLSTATE ' + sqlstate + ']');
    this.sqlstate = sqlstate;
  }
}

const REDACTED_KEYS = ['secret_locator', 'account_reference'];

module.exports = class ToyPg {
  constructor(engineKind) {
    this.engineKind = engineKind === 'pglite' ? 'pglite' : 'native';
    this.engineId = this.engineKind === 'pglite' ? 'toy-pglite' : 'toy-native';
    this.major = this.engineKind === 'pglite' ? '16.4 (PGlite-совместимый)' : '18.6';
    this.rls = new Map(); // таблица -> { enabled, forced }
    this.policies = new Map(); // таблица -> [{ roles: [], capability }]
    this.immutable = new Set();
    this.roles = new Map(); // имя -> { bypassrls }
    this.rows = new Map(); // таблица -> []
    this.journalTable = null;
    this.auditTable = null;
    this.role = 'toy_owner';
    this.scope = null;
    this.executed = [];
    this.errors = [];
  }

  version() { return 'ToyPostgreSQL ' + this.major + ' toy, ' + this.engineId; }

  applyFile(file) {
    const text = fs.readFileSync(file, 'utf8');
    for (const raw of text.split('\n')) {
      const line = raw.trim();
      if (!line || line.startsWith('--')) continue;
      let m;
      if ((m = line.match(/^CREATE TABLE (\S+) \(/))) {
        this.rows.set(m[1], []);
        if (m[1] === 'app.finance_journal') this.journalTable = m[1];
        if (m[1] === 'control.runtime_admin_audit') this.auditTable = m[1];
      } else if ((m = line.match(/^CREATE TRIGGER \S+ BEFORE UPDATE OR DELETE ON (\S+) FOR EACH ROW EXECUTE FUNCTION app\.guard_immutable/))) {
        this.immutable.add(m[1]);
      } else if ((m = line.match(/^CREATE TRIGGER \S+ BEFORE INSERT ON (\S+) FOR EACH ROW EXECUTE FUNCTION app\.assert_journal_balance/))) {
        if (m[1] !== this.journalTable) throw new SqlError('42601', 'журнальный триггер не на журнале');
      } else if ((m = line.match(/^CREATE TRIGGER \S+ BEFORE INSERT ON control\.runtime_admin_audit FOR EACH ROW EXECUTE FUNCTION app\.require_admin_context/))) {
        this.auditContextTrigger = true;
      } else if ((m = line.match(/^ALTER TABLE (\S+) ENABLE ROW LEVEL SECURITY/))) {
        this.rls.set(m[1], Object.assign({ enabled: true }, this.rls.get(m[1])));
      } else if ((m = line.match(/^ALTER TABLE (\S+) FORCE ROW LEVEL SECURITY/))) {
        this.rls.set(m[1], Object.assign({ enabled: true, forced: true }, this.rls.get(m[1])));
      } else if ((m = line.match(/^CREATE ROLE (\S+) NOLOGIN NOSUPERUSER NOBYPASSRLS/))) {
        this.roles.set(m[1], { bypassrls: false });
      } else if ((m = line.match(/^CREATE POLICY \S+ ON (\S+) FOR SELECT TO ([^ ]+) USING \(app\.has_scope_access\('([^']+)'\)\)/))) {
        this.policies.set(m[1], [{ roles: m[2].split(','), capability: m[3] }]);
      } else {
        throw new SqlError('42601', 'toy_pg: неизвестный оператор (грамматика закрыта): ' + line);
      }
    }
  }

  applyMigrationsDir(dir) {
    for (const f of ['001_core.sql', '002_rls.sql', '003_finance.sql', '004_runtime_role_fixes.sql']) {
      this.applyFile(path.join(dir, f));
    }
  }

  setRole(r) {
    if (r !== 'toy_owner' && !this.roles.has(r)) throw new SqlError('42743', 'неизвестная роль ' + r);
    this.role = r;
  }

  setScope(s) { this.scope = s; }

  roleAttr(name) {
    if (!this.roles.has(name)) throw new SqlError('42743', 'неизвестная роль ' + name);
    return this.roles.get(name);
  }

  insert(table, row) {
    this.executed.push('INSERT INTO ' + table);
    if (!this.rows.has(table)) throw new SqlError('42P01', 'нет таблицы ' + table);
    if (table === this.journalTable) {
      if (JOURNAL_BALANCE) {
        const cmd = row.command_id;
        const prior = this.rows.get(table).filter((r) => r.command_id === cmd)
          .reduce((s, r) => s + r.amount_minor, 0);
        if (row.effect_ref != null && prior + row.amount_minor !== 0) {
          throw new SqlError('23514', 'UNBALANCED_JOURNAL: сумма команды ' + cmd + ' не 0');
        }
      }
    }
    this.rows.get(table).push(Object.assign({}, row));
    return row;
  }

  update(table, id, patch) {
    this.executed.push('UPDATE ' + table);
    if (table === this.auditTable) throw new SqlError('42501', 'AUDIT_APPEND_ONLY: журнал аудита не редактируется');
    if (IMMUTABLE_GUARD && this.immutable.has(table)) {
      throw new SqlError('42501', 'GUARD_IMMUTABLE: ' + table + ' запрещено UPDATE/DELETE');
    }
    const list = this.rows.get(table) || [];
    const row = list.find((r) => r.id === id);
    if (!row) throw new SqlError('P0002', 'строка не найдена');
    Object.assign(row, patch);
    return row;
  }

  delete(table, id) {
    this.executed.push('DELETE FROM ' + table);
    if (table === this.auditTable) throw new SqlError('42501', 'AUDIT_APPEND_ONLY: журнал аудита не редактируется');
    if (IMMUTABLE_GUARD && this.immutable.has(table)) {
      throw new SqlError('42501', 'GUARD_IMMUTABLE: ' + table + ' запрещено UPDATE/DELETE');
    }
    const list = this.rows.get(table);
    const i = list.findIndex((r) => r.id === id);
    if (i < 0) throw new SqlError('P0002', 'строка не найдена');
    list.splice(i, 1);
  }

  select(table) {
    this.executed.push('SELECT * FROM ' + table);
    const all = (this.rows.get(table) || []).slice();
    const policy = this.policies.get(table);
    const st = this.rls.get(table);
    if (!policy || !st || !st.enabled) return all;
    const attr = this.role === 'toy_owner' ? { bypassrls: false } : (this.roles.get(this.role) || { bypassrls: false });
    if (attr.bypassrls) return all; // BYPASSRLS снимает фильтр (в честном мире роли его не имеют)
    if (this.role === 'toy_owner' && !(FORCE_RLS_DEFAULT && st.forced)) return all; // FORCE держит и владельца
    if (!policy.some((p) => p.roles.includes(this.role))) return [];
    return all.filter((r) => r.scope_id == null || r.scope_id === this.scope);
  }

  adminCommand(cmd) {
    this.executed.push('SELECT control.audit_runtime_admin_change(?)');
    if (AUDIT_CONTEXT_REQUIRED && this.auditContextTrigger && !cmd.context) {
      const e = new SqlError('42501', 'ADMIN_AUDIT_CONTEXT_REQUIRED');
      this.errors.push({ sqlstate: e.sqlstate, message: e.message });
      throw e;
    }
    const metadata = {};
    for (const [k, v] of Object.entries(cmd.metadata || {})) metadata[k] = REDACTED_KEYS.includes(k) ? '<redacted>' : v;
    const row = {
      id: 'audit-' + (this.rows.get(this.auditTable).length + 1),
      command: cmd.command,
      actor_principal_id: cmd.actor,
      metadata,
    };
    this.rows.get(this.auditTable).push(row);
    return row;
  }

  // Одно живое доказательство на свойство — для evidence, пишемого самим тестом.
  probeEvidence() {
    this.insert('app.document_version', { id: 'ev-1', scope_id: 'A' });
    this.setRole('brokeros_api');
    this.setScope('A');
    this.select('app.document_version');
    this.setRole('toy_owner');
    try { this.update('app.document_version', 'ev-1', { patched: true }); } catch (e) { if (!/GUARD_IMMUTABLE/.test(e.message)) throw e; }
    this.insert(this.journalTable, { id: 'j-1', command_id: 'c-1', amount_minor: 0, effect_ref: 'eff-1' });
    this.adminCommand({ command: 'UPDATE provider_connection SET enabled = NOT enabled', actor: 'toy-principal-1', context: 'ctx-1', metadata: { enabled: false, secret_locator: 's3://x' } });
    const audit = this.rows.get(this.auditTable).slice(-1)[0];
    if (audit.metadata.secret_locator !== '<redacted>') throw new SqlError('23514', 'redaction не работает');
    return this;
  }
};

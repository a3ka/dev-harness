-- toy 004: control.runtime_admin_audit, ADMIN_AUDIT_CONTEXT_REQUIRED, redaction
CREATE TABLE control.runtime_admin_audit (id text, command text, actor_principal_id text, metadata jsonb);
CREATE TRIGGER audit_runtime_admin_change BEFORE INSERT ON control.runtime_admin_audit FOR EACH ROW EXECUTE FUNCTION app.require_admin_context();

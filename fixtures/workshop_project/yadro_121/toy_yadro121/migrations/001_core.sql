-- toy 001: ядро — таблицы версий и guard_immutable (грамматика закрыта, парсер toy_pg.js)
CREATE TABLE control.schema_migration (num text, name text, sha256 text);
CREATE TABLE app.document_version (id uuid, document_id uuid, scope_id text, generated_columns jsonb);
CREATE TABLE app.approval (id uuid, document_version_id uuid, scope_id text, decision text);
CREATE TRIGGER guard_document_version BEFORE UPDATE OR DELETE ON app.document_version FOR EACH ROW EXECUTE FUNCTION app.guard_immutable();
CREATE TRIGGER guard_approval BEFORE UPDATE OR DELETE ON app.approval FOR EACH ROW EXECUTE FUNCTION app.guard_immutable();

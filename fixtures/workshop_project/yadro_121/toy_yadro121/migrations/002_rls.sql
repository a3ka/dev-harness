-- toy 002: app.has_scope_access, FORCE ROW LEVEL SECURITY, runtime-роли без bypassrls
CREATE ROLE brokeros_api NOLOGIN NOSUPERUSER NOBYPASSRLS;
CREATE ROLE toy_runtime_admin NOLOGIN NOSUPERUSER NOBYPASSRLS;
ALTER TABLE app.document_version ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.document_version FORCE ROW LEVEL SECURITY;
ALTER TABLE app.approval ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.approval FORCE ROW LEVEL SECURITY;
CREATE POLICY scoped_read ON app.document_version FOR SELECT TO brokeros_api,toy_owner USING (app.has_scope_access('core:read'));

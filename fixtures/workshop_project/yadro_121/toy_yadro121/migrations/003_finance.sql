-- toy 003: app.finance_journal — баланс команды и effect evidence
CREATE TABLE app.finance_journal (id uuid, command_id uuid, amount_minor bigint, effect_ref text);
CREATE TRIGGER journal_must_balance BEFORE INSERT ON app.finance_journal FOR EACH ROW EXECUTE FUNCTION app.assert_journal_balance();

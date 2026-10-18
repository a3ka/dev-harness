accept
OBJECT=0230ee068d10047b1be99c26747aef1bd1579bcf

Закрытый предмет арбитра V1–V5/C1–C3/A1–A3 и названные обходы кругов 3–4 выдержал независимые мутации. Нового блокирующего обхода в закрытом перечне не найдено.

Живой baseline
- Команда: `/tmp/dev-harness-verify/architect993-venv/bin/python tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/adversary993r5b/baseline` (cwd disposable repo C).
- rc=1; `FAIL_STATIC`; checks=1491; failure_ids=57 = 51 `*_source_consumers` + 5 `*_cas` + 1 `*_conditional_policy`.
- Это сохранённый owner-blocker V-1, не ложная зелень. Именованные non-consumer IDs: acknowledgeDisclosure_cas, requestAction_cas, revokeApproval_cas, revokePartnerGrant_cas, revokePartnerGrant_conditional_policy, revokePermission_cas.

Независимые CAS-мутанты (полная копия C на каждый вход; source_sha256 index синхронизировался, поэтому результат не мог быть stale-hash отказом):
- m_cond_query/updatePersonalProfile If-Match in=query: rc=1, добавлены ровно updatePersonalProfile_cas и updatePersonalProfile_conditional_policy.
- m_cond_drop/updatePersonalProfile без If-Match: rc=1, те же два ID.
- m_cond_ifm_weakstar: rc=1, те же два ID.
- m_cond_inm_rejects_star: rc=1, те же два ID.
- m_add_cond_drop/revokeAccountSession: удалён wire If-Match, добавлен лишь формально правильный conditional dict: rc=1, добавлены ровно revokeAccountSession_cas и revokeAccountSession_conditional_policy.
- m_prose_drop/string conditional profile: rc=1, добавлены ровно revokeAccountSession_cas и revokeAccountSession_conditional_policy.
- m_query/revokeAccountSession If-Match in=query: rc=1, добавлен ровно revokeAccountSession_cas.
- m_ras_optional_inline и m_ras_downgrade: каждый rc=1, добавлен ровно revokeAccountSession_cas.
- m_wildcard_schema и m_optional: каждый rc=1, добавлены ровно 44 новых `*_cas`, removed=[]; все 44 additions имеют суффикс `_cas`.
- m_v4_412_not_problem: rc=1, добавлены revokeAccountSession_cas и revokeAccountSession_problem; второй ID является ожидаемой проверкой повреждённой explicit error response, не обходом.
- A3 204-мутант revokePermission (200 response перенесён на 204): rc=1, baseline failure-set не изменился; revokePermission_cas не стал зелёным.

Позитивный контроль
- В отдельной полной копии добавлен к revokePermission настоящий required header If-Match с StrongETag schema. rc=1 только из нерешённого глобального остатка; removed=[revokePermission_cas], added=[]. Следовательно годная target-CAS ветвь проходит именно свой check, а не является постоянной краснотой.
- Полный rc0/пустой failure_ids заведомо недостижим без owner-решения 57 честных остатков. Это не подменялось зелёным контролем: frozen `probe.py --case revocations-target-cas` на исходном C вернул rc=1 (`control_rc=1`, `mutant_rc=1`, `control_green=False`, mismatch=1), как и должно при V-1.

Обязательные adversarial классы
- Неверный ответ из другого состояния: source bytes изменены без обновления operation-index.source_sha256. CLI rc=1 и добавил ровно index_source_sha256.
- Пустой вход: OpenAPI paths={} с синхронизированным source hash не объявлен чистым: прямой CLI rc=1 без PASS report; frozen probe завершился rc=2, `993 UNMEASURABLE: 'revokeAccountSession'`.
- PATH: CLI вызван абсолютным interpreter path при PATH=/definitely-missing; дал тот же структурный baseline rc=1/57 IDs. Проверка не зависит от отсутствующего PATH tool и не считает его успехом.

Сырой вывод и JSON каждого запуска:
- `/tmp/dev-harness-verify/adversary993r5b/cas-mutants/raw.json`
- `/tmp/dev-harness-verify/adversary993r5b/corrected-mutants/raw.json`
- `/tmp/dev-harness-verify/adversary993r5b/shared-header-mutants/raw.json`
- `/tmp/dev-harness-verify/adversary993r5b/edge-probes/raw.json`
- `/tmp/dev-harness-verify/adversary993r5b/frozen-probe/raw.json`

Зона
`git diff --check f7b972913ec2af0df83ce58ea34dd688870fb0e9..C` чист. Изменены 25 путей, все внутри разрешённой implementer-зоны контракта 993; удалений нет.

Совет (не блокер, вне закрытого перечня): после owner compatibility-решения V-1 повторить frozen probe на полном rc0 control, потому что текущий subject intentionally retains 57 known failures.

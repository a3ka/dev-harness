# Контракт 052 — карта переносимости (В1 плана «Перенос харнесса на Odelix»)

Статус: черновик. Doc-контракт по профилю 027 (прецедент — 048). Минт: тег `id/CONTRACT/052`
(tag-object `7abb5a4d3f8e400e874ad4acd3dac83c66267443`, `git rev-parse` живьём) + строка
`052 → 7abb5a4…` в `registry/contracts.tsv` (origin/main `135550f`; резерв 023 исполнен до
пачки). Заморозка — после круга критика (оркестратор). Работа ведётся в worktree
`/tmp/dev-harness-worktrees/775e24e1/wip-052-architect`, ветка `wip/052/architect`.

## Предмет

Норма плана владельца 2026-09-27 «ПЕРЕНОС ХАРНЕССА НА ODELIX», §В1 — дословно:

> «КАРТА ПЕРЕНОСИМОСТИ (doc-контракт 027, architect). Инвентарь ВСЕГО, что умеет харнесс:
> каждый scripts/*, .githooks/*, шаг CI, норма ролей, лаунчер, gen-harness, spawn/land/gc,
> детектор, gitw, форки, doc-приёмка. Для каждого: класс (универсален / параметр профиля /
> только для харнесса), зашитые пути и константы (file:line), зависимость от языка проекта,
> что заменяет на проекте. Счёт строк карты = счёт механизмов — командой. Это frontier
> всего переноса.»

Цель: весь функционал харнесса работает на ЛЮБОМ репо Odelix через `./workshop <репо>` без
ручных обходов, по ROADMAP Odelix. Правило переноса (план, дословно): механизм перенесён ⇔
прогон на репо Odelix (или игрушечном внешнем репо в фикстуре) дал ожидаемый rc на честном
входе И красный на обманном; минимум ДВА репо разных стеков (Rust и TS). Механизм без
предмета — строка «не переносим: <причина>» в карте, не код.

Форма: инвентарная таблица (§КАРТА) — наблюдение as-is живого дерева `135550f`, снятое
grep'ом по основному чекауту в этой пачке (Н-71: file:line живьём, не по памяти). Каждый
file:line этой карты проверяем пробой приёмки «путь живой».

## Контекст — измеренные боли плана (чекпойнт #50 HANDOFF, дословно)

1. workshop передаёт сессии ТОЛЬКО роль; AGENTS.md проекта читает omp — правила 1-16
   не доходят (workshop:575-601).
2. Барьеры привязаны к дереву dev-harness: gitw:41 (канон a3ka/dev-harness),
   verify_antiplacebo (fixtures/<ключ>/case_*.sh), зоны/заморозка/charter/done ждут
   contracts/registry/verdicts в судимом дереве.
3. Лаунчер требует git/harness_pin.json/.env (workshop:543,560,571), не создаёт и не
   описывает.
4. У продуктовых репо нет CI-гейтов харнесса, анти-плацебо, зон, паков; стеки Rust/TS —
   перенос независим от языка.

Б6-факт (закрыт этой пачкой, записан дословно): «профиль Odelix лежит в
odelix-stack/development/ODELIX-PROJECT-PROFILE.md».

## КАРТА — главная таблица

Одна строка = один механизм. Счёт строк карты = счёт механизмов (команда в §Приёмка).
Колонки: механизм | класс | зашитые пути и константы (file:line, живой grep) | зависимость
от языка проекта | что заменяет / как параметризуется на проекте.

Алфавит класса (замкнут, судится пробой приёмки):

- **универсален** — переносится в проект как есть, правок не требует;
- **параметр-профиля** — переносится, значения путей/канонов/лимитов задаёт профиль репо (В2);
- **только-харнесс** — остаётся в мастерской dev-harness и обслуживает проектные сессии
  (`./workshop` поднимает его сам), в дерево проекта не копируется;
- **не-переносим** — предмет проверки на проектах отсутствует (§Что НЕ переносим).

«Зависимость от языка» — зависимость от языка ПРОЕКТА (Rust/TS); рантайм харнесса
(bash+git+node≥26+python3+jq) одинаков для всех репо и в колонке не повторяется.

### Таблица (133 механизма)

| Механизм | класс | зашитые пути и константы (file:line) | язык | замена / параметризация на проекте |
| scripts/accept_task_commit.sh | универсален | scripts/accept_task_commit.sh:167 суффикс автора `@dev-harness.local`; норма 037 — буквальное равенство строк | нет | профиль В2: домен почты исполнителей; грамматика сравнения без правки |
| scripts/check_approval.sh | параметр-профиля | scripts/check_approval.sh:6, scripts/check_approval.sh:13 `tools.approvalMode: always-ask` в `.omp/config.yml` | нет | omp-конфиг проекта (входит в профиль В2/В3) |
| scripts/check_ceilings.sh | параметр-профиля | scripts/check_ceilings.sh:4 roles/ ≤51200 Б; scripts/check_ceilings.sh:5 AGENTS.md и `.omp/rules/` ≤30720 Б | нет | профиль: лимиты байтов персон/правил проекта |
| scripts/check_charter.sh | универсален | scripts/check_charter.sh:12 AGENTS.md — норма системы; scripts/check_charter.sh:13 ROADMAP.md в нём же | нет | устав проекта: свои AGENTS.md/ROADMAP.md и тег `ustav/1` своего репо |
| scripts/check_check_contract_ready.sh | универсален | scripts/check_check_contract_ready.sh:6 fixtures/check_check_contract_ready/case_*.sh; scripts/check_check_contract_ready.sh:14 verdicts/arbitration/ | нет | метабарьер семьи «НЕ БАРЬЕР»; предмет появляется с контрактами проекта — правки не требует |
| scripts/check_check_spec_ready.sh | универсален | scripts/check_check_spec_ready.sh:5 fixtures/check_check_spec_ready/case_*.sh | нет | метабарьер; без правки |
| scripts/check_ci_gate.sh | параметр-профиля | scripts/check_ci_gate.sh:1 вход GITHUB_TOKEN (jq/curl в теле) | нет | CI проекта (В5): свой workflow-реф и токен; «ждёт финального каталога» для org/repo Odelix на GitHub |
| scripts/check_consumers.sh | универсален | scripts/check_consumers.sh:4 окно frozen/contracts/<NNN>/<v>..HEAD; scripts/check_consumers.sh:65 registry_state 'frozen/' | нет | теги заморозок проекта; scripts/consumers.d/ маппинг переносится как есть |
| scripts/check_contract_frozen.sh | универсален | scripts/check_contract_frozen.sh:10 теги frozen/*; scripts/check_contract_frozen.sh:64 registry_state 'frozen/' | нет | теги заморозок проекта (заводятся с нуля, история харнесса не мигрирует) |
| scripts/check_contract_ready.sh | универсален | scripts/check_contract_ready.sh:1 API `<корень> <контракт>`; judge проб/зон/замеров (036) | нет | пре-фриз гейт контрактов проекта; без правки |
| scripts/check_decisions.sh | параметр-профиля | scripts/check_decisions.sh:2 реестр `decisions/`; scripts/check_decisions.sh:16 пин contracts/002-*.md | нет | профиль: ведёт ли проект свой `decisions/`;基底-контракты проекта свои |
| scripts/check_document.sh | универсален | scripts/check_document.sh:1 вход в node-часть doc-приёмки 027 | нет | doc-приёмка 027 на docs/ проекта; без правки |
| scripts/check_document.ts | универсален | scripts/check_document.ts:1 node-раннер doc-приёмки 027 | нет | без правки; предмет — доки проекта |
| scripts/check_fork_route.sh | параметр-профиля | scripts/check_fork_route.sh:192 verdicts/consultant/; scripts/check_fork_route.sh:253 `forks/<id>.md` поле ОТВЕЧЕНО | нет | профиль: ведёт ли проект forks/ (029); судимая грамматика без правки |
| scripts/check_hooks.sh | параметр-профиля | scripts/check_hooks.sh:8 .githooks/pre-commit; scripts/check_hooks.sh:9 вызов scripts/check_staged.sh | нет | package.json проекта: `hooks:install` → core.hooksPath .githooks (В5) |
| scripts/check_ids.sh | универсален | scripts/check_ids.sh:17 verdicts/adversary/; scripts/check_ids.sh:26 артефакт без номера | нет | теги id/CONTRACT/<NNN> проекта; next_id.sh без правки |
| scripts/check_judge_gate.sh | универсален | scripts/check_judge_gate.sh:5 fixtures/check_judge_gate/case_*.sh (семья «НЕ БАРЬЕР») | нет | метабарьер; без правки |
| scripts/check_metering.sh | параметр-профиля | scripts/check_metering.sh:20 дом секретов `~/.config/dev-harness/secrets.env`; scripts/check_metering.sh:92 requests.jsonl | нет | окружение сессии мастерской; URL/токен из профиля (config/metering.json) |
| scripts/check_nabludenia.sh | не-переносим | scripts/check_nabludenia.sh:4 NABLIUDENIA.md `### Н-NN.`; scripts/check_nabludenia.sh:5 NABLIUDENIA_ARCHITECT.md `### А-NN.` | нет | не переносим: предмет — журналы наблюдений мастерской; проект планом журнала не заводит (см. §Что НЕ переносим) |
| scripts/check_no_leak.sh | универсален | scripts/check_no_leak.sh:51 снапшот `${TMPDIR}/dev-harness-leak/` вне дерева; scripts/check_no_leak.sh:5 детектор утечек | нет | детектор утечек сессий: работает из мастерской над любым репо; без правки |
| scripts/check_no_rewrite.sh | универсален | scripts/check_no_rewrite.sh:1 вход `<before> <sha>` (.github/workflows/ci.yml:416) | нет | гейт пуша проекта; без правки |
| scripts/check_precision_gate.sh | универсален | scripts/check_precision_gate.sh:8 правило 7 AGENTS.md (ПЕРЕСЕЧЕНИЕ); scripts/check_precision_gate.sh:4 Н-113/Н-115 | нет | пре-фриз precision-гейт 043 контрактов проекта; без правки |
| scripts/check_protected.sh | универсален | scripts/check_protected.sh:77 verdicts/adversary/contracts-040-v5-circle.md; scripts/check_protected.sh:120 verdicts/arbitration/ | нет | защищённые артефакты проекта (список путей судим по грамматике 040) |
| scripts/check_provodka.sh | универсален | scripts/check_provodka.sh:34 charter= ровно `AGENTS.md`; scripts/check_provodka.sh:36 `$ROOT/AGENTS.md` | нет | ПРОВОДКА-гейт 038 контрактов проекта; канон цели — AGENTS.md проекта |
| scripts/check_runner_hygiene.sh | универсален | scripts/check_runner_hygiene.sh:57 AGENTS.md приёмка судьи v2; scripts/check_runner_hygiene.sh:65 carve-out правила 16 | нет | гигиена раннера анти-плацебо на CI проекта; без правки |
| scripts/check_scope_select.sh | универсален | scripts/check_scope_select.sh:5 fixtures/check_scope_select/; scripts/check_scope_select.sh:56 toy-корни scripts/fixtures | нет | селектор case_* для шардов CI проекта; без правки |
| scripts/check_scoped_run.sh | универсален | scripts/check_scoped_run.sh:16 фикстуры архитектора; scripts/check_scoped_run.sh:71 `fixtures/<bar>/<cas>.sh` | нет | интеграция scoped в раннер; без правки |
| scripts/check_skills.sh | только-харнесс | scripts/check_skills.sh:7 пин config/harness_pin.json (sha256); scripts/check_skills.sh:11 каталог skills/ из четырёх | нет | навыки кладёт мастерская в сессию; на проекте каталога skills/ нет — проверяется в мастерской |
| scripts/check_spec_ready.sh | универсален | scripts/check_spec_ready.sh:23 теги frozen/contracts/<NNN>/<v>; scripts/check_spec_ready.sh:25 окно frozen/…/1..HEAD | нет | spec-preflight 036 контрактов проекта; без правки |
| scripts/check_staged.sh | параметр-профиля | scripts/check_staged.sh:18 staged `contracts/<NNN>-*.md` (023); scripts/check_staged.sh:24 staged `registry/contracts.tsv` (031) | нет | гейт add-A над staged проекта; пути совпадают с воркфлоу проекта |
| scripts/check_threat_model.sh | универсален | scripts/check_threat_model.sh:21 verdicts/arbitration/oblast-i-porog.md; scripts/check_threat_model.sh:47 reason_weak | нет | барьер «Модель угроз» 041 контрактов проекта; python3-часть без правки |
| scripts/check_zones.sh | универсален | scripts/check_zones.sh:29 диапазон от ПЕРВОЙ заморозки frozen/contracts/<NNN>/1; scripts/check_zones.sh:37 registry/contracts.tsv | нет | зоны исполнителей из заморозок проекта; identity `-c user.name` без правки |
| scripts/ci_diag.sh | параметр-профиля | scripts/ci_diag.sh:13 GITHUB_TOKEN; scripts/ci_diag.sh:38 `$ROOT/.env` | нет | диагностика джобов CI проекта (В5); «ждёт финального каталога» для org/repo Odelix |
| scripts/done_contract.sh | универсален | scripts/done_contract.sh:2 тег done/contracts/<NNN>/<v>; scripts/done_contract.sh:33 вход `contracts/NNN-*.md` | нет | писатель done-тегов проекта; без правки |
| scripts/draft_nabludenia.sh | не-переносим | scripts/draft_nabludenia.sh:3 черновики в `${TMPDIR}/dev-harness-nabludenia/drafts/`; scripts/draft_nabludenia.sh:12 вне стерегомого | нет | не переносим: журнал наблюдений мастерской (§Что НЕ переносим) |
| scripts/drill_contract_change.sh | универсален | scripts/drill_contract_change.sh:29 Н-15; scripts/drill_contract_change.sh:87 toy `contracts/`, `verdicts/critic/` | нет | дрилл устава проекта; без правки |
| scripts/drill_exit_marker.sh | универсален | scripts/drill_exit_marker.sh:3 .omp/extensions/exit-marker.ts; scripts/drill_exit_marker.sh:21 НЕ БАРЬЕР | нет | дрилл расширения сессии; без правки |
| scripts/drill_gate_draft.sh | не-переносим | scripts/drill_gate_draft.sh:3 scripts/draft_nabludenia.sh + .omp/extensions/gate-draft.ts; scripts/drill_gate_draft.sh:6 `$WORK/{scripts,.omp/extensions}` | нет | не переносим: предмет — черновик наблюдения мастерской (§Что НЕ переносим) |
| scripts/drill_nabludenia_nechitaemo.sh | не-переносим | scripts/drill_nabludenia_nechitaemo.sh:13 chmod 000 NABLIUDENIA.md; scripts/drill_nabludenia_nechitaemo.sh:37 toy NABLIUDENIA.md | нет | не переносим: тот же предмет-журнал (§Что НЕ переносим) |
| scripts/drill_next_id_race.sh | универсален | scripts/drill_next_id_race.sh:1 вход — атомарность next_id | нет | дрилл выдачи номеров контрактов проекта; без правки |
| scripts/drill_path_guard.sh | универсален | scripts/drill_path_guard.sh:3 .omp/extensions/path-guard.ts; scripts/drill_path_guard.sh:25 НЕ БАРЬЕР | нет | дрилл стража путей сессии; без правки |
| scripts/drill_protected_exception.sh | универсален | scripts/drill_protected_exception.sh:55 toy roles/, verdicts/adversary/, plans/; scripts/drill_protected_exception.sh:56 frontmatter `verdict: verdicts/adversary/` | нет | дрилл исключений защищённых артефактов проекта; без правки |
| scripts/drill_protected_rename.sh | универсален | scripts/drill_protected_rename.sh:12 verdicts/adversary/v-1.md; scripts/drill_protected_rename.sh:15 перенос вне `verdicts/…/` | нет | дрилл честного переноса 039; без правки |
| scripts/drill_startup_digest.sh | универсален | scripts/drill_startup_digest.sh:3 nabludenia_digest + startup-digest.ts; scripts/drill_startup_digest.sh:21 указатель на HANDOFF | нет | дрилл дайджеста старта сессии; без правки |
| scripts/freeze_contract.sh | универсален | scripts/freeze_contract.sh:2 тег `frozen/<каталог>/<NNN>/<v>`; scripts/freeze_contract.sh:23 вход contracts/001-x.md + КОРЕНЬ | нет | заморозка контрактов/планов проекта; без правки |
| scripts/gc_agent_branches.sh | универсален | scripts/gc_agent_branches.sh:36 done/contracts/NNN/* реап; scripts/gc_agent_branches.sh:50 refs/tags/done/contracts/ fail-closed | нет | сборка веток wip/ проекта; без правки |
| scripts/judge_gate.sh | универсален | scripts/judge_gate.sh:1 вход — судья через CI-сигнал (008) | нет | гейт судьи контрактов проекта; без правки |
| scripts/land_agent.sh | универсален | scripts/land_agent.sh:160 блобы frozen/* до merge; scripts/land_agent.sh:166 for-each-ref refs/tags/frozen/ | нет | ленд веток wip/ проекта в его main; без правки |
| scripts/lib_registry.sh | универсален | scripts/lib_registry.sh:17 префиксы id/, frozen/, ustav/; scripts/lib_registry.sh:26 frozen/<каталог>/<NNN>/1 | нет | библиотека тегов-реестра проекта; без правки |
| scripts/lib_roles.sh | универсален | scripts/lib_roles.sh:6 verdicts/review/shag-5.md; scripts/lib_roles.sh:8 поле `verdict: verdicts/*/` | нет | разбор frontmatter ролей; без правки |
| scripts/lib_zones.sh | универсален | scripts/lib_zones.sh:5 refs/tags/frozen/contracts/; scripts/lib_zones.sh:26 контракт<TAB>frozen/contracts/<NNN>/1 | нет | зоны из заморозок проекта; без правки |
| scripts/measure_parallel_windows.sh | универсален | scripts/measure_parallel_windows.sh:2 окна контрактов §10 ROADMAP (021); scripts/measure_parallel_windows.sh:9 frozen/A/1 раньше done/B/1 | нет | мера параллельности окон контрактов проекта; без правки |
| scripts/models_actual.sh | только-харнесс | scripts/models_actual.sh:39 zones/dev в `${XDG_STATE_HOME}/dev-harness-sessions/`; scripts/models_actual.sh:47 `.omp/agents/$SESSION_ROLE.md` | нет | судит тирь сессий мастерской; на проекте не поднимается отдельно |
| scripts/nabludenia_digest.sh | не-переносим | scripts/nabludenia_digest.sh:3 указатель HANDOFF §«ГДЕ МЫ»; scripts/nabludenia_digest.sh:14 черновики из `${TMPDIR}/dev-harness-nabludenia/drafts/` | нет | не переносим: дайджест журнала наблюдений мастерской (§Что НЕ переносим) |
| scripts/next_id.sh | универсален | scripts/next_id.sh:8 резервация git-тегом (mech-2-ids); scripts/next_id.sh:15 пути VERDICT из roles/*.md поле `verdict:` | нет | выдача номеров контрактов/вердиктов проекта; без правки |
| scripts/overlay.sh | только-харнесс | scripts/overlay.sh:20 PIN=config/harness_pin.json; scripts/overlay.sh:79 modelRoles в `.omp/config.yml` | нет | слой ролей мастерской поверх бинаря omp; проектные сессии получает workshop |
| scripts/render_document.sh | универсален | scripts/render_document.sh:1 вход в node-часть рендера 027 | нет | рендер doc-приёмки 027 проекта; без правки |
| scripts/render_document.ts | универсален | scripts/render_document.ts:1 node-раннер рендера 027 | нет | без правки |
| scripts/scope_select.sh | универсален | scripts/scope_select.sh:129 traversal из fixtures/; scripts/scope_select.sh:137 `fixtures/<bar>/<cas>.sh` | нет | выбор case_* по --scope для CI проекта; без правки |
| scripts/spawn_agent.sh | универсален | scripts/spawn_agent.sh:2 ветка `wip/<NNN>/<автор>` + worktree вне стерегомого; scripts/spawn_agent.sh:99 `implementer@dev-harness.local` | нет | спавн субагентов контрактов проекта; домен почты — параметр профиля |
| scripts/verify_antiplacebo.sh | универсален | scripts/verify_antiplacebo.sh:66 соглашение `fixtures/<ключ барьера>/case_*.sh`; scripts/verify_antiplacebo.sh:585 find case_*.sh | нет | раннер анти-плацебо над корпусом фикстур проекта (В4); без правки |
| scripts/verify_ci_parity.sh | универсален | scripts/verify_ci_parity.sh:5 «каждая команда из run:» AGENTS.md; scripts/verify_ci_parity.sh:15 config/ci_parity_exceptions.txt | нет | паритет run:/приёмка для ci.yml проекта (В5); без правки |
| scripts/verify_consultant.sh | параметр-профиля | scripts/verify_consultant.sh:21 `--root` обязательный; scripts/verify_consultant.sh:27 вход `--otvet` | нет | проверка ответов консультанта (029) на forks/ проекта |
| scripts/doc_contract.ts | универсален | scripts/doc_contract.ts:276 profile ∈ {product,architecture}; scripts/doc_contract.ts:464 тег frozen/contracts/${nnn}/ | нет | ядро doc-приёмки 027; без правки |
| scripts/gen-harness.ts | только-харнесс | scripts/gen-harness.ts:3 источник `roles/*.md`; scripts/gen-harness.ts:18 config/agent_models.json + `.omp/config.yml` | нет | генерация агентов/промптов из ролей мастерской; раскладывается workshop'ом в HOME сессии |
| scripts/roles.ts | только-харнесс | scripts/roles.ts:23 роль модели `@slow`/`@advisor`; scripts/roles.ts:34 `.omp/agents/*.md` + modelRoles `.omp/config.yml` | нет | типы ролей мастерской; потребляется gen-harness |
| scripts/gitw | параметр-профиля | scripts/gitw:41 CANON `ssh://git@github.com/a3ka/dev-harness.git` (ручка GIT_EXCHANGE_GUARD_CANONICAL) | нет | профиль В2: канон проекта Odelix; git-обмены только через gitw (045) |
| scripts/consumers.d/ (6 tsv) | универсален | scripts/consumers.d/freeze_contract.sh__spawn_agent_sh.tsv и ещё 5 пар писатель→потребитель (замер census: contracts/029-auto-konsultant-forkov.md:299) | нет | маппинг потребителей писателей воркфлоу; состав — параметр набора барьеров проекта |
| scripts/proxy/metering_proxy.ts | только-харнесс | scripts/proxy/metering_proxy.ts:5 modelRoles вне `omp config list`; адрес — .env.example METERING_PROXY_URL (порт 8787 локально) | нет | прокси учёта поднимает мастерская; проектные сессии идут через URL из профиля |
| .githooks/pre-commit | параметр-профиля | .githooks/pre-commit:1 судья staged — вызов scripts/check_staged.sh | нет | hooks проекта; установка `git config core.hooksPath .githooks` (package.json:40) |
| .githooks/pre-push | параметр-профиля | .githooks/pre-push:1 чартер-суд диапазона пуша (022); кольцо CHARTER_LIB из scripts/check_charter.sh | нет | hooks проекта; ls-remote своего origin |
| .omp/extensions/exit-marker.ts | только-харнесс | scripts/drill_exit_marker.sh:3 | нет | расширение сессии; раскладывается workshop'ом |
| .omp/extensions/gate-draft.ts | не-переносим | scripts/drill_gate_draft.sh:3 | нет | не переносим: предмет — черновик наблюдения (§Что НЕ переносим) |
| .omp/extensions/path-guard.ts | только-харнесс | scripts/drill_path_guard.sh:3; норма 037 five-condition allowlist | нет | страж путей сессии; норма 037 дословно |
| .omp/extensions/rc-prefix.ts | только-харнесс | .omp/extensions/rc-prefix.ts:10 default-export factory; .omp/extensions/rc-prefix.ts:57 маркер [exit=N] | нет | префикс rc в выводе инструментов сессии |
| .omp/extensions/startup-digest.ts | только-харнесс | scripts/drill_startup_digest.sh:3 | нет | дайджест старта сессии над проектом |
| workshop (лаунчер) | параметр-профиля | workshop:559 PIN `config/harness_pin.json` проекта; workshop:571 require_metering; workshop:575-601 gen-harness промпт роли; workshop:583-586 AGENTS `$HOME/.omp/agent/agents`; workshop:111-116 `.env`; workshop:125 дом секретов | нет | В3: bootstrap пина/.env/metering для проекта; боль 1 — правила 1-16 проекта должны доходить |
| ci.yml шаг «Анти-плацебо · шард» | параметр-профиля | .github/workflows/ci.yml:87 `npm run check:antiplacebo -- --scope` (матрица 5 шардов) | нет | В5: CI проекта, шарды под тайминги репо |
| ci.yml шаг «Проверка паритета с CI» | параметр-профиля | .github/workflows/ci.yml:110 check:ci-parity | нет | В5: первый шаг ci проекта |
| ci.yml шаг «Сам-тесты раннера анти-плацебо» | параметр-профиля | .github/workflows/ci.yml:122 mktemp-корень самотеста раннера | нет | В5: самотест раннера проекта |
| ci.yml шаг «Сам-тесты check_threat_model» | параметр-профиля | .github/workflows/ci.yml:151 check:threat-model-selftest | нет | В5 |
| ci.yml шаг «Сам-тесты семьи ПРОВОДКА» | параметр-профиля | .github/workflows/ci.yml:173 check:provodka-family-selftest | нет | В5 |
| ci.yml шаг «Проба слабых реализаций меры параллельности» | параметр-профиля | .github/workflows/ci.yml:181 check:measure-probe | нет | В5 |
| ci.yml шаг «Барьер scoped-селектора» | параметр-профиля | .github/workflows/ci.yml:185 check:scope-select | нет | В5 |
| ci.yml шаг «Барьер интеграции scoped в раннер» | параметр-профиля | .github/workflows/ci.yml:189 check:scoped-run | нет | В5 |
| ci.yml шаг «Предполётный гейт автора» | параметр-профиля | .github/workflows/ci.yml:194 check:contract-ready | нет | В5 |
| ci.yml шаг «Doc-приёмка» | параметр-профиля | .github/workflows/ci.yml:200 check:document | нет | В5 |
| ci.yml шаг «Пре-фриз precision-гейт» | параметр-профиля | .github/workflows/ci.yml:213 check:precision-gate | нет | В5 |
| ci.yml шаг «Сам-тесты семьи precision-гейт» | параметр-профиля | .github/workflows/ci.yml:229 check:precision-family-selftest | нет | В5 |
| ci.yml шаг «Батарея гигиены парсинга» | параметр-профиля | .github/workflows/ci.yml:246 check:precision-battery | нет | В5 |
| ci.yml шаг «Сам-тесты pre-exchange гард» | параметр-профиля | .github/workflows/ci.yml:269 check:gitw-family-selftest | нет | В5 |
| ci.yml шаг «Спек-точность пре-фриз» | параметр-профиля | .github/workflows/ci.yml:275 check:spec-ready на живом контракте | нет | В5: вход — замороженный контракт проекта |
| ci.yml шаг «Судья через CI-сигнал» | параметр-профиля | .github/workflows/ci.yml:280 check:judge-gate | нет | В5 |
| ci.yml шаг «Гигиена раннера + форма нормы приёмки» | параметр-профиля | .github/workflows/ci.yml:286 check:runner-hygiene | нет | В5 |
| ci.yml шаг «Грамматика наблюдений» | не-переносим | .github/workflows/ci.yml:293 check:nabludenia | нет | не переносим: предмет — NABLIUDENIA мастерской (§Что НЕ переносим) |
| ci.yml шаг «Дрилл — черновик наблюдения на отказ гейта» | не-переносим | .github/workflows/ci.yml:298 drill:gate-draft | нет | не переносим: тот же предмет |
| ci.yml шаг «Дрилл — дайджест старта сессии» | универсален | .github/workflows/ci.yml:303 drill:startup-digest | нет | В5 |
| ci.yml шаг «Дрилл — нечитаемость файлов наблюдений» | не-переносим | .github/workflows/ci.yml:309 drill:nabludenia-nechitaemo | нет | не переносим: тот же предмет |
| ci.yml шаг «Генератор ролей под чек» | параметр-профиля | .github/workflows/ci.yml:312 check:gen | нет | В5 |
| ci.yml шаг «Selftest прокси учёта» | параметр-профиля | .github/workflows/ci.yml:319 metering:selftest | нет | В5 |
| ci.yml шаг «Проверка уникальности идентификаторов артефактов» | параметр-профиля | .github/workflows/ci.yml:323 check:ids | нет | В5 |
| ci.yml шаг «Скилы подлинны и комплектны» | только-харнесс | .github/workflows/ci.yml:328 check:skills | нет | проверка каталога skills/ мастерской; на CI проекта шага нет |
| ci.yml шаг «Потолки документов» | параметр-профиля | .github/workflows/ci.yml:333 check:ceilings | нет | В5: лимиты персон/правил проекта |
| ci.yml шаг «Реестр решений: состав и грамматика» | параметр-профиля | .github/workflows/ci.yml:339 check:decisions | нет | В5 |
| ci.yml шаг «Режим входа — политика подтверждений» | параметр-профиля | .github/workflows/ci.yml:346 check:approval | нет | В5 |
| ci.yml шаг «Механизм pre-commit коммичен» | параметр-профиля | .github/workflows/ci.yml:353 check:hooks | нет | В5: hooks проекта |
| ci.yml шаг «Замороженные планы и контракты неизменны» | параметр-профиля | .github/workflows/ci.yml:359 check:contract-frozen | нет | В5: теги заморозок проекта |
| ci.yml шаг «Зоны исполнителей» | параметр-профиля | .github/workflows/ci.yml:365 check:zones | нет | В5 |
| ci.yml шаг «Устав не меняется без слова владельца» | параметр-профиля | .github/workflows/ci.yml:370 check:charter | нет | В5: устав проекта |
| ci.yml шаг «Дрилл: изменение устава по процедуре принимается» | параметр-профиля | .github/workflows/ci.yml:375 drill:contract-change | нет | В5 |
| ci.yml шаг «Дрилл — атомарность выдачи номеров» | параметр-профиля | .github/workflows/ci.yml:381 drill:next-id-race | нет | В5 |
| ci.yml шаг «Защищённые артефакты не исчезали» | параметр-профиля | .github/workflows/ci.yml:384 check:protected | нет | В5 |
| ci.yml шаг «Дрилл: явное разрешение принимается» | параметр-профиля | .github/workflows/ci.yml:389 drill:protected-exception | нет | В5 |
| ci.yml шаг «Дрилл: честный перенос распознаётся» | параметр-профиля | .github/workflows/ci.yml:394 drill:protected-rename | нет | В5 |
| ci.yml шаг «Счётчик git-вызовов check_zones» | параметр-профиля | .github/workflows/ci.yml:402 check:zones-call-budget | нет | В5 |
| ci.yml шаг «Счётчик git-вызовов check_protected» | параметр-профиля | .github/workflows/ci.yml:408 check:protected-call-budget | нет | В5 |
| ci.yml шаг «История не перезаписана» | параметр-профиля | .github/workflows/ci.yml:416 check:no-rewrite по github.event.before | нет | В5: события пуша своего CI |
| роль orchestrator | параметр-профиля | .omp/agents/orchestrator.md:5 `model: ["@default"]` | нет | профиль моделей проекта; текст нормы переносим целиком |
| роль architect | параметр-профиля | .omp/agents/architect.md:5 `model: ["@slow"]` | нет | то же |
| роль implementer | параметр-профиля | .omp/agents/implementer.md:5 `model: ["@task"]` | нет | то же |
| роль critic | параметр-профиля | .omp/agents/critic.md:5 `model: ["@apex"]` | нет | то же |
| роль adversary | параметр-профиля | .omp/agents/adversary.md:5 `model: ["@advisor"]` | нет | то же |
| роль reviewer | параметр-профиля | .omp/agents/reviewer.md:5 `model: ["@audit"]` | нет | то же |
| роль arbiter | параметр-профиля | .omp/agents/arbiter.md:5 `model: ["@plan"]` | нет | то же |
| роль consultant | параметр-профиля | .omp/agents/consultant.md:5 `model: ["@consultant"]` | нет | то же; предмет forks/ проекта |
| роль steward | параметр-профиля | .omp/agents/steward.md:5 `model: ["@steward"]` | нет | то же |
| опора package.json | параметр-профиля | package.json:40 `"hooks:install": "git config core.hooksPath .githooks"` | нет | npm run карта CI проекта (В5) + установка hooks |
| опора AGENTS.md | параметр-профиля | scripts/check_runner_hygiene.sh:57 приёмка судьи v2; scripts/check_charter.sh:12 | нет | норма 1-16 проекта — своя; боль 1: обязательная доставка в сессию проекта (В3) |
| опора .omp/config.yml | параметр-профиля | .omp/config.yml:42 `approvalMode: always-ask`; .omp/config.yml:44 modelRoles из config/agent_models.json | нет | omp-конфиг проекта (В2/В3) |
| опора config/ (pin, metering, models, exceptions) | параметр-профиля | scripts/overlay.sh:20 harness_pin.json; scripts/gen-harness.ts:18 agent_models.json; scripts/verify_ci_parity.sh:15 ci_parity_exceptions.txt; workshop:465 models-src | нет | пин omp-версии и исключения паритета — свои у каждого репо; agent_models/models-*.yml — мастерская |
| опора .env.example + дом секретов | параметр-профиля | workshop:125 `~/.config/dev-harness/secrets.env`; .env.example METERING_PROXY_URL (порт 8787 локально) | нет | В3: bootstrap окружения проектной сессии (боль 3) |
| опора skills/ (4 навыка) | только-харнесс | scripts/check_skills.sh:11 каталог из четырёх | нет | канон навыков мастерской; в проект не копируется |
| опора fixtures/ (корпус анти-плацебо) | универсален | scripts/verify_antiplacebo.sh:66 `fixtures/<ключ>/case_*.sh`; 60 семей (каталог) | нет | В4: корпус красных предъявлений под барьеры проекта; формат без правки |

Счёт: 69 scripts/ + 2 .githooks/ + 5 .omp/extensions/ + 1 workshop + 40 ci.yml-шагов + 9
ролей + 7 опора = **133 механизма**. Команда счёта — §Приёмка (проба 1 и замеры census).

## Что НЕ переносим (правило плана)

Механизмы без предмета проверки на проектах Odelix (предмет — журналы наблюдений и
черновики наблюдений мастерской; план перенос наблюдений на проекты не включает):

- scripts/check_nabludenia.sh — не переносим: судит NABLIUDENIA.md/NABLIUDENIA_ARCHITECT.md
  мастерской; проект планом журнала не заводит.
- scripts/nabludenia_digest.sh — не переносим: дайджест тех же журналов + указатель HANDOFF.
- scripts/draft_nabludenia.sh — не переносим: черновики наблюдений в TMPDIR мастерской.
- scripts/drill_nabludenia_nechitaemo.sh — не переносим: дрилл нечитаемости тех же файлов.
- scripts/drill_gate_draft.sh — не переносим: дрилл черновика наблюдения на отказ гейта.
- .omp/extensions/gate-draft.ts — не переносим: extension дописания черновиков наблюдений.
- ci.yml-шаги check:nabludenia, drill:gate-draft, drill:nabludenia-nechitaemo — не
  переносим: проводка непереносимых механизмов (три строки выше).

Не мигрируют артефакты (не механизмы): теги `id/CONTRACT/*`, `frozen/*`, `done/*`,
`ustav/*` и история git харнесса — каждый репо Odelix заводит свои с нуля; тела
NABLIUDENIA*.md/HANDOFF.md/ROADMAP.md мастерской остаются в dev-harness. Включение
журнала наблюдений проекту — отдельное слово владельца (сейчас его нет).

## Каталоги Odelix — временная версия

Слово владельца 2026-09-27: финальную версию каталогов сбросит позже; до неё привязки к
структуре репо Odelix считать UNVERIFIED и работ, зависящих от структуры (Б4, Г2/Г3), не
начинать. Ячейки карты, зависящие от структуры репо Odelix, помечены «ждёт финального
каталога» (check_ci_gate.sh, ci_diag.sh — org/repo на GitHub; стек-шаги CI проекта — В5).
Замены через профиль В2 (пути воркфлоу: contracts/, registry/, verdicts/, fixtures/) от
каталогов Odelix не зависят — грамматика путей едина для любого репо.

Б6-факт (дословно): «профиль Odelix лежит в odelix-stack/development/ODELIX-PROJECT-
PROFILE.md».

## Зоны

ЗОНА architect: contracts/052-karta-perenosimosti.md

РАБОТА НЕ РАЗДАЁТСЯ: карта — единый doc-артефакт frontier, одна таблица = один предмет;
потребители (контракты В2 профиля, В4 барьеров, В5 CI репо) читают её как вход, не
редактируют; правки карты — только architect следующей пачкой по слову владельца.

## ПРОВОДКА

ПРОВОДКА: новый нормы этот doc-контракт не вводит; предмет — инвентарь as-is. Проводка
существующих норм не меняется: классы/замены карты становятся входом контрактов В2/В4/В5
(оркестратор раздаёт); приёмка — как у прецедента 048 (doc-контракт 027, калибровка
check_spec_ready/check_consumers).

## Приёмка

Приёмка оркестратора в worktree — обе зелёные до коммита (пишутся без маркера пробы,
чтобы гейт не запускал сам себя): bash scripts/check_spec_ready.sh .
contracts/052-karta-perenosimosti.md → rc=0; bash scripts/check_consumers.sh .
contracts/052-karta-perenosimosti.md → rc=0.

Инвентарные предъявления doc-профиля 027 — исполняемые команды с корня дерева
(fenced-блок; каждая обязана давать rc=0 на этом черновике, красная ветвь печатает
именованную причину в echo; грамматике В1-проб эти строки не соответствуют
сознательно — их второй токен не обязан существовать путём):

```
bash -c 'n=$(grep -c "^| " contracts/052-karta-perenosimosti.md); [ "$n" -eq 134 ] || { echo "строк таблицы $n != 134 (шапка + 133 механизма)"; exit 1; }'
bash -c 'c(){ n=$(grep -c "^| $1" contracts/052-karta-perenosimosti.md); [ "$n" -eq "$2" ] || { echo "строк секции «$1» $n != $2"; ec=1; }; }; ec=0; c "scripts/" 69; c ".githooks/" 2; c ".omp/extensions/" 5; c "workshop" 1; c "ci.yml шаг" 40; c "роль " 9; c "опора " 7; exit $ec'
awk -F'|' '/^\| /{if($2~/Механизм/)next; for(i=2;i<=6;i++)if($i~/^[ \t]*$/){print "пустая колонка в строке " NR; bad=1} if($3!~/универсален|параметр-профиля|только-харнесс|не-переносим/){print "класс вне алфавита в строке " NR ": " $3; bad=1}} END{exit bad}' contracts/052-karta-perenosimosti.md
bash -c 'grep -oE "([A-Za-z0-9_-]+\.[A-Za-z0-9_-]+|[A-Za-z0-9_.-]+/[A-Za-z0-9_./-]+):[0-9]+" contracts/052-karta-perenosimosti.md | sort -u | while IFS=: read -r f l; do awk -v n="$l" "NR==n{ok=1} END{exit !ok}" "$f" || { echo "file:line не существует живьём: $f:$l"; exit 1; }; done'
bash -c 'ec=0; for f in scripts/*.sh scripts/*.ts scripts/gitw; do grep -q "^| $f |" contracts/052-karta-perenosimosti.md || { echo "нет строки карты: $f"; ec=1; }; done; for f in .githooks/pre-commit .githooks/pre-push .omp/extensions/exit-marker.ts .omp/extensions/gate-draft.ts .omp/extensions/path-guard.ts .omp/extensions/rc-prefix.ts .omp/extensions/startup-digest.ts; do grep -q "^| $f |" contracts/052-karta-perenosimosti.md || { echo "нет строки карты: $f"; ec=1; }; done; grep -q "^| workshop " contracts/052-karta-perenosimosti.md || { echo "нет строки workshop"; ec=1; }; grep -q "^| scripts/consumers.d/" contracts/052-karta-perenosimosti.md || { echo "нет строки consumers.d"; ec=1; }; grep -q "^| scripts/proxy/metering_proxy.ts |" contracts/052-karta-perenosimosti.md || { echo "нет строки proxy"; ec=1; }; for l in $(grep -n "run:" .github/workflows/ci.yml | cut -d: -f1); do grep -q "ci.yml:$l" contracts/052-karta-perenosimosti.md || { echo "нет строки карты для ci.yml run: строка $l"; ec=1; }; done; exit $ec'
```

Проба В1 (зелёная на черновике; единственная строка файла в грамматике проб гейта):

- `bash scripts/check_consumers.sh . contracts/052-karta-perenosimosti.md` → красная: писатель окна 052 без пробы потребителя

Замеры census (В2 spec_ready):

замер: `ls scripts/*.sh | wc -l` = 61 census scripts/*.sh
замер: `ls scripts/*.ts | wc -l` = 5 census scripts/*.ts
замер: `ls .omp/agents/*.md | wc -l` = 9 census .omp/agents/*.md
замер: `ls .githooks/* | wc -l` = 2 census .githooks/*
замер: `ls .omp/extensions/*.ts | wc -l` = 5 census .omp/extensions/*.ts

Имя счёта карты: `grep -c "^| " contracts/052-karta-perenosimosti.md` = 134 (1 шапка +
133 механизма; команды проб 1-2 своряют и по секциям).

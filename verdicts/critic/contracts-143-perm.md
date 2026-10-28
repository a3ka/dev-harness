accept
OBJECT=f7e95185cb0a951ef6d479466b77862b368fa427
СУД: repo=dev-harness; предмет=143; фаза=реализация-правка модели (permissions по живой приёмке); роль=critic; вызов=1/2; модель-план=роль critic; сессия=01a18227-2cba-76c6-869f-3f578bbb7fd5; модель-факт=openai-codex/gpt-6-sol; SHA=f7e95185cb0a951ef6d479466b77862b368fa427; предыдущий=Crit143r4 accept (развязка пинов 117); исключение=нет. Трейс автора Perm143: сессия=01a18210-da88-7599-8db6-affa7ff4dda6; модель-факт=zai/glm-5.3; независимость подтверждена по session/model_change обоих трейсов.

ИТОГ: блокирующих находок нет. Это суд коммита модели, НЕ утверждение о зелёном повторе живого CI на новой версии workflow. Текст замороженного 143/1 не правился, привязку стабов задаёт код/source.json (Н-39), не проза.

1. Факт/закрытие. `git cat-file -t f7e95185cb0a951ef6d479466b77862b368fa427 && git rev-parse HEAD` в клоне архитектора и затем в собственном клоне: `commit` / `f7e95185cb0a951ef6d479466b77862b368fa427`, rc 0. `gh run view 40650367385 --repo a3ka/Complior-mob --json jobs --jq '.jobs[] | select(.name | startswith("e2e-")) | [.name,.conclusion,.databaseId] | @tsv'` → rc 0, сырой вывод:
```
e2e-start	failure	122691212967
e2e-splash	failure	122691212996
e2e-erstinformation	failure	122691213015
e2e-first-run	failure	122691213041
e2e-pilot	failure	122691213083
```
`gh run view 40650367385 --repo a3ka/Complior-mob --json jobs --jq '.jobs[] | select(.name=="select-screens" or .name=="quality" or .name=="build-apk" or .name=="android-e2e") | [.name,.conclusion] | @tsv'` → rc 0: `select-screens success`, `quality success`, `build-apk success`, `android-e2e failure`. Run head `5ea59a1169bdf6cade6dd1d650376c8ddd895a97`, created `2026-10-28T07:29:04Z`, conclusion `failure` (`gh run view --json headSha,createdAt,conclusion`, rc 0).
Логи `/tmp/dev-harness-verify/Crit143p/gh-cli-cache/run-log-40650367385-1793172544.zip:{3_e2e-start,4_e2e-splash,5_e2e-first-run,6_e2e-erstinformation,2_e2e-pilot}.txt` прочитаны по пяти членам архива: каждый на `gh run download "40650367385" --name "$IMJA_ARTEFAKTA"` с GH_TOKEN получает `error fetching artifacts: HTTP 403: Resource not accessible by integration (https://api.github.com/repos/a3ka/Complior-mob/actions/runs/40650367385/artifacts?per_page=100)` и `Process completed with exit code 1`. Два исходных лога из задания (`e2e136-122691212996.log`, `e2e136-122691213041.log`) совпадают. Документация GitHub `REST permissions-required-for-github-apps#repository-permissions-for-actions`: GET `/actions/runs/{run_id}/artifacts` и GET архива — Actions/read. Модель: ровно пять job с `GH_TOKEN: ${{ github.token }}`, по одному `gh run download` каждому; у `select-screens`, `quality`, `build-apk`, `android-e2e`, `mobile-regression-signal` ни вызова `gh run download`, ни `GH_TOKEN`. Других gh run view/gh pr/checks/statuses в YAML нет. `upload-artifact@v7` использует пакет @actions/artifact с `ACTIONS_RUNTIME_TOKEN` (`actions/toolkit/packages/artifact/src/internal/shared/config.ts:getRuntimeToken`), не требует разрешения Actions/write; `actions/cache` в модели отсутствует.

2. Права и безопасность. PyYAML-разбор `model/.github/workflows/mobile.yml`: workflow-level ровно `{contents: read}`; у `e2e-splash` (строка 451), `e2e-first-run` (644), `e2e-erstinformation` (842), `e2e-start` (1100), `e2e-pilot` (1258) job-level ровно `{contents: read, actions: read}`; остальные пять jobs наследуют workflow-level. Job-level заменяет общий набор (GitHub Workflow syntax §jobs.<job_id>.permissions: все неуказанные permissions становятся `none`), поэтому `contents: read` повторён для checkout приватного продукта и публичного `a3ka/dev-harness` (`gh repo view ... --json visibility`: PRIVATE/PUBLIC, обе команды rc 0). Во ВСЕХ checkout `persist-credentials: false`; ни одного `write` в разрешениях. Для fork pull_request GitHub допускает добавление read, но обычно не write; здесь write не запрошен. Селектор имеет отдельный старый fallback `gh api pulls/N{,/files}` без GH_TOKEN/`pull-requests: read`; на PR checkout селектора `fetch-depth: 0`, сначала git merge-base, при сбое git и API — `NET_BAZY`/`OSIBKA_DIFFA`, а не зелёный пустой выбор. См. СОВЕТ ниже.

3. Адресность. `git diff --name-only f3c18d3c6a867d18268363051dc8977639b28720 HEAD` → только `fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml` и `fixtures/workshop_project/mob_ci_143/source.json`, оба внутри `ЗОНА architect` (`contracts/143-mob-ci-razdelenie.md:140`). PyYAML-разбор base/HEAD после удаления пяти новых permission maps совпал полностью: никакой другой YAML-семантики не изменено. `git diff --check BASE HEAD` → rc 0. `sha256sum fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml` → `7e4b292c836ccd5a530d831560671b1465f3847045d1eb90993d16e63ed829d5`, совпадает с `source.json:.piny` (прежний `22e26f22…`). Числа source.json: клетки 69 (S25/A17/Y22/F4/P1), стабы 33, привязки 49, пины 12+9=21; census model/nositeli/stabs/drafts = 4/8/33/9. `git diff --exit-code frozen/contracts/143/1 HEAD -- contracts/143-mob-ci-razdelenie.md` → rc 0; тег origin `frozen/contracts/143/1` и локальный тег оба `438ccbbf24246887373a05a7f6a6ce3514b44dfc`.

4. Исполненные прогоны из клона OBJECT (корень `/tmp/dev-harness-verify/Crit143p/repo`):
```
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model  # 3 × rc 0
клеток 69, зелёных 69, красных 0
клеток 69, зелёных 69, красных 0
клеток 69, зелёных 69, красных 0
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs  # rc 0
клеток 69, зелёных 69, красных 0
стабов 33, привязок 49, непойманных 0
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh  # rc 1
клеток 69, зелёных 0, красных 69 — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)
```
`python3 prove143.py` (одноразовый адаптер Fix143r2/{sanity,krasnye,zeljonye,porcha_pinov}.py, удалён после прогона) → rc 0; сырой значимый вывод:
```
SANITY OK
контроль double-exact (retired после хорошего, до P): rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml'
OK: красна РОВНО p01, причина именована (rglob)
плохой, затем хороший (эффективный хороший): rc=0  клеток 69, зелёных 69, красных 0
OK: честная запись зелена 69/69
('пин', 'model/.github/workflows/mobile.yml') model/.github/workflows/mobile.yml → rc=2 ORACLE_TAMPERED: пин: sha256 model/.github/workflows/mobile.yml
('пин', 'model/mobile/ci-screens.json') model/mobile/ci-screens.json → rc=2 ORACLE_TAMPERED: пин: sha256 model/mobile/ci-screens.json
('пин', 'model/mobile/scripts/ci-aggregate.cjs') model/mobile/scripts/ci-aggregate.cjs → rc=2 ORACLE_TAMPERED: пин: sha256 model/mobile/scripts/ci-aggregate.cjs
('пин', 'model/mobile/scripts/select-ci-screens.cjs') model/mobile/scripts/select-ci-screens.cjs → rc=2 ORACLE_TAMPERED: пин: sha256 model/mobile/scripts/select-ci-screens.cjs
('пин', 'nositeli/api/pull-124-files-stranitsa.json') nositeli/api/pull-124-files-stranitsa.json → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/pull-124-files-stranitsa.json
('пин', 'nositeli/api/pull-124-files.json') nositeli/api/pull-124-files.json → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/pull-124-files.json
('пин', 'nositeli/api/pull-124.json') nositeli/api/pull-124.json → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/pull-124.json
('пин', 'nositeli/api/run-40426209738-jobs.json') nositeli/api/run-40426209738-jobs.json → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/run-40426209738-jobs.json
('пин', 'nositeli/ci-e2e-995-4.sh') nositeli/ci-e2e-995-4.sh → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/ci-e2e-995-4.sh
('пин', 'nositeli/mobile-124.yml') nositeli/mobile-124.yml → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/mobile-124.yml
('пин', 'nositeli/p-4ac99af9.py') nositeli/p-4ac99af9.py → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/p-4ac99af9.py
('пин', 'nositeli/pilot-66052cdf.yaml') nositeli/pilot-66052cdf.yaml → rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/pilot-66052cdf.yaml
('черновик', 'drafts/111-v5-draft.md') drafts/111-v5-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 111-v5-draft.md
('черновик', 'drafts/116-v4-draft.md') drafts/116-v4-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 116-v4-draft.md
('черновик', 'drafts/117-v5-draft.md') drafts/117-v5-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 117-v5-draft.md
('черновик', 'drafts/118-v3-draft.md') drafts/118-v3-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 118-v3-draft.md
('черновик', 'drafts/123-v3-draft.md') drafts/123-v3-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 123-v3-draft.md
('черновик', 'drafts/138-v2-draft.md') drafts/138-v2-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 138-v2-draft.md
('черновик', 'drafts/139-v3-draft.md') drafts/139-v3-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 139-v3-draft.md
('черновик', 'drafts/141-v2-draft.md') drafts/141-v2-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 141-v2-draft.md
('черновик', 'drafts/995-v5-draft.md') drafts/995-v5-draft.md → rc=2 ORACLE_TAMPERED: черновик: sha256 995-v5-draft.md
('retired-нагрузка', 'stabs/p-66052cdf.py') stabs/p-66052cdf.py → rc=2 ORACLE_TAMPERED: retired-нагрузка: sha256 stabs/p-66052cdf.py
('retired-нагрузка удалена', 'stabs/p-66052cdf.py') stabs/p-66052cdf.py → rc=2 ORACLE_TAMPERED: retired-нагрузка: файла нет stabs/p-66052cdf.py
('retired-нагрузка ПОДМЕНЕНА хорошим P', 'stabs/p-66052cdf.py (podmena)') stabs/p-66052cdf.py → rc=2 ORACLE_TAMPERED: retired-нагрузка: sha256 stabs/p-66052cdf.py
ИТОГ: порча каждого из 21 пина и все три случая retired-нагрузки → rc 2 ORACLE_TAMPERED
```
`bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` → rc 0 `SVJAZI 60`; `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs` → rc 0 `SVJAZI 66`, `zhivykh 0`. `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs`: первая попытка ограничена 120 с и прервана timeout, повтор с дедлайном 360 с завершил 69 связей, сырой финал `SVJAZI 69\nzhivykh 0` (код 0 [INFERENCE: вывод и контракт скрипта, числовой exit code фонового инструмента не показан]). `PYTHONDONTWRITEBYTECODE=1 bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit143p/repo contracts/143-mob-ci-razdelenie.md` → rc 0 `OK`, `__pycache__` не возник; `bash scripts/check_charter.sh` → rc 0 `уставных документов: 141 · изменений в них: 355 · с разрешения: 355`. Последним гейтом `bash zone_gate.sh` (одноразовая обёртка, удалена после прогона): полный `bash /tmp/dev-harness-verify/Crit143p/repo/scripts/check_zones.sh /tmp/dev-harness-verify/Crit143p/repo` → сырой финал `замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 35658 · проверено по зонам: 7806`, `ZONE_RC=0`, за 317.84 с. До этого первый вызов прерван дедлайном 360 с, второй полный дал тот же финал без числового rc (457.22 с); заключительный — с явным `ZONE_RC=0`. Независимая scoped-проверка `git diff --name-only HEAD~1..HEAD` ⊆ `fixtures/workshop_project/mob_ci_143/` → rc 0.

СОВЕТ fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:51 — `select-screens` вызывает fallback `model/mobile/scripts/select-ci-screens.cjs:132-174` без GH_TOKEN и `pull-requests: read`, если git merge-base недоступен. PR в этом состоянии остановится именованным отказом, а не ложно позеленеет; вне адреса прав работников.

СОВЕТ fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:451 — батарея не судит rights: собственная мутация на одноразовой копии, удаление `actions: read` у `e2e-splash`, команда `python3 permission_probe.py` (удалён после прогона) → сырой вывод `one worker missing actions: read: 0 ['клеток 69, зелёных 69, красных 0']`. Это честный остаток контрактной §Модель угроз НЕ ЗАЩИЩАЕТ живое исполнение GitHub Actions (включая получение артефакта): 143/1 не обещает проверку token permissions батареей, а живое исполнение — отдельная приёмка. Для данного OBJECT права присутствуют; искусственно зелёный W без них НЕ считается достаточным доказательством живой работы, поэтому находка вне защищаемой границы, не блокер этого cutover.

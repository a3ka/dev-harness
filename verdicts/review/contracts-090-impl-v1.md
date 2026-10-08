accept

# Вердикт reviewer: контракт 090, реализация (wip/090/implementer), круг 1

- Судимая ревизия: HEAD `90e82e0` (implementer), над ним `c83d516` (architect, фикстуры) и `8ce382a` (orchestrator, freeze). Worktree `/tmp/dev-harness-worktrees/c907157c/wip-090-implementer`.
- Контракт прочитан из блоба заморозки: `git show frozen/contracts/090/1^{commit}:contracts/090-fix-orch-peak-home-install-safe-dir.md` (тег → коммит `e2fb6a4`; tag-object `b0d92489…` = строка 090 в registry/contracts.tsv).
- Блокирующих находок нет. Ниже 5 советов (не блокируют).

## 1. Область правки — СООТВЕТСТВУЕТ
`git diff --stat c83d516 HEAD` → ровно 4 файла: `.github/workflows/ci.yml` (10 +5/-5), `ops/server/install.sh` (4), `ops/server/root/orch-peak` (3), `registry/ci-steps.tsv` (1) — это в точности строка `ЗОНА implementer` замороженного текста. `scripts/lib_session.sh`, `scripts/orch_restart.sh` не тронуты.
Своя мера по коммитам (`git diff-tree --name-only -r`, `git log --format=%an`): `8ce382a` orchestrator → только `registry/contracts.tsv` (минт-заморозка); `c83d516` architect → только `fixtures/_krasnye_090.sh` + `fixtures/fix_090_orch_peak_home/*` (8 файлов, ЗОНА architect); `90e82e0` implementer → 4 файла ЗОНА implementer. `git rev-list --count frozen/contracts/090/1..HEAD` → 3.
`reslop t -- bash scripts/check_zones.sh` → `exit: 0`, passed 81, failed 0 (зоны читаются из блоба тега, не из дерева — потому отсутствие файла контракта в этой ветке суд зон не обнуляет).
Дельта ci.yml — только 5 строк `keys:` генерируемых блоков. Своя мера множеств ключей lane (python по `git show <rev>:ci.yml`): до 97 уникальных, после 98; добавлен ровно `check:fix-085-orch-peak-home-090-family-selftest`, удалено 0 — перетасовка шардов есть работа LPT-генератора, не ручная правка.

## 2. Сырой вывод — ЕСТЬ
Тело коммита `90e82e0` несёт сырой вывод `bash fixtures/_krasnye_090.sh` (после фикса, `ИТОГ 090: rc=0`), baseline до фикса и grep-строки приёмки п.6. Счётные утверждения сверены своей мерой (п.7 ниже).

## 3. Проверка не подогнана — ЧИСТО
`git log --format='%h %an' --all -- fixtures/fix_090_orch_peak_home fixtures/_krasnye_090.sh` → только architect (`a581413`, `c83d516`). `git diff --stat wip/090/architect HEAD -- fixtures/fix_090_orch_peak_home fixtures/_krasnye_090.sh` → пусто (rc 0): фикстуры на ветке реализации побайтово равны фикстурам architect-ветки. Implementer файлов проверок не касался.

## 4. Красное предъявлено — ДА, своей мерой
Дерево `c83d516` (до фикса, `git archive` в `/tmp/dev-harness-verify`):
- `red_no_home_ctx.sh` rc=1 — `scripts/lib_session.sh: line 18: HOME: unbound variable`
- `red_ctx_deep_no_home.sh` rc=1 — то же unbound в LIBSRC-копии
- `red_install_local_config.sh` rc=1 — ✗A, ✗B, ✓C, ✗D (совпадает с заявлением автора «A/B/D»)
- `battery_stubs.sh` rc=0 (3/3 пойманы — по контракту работает и до фикса)
- `red_hermetic_no_real_sessions.sh` rc=0 (по контракту rc 0 и до, и после)
Собственные мутации ФИКСА (копии HEAD, правка python-скриптом):
- m1 убран посев `ORCH_SESS_GLOB` → лёгкая rc=1, глубокая rc=1
- m2 убран knob `ORCH_UHOME` → лёгкая rc=0 (ожидаемо: ей knob не нужен), глубокая rc=1 «маркер перезапуска не поставлен»
- m3 посев перенесён ПОСЛЕ `. lib_session.sh` → лёгкая rc=1 (unbound), глубокая rc=1
- m6 посев пустой строкой `ORCH_SESS_GLOB=""` → обе rc=1
- m4 hooksPath назад на `config --local` → install rc=1; m5 autoSetupMerge назад на `--local` → install rc=1
Каждая из трёх правок (П1 посев, П3 knob, П2 обе читалки) держится отдельной клеткой.

## 5. Атомарность — ДА
Один коммит implementer `90e82e0` со ссылкой на 090; П1/П2/П3 + CI-проводка — одно задание одной зоны одного замороженного контракта.

## 6. Норма не тронута — ДА
В диффе нет `roles/`, `AGENTS.md`, `contracts/`, норм-документов.

## 7. Заявленное = сделанное (своя мера)
- `bash fixtures/_krasnye_090.sh` (изолированно) → `RC=0`, 5 строк `rc=0`, `ИТОГ 090: rc=0`, 22.09 с.
- Прогон того же ключа через CI-раннер `bash scripts/run_ci_lane.sh check:fix-085-orch-peak-home-090-family-selftest` → lane_rc=1, красна ТОЛЬКО `red_hermetic_no_real_sessions.sh`; названный путь — `.../--home-harness-dev-harness--/2026-10-08T09-15-33-359Z_…/Adversary090.jsonl` (журнал параллельно работающего субагента-адверсария, не путь семьи). Перепрогон клетки одной, изолированно → rc=0. Класс шума, названный оркестратором и границей контракта; не дефект реализации.
- Приёмка п.6: `grep -n 'config --local' ops/server/install.sh` → пусто (rc 1); `grep -n ORCH_UHOME ops/server/root/orch-peak` → `18:UHOME="${ORCH_UHOME:-$(getent passwd "$U" | cut -d: -f6)}"`; посев `160:ORCH_SESS_GLOB="$SESS_GLOB"` ДО `168:  . "${REPO}/scripts/lib_session.sh"` (блок `if` на 166); `SESS_GLOB` вычислен на 34, `set -u` на 16.
- П2: `install.sh` 121/138 — `git config --file "$CFG_MAIN" …` дословно как в §Диагноз; гард существования `CFG_MAIN` стоит выше по коду.

## Советы (не блокируют)

1. ci.yml дельта — чисто генераторная (gen_ci_steps.sh --write), ручных правок нет.
2. Герметичность красной клетки чувствительна к параллельным субагентам на станции — известный класс шума, назван контрактом явно; не требует фикса до done.
3. Остальное — на усмотрение оркестратора.

## Итог

**accept.** Реализация П1/П2/П3 соответствует зоне, предписанному диагнозу и приёмочному критерию контракта 090; живой прогон 5/5 зелёных независимо перепроверен (изолированно, вне шума watcher'а).

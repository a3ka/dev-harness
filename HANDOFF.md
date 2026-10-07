## ГДЕ МЫ (2026-10-07, ~20:10 UTC)

- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).

**Push-гейт 071 — разблокирован для этого диапазона словом владельца 2026-10-07 ~19:15 UTC.** Корень «main красен с db6a4e7» — непринятая реализация 086 (`spawn_agent.sh`/`check_charter.sh`), уехавшая разовым push, краснила ap3/ap4 на каждом следующем push. Владелец: остановить 087, откатить 7 ленд-коммитов 086 из main (`revert -m 1`, newest-first, identity = автор исходного ленда), закрыть 084/086 без done строками `registry/closed-without-done.tsv`, один РАЗРЕШИЛ-ВЛАДЕЛЕЦ-push мимо 071 для диапазона `2c93191..4953659`.

**Сделано и запушено (`4953659`, origin/main подтверждён):**
- 7 revert-коммитов 086 (`a09c65e`…`018e50f`, identity architect/implementer по исходному автору ленда) + `fork-` префикс на `verdicts/consultant/071-...md` (ложный mint-match check:ids) + пустой маркер-коммит с транскриптом проверок.
- До push в одноразовых клонах зелёные: `check_zones.sh` full (rc0) и `--incr` на критичном окне (rc0), `check_protected.sh` (0 исчезло), `check_charter.sh` full (177/177 с разрешения), четыре npm-проверки (nabludenia/ci-parity/ceilings/ids), `fixtures/_krasnye_083.sh` (107/0), `npm run check:antiplacebo -- --scope <ap3+ap4 ключи>` (168/168).
- Живой CI после push (`run 37678420489`) — **ap3 И ap4 ОБА success**, подтверждает: причина была в 086, не в гейте 071. Два ДРУГИХ джоба красны: `ci (l6)` — `check:ids --incr` ложно флагует переименованный `verdicts/consultant/071-...` по СТАРОМУ имени (добавлен-затем-переименован в одном окне, `collect_paths_incr` не фильтрует по существованию на HEAD); `ci (l7)` — `cell_k7`: эта секция несла укороченную строку-указатель (без `(инвентарь механизмов, установка, настройка)`) — чинится ЭТИМ коммитом.

**В работе прямо сейчас:** `scripts/check_ids.sh` — однострочный фикс `collect_paths_incr` (добавлен `git cat-file -e HEAD:$path` перед флагом, путь без текущего существования не судится — тот же класс, что check_zones' «судим HEAD, не транзит»); живой `check_ids.sh --incr` на окне `2c93191..4953659` подтверждён зелёным ДО коммита. `contracts/026-zhnec-tmp.md` v4 — zone-экспансия orchestrator на `registry/closed-without-done.tsv` (АДМИНИСТРАТИВНЫЙ zone-респект, тот же класс v3:72, прямое слово владельца 2026-10-07 — `check_staged.sh` отказал «вне зоны» без неё, ни один frozen-контракт её не грантовал).

**087 — ОСТАНОВЛЕН словом владельца, ветки сохранены.** `wip/087/implementer` (3 коммита: ci_klass/ci_vesa/реестр, проводка ci.yml, cache-миграция в legkij) и `wip/083/architect` (Г10-фикстура под legkij-владение, Architect083G10Fix) — НЕ слиты, НЕ удалены. Возобновление — только после ленда 083 на origin и без новых гейтов (владелец).

**084/086 закрыты без done** строками `registry/closed-without-done.tsv` (084: кап кругов реализации; 086: 9 кругов судей, Б-7/F3 остаточный риск в NABLIUDENIA) — слово владельца 2026-10-07.

**Дальше по слову владельца:** push текущих правок через `gitw` (не land-диапазон, 071 пройдёт штатно) → main CI --json по job → `done_contract.sh` 088 → 083 → 082 → затем 089 (fix-085, патч готов `/tmp/dev-harness-verify/arch089/089-architect.patch`) → заморозка харднинга. Отдельно: `orch_restart.sh` снять ТОЛЬКО ногу `HEAD==origin/main`, `roles/orchestrator.md:421` — «HANDOFF «ГДЕ МЫ» на origin» → «HANDOFF закоммичен» (слово владельца, НЕ сделано ещё).

Архив предыдущих записей (до этой ротации) — `docs/handoff-archive/2026-10-07.md`.
<!-- BEGIN GENERATED NEXT SESSION -->
## Следующая сессия (генерируется: bash scripts/gen_plan.sh --write)

- 082 · пара 1 · заморожен · трек CI
- 083 · пара 1 · заморожен · трек CI
- 084 · пара 2 · заморожен · трек plan-infra
<!-- END GENERATED NEXT SESSION -->

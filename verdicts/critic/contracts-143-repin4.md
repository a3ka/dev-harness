accept
OBJECT=f8bb293d32fa82d5087445c49504df1287cccea2
СУД: repo=dev-harness; предмет=143; фаза=реализация-перепин (развязка пинов по живой приёмке); роль=critic; вызов=1/2; модель-план=роль critic; сессия=Crit143r4; модель-факт=openai-codex/gpt-6-sol; SHA=f8bb293d32fa82d5087445c49504df1287cccea2; предыдущий=Crit143r3 accept (перепин H); исключение=нет

ИТОГ: блокирующих находок нет. Дельта от принятого 8053f510 — только модель mobile.yml и её SHA-пин source.json. Нового зелёного ЖИВОГО CI этим вердиктом НЕ утверждаю: шаг 15 и хвост quality проверены локально, повтор #136 — задача оркестратора. Остаток: экранный продукт ещё не поставляет 117 v5 W1A; quality использует прежнее поведение 117 v2, а не объявляет v5 поведение зелёным.

1. Факт и адресность. `git cat-file -t f8bb293d32fa82d5087445c49504df1287cccea2 && git rev-parse HEAD` в клоне архитектора → `commit` / `f8bb293d32fa82d5087445c49504df1287cccea2`, rc 0; клон судьи имеет ту же голову. `q136b.log:1428-1429` запускает ОБЕ пробы из `.harness117`; `:1509` → `static 70/70`, `:1701-1702` → `failed 34 of 191`, `Process completed with exit code 1`; строки между ними содержат MIGRACIYA_W0/W1A/NEPODKLYUCHEN, G0_SMENA_TEMY, PORYADOK, RERENDER_W1A_W0. На `cp -a` продукта `/tmp/dev-harness-verify/Impl143/mob` @ `3a94e19a6b13791d959f70712cd674b72db53c2b` с `git archive 4ac99af9…` и `git archive 8d3f48b8…` (каждый — fixtures/workshop_project/vkhod_117, scripts, fixtures/workshop_project/mob_sverka_123): `python3 battery-v5/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo cutover` → rc 0 `static 70/70`; `python3 battery-v2/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo cutover` → rc 0 `behavioral 26/26`. Это 26 РЕАЛЬНЫХ именованных Jest-клеток, не 191 клетка v5. При первом запуске v2 ошибочно добавленный symlink `node_modules/node_modules` (исходное `node_modules` УЖЕ имелось в скопированном продукте) привёл к `failed 26 of 26`/invalid React hook `Cannot read properties of null (reading 'useMemo')`, rc 1; symlink удалён, повтор на корректной копии → `behavioral 26/26`, rc 0. Предыдущий независимый Crit143r3 `compare_117.py` измерил v5 `failed 34 of 191` на монолите И split, `same output True`: это не регресс cutover; живой лог подтверждает его.

2. Проверка варианта А. `fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:310-374`: `.harness117` остаётся 4ac99af9 (v5, статическая 70/70), отдельный `.harness117b` = 8d3f48b8 (v2, поведенческая 26/26); `set -e` запускает обе пробы, `mv .harness117b` стоит до lint; комментарий `РАЗВЯЗКА ПИНОВ` честно описывает оба красных прогона CI и W1A-остаток. В upstream-клоне `git merge-base --is-ancestor frozen/contracts/117/2 8d3f48b8…` и аналогичный `117/5 4ac99af9…`, `git diff --exit-code <rev> frozen/contracts/117/{2,5} -- fixtures/workshop_project/vkhod_117/` → все rc 0: пробы взяты из соответствующих frozen. Исходное зелёное поведение #124 v2 оставлено без изменений, статика строже; ревизия v5 для поведения — отдельная поставка 117. `git diff 8053f510 HEAD -- .../model/.github/workflows/mobile.yml .../source.json` → ровно два пути; `git diff --exit-code frozen/contracts/143/1 HEAD -- contracts/143-mob-ci-razdelenie.md` → пусто, rc 0. И-7 (`contracts/143-mob-ci-razdelenie.md:55-56`), инвентарь 117 (`:73`), §Порядок (`:133-134`) с этим не конфликтуют: 117 перепиняется своей пачкой, буквального `.harness117` в 143/1 нет.

СОВЕТ fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:338 — известный остаток проверки продукта по модели, НЕ лазейка живой quality. `python3 /tmp/dev-harness-verify/Crit143r4/pin_attack.py` подменил только ref `.harness117b` в ОДНОРАЗОВОЙ копии модели на существующую корневую ревизию без пробы; сырой вывод:
```
root ref 87cbba2c57611bd1c56e7818ac6eb034f3419275 battery rc 0 клеток 69, зелёных 69, красных 0
missing probe git cat-file rc 128 fatal: path 'fixtures/workshop_project/vkhod_117/vkhod_probe.py' exists on disk, but not in '87cbba2c57611bd1c56e7818ac6eb034f3419275'
```
Команда шага `python3 <копия без пробы>/fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo cutover` → `can't open file: [Errno 2] No such file or directory`, rc 2: `set -e` не даёт CI ложно позеленеть. Доверенная модель сама закреплена sha256 и порча её оригинала краснеет `ORACLE_TAMPERED`; `W --repo` НЕ сверяет байты продукта с моделью (принятый остаток Crit143r3), побайтовую доставку ловят ревью cutover-PR и адверсарий, §Порядок.

3. Счёт и границы. `sha256sum fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml` → `22e26f22a758b1478f9404b5e8caf47190aea104728e1a8569a82261e183c6d1`, ровно source.json (старый `0ca3317e…`); Python-счёт source.json: `kletki 69 stabs 33 pins 21` / `stabs bindings 49`; census 4-8-33-9 не изменился от принятого объекта. `grep harness117|_v_rabote` по probe.py, osi.md и stabs — пусто; единственный ref-якорь 4ac99af9 в `stab_p_rglob_kataloga.py` вне quality, добавленный checkout не сдвинул его. `git diff --name-only HEAD~1 HEAD` — ровно 7 файлов, ВСЕ `fixtures/workshop_project/mob_ci_143/`, зона architect `contracts/143-mob-ci-razdelenie.md:140`; `git status --porcelain` пуст. Отдельно склонирован upstream для тегов; `frozen/contracts/117/2` и `/5` присутствуют.

4. Прогоны и атаки. Из корня клона:
```
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model  # 3 × rc 0
клеток 69, зелёных 69, красных 0
клеток 69, зелёных 69, красных 0
клеток 69, зелёных 69, красных 0
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs  # rc 0
клеток 69, зелёных 69, красных 0
стабов 33, привязок 49, непойманных 0
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh # rc 1
клеток 69, зелёных 0, красных 69 — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143r4/cutover # rc 0 (до mv)
клеток 69, зелёных 69, красных 0
```
Реально выполненные красные P1/P2 на отдельных одноразовых копиях модели: `python3 /tmp/dev-harness-verify/Crit143r4/replay_p.py krasnye` → rc 0; сырые строки вывода (сам драйвер укорачивает строки диагностик до 240 символов):
```
(а) второй полный P после retired checkout: rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: запусков P 2: e2e-pilot[7], e2e-pilot[9] — И-8 требует ровно один запуск P в e2e-pilot КРАСНА
(а′) P + retired checkout в android-e2e: rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: запусков P 2: e2e-pilot[7], android-e2e[1] — И-8 требует ровно один запуск P в e2e-pilot КРАСНА
(б1) retired checkout path ./.harness: rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml'
(б2) retired checkout path .harness/: rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml'
(б3) retired checkout path ${{ github.workspace }}/.harness: rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: путь checkout неизмерим: ${{ github.workspace }}/.harness КРАСНА
контроль double-exact (retired после хорошего, до P): rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml'
доп: литерал скрыт ${EMPTY} (ноль запусков, fail-closed): rc=1  клеток 69, зелёных 68, красных 1
      КЛЕТКА p01-P-nabor: нет checkout .harness до шага запуска maestro_probe.py — P не исполняется этим workflow КРАСНА
```
`python3 /tmp/dev-harness-verify/Crit143r4/replay_p.py zeljonye` → rc 0, сырой вывод трёх обратных ветвей:
```
плохой, затем хороший (эффективный хороший): rc=0  клеток 69, зелёных 69, красных 0
retired checkout ПОСЛЕ запуска P (не влияет): rc=0  клеток 69, зелёных 69, красных 0
алиас ./.harness с ХОРОШИМ ref (исходный .harness сохранён): rc=0  клеток 69, зелёных 69, красных 0
```
`python3 /tmp/dev-harness-verify/Crit143r4/replay_p.py porcha_pinov` → rc 0, сырые строки каждого пина и retired-нагрузки:
```
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
```
`bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit143r4/repo contracts/143-mob-ci-razdelenie.md` → `OK`, rc 0, `__pycache__` в зоне батареи нет. Ошибочно вызванный первоначально checker с одним аргументом вернул «использование: … <корень> <отн-путь-контракта>», rc 1; корректный вызов выше зелёный. Соседи: `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs && bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs && bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` → rc 0, сырые итоги `SVJAZI 69` / `zhivykh 0`, `SVJAZI 66` / `zhivykh 0`, `SVJAZI 60` (первоначальные ошибочные имена соседских скриптов были исправлены). ПОСЛЕДНИМ гейтом `bash scripts/check_zones.sh` → rc 0, сырой итог `замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 35335 · проверено по зонам: 7682` (350.03 с, отказов нет).

5. Хвост quality после шага 15: на копии продукта исполнены все шесть `mv` для `.harness`, `.harness117`, `.harness117b`, `mobile/e2e-first-run`, `mobile/e2e-erstinformation`, stand-in-пробы в отдельные пути под Crit143r4, общая цепь rc 0; затем `npm test -- --runInBand` → rc 0 `Test Suites: 12 passed, 12 total; Tests: 134 passed, 134 total`, `npm run typecheck` → rc 0 `tsc --noEmit`, `npm run lint` → rc 0 `structure: OK (repository inventory; external trees excluded)`, `EXPO_DOCTOR_SKIP_DEPENDENCY_VERSION_CHECK=1 npm run doctor` → rc 0 `20/20 checks passed. No issues detected!`. Повтор живого CI/эмуляторы не выполнялись здесь.

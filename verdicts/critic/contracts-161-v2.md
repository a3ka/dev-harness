accept
OBJECT=1c75a7ec228a7bd3a30cf0041e3e99926fde3268
КЛАСС=задача: контракт v+1 замороженного + красные тесты (смешанный); риск: рисковый — сохранён из frozen 161/1 (:4 «чужой контекст, обход замка»; v+1 не расширяет 161a), реализацию затем судят adversary и reviewer; класс пакета «обычный» к 161 не применяется; порог: новый §Быстрый-процесс (161 заведён 2026-11-04, после 5ca237e4) — нарушений обязательств на достижимом состоянии не найдено
СУД: repo=dev-harness; предмет=161; фаза=контракт (v+1 → v2, пакет 184 А10; Arch184Vplus4, коммит 1c75a7ec228a7bd3a30cf0041e3e99926fde3268); роль=critic; вызов=1/2; модель-план=zai/glm-5.3 (fallback openai-codex/gpt-5.6-terra); сессия=Crit184Vplus8; модель-факт=zai/glm-5.3 (workstation сессии; провайдер поднят консультантом 10:10 UTC, healthz 200 — повторов не было); SHA=1c75a7ec228a7bd3a30cf0041e3e99926fde3268 (tip wip/184/architect); предыдущий=нет (нематериализованный FAIL Crit184Vplus `a882299e54b12d19b06ac19f6d865f04c60ac2a0` — обрыв без вердикта по модели вне тира; его блок проверен на закрытие ниже); исключение=нет

# Вердикт критика — контракт 161 v+1 (v2), пакет 184 (А10), вызов 1/2, повтор после обрыва

## ИМЯ ФАЙЛА — КОЛЛИЗИЯ (для оркестратора/владельца)

Канон `freeze_contract.sh` для v+1 161 (vmax(`frozen/contracts/161/*`)=1) даёт `verdicts/critic/contracts-161-v2.md`. Это имя на origin/main УЖЕ занято: accept вызова 2/5 дельты по тексту v1 (OBJECT `af90be5eb1b8c26e6947799fb6e1faf34524e861`, commit `0c782f8e`, модель openai-codex/gpt-6-sol). Тот accept ОТНОСИТСЯ К ДРУГОМУ ТЕКСТУ (v1-дельта) и не разрешает этот v+1: настоящий вердикт судит OBJECT `1c75a7ec` и заменяет файл по имени канона в этой ветке; прежнее содержимое остаётся в истории git (`0c782f8e`). Решение об имени/заморозке — оркестратор/владелец (замечено и заданием пакета 184, и §Позицией автора). Смежно: счёт кругов `freeze_contract.sh` (§6в, глоб `contracts-161-v*.md`) видит историю v1/v1-fail/v2/v3 (круги ≥3) — заморозка v2 может потребовать арбитра с титулом «(контракт 161)» либо строки `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в причине заморозки; это вне зоны architect и вне текста контракта.

## Кандидат, независимость, законность вызова

- Клон `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/Crit184Vplus8/repo`; OBJECT = tip `wip/184/architect` (ветка от `16a65dcb5`, main ушёл вперёд — сужено по diff коммита). Дельта предмета — сам коммит OBJECT: контракт (+26/−2 против v+1 Arch184Vplus3), `proektnaja_raskladka_161/probe.py` (+251: клетки A10_ROOT_PROFILE make/spawn × root-only/both, STATION_MANIFEST_MISSING, подмены a10-root-as-profile/a10-root-ignored/station-root-profile, трёхрежимный выбор адреса по резолверу установки), SPEC.md (+2). `frozen/contracts/161/1` ≡ базе `79b615f53`.
- Автор — `architect <architect@dev-harness.local>` (Arch184Vplus4). Судья — Crit184Vplus8 (zai/glm-5.3, apex-sol), собственной работы не судит.
- `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле OBJECT дословно, ровно один раз: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/161-revizija-mekhanizmov-proektnaja-raskladka.md — v+1 только в объёме решения А10 (предмет 184); слово владельца 2026-11-10 ~20:44 UTC «г да» через консультанта».
- Повтор законен (см. вердикт 054); автор СОГЛАСЕН с блоком в §Позиции автора.

## Что изменено против Arch184Vplus3 (1ee124ad8 → 1c75a7ec)

Обязательство :17 уточнено: отказ `make_task`/`spawn_agent` на корневом профиле (только корень — P1, оба — P10) — rc 1, stderr с телом фразы резолвера 054 v+1, до MAP/манифеста/ветки/worktree, stdout пуст; дверь несёт отказ резолвера, второго валидатора нет; диагноз через корневую раскладку (`нет свидетельства модели`, `тег … не выдан авторитетом`, `нет манифеста`) объявлен ложным (AGENTS.md правило 7). Приёмка: три режима по резолверу установки (до cutover bare — rc 2 `NOT_IMPLEMENTED`; `--model`/`--stabs` — прежний контроль на корневом адресе миров; после cutover — клетки А10 + клетка станции). Порядок ленда одним слиянием, тег после слияния. Инварианты 1–2, замок, dual-control, зоны, LAYER_FOREIGN/CONTEXT_FOREIGN/PROFILE_PATH_MISSING/MANIFEST_MISSING не тронуты; буллет модели угроз добавлен.

## Закрытие прежнего блока

БЛОК (отказ make_task/spawn_agent на корневом профиле не проверялся ни одним миром; двери «только адрес» — ложный диагноз продукту, станции — снятый MANIFEST_MISSING) — ЗАКРЫТ. Живой прогон на OBJECT:

```
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh --model
CONTROL: honest product green   [rc=0]
$ … --stabs   [rc=0]
STAB_CAUGHT: optional-skipped … foreign-make … foreign-write … missing-spawn: MANIFEST_MISSING:
… collision-spawn … git-path-spawn … tmpdir-write … hash-ignored … symlink-bypass   (9/9)
A10: резолвер установки ещё не принимает .harness/harness.project.json (до cutover 184) — клетки А10 и их подмены судит bare после cutover
$ … (bare)   [rc=2]
NOT_IMPLEMENTED: А10 (184) не влит: резолвер установки не принимает .harness/harness.project.json: profile ОТКАЗ: нет harness.project.json: …
```

(Прежнее механическое расхождение — трассировка Python вместо rc 2 — закрыто текстом и кодом.)

Мутант критика «только адрес» прежнего вердикта (якоря → `.harness/`, корень не судится; резолвер H; станция перенесена) пойман клетками А10:

```
$ bash <mutA>/…/red_proektnaja_raskladka_161.sh   → rc 1
A10_ROOT_PROFILE: make-root-only: expected resolver refusal before output: rc=1 ОТКАЗ: нет свидетельства модели: architect
A10_ROOT_PROFILE: make-both: … rc=1 ОТКАЗ: нет свидетельства модели: architect
A10_ROOT_PROFILE: spawn-root-only: … rc=1 ОТКАЗ: тег 761 не выдан авторитетом: манифест registry/contracts.tsv отсутствует на origin/main (3б)
  — ложные диагнозы прежнего блока теперь КРАСНЫЕ именованными клетками
```

Мутант «станция без манифеста» (та же дверь, профиль станции НЕ перенесён) пойман клеткой станции:

```
$ bash <mutS>/…/red_proektnaja_raskladka_161.sh   → rc 1
STATION_MANIFEST_MISSING: station spawn without pack not refused by manifest: rc=1 ОТКАЗ: номер 761 не выдан — спавн мимо реестра (тег id/CONTRACT/761 отсутствует)
```

Честное состояние (полный cutover критика: резолвер H + перенос профиля станции + якоря `.harness/` + перенос отказа резолвера в двери) проходит батарею целиком, включая подмены А10:

```
$ bash <mutW>/…/red_proektnaja_raskladka_161.sh          → rc 0 (все клетки, включая A10_ROOT_PROFILE ×4 и STATION_MANIFEST_MISSING)
$ bash <mutW>/…/red_proektnaja_raskladka_161.sh --stabs  → rc 0
STAB_CAUGHT: … (прежние 9) …
STAB_CAUGHT: a10-root-as-profile: A10_ROOT_PROFILE: make-root-only
STAB_CAUGHT: a10-root-as-profile: A10_ROOT_PROFILE: spawn-root-only
STAB_CAUGHT: a10-root-ignored: A10_ROOT_PROFILE: make-both
STAB_CAUGHT: a10-root-ignored: A10_ROOT_PROFILE: spawn-both
STAB_CAUGHT: station-root-profile: STATION_MANIFEST_MISSING:
```

Спавн-миры клеток А10 несут подготовленный внешний манифест и mint — корневой профиль остаётся единственным дефектом, поэтому клетка различает именно его (наблюдение прежнего вердикта учтено).

## Обязательные мутации

«только корневой мир» и «оба профиля» — A10_ROOT_PROFILE make/spawn × root-only/both (красны на mutA/mutS, зелены на mutW); «корневой профиль как вход/фолбэк» — a10-root-as-profile + stab station-root-profile + вердикты 054/996; «станция без манифеста» — mutS выше; «удаление клетки» — набор клеток/подмен закреплён литералами A10_STABS/базовой клетки в probe.py (удаление элемента расходится с CONTROL-строкой honest_control и краснит прогон); «обход резолвера» — вердикт 122; «симлинк наружу» — прежние symlink-клетки (state_symlink_must_not_enter_main ×4) зелены в честном bare (rc 0), прежние подмены пойманы в --stabs.

## Гейты и прогоны (OBJECT, сырой вывод)

```
$ bash scripts/pre_critic.sh contracts/161-…raskladka.md    → «КРИТИК: дверь зелёная» [rc=0]
$ bash scripts/check_precision_gate.sh . contracts/161-…    → OK [rc=0]
$ bash scripts/check_threat_model.sh . contracts/161-…      → валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 2) [rc=0]
$ bash scripts/check_provodka.sh . contracts/161-…          → [rc=0]
$ bash scripts/check_ceilings.sh .                          → потолки в порядке [rc=0]
$ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model → rc 0; --stabs → rc 0
```

## Механические сверки (живой прогон)

Прежнее расхождение 1 (bare-трассировка вместо rc 2; `--model`/`--stabs` CONTROL_INVALID) закрыто: bare rc 2 `NOT_IMPLEMENTED: А10 (184) не влит…`, `--model`/`--stabs` rc 0 с честным контролем. Шаги CI :19 — прежние (реестр не менялся); «Toy-мир кладёт профиль только в `.harness/harness.project.json`» ✓ (`git grep -P '(?<!\.harness/)harness\.project\.json' -- fixtures/workshop_project/proektnaja_raskladka_161/` пуст).

## Пересечения пакета

- 184/1: клеток не копирует; зона implementer 161 (make_task.sh, spawn_agent.sh) внутри зоны implementer 184 — одно имя, ПЕРЕСЕЧЕНИЕ-строк не требует.
- 054 v+1: перенос профиля станции (§Потребители) — якорь клетки станции и манифестной ноги 095 И-15; клетка станции зелена только при переносе (mutW) и красна без него (mutS).
- 996 v+1: те же двери через project_paths_resolve; грамматика отказа одна — фраза резолвера (996 демаркация и 161 :17 согласованы дословно).
- 122 v+1: пересечений нет. Порядок ленда: одним слиянием, тег frozen/161/2 после слияния; до него bare-шаг CI дал бы rc 2 — на main текст v2 до слияния не попадает (заморозка после), противоречия нет.

## Советы (едут с accept)

СОВЕТ — коллизия имени `contracts-161-v2.md` и счёт кругов §6в `freeze_contract.sh`: оба вопроса вне текста контракта; оркестратору при заморозке v2 выбрать маршрут (переименование старого файла по прецеденту `contracts-118-v3-staryj-accept-*.md` / `contracts-162-v2-staryj-accept-*.md`, арбитраж по кругам или слово владельца) и записать решение.
СОВЕТ — при cutover реализатора 184 клетка STATION_MANIFEST_MISSING требует, чтобы перенос профиля станции лёг В ТОМ ЖЕ слиянии, что и якоря дверей (иначе шаг CI красен); порядок уже объявлен в 054 v+1 §Потребители — здесь только напоминание о связи.

## Итог

`accept`: блок нематериализованного FAIL закрыт — клетки A10_ROOT_PROFILE и STATION_MANIFEST_MISSING предъявлены, ловят двери «только адрес» (ложный диагноз `тег … не выдан авторитетом` / `нет свидетельства модели` красен) и неперенесённый профиль станции (спавн мимо манифеста красен); честный полный cutover проходит bare и все 14 подмен rc 0; rc 2 `NOT_IMPLEMENTED` до cutover исполнен дословно. Гейты зелёные. Коллизия имени и счёт кругов — оркестратору/владельцу. Советы автор закрывает по усмотрению.

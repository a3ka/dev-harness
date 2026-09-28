FAIL
# Ревью 054 — финальный суд (профиль два слоя + лаунчер), HEAD a7e3fe6

Судья: reviewer (семейство, отличное от автора). Контракт: `frozen/contracts/054/1`
(tag-object 53dbc719 = строка реестра `054 → 53dbc719…`). Судимый диапазон
реализации: 645496d..a7e3fe6 (7 коммитов implementer: 645496d d458f4a 445b386 7f57fb2
c2390de 1478602 c455f15). Прогоны — одноразовый клон
`/tmp/dev-harness-verify/rev054fin-1790630918-587707` (ssh-клон origin, HEAD a7e3fe6);
основной чекаут только читался.

## Красный вход (Н-165 п.2)

```text
до:    ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
```

## Итог одной строкой

Реализация fd-first (TOCTOU к5) — ВЕРНА, моя независимая гонка это подтверждает. Но
барьер предмета не держит предмет: клетка b11 на честном субъекте не исполняется
никогда, раннер `_krasnye_054.sh` всегда отдаёт rc=0, guard-канал ПРОВОДКИ отключён
маркером `.probe-only`, и резолвер отказывает на конформном входе И-4. Четыре
блокера (Б1–Б4), один формальный (Б5), советы С1–С4.

## Регресс (сырьё, коды возврата)

```text
$ bash fixtures/_krasnye_054.sh
стаб пойман: … (20 строк, МОЛЧАЛИВЫЙ-ENV … TOCTOU-CHECK-OPEN — клетка b11)
стаб-пак: просмотрено 20, поймано 20
054-батарея зелёная: все клетки к1-к14 + b1-b11 пройдены
итог 054: rc=0
RC=0            # ← см. Б2: этот rc не зависит от батареи

$ bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver
БАТАРЕЯ profile_resolver: класс delimiter-collision/regex-injection/silent-drop/self-application-green — закрыт (rc 0)
БАТАРЕЯ profile_resolver: итог 4/4 классов закрыто
RC=0

$ bash fixtures/_krasnye_055.sh ; bash fixtures/workshop_project/_verify_055_r3.sh
стаб-пак: 13/13 поймано, диффпроба 13/13 — различимость жива (Н-39)
честная часть: 17/17 зелёная; предъявлений: стабы 13/13 + дифф 13/13 + честные 17/17
итог 055: rc=0
(а) repro stale-delete race ... OK (W3 + каталог сохранён)
  раунд 1: succ=1/64 (ожидалось 1)
  раунд 2: succ=1/64 (ожидалось 1)
итог 055-r3: rc=0 (оба сценария прошли)
RC_VERIFY=0

$ bash scripts/check_zones.sh .        # в клоне, на ветке предмета (4.7)
  FAIL строка ЗОНА вне объявленной грамматики в contracts/055-…md: «ЗОНА architect (до-заморозочная батарея …):» — … не назван ни один путь
  ok   contracts/054-profil-dva-sloja-launcher-proekta.md — работа не раздаётся: scripts/gitw …
замороженных контрактов: 54 · объявленных авторов: 2 · коммитов в диапазонах: 2409 · проверено по зонам: 1453
RC_ZONES=0
```

FAIL-строка check_zones — предсуществующий грамматический дефект контракта 055
(architect), не 054 (тот же, что записал адверсарий в 40ab940).

## Frozen-неизменность

```text
$ git diff --stat frozen/contracts/054/1 HEAD -- contracts/054-profil-dva-sloja-launcher-proekta.md   → пусто, rc=0
$ git log frozen/contracts/054/1..HEAD -- contracts/054-…md                                          → пусто
$ git hash-object contracts/054-…md == git rev-parse HEAD:contracts/054-…md == f460b4fb982602b2f4195470e456208413f4f3d7
```

## Область правки (п.1), атомарность (п.5), норма (п.6)

`git show --stat` каждого из 7 коммитов implementer: затронуты только `workshop`,
`scripts/profile_resolver.sh`, `scripts/gen-harness.ts`, `fixtures/workshop_project/`
(red_profil_dva_sloja.sh, .probe-only), `fixtures/_krasnye_054.sh`,
`fixtures/parsing_hygiene_battery/profiles/profile_resolver.sh` — ровно ЗОНА implementer
054. Каждый коммит несёт «054» в теме, одна фикс-раунд — один коммит. Нормативных
документов (roles/, AGENTS.md, contracts/) implementer 054 не трогал. Остальные коммиты
диапазона — чужие зоны (055 implementer, architect, adversary, critic, orchestrator:
land/mint/HANDOFF), check_zones их не флагает. — ПРОЙДЕНО.

## Изолированные fd-пробы (моя мера, не повтор b11)

Скрипт `rev054fin-race.sh` (выброшен): конформный JSON (все ветви + barriers),
final-symlink внутрь/наружу, symlink слоя проекта наружу, и ЖИВАЯ гонка — фоновой
цикл атомарно (`mv -T`) перекидывает `harness.project.json` между внутренним и внешним
JSON, 200 запусков резолвера.

```text
### HONEST (HEAD a7e3fe6, scripts/profile_resolver.sh)
probe positive-internal: rc=0 repoId=r_internal
probe repo-external: rc=1 msg=profile ОТКАЗ: нет файла репо-слоя в корне репо: …/b/harness.project.json. Инструкция: … не symlink на внешний файл
probe layer-external: rc=1 msg=profile ОТКАЗ: корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=…
race repo-layer N=200: internal_ok=97 refused_named=103 EXTERNAL_LEAK=0 other=0
RC_HONEST=0

### MUTANT (тот же файл, порядок check-then-open: readlink -f pathname → exec {fd}<)
probe positive-internal: rc=0 repoId=r_internal
probe repo-external: rc=1 …нет файла репо-слоя в корне репо…
probe layer-external: rc=1 …корень слоя проекта не задан/недоступен…
race repo-layer N=200: internal_ok=55 refused_named=124 EXTERNAL_LEAK=21 other=0
RC_MUT=1
```

Вывод: инверсия порядка закрывает окно на реальном субъекте (утечек 0), мутант
check-then-open течёт живьём (21/200). Предмет fd-first — принят.

## Находки

### Б1 — БЛОКЕР (п.4 «красное предъявлено» / п.3 проверка не держит субъект): b11 на честном субъекте не исполняется; check-then-open мутант РЕАЛЬНОГО резолвера — батарея ЗЕЛЁНАЯ

Фрагмент: `fixtures/workshop_project/red_profil_dva_sloja.sh` — `run_honest` перечисляет
`b11` (строка `for cell in k2 … b10 b11`), но `cell_resolver_run` не имеет ветви `b11)` и
падает в `*) return 0 ;;`. Печать «все клетки к1-к14 + b1-b11 пройдены» для b11 ложна.

Мутант-сэмпл (клон, `rev054fin-mut.py cto`, диф — 6+/6−: `exec {REPO_FD}<` перенесён
ПОСЛЕ `readlink -f -- "$REPO_JSON"`):

```text
$ bash fixtures/_krasnye_054.sh   # против мутированного scripts/profile_resolver.sh
стаб-пак: просмотрено 20, поймано 20
054-батарея зелёная: все клетки к1-к14 + b1-b11 пройдены
итог 054: rc=0
```

Тот же мутант течёт живьём (EXTERNAL_LEAK=21/200 выше). Значит b11 красен только против
отдельного стаба `stub_resolver_checkopen`, а против предмета барьера нет; b10 — поиск
маркеров в исходнике — мутант проходит (маркеры `exec {REPO_FD}<`/`/proc/self/fd` в
файле остались). Если b11 подключить к честному субъекту (`rev054fin-mut.py b11h`:
`b11) cell_b11 "$PROFILE_RESOLVER" || return 1 ;;`):

```text
стаб-пак: просмотрено 20, поймано 20
клетка b11 (resolver): красная
итог 054: rc=1
```

— красная на ЧЕСТНОМ HEAD: фикстура b11 (`harness_internal.json` без `barriers`)
отвергается резолвером по Б3 (`barriers.mandatory: <null>`), т.е. честная ветвь b11
никогда не была исполнена ни разу. «Зелёное без красного» наоборот: красное есть только
на стабе.

### Б2 — БЛОКЕР (п.2/п.7, приёмка «прогон `bash fixtures/_krasnye_054.sh` → rc 0»): раннер всегда rc=0

Фрагмент: `fixtures/_krasnye_054.sh`, две последние строки:
`… bash "$BATTERY" "$@"` / `echo "итог 054: rc=$?"` — код выхода скрипта = код `echo`.
Замер (клон, мутант b11h — батарея красная):

```text
итог 054: rc=1
RUNNER_RC=0
```

Строка приёмки «→ rc 0» этим раннером не измеряема: rc 0 при любом исходе батареи.
Все прежние «rc=0» по раннеру значимы только печатной строкой `итог 054: rc=…`.
(Тот же шаблон — в `fixtures/_krasnye_055.sh`; вне предмета 054, передано 055-суду.)

### Б3 — БЛОКЕР (семантика, обязательство И-4 / И-6): конформный вход отвергнут

И-4 (заморожено): «Обязательные поля репо-слоя: schemaVersion, repoId, language,
projectLayer; остальные ветви опциональны — умолчание из `defaults` слоя проекта …
`defaults` опционален … `barriers.mandatory`/`barriers.optional` сливаются как ЕДИНИЦА».

Фрагмент: `scripts/profile_resolver.sh` `check_barrier_array` —
`jq -e --arg p "$path" 'getpath($p | split(".")) | type'` истинно ВСЕГДА (`type` отсутствующего
пути = строка `"null"`, не null), поэтому «ключ отсутствует — пропускаем» недостижим, и
`[ "$ft" = "array" ] || die_p …` отказывает. Ветвь слияния `elif $p.defaults.barriers…`
(строки 539–546) мертва. Замер (`rev054fin-sem.sh`, `rev054fin-sem2.sh`):

```text
== A: minimal repo (required-only) + FULL-defaults layer:           rc=1  profile ОТКАЗ: значение вне алфавита: barriers.mandatory: <null>
== G: repo = required + all branches, barriers ABSENT (→ defaults):  rc=1  profile ОТКАЗ: значение вне алфавита: barriers.mandatory: <null>
== F: repo = required + barriers only (прочие ветви → defaults):    rc=0  commands.origin=project   # ветви кроме barriers — ок
== C: repo со всеми ветвями, слой БЕЗ defaults:                     rc=1  profile ОТКАЗ: значение вне алфавита: defaults.barriers.mandatory: <null>
```

Противоречие: репо без `barriers` при наличии `defaults.barriers` обязан получить
`barriers.*.origin="project"`; слой без `defaults` обязан приниматься. Внесено 7f57fb2
(фикс-раунд 4, type-gate). Батарея не видит: `repo_make` всегда пишет `barriers`.

### Б4 — БЛОКЕР (ПРОВОДКА, норма 038 роли): guard-канал не подключён

ПРОВОДКА (заморожено): «guard=scripts/verify_antiplacebo.sh … канал один — guard: семья
fixtures/workshop_project/ (case_*), подхватываемая шардом матрицы анти-плацебо без
правки ci.yml»; §Честные клетки: «case_*.sh семьи fixtures/workshop_project/».

Факт: в `fixtures/workshop_project/` — `red_profil_dva_sloja.sh`,
`red_izoljacija_projectid.sh`, `_verify_055_r3.sh`, `.probe-only`; `case_*.sh` — ноль.
`scripts/verify_antiplacebo.sh:200-223` (`is_probe_only_legal`) такой каталог
ПРОПУСКАЕТ; `grep` по ci.yml/verify_antiplacebo.sh/package.json на
`_krasnye_05|workshop_project|red_profil` — пусто. Маркер `.probe-only` внесён d458f4a
(«фикс-CI»). Следствие: «CI 6/6» не исполняет ни одной клетки 054; единственный
исполнитель батареи — ручной прогон судей через раннер Б2. Канал ПРОВОДКИ объявлен, но
не существует.

### Б5 — FAIL формальный (Фразы, обязательство P4 / клетка к4б)

Замороженная фраза: `P4 = profile ОТКАЗ: неизвестный ключ <репо-слой|слой-проекта>: <путь>`;
к4б: «rc 1, P4 с `слой-проекта`». Код: `die_p "неизвестный ключ ${level}: …"` с
`level ∈ {repo, project}`:

```text
== D: profile ОТКАЗ: неизвестный ключ repo: workflowPaths.contrete        rc=1
== E: profile ОТКАЗ: неизвестный ключ project: boguskey                    rc=1
```

«Код несёт дословно» (§Фразы, §Единый источник) нарушено; к4/к4б в батарее сверяют только
`неизвестный ключ` + имя ключа, поэтому зелёные. Исходный стаб архитектора печатал
литерал `неизвестный ключ репо-слой:` — реализация от него отошла.
Также (тот же класс, мягче): §Честные клетки «каждая клетка обязана печатать число
проверенных предъявлений» — честная часть счёта не печатает (печатает только стаб-пак).

### Советы (не блокируют)

- С1. Отказ на внешний symlink репо-слоя — новая фраза «нет файла репо-слоя в корне
  репо … не symlink на внешний файл», вне списка P1–P9 (адверсарий зовёт её «P1»). Контракт
  этого случая не заявлял; при v2 внести в §Фразы.
- С2. Под нагрузкой (первая гонка, 055-verify параллельно) 1 из 300 запусков на
  неизменном слое дал `profile ОТКАЗ: неизвестный ключ project: workspaceId` — ключ из
  алфавита. [INFERENCE] сбой конвейера `printf … | grep -qF` в `_key_in_schema` под
  `pipefail` при нехватке ресурса отображается в P4. Fail-closed, но причина ложная.
- С3. Алфавит И-3 перечислен в резолвере трижды: `SCHEMA_LEVELS`, `known_branches`
  (строка 264) и ключи jq-сборки вывода (495+). «Один массив» (§Единый источник)
  выполнен для проверки, но не для вывода.
- С4. Порядок вывода батареи: «все клетки к1-к14» — к14 в этой батарее не исполняется
  (отдельная команда run_battery.sh).

## Паразитная сложность (контракт 050)

- `scripts/profile_resolver.sh` (новый, 558 стр.): (1) И-1..И-7; (2) состояние — два fd,
  явный env `HARNESS_PROJECT_LAYER_ROOT` (контрактный), вывод JSON на stdout — явно;
  (3) правка алфавита = 3 места в файле (С3) + layer_make батареи; (4) интерфейс
  `--repo` + 1 env + rc 0/1 против ~550 стр. — глубокий; (5) потребители workshop --probe,
  батарея, к14. ESSENTIAL.
- `workshop` --probe (дельта 054): (1) И-8/И-10/И-11/И-13; (2) флаг `--probe` явный;
  (3) 1 файл; (4) флаг + rc — глубоко; (5) к1/к7/к8/к12/к13. ESSENTIAL.
- `scripts/gen-harness.ts --agents-rules`: (1) И-14; (2) нет; (3) 1; (4) режим + rc 0/1/2;
  (5) к8/к10/к10б/b4. ESSENTIAL.
- `fixtures/_krasnye_054.sh`: (1) строка приёмки «Зелёное ПОСЛЕ»; (2) нет; (3) 1;
  (4) env REPO_ROOT; (5) приёмка — но rc проглочен (Б2). ESSENTIAL, дефектен.
- `fixtures/parsing_hygiene_battery/profiles/profile_resolver.sh`: (1) И-7/к14; (2) нет;
  (3) 1; (4) —; (5) run_battery.sh. ESSENTIAL.
- `fixtures/workshop_project/.probe-only`: (1) никакое — контракт требует case_*-семью;
  (2) вводит состояние «опт-аут раннера», видно только по пропуску в verify_antiplacebo;
  (3) —; (4) —; (5) потребитель — ветвь пропуска раннера, т.е. отключение канала.
  ACCIDENTAL, блокирует (фрагмент — файл; отсутствующее свойство — guard ПРОВОДКИ;
  более простая форма — case_*.sh-обёртки клеток без маркера, проходят те же строки
  приёмки через существующий шард) — это Б4.
- семья клеток `red_profil_dva_sloja.sh` (1126 стр.): (1) §Приёмка; (2) нет;
  (3) каждое утверждение клетки живёт ДВАЖДЫ — `cell_kN` (стаб-сторона) и ветвь
  `cell_*_run kN)` (честная сторона) с тем же предикатом; (4) —; (5) приёмка.
  Дублирование — ACCIDENTAL, блокирует как причина Б1 (фрагмент — `cell_resolver_run`
  с `*) return 0`; отсутствующее свойство — один предикат против стаба И субъекта;
  более простая форма — звать `cell_X "$PROFILE_RESOLVER"`/`"$WORKSHOP"`, как уже сделано
  для b10, без второй копии и без `*) return 0`).
- `stub_resolver_checkopen` + BASH_ENV-шим (b11): (1) TOCTOU к5; (2) env B11_EXTERNAL,
  BASH_ENV — явны в клетке; (3) 1; (4) —; (5) стаб-пак. ESSENTIAL по замыслу, но без
  прогона на субъекте (Б1).
- клетка b10 (поиск маркеров в исходнике): (1) TOCTOU к4; (2) нет; (3) 1; (4) —;
  (5) стаб-пак. Совет: проверка текста исходника — мутант check-then-open её проходит.

## Развилка §Развилка

ЗАКРЫТА словом владельца (HANDOFF.md, чекпойнт #56, «ДОПОЛНЕНИЕ §11», п.2): «Развилка
«где наши артефакты» ЗАКРЫТА словом владельца: .harness/ в самом репо. Консультанта НЕ
собирать.» Механизм 054 инвариантен к ответу (пути — значения `workflowPaths.*`), правки
не требует. Там же п.1: «054 → done КАК ЕСТЬ» — это решение владельца о ПЛАНЕ (II-2
(д)/(е)/(ж) уходят в 057/058); данный вердикт — суд по замороженному контракту и не
отменяет слова владельца: Б1–Б5 предъявлены владельцу как измеренные расхождения с
контрактом; принять ли 054 с ними — его арбитраж, не мой.

## Вердикт

**FAIL.** Предмет fd-first — принят (гонка 0 утечек на честном, 21/200 на мутанте).
Гейт — нет: Б1 (b11/b10 не держат реальный субъект — check-then-open мутант резолвера
проходит батарею), Б2 (раннер rc всегда 0), Б3 (И-4: отказ на репо без `barriers`/слой
без `defaults`), Б4 (guard ПРОВОДКИ отключён `.probe-only`, в CI 054 не исполняется),
Б5 (P4 не дословно; счёт предъявлений честной части не печатается).

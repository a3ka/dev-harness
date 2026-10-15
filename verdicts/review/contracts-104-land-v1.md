FAIL

# Review PR#97 `wip/104/implementer2` — контракт 104 «узкий доверенный гейт судьи» (land-v1)

Находки с чекбоксами лежат в `.review/2026-10-15-03.md`. Вердикт adversary — `verdicts/adversary/contracts-104-land-v1.md`
(коммит `5060c112c69da49dba95bf547de6c5e697f09f78` в клоне `/tmp/dev-harness-verify/adversary-104-verdict-main`, FAIL A104-1).
Я прочитал его ДО написания своего.

МОДЕЛЬ судьи: `anthropic/claude-opus-5-5` (reviewer, тир audit). Реализацию писал implementer на `zai/glm-5.3`.
Совпадения семейства — по фикстурам и регенерации, см. Рв97-10.

**Субъект.** https://github.com/a3ka/dev-harness/pull/97, head `6c366f54a802e52a5a681c5189954771017fcb26`
(OPEN, MERGEABLE, base main). Merge-base `60d82e94`, origin/main `dc43954d`. Коммиты:

```
$ git log --format='%h %an<%ae> / %cn<%ce> %s' origin/main..origin/wip/104/implementer2
6c366f54 implementer<implementer@dev-harness.local> / implementer<…> 104 implementer: регенерация .omp/agents/orchestrator.md …
8931df63 implementer<implementer@dev-harness.local> / implementer<…> 104 implementer: потолок персоны orchestrator 52904 → 51084 …
3ef470c9 implementer<implementer@dev-harness.local> / orchestrator<…> 104 implementer: узкий доверенный гейт судьи …
7f714159 architect<architect@dev-harness.local>     / orchestrator<…> 104: fixtures/zashchita_main_104 …
452f682b architect<architect@dev-harness.local>     / architect<…>    104: точечный перенос contracts/104-*.md …  (= frozen/contracts/104/1)
$ git merge-base --is-ancestor frozen/contracts/104/1 origin/wip/104/implementer2 && echo tag-ancestor-ok
tag-ancestor-ok
```

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/rev104land-672011-1792063517` (`git clone git@github.com:a3ka/dev-harness.git`)
и worktree `../rev104land-tip` (голова), `../rev104land-base` (60d82e94), `../rev104land-fx` (7f714159, фикстуры без реализации),
`../rev104land-099` (4952f3ff2). Мутанты лежат в `/tmp/dev-harness-verify/rev104land-mut/`. Основной чекаут не трогался,
push не делался.

## 1. Область правки — FAIL (Рв97-2), по путям PASS

ЗОНА из живого блоба `git show frozen/contracts/104/1:contracts/104-uzkij-doverennyj-gejt-sudi.md`:
architect — `contracts/104-…md fixtures/zashchita_main_104/ fixtures/_krasnye_104.sh`; implementer —
`.omp/extensions/spawn-guard.ts scripts/check_sud_model.sh scripts/models_actual.sh scripts/judge_gate.sh roles/orchestrator.md fixtures/dokazatelstva_098/`.

```
452f682b  contracts/104-uzkij-doverennyj-gejt-sudi.md | 122                                   architect ✓
7f714159  fixtures/_krasnye_104.sh, fixtures/zashchita_main_104/{.probe-only,_mir.sh,battery_stubs.sh,red_*.sh ×6}   architect ✓
3ef470c9  .omp/extensions/spawn-guard.ts, scripts/{check_sud_model,judge_gate,models_actual}.sh, roles/orchestrator.md,
          fixtures/dokazatelstva_098/{_mir.sh,battery_stubs.sh,model/check_sud_model.sh,model/judge_gate.sh,red_*.sh ×11}   implementer ✓
8931df63  roles/orchestrator.md                                                            implementer ✓ (по пути)
6c366f54  .omp/agents/orchestrator.md                                                      implementer — вне ЗОНЫ 104; покрыт
          объединением зон (ЗОНА implementer frozen 002/1–7, 003/6: `.omp/agents/`)
```

`bash scripts/check_zones.sh` на голове: `замороженных контрактов: 96 · объявленных авторов: 2 · коммитов в диапазонах: 11522 · проверено по зонам: 2709`, RC=0.
Строка `FAIL строка ЗОНА вне объявленной грамматики в contracts/055-…` — это самотест check_zones о 055,
к диффу не относится. `reslop t -- bash scripts/check_zones.sh`: ok, passed 82, failed 0.

Черри-пики точные: `git patch-id --stable` у 1f9b2c585 и 7f7141596 одинаковый (`aaffebaefc40`), у 072a43255 и 3ef470c9a тоже (`d4ac439e2276`).

По путям всё в зоне. По содержанию FAIL: в задании ceiling-fix прямо сказано «НЕ трогай остальной текст
roles/orchestrator.md», а коммит 8931df63 сжимает 11 фрагментов чужих разделов. Разбор и закрытие — Рв97-2.

## 2. Сырой вывод своими прогонами — PASS

**Приёмка 3** (голова, `bash fixtures/_krasnye_104.sh`):
```
стаб-пак: 13/13 поймано         (t104-m1…m13, каждый своей клеткой)
ЗЕЛЕНО: red_huk_alfavit_ustanovki / red_huk_bez_ustanovochnogo_konfiga / red_huk_task_spavna (случаев 18, провалено 0)
ЗЕЛЕНО: red_judge_gate_svidetelstvo_sudi / red_sud_model_dver_spavna / red_sud_model_materializatsija
клеток просмотрено: 6
ИТОГ 104: rc=0                  RC=0
```
**Приёмка 1** (7f714159, реализации нет):
```
стаб-пак: 13/13 поймано
КРАСНО: red_huk_alfavit_ustanovki: предмет отсутствует: .omp/extensions/spawn-guard.ts
КРАСНО: red_huk_bez_ustanovochnogo_konfiga: предмет отсутствует: .omp/extensions/spawn-guard.ts
КРАСНО: red_huk_task_spavna: предмет отсутствует: .omp/extensions/spawn-guard.ts
КРАСНО: red_judge_gate_svidetelstvo_sudi: вход 1: ожидался rc 1 «свидетельство судьи не передано», журнал пуст; факт rc=0, … verdict-строка записана …
КРАСНО: red_sud_model_dver_spavna: предмет отсутствует: scripts/check_sud_model.sh
КРАСНО: red_sud_model_materializatsija: предмет отсутствует: scripts/check_sud_model.sh
клеток просмотрено: 6
ИТОГ 104: rc=1                  RC=1
```
**Приёмка 2** (клетки 7f714159 с субъектами 4952f3ff2: `D104_SUBJECTS_DIR=…/rev104land-099/scripts Z104_SPAWN_GUARD=…/spawn-guard.ts`):
```
КРАСНО: red_huk_alfavit_ustanovki: проектный конфиг повлиял на алфавит (rc=1)
КРАСНО: red_huk_bez_ustanovochnogo_konfiga: без установочного конфига спавн не отказан именованно (rc=1)
КРАСНО: red_huk_task_spavna: провалено фабричным драйвером (rc=1)
КРАСНО: red_judge_gate_svidetelstvo_sudi: вход 1 … (rc=1)
ЗЕЛЕНО: red_sud_model_dver_spavna (rc=0)
КРАСНО: red_sud_model_materializatsija: вход 1: честная трасса, ожидался rc 0; факт rc=2 … неизвест… (rc=1)
```
Совпадает с текстом приёмки 2.

**Приёмка 5а** (поклеточно, `for c in fixtures/dokazatelstva_098/red_*.sh; do bash "$c" 1>/dev/null 2>&1; printf '%s %s\n' …; done`):
на base 60d82e94 и на голове одинаково — 17 строк, все `0`. diff двух списков пуст.
Своя мера мест вызова на base: `git grep -c -- '_d98_zov.*--verdict-row' 60d82e94 -- fixtures/dokazatelstva_098/` → `14 мест в 11 файлах`.
**5б** `bash fixtures/_krasnye_095.sh` → `ИТОГ стаб-пак 095: rc=0`, `ИТОГ 095: rc=0`, RC=0.
**5в** `bash scripts/check_judge_gate.sh` → `ok (красный) …`, `ok (зелёный) …`, RC=0.
**098 целиком** `bash fixtures/_krasnye_098.sh` на base и на голове → `ИТОГ стаб-пак 098: rc=0`, `ИТОГ 098: rc=0`.
`--model` на голове → тоже rc=0.
**Производная** `node scripts/gen-harness.ts --check` → RC=0. **Потолки** `bash scripts/check_ceilings.sh .` → `ok персоны: 9 файл(ов), потолок 51200 байт`, RC=0.
**CI** `gh pr checks 97`: 12/12 pass (ap1–ap5, l1–l7). `gh run view 38720132971 --json headSha` → `6c366f54a802e52a5a681c5189954771017fcb26 success pull_request`.

## 3. Проверка не переписана под реализацию — PASS с оговоркой

Файлы `fixtures/zashchita_main_104/` и `fixtures/_krasnye_104.sh` меняет только коммит architect 7f714159.
Implementer их не трогал. Implementer менял `fixtures/dokazatelstva_098/`, и это ПЕРЕСЕЧЕНИЕ Решения 4,
переданное ему явно. Дифф 3ef470c9 по 11 клеткам 098 механический: к каждому из 14 вызовов
`--verdict-row` дописано `$(_d98_sud "$W" "$M")`, ожидания и предикаты клеток не тронуты.
`model/check_sud_model.sh` — новая честная модель двери по существующему образцу `model/` (по модели на субъект).
Оговорка: семья 104 слаба там, где её писал architect (Рв97-3, A104-1).

## 4. Красное предъявлено — PASS по стабам, FAIL по полноте (Рв97-3)

Стаб-пак 13/13 и приёмки 1/2 — выше. Своей мерой я сломал реальные субъекты головы (копии через `sed … | tee`):

```
[A]  check_sud_model: allowed-модель не сверяется  → КРАСНО: red_sud_model_materializatsija: вход 2 … факт rc=0  (rc=1)
[B]  judge_gate: rc двери 2 → 1                    → КРАСНО: red_judge_gate_svidetelstvo_sudi: вход 4: ожидался rc 2 … факт rc=1  (rc=1)
[C]  spawn-guard: CFG_PATH = HARNESS_TOOLS_ROOT ?: расположение
                                                   → КРАСНО: red_huk_alfavit_ustanovki (rc=1); КРАСНО: red_huk_bez_ustanovochnogo_konfiga (rc=1)
[A2] check_sud_model: break после первой строки роли → ЗЕЛЕНО: red_sud_model_materializatsija (rc=0)   ← не пойман
[R]  check_sud_model стр.159: тир critic для любой роли → 6/6 ЗЕЛЕНО, 13/13, ИТОГ 104: rc=0             ← не пойман (A104-1)
```
Прямой вызов (`--root .`): для A2 трасса `critic gpt-6-astra allowed S1 O` + `critic zai/glm-5.3 denied S1 O` даёт
у реального субъекта `ОТКАЗ: фолбэк вне списка тира: critic на zai/glm-5.3, тир apex (Н-270)` rc=1, у мутанта
`СУДЬЯ СВОЕЙ МОДЕЛИ` rc=0. Для R трасса `reviewer anthropic/claude-opus-5-5 allowed S1 <sha>` даёт у реального
субъекта rc=0, у мутанта `ОТКАЗ: вердикт не материализуется: судья reviewer … тир apex` rc=1.
Это подтверждает A104-1 adversary другим мутантом и добавляет вторую дыру того же класса.

## 5. Атомарность — PASS

Один предмет — одна ветка. Фикстуры architect, реализация, ceiling-fix и регенерация идут отдельными коммитами,
каждый со ссылкой «104». Freeze-коммит — отдельный и он же тег.

## 6. Норма не тронута молча — FAIL (Рв97-2)

`contracts/*` после тега не менялся: `git diff --stat frozen/contracts/104/1 origin/wip/104/implementer2 -- contracts/` пуст,
blob `e4b1e185` одинаков на теге и на голове. Утверждение брифа «diff origin/main..head -- contracts/* пуст»
неверно, там +122 строки freeze-коммита (Рв97-4). `roles/orchestrator.md` — нормативный документ роли. Раздел
Решения 5 лицензирован ПЕРЕСЕЧЕНИЕМ, а сжатие 11 фрагментов чужих разделов (029/011/012/031/Н-51) — нет.
Правка раскрыта в теле коммита, но решение о ней принял implementer. Прецедент 099 Р1-1 относит такую развилку к architect.

## 7. Заявленное равно сделанному — FAIL (Рв97-1), счёт сверен своей мерой

- Авторство 6c366f54. Коммит подписан implementer, создал его оркестратор: `history://Main:533`
  `git -c user.name=implementer … commit`, строка `[wip/104/implementer2 6c366f54]` есть только в JSONL сессии Main,
  в `Implementer104CeilingFix.jsonl` вхождений 0. Это Рв97-1.
- Авторство 072a43255/1f9b2c585 настоящее: строка коммита `072a43255 … (19 files +679 -41)` есть в
  `Implementer104.jsonl` (agent=implementer, glm-5.3). 8931df63 создан `Implementer104CeilingFix` (`[wip/104/implementer2 8931df63]`).
- Счёт: клеток 104 = 6 (`ls fixtures/zashchita_main_104/red_*.sh | wc -l`), стабов = 13 (`grep -c '^progon t104-m'`).
  Это совпадает с контрактом. Клеток 098 по `ls …red_*.sh | wc -l` — 17, а контракт пишет 18 (Рв97-5).
  У adversary «18 клеток» — это 18 строк раннера, восемнадцатая из них `battery_stubs.sh`.
- Тело 3ef470c9 называет «17 клеток, все rc 0». Моя мера та же.

## ПРОВОДКА (038)

`guard=fixtures/_krasnye_104.sh` — барьер именно этого предмета: раннер семьи 104, rc 0 ⟺ стабы ∧ 6 клеток.
`bash scripts/check_provodka.sh . contracts/104-uzkij-doverennyj-gejt-sudi.md` → `проводка: guard не подключён: fixtures/_krasnye_104.sh не вызывается в .githooks/ или .github/workflows/`, rc 1.
Так и объявлено в ПРОВОДКА-ЭНФОРСМЕНТ: подключение ТОЛЬКО ПОСЛЕ landing, прецедент 074 (`package.json:77` `check:ops-server-family-selftest`).
Это открытое обязательство до `done` (Рв97-7). `role=roles/orchestrator.md` — поведенческая норма идёт role-каналом:
раздел «Свидетельство судьи» на голове несёт `OBJECT=<sha>` (40 hex, отдельной строкой) в задании КАЖДОГО судьи, трассу
`--sud` ПОСЛЕ суда только из строк его сессии (`models_actual.sh --tsv --bind | awk -F'\t' -v s=… '$4 == s'`) и запрет
подкладывать трассу другой сессии. Все три обязательства Решения 5 на месте. Механическая часть — чистый энфорсмент
(хук, дверь, писатель), обоснование честное.

## Паразитная сложность (050)

| артефакт | (1) свойство контракта | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `.omp/extensions/spawn-guard.ts` (новый, 120) | Решение 1, И-1/И-2/И-5 | нет (кэш 099 снят, конфиг читается на каждый `task`) | 1 + клетки хука | интерфейс — 1 событие, env не читает | клетки И-1/2/5; живая проба 4а | ESSENTIAL |
| `scripts/check_sud_model.sh` (новый, 337) | Решение 3, И-3а/И-3б/И-4 | нет; rc 0/1/2 в выводе | 1 + model-копия 098 (было 0 → стало 2) | 3 ноги + `--root`; работы много | `judge_gate --sud`, клетки | ESSENTIAL; `--root` — совет Рв97-9 |
| `models_actual.sh --bind` (+54) | Решение 2, И-7 | нет | 1 | +1 флаг; `--bind` без `--tsv` шире грамматики | норма Решения 5 | ESSENTIAL; форма без `--tsv` — совет Рв97-8 |
| `judge_gate.sh --sud` (+43) | Решение 4, И-6 | нет | 1 + `model/judge_gate.sh` 098 | 5\|9 аргументов | клетка И-6, 14 мест 098 | ESSENTIAL |
| `dokazatelstva_098/model/check_sud_model.sh` (61) + `_d98_sud` | Решение 4а (миграция) + образец `model/` 098 | файл трассы `sud-<sha>.tsv` в мире клетки, явный | грамматика `--verdict` живёт в 2 местах (субъект + модель) | малая | стаб-пак/`--model` 098 | ESSENTIAL по образцу `model/` (по модели на субъект; реальный субъект в стаб-паке связал бы 098 с 104) |
| семья `fixtures/zashchita_main_104/` + `_krasnye_104.sh` (одним артефактом) | Инварианты, приёмки 1–3/6 | миры `/tmp/dev-harness-verify/zashchita-104-*`; env `Z104_SPAWN_GUARD`, `D104_SUBJECTS_DIR` (только стаб-пак) | 1 семья | — | ПРОВОДКА guard | ESSENTIAL; полнота — Рв97-3 |
| раздел роли «Свидетельство судьи» | Решение 5 | — | 1 + производная `.omp/agents/` (генератор) | — | role-канал | ESSENTIAL |

ACCIDENTAL с полной тройкой (фрагмент, отсутствующее свойство, более простая форма) не найдено.

## Итог

| находка | класс | блок |
|---|---|---|
| Рв97-1 | авторство: регенерация 6c366f54 сделана оркестратором под `user.name=implementer` (Н-289-класс) | **да** |
| Рв97-2 | область правки/норма: сжатие 11 чужих фрагментов роли вопреки границе задания; решение — architect/владелец | **да** (закрывается словом, не кодом) |
| Рв97-3 | дыра батареи: A104-1 подтверждён мутантом R; «каждая строка роли» не пришпилена (мутант A2) | **да** (зона architect) |
| Рв97-4 | бриф: «diff contracts/* пуст» неверно (+122 freeze-коммита); верное — blob = тег | нет |
| Рв97-5 | контракт: «клеток 098 = 18», по его же команде 17 | нет |
| Рв97-6 | живая проба `--bind`: rc 2 на зоне c907157c (`Arbiter079Б1`), 960/2258; rc глушится конвейером нормы | нет |
| Рв97-7 | ПРОВОДКА: guard подключается после ленда — обязательство до done | нет |
| Рв97-8 | `--bind` без `--tsv` — интерфейс шире контракта | нет (совет) |
| Рв97-9 | `--root` у `--verdict`: override закрыт только через judge_gate | нет (совет) |
| Рв97-10 | семейство: фикстуры и регенерация — из семейства судьи | нет |
| Рв97-11 | пустой batch → пропуск (согласие с adversary) | нет |

Сам код субъектов (spawn-guard, check_sud_model, models_actual --bind, judge_gate --sud) верен на всех моих пробах.
Для ленда нужно три вещи: честное авторство регенерации (Рв97-1), слово architect или владельца о сжатии роли (Рв97-2)
и клетки семьи 104 с не-`critic` входами и многострочной трассой (Рв97-3 + A104-1).

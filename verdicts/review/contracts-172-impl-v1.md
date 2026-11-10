accept

# Вердикт ревьюера — 172, реализация (вызов 1)

- SUBJECT: 172 — преддверие судейской проводки
- OBJECT: db303b0e155eb747b7e6dbdf88c2e2c86a003dda (`wip/172/implementer`, PR #654; один коммит
  автора `implementer`)
- Контракт: `frozen/contracts/172/1` → 24cc7ea9c. Блобы на OBJECT равны тегу:
  контракт afca3e64, `red_predverie_172.py` 2b6ffaad, `reference.py` 0c36b660.
- Принятые блобы: `scripts/pre_judge.sh` 07e32e55, `roles/orchestrator.md` 15f976de,
  `.omp/agents/orchestrator.md` 372ba777. Новая редакция любого из них это accept не наследует.
- Класс задачи: кодовый. Класс риска: обычный, адверсарий не нужен.
- Находки: `.review/2026-11-09-95.md`. Блоков 0, советов 2 (С-1, С-2), наблюдений для
  orchestrator 1 (О-1).

## 1. Область правки ⊆ зоны

Зона из frozen-блоба: `ЗОНА implementer: scripts/pre_judge.sh roles/orchestrator.md .omp/agents/orchestrator.md`.

```
$ git diff --name-only origin/main...db303b0e1        # merge-base a58872bff (freeze registry 172)
.omp/agents/orchestrator.md
roles/orchestrator.md
scripts/pre_judge.sh
$ git log --format='%h %an %s' origin/main..db303b0e1
db303b0e1 implementer 172: pre-judge door prepare/sync-main/verdict/archive + orchestrator norm line
```

Три файла, все из зоны. В PR #654 тот же список (Files (3): +6/-0, +6/-0, +362/-0). Правка
роли — только новый раздел, удалений 0. Это соответствует ПЕРЕСЕЧЕНИЕ «только новый шаг» /
«только генерация нового шага». `true | bash scripts/check_zones.sh` на дереве OBJECT. stdin закрыт: под `reslop t` первый
прогон 9 минут висел в `pipe_read` и был снят.

```
замороженных контрактов: 159 · объявленных авторов: 5 · коммитов в диапазонах: 49946 · проверено по зонам: 12418
rc=1
```

rc=1 к OBJECT не относится. Строки FAIL я разобрал своей мерой, regex по журналу прогона:
`FAIL 174 mint-lightweight-tag 174 other 0`, `mentions db303/implementer-172: 0`. Все 174
отказа одного класса: коммит orchestrator в `registry/contracts.tsv`, «дверь минта 031: тег …
не аннотированный». В этом клоне все `id/CONTRACT/*` — лёгкие теги (`for-each-ref`: 185
commit, 0 tag), origin недоступен. Это станционный класс Н-181: те же коммиты 63c3d44f… уже
лежат в main. Строк про implementer или db303b0e1 нет.

Вторая мера: `git log --format='%h %an' --name-only frozen/contracts/172/1..db303b0e1`. В
диапазоне два коммита: `db303b0e1 implementer` (3 файла зоны) и `a58872bff orchestrator`
(`registry/contracts.tsv`, freeze-запись; это канал оркестратора, а не implementer).

## 2. Батарея — мой прогон (дерево OBJECT, worktree /tmp/dev-harness-verify/review172/obj)

```
== --repo
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
rc=0
== --model
(те же 16 строк, все ok)
rc=0
== --stabs
STAB stale_origin caught on stale_origin
STAB allow_incomplete_prepare caught on prepare_no_state
STAB state_inside caught on state_inside
STAB ignore_manifest caught on manifest_wait
STAB ignore_leak caught on leak_reject
STAB allow_nonff caught on nonff_sync
STAB ref_only_ff caught on ff_sync
STAB allow_main_verdict caught on staged_main_verdict
STAB allow_main_verdict caught on committed_main_verdict
STAB allow_incomplete_verdict caught on verdict_no_file
STAB allow_nonjudge_verdict caught on nonjudge_verdict
STAB allow_archive_worktree caught on archive_attached
rc=0
```

Счёт сверен второй мерой: AST батареи даёт `CASES 16`, `MUTATIONS 12`. Токены повторного
прогона: `ok-tokens 16 KRASNO 0`, `caught 12 ZHIV 0`. Значит 16/16, 16/16 и 12/12, как
заявлено.

**Красное предъявлено.** Та же батарея на дереве main 3780cd1dd, где `scripts/pre_judge.sh`
нет, даёт 16 строк `<клетка> KRASNO (rc=2)` и rc=1. Каждая клетка названа отдельно.

## 3. Реализация против инвариантов контракта (не только батарея)

Пробы — throwaway `/tmp/dev-harness-verify/review172/probe.py` (sha256 af4f11ca…). Каждая
работает в своём временном репозитории с bare origin. Имена (`wip/301/backend`), OID и пути в
них отличаются от фикстуры. Итог: `probes: 19/19 PASS`, rc 0.

| Инвариант §Предмет | Проба / наблюдение | Итог |
|---|---|---|
| prepare: S абсолютный, cwd не угадывается | P4: `--sostojanie st` (относительный, cwd=база) → rc 1 `ОТКАЗ: NE_POLNYJ_VHOD` | ok |
| S строго вне realpath R | P3: S — внешний symlink на `R/inner` → rc 1 `SOSTOJANIE_V_CHECKOUT` (канон через `pwd -P`) | ok |
| OBJECT = tip origin/B, не HEAD | P5: HEAD на другой ветке с новым коммитом → `OBJECT=<origin/B>`, HEAD в выводе нет | ok |
| Устаревшая публикация: готовая команда, push не делается | P7: локальный ahead → rc 1 `VETKA_NE_OPUBLIKOVANA` + `bash scripts/gitw push origin wip/301/backend`; tip в bare не изменился | ok |
| Ожидание уборщика манифестов | P1: `.omp/context/301.tsv` убран фоном через 0.6 с, `--timeout 5` → rc 0 за 0.61 с (дверь действительно ждала) | ok |
| Манифест не удаляется за уборщика | P2: истёк срок → `MANIFESTY_NE_UBRANY`, файл на месте | ok |
| Действующий `check_no_leak.sh --check R` | P6: детектор получил argv `--check /tmp/…/r` (абсолютный R) | ok |
| Нет детектора → rc 2 | P8: rc 2 `NOT_IMPLEMENTED: нет детектора утечки` | ok |
| sync-main: local ahead → отказ без мутации, готовая команда | P9: rc 1 `MAIN_NE_FAST_FORWARD`, main не тронут; команда из stderr, исполненная как есть, сохранила tip в `wip/301/backend-main-saved` и вернула main к origin/main | ok (имя — см. С-1) |
| sync-main при равенстве | P10: rc 0 `MAIN=<tip>` | ok |
| чистый main | P11: грязный tracked → rc 1 `MAIN_NE_CHISTY` | ok |
| verdict: судейские ветки | P12: `wip/301/reviewer`, `wip/301/arbiter` → rc 0; `wip/301/backend-x`, `archive/301/critic` → `NE_SUDJSKAJA_VETKA`; P13: detached → `NE_SUDJSKAJA_VETKA` | ok |
| archive: только `branch refs/heads/archive/*`, worktree сохраняется | P14a: detached worktree на коммите archive → rc 0; P14b: прикреплённый → rc 1 `ARCHIVE_WORKTREE`, каталог на месте | ok |
| Сбой Git → rc 2 | P15: не репозиторий / подкаталог → rc 2 `NOT_IMPLEMENTED` | ok |

**Живой смоук на станции.** Запуски на `/home/harness/dev-harness` только читают: archive,
prepare, verdict. sync-main не запускал, он мутирует.

```
ARCHIVE_WORKTREE=0
archive rc=0
OBJECT=db303b0e155eb747b7e6dbdf88c2e2c86a003dda
SOSTOJANIE=/tmp/dev-harness-verify/review172
prepare rc=0          (действующий детектор check_no_leak.sh — зелёный, 74 с)
ОТКАЗ: NE_SUDJSKAJA_VETKA
ветка 'main' не судейская
verdict rc=1
```

**Подгонка под фикстуру — не найдена.** В `scripts/pre_judge.sh` нет ни одного литерала
фикстуры: grep `architect|STAB|fixture|predverie|reference|leak\.flag|critic/contracts|README`
дал 0 совпадений по смыслу (все попадания — `remote_tip`/`remote_main`). Дверь не читает
`reference.py`, `STAB_172` и вообще ничего из `fixtures/`. Имя схоронки дверь выводит из
локальных refs: на чужих входах P9 выдало `wip/301/backend-main-saved`. Отказы — общие
предикаты Git (`rev-parse`, `merge-base --is-ancestor`, `status --porcelain`, `log -1 --`,
`worktree list --porcelain`). Кодов за пределами перечня контракта шесть:
`VETKA_NE_FIT_AUTORA`, `VETKA_NET_LOKALNO`, `SOSTOJANIE_NE_NAIDEN`, `MAIN_NE_CHISTY`,
`NE_NA_MAIN`, `VERDIKT_VNE_REPO`. Каждый закрывает отдельный некорректный вход, и ни один не
подменяет перечисленные контрактом коды на их входах.

**Мутанты самого предмета** (throwaway `/tmp/dev-harness-verify/review172/mut.sh`: правка
`scripts/pre_judge.sh` в review-worktree → батарея `--repo` → `git checkout --` файла):

```
M1_ignore_leak_rc: battery rc=1 KRASNO=[leak_reject ]
M2_archive_any: battery rc=1 KRASNO=[archive_attached ]
M3_object_local: battery rc=0 KRASNO=[]
M4_no_dirty_check: battery rc=0 KRASNO=[]
M5_updateref_ff: battery rc=1 KRASNO=[ff_sync ]
```

M3 (`OBJECT=$local_tip`) — эквивалентный мутант: печать идёт только после проверки
`local_tip == remote_tip`, отличить их нечем. M4 (снят отказ `MAIN_NE_CHISTY`) батарея не
ловит. В строках приёмки предусловия «на чистом main» нет. Само поведение я подтвердил пробой
P11: грязный tracked-файл → rc 1 `MAIN_NE_CHISTY`. Это пробел покрытия у батареи architect, а
не дефект реализации, в находки не вношу.

**Свежесть origin.** prepare сверяет локальный tip с remote-tracking `refs/remotes/origin/B`
и сам не fetch'ит. Так же устроена честная модель `reference.py`. По §Предмет fetch идёт
через `gitw` до sync-main. Отклонения от замороженного обязательства нет.

## 4. Норма-строка и генерация

Скрипт извлёк замороженную строку `- role=roles/orchestrator.md «…»` из блоба тега 172/1 и
сравнил её побайтово с файлами: `roles/orchestrator.md exact-line-matches= 1`,
`.omp/agents/orchestrator.md exact-line-matches= 1`.

```
$ npm run gen:harness -- --check
харнес соответствует roles/ (12 ролей)
rc=0
$ npm run gen:harness            # вторая мера: перегенерация + git status
сгенерировано: 12 ролей, обновлено файлов: 0
(git status --porcelain пуст)
```

## 5. Приёмка контракта и проводка

```
$ reslop t -- bash scripts/pre_critic.sh --repo . contracts/172-predverie-sudejskoj-provodki.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
  ok   гейт трека:
exit: 0
$ reslop t -- bash scripts/check_project_sources.sh --repo . --contract contracts/172-predverie-sudejskoj-provodki.md --stage done
exit: 0
$ reslop t -- bash scripts/check_provodka.sh . contracts/172-predverie-sudejskoj-provodki.md
проводка: guard не подключён: scripts/pre_judge.sh не вызывается в .githooks/ или .github/workflows/
exit: 1
```

check_provodka красный ожидаемо: CI-строка 172 принадлежит зоне orchestrator и пишется после
ленда («До подключения CI guard-канала done невозможен»). Дефектом реализации это не
является. Есть подводный камень подключения, он описан в О-1.

ПРОВОДКА (038). Role-канал существует и подключён: строка в `roles/orchestrator.md` и в
сгенерированном агенте. Guard `scripts/pre_judge.sh` — барьер именно этого предмета, его
красное несёт батарея 172. CI-подключение — после ленда (О-1).

## 6. Scoped-регресс

```
$ reslop t -- bash scripts/verify_antiplacebo.sh --scope pre_judge
SCOPED: барьеров 1 из выборки — не для приёмки
  FAIL pre_judge.sh: нет фикстур — ожидается fixtures/pre_judge/case_*.sh
барьеров: 1 · фикстур: 0 · предъявлено красным повторным прогоном: 0
exit: 1
```

Класс находки — совет С-2, не блок. Красное доказательство барьера дано батареей контракта
(`--stabs` 12/12). Зона implementer не включает `fixtures/pre_judge/`. Моя мера по шапкам на
дереве OBJECT: 73 барьера, из них 28 без `fixtures/<key>/case_*.sh`, то есть 27 прежних плюс
`pre_judge`. Ключа `pre_judge` в CI-шардах antiplacebo нет, поэтому CI это не краснит.

Слияние с текущим main: правок тех же трёх путей в `a58872bff..origin/main` нет,
`git merge-tree --write-tree origin/main db303b0e1` rc 0.

CI PR #654 «16 pass, 0 fail» взят из spawn evidence оркестратора, сам я его не наблюдал.

## 7. Атомарность, проверки не переписаны, норма

- Атомарность. Один коммит, одна задача, ссылка на предмет «172:». ok.
- Проверка не подогнана. Коммит автора не трогает `fixtures/` и контракт, блобы равны тегу
  (§шапка). ok.
- Норма. Правка `roles/orchestrator.md` — это ПРОВОДКА-строка, которую требует сам
  замороженный контракт: дословная, новый раздел, 0 удалений. Молчаливой правки нормы нет.

## 8. Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `scripts/pre_judge.sh` (дверь, 4 режима) | §Предмет: prepare/sync-main/verdict/archive | без своего state-файла; читает refs/worktree/`.omp/context` R, всё видно в argv `--repo/--branch/--sostojanie/--file` и выводе `OBJECT=/SOSTOJANIE=/MAIN=/…` | 1 (+ роль, если меняется вызов) | интерфейс 5 флагов / 4 режима против ~200 строк проверок Git — глубокий | батарея 172 `--repo` (строка приёмки 1), роль orchestrator шаг 0; детектор утечки переиспользован, второго нет | ESSENTIAL |
| `save_branch_name` (~40 строк) | §Предмет: готовая команда с `wip/<N>/<author\|judge>-main-saved`; клетка `nonff_sync` требует `branch wip/172/architect-main-saved` | неявный вход: порядок локальных `wip/*` по committerdate (в argv не виден) | 1 | мелкий хелпер | клетка nonff_sync; более простой формы при входе только `--repo` нет | ESSENTIAL (fallback вне `wip/` — С-1) |
| `timeout_ms` | `--timeout` конечный и дробный (батарея даёт 0.05) | нет | 1 | мелкий | клетка manifest_wait | ESSENTIAL |
| 6 доп. кодов отказа | неполный/некорректный вход (S обязателен, чистый main, ветка вида wip/N/x) | нет | 1 | — | `NE_NA_MAIN`/`MAIN_NE_CHISTY` — предусловие «на чистом main» из §Предмет; остальные — граница входа | ESSENTIAL |
| Норма-строка роли + генерация агента | ПРОВОДКА role= | нет | 2 (роль + генерат), так устроено 002/003 | — | check_provodka role-канал | ESSENTIAL |

## СВЕРКА-СТАНДАРТОВ

Не применимо. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` /
`docs/CODING-STANDARDS.md`, файлов нет. `harness.project.json` не объявляет `sourceCanon`,
поэтому норма 996/1 не применяется. Мобильного экрана нет.

## Итог

accept для OBJECT db303b0e155eb747b7e6dbdf88c2e2c86a003dda на frozen/contracts/172/1.
Блоков нет. Советы С-1 и С-2 и наблюдение О-1 — в `.review/2026-11-09-95.md`. Done
по-прежнему требует CI-строку orchestrator и зелёный `check_provodka`.

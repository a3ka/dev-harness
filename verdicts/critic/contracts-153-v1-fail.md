FAIL
OBJECT=bcacc85caa7c42beaef316221f66f3a905ee4669
СУД: repo=dev-harness; предмет=153; фаза=контракт (+красная батарея); роль=critic; вызов=1/2; модель-план=anthropic/claude-opus-5-5; сессия=Crit153; модель-факт=anthropic/claude-opus-5-5; SHA=bcacc85caa7c42beaef316221f66f3a905ee4669; предыдущий=нет; исключение=нет. Автор OBJECT: architect (все 5 коммитов wip/153/architect, %an=architect), модель автора по отчёту /tmp/dev-harness-verify/Arch153/report.md — openai-codex/gpt-6-sol; семейства разные, независимость соблюдена. Судился только закоммиченный OBJECT в одноразовом клоне /tmp/dev-harness-verify/Crit153/repo (`git cat-file -t` → commit); мутации — в отдельном одноразовом клоне /tmp/dev-harness-verify/Crit153/mut, восстановлен `git checkout -- .`, `git status --short` пуст. Дерево contracts/153 + fixtures/workshop_project/ OBJECT == main 0d9bb228b (`git diff --stat` пуст).

Итог: один блокирующий класс — положительные клетки батареи покрывают цифру 0 только ВНУТРИ имени, поэтому реализация, оставляющая ложный отказ по 0 в начале/конце/как целый компонент, проходит все команды приёмки. Остальное (настоящий NUL, прежние отказы, честность батареи, 996, ворота) измерено и держится.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/153-nul-v-puti-istochnika.md:25 (И-1 «цифра 0 сама по себе не основание SOURCE_CANON_INVALID») и :34-37 (приёмка W/--model/--stabs/--repo) — критерий слабее предмета: все три положительные клетки (`migrations/001_core.sql`, `10.sql`, `a0b/0.md`; fixtures/workshop_project/nul_istochnika_153/probe.py:44-45) несут 0 только в середине пути; ни одна не начинается и не кончается на 0 и не имеет компонента «0» целиком в начале.
ОБХОД: реализация заменяет строку 111 `*\0*)` на `0*|*0) die "SOURCE_CANON_INVALID: NUL в пути: $p"` (мутант edge-zero) либо на `0|*/0)` (whole-zero) — `W` rc 0 `CELLS=9 GREEN=9`, `W --stabs` rc 0 `SVJAZI=8 CAUGHT=8 LIVE=0`, а допустимые пути `0`, `0.md`, `v1.0`, `0/x.md`, `x/0` получают тот же ложный отказ «NUL в пути» (сырые выводы ниже, §Атаки А-1).
ОБЯЗАТЕЛЬСТВО: И-1 (:25) и воля владельца (docs/owner/2026-11-01-done-gate-nul.md §Боль: «любой путь источника с цифрой 0 отказывает ложно» → красный тест на путь с цифрой 0); класс причины — ложная достаточность критерия (позиционное недопокрытие положительных входов).
СОСТОЯНИЕ: дерево после реализации с мутантом edge-zero/whole-zero в scripts/check_project_sources.sh; resolver принимает эти пути (модель: `0`, `0.md`, `v1.0`, `0/x.md`, `x/0` → rc 0, gate=True).
НАБЛЮДЕНИЕ: мутанты зелёные на всей приёмке; на живых входах rc 1 `ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0.md` и т.д.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: положительные клетки батареи покрывают 0 как первый символ пути, как последний символ пути и как целый компонент (в начале и в конце), каждую — до ремонта красной по «NUL в пути», на модели зелёной; обманка, отвергающая 0 в любой из этих позиций, красна своей клеткой в `W` (и при желании автора — отдельной связью `--stabs`). Конкретный выбор имён — за автором.

## САМООПИСАНИЕ (полный список «утверждение → живое значение»)

1. :34 `CELLS=9 GREEN=6`, красны ровно 3 пути с 0, причина «NUL в пути» → живое `W`: rc 1, CELLS=9 GREEN=6, RED backend/ten/nested — каждый `SOURCE_CANON_INVALID: NUL в пути: <path>`. Совпадает.
2. :35 `W --model`, `W --model --seed 7` → rc 0 `CELLS=9 GREEN=9` → живое: seeds 0/1/7/42 — каждый rc 0 CELLS=9 GREEN=9. Совпадает.
3. :36 `SVJAZI=8 CAUGHT=8 LIVE=0` → живое `--stabs` (seed 0) и `--stabs --seed 42`: rc 0 SVJAZI=8 CAUGHT=8 LIVE=0. Совпадает. Примечание: 8 связей = 7 различных правок — `accept-directory` и `accept-fifo` (probe.py:84-85) несут одну и ту же замену `-f`→`-e`, привязанную к двум клеткам; «8 стабов» в задании = 8 связей, не 8 различных обманок.
4. :36 негатив «выжившая обманка → rc 1 STAB_SURVIVED» → живое (одноразовый клон, добавлен no-op стаб `noop`→backend): `STAB_SURVIVED noop backend: rc=0 stderr='' gate=True`, `SVJAZI=9 CAUGHT=8 LIVE=1`, rc 1. Совпадает.
5. :37 «`W` и `W --repo` — оба rc 0» → это один и тот же режим: probe.py:170 `mode = 'model' if args.model else 'repo'`; без флага == `--repo` (живое: оба rc 1 CELLS=9 GREEN=6 до ремонта, вывод идентичен). Две команды, одно измерение — не два независимых доказательства.
6. :37 шесть отрицательных клеток (NUL, absolute, dotdot, outside, directory, fifo) → CASES: 6 с rc 1, 3 с rc 0. Совпадает.
7. :9 `case "$p" in *\0*)` → scripts/check_project_sources.sh:108 (`case "$p" in`), :111 (`*\0*)`). Совпадает.
8. :11 scan_canon `contains("\u0000")` для path и gate → scripts/profile_resolver.sh:443 (path), :501 (gate). Совпадает. Задание: «profile_resolver.sh:442-445» → предикаты $pth занимают 441-445 (441 type, 442 length, 443 NUL, 444 `..`, 445 `/`); NUL/../ — 443-445.
9. :19 `contains("..")` → profile_resolver.sh:444 и :457. Совпадает (отчёт автора «444,457» — совпадает).
10. :13 «`registry/plan.tsv` в этой ветке ещё не несёт 153» → на OBJECT `grep -c 153 registry/plan.tsv` = 0 — верно; но в main строка есть: `origin/main:registry/plan.tsv:86` `153	3	до V-2	-	docs/owner/2026-11-01-done-gate-nul.md#Порядок	autonomy` (влита 33f3e80d7, не предок OBJECT). Утверждение станет ложным в момент приземления в main — формулировка привязана к ветке, не к дереву, где контракт будет жить.
11. :13/:127 PR #470 `owner/plan-153` → живое pr://470: CLOSED, head owner/plan-153, 3 файла (ROADMAP.md, docs/owner/2026-11-01-done-gate-nul.md, registry/plan.tsv), «влито в main как 33f3e80d7». Совпадает.
12. :5 «done по 142/143/144» → docs/owner/2026-11-01-done-gate-nul.md: «142/2, 143/1, 144/1». Совпадает. Расходится соседний источник: NABLIUDENIA.md:8277-8279 (Н-405) называет «done 001/002 Complior-back» — контракт следует записи владельца, Н-405 — иной счёт.
13. :26 причина `path NUL` → живое stderr `…sourceCanon.sources[0]: path NUL`. Совпадает. Батарея судит подстроку `NUL` (probe.py:96), не `path NUL`.
14. :27 причины «источник вне репозитория», «источник не regular file» → живое stderr. Совпадает.
15. :38 996 rc 0; задание «111 кейсов» → живое `996: examined=111 mutants=0 mismatches=0`, rc 0. Совпадает.
16. ПЕРЕСЕЧЕНИЕ :45-108 → счёт строк: ci.yml 44, ci-steps.tsv 17 (:47 + :92-107), ci-zamery.tsv 1, implementer 1; итого 63 (отчёт автора «62 CI» = 44+17+1 — совпадает). `check_precision_gate.sh` → OK rc 0.
17. Задание: батарея `fixtures/workshop_project/<батарея>_153/red_*.sh` → в OBJECT `red_*.sh` нет; батарея — `fixtures/workshop_project/nul_istochnika_153/probe.sh` (+probe.py, .probe-only). Расхождение текста задания, не контракта.
18. Задание «check_project_sources.sh:111» → :111. Совпадает. Отчёт автора «check_project_sources.sh:55» (stage) → :55. Совпадает. Отчёт «lib_incr.sh:109-111» → :109 комментарий, :110-112 `if [ -z "$INCR_CACHE" ]; then return 0; fi`. Сдвиг на одну строку в конце диапазона.
19. Модель угроз → `check_threat_model.sh . <контракт>`: «ЗАЩИЩАЕТ 3 буллет(ов), НЕ ЗАЩИЩАЕТ 4» — соответствует :120-129.

## СОВЕТ

СОВЕТ contracts/153-nul-v-puti-istochnika.md:127 — граница «управляющие символы вне объёма» обоснована измерением: существующего отказа на управляющих символах нет, «сохранять» нечего (модель: `a\tb0.md` → rc 0). Но измерено соседнее следствие того же класса «путь превращается в соседний валидный»: JSON path `"x\ny.md"` при существующих `x` и `y.md` (и отсутствующем `x\ny.md`) даёт rc 0, gate=True — `mapfile` расщепляет путь на два соседних, проверяется не объявленный файл (до и после ремонта одинаково; attack.py «newline»). Запись владельца говорит «сохранение отказа на настоящем NUL/управляющем символе» — решение по управляющим символам (включая перевод строки) оркестратору стоит получить словом владельца до done, а не после; контракт честно передаёт его наверх.
СОВЕТ :19/:126 — решение по `*..*` (подстрока против компонента) оцениваю как правильное для 153: подстроку запрещает замороженный resolver (:444), а не только case в шлюзе; `a..b.md` → rc 1 `path ..` уже в resolver. Смена — отдельный предмет. Блокировать нечем.
СОВЕТ :45 — мутант cntrl (`*[[:cntrl:]]*` вместо строки 111) зелёный на `W`, `W --stabs` и вводит новый отказ (`a\tb0.md` → rc 1 «NUL в пути») — расширение замороженной грамматики, запрещённое текстом ПЕРЕСЕЧЕНИЯ («удалить лишь ложный NUL-case»), но не клеткой. Не блокирую: закрывающая клетка «tab принимается» предрешила бы вопрос, переданный владельцу (см. выше). Держится ревьюером по диффу.
СОВЕТ :45 — мутант strip-all-case (удалить также `/*)` и `*..*)` в шлюзе) зелёный на `W` (резолвер отказывает раньше, поведение эквивалентно; ср. .review/2026-10-19-16.md:70 С3-2), но `W --stabs` падает `AssertionError: MUTANT_ANCHOR check_project_sources.sh: 0` (rc 1) — ловится якорями стабов, а не клеткой. Приёмка :37 и CI (:116) судят только безфлаговый `W`; если хочется, чтобы ПЕРЕСЕЧЕНИЕ «только эта строка» держалось механизмом, — включить `W --stabs` в пункт 4 и CI-строку.
СОВЕТ :36 — после ремонта `--model` совпадает с реализацией (probe.py:113-114 удаляет NUL-case только если он есть) — режим теряет самостоятельный смысл, это ожидаемо; отметить в тексте, что пункт 2 — доказательство до реализации.
СОВЕТ — класс «литерал 0 вместо NUL» по всему харнессу: `grep '\*\\0|\$'\''\\0'\''|\$'\''\\x00'\'''` по дереву OBJECT → единственный шаблон `case` с `\0` — scripts/check_project_sources.sh:111; прочие вхождения корректны (`tr '\0'` — octal NUL; `read -d $'\0'` в check_precision_gate.sh:500 — пустой разделитель = NUL; Python/TS `'\0'`/`b'\0'` — настоящий NUL). Других мест в объём добавлять не нужно.
СОВЕТ — jq на станции — `jaq 2.3.0`; в CI — системный jq. Замороженный resolver полагается на `contains("\u0000")`; под jq 1.6 (strstr) этот предикат истинен для любой строки, под 1.7+ корректен. 153 его не меняет; батарея 996 и 153 в CI сразу покажут, если раннер окажется на 1.6.

## Атаки (команды и сырой вывод)

А-0 Мера приёмки на OBJECT (клон repo):
```
$ bash fixtures/workshop_project/nul_istochnika_153/probe.sh            → RED backend/ten/nested «NUL в пути: …»; CELLS=9 GREEN=6; rc=1
$ … --model                                                               → CELLS=9 GREEN=9; rc=0
$ … --model --seed 0|1|7|42                                               → каждый CELLS=9 GREEN=9; rc=0
$ … --repo                                                                → CELLS=9 GREEN=6; rc=1 (вывод идентичен безфлаговому)
$ … --stabs                                                               → CAUGHT false-zero backend / accept-all nul / skip-nul-json nul / skip-absolute absolute / skip-dotdot dotdot / skip-canonical outside / accept-directory directory / accept-fifo fifo; SVJAZI=8 CAUGHT=8 LIVE=0; rc=0
$ … --stabs --seed 42                                                     → SVJAZI=8 CAUGHT=8 LIVE=0
$ bash fixtures/workshop_project/rezhim_996/probe.sh                      → 996: examined=111 mutants=0 mismatches=0; rc=0
$ bash scripts/pre_critic.sh contracts/153-nul-v-puti-istochnika.md       → «КРИТИК: дверь зелёная»; rc=0
$ bash scripts/check_ceilings.sh                                          → «потолки в порядке»; rc=0
$ bash scripts/check_provodka.sh . contracts/153-nul-v-puti-istochnika.md → (пусто); rc=0
$ bash scripts/check_precision_gate.sh . contracts/153-nul-v-puti-istochnika.md → OK; rc=0
$ bash scripts/check_threat_model.sh . contracts/153-nul-v-puti-istochnika.md → «секция валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 4)»; rc=0
$ bash scripts/check_spec_ready.sh . contracts/153-nul-v-puti-istochnika.md → OK; rc=0
$ bash scripts/check_zones.sh                                             → полный прогон на checkout OBJECT: «замороженных контрактов: 146 · объявленных авторов: 5 · коммитов в диапазонах: 40315 · проверено по зонам: 9504», FAIL-строк в хвосте нет; elapsed=375.17; rc=0
```

А-1 Мутанты реализации (scripts/check_project_sources.sh в клоне mut; /tmp/dev-harness-verify/Crit153/attack/mutate.py), прогон `W` (= реальный скрипт):
```
honest         (удалить :111)                         → CELLS=9 GREEN=9  W rc=0
edge-zero      (:111 → `0*|*0)`)                      → CELLS=9 GREEN=9  W rc=0   ← ВЫЖИЛ
whole-zero     (:111 → `0|*/0)`)                      → CELLS=9 GREEN=9  W rc=0   ← ВЫЖИЛ
cntrl          (:111 → `*[[:cntrl:]]*)`)              → CELLS=9 GREEN=9  W rc=0   ← ВЫЖИЛ (СОВЕТ)
comp-zero      (:111 → `*/0*|0*)`)                    → RED backend, RED nested; CELLS=9 GREEN=7  W rc=1
ansi-nul       (:111 → `*$'\0'*)`)                    → RED backend/ten/nested/outside/directory/fifo; CELLS=9 GREEN=3  W rc=1
strip-all-case (удалить :109-111)                     → CELLS=9 GREEN=9  W rc=0   ← ВЫЖИЛ на W (СОВЕТ)
edge-zero      W --stabs                              → SVJAZI=8 CAUGHT=8 LIVE=0  rc=0
strip-all-case W --stabs                              → AssertionError: MUTANT_ANCHOR check_project_sources.sh: 0  rc=1
```
Следствие edge-zero на допустимых входах (attack.py, режим real на мутированном дереве):
```
pos '0':      rc=1 gate=False stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0'
pos '0.md':   rc=1 gate=False stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0.md'
pos 'v1.0':   rc=1 gate=False stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: v1.0'
pos '0/x.md': rc=1 gate=False stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0/x.md'
pos 'x/0':    rc=1 gate=False stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: x/0'
```
whole-zero: `pos '0'` rc=1 «NUL в пути: 0»; `pos 'x/0'` rc=1 «NUL в пути: x/0»; `pos '0.md'` rc=0.
cntrl: `pos 'a\tb0.md'` rc=1 «NUL в пути: a\tb0.md».

А-2 Настоящий NUL и ложные отказы на модели честного ремонта (attack.py repo model; та же картина на `real` для NUL-входов):
```
pos '0' / '0.md' / 'v1.0' / '0/x.md' / 'x/0' / 'a 0 b.md' / 'тест0.md' / 'a\tb0.md' → каждый rc=0 gate=True stderr=''
pos 'a..b.md'      → rc=1 «профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path ..» (замороженная грамматика, по решению :19)
newline 'x\ny.md' (есть x и y.md) → rc=0 gate=True stderr=''   (СОВЕТ, вне объёма)
nul '\x00src.md' / 'src\x00.md' / 'src.md\x00' / '.\x00.\x00/src.md' (соседний src.md существует) → rc=1 «…sources[0]: path NUL»
nul 'sub\x00/../src.md' → rc=1 «…path ..»
nul second source       → rc=1 «…sources[1]: path NUL»
nul in gate[0] / gate[1] → rc=1 «…sourceCanon.gate[null]: NUL»   (индекс печатается `null` — косметика замороженного resolver, profile_resolver.sh:502 `.key` вместо `$e.key`)
nul in key {"path\u0000":…} → rc=1 «…sources[?]: неизвестный ключ: path» (+ warning bash «ignored null byte» в stderr)
nul defaults-layer only / defaults + repo valid → rc=1 «слой-проекта.defaults.sourceCanon.sources[0]: path NUL»
outside via defaults (link.md → /etc/hostname) → rc=1 «источник вне репозитория: link.md»
dir symlink d→/etc, path d/hostname → rc=1 «источник вне репозитория: d/hostname»
```
Что сделал бы шлюз, пропусти resolver NUL (attack/mapfile_nul.sh): `jq -r` печатает байт NUL как есть (`s r c \0 . m d \n`), `mapfile -t` усекает строку на NUL: `A=([0]="src" [1]="x" [2]="y.md")` — путь превращается в соседний префикс. Защита от этого — только resolver (оба слоя, path и gate, измерено выше); стаб skip-nul-json это ловит клеткой nul по причине (`NUL` отсутствует в «SOURCE_CANON_MISSING»).

А-3 Честность батареи: без флага и `--repo` исполняют реальный `scripts/check_project_sources.sh` из корня харнесса (probe.py:101-103, 130); `--model`/`--stabs` — копии реальных gate+resolver с одной заменой (probe.py:104-119), якорь обязан встречаться ровно один раз (probe.py:27-31). Двойников времени/ожидания нет (timeout=30 только как предел subprocess). Каждый мир — свой `git init` во временном каталоге; gate наблюдается файлом `gate-observed`, отрицательные клетки требуют его отсутствия (probe.py:137-141). Каждый стаб ловится своей клеткой по содержательной причине (REASONS), а не побочным rc: accept-all/skip-* дают rc 0 либо иную причину — сверено по выводу CAUGHT. Батарея 996 не тронута (`git diff --stat 0d9bb228b bcacc85ca -- fixtures/workshop_project/rezhim_996` пуст; дерево fixtures/ совпадает с main).

## Проводка/риск
КЛАСС РИСКА :4 — «рисковый — безопасность» с основанием (граница пути/симлинк вне R) — соответствует предмету. ПРОВОДКА :114-116 — guard на батарею, ПРОВОДКА-ЭНФОРСМЕНТ называет исполнение CLI; `check_provodka.sh` rc 0. ЗОНА/ПЕРЕСЕЧЕНИЕ :43-108 — `check_precision_gate.sh` OK.

## НЕ проверено
- CI-раннер (версия jq на GitHub Actions) — не запускался.
- `gen_ci_steps.sh --write/--check` (:47) — шаг оркестратора после реализации, не исполнялся.
- Инкрементальный `check_zones --incr=<кэш>` — не прогонялся; прогнан только полный.
- Реализация — её нет на OBJECT; судились модель и мутанты.
- TOCTOU и нестандартные ФС — объявлены НЕ ЗАЩИЩАЕТ, не атаковались.

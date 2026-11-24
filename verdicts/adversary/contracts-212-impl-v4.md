accept
OBJECT=1c2844536407bc7da0411296a8dbe6932aa62312
СУД: репо=dev-harness; предмет=212; роль=adversary; вызов=4 (узкий повтор по слову владельца R-0065 п.3/SANKCIJA; сверх бюджета 1 полный + ≤1 scoped); фаза=реализация; модель-план=anthropic/claude-sonnet-5-5; модель-факт=anthropic/claude-sonnet-5-5 (метаданные среды выполнения); предыдущий=archive/212/adversary-v3-fail-2b13555868 (FAIL); класс риска=рисковый

## Область

Узкий повтор по слову владельца: только дельта ремонта Architect212e (клетка `r28-tmpdir-cwd-drugaja-fs`, стабы `st49`/`st50`, нормализация `Path.resolve()` в наблюдателе, абзацы SDACHA), регресс, повтор собственного блока Б-1 вызова 3 (К-08) и полнота по классу «откуда берётся родитель/ФС временного файла и как атомарна замена». Все мутации и миры — одноразовые: клон с собственным `.git` (`scripts/gitw clone --no-hardlinks --no-checkout` + `checkout --detach`), `TMPDIR=/tmp/dev-harness-verify/scratch-adv212d` (внутри разрешённой зоны, scratch удалён в конце), toy/bare-origin; настоящий origin и основной чекаут не затронуты. Нового sourceCanon нет. `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`.

Дельта считана по коммитам носителя: `git log --format='%h %an %s' cb136eb51..HEAD` (merge-base с актуальным main) — 7 коммитов: implementer `7953de24f`, architect `b575fd6e9`, orchestrator `69cf963ef`, architect `8132a7b33`, orchestrator `01291b107`, architect `4b4bec69b`, **architect `1c2844536`** (OBJECT; в задании назван `42862d7a8` — в этой копии тот же ремонт лежит коммитом `1c2844536`, `git show 1c2844536 --stat` идентичен: 6 файлов fixtures, +860/−45). Ремонт вызова 3 — ровно эти 6 файлов `fixtures/workshop_project/replace_posle_lenda_212/{SDACHA.md,mutants212.py,probe212.py,source.json,stabs/st49-mktemp-tmpdir/replace_line.sh,stabs/st50-mktemp-cwd-rel/replace_line.sh}`. `git diff cb136eb51 HEAD -- scripts/` — только новый файл `scripts/replace_line.sh` (Impl212, `git log -- scripts/replace_line.sh` — один коммит `7953de24f`, правок после него нет): production и контракт между OBJECT вызова 3 и OBJECT не менялись. `git diff --name-only cb136eb51 HEAD` ⊆ {fixtures/replace_posle_lenda_212, scripts/replace_line.sh, registry/ci-steps.tsv, registry/ci-zamery.tsv, .github/workflows/ci.yml} — зоны frozen/212/1. Необъявленной семантики в дельте нет (К-01 чисто).

## Блоки

Нет. Блок Б-1 Adv212c (К-08) закрыт: оба моих мутанта вызова 3 (`${TMPDIR:-/tmp}` и cwd-относительный `mktemp -p "$_REGISTRY_PATH"`) красятся `--repo` rc 1 ровно клеткой r28; честная production на r28 и на соседних входах зелёная; мутанты вызовов 1–2 и соседние того же класса красятся либо названы листом (см. «Остатки»). Доказанного нарушения обязательства контракта на достижимом состоянии production нет: production не читает ни одну переменную окружения и не использует cwd для выбора каталога временного файла — единственный `mktemp` (`scripts/replace_line.sh:342`) получает абсолютный путь `$ROOT/$_REGISTRY_PATH/…`, `$ROOT` — результат `cd … && pwd -P` (в т.ч. при относительном `--root`).

## Остатки

(не блоки; для отчёта оркестратору/ревьюеру)

- ОСТАТОК-1 (не назван в листе; живой, но только мутант, не production): родитель временного файла из переменных окружения, которые `mktemp` сам не читает и production не использует, — `HOME`, `TMP`, `TEMP`. Мутанты `mktemp -p "$HOME" …`, `mktemp "${TMP:-$ROOT/$_REGISTRY_PATH}/…"`, `mktemp "${TEMP:-…}/…"` зелёные (`--repo` rc 0, 34/0): r28 варьирует субъекту только `TMPDIR` и cwd; остальное окружение наследуется от процесса батареи, а на станции `HOME` лежит на той же ФС, что и миры. Те же мутанты красятся, когда ФС окружения процесса батареи иная (`HOME=/dev/shm`, `TMP=/dev/shm TEMP=/dev/shm` → rc 1, r27+r28) — то есть дефект ловится окружением вызывающего, не самой батареей. `XDG_RUNTIME_DIR` (на этой станции задан и лежит на tmpfs `/run/user/1004`) красится r27+r28 по наследованию. Класс — открытое множество имён переменных, которые автор кода должен прочитать явно (в отличие от `TMPDIR` и cwd, единственных двух каналов выбора родителя самим `mktemp`/ОС, закрытых r28); контракт :173 («конечная батарея не доказывает эквивалентность произвольной программы») и сам лист («r28 меняет только условия вызова: TMPDIR и cwd») прямо ограничивают предъявление. Ловец — adversary/reviewer реализации. Рекомендация — назвать в `НЕ ЗАЩИЩАЕТ` (Советы).
- ОСТАТОК-2 (назван листом как «честный эквивалент»): константный родитель на той же ФС, что и миры батареи: `mktemp -p /tmp`, `mktemp -p /var/tmp` — зелёные (rc 0, 34/0); на станции с `/tmp` и миры на одной ФС это не дефект; при мирах на другой ФС (`TMPDIR=/dev/shm` процесса батареи) оба красятся r27+r28 (rc 1). Константа на иной ФС (`/dev/shm`, `/run/user/<uid>`) красится всегда.
- ОСТАТОК-3 (назван листом): remint /3 при сверке `-le 2` и сверка tag-object по префиксу sha[0:8] — живые (rc 0); production безусловна по номеру версии (подтверждено вызовом 3: живой remint /3 rc 1). Ловец adversary/reviewer.
- ОСТАТОК-4 (назван листом): абсолютный `/bin/mv` ложно-красный (`mv реестра не наблюдался`, r27+r28, rc 1) — непроверяемый PATH-шимом вызов, не дефект production; `unlink перед rename` (`rm -f "$ROOT/$_REG_FILE"; mv …`) — живой, назван («unlink перед rename не доказаны этой пробой»).
- ОСТАТОК-5 (запас по времени двери листа): `python3 mutants212.py` теперь — 7 полных батарей `--repo` + 8 соседних/эквивалентных одиночных клеток; при нагрузке станции (load average 33–55, мои параллельные прогоны) этот один шаг занял 5 м 28 с (>300 с = умолчание `SDACHA_TIMEOUT_SEK`, бюджет одной команды листа). Первый прогон `check_sdacha --run` в этих условиях дал rc 1 «строка 27: таймаут 300 с команды: …/mutants212.py» (самому скрипту rc 0 при отдельном запуске); повтор одним процессом на менее нагруженной станции — rc 0, `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=1)`, 12 м 29 с из бюджета 900 с (запас ~17 %). Не дефект предмета (rc 0 воспроизводим при штатной нагрузке; CI-шаг `check:replace-posle-lenda-212-family-selftest` это не вызывает: `--repo . && --stabs && --sintaksis`), но дверь `check_sdacha --run` для 212 чувствительна к нагрузке — см. Советы.

## Регресс

Одна команда за раз, на OBJECT, `W=fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh`, `TMPDIR=/tmp/dev-harness-verify/scratch-adv212d`:

- `bash "$W" --repo .` — rc 0, `SUBJEKT 212: KLETKI 34 KRASNYH 0`.
- `bash "$W" --model` — rc 0, `MODEL 212: KLETKI 34 KRASNYH 0`.
- `bash "$W" --stabs` — rc 0, `STABY 212: SVJAZI 83 ZHIVYH 0`.
- `bash "$W" --sintaksis` — rc 0, `SINTAKSIS OK (bash -n: 52; пинованный shellcheck честных носителей: 3)`.
- `bash scripts/gen_ci_steps.sh --check` — rc 0.
- `bash scripts/pre_critic.sh contracts/212-replace-posle-lenda.md` — rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_sdacha.sh "$PWD" contracts/212-replace-posle-lenda.md --run` — первый прогон (при load average до 55 и моих параллельных батареях) rc 1 «таймаут 300 с команды: …/mutants212.py» (см. ОСТАТОК-5); повтор одним процессом: rc 0, `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=1)`, real 12 м 29 с. `python3 …/mutants212.py` отдельно — rc 0, real 5 м 28 с, все 7 production-мутантов rc 1 с точными множествами красных клеток (st44 r23+r26; st45 r24; st46 r25+r27+r28; st47 r26; st48 r27+r28; st49 r28; st50 r28), 8 соседей красные по названной причине, 10 честных эквивалентов `RED=[]`, `TMP-IN-/tmp SAME_FS=True RED=[]`.
- `bash fixtures/mint_line/red_mint_line_068.sh` — rc 0, `ИТОГ 068b (mint_line): ветвей 8, стабов 4, красных 0, зелёных 11, не прогнано 1` (`стМ1/стМ2: мёртв … next_id.sh: No such file`, `стМ3: не построен (sed-ручка не применилась)`, `стМ4: мёртв` — как в вызовах 1–3; rc 0 не доказывает прогон всех стабов 068 — без изменений, не предмет 212).
- shellcheck пин 0.11.0 `-S warning scripts/replace_line.sh` — rc 0, 0 находок; `bash -n scripts/replace_line.sh` — rc 0.
- Независимый счёт: `jq '{worlds:(.kejsy|length),stabs:(.stab_vhod|length),bindings:([.stab_vhod[]|length]|add),carriers:(.nositeli|length)}' source.json` → `{"worlds":28,"stabs":50,"bindings":83,"carriers":51}` (заявлено: миров 28, стабов 50, привязок 83; клеток 34 = 28 миров + 6 argv-клеток). `st49`/`st50` привязаны в `source.json:stab_vhod` ровно к `r28-tmpdir-cwd-drugaja-fs`; `diff scripts/replace_line.sh stabs/st49…/replace_line.sh` — одна строка 342 (`${TMPDIR:-/tmp}`), `…/st50…/replace_line.sh` — одна строка 342 (`mktemp -p "$_REGISTRY_PATH" …`).

## Мутации

Каждая — якорь кратности 1 в production `scripts/replace_line.sh` одноразового клона, затем `bash "$W" --repo <клон>` (cwd = клон, `TMPDIR` = scratch той же ФС, остальное окружение — станции), файл возвращается после каждого прогона. Контроль (честный текст): rc 0, 34/0. Драйвер — одноразовый скрипт в scratch (не в репозитории); сырой вывод — в конце.

Повтор моих мутантов вызова 3 и вызовов 1–2:

| мутация | rc | красные клетки | оценка |
|---|---|---|---|
| Б-1 в3: `mktemp "${TMPDIR:-/tmp}/…"` | 1 | r28 | закрыт |
| Б-1 в3: `mktemp -p "$_REGISTRY_PATH" …` (cwd-относительный) | 1 | r28 | закрыт |
| в1-Б-1: peeled-коммиты вместо tag-object (`n-peeled`) | 1 | r01,r03,r04,r05,r08,r10,r12,r15–r22,r24,r25,r27,r28 (19) | закрыт |
| в1-Б-2: убрать откат после отказа хука | 1 | r24 | закрыт |
| в1-Б-3: `cat > …; rm` (`mutants212.py st46`) | 1 | r25,r27,r28 | закрыт |
| в2-Б-1: сверка tag-object только при vmax=1 | 1 | r26 | закрыт |
| в2-Б-2: `mktemp -p /dev/shm` (`st48`) | 1 | r27,r28 | закрыт |

Полнота по каналу выбора родителя/ФС временного файла (все места production: единственный `mktemp`, `scripts/replace_line.sh:342`; цель `mv` — `:353`; `$ROOT`, `$_REGISTRY_PATH`, `$_REG_FILE` — `:150–163,195–203`):

| вход/форма | мутант | rc | красные клетки | оценка |
|---|---|---|---|---|
| `TMPDIR` с запасным registry | `mktemp -p "${TMPDIR:-$ROOT/$_REGISTRY_PATH}"` | 1 | r28 | поймано |
| `mktemp -t` | `mktemp -t .replace-line-…` | 1 | r28 | поймано |
| `mktemp` без шаблона | `mktemp` | 1 | r28 | поймано |
| cwd | `mktemp .replace-line-…` / `-p .` / `-p "$PWD"` / `-p ..` / `"registry/…"` | 1 | r28 (все пять) | поймано |
| `mktemp -u` с `TMPDIR` | `mktemp -u "${TMPDIR:-/tmp}/…"` | 1 | r28 | поймано |
| `mktemp -u` в registry (честный) | `mktemp -u "$ROOT/$_REGISTRY_PATH/…"` | 0 | — | честный эквивалент, зелёный верно |
| `$(mktemp -d)` + файл внутри (TMPDIR) | `d=$(mktemp -d); …/f` | 1 | r28 | поймано |
| `mktemp -d` в registry + файл внутри (честный) | `mktemp -d "$ROOT/$_REGISTRY_PATH/.d.XXXXXX"` | 0 | — | честный эквивалент |
| родитель корня репозитория | `mktemp "$ROOT/../.replace-line-…"` | 0 | — | та же ФС, эквивалент |
| `XDG_RUNTIME_DIR` (tmpfs станции) | `mktemp "${XDG_RUNTIME_DIR:-…}/…"` | 1 | r27,r28 | поймано (по наследованию окружения) |
| константа `/run/user/<uid>` (другая ФС) | `mktemp -p "/run/user/$(id -u)"` | 1 | r27,r28 | поймано |
| **`HOME`** | `mktemp -p "$HOME" …` | **0** | — | живой (ОСТАТОК-1); при `HOME=/dev/shm` процесса батареи — rc 1 r27,r28 |
| **`TMP`/`TEMP`** | `mktemp "${TMP:-…}/…"`, `"${TEMP:-…}/…"` | **0** | — | живой (ОСТАТОК-1); при `TMP=/dev/shm TEMP=/dev/shm` — rc 1 r27,r28 |
| константа `/tmp`, `/var/tmp` | `mktemp -p /tmp …`, `-p /var/tmp …` | 0 | — | назван листом (ОСТАТОК-2); при `TMPDIR=/dev/shm` батареи — rc 1 r27,r28 |

Как делается замена (цель `mv`): `install -T …; rm` — rc 1 (r27,r28: `mv реестра не наблюдался`); `cp --reflink=auto …; rm` — rc 1 (r25,r27,r28); `ln -f "$TMP" …; rm` — rc 1 (r27,r28); `python3 os.rename` — rc 1 (r27,r28, мимо PATH-шима → «не наблюдался»); `mv -n` — rc 1 (r01,r15–r18,r24,r25,r27,r28 — не заменяет файл); `rm -f "$ROOT/$_REG_FILE"; mv …` — rc 0 (назван: «unlink перед rename», ОСТАТОК-4); `/bin/mv` по абсолютному пути — rc 1 (честный вариант ложно-красный, назван, ОСТАТОК-4); `command mv` — rc 0 (честный, идёт через PATH); `( cd "$ROOT/$_REGISTRY_PATH" && mv "$TMP" contracts.tsv )` — rc 0 (честный эквивалент); `mv "$TMP" "$ROOT/registry/../registry/contracts.tsv"` — rc 0 (честный; совет вызова 3 про `resolve()` исполнен — ложная краснота ушла).

Соседние мутанты по сверке/откату: remint /3 (`-le 2`) — rc 0 (назван); сверка по префиксу `sha[0:8]` — rc 0 (назван); сверка только `vmax=1` — rc 1 (r26); откат ПОСЛЕ успешного commit (`reset --hard HEAD~1`) — rc 1 (r01,r15–r18,r25,r27,r28); без rollback — rc 1 (r24); перетег того же commit иной аннотацией (`n-peeled`) — rc 1 (r23/r26 и др.).

Честная production на входах вне батареи (мир — настоящий `probe212.Mir`, наблюдатель `mv` — `nabludenie_mv`, субъект — `scripts/replace_line.sh`): (а) абсолютный `--root`, cwd и `TMPDIR` на другой ФС (dev 27 vs реестр 2306): rc 0, `REPLACED …`, `mv_records=[[2306, 2306]]`; (б) `--root` ОТНОСИТЕЛЬНЫЙ (`os.path.relpath`) из чужого cwd: rc 0, `mv_records=[[2306, 2306]]`; (в) то же при `HOME=/dev/shm TMP=/dev/shm TEMP=/dev/shm XDG_RUNTIME_DIR=/dev/shm`: rc 0, `mv_records=[[2306, 2306]]`. Production не даёт не-rename ни на одном из исследованных входов окружения/cwd/`--root`; симлинк `registry/contracts.tsv`/`registry` отказывается грамматикой манифеста (blob симлинка — путь, не `NNN → 40-hex`) либо чистотой дерева (проверено в вызове 1).

## Карта классов

- К-01: чисто — дельта = 6 файлов fixtures; production, контракт, роли, реестры (кроме CI-строк вызова 2) не менялись.
- К-02..К-06, К-09..К-13, К-16, К-17: не затронуты дельтой; без изменений относительно вызова 3.
- К-07: честная production на r28 и входах (а)–(в) — зелёная/rc 0 с rename на той же ФС.
- К-08: Б-1 вызова 3 закрыт; ОСТАТОК-1 — открытое множество имён env, не блок (см. выше).
- К-14: честные эквиваленты (`mv -f/-T`, `registry/../registry`, `cd registry && mv`, `command mv`, TMP в корне toy/registry, `mktemp -u`/`-d` в registry) зелёные.
- К-15: `--repo` 34/0, `--model` 34/0, `--stabs` 83/0, `--sintaksis` 52/3, rc 0; независимый jq 28/50/83/51.

## НЕ ЗАЩИЩАЕТ

Строки `ОСТАТОК: К-NN` с ловцом adversary в контракте/листе отсутствуют. Остатки листа проверены на «укусил/не укусил»:

- «сверка только при vmax≤2 и по префиксу sha[0:8] не стали новыми клетками» (ловец adversary/reviewer): укусил в смысле «живой», как и заявлено; production безусловна — не блок.
- «r27/r28 … не доказывают абсолютный вызов mv вне PATH (включая честный /bin/mv), mv -t, прямые syscalls, unlink перед rename» (ловец adversary/reviewer): `/bin/mv` — ложно-красный; `unlink перед rename` — живой, назван; `mv -t` не строился (нет честной формы без отказа на одном каталоге) — не укусил.
- НЕ названо листом: родитель временного файла из `HOME`/`TMP`/`TEMP` (ОСТАТОК-1) — остаток, не блок.

## Советы

- Назвать в `НЕ ЗАЩИЩАЕТ` листа: «r28 варьирует субъекту только TMPDIR и cwd; иные переменные окружения (`HOME`, `TMP`, `TEMP`) как родитель временного файла красятся лишь при другой ФС окружения процесса батареи». Либо дёшево закрыть: в r28 (`env`) и клетке по cwd передать `HOME`, `TMP`, `TEMP` на ту же чужую ФС (три присваивания рядом с `env['TMPDIR']`; production на них рабочая — вход (в) выше).
- Дверь `check_sdacha --run` для 212 близка к потолку: 7 полных батарей в `mutants212.py` (≈ 5,5 мин при нагрузке 33) против `SDACHA_TIMEOUT_SEK=300`. Либо уменьшить число полных батарей (`st45`, `st47`, `st49`, `st50` красятся по одной клетке — можно прогонять скоупно через `prognot_kletku`), либо оговорить в листе, что прогон — на нераспараллеленной станции. Не блок: на штатной нагрузке rc 0.
- st49/st50 — полные копии production с изменением строки 342 (по `sgeneriruj()`); при будущей правке production их надо перегенерировать (`--sgeneriruj-staby`), иначе стабы останутся копиями старого текста; production в числе носителей `source.json` не значится (носителей 51: model + 50 стабов). Мелкое, не блок.
- Отсутствующее значение после `--nnn`/`--root` (`${2:?}`) даёт shell-диагностику, не usage (назван листом).
- Гонка временных каталогов `lib_zones.*` и общего `TMPDIR` при параллельных батареях разных судей — изоляция каталога на запуск, совет оркестратору.
- 068: `ИТОГ … не прогнано 1`, мёртвые стабы стМ1–стМ4 при rc 0 — замечание прежних вызовов, не предмет 212.

## Сырой вывод ключевых прогонов

```
bash $W --repo .          → SUBJEKT 212: KLETKI 34 KRASNYH 0   rc 0
bash $W --model           → MODEL 212: KLETKI 34 KRASNYH 0     rc 0
bash $W --stabs           → STABY 212: SVJAZI 83 ZHIVYH 0      rc 0
bash $W --sintaksis       → SINTAKSIS OK (bash -n: 52; пинованный shellcheck честных носителей: 3)  rc 0
gen_ci_steps --check rc 0; pre_critic rc 0 «КРИТИК: дверь зелёная»; shellcheck -S warning rc 0; bash -n rc 0
check_sdacha --run (1-й, нагрузка до 55, параллельные прогоны)  → «ОТКАЗ: строка 27: таймаут 300 с команды: …/mutants212.py» rc 1
check_sdacha --run (повтор)  → СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=1)  rc 0, real 12m29s
mutants212.py (отдельно)  → rc 0, real 5m28s; st44..st50 rc 1; neighbours красные; equivalents RED=[]

MUTANT control-honest         rc=0 red=                                   KLETKI 34 KRASNYH 0
MUTANT v3-tmpdir-env          rc=1 red=r28                                KLETKI 34 KRASNYH 1
MUTANT v3-p-relative          rc=1 red=r28                                KLETKI 34 KRASNYH 1
MUTANT c-tmpdir-or-reg        rc=1 red=r28
MUTANT c-mktemp-t             rc=1 red=r28
MUTANT c-mktemp-bare          rc=1 red=r28
MUTANT c-cwd-bare             rc=1 red=r28
MUTANT c-p-dot                rc=1 red=r28
MUTANT c-p-pwd                rc=1 red=r28
MUTANT c-p-dotdot             rc=1 red=r28
MUTANT c-p-relroot            rc=1 red=r28
MUTANT c-home                 rc=0 red=                                   KLETKI 34 KRASNYH 0   <-- ОСТАТОК-1
MUTANT c-env-TMP              rc=0 red=                                   KLETKI 34 KRASNYH 0   <-- ОСТАТОК-1
MUTANT c-env-TEMP             rc=0 red=                                   KLETKI 34 KRASNYH 0   <-- ОСТАТОК-1
MUTANT c-env-XDG              rc=1 red=r27,r28
MUTANT c-hard-tmp             rc=0 red=                                   (назван, ОСТАТОК-2)
MUTANT c-hard-vartmp          rc=0 red=                                   (назван, ОСТАТОК-2)
MUTANT c-hard-run-user        rc=1 red=r27,r28
MUTANT c-u-tmpdir             rc=1 red=r28
MUTANT c-u-honest             rc=0 red=
MUTANT c-d-tmpdir-mv-in       rc=1 red=r28
MUTANT c-d-registry-mv-in     rc=0 red=
MUTANT c-root-parent          rc=0 red=
MUTANT m-install-T            rc=1 red=r27,r28
MUTANT m-cp-reflink           rc=1 red=r25,r27,r28
MUTANT m-ln-f                 rc=1 red=r27,r28
MUTANT m-python-rename        rc=1 red=r27,r28
MUTANT m-rm-then-mv           rc=0 red=                                   (назван)
MUTANT m-mv-n                 rc=1 red=r01,r15,r16,r17,r18,r24,r25,r27,r28
MUTANT m-abs-binmv            rc=1 red=r27,r28                            (назван)
MUTANT m-command-mv           rc=0 red=
MUTANT m-cd-mv                rc=0 red=
MUTANT m-mv-dotdot            rc=0 red=
MUTANT n-sverka-le2           rc=0 red=                                   (назван)
MUTANT n-sverka-v1only        rc=1 red=r26
MUTANT n-sverka-prefix8       rc=0 red=                                   (назван)
MUTANT n-peeled               rc=1 red=r01,r03,r04,r05,r08,r10,r12,r15-r22,r24,r25,r27,r28 (19)
MUTANT n-rollback-after-ok    rc=1 red=r01,r15,r16,r17,r18,r25,r27,r28
MUTANT n-no-rollback          rc=1 red=r24

С окружением процесса батареи на иной ФС (контроль «ловится окружением, не батареей»):
HOME=/dev/shm                 c-home        rc=1 red=r27,r28
TMP=/dev/shm TEMP=/dev/shm    c-env-TMP/TEMP rc=1 red=r27,r28 (оба)
TMPDIR=/dev/shm (миры на tmpfs) c-hard-tmp, c-hard-vartmp rc=1 red=r27,r28 (оба)

Честная production (probe212.Mir + nabludenie_mv, cwd/TMPDIR на ФС dev 27, реестр dev 2306):
honest-abs-root                        rc=0 mv_records=[[2306, 2306]]
honest-REL-root-foreign-cwd            rc=0 mv_records=[[2306, 2306]]
honest-REL-root-HOME-TMP-TEMP-XDG-foreign rc=0 mv_records=[[2306, 2306]]
```

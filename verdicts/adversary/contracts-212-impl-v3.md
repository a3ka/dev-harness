FAIL
OBJECT=d1c576188c2f54b9a19d680af3372d6f546d43fc
СУД: репо=dev-harness; предмет=212; роль=adversary; вызов=3 (узкий повтор по слову владельца/SANKCIJA; бюджет сверх 1 полный + ≤1 scoped по санкции); фаза=реализация; модель-план=anthropic/claude-sonnet-5-5; модель-факт=anthropic/claude-sonnet-5-5 (метаданные среды выполнения); предыдущий=archive/212/adversary-v2-fail-d3e7adfd1d (FAIL); класс риска=рисковый

## Область

Узкий повтор: закрытие блоков Б-1 (remint /2) и Б-2 (кросс-ФС mv) вызова 2, регресс, соседние мутанты того же класса, необъявленная семантика в дельте носителя. Все мутации и миры — одноразовые: клон с собственным `.git` (`scripts/gitw clone --no-hardlinks`, `$TMPDIR=/tmp/dev-harness-verify/scratch-adv212c`), toy/bare-origin; настоящий origin и основной чекаут не затронуты. `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`. Нового sourceCanon нет.

Дельта носителя считана по коммитам носителя, не по `origin/main..HEAD`: `git log --format='%h %an %s' 1ec472715..HEAD` — 6 коммитов (implementer `9a545d398`; architect `e742e2229`, `89776d1f8`, `d1c576188`; orchestrator `427542033`, `2a2324859`). `git diff 1ec472715 HEAD --name-only -- scripts/` → только `scripts/replace_line.sh` (новый файл); `git diff 2574fec93 HEAD --stat -- scripts/ roles/ .omp/ docs/ contracts/ registry/` пуст — production, контракт, роли и реестры между OBJECT вызова 2 и OBJECT не менялись; дрейф main (992/143/217/…) в дельту не входит и блока не создаёт. Содержимое ремонта Architect212d (`d1c576188`) — `probe212.py` (+клетки r26/r27, `nabludenie_mv`, STAB_MUTACII st47/st48), `mutants212.py`, `source.json`, `SDACHA.md`, два новых стаба; прочие клетки/ожидания/сравнение байт не ослаблены (diff `2574fec93..HEAD -- probe212.py` прочитан целиком: меняются только `vyzvat(env=)`, список ZELENYE, r26/r27, mv-наблюдатель, две мутации и привязки). Необъявленной семантики в дельте нет (К-01 — чисто).

## Регресс

Одна команда за раз, на OBJECT, `W=fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh`:

- `bash "$W" --repo .` — rc 0, `SUBJEKT 212: KLETKI 33 KRASNYH 0`.
- `bash "$W" --model` — rc 0, `MODEL 212: KLETKI 33 KRASNYH 0`.
- `bash "$W" --stabs` — rc 0, `STABY 212: SVJAZI 81 ZHIVYH 0`.
- `bash "$W" --sintaksis` — rc 0, `SINTAKSIS OK (bash -n: 50; пинованный shellcheck честных носителей: 3)`.
- `bash scripts/gen_ci_steps.sh --check` — rc 0.
- `bash scripts/pre_critic.sh contracts/212-replace-posle-lenda.md` — rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_sdacha.sh "$PWD" contracts/212-replace-posle-lenda.md --run` — rc 0, `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=1)` (включает `mutants212.py`, rc 0).
- `bash fixtures/mint_line/red_mint_line_068.sh` — rc 0, `ИТОГ 068b (mint_line): ветвей 8, стабов 4, красных 0, зелёных 11, не прогнано 1` (`стМ3: не построен (sed-ручка не применилась)` — как в вызовах 1–2, фиксирую без изменений).
- shellcheck пин 0.11.0 `-S warning scripts/replace_line.sh` — rc 0, 0 находок; `bash -n scripts/replace_line.sh` — rc 0.

CI-шаг `registry/ci-steps.tsv` (`check:replace-posle-lenda-212-family-selftest`): цепочка `--repo . && --stabs && (пин shellcheck) --sintaksis` прочитана; пин-шаг не ослаблен (sha256 бинаря сверялся в вызове 2; в дельте `2a2324859` — одна строка, как проверено там); `ci.yml` — сгенерированная пересборка полос, `gen_ci_steps --check` rc 0.

## Мутации

Каждая — один якорь кратности 1 в production `scripts/replace_line.sh` одноразового клона, затем `bash "$W" --repo <клон>` (cwd = клон, TMPDIR = scratch той же ФС); файл возвращается из `git show HEAD:` после каждого прогона. Контроль (честный текст) — rc 0, 33/0.

Закрытие блоков вызовов 1–2 (повтор собственных мутантов):

| мутация | rc | красные клетки |
|---|---|---|
| v2-Б-1: сверка tag-object только при `vmax = 1` | 1 | r26 (KRASNYH 1) |
| v2-Б-2: `mktemp -p /dev/shm` вместо registry | 1 | r27 (KRASNYH 1; st_dev /dev/shm=27 ≠ 2306) |
| v1-Б-1: peeled-коммиты вместо tag-object | 1 | r23, r26 (KRASNYH 2) |
| v1-Б-2: убрать откат после отказа хука | 1 | r24 (KRASNYH 1) |
| v1-Б-3: `mv` → `cat > …; rm -f "$TMP"` | 1 | r25, r27 (KRASNYH 2) |

Все пять красятся новыми/сохранёнными клетками; Б-1 и Б-2 вызова 2 закрыты КАК ЗАЯВЛЕНО. `python3 mutants212.py` — rc 0 (в составе check_sdacha).

Соседние мутанты того же класса:

| мутация | rc | красные клетки | оценка |
|---|---|---|---|
| сверка только при `vmax -le 2` (remint /3 после /2) | 0 | — | живой; назван в НЕ ЗАЩИЩАЕТ листа («не каждый будущий номер версии»), ловец adversary/reviewer |
| сверка по префиксу sha[0:8] | 0 | — | живой; назван в НЕ ЗАЩИЩАЕТ листа («префикс-коллизии tag-object») |
| откат после успешного commit: `git reset --hard HEAD~1` | 1 | r01, r15, r16, r17, r18, r25 и др. | поймано |
| `git checkout HEAD -- файл` после успешного commit (эквивалент) | 0 | — | честный эквивалент, зелёный верно |
| `mv` через `( cd registry && mv "$TMP" contracts.tsv )` (честный) | 0 | — | честный эквивалент, зелёный верно |
| `mv "$TMP" "$ROOT/registry/../registry/contracts.tsv"` (честный) | 1 | r27: «mv реестра не наблюдался» | ложно-красный честный вариант (наблюдатель сравнивает `Path.absolute()` без нормализации `..`); см. Советы |
| `/bin/mv` по абсолютному пути (честный) | 1 | r27: «mv реестра не наблюдался» | ложно-красный; назван в НЕ ЗАЩИЩАЕТ листа как непроверяемый вызов вне PATH; см. Советы |
| TMP в корне репозитория `mktemp "$ROOT/.replace-line…"` / `registry/../` | 0 | — | честный эквивалент (та же ФС), зелёный верно; назван листом |
| убрать `grep -v '\^{}'` из разбора ls-remote | 0 | — | эквивалент (`head -1` берёт tag-object раньше peeled) |
| **TMP в `${TMPDIR:-/tmp}`: `mktemp "${TMPDIR:-/tmp}/.replace-line-$NNN.XXXXXX"`** | **0** | **— (33/0)** | **живой; НЕ назван → Б-1** |
| **TMP по cwd: `mktemp -p "$_REGISTRY_PATH" …` (относительно cwd, не `--root`)** | **0** | **— (33/0)** | **живой, тот же класс; НЕ назван → Б-1** |

Честная production на соседних входах (мир одноразовый, `probe.Mir`): remint `/3` при vmax=3 на тот же commit — rc 1 `ОТКАЗ: переминт заморозки: sha локального frozen/contracts/992/3 (…) ≠ sha тега на origin (…)`, HEAD и status не изменены (проверка безусловна по номеру версии); догон `/3` после REPLACE на `/2` — rc 0, один коммит, identity orchestrator; локальный vmax=2 при /3 на origin и без локального тега /3 — rc 1 (дверь 031: «реестр заморозок недоступен», откат точечный, HEAD/status без изменений) — fail-closed, не нарушение.

## Блоки

**БЛОКИРУЕТ Б-1 — проверка атомарного cutover не различает кросс-ФС mv, вызванный окружением/cwd (родственник Б-2 вызова 2), К-08.**
ПРОИСХОЖДЕНИЕ: узкое-закрытие (тот же класс, что Б-2 вызова 2; закрытие названо `st48`/r27 и охватывает только константный `-p /dev/shm`).
ОБЯЗАТЕЛЬСТВО: `contracts/212-replace-posle-lenda.md:36` (инвариант 6) — «запись во временный файл и mv»; заявлено листом `SDACHA.md` (абзац «Шим r27…»): r27 доказывает, что наблюдаемый `mv` — rename на той же ФС, а не EXDEV-копирование. Станционная норма места временного файла — `scripts/handoff_rotate.sh:124-126,233-235` (091, находка ревьюера Ф-2: временные файлы создаются в целевом каталоге, «`$TMPDIR` на другой ФС /dev/shm tmpfs — rename(2) падает Errno 18», живой контроль P3 cross-device `/dev/shm`).
ИСТОЧНИК ВХОДА: состояние «`TMPDIR` указывает на другую ФС, чем репозиторий» — штатное окружение вызова скрипта (`TMPDIR` читают `mktemp` и все инструменты станции; станция уже судила именно этот вход в 091 и держит против него контроль). Второй вход — вызов из cwd, лежащего на другой ФС (`--root` — отдельный путь).
ИСТОЧНИК ОШИБОЧНОГО МЕХАНИЗМА: замена одной существующей операции production — `scripts/replace_line.sh:342` `mktemp "$ROOT/$_REGISTRY_PATH/.replace-line-$NNN.XXXXXX"` → `mktemp "${TMPDIR:-/tmp}/.replace-line-$NNN.XXXXXX"` (либо `mktemp -p "$_REGISTRY_PATH" …` по cwd); остальной текст не менялся.
НАБЛЮДЕНИЕ: (1) `bash "$W" --repo <клон с мутантом>` → rc 0, `SUBJEKT 212: KLETKI 33 KRASNYH 0` для обоих (мутанты `n7-mktemp-env-tmpdir`, `n8-mktemp-p-relative`): `vyzvat` в r27 передаёт субъекту `TMPDIR` самого процесса батареи, а миры лежат под тем же `TMPDIR` — родитель TMP при любом значении `TMPDIR` оказывается на ФС мира, ни одна клетка не задаёт субъекту другую ФС. (2) Та же клетка r27 построена настоящим `probe212.Mir` и `nabludenie_mv` (то же наблюдение батареи), но субъект запущен с `TMPDIR=/dev/shm` (cwd `/dev/shm/…` для n8): честная production — `mv_records=[[2306, 2306]]`, rc 0; мутант `${TMPDIR:-/tmp}` — rc 0, `mv_records=[[27, 2306]]`, st_dev источника ≠ st_dev каталога реестра, mv копирует и удаляет вместо rename; мутант `mktemp` без шаблона — то же `[[27, 2306]]`; мутант по cwd — то же `[[27, 2306]]`. Успех rc 0 с межфайловой неатомарной подменой реестра; батарея этого различить не может — вердикт зелёный.
КЛАСС ПРИЧИНЫ: наблюдатель r27 исправен, но вход «ФС родителя TMP ≠ ФС реестра» достижим для субъекта только константой в тексте, а не окружением/cwd; предъявление не варьирует единственные два канала, которыми production-текст выбирает родителя.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО (не предписывает реализацию): в r27 (или одной новой зелёной клетке) субъекту передаётся `TMPDIR` на ФС, отличную от ФС toy-реестра (например `/dev/shm`, если `st_dev` отличается; если подходящей отличной ФС нет — именованный rc 2 `ORACLE_TAMPERED`, не зелёный пропуск) и cwd на отличной ФС; ожидание — rc 0 и `st_dev` источника наблюдаемого mv == `st_dev` каталога реестра; мутанты `${TMPDIR:-/tmp}`, `mktemp` без шаблона и cwd-относительный должны краситься r27, честная production (TMP в registry, в корне репозитория, любая та же ФС) остаётся зелёной; пара мутантов привязывается к r27 в `source.json:.stab_vhod`. Либо: отнести этот остаток в `НЕ ЗАЩИЩАЕТ` листа с ловцом и обоснованием, что станция не вызывает инструмент с `TMPDIR` на другой ФС (решение автора листа/владельца, не совет судьи).

Остальные блоки вызова 2 закрыты: Б-1 (remint /2) — красится r26 (st47 и сверка только `vmax=1` дают rc 1, KRASNYH 1); Б-2 (константный кросс-ФС mktemp) — красится r27; Б-3 вызова 2 был ложным (дрейф main) — в дельте носителя необъявленной семантики нет.

## Карта классов

- К-01: чисто — дельта носителя по 6 коммитам, production между OBJECT вызова 2 и OBJECT не менялась.
- К-02..К-06, К-09..К-13, К-16, К-17: без изменений относительно вызова 2 (не затронуты дельтой).
- К-07: честная production на r26/r27 и на соседних входах (remint /3, догон /3) — зелёная/именованный отказ по контракту.
- К-08: блок — Б-1 (родственник Б-2 вызова 2); прежние Б-1/Б-2 вызова 2 закрыты.
- К-14: честные эквиваленты (`mv -f/-T`, обратные операнды, `checkout HEAD` после commit, TMP в корне/registry, `cd registry && mv`) — зелёные; ложно-красные честные варианты — в Советах.
- К-15: `--model` 33/0, `--stabs` 81/0, `--sintaksis` 50/3, `--repo .` 33/0, rc 0.

## НЕ ЗАЩИЩАЕТ

Строки `ОСТАТОК: К-NN` с ловцом adversary в контракте/листе отсутствуют; остатки листа проверены на предмет «укусил/не укусил»:

- «r23/r26 … не доказывают поведение для каждого будущего номера версии или префикс-коллизии tag-object» — ловец adversary/reviewer. ОСТАТОК: remint /3 по сверке `-le 2` — живой, назван, не блок (production безусловна, подтверждено живым remint /3 rc 1); префикс[0:8] — живой, назван, не блок.
- «r27 … не доказывает абсолютный вызов mv вне PATH, `mv -t`, прямые syscalls» — ловец adversary/reviewer. ОСТАТОК: `/bin/mv` по абсолютному пути краснится как «не наблюдался» (честный вариант — ложно-красный, не обход).
- НЕ названо листом и не красится: родитель TMP, выбираемый окружением (`TMPDIR`) или cwd — Б-1 выше.

## Советы

- Наблюдатель r27 сравнивает `Path(args[-1]).absolute() == registry` без нормализации: честный `mv "$TMP" "$ROOT/registry/../registry/contracts.tsv"` и честный `/bin/mv` красятся ложно («mv реестра не наблюдался»). Нормализовать через `os.path.normpath`/`resolve` аргумента, если нужен более широкий класс честных реализаций.
- Отсутствующее значение после `--nnn`/`--root` (`${2:?}`) даёт shell-диагностику, не usage (названо листом, не блок).
- Гонка временных каталогов `lib_zones.*` в `/dev/shm` и общем TMPDIR при параллельных батареях различных судей; изоляция каталога на запуск — совет оркестратору.
- 068: `ИТОГ … не прогнано 1`, `стМ3: не построен (sed-ручка не применилась)` при rc 0 — rc 0 не доказывает прогон всех стабов 068 (замечание вызова 1–2, без изменений).
- Мутант вызова 2 «`mv -T`» и «обратные операнды» остаются честными эквивалентами; повторять не нужно.

## Сырой вывод ключевых прогонов

```
bash $W --repo .          → SUBJEKT 212: KLETKI 33 KRASNYH 0   rc 0
bash $W --model           → MODEL 212: KLETKI 33 KRASNYH 0     rc 0
bash $W --stabs           → STABY 212: SVJAZI 81 ZHIVYH 0      rc 0
bash $W --sintaksis       → SINTAKSIS OK (bash -n: 50; пинованный shellcheck честных носителей: 3)  rc 0
check_sdacha --run        → СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=1)  rc 0

MUTANT control-honest             rc=0 KLETKI 33 KRASNYH 0
MUTANT v2b1-sverka-only-v1        rc=1 red=r26                KLETKI 33 KRASNYH 1
MUTANT v2b2-mktemp-dev-shm        rc=1 red=r27                KLETKI 33 KRASNYH 1
MUTANT v1-peeled                  rc=1 red=r23,r26            KLETKI 33 KRASNYH 2
MUTANT v1-no-rollback             rc=1 red=r24                KLETKI 33 KRASNYH 1
MUTANT v1-cat-rm                  rc=1 red=r25,r27            KLETKI 33 KRASNYH 2
MUTANT n1-sverka-vmax-le2         rc=0 KLETKI 33 KRASNYH 0
MUTANT n2-sverka-prefix8          rc=0 KLETKI 33 KRASNYH 0
MUTANT n3-mv-cd-relative          rc=0 KLETKI 33 KRASNYH 0
MUTANT n4-mv-dotdot-path          rc=1 red=r27 (пост: mv реестра не наблюдался)
MUTANT n5-mv-abs-binmv            rc=1 red=r27 (пост: mv реестра не наблюдался)
MUTANT n6-tmp-in-repo-root        rc=0 KLETKI 33 KRASNYH 0
MUTANT n7-mktemp-env-tmpdir       rc=0 KLETKI 33 KRASNYH 0     <-- Б-1
MUTANT n8-mktemp-p-relative       rc=0 KLETKI 33 KRASNYH 0     <-- Б-1
MUTANT n9-rollback-after-success-hard rc=1 red=r01,r15,r16,r17,r18,r25,...
MUTANT n10-checkout-after-success-noop rc=0 KLETKI 33 KRASNYH 0
MUTANT n11-lsremote-peeled-kept   rc=0 KLETKI 33 KRASNYH 0
MUTANT n12-mktemp-subdir-registry rc=0 KLETKI 33 KRASNYH 0

nabludenie_mv на r27-мире, субъект с TMPDIR=/dev/shm (cwd /dev/shm/adv212c-cwd для n8):
SUBJECT=honest                    rc=0 mv_records(src_dev,reg_dev)=[[2306, 2306]] same_fs=[True]
SUBJECT=n7-mktemp-env-tmpdir      rc=0 mv_records(src_dev,reg_dev)=[[27, 2306]]   same_fs=[False]
SUBJECT=n7b-mktemp-default        rc=0 mv_records(src_dev,reg_dev)=[[27, 2306]]   same_fs=[False]
SUBJECT=n8-mktemp-p-relative-cwd  rc=0 mv_records(src_dev,reg_dev)=[[27, 2306]]   same_fs=[False]
```

accept
OBJECT=d15d162d09ac921f4439054c4b24fbcb208cb833
СУД: repo=dev-harness; предмет=153; фаза=реализация; роль=adversary; вызов=1/1; сессия=Adv153; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; SHA=d15d162d09ac921f4439054c4b24fbcb208cb833; исключение=нет.

Итог: БЛОКИРУЕТ — 0. Реальная граница путей не обойдена. Удаление ложного bash-pattern `*\0*` допустило только корректные пути с цифрой `0`; проверка настоящего JSON NUL остаётся в `profile_resolver.sh:scan_canon` до `jq -r`/`mapfile`.

## Предмет и область

- `git cat-file -t d15d162d09ac921f4439054c4b24fbcb208cb833` → `commit`, rc=0.
- Изолированный клон `/tmp/dev-harness-verify/Adv153/repo`: `git clone`, `fetch /home/harness/dev-harness wip/153/implementer`, `checkout -q d15d162…`; основной checkout не использовался как GIT_DIR/GIT_WORK_TREE, push и сборки/эмуляторы не запускались.
- `git diff --check d15d162…^ d15d162… && git diff --numstat … && git diff --name-only …` → `0\t1\tscripts/check_project_sources.sh` и только `scripts/check_project_sources.sh`, rc=0. `git log main..OBJECT` содержит ровно коммит implementer `153: убран ложный отказ *\0*`.
- В `scripts/check_project_sources.sh:108-111` остались только `/*)` и `*..*)`; `grep` всех `case "$p" in` в `scripts/` показывает единственный source-path case там. Литерал `*\0*` в source gate отсутствует. `pre_critic.sh:165-173` и `done_contract.sh:177-185` только делегируют этому CLI; `check_provodka.sh` sourceCanon не потребляет. Другого отказа пути с цифрой `0` не найдено.

## Позитивный контроль и штатная батарея

```text
$ bash fixtures/workshop_project/nul_istochnika_153/probe.sh
DOMAIN strok=37448 putej=26502 otkaz-grammatika=6530 ne-regular=4416
GREEN backend … zero-tail; GREEN nul … fifo; GREEN sweep: GREEN paths=26502 batches=9
CELLS=15 GREEN=15
rc=0

$ bash fixtures/workshop_project/nul_istochnika_153/probe.sh --stabs
CAUGHT false-zero backend
CAUGHT reject-edge-zero|reject-whole-zero|reject-middle-zero|reject-double-edge-zero|reject-triple-zero|reject-quoted-backslash-zero sweep
CAUGHT accept-all|skip-nul-json nul; CAUGHT skip-absolute absolute; CAUGHT skip-dotdot dotdot
CAUGHT skip-canonical outside; CAUGHT accept-directory directory; CAUGHT accept-fifo fifo
SVJAZI=14 CAUGHT=14 LIVE=0
rc=0

$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=111 mutants=0 mismatches=0
rc=0
```

`W --model` — отдельный честный позитивный контроль: он копирует реальные gate+resolver и удаляет ровно бывшую строку `*\0*`; все 15 клеток (включая sweep 26 502 путей) проходят. Фактическая реализация дала тот же зелёный результат при `W`.

## Собственные исполнения обманных заглушек

Скрипт в одноразовой рабочей области добавил к `--stabs` и прогнал реальные публичные вызовы на копиях gate/resolver. Результат:

```text
manual-edge-zero          0*|*0)       → CAUGHT sweep
manual-middle-zero        */0/*         → CAUGHT sweep
manual-double-zero        *00*)         → CAUGHT sweep
manual-class-zero         [0])          → CAUGHT sweep
manual-no-file-check      удалить -f    → CAUGHT directory
manual-no-canonical-boundary            → CAUGHT outside
manual-no-dotdot          resolver+gate → CAUGHT dotdot
SVJAZI=21 CAUGHT=21 LIVE=0
rc=0
```

Это проверяет нейтрализацию: каждая снятая защита краснеет именно назначенной клеткой, а не всеобщим аварийным отказом. Уже имеющийся `accept-all` (пустой «успех» без gate marker), `skip-nul-json`, `skip-absolute`, `skip-dotdot`, `skip-canonical`, замены `-f` на `-e` для directory/FIFO и шесть ложных zero-glob также пойманы штатной матрицей выше.

## Атака NUL и границы пути

Настоящий NUL проверен реальным CLI на новых временных git-репозиториях; во всех строках rc=1 и gate не исполнялся:

```text
path-leading-nul, path-middle-nul, path-trailing-nul: SOURCE_CANON_INVALID … path NUL
second-source-nul: SOURCE_CANON_INVALID … sources[1]: path NUL
gate-argv-nul: SOURCE_CANON_INVALID … gate[null]: NUL
defaults-path-nul/defaults-gate-nul: SOURCE_CANON_INVALID в слой-проекта.defaults.sourceCanon … NUL
source-item-key-nul/top-key-nul: rc=1, gate=false (отказ закрытого алфавита до mapfile)
NUL_BOUNDARY=9 CAUGHT=9 LIVE=0
```

Проверка прочих границ также исполнялась реальным CLI:

```text
dir0, p0 FIFO                         → rc=1 «не regular file», gate=false
..0/x, 0.., a/..0, .0/.., 0/../x     → rc=1 «path ..», gate=false
/0, //0                               → rc=1 «path абсолютный», gate=false
./0, a//0, a/./0                      → rc=0, gate=true
link0 → outside; link0 → ../project0; цепочка → ../project-evil
                                      → rc=1 «источник вне репозитория», gate=false
PATH_BOUNDARY=15 CAUGHT=15 LIVE=0
```

Последние два случая подтверждают, что проверка `"$REPO"/*` не подвержена prefix-коллизии `/tmp/R` против `/tmp/R0`/`/tmp/R-evil`: обязательный `/` после `$REPO` сохраняет границу. Это существующая защита, не новый предмет 153.

`printf '"a\\u0000b"\n' | jq -e 'contains("\u0000")' && jq --version` → `true`, `jaq 2.3.0`, rc=0. Именованные `jq-1.6` и `jq-1.7` на станции отсутствуют (каждая `command -v` rc=1); их семантика не проверена и остаётся оговорённой границей контракта.

## ВНЕ ПРЕДМЕТА / СОВЕТ

СОВЕТ — JSON-ключ с NUL в корне профиля отвергается до gate, однако `scan_levels` получает ключ через command substitution: наблюдалось bash warning `ignored null byte in input`, а диагностическое имя стало `sourceCanonx`. Обхода нет (rc=1, gate=false); это не ослабление path/gate-NUL и не блокирует 153. Если требуется точный диагноз NUL в произвольных ключах, это отдельный предмет resolver.

ВНЕ ПРЕДМЕТА — jq 1.6/1.7 отсутствуют; не заявляю их поведение. Управляющие символы кроме NUL, символы вне Σ и пути длиной >5 — явно НЕ ЗАЩИЩАЕТ frozen-контракта.

## Что не проверено

- jq 1.6 и jq 1.7 отсутствуют на станции.
- CI-строка оркестратора и полный CI не запускались (вне scoped-суда).
- TOCTOU/нестандартные файловые системы и управляющие символы кроме NUL — явно вне предмета/границы frozen-контракта.

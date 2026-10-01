FAIL

# Адверсарий — контракт 067 (isolation.backend auto), круг 1

Предмет: реализация 942b604 → land `fd66ed4ffa945f07516ca9d5c85d9892ac8335fb` (= origin/main,
`git rev-list --left-right --count HEAD...origin/main` → `0 0`). Клон
`/tmp/dev-harness-verify/adv067`. Тег `frozen/contracts/067/1`. Адверсарий: Adv067.

## Стенограммы

```text
bash scripts/check_no_leak.sh --check /home/harness/dev-harness            → rc=0, «основной чекаут чист»
bash scripts/check_no_leak.sh --check /tmp/dev-harness-verify/adv067       → rc=1, «ОТКАЗ: снимок отсутствует
  (/tmp/dev-harness-leak/33062d20/porcelain)» — fail-closed без снимка клона (прецедент contracts-032-v1), не дефект предмета
git rev-parse HEAD origin/main → fd66ed4… fd66ed4…; ahead/behind 0/0
CI зелёный abe86c2 — со слов оркестратора, мной не наблюдался [INFERENCE]
```

## Живые прогоны (позитивный контроль — честная реализация зелёная)

| команда (cwd = корень клона) | rc | вывод |
|---|---:|---|
| `bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh .` | 0 | `ИТОГ 067: ветвей 8, красных 0, зелёных 8` |
| `bash scripts/check_runner_hygiene.sh . izolcfg` | 0 | `ok (izolcfg) … enabled: true + … backend: auto` |
| `bash scripts/check_runner_hygiene.sh . klon` | 0 | норма клона названа |
| `bash scripts/check_runner_hygiene.sh . izolnorm` | 0 | isolated: true + disposable-клон |
| `bash scripts/verify_antiplacebo.sh . --scope check_runner_hygiene/case_izolcfg_bez_kljucha check_runner_hygiene/case_klon_v_dereve check_runner_hygiene/case_izolnorm_bez_isolated` | 0 | 1 барьер, 3 фикстуры, 3 повторно красных |
| `omp config get isolation.backend` | 0 | `auto` |
| `omp config get task.isolation.enabled` | 0 | `true` |
| `npm run check:gen` | 0 | `харнес соответствует roles/ (9 ролей)` |
| `git diff --exit-code frozen/contracts/067/1 HEAD -- 'contracts/067-*.md'` | 0 | пусто |
| `git diff --exit-code 0b91b0c HEAD -- 'contracts/06[1-9]-*.md' ':!contracts/067-isolyacija-backend-auto.md'` (часть пути из вердикта критика) | — | контракты 061–069 кроме 067 не тронуты; полная команда критика с `scripts .omp/config.yml roles .omp/agents fixtures` даёт rc=1 ровно на семь файлов предмета (`.omp/agents/{architect,orchestrator}.md`, `.omp/config.yml`, `_lib.sh`, `roles/{architect,orchestrator}.md`, `check_runner_hygiene.sh`) — ожидаемая дельта реализации, не чужой путь |

## Мутанты (оракул — батарея `red_izolcfg_backend_avto_067.sh <корень-мутанта>`)

Каждый мутант — копия настоящего барьера в `tmp/adversary-067-mutants/<имя>/scripts/`, правка
`sed` по коду ветви izolcfg (строки 865–872 и 857 барьера).

| мутант | правка | итог батареи | статус |
|---|---|---|---|
| (а) без enabled-проверки | условия `ENABLED`/`ENABLED_INVALID` → `if (0)` | rc=1, `красных 1`: к8 получила rc=0 «ok (izolcfg)» | **пойман** (к8, named-reason «enabled: false») |
| (б) легаси-пин принимается | `if (have_mode)` → `if (0)` и `NO_KEYS` не срабатывает при `have_mode` | rc=1, `красных 1`: к2 rc=0 | **пойман** (к2) |
| (б′) то же, только `if (have_mode)` → `if (0)` | — | rc=0, 8/0/8 | не мутант по сути: `NO_KEYS` остаётся вторым ловцом — защита в глубину, не дефект |
| (в) хардкод copy | `backend != "auto"` → `… && backend != "rcopy"` | rc=1, `красных 1`: к4 rc=0 | **пойман** (к4) |
| отказ 127 | барьер `exit 127` | rc=1, `красных 8` | **пойман** |
| инструмент мимо PATH | `PATH=/definitely-no-awk` перед awk | rc=1, к1 и к8 красные | **пойман** (к2–к7 зелёны на «причина не записана», см. Д2) |
| **структурно слепой стаб** | весь барьер = `grep -q 'enabled: true' && grep -q '^  backend: auto'`, иначе `ОТКАЗ ветвь (izolcfg): enabled: false` | **rc=0, `ИТОГ 067: ветвей 8, красных 0, зелёных 8`** | **УСКОЛЬЗНУЛ** |

## Дефекты

### Д1 (блокирующий): батарея не судит инвариант 4, настоящий барьер его нарушает — живая изоляция выключена при зелёном izolcfg

Инвариант 4 контракта: «Грамматика ветви izolcfg v2 структурна: якорь отступа различает … ;
сравнения литеральны … значение с хвостом не совпадают». Ни одна из 8 клеток не подаёт вход,
на котором структурная грамматика отличается от двух grep — стаб выше проходит 8/0/8.

Настоящий барьер наследует ту же слепоту (awk: `in_task` не сбрасывается на новой
верхнеуровневой строке, если `in_task_isol` ещё не было; `^[[:space:]]+isolation:` — любой
отступ). Три пробы в toy-корнях `tmp/adversary-067-probes/<имя>/` (+ заглушка
`scripts/verify_antiplacebo.sh`), команда `bash scripts/check_runner_hygiene.sh <корень> izolcfg`,
живая omp-проба — `omp config get … --json` с cwd = toy-корень (omp читает его `.omp/config.yml`:
контроль на `trailing` даёт `task.isolation.enabled` = `true`):

| проба | конфиг | izolcfg | omp `task.isolation.enabled` | omp `isolation.backend` |
|---|---|---:|---|---|
| sibling | `task:`/`  maxConcurrency: 4`/`other:`/`  isolation:`/`    enabled: true` + верхний `isolation:`/`  backend: auto` | **rc=0 ok** | **false** | auto |
| deep | `task:`/`  nested:`/`    isolation:`/`      enabled: true` + верхний `backend: auto` | **rc=0 ok** | **false** | auto |
| trailing | честный enabled + `  backend: auto trailing` | **rc=0 ok** (awk берёт `$2`) | true | auto (дефолт omp; значение не из enum) |
| upper (контроль) | `enabled: TrUE` + `backend: AUTO` | rc=1 HALF | — | — |
| empty (контроль) | пустой файл | rc=1 NO_KEYS | — | — |

sibling/deep — ровно класс Б2 вердикта 4305580 другим входом: барьер печатает
«task.isolation.enabled: true», рантайм omp видит изоляцию ВЫКЛЮЧЕННОЙ. trailing нарушает
дословную норму «значение с хвостом не совпадают» (рантайм спасает дефолт auto, не барьер).

Лечение — за автором (клетки батареи на sibling/deep/trailing с ожиданием reject + сброс
контекста task в awk на любой верхнеуровневой строке и фиксированный отступ вложения, сравнение
всего значения, а не `$2`). Батарея — зона architect/implementer по §Зоны 067.

### Д2 (не блокирует сам по себе): reject-клетки к2–к7 не различают причину

`run_cell … reject` без третьего аргумента принимает любую строку «ОТКАЗ ветвь (izolcfg)»:
мутант «awk мимо PATH» отказывает в к2–к7 причиной «причина не записана», и эти клетки
зелёные. Именованные причины LEGACY_MODE/LEGACY_PATH/PINNED_BACKEND/HALF (инвариант 3: «отклонения
с именованной причиной») батареей не пинуются — только к8. Стаб Д1 проходит именно поэтому:
одна общая причина на все отказы.

## Итог

Мутанты задания (а)/(б)/(в) пойманы, позитивный контроль зелёный, живые прогоны rc 0,
frozen-diff 067 пуст. FAIL по Д1: структурно слепой стаб проходит батарею 8/0/8, и настоящий
барьер v2 на двух входах (sibling, deep) принимает конфиг, в котором omp фактически выключает
изоляцию. Предмет и проверка не правились.

FAIL
Ревьюер Rev112r2, контракт 112 (frozen/contracts/112/2), круг 2, OBJECT=2a83bd1ee1998c775ce5c08ad7a46a2473fb81b3 (union: 61260217c + f27db3964 + 2a83bd1ee). Зоны чисты, контракт не тронут, прежние клетки не ослаблены, все прогоны (в) с ожидаемыми rc, новые клетки честны (на 61260217c красны ровно D34/D35/D36). Но F2/F3 в РЕАЛИЗАЦИИ закрыты только на литералах круга 1. Есть три обхода, на которых реализация даёт rc 0, а модель v3 даёт rc 1: B1 `--prefix ..`, B2 симлинк-лист `--prefix`, B3 `node … || true`. Кроме того, батарея 40/40 остаётся зелёной на мутанте, у которого ветвь node возвращена к дефекту F1/F2 (B4).

---
status: ready
object: 2a83bd1ee1998c775ce5c08ad7a46a2473fb81b3
contract: frozen/contracts/112/2
reviewer: Rev112r2 (anthropic/claude-opus-5-5)
date: 2026-10-20
round: 2
---

## Блокирующие находки

- [ ] **B1 [ОБХОД, F2 не закрыт по сути; зона implementer] `npm --prefix ..` читает package.json родителя репо.**
  Фрагмент: `scripts/check_project_connection.sh:165-170` (`canon_inside_R`): канонизируется только `dirname`, а `basename` дописывается сырым. Для `..` получается `_real="$R/.."`, и это проходит `case "$R"/*`.
  Вход: мир mob (честный), одна мутация `commands.test="npm --prefix .. test"`, `package.json` с `scripts.test` лежит в родителе мира → **impl rc=0, model rc=1**. Тот же результат даёт `npm --prefix mobile/../.. test` (impl 0 / model 1). Без внешнего `package.json` impl отказывает строкой `нет <R>/../package.json`, то есть читает именно файл вне репо.
  Модель v3 делает `cd "$R/$d" && pwd -P` по ПОЛНОМУ пути (`model_check_connection.sh`, блок KOMANDY), поэтому отказывает.

- [ ] **B2 [ОБХОД, F1/F2-класс «вне дерева»; зона implementer] симлинк-лист `--prefix` наружу принимается.**
  Причина та же (`:165-170`): лист `--prefix` не разрешается.
  Вход: в мире `lnkpkg -> <вне>/pkg` (там `package.json` со `"test":"echo fake"`), мутация `commands.test="npm --prefix lnkpkg test"` → **impl rc=0, model rc=1**.
  Контракт §Конструкция `komandy`: скрипт обязан быть в `D/package.json` «в дереве»; модель угроз: «файла нет в дереве».

- [ ] **B3 [ОБХОД, F3 не закрыт для семейства node|python3; зона implementer] `|| true` / `|| exit 0` / `| cat` после файла проходят.**
  Фрагмент: `:199` — образец `*\|-*` ловит только подстроку `|-`, а не `|`. Поэтому токены `||` и `|` проходят. Комментарий `:195` при этом обещает фильтр `|| ; && | & > <` и `"`.
  Вход (мир mob, файл `mobile/scripts/gen.js` есть):
  `commands.lint="node mobile/scripts/gen.js --check || true"` → **impl rc=0, model rc=1**;
  `commands.typecheck="node mobile/scripts/gen.js --check || exit 0"` → impl 0 / model 1;
  `commands.lint="node mobile/scripts/gen.js | cat"` → impl 0 / model 1.
  Для сравнения: `&& true` и `; true` impl отвергает (rc 1). Маскировка отказа (`|| true`) переживает и `bash -e` шага `run: |`, в который `gen_ci_workflow.sh:108-113` кладёт команду профиля.

- [ ] **B4 [ОБХОД барьера, (г): батарея 40/40 при неверной проверке; зона architect] клетки D34/D35 несут по две мутации, поэтому регресс одной ветви не виден.**
  Фрагмент: `red_podkljuchenie_112.sh`, D34/D35 мутируют сразу `.commands.lint` (node) и `.commands.test` (npm --prefix). Клетка ждёт rc 1 с `komandy`, и этого добивается любая из двух мутаций.
  Мутант (клон `/tmp/dev-harness-verify/Rev112r2/mut`): в ветви node `if canon_inside_R …` заменён на `case "$file" in /*) REAL="$file";; *) REAL="$R/$file";; esac; if true` — это ровно дефект F1/F2 круга 1 для node. Результат: `--cell D34` rc 0, `--cell D35` rc 0, **полный прогон: `ИТОГ 112: клеток 40, зелёных 40, красных 0, rc=0`**. При этом probe на том же мутанте: `node-dotdot-F2 impl rc=0 model rc=1`.
  Входов B1/B2/B3 в батарее нет ни одной клеткой, поэтому дефекты реализации живут при зелёном CI. Нужны раздельные клетки по семействам (node-abs, node-dotdot, prefix-abs, prefix-dotdot, включая `--prefix ..`, prefix-symlink-лист, npm `|| true`, npm-голое-имя, node `|| true`).

Подгонки новых клеток под код нет: их входы — литералы вердикта круга 1, а на 61260217c красны ровно D34/D35/D36. Изъян в узости клеток, а не в подгонке.

## Советы (не блокируют)

- [ ] A1 `verify_antiplacebo.sh . --scope check_project_connection` → rc 1 («расхождений: 1»). Это принятый cognitive-only остаток, вне зоны.
- [ ] A2 Ложные комментарии в реализации. `:151` «Здесь — СТРОЖЕ модели»: после v3 модели это неверно, см. B1–B3. `:195` перечень метасимволов не совпадает с образцом `:199`: нет `"` и `|`. Шапка `:20-23` не упоминает закрытую форму.
- [ ] A3 `node <файл>` с симлинк-ЛИСТОМ наружу (`mobile/scripts/lnk.js -> <вне>/evil.js`) принимают и impl, и model (rc 0/0): `-f` следует по ссылке, а лист не канонизируется. Контракт «файл есть в дереве» это допускает буквально. Та же правка, что для B1/B2 (разрешать лист), закрыла бы и этот случай.
- [ ] A4 Перевод строки в значении (`"node f.js\nexit 0"`) принимают impl и model (0/0). Под `bash -e` шага `run: |` отказ node не маскируется [INFERENCE: умолчание shell GitHub Actions], поэтому это не обход.
- [ ] A5 Расхождение без обхода: `npm --prefix mobile --prefix mobile test` impl принимает (цикл по `--prefix`), model v3 отвергает. Абсолютный путь ВНУТРИ репо в node impl принимает, model отвергает как форму.
- [ ] A6 (зона architect) `red_podkljuchenie_112.sh:496` всё ещё вызывает несуществующую `usage` (`line 496: usage: command not found`). rc 2 получается только через `exit "$rc"`.
- [ ] A7 (050) Канонизация «внутрь $R» трижды повторена в одном файле: `check_inside_dir` `:97-121`, `canon_inside_R` `:159-173` и инлайн-блок source-canon `:268-281`. Копии расходятся в главном: `check_inside_dir` разрешает весь путь, а две другие — только родителя, откуда и взялся B1. Проще: один хелпер «`cd` полного каталога + префикс» с параметром причины.

## (а) Область правки и неизменность frozen

`git show --stat` по коммитам (клон `/tmp/dev-harness-verify/Rev112r2/m`):
```
61260217c implementer: .github/workflows/ci.yml, package.json, registry/ci-steps.tsv, scripts/check_project_connection.sh, scripts/profile_resolver.sh
f27db3964 implementer: scripts/check_project_connection.sh (119+/57-)
2a83bd1ee architect:   fixtures/workshop_project/podklyuchenie_112/model_check_connection.sh (65), red_podkljuchenie_112.sh (72)
```
Оба автора не выходят за свои ЗОНЫ. `git diff frozen/contracts/112/2^{commit}..HEAD -- contracts/112-podklyuchenie-proekta.md | wc -l` → 0 (тег = 24672c6ad). Implementer-коммиты фикстур не трогают, architect-коммит реализацию не трогает.

Diff батареи и модели прочитан целиком. В цикле клеток только добавлены D34/D35/D36: ни одна прежняя клетка не удалена, `run_cell` и ожидания прежних клеток не изменены. Счёт заменён счётчиком `vsego`, расхождение 37/40 с текстом принято заданием. Модель только ужесточена: node — непустой файл, запрет абсолютного пути, `cd && pwd -P` + префикс; npm — один `--prefix`, канонизация полного каталога, запрет хвоста и голого имени, оператор оболочки в любом токене. M1/M2 на модели зелёные (`--model` 40/40).

## (б) F1/F2/F3 в реализации — probe (`/tmp/dev-harness-verify/Rev112r2/probe.sh`, `probe2.sh`; мир mob + одна jq-мутация, impl и model на одном входе)

```
honest                         impl rc=0 model rc=0
node-honest-arg                impl rc=0 model rc=0
node-or-true                   impl rc=0 model rc=1   ← B3
node-pipe                      impl rc=0 model rc=1   ← B3
node-or-true-exit              impl rc=0 model rc=1   ← B3
node-amp                       impl rc=1 model rc=1
node-semicolon-sep             impl rc=1 model rc=1
node-newline-exit0             impl rc=0 model rc=0   (A4)
node-dquote                    impl rc=0 model rc=0
node-symlink-leaf-out          impl rc=0 model rc=0   (A3)
npm-prefix-dotdot-bare         impl rc=0 model rc=1   ← B1
npm-prefix-sub-dotdot2         impl rc=0 model rc=1   ← B1
dotdot-without-outer-pkg       impl rc=1 model rc=1   (нет <R>/../package.json — читает вне репо)
npm-prefix-symlink-out         impl rc=0 model rc=1   ← B2
npm-prefix-dollar              impl rc=1 model rc=1
npm-prefix-twice               impl rc=0 model rc=1   (A5)
npm-prefix-eq                  impl rc=1 model rc=1
npm-newline-tail               impl rc=1 model rc=1
npm-dotdot-F2                  impl rc=1 model rc=1   (литерал круга 1 — закрыт)
node-dotdot-F2                 impl rc=1 model rc=1   (литерал круга 1 — закрыт)
npm-or-true-F3                 impl rc=1 model rc=1   (литерал круга 1 — закрыт)
npm-bare-F3                    impl rc=1 model rc=1   (литерал круга 1 — закрыт)
npm-glob                       impl rc=1 model rc=1
unicode-long (5000×«ж»)        impl rc=1 model rc=1
tabs-sep                       impl rc=0 model rc=0
src-dotdot                     impl rc=1 model rc=1   (profil: резолвер SOURCE_CANON_INVALID)
state-dotdot-into              impl rc=0 model rc=0   (mobile/../.harness — внутри, честно)
```
Честные back/mob ложных отказов не дали: M1/M2 зелёные, `node … --check` и табы приняты.

## (в) Прогоны (клон union @ 2a83bd1ee)

| команда | rc | вывод |
|---|---|---|
| `red_podkljuchenie_112.sh` | 0 | `ИТОГ 112: клеток 40, зелёных 40, красных 0, rc=0` |
| `--model` | 0 | `ИТОГ 112: клеток 40, зелёных 40, красных 0, rc=0` |
| `--cell net-takoj-kletki` | 2 | `line 496: usage: command not found` (A6) |
| батарея union против impl 61260217c (`PODKLJUCHENIE_112_CHECKER=<клон 61260217c>`) | 1 | `ИТОГ 112: клеток 40, зелёных 37, красных 3`; красны ровно D34/D35/D36 |
| батарея union против мутанта B4 | 0 | `клеток 40, зелёных 40, красных 0` (B4) |
| state-слепая контрмодель (sed STATE-112) `--cell D14` / `D16` | 1 / 1 | расхождение поймано |
| komandy-слепая контрмодель (sed KOMANDY-112) `--cell D34` / `D35` / `D36` | 1 / 1 / 1 | расхождение поймано |
| impl `--cell D34` / `D35` / `D36` | 0 / 0 / 0 | |
| п.6 jq package.json / awk ci-steps.tsv | 0 / 0 | |
| `gen_ci_steps.sh --write && --check` | 0 | `git status --porcelain` → 0 строк |
| `verify_ci_parity.sh` | 0 | `расхождений: 0` |
| `run_battery.sh profile_resolver` | 0 | `итог 4/4 классов закрыто` |
| `_krasnye_054.sh` | 0 | `итог 054: rc=0` |
| `check_provodka.sh . contracts/112-…md` | 0 | |
| `check_threat_model.sh . contracts/112-…md` | 0 | `ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 4` |
| `verify_antiplacebo.sh . --scope check_project_connection` | 1 | `расхождений: 1` (A1) |

Счёт 40 проверен своей мерой: в цикле 37 прежних имён + 3 новых, итог раннера печатает `vsego`. На 61260217c получено 37 зелёных + 3 красных, что сходится.

## Паразитная сложность (050) — артефакты круга 2

- `canon_inside_R` (impl, f27db3964). (1) Свойство «komandy: файл/каталог в дереве» (§Конструкция). (2) Состояние неявно передаётся через глобальную `REAL`: побочный эффект, его нет в аргументах. (3) Свойство «внутри $R» теперь живёт в 3 копиях одного файла (A7), правка дала +2. (4) Интерфейс мелкий, но работа неполная: лист не разрешается (B1/B2). (5) Потребитель — ветвь komandy. Свойство ESSENTIAL, форма ACCIDENTAL: проще `check_inside_dir`-подобный `cd` полного каталога; он же закрывает B1/B2. Блок по этому пункту уже в B1.
- Инлайн-канонизация source-canon `:268-281` (impl). (1) §Конструкция source-canon «существует в дереве». (2) Явное. (3) См. A7. (4) Дубль логики. (5) Клетка D10. ESSENTIAL по свойству, ACCIDENTAL по форме (A7, совет).
- `op_obolochki` в модели (architect). (1) Закрытая форма komandy (стр. 85 блоба). (2) Нет состояния. (3) 1 файл. (4) Глубокий: один case. (5) D36 и контрмодель (4). ESSENTIAL.
- Клетки D34/D35/D36 (одна семья). (1) Свойства F1/F2/F3 «в дереве» и «закрытая форма». (2) Миры в `$SCRATCH`, внешние цели явные. (3) Батарея + модель: 2 файла. (4) Две мутации на клетку скрывают регресс одной ветви (B4). (5) Полный прогон и CI-шаг. ESSENTIAL; узость — B4.
- Анти-плацебо (4): sed по KOMANDY-112-BEG/END, контрмодель. (1) Правило 3 контракта. (2) Временный `$STAB` удаляется. (3) Sentinels в модели + раннер. (4)–(5) Полный прогон. ESSENTIAL: повторяет образец (3) STATE-112, новой грамматики не вводит.
- Счётчик `vsego` — ESSENTIAL: заменил литерал 37, единый источник.

## Починка (норма 050)

- implementer, `scripts/check_project_connection.sh`: B1, B2 — канонизировать ПОЛНЫЙ каталог `--prefix` (`cd "$R/$d" && pwd -P` + префикс), как в модели и `check_inside_dir`; B3 — образец `:199` ловить `|` (а не `|-`).
- architect, `fixtures/workshop_project/podklyuchenie_112/`: B4 — разнести мутации D34/D35 по семействам и добавить входы B1/B2/B3 клетками; каждая новая клетка обязана быть красной на текущем union-коде (на 2a83bd1ee: B1/B2/B3 дают impl rc 0).

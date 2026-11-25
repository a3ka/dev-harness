accept
OBJECT=b83edfaacf6368d69f809e08f229ecadd475f503

СУД: репо=dev-harness; предмет=206; роль=adversary; вызов=4 (узкий, слово владельца для done); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=archive/206/adversary-v3-fail-72238dc2e7 (FAIL); класс риска=рисковый

Сужу неизменяемый OBJECT, а не собственные изменения. Сверены frozen blob контракта и HEAD: оба `7b89189a2825e7a32618e643cc67b9abb09599bc`. Прочитаны контракт, предыдущий вердикт, решение арбитра и §Быстрый-процесс critic. Порог — воспроизводимое нарушение обязательства на достижимом входе с источниками входа и механизма; зелёная мутация сама по себе не доказывает блок. Это только санкционированное закрытие и регресс, не новый полный суд. Ревьюер `dcf3d350577d92a3e5cca73e951e5f9cbf5db8b7` — другой исполнитель; совпадение модели не запрещено контрактом 166. sourceCanon для предмета не объявлен. Н-39: привязки установлены architect в коде MUTATIONS, не прозой контракта.

## Закрытие

- Б-1 Adv206c: дословная замена цикла mkdir из предыдущего вердикта в настоящем guard, по одному мутанту в одноразовом клоне: `--repo <клон>` rc 1, `guard-mkdir-dirlink-bin-outside: KRASEN`. Честный OBJECT даёт этой клетке ZELEN. Штатный `--stabs` даёт `mkdir-dirlink-parent-symlink-skipped: guard-mkdir-dirlink-bin-outside: POIMAN SELEKTOR neg=48 ctl=24 krasnyh=48:POIMAN`: все отрицательные в заявленном селекторе различены и 24 разрешённых контроля не покраснели. Оси имени бинарника, позиции и лексики присутствуют в `matrix.py` dirlink-продукте.
- Б-2: удаление проверки `vcanon != R` при сохранении `path_inside` в настоящем pre_judge: `--repo <клон>` rc 1, `verdict-root-file: KRASEN`; честный OBJECT — ZELEN. Адресный стаб `verdict-root-equals-repo-ignored: verdict-root-file: POIMAN`; внутренний файл — положительный контроль батареи.
- Сопутствующая действительность `existing/../`: честный `--repo .` вывел ZELEN для `world-existing-rel-own`, других четырёх размещений и трёх dirlink-назначений; генератор добавляет `lex` в относительный путь, а проверка действительно проверяет существование промежуточных каталогов.

## Мутации

Команда каждого измерения: `bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo <одноразовый-клон>`. Клон с собственным `.git` был checkout ровно OBJECT; замены применялись по одной, единственность якоря проверялась, после каждого прогона файл восстанавливался. Внешний запускающий скрипт использовал `subprocess.run`, сохранял сырой rc и выбирал строки результата; саму батарею или исходный OBJECT не менял. Сырые rc:

| Замена единственного якоря | rc | Наблюдение |
|---|---:|---|
| `.omp/extensions/path-guard.ts:591`: `for (const path of paths) pushOp(path);` → дословная замена Adv206c, пропускающая путь с symlink-родителем при квалифицированном бинарнике и нескольких целях | 1 | `guard-mkdir-dirlink-bin-outside: KRASEN` |
| `scripts/pre_judge.sh:377`: `if path_inside "$vcanon" "$R" && [ "$vcanon" != "$R" ]; then` → `if path_inside "$vcanon" "$R"; then` | 1 | `verdict-root-file: KRASEN` |
| `.omp/extensions/path-guard.ts:1154`: `if (!pathAllowed(resolved, canonicalWt, canonicalActual, worktree, sessionName, canonicalSessionCwd)) {` → условие без `!` | 1 | `guard-mkdir-dirlink-bin-outside: KRASEN` |
| `.omp/extensions/path-guard.ts:582`: `if (options && arg.startsWith('-')) continue;` → `if (arg.startsWith('-')) continue;` | 1 | потеря операндов с ведущим дефисом после `--` обнаружена батареей |
| `.omp/extensions/path-guard.ts:1029`: `realAncestorWithin(canonicalSessionCwd, resolved)` → `true` | 1 | `guard-mkdir-dirlink-bin-outside: KRASEN` |
| `scripts/pre_judge.sh:376`: `realpath -m -- "$vcandidate"` → `realpath -mL -- "$vcandidate"` | 1 | `verdict/abs/plain/dir-symlink-dotdot/outside: KRASEN`, соответствующий inside ZELEN |

Дополнительно штатный `--stabs` поймал `mkdir-options-after-separator`, `ancestor-not-checked` и `verdict-logical-before-physical`; для последнего `SELEKTOR neg=8 ctl=8 krasnyh=8:POIMAN`. `--stabs` работает на модели и не подменяет приведённые отдельные мутации production.

## Регресс

Последовательно, `TMPDIR=/tmp/dev-harness-verify/scratch-adv206d`, `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`; cwd — собственная копия. `R=fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh`:

| Команда | сырой rc | Вывод |
|---|---:|---|
| `bash "$R" --repo .` | 0 | `KLETKI=2226 ZELENYE=2226 KRASNYE=0` |
| `bash "$R" --model` | 0 | `KLETKI=2226 ZELENYE=2226 KRASNYE=0` |
| `bash "$R" --stabs` | 0 | `OBMANOK=45 POIMANY=45 ZHIVYH=0` |
| `bash -n scripts/pre_judge.sh` | 0 | без вывода |
| `node --check .omp/extensions/path-guard.ts` | 0 | без вывода |
| `bash scripts/pre_critic.sh contracts/206-sreda-sudji.md` | 0 | `КРИТИК: дверь зелёная` |
| `bash scripts/check_sdacha.sh "$PWD" contracts/206-sreda-sudji.md --run` | 0 | `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3)` |
| `bash scripts/gen_ci_steps.sh --check` | 0 | без вывода |
| `bash scripts/pre_judge.sh verdict --repo "$PWD" --file "$PWD/verdicts/adversary/contracts-206-v4.md"` | 0 | `VERDICT_BRANCH=wip/206/adversary` |

Опция `--syntax` в `probe.py` отсутствует; отдельно выполнены обе указанные синтаксические команды. CI-строка `check:sreda-sudji-206-family-selftest` на OBJECT подключена в `registry/ci-steps.tsv` и workflow, включает три ноги repo/model/stabs; реестр замера 220/217. Наличие строки и локальный `--check` не означают зелёный удалённый CI.

## Блоки

В санкционированной области не обнаружены. Оба прежних предъявленных обхода краснеют на неизменённой батарее OBJECT, честные production и модель зелёные. Этот вердикт не объявляет live-приёмку или весь процесс done.

## НЕ ЗАЩИЩАЕТ

Конечная матрица не доказывает все длины и комбинации поддерживаемого языка; ловцы — CI, reviewer и adversary в санкционированном объёме. За пределами этого узкого вызова остались произвольный shell, `cp -t`/`--target-directory`, обёртки `env`/`command`/`sudo`/`busybox`, компрометация интерпретатора, hardlink и гонки; ловцы — reviewer и живая станционная проба согласно арбитражу. Tool-level deny другого слоя и следование норме реальной моделью не выводятся из локальных фикстур: ловцы — обязательная живая тройка после рестарта и orchestrator. LIVE_JUDGES_NOT_RUN; ТЕГ 4, рестарт, зелёный CI и вливание остаются оркестратору. Красная клетка 083 И0 — известный отдельный блокер 217, не пересуживалась.

## Советы

Нет.

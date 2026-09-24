FAIL

# Контракт 043 — четвёртый круг критика

Предмет `contracts/043-precizionnyj-prefriz-gejt.md` прочитан ЦЕЛИКОМ на свежем
закоммиченном HEAD `ab5e7958b6557635c27b3b3ef94270860d53096d` SSH-клона
`ssh://git@github.com/a3ka/dev-harness.git`, каталог
`/tmp/dev-harness-verify/critic043-round4`. Целиком прочитаны предыдущий
вердикт `verdicts/critic/contracts-043-v3.md`, включая воспроизведение Б6,
и полный diff ab5e795. Перед коммитом выполнены fetch и fast-forward:
origin/main уже на том же ab5e795. Identity коммита — critic.

## Граница и полнота

Судятся ТОЛЬКО закрытие БС6 (Б6 предыдущего вердикта) и действительно новые
дефекты правки ab5e795. БС4 окончательно закрыт арбитражем, исходный БС5
закрыт кругом 3; ни один из них не переоткрывается. Это вторая проверка
предмета БС6, а не четвёртый спор по БС4.

Набор артефактов полный: предмет :10–53, модель угроз :55–68, исполнители
architect/implementer и ЗОНА-границы :273–287, исполняемые команды готовности
:310–347. Контракт и код критиком не менялись. Единственная постоянная
правка — этот вердикт.

## БС6 закрыт; green_18 действительно различает дефект

Создан отдельный worktree из того же SSH-клона на `ab5e795^` (`80153eb`).
В него восстановлены из ab5e795 только барьер и новый green_18:

```bash
git worktree add --detach /tmp/dev-harness-verify/critic043-round4-before ab5e795^
# Следующие команды — в этом worktree:
git restore --source=ab5e795 -- scripts/check_precision_gate.sh fixtures/check_precision_gate/green_18_honest_live_barrier_with_arg.sh
git stash push -m critic043-v4-b6-differential -- scripts/check_precision_gate.sh
bash fixtures/check_precision_gate/green_18_honest_live_barrier_with_arg.sh
git stash pop
bash fixtures/check_precision_gate/green_18_honest_live_barrier_with_arg.sh
```

Stash убирает ТОЛЬКО фикс барьера, один и тот же новый green_18 остаётся.
До фикса получен **rc1**, именно по БС6:

```text
ACTUAL_BARRIER_EXEC pid=1880263 arg=/tmp/pg_case18.Z3y7sx
ACTUAL_BARRIER_EXEC pid=1880831 arg=/tmp/pg_case18.Z3y7sx
precision-гейт 043: fixtures/check_dummy/green_live_with_arg.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

После `git stash pop` тот же green_18 дал **rc0**:

```text
case_18 (честный живой вызов барьера С АРГУМЕНТОМ, Б6 fix — argv[1] обязан быть argv[1], не argv[N]): rc 0
```

Дополнительно воспроизведён исходный сценарий круга 3: прямой абсолютный
вызов dummy с аргументом корня и `sleep 10`. На ab5e795 прямой case **rc0**,
гейт **rc0**, наблюдаемые поля `bash`, абсолютный путь dummy, аргумент корня;
оба запуска внутри гейта реально исполняют dummy. БС6 не оставляется
открытым по инерции и не объединяется с новым БС7 ниже.

## Scoped-регресс и обязательный self-gate

Полный verify_antiplacebo, полный CI, линтеры и форматтеры не запускались.
Собственные живые прогоны:

- `bash fixtures/_krasnye_043.sh` → **rc0**, `итог: 15 файлов, провалов 0`.
  Все прежние 14 файлов и новый green_18 зелёные. В частности:

  ```text
  check_precision_gate/red_07_case_no_live_call.sh rc=0
  check_precision_gate/red_08_case_self_check_fails.sh rc=0
  check_precision_gate/red_15_forged_trace_via_xtracefd.sh rc=0
  check_precision_gate/red_16_xtrace_only_pass.sh rc=0
  check_precision_gate/green_17_honest_live_barrier.sh rc=0
  check_precision_gate/green_18_honest_live_barrier_with_arg.sh rc=0
  ```

- `npm run check:precision-battery` → **rc0**, `итог 4/4 классов закрыто`.
  В stderr остался известный `fatal: tag 'frozen/contracts/991/1' already exists`;
  чистый stderr этому прогону не приписывается.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic043-round4 contracts/043-precizionnyj-prefriz-gejt.md`
  → **rc0**, последняя строка `OK`; stderr именует пропуск собственной семьи.
  Первый запуск параллельно батарее также дал rc0, но сопровождался ошибками
  отсутствующего scratch `lib_zones.../zones_scoped`. Повтор без одновременной
  батареи дал rc0 без этих ошибок. Это не объявляется новым дефектом ab5e795
  и не используется как блокер данного круга.

## Дополнительные края cmdline

Одноразовые пробы строят настоящий toy-репозиторий через `_toy.sh`, запускают
case прямо, затем настоящий гейт; dummy печатает собственный `/proc/$$/cmdline`
по NUL-полям и живёт `sleep 1`. На ab5e795 получено:

| Сценарий | Прямой case | Гейт |
|---|---:|---:|
| Прямой исполняемый shebang-скрипт без аргументов | 0 | 0 |
| Пять аргументов: корень, `alpha`, пустой, `two words`, `omega` | 0 | 0 |
| Единственный пустой аргумент | 0 | 0 |
| `exec /abs/barrier` с теми же пятью аргументами | 0 | 0 |
| `bash /abs/barrier` с теми же пятью аргументами | 0 | 0 |
| Прямой скрипт с `#!/bin/bash -e`, без аргументов | 0 | 1 |
| Прямой скрипт с `#!/usr/bin/env -S bash -e`, без аргументов | 0 | 1 |
| `bash -e /abs/barrier`, без аргументов | 0 | 1 |

Пустой cmdline проверен отдельно на реальном zombie-процессе: `fork`,
`waitid(..., WNOWAIT)`, прочитано **0 байт** из `/proc/<pid>/cmdline`.
На этом файле исполнен буквально извлечённый из текущего барьера блок
`_argv=()`…`_argv1="${_argv[1]:-}"` под `set -u`, с заранее загрязнённым
массивом. Результат **rc0**, `ARGV1=<> COUNT=0`: старое значение не протекает,
обращение к отсутствующему второму полю не падает. Это проверка блока
индексации, не заявленный E2E-прогон гейта на zombie.

## Новый блокер БС7: опция shebang занимает argv[1]

БЛОКИРУЕТ contracts/043-precizionnyj-prefriz-gejt.md:332 — Р10 с green_18 остаётся зелёным при новой потере обещанного в :35–45 и :177–183 подтверждения честного прямого вызова: bash-барьер с опцией в shebang теперь отвергается как неисполненный. Причина в новом ограничении scripts/check_precision_gate.sh:438–445: два прочитанных поля не гарантируют, что второе — путь скрипта.
ОБХОД: дерево ab5e795 выполняет 15/15 семейной приёмки, 4/4 батареи и Р13, но новый green_live.sh буквально исполняет абсолютный scripts/check_dummy.sh без аргументов; dummy имеет `#!/bin/bash -e`, печатает PID и настоящий cmdline, спит секунду и возвращает 0. Прямой case даёт rc0, оба запуска внутри гейта реально вызывают dummy, гейт даёт rc1 «барьер dummy не вызван живьём». На том же входе с ТОЛЬКО убранным ab5e795-фиксом барьера гейт даёт rc0. Приёмка выполнена, подтверждение честного живого вызова потеряно именно этим изменением.

Linux действительно переписывает argv[0] в интерпретатор, но вставляет
необязательную shebang-опцию ПЕРЕД именем скрипта. Наблюдаемые поля:

```text
CMDLINE_FIELD=/bin/bash
CMDLINE_FIELD=-e
CMDLINE_FIELD=/tmp/dev-harness-verify/critic043-v4-b7.7gbtCe/scripts/check_dummy.sh
```

Старый ошибочный цикл до EOF на этом входе случайно находил последнее поле —
путь скрипта. Новый цикл останавливается на `-e`, не читает путь и выносит
ложный диагноз. Это не короткий exec, не подделка argv, не враждебное
окружение и не поиск имени барьера среди данных чужого вызова: сам case
исполняет путь первым словом, опцию добавляет ядро по обычному shebang.
Также нарушается правило 7 AGENTS.md о правдивости отказа.

Новизна проверена ДВАЖДЫ: матричная проба в старом/новом дереве дала
`plain_rc=0, gate_rc=0` → `plain_rc=0, gate_rc=1`; затем минимальная проба
ниже исполнена в одном worktree с stash/pop ТОЛЬКО барьерного фикса:

```text
# Фикс убран, старый барьер ab5e795^:
SHEBANG_OPTION plain_rc=0 gate_rc=0
ACTUAL_BARRIER_EXEC pid=1886637 argc=0
ACTUAL_BARRIER_EXEC pid=1886647 argc=0
OK

# Тот же worktree и та же проба после git stash pop:
SHEBANG_OPTION plain_rc=0 gate_rc=1
ACTUAL_BARRIER_EXEC pid=1886791 argc=0
ACTUAL_BARRIER_EXEC pid=1886801 argc=0
precision-гейт 043: fixtures/check_dummy/green_live.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

### Исполненное минимальное воспроизведение БС7

Сохранить вне рабочего дерева и запустить `bash <проба>` из корня проверяемого
клона. Скрипт возвращает 0 только при принятии честного вызова. На старом
барьере вернул **0**, на ab5e795 — **1**.

```bash
#!/usr/bin/env bash
set -uo pipefail
HERE="$PWD/fixtures/check_precision_gate"
. "$HERE/_toy.sh"
BARRIER="$SUBJ"
WORK="$(mktemp -d /tmp/dev-harness-verify/critic043-v4-b7.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
mk_toy_repo "$WORK"
mk_mint "$WORK" 043
printf '%s\n' '#!/bin/bash -e' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d argc=%d\n" "$$" "$#"' \
  'mapfile -d "" -t cmd < "/proc/$$/cmdline"' \
  'printf "CMDLINE_FIELD=%q\n" "${cmd[@]}"' \
  'sleep 1' 'exit 0' > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"
mk_family_case "$WORK" dummy green_live.sh "#!/usr/bin/env bash
\"$WORK/scripts/check_dummy.sh\"
"
put_draft "$WORK/contracts/043-toy-draft.md" '# Контракт 043

## Предмет
Честный прямой вызов bash-барьера с опцией в shebang.

## Зоны
ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'
plain_rc=0
bash "$WORK/fixtures/check_dummy/green_live.sh" || plain_rc=$?
run_barrier "$WORK" contracts/043-toy-draft.md
printf 'SHEBANG_OPTION plain_rc=%s gate_rc=%s\n%s\n' "$plain_rc" "$LAST_RC" "$LAST_OUT"
[ "$plain_rc" -eq 0 ] && [ "$LAST_RC" -eq 0 ]
```

## Пять вопросов в пределах круга

1. **Критерий слабее предмета?** БС6 теперь различается green_18. Новый БС7
   предъявляет конкретное зелёное по приёмке дерево с потерей честного вызова.
2. **Готовность доказуема командой?** БС6 доказан живым отрицательным контролем,
   неизменностью green_18 и возвратом зелёного после восстановления фикса;
   БС7 этой приёмкой пока не различается.
3. **Решение молча оставлено исполнителю?** Нельзя отождествлять второе поле
   cmdline с именем bash-скрипта при наличии опции интерпретатора. Требуется
   сохранить подтверждение командной позиции; изменение предмета на
   «только shebang без опций» контрактом не объявлено.
4. **Названы ли границы?** Барьер и семейные фикстуры входят в объявленные
   architect/implementer-зоны :275–277; существующий механизм check_zones
   сохраняется. Для закрытия найденной регрессии расширять зоны не нужно.
5. **Противоречие старшей норме?** Новый ложный диагноз БС7 противоречит
   правилу 7 AGENTS.md. Обязательный precision-гейт исполнен живьём.
   Окончательные решения по БС4 и исходному БС5 не пересмотрены.

Итог: БС6 закрыт. Единственный блокер — действительно новый БС7, не повтор
прежнего отказа. Арбитраж по уже закрытым БС4/БС5 не созывается.

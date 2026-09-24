FAIL

# Контракт 043 — пятый круг критика

Предмет `contracts/043-precizionnyj-prefriz-gejt.md` прочитан ЦЕЛИКОМ на
закоммиченном HEAD `f5e88af0da1b4c1d5c70c10f96e855e1403bee8b` собственного
SSH-клона `ssh://git@github.com/a3ka/dev-harness.git`, каталог
`/tmp/dev-harness-verify/MilitaryCoyote-043-v5`. Целиком прочитаны diff f5e88af
и `verdicts/critic/contracts-043-v4.md`, включая раздел «Новый блокер БС7».

## Граница и полнота

БС4, исходный БС5 и БС6 окончательно закрыты и НЕ переоткрываются.
Проверяются закрытие БС7 и структурная достаточность предъявленного фикса.
Набор артефактов полный: предмет :10–53, модель угроз :57–69,
исполнители architect/implementer и ЗОНА-границы :275–287, команды
готовности :312–347. Контракт и реализация критиком не менялись.

**Точный сценарий предыдущего БС7 закрыт. Класс смещения пути скрипта
опциями интерпретатора НЕ исчерпан.** Ниже один блокер — неполнота закрытия
БС7, а не переименование старых БС4–БС6 и не утверждение, будто f5e88af
внёс ещё одну новую регрессию.

## Живой дифференциал green_19: 1 → 0

Создан изолированный worktree на `f5e88af^` (`1e5231f`). В нём из f5e88af
восстановлены только барьер и новый green_19; stash убирает ТОЛЬКО барьерный
фикс, сам green_19 в обоих прогонах один и тот же:

```bash
git worktree add --detach /tmp/dev-harness-verify/MilitaryCoyote-043-v5-before f5e88af^
# Далее в этом worktree:
git restore --source=f5e88af -- scripts/check_precision_gate.sh fixtures/check_precision_gate/green_19_honest_live_barrier_shebang_option.sh
git stash push -m critic043-v5-b7-differential -- scripts/check_precision_gate.sh
bash fixtures/check_precision_gate/green_19_honest_live_barrier_shebang_option.sh
git stash pop
bash fixtures/check_precision_gate/green_19_honest_live_barrier_shebang_option.sh
```

До фикса **rc1**:

```text
ACTUAL_BARRIER_EXEC pid=1946958 argc=0
ACTUAL_BARRIER_EXEC pid=1946969 argc=0
precision-гейт 043: fixtures/check_dummy/green_live_shebang_option.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

После восстановления фикса **rc0**:

```text
case_19 (честный живой вызов барьера С ОПЦИЕЙ В SHEBANG, БС7 fix — argv[2] обязан быть argv[2], не argv[1]): rc 0
```

Регрессия полезна и действительно различает исправленный дефект, это не
фикстура с безусловно зелёным результатом.

## Остальные 15 файлов не сломаны; scoped-приёмка зелена

Собственные живые прогоны на f5e88af:

- `bash fixtures/_krasnye_043.sh` → **rc0**, `итог: 16 файлов, провалов 0`.
  В полном выводе индивидуальный rc0 у red_02, red_04, red_05, red_06,
  red_07, red_08, red_13, red_14, red_15, red_16, green_01, green_03,
  green_09, **green_17, green_18, green_19**. Тем самым проверены все прежние
  15 файлов, включая оба чувствительных к cmdline green_17/green_18.
- `npm run check:precision-battery` → **rc0**, `итог 4/4 классов закрыто`.
  В stderr есть `fatal: tag 'frozen/contracts/991/1' already exists`;
  безошибочный stderr этому прогону не приписывается.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/MilitaryCoyote-043-v5 contracts/043-precizionnyj-prefriz-gejt.md`
  → **rc0**, последняя строка `OK`; stderr именует пропуск собственной семьи.
  Обязательная bash-команда роли исполнена.

Полный CI, полный verify_antiplacebo, форматтеры и линтеры не запускались.

## Структурная оценка: локальная лемма верна, общий вывод неверен

Linux `fs/binfmt_script.c`, `load_script`, действительно вставляет ровно:
`interpreter`, необязательный **один** `i_arg`, имя скрипта, прежние аргументы.
Для ОДНОГО преобразования shebang, если интерпретатор затем не меняет argv,
это исчерпывающе: имя скрипта находится на позиции 1 или 2. Число, пустота
и содержимое аргументов ПОСЛЕ имени скрипта этого не меняют. Здесь фикс
не точечный: обычные прямые `#!/bin/bash` и `#!/bin/bash -e` покрыты структурно.

Но гейт читает `/proc/<pid>/cmdline` ПОСЛЕ возможного exec интерпретатора,
а не argv строго на выходе `load_script`. Уже названный самим фикс-коммитом
`#!/usr/bin/env -S ...` выполняет второе преобразование: GNU env разделяет
ОДИН полученный от ядра аргумент на НЕСКОЛЬКО и исполняет bash с ними.
Поэтому из ограничения ядра не следует ограничение окончательного cmdline.

Источники, прочитанные в этом круге:

- https://raw.githubusercontent.com/torvalds/linux/v6.18/fs/binfmt_script.c
  — `remove_arg_zero`, `copy_string_kernel(bprm->interp)`, условный
  `copy_string_kernel(i_arg)`, `copy_string_kernel(i_name)`.
- https://www.gnu.org/software/coreutils/manual/html_node/env-invocation.html
  — §23.2.2 прямо определяет `-S` как разделение единственной shebang-строки
  в несколько аргументов; приводит `#!/usr/bin/env -S perl -T -w`.

Для `#!/usr/bin/env -S bash -e -u` преобразования таковы:

```text
ядро: [env, "-S bash -e -u", /abs/barrier]
env:  [bash, -e, -u, /abs/barrier]
                         путь = argv[3]
```

С `-e -u -o pipefail` путь уже на argv[5]. Это целый класс вторичного
преобразования argv, а не следующий магический индекс. Увеличение лимита
с 3 до 4 полей не является структурным закрытием; поиск имени во всех
аргументах тоже сам по себе не доказывает командную позицию. Выбор
корректного механизма остаётся автору, не критик-реализация в вердикте.

## БС7 закрыт не полностью: живая контрпроба

БЛОКИРУЕТ contracts/043-precizionnyj-prefriz-gejt.md:332 — Р10 остаётся зелёным на дереве, где обещанное :35–45, :62 и :177–183 подтверждение честного прямого вызова теряется после штатного env -S преобразования shebang. Три прочитанных поля scripts/check_precision_gate.sh:466–479 не исчерпывают cmdline процесса интерпретатора; утверждение :440–441 «ВСЕГДА ... НИКОГДА дальше» неверно.
ОБХОД: дерево f5e88af даёт 16/16 Р10, 4/4 Р11 и rc0 Р13. Новый green_live.sh буквально исполняет абсолютный scripts/check_dummy.sh без аргументов; dummy имеет `#!/usr/bin/env -S bash -e -u`, печатает настоящий /proc/$$/cmdline, спит секунду и возвращает 0. Прямой case rc0; оба запуска внутри гейта реально исполняют dummy с cmdline `[bash,-e,-u,/abs/barrier]`; гейт rc1 «барьер dummy не вызван живьём». Приёмка выполнена, честный живой вызов потерян. Это также ложный диагноз по правилу 7 AGENTS.md.

Одноразовая проба строила настоящий toy через `_toy.sh`, меняла только
shebang одного dummy, выполняла case прямо и затем настоящий гейт:

| Shebang | Прямой case | Гейт до f5e88af | Гейт f5e88af |
|---|---:|---:|---:|
| `#!/bin/bash -e` | 0 | 1 | 0 |
| `#!/usr/bin/env -S bash -e` | 0 | 1 | 0 |
| `#!/usr/bin/env -S bash -e -u` | 0 | 1 | 1 |
| `#!/usr/bin/env -S bash -e -u -o pipefail` | 0 | 1 | 1 |

Старое состояние проверено повторным stash ТОЛЬКО барьера в том же
изолированном worktree. Таблица честно показывает: это НЕ новая регрессия
f5e88af, а оставшаяся непокрытой часть БС7, обнаруженная именно запрошенной
оценкой исчерпанности. БС6 про аргументы ПОСЛЕ имени скрипта не пересматривается.

Сырой фрагмент результата f5e88af (тот же путь во всех трёх cmdline):

```text
SHEBANG=#!/usr/bin/env -S bash -e -u
ACTUAL_BARRIER_EXEC pid=1948935 argc=0
CMDLINE_FIELD=bash
CMDLINE_FIELD=-e
CMDLINE_FIELD=-u
CMDLINE_FIELD=/tmp/dev-harness-verify/MilitaryCoyote-043-v5-structural.jUVbEr/scripts/check_dummy.sh
plain_rc=0 gate_rc=1
ACTUAL_BARRIER_EXEC pid=1949003 argc=0
ACTUAL_BARRIER_EXEC pid=1949013 argc=0
precision-гейт 043: fixtures/check_dummy/green_live.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

Это не враждебное окружение, не ложное совпадение имени среди данных чужого
вызова, не короткий exec: файл действительно исполняется первым словом
case, оба раза живёт секунду. `env -S` здесь штатный интерпретатор shebang,
а не ENV TRUST-инъекция. Исключения :66–69 этого входа не исключают.

### Минимальная воспроизводимая проба

Сохранить вне проверяемого дерева и выполнить `bash <проба>` из корня клона.
На f5e88af она возвращает **1**, с именованным ложным отказом; сам case — 0.
Тело ниже — минимальный вариант исполненной матрицы для её третьей строки.

```bash
#!/usr/bin/env bash
set -uo pipefail
HERE="$PWD/fixtures/check_precision_gate"
. "$HERE/_toy.sh"
BARRIER="$SUBJ"
WORK="$(mktemp -d /tmp/dev-harness-verify/critic043-v5-b7.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
mk_toy_repo "$WORK"
mk_mint "$WORK" 043
printf '%s\n' '#!/usr/bin/env -S bash -e -u' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d argc=%d\n" "$$" "$#"' \
  'mapfile -d "" -t cmd < "/proc/$$/cmdline"' \
  'printf "CMDLINE_FIELD=%q\n" "${cmd[@]}"' \
  'sleep 1' 'exit 0' > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"
mk_family_case "$WORK" dummy green_live.sh "#!/usr/bin/env bash
\"$WORK/scripts/check_dummy.sh\"
:"
put_draft "$WORK/contracts/043-toy-draft.md" '# Контракт 043

## Предмет
Честный прямой вызов барьера с опциями shebang.

## Зоны
ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'
plain_rc=0
bash "$WORK/fixtures/check_dummy/green_live.sh" || plain_rc=$?
run_barrier "$WORK" contracts/043-toy-draft.md
printf 'plain_rc=%s gate_rc=%s\n%s\n' "$plain_rc" "$LAST_RC" "$LAST_OUT"
[ "$plain_rc" -eq 0 ] && [ "$LAST_RC" -eq 0 ]
```

## Пять вопросов в пределах круга

1. **Критерий слабее предмета?** Да: названо конкретное дерево и честный
   прямой вызов, не различаемый зелёной приёмкой. Один блокер выше.
2. **Готовность доказуема командой?** Точный green_19 — да, независимый
   отрицательный контроль 1→0 исполнен; исчерпанность всего класса — нет,
   контрпроба возвращает 1 при прямом rc0.
3. **Решение молча оставлено исполнителю?** Не определено корректное
   подтверждение имени скрипта ПОСЛЕ userspace-преобразования argv.
   Нельзя молча ограничить обещанный прямой вызов shebang без env -S
   с несколькими опциями; такого ограничения контракт не содержит.
4. **Границы исполнения названы?** Да: барьер и семейные фикстуры входят
   в architect/implementer-зоны :275–277, механизм — check_zones.sh.
   Расширять зоны для закрытия БС7 не требуется.
5. **Противоречие AGENTS.md?** Ложное «не вызван живьём» при доказанном
   вызове противоречит правилу 7. Обязательный precision-гейт исполнен.
   Старые решения БС4–БС6 не пересматривались.

АРБИТР: Arbiter043B4 (роль arbiter) — созывается критиком на вопрос структурного закрытия БС7: достаточно ли двух позиций окончательного cmdline, когда штатный env -S преобразует один shebang-аргумент в несколько, и является ли предъявленный честный прямой вызов частью обещанного предмета. Это второй FAIL по причине БС7; БС4 и прежнее решение этого арбитра НЕ пересматриваются.

Итог: точная репродукция БС7 исправлена, остальные 15 файлов не сломаны,
но заявленная исчерпанность класса опровергнута живым исполнением и
семантикой двух последовательных преобразований argv. Заморозка пока
не разрешена; третий точечный фикс индекса вместо решения класса
этим вердиктом не предлагается.

Перед коммитом выполнены `git fetch origin` и `git merge --ff-only origin/main`: получен 951d993, изменён только HANDOFF.md; предмет и проверенный фикс остались прежними. Identity вердикта — critic.

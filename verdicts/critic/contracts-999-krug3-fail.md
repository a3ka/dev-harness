FAIL
OBJECT=559eb232d9810ef8f4a9e2b56624eed028f161a3

# Критик 999 — круг 3 после арбитража

**К ВЛАДЕЛЬЦУ: кап трёх кругов достигнут.** Блокирует один воспроизведённый обход принятого пункта **К1.5**, не новое требование вне закрытого перечня. Следующий обычный круг этим вердиктом не предлагается.

Предмет — закоммиченный контракт `contracts/999-cmp-mob-002-navigatsiya.md` и его исполняемые критерии на OBJECT, не будущая реализация Complior-mob. Набор артефактов полный: предмет, команды готовности, исполнители и ЗОНА-строки есть. Прочитаны роль критика, AGENTS.md, оба прежних вердикта и `verdicts/arbitration/contracts-999-perechen-v1.md` из origin/main. Суд ограничен К1–К4 / П1–П7.

**Что действительно закрыто:** все 11 обходов круга 1 красные; все 7 обходов круга 2 и X1–X5 арбитра красные, включая отдельные named-клетки; оба прежних combined красные; матрицы copy/static не регрессировали. Честный эталон зелёный, в том числе у независимого свидетеля арбитра. Однако известные обманки не исчерпывают принятый пункт К1.5: его проверка пропускает дефект после перехода в уже объявленное состояние profile(origin).

## Единственная блокирующая находка

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:53 — К1.5 обещает отсутствие faden при `rm=true` в тех же клетках состояний, но команды критерия :66–67 допускают появление `shell-faden` после входа в профиль. В `fixtures/workshop_project/nav_999/nav.test.tsx:104` отсутствие проверяется ДО `profile-entry`; после перехода (:105–109) вызывается `sweepSurface`, который проверяет контейнеры/copy/accent, но не отсутствие faden. Правильные координаты в имени `PROFILE_RETURN_*_RM1_*` не обеспечивают наблюдение К1.5 внутри состояния profile.

ОБХОД: в честном эталоне, установленном только в disposable R, изменить `mobile/src/bootstrap/tab-shell.tsx:74`: `{!reducedMotion ? <View` заменить на `{(!reducedMotion || route === 'profile') ? <View`. Больше ничего не менять. Начальное состояние при `reducedMotion=true` правильное; после `shell-profile-entry` профиль показывает запрещённый `shell-faden`. Все четыре обычные пробы возвращают 0; все четыре `--matrix` тоже возвращают 0. Независимый живой RNTL-свидетель на восьми сочетаниях origin×theme проходит на честном эталоне и падает на обходе во всех восьми случаях именно на `queryByTestId('shell-faden').toBeNull()` ПОСЛЕ открытия профиля.

Это существующий закрытый пункт: арбитраж, «Решение 2», К1.5 — «∀ клетка с rm=true: shell-faden отсутствует»; profile(origin) входит в К1.2. `returnSection` в репро не задан. Наличие faden при `rm=false`, физическая анимация/Android и новые состояния не проверяются. Исключения строки :59 («присутствие faden при rm=false», returnSection+profile) к обходу не относятся. Расширять перечень не требуется: не наблюдается уже принятое свойство внутри уже принятого состояния.

Граница исправления, если владелец разрешит дальнейшую работу: наблюдать К1.5 в достигнутых состояниях принятой таблицы, а не только до действия. Сам контракт, пробы и модель судимого объекта мной не исправлялись.

## Проверка закрытого перечня и П1–П7

| Пункт | Наблюдённый результат |
|---|---|
| К1.1–1.4, 1.6 / П1 | Координаты from×to×mode порождаются грамматикой; названные навигационные обходы круга 1, круга 2 и X1 красные. К1.5 закрыт не полностью — единственная находка выше. |
| К2 / П2 | Button 2×2×2, Notice×2, TextField secure×scheme; secondary-disabled, input-accent, X3 и старые UI-обходы красные. |
| К3 / П3 | Общий обход проверяет композицию и вложенность хостов; containers-detached, X4 и X5 красные; прямые подмены View по-прежнему красные. |
| К4 / П4 | Каталог/Back/accent наблюдаются на расширенной поверхности; light-copy, nonstart-accent, X2 и старый неверный Back красные. Dark-гейт не используется как новый блокер. |
| П5 | Все 12 предписанных патчей совпадают побайтово с CRITIC/ARB арбитражного measure.py; каждый красен в своей семье и своей named-клетке. Все 46 матричных мутантов именованно красные, unexpected_red=none. |
| П6 | Контракт объявляет грамматику, закрытые пункты и исключения. Числа 165/18/6/51 подтверждены независимым сопоставлением имён из живого вывода, не повтором case_list(). Модель не менялась относительно круга 2. |
| П7 | B красный именованно; --model и установленный эталон зелёные; все четыре матрицы эталона зелёные; обязательные декои/combined красные; прежняя регрессия закрыта; disposable-деревья восстановлены; метагейты зелёные. Это не устраняет предъявленный дополнительный обход внутри К1.5. |

### Пять вопросов роли

1. Критерий слабее предмета — да, конкретный К1.5-обход удовлетворяет восьми предъявленным командам.
2. Команды готовы к исполнению и названы; недостаточность — наблюдение свойства после перехода, не отсутствие команды и не отложенная Android-приёмка.
3. Решение не оставлено исполнителю: арбитраж и контракт уже требуют отсутствия faden при rm=true. Дефект — доказательство принятого решения.
4. Исполнители и границы названы (:78–88), precision-гейт зелёный. Контрпример внутри implementer-пути `mobile/src/bootstrap/tab-shell.tsx`; расширять зону для обхода не нужно.
5. Применена норма красных критериев кодового контракта. Отдельного блокера вне К1–К4 по остальной прозе нет.

## Команды и сырой вывод

Корень всех собственных записей: `/tmp/dev-harness-verify/critic999r3/`. Основной checkout не открывался; commit/push не выполнялись по Н-85 и прямому брифу. Read-only `product/` получен `gh repo clone a3ka/Complior-mob` и закреплён на B=`f0d8e54e181853473e23c7df3dc623bbb7faecdf`. `R/` и `R-regression/` — отдельные disposable-клоны, каждый подготовлен `npm ci` (rc=0, не project-wide validation). Полное тело issue #6 прочитано через `gh issue view 6 --repo a3ka/Complior-mob --json body --jq .body`, rc=0.

### Предмет и допуск

```text
$ git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/critic999r3/clone
$ git fetch origin wip/999/architect
$ git checkout --detach 559eb232d9810ef8f4a9e2b56624eed028f161a3
$ git fetch origin --tags
$ git rev-parse HEAD
559eb232d9810ef8f4a9e2b56624eed028f161a3
[exit=0]

$ bash scripts/pre_critic.sh --repo . contracts/999-cmp-mob-002-navigatsiya.md
КРИТИК: дверь зелёная
[exit=0]

$ bash scripts/check_precision_gate.sh . contracts/999-cmp-mob-002-navigatsiya.md
OK
[exit=0]

$ bash scripts/check_threat_model.sh . contracts/999-cmp-mob-002-navigatsiya.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 8 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))
[exit=0]
```

`pre_critic` исполнен первым барьером после checkout. Первоначальный origin/main не содержал арбитраж; `git fetch origin main` обновил ref с `977454a6` до `c1e4b768`, затем `git show origin/main:verdicts/arbitration/contracts-999-perechen-v1.md` дал документ, rc=0. Это устранённая задержка ref, не блокер. SHA256 закоммиченного текста арбитража: `1dc7ab9d9f830a1af9a52a9de93c73b10aa4d80ecbbd6ead1d76ddd6382bd541`.

### Воспроизводимые запуски

```bash
env PYTHONDONTWRITEBYTECODE=1 TMPDIR=/tmp/dev-harness-verify/critic999r3 \
  python3 /tmp/dev-harness-verify/critic999r3/audit.py baseline
env PYTHONDONTWRITEBYTECODE=1 TMPDIR=/tmp/dev-harness-verify/critic999r3 \
  python3 /tmp/dev-harness-verify/critic999r3/audit.py gap
env PYTHONDONTWRITEBYTECODE=1 TMPDIR=/tmp/dev-harness-verify/critic999r3 \
  python3 /tmp/dev-harness-verify/critic999r3/regression.py
env PYTHONDONTWRITEBYTECODE=1 \
  python3 /tmp/dev-harness-verify/critic999r3/summarize.py
```

Все четыре запуска завершились rc=0. У `audit.py` это успешное измерение ожидаемых зелёных И красных результатов, а не зелёность каждого субъекта. Дочерние CLI-команды, stdout/stderr и реальные EXIT записаны полностью в `baseline.log`, `gap.log`, `matrix.log`, `decoys.log`, `old.log`; `summary.txt` — отдельно помеченная производная сводка. Сырые итоговые строки раннеров:

```text
MEASUREMENT_COMPLETED baseline log=/tmp/dev-harness-verify/critic999r3/baseline.log
MEASUREMENT_COMPLETED gap log=/tmp/dev-harness-verify/critic999r3/gap.log
MEASUREMENT_COMPLETED matrix log=/tmp/dev-harness-verify/critic999r3/matrix.log
MEASUREMENT_COMPLETED decoys log=/tmp/dev-harness-verify/critic999r3/decoys.log
MEASUREMENT_COMPLETED old log=/tmp/dev-harness-verify/critic999r3/old.log
```

### Невакуумный контроль

На B — дословные диагностические строки и коды четырёх дочерних команд:

```text
999 NAV_SHELL_ABSENT
EXIT=1
999 UI_PRIMITIVES_ABSENT
EXIT=1
999 STATIC_THEME_ABSENT
EXIT=1
999 COPY_MODULE_ABSENT
EXIT=1
```

На B с `--model` и на установленном эталоне без этого флага все четыре пробы rc=0. Неизменённый RNTL-свидетель арбитра на честной модели:

```text
WITNESS honest JEST_EXIT=0 cells=62
STATUS_AFTER rc=0 (clean)
MEASUREMENT_COMPLETED baseline
```

Независимая сверка множества имён из живого вывода с декартовыми произведениями (сырой stdout `summarize.py`):

```text
INDEPENDENT_GRAMMAR nav: model=165 ref=165 missing=0 extra=0
INDEPENDENT_GRAMMAR ui: model=18 ref=18 missing=0 extra=0
INDEPENDENT_GRAMMAR static: model=6 ref=6 missing=0 extra=0
INDEPENDENT_GRAMMAR copy: model=51 ref=51 missing=0 extra=0
MATRICES matrix.log: nav=16 ui=18 static=7 copy=5 all_named_red=46 unexpected_red=0
MATRICES gap.log: nav=16 ui=18 static=7 copy=5 all_named_red=46 unexpected_red=0
```

### Обязательные обходы и регрессия

В каждой строке RESULT порядок кодов — nav/ui/static/copy. Ниже дословные строки `decoys.log`, не выдуманная таблица:

```text
RESULT transition-post-vorgaenge [1, 0, 0, 0]
RESULT reduced-motion-emits-command [1, 0, 0, 0]
RESULT secondary-disabled-ignored [0, 1, 0, 0]
RESULT input-accent-text [0, 1, 0, 0]
RESULT containers-detached [1, 1, 0, 0]
RESULT light-copy-invented [1, 0, 0, 1]
RESULT nonstart-accent-title [1, 1, 0, 0]
RESULT X1 nav-gated-by-colorScheme [1, 0, 0, 0]
RESULT X2 copy-invented-under-reducedMotion [1, 0, 0, 1]
RESULT X3 textfield-always-secure [0, 1, 0, 0]
RESULT X4 tabbar-outside-safe-area [1, 1, 0, 0]
RESULT X5 profile-not-in-keyboard-container [1, 1, 0, 0]
RESULT combined [1, 1, 0, 1]
WITNESS combined JEST_EXIT=1 cells=62
```

Каждый декой дополнительно исполнен через `--case <named>` и дал rc=1; сопоставление патчей с исходными CRITIC/ARB выполнено до запуска. Named-имена и весь вывод — `decoys.log` и `summary.txt`.

Все 11 мутаций первого круга по отдельности дали rc=1 своей семье (`old.log`); старый combined и прежний спорный status-lost:

```text
RESULT old-combined [1, 1, 0, 1]
MUTANT status-lost: named=REVIEW_STATUS RED depends_red=['COPY_TEXT'] unexpected_red=none -> OK
```

Static=0 у combined ожидаем: в этом дереве нет статической мутации. Матрицы исполняли все колонки, а не только named. После каждого режима раннер получил:

```text
STATUS_AFTER rc=0 (clean)
```

### Доказанный оставшийся обход К1.5

`audit.py:GAP` содержит единственную замену условия; `motion.test.tsx` — независимый свидетель принятого К1.5. Файлы устанавливаются только в disposable R с восстановлением.

Четыре обычные CLI-команды на обходе — строки команд и кодов из `gap.log` (промежуточные case здесь не перепечатаны):

```text
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/nav_probe.py --repo /tmp/dev-harness-verify/critic999r3/R
EXIT=0
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/ui_probe.py --repo /tmp/dev-harness-verify/critic999r3/R
EXIT=0
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/shell_static_probe.py --repo /tmp/dev-harness-verify/critic999r3/R
EXIT=0
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/copy_probe.py --repo /tmp/dev-harness-verify/critic999r3/R
EXIT=0
RESULT K1.5-gap [0, 0, 0, 0]
```

Невакуумное различение независимым свидетелем — дословно:

```text
WITNESS honest-K1.5 JEST_EXIT=0 cells=8
{"profile post RM1 dark has no faden": "passed", "profile post RM1 light has no faden": "passed", "profile schutz RM1 dark has no faden": "passed", "profile schutz RM1 light has no faden": "passed", "profile start RM1 dark has no faden": "passed", "profile start RM1 light has no faden": "passed", "profile vorgaenge RM1 dark has no faden": "passed", "profile vorgaenge RM1 light has no faden": "passed"}
WITNESS bypass-K1.5 JEST_EXIT=1 cells=8
{"profile post RM1 dark has no faden": "failed", "profile post RM1 light has no faden": "failed", "profile schutz RM1 dark has no faden": "failed", "profile schutz RM1 light has no faden": "failed", "profile start RM1 dark has no faden": "failed", "profile start RM1 light has no faden": "failed", "profile vorgaenge RM1 dark has no faden": "failed", "profile vorgaenge RM1 light has no faden": "failed"}
```

Фрагмент живого отказа Jest (`gap.log:265–275`):

```text
  ● critic999r3 K1.5 › profile start RM1 dark has no faden

    expect(received).toBeNull()

    Received: <View style={[{"height": 3, "marginHorizontal": 16}, {"backgroundColor": "#d6f75a"}]} testID="shell-faden" />

      13 |         await fireEvent.press(view.getByTestId('shell-profile-entry'));
      14 |         expect(view.getByTestId('profile-surface')).toBeTruthy();
    > 15 |         expect(view.queryByTestId('shell-faden')).toBeNull();
         |                                                   ^
```

Все четыре матрицы на ТОМ ЖЕ обходном дереве также исполнены через CLI:

```text
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/nav_probe.py --repo /tmp/dev-harness-verify/critic999r3/R --matrix
EXIT=0
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/ui_probe.py --repo /tmp/dev-harness-verify/critic999r3/R --matrix
EXIT=0
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/shell_static_probe.py --repo /tmp/dev-harness-verify/critic999r3/R --matrix
EXIT=0
$ python3 /tmp/dev-harness-verify/critic999r3/clone/fixtures/workshop_project/nav_999/copy_probe.py --repo /tmp/dev-harness-verify/critic999r3/R --matrix
EXIT=0
STATUS_AFTER rc=0 (clean)
MEASUREMENT_COMPLETED gap
```

Полный вывод case/MUTANT — `gap.log:416–1012`. Nav/UI-матрицы устанавливают собственных мутантов модели, но honest-часть исполняет текущее обходное дерево; все honest-части тоже зелёные. Это не отсутствие дефекта: именно его критерий не различает.

## Граница результата

Не запускались и не объявляются зелёными Android/Maestro, quality/CI Complior-mob и frozen-995 на будущем C. Физический рендер не подменён RNTL. FAIL касается только принятого К1.5 до заморозки; остальные подтверждённые исправления не обнуляются. Изменений реализации продукта или критериев на HEAD нет. Репро, свидетель и полные сырые логи сохранены рядом с этим файлом; дальнейшее решение после капа — владельцу.

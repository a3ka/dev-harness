FAIL

# Адверсарий: контракт 006 — scoped изолированный гейт

Проверено на `/home/aka/Documents/dev-harness`, исходный HEAD `e0484ac`.
Атакующие деревья и генераторы находятся только в `tmp/adversary-006/`; предмет и барьеры не
изменялись.

## Положительный контроль барьеров

Перед атаками оба барьера были запущены непосредственно на реализованном предмете:

```console
$ pkill -9 -f 'verify_antipl|check_scop' 2>/dev/null; rm -rf tmp/antiplacebo/run-* 2>/dev/null
$ bash scripts/check_scope_select.sh "$PWD"
  ok   (а) неизвестный ключ отвергнут
  ok   (б) пустой --scope отвергнут
  ok   (в) неизвестный case отвергнут
  ok   (г) доки-only → needs-full код 2, маркер SCOPED:
  ok   (д) нерезолвимая база и не-git дерево → 2
  ok   (е) правка b → scoped, ровно ключ b
  ok   (ж) правка библиотеки → full
  ok   (з) add/delete/rename/смена-роли → full
  ok   (и) case-уровень выбирает ровно свой case
  ok   (к) scoped и needs-full помечены SCOPED:
  ok   (л) git-отсутствие (PATH без git) → код 2 + SCOPED:
check_scope_select: ветви «all» зелены
$ bash scripts/check_scoped_run.sh "$PWD"
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
check_scoped_run: ветви «all» зелены
```

Следующие состояния контракта запрещены, однако тот же предмет проходит оба барьера зелёным.
Это дыры приёмки вида **2**.

## Обход 1 — зависимый барьер сужается вместо полного прогона

**Вид:** 2 (дыра `check_scope_select.sh`).

**Нарушенный инвариант:** контракт §2 разрешает сузить выборку лишь когда изменённый барьер
не сорсится другим eligible-барьером. Если `a` делает `source b.sh`, изменение `b.sh` обязано
дать `MODE: full`, поскольку воздействует также на `a`.

Генератор `tmp/adversary-006/setup-sourced-barrier.sh` создаёт git-дерево с двумя корректно
объявленными барьерами `a` и `b`, где `a` сорсит `b`; затем изменяет только `b`.

```console
$ base="$(tmp/adversary-006/setup-sourced-barrier.sh tmp/adversary-006/sourced-barrier)" \
  && scripts/scope_select.sh "$PWD/tmp/adversary-006/sourced-barrier" --changed "$base"; \
  rc=$?; printf 'scope_select_rc=%s\n' "$rc"
SCOPED: не для приёмки
MODE: scoped
KEY: b
scope_select_rc=0
```

Это наблюдаемый недобор: `a` не попал в выборку. При этом приведённый выше полный прогон
`check_scope_select.sh` зелёный.

**Минимальный фикс:** при разборе допустимого диффа построить граф статических `source` среди
eligible-барьеров (в обоих концах); если изменённый файл является целью `source` другого
барьера, вернуть `MODE: full`. Любой динамический `source` — тоже `full`.

## Обход 2 — dynamic source сужается вместо полного прогона

**Вид:** 2 (та же дыра `check_scope_select.sh`, самостоятельный запрещённый вход).

**Нарушенный инвариант:** контракт §2 прямо требует полный откат при динамическом `source`.

Генератор `tmp/adversary-006/setup-dynamic-source.sh` создаёт барьер `b` с
`source "$plugin"`, затем меняет его только комментарием. Это не безопасная локальная правка:
цель source определяется во время запуска.

```console
$ base="$(tmp/adversary-006/setup-dynamic-source.sh tmp/adversary-006/dynamic-source)" \
  && scripts/scope_select.sh "$PWD/tmp/adversary-006/dynamic-source" --changed "$base"; \
  rc=$?; printf 'scope_select_rc=%s\n' "$rc"
SCOPED: не для приёмки
MODE: scoped
KEY: b
scope_select_rc=0
```

Ожидался `MODE: full`, но предмет сообщает зелёный scoped. Положительный контроль
`check_scope_select.sh` выше зелёный, значит его ветви не покрывают ни dynamic source, ни
граф source между барьерами.

**Минимальный фикс:** тот же анализ source: обнаружение любого source, аргумент которого не
является статическим относительным путём, должно немедленно делать выборку полной.

## Обход 3 — не-барьер принимается как явный ключ

**Вид:** 2 (дыра `check_scope_select.sh`).

**Нарушенный инвариант:** интерфейс контракта принимает `--scope <ключ>` как ключ **барьера**;
неизвестный ключ обязан получить код 1. Passive/support-файл не является барьером и не может
становиться scoped-ключом.

В созданном выше дереве добавлен `scripts/passive.sh` с единственной ролью
`# НЕ БАРЬЕР: support helper`.

```console
$ scripts/scope_select.sh "$PWD/tmp/adversary-006/dynamic-source" --scope passive; \
  rc=$?; printf 'scope_select_rc=%s\n' "$rc"
SCOPED: не для приёмки
MODE: scoped
KEY: passive
scope_select_rc=0
```

Это ложный успешный выбор несуществующего ключа барьера. Полный положительный контроль
`check_scope_select.sh` зелёный: его ветвь (а) проверяет только отсутствующий путь, не
существующий passive-файл.

**Минимальный фикс:** в ветви `--scope` проверять `header_role` и принимать ключ только при
роли ровно `b`; для case дополнительно требовать существующий case именно этого barrier key.
Добавить passive/support как негативную фикстуру ветви (а).

## Обход 4 — HOME общий между фикстурами

**Вид:** 2 (дыра `check_scoped_run.sh`).

**Нарушенный инвариант:** контракт §4 требует per-fixture изоляцию `HOME` (наряду с портами и
`TMPDIR`). Реальный раннер передаёт каждой фикстуре один и тот же `HOME=${HOME:-/tmp}` в
`ap_run`, поэтому состояние первой фикстуры определяет результат второй.

`tmp/adversary-006/setup-home-leak.sh` строит два честно объявленных барьера. На зелёном
вызове `a` записывает `$HOME/seed-from-a`; `b` краснеет на своём испорченном вызове только
если этот файл остался в HOME. При корректной per-fixture изоляции `b` остался бы зелёным и
его фикстура была бы отвергнута как «красное не предъявлено». Воспроизведение использует
собственный HOME под `tmp/`, так что внешний HOME не затрагивается:

```console
$ tmp/adversary-006/setup-home-leak.sh tmp/adversary-006/home-leak \
  && rm -rf tmp/adversary-006/shared-home \
  && mkdir -p tmp/adversary-006/shared-home \
  && HOME="$PWD/tmp/adversary-006/shared-home" \
       bash scripts/verify_antiplacebo.sh "$PWD/tmp/adversary-006/home-leak"; \
  rc=$?; printf 'verify_rc=%s; leaked_files=' "$rc"; \
  printf '%s ' tmp/adversary-006/shared-home/*; printf '\n'
  ok   a/case_a.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «a red»
  ok   b/case_b.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «home leaked between fixtures»

барьеров: 2 · фикстур: 2 · предъявлено красным повторным прогоном: 2
verify_rc=0; leaked_files=tmp/adversary-006/shared-home/seed-from-a
```

То есть runner объявляет весь toy зелёным именно потому, что состояние протекло между
фикстурами; `check_scoped_run.sh` остаётся зелёным (положительный контроль выше), поскольку
его toy не нейтрализует изоляцию HOME.

**Минимальный фикс:** создавать отдельный каталог HOME в `$d/work` (например
`$d/work/home`) и передавать `HOME=$d/work/home` через `env -i` для каждого запуска и повторного
запуска. Добавить двухфикстурный тест: первая оставляет HOME-маркер, вторая может покраснеть
только при его наличии; корректный runner обязан отклонить такую фикстуру.

## Атаки без найденного обхода

Положительный прогон барьеров выше исполняемо закрыл проверенные обязательные классы на их
имеющихся входах: ложный успех на нерезолвимой базе и пустом docs-only diff (г/д), отсутствие
`git` из PATH (л), константная/неверная выборка при изменении барьера и библиотеки (е/ж),
add/delete/rename/смена роли (з), пустой и неизвестный `--scope`/case (а/б/в), scoped и
needs-full маркеры (к), а также нейтрализацию классов отказа 1/2/необъявленного кода/записи
вне WORK и case-фильтр (тир-2 л, м1, м2, м3, н, case). Эти зелёные сценарии не закрывают
четыре предъявленные выше входа.

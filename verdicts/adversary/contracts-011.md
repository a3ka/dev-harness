FAIL

# Адверсарий — контракт 011, круг 1

Проверены предмет `contracts/011-prijomka-sudi-i-gigiiena-rannera.md`, реализация `scripts/verify_antiplacebo.sh`, все десять ветвей `scripts/check_runner_hygiene.sh`, `AGENTS.md` (раздел «Воркфлоу майлстоуна»), аннотация §Приёмка п.8 010, 28 case-файлов и оба прецедента формата. Это не суд конструкции 011 и не три объявленных cognitive-only остатка (`norma` Markdown-экзотика, наполненная приманка/третье место `scratchdef`, содержательность пачки A `porjadok`).

На исходном дереве обе предъявленные положительные проверки действительно зелёные:

```text
$ bash scripts/check_runner_hygiene.sh
… 10 ветвей зелены
$ bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
```

Следовательно, ниже не вечно-красные сценарии.

## Находка 1 — явный scratch внутри корня реально загрязняет стерегомое дерево

`verify_antiplacebo.sh` принимает непустой `VERIFY_ANTIPLACEBO_SCRATCH` буквально (`SCRATCH="${VERIFY_ANTIPLACEBO_SCRATCH:-}"`; затем `mkdir -p "$SCRATCH"`) и не канонизирует его, не сравнивает с каноническим `ROOT` и не отказывает при вложенности. Поэтому допустимое с точки зрения кода состояние

```text
VERIFY_ANTIPLACEBO_SCRATCH="$ROOT/tmp/antiplacebo"
```

направляет lock, `run-<pid>`, FIFO, журналы, окружение и рабочие файлы **в стерегомое дерево**. Это нарушает §Предмет Б.1: scratch обязан быть вне него «в любом режиме», включая явную переменную. После cleanup следов не остаётся, но предмет запрещает протекание и во время прогона.

**Воспроизведённый минимальный прогон.** В `/tmp/adversary-011-scratch-root` был создан обычный игрушечный барьер с честной fixture: зелёный вызов создаёт marker, красный его удаляет. Реальный исходный `scripts/verify_antiplacebo.sh` запускался на этом корне, а scratch был именно `/tmp/adversary-011-scratch-root/tmp/antiplacebo`.

```text
$ bash /tmp/adversary-011-scratch-probe.sh
during=run-3476123,run-3476123/check_a.case_a,run-3476123/check_a.case_a/barrier,
       run-3476123/check_a.case_a/case.out,run-3476123/check_a.case_a/env,
       run-3476123/check_a.case_a/req,run-3476123/check_a.case_a/resp,
       run-3476123/check_a.case_a/work,run-3476123/check_a.case_a/work/home,
       verify_antiplacebo-96988226.lock,
rc=0
after=
```

То есть это не предположение о пути: реальный раннер дал `0`, а независимый наблюдатель увидел его артефакты в `$ROOT/tmp/antiplacebo` во время работы. Ветви `scratch` и `scratchdef` всегда передают внешний `$WORK/s-*` либо внешний `$WORK/tmpdir-def`; они не подают явный scratch, разрешающийся внутри `T`. Поэтому полный `check_runner_hygiene` остаётся зелёным и дефект не наблюдает.

**Нужна правка implementer:** до любой чистки/захвата lock канонизировать существующий или созданный scratch (`pwd -P`), сравнить его с каноническим `ROOT` по границе пути и при `$SCRATCH = $ROOT` либо `$SCRATCH` внутри `$ROOT` отказать названной ошибкой. Для `scratch` нужна fixture, передающая `$T/tmp/antiplacebo` как явную переменную и наблюдающая рекурсивно; честный контроль должен остаться зелёным на внешнем scratch.

## Находка 2 — барьер принимает runner, который работает только на его известных игрушках

В отдельном клоне `/tmp/adversary-011-overfit-clone` исходный runner заменён обманкой следующей семантики:

```text
если $1 содержит scripts/check_a.sh и fixtures/check_a/case_a.sh:
    exec fixtures/check_runner_hygiene/_ref_runner.sh "$@"
иначе:
    напечатать «complete verification accepted» и exit 0
```

Это не исполняет предмет раннера на реальном дереве: не классифицирует барьеры, не запускает fixtures, не требует положительного контроля и не предъявляет повторный красный прогон. Однако все четыре исполняемые ветви `lock/race/scratch/scratchdef/chistka/pgid` барьера строят ровно эту предсказуемую форму игрушки (`build_toy`: один `check_a` и один `case_a`); остальные четыре ветви не запускают runner. Получился следующий ложнозелёный прогон против неизменённого барьера:

```text
$ bash scripts/check_runner_hygiene.sh /tmp/adversary-011-overfit-clone
… 10 ветвей зелены
check_runner_hygiene: ветви «all» зелены

$ bash /tmp/adversary-011-overfit-clone/scripts/verify_antiplacebo.sh --scope check_runner_hygiene
complete verification accepted
rc=0
```

Тем самым положительный контроль барьера честно проверяет эталонную дисциплину на toy-входе, но не отличает реальную реализацию от условной константы «для `check_a/case_a` — эталон, иначе успех». Это ровно класс зашитой константы вместо вычисления; один и тот же стаб также возвращает ложный успех на правильном, но не том входе.

**Нужна правка architect:** добавить независимую форму исполняемого входа, не сводимую к `build_toy` (другие ключ и case-имя, как минимум два барьера/case), и/или поведенческую ветвь, запускающую runner над непредсказуемо сгенерированным составом барьеров и fixtures и проверяющую фактический счёт/повтор. Новый стаб обязан краснеть именно там; эталонный `_ref_runner.sh` — оставаться зелёным.

## Проверенные, но пойманные классы

* **Отказ, выглядящий успехом / инструмент мимо PATH:** `PATH=/nonexistent /usr/bin/bash scripts/check_runner_hygiene.sh` завершился `NOT_IMPLEMENTED` и rc=2, не `0`; отсутствие `dirname` привело к названному отсутствию предмета. Оно не объявляется успехом.
* **Пустой вход:** реальный runner на дереве с одним объявленным `check_empty.sh` и нулём `fixtures/check_empty/case_*.sh` дал rc=1: `FAIL check_empty.sh: нет фикстур`; счёт `0/0` не был принят.
* **Нейтрализация:** scoped-регресс реально предъявил все 28 отдельных нейтрализаций красными повторными запусками, включая отказ 3/«занят», реальную race с пустым окном, in-tree scratch с trap, stale/live lock, decoy по имени, норму, аннотацию и порядок истории.
* **Реальные параллельные прогоны, формат lock, live чужой lock и name-decoy:** они также были зелены на полном положительном контроле `check_runner_hygiene.sh`; это не отдельные обходы.

## Рекомендация

Не передавать пачку ревьюеру. Implementer должен закрыть находку 1, architect — усилить барьер против находки 2, после чего нужны новые красные fixture-прогоны, полный `check_runner_hygiene.sh`, scoped `verify_antiplacebo --scope check_runner_hygiene` и новый круг адверсария.

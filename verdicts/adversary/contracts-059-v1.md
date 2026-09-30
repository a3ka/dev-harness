FAIL

# Адверсарий — контракт 059, круг к1

Детектор перед спавном: bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness → rc 0, «основной чекаут чист» (2026-09-30, CI зелёный 6/6 по 3130528).

## Область и базовые барьеры

Предмет: `contracts/059-sverka-objavlennyh-putej-profylja-s-derevom.md`,
реализация `scripts/profile_resolver.sh`, живая проводка `workshop`, батарея
`fixtures/_krasnye_059.sh` / `fixtures/workshop_project/red_sverka_puti_profylja.sh`.

- `bash fixtures/_krasnye_059.sh` — **rc 0**: стаб-пак 9/9, диффпроба 0 ошибок,
  честные 12/12.
- `bash scripts/check_contract_frozen.sh` — **rc 0**; для 059 сообщено:
  `заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают`.
- Прямой CI-шаг `.github/workflows/ci.yml` запускает именно
  `bash fixtures/_krasnye_059.sh`. Поэтому ниже приведённые зелёные прогоны
  батареи являются обходами подключённого guard-канала; полный CI по правилу
  приёмки не запускался.

## FINDING A — допустимый внутренний компонент `..` не защищён от сужения грамматики

И-2 допускает относительный путь, который после канонизации существует и
лежит внутри `REPO_ABS`; он не запрещает компонент `..`. Честный минимальный
контроль подтвердил корректное поведение:

```sh
bash tmp/adversary059k1/valid-path-probe.sh scripts/profile_resolver.sh dotdot
# kind=dotdot rc=0 stdout=nonempty workflow=ci/../ci.yml stderr_lines=0
```

Собранный мутант `tmp/adversary059k1/reject-dotdot-resolver.sh` сперва
делегирует реальному резолверу, но на успешном `ci/../ci.yml` возвращает rc 1
и пустой stdout. Он действительно ломает годную ветку:

```sh
bash tmp/adversary059k1/valid-path-probe.sh \
  tmp/adversary059k1/reject-dotdot-resolver.sh dotdot
# kind=dotdot rc=1 stdout=empty workflow='' stderr_lines=1
```

Но батарея его принимает:

```sh
PROFILE_RESOLVER="$PWD/tmp/adversary059k1/reject-dotdot-resolver.sh" \
  bash fixtures/_krasnye_059.sh
# rc=0; стаб-пак 9/9, честные 12/12
```

Нужна отдельная положительная клетка: существующий регулярный файл по
`ci/../ci.yml` (либо иной относительный путь с внутренним `..`) обязан
вернуть rc 0 и дословно сохранить значение в merged.

## FINDING B — Unicode и кавычки не защищены от сужения представления пути

`ci.workflow` проходит 054 как непустая JSON-строка; 059 требует только
относительность, канонизацию, принадлежность дереву и регулярный файл.
Следовательно `ci/ü.yml` и `ci/'quoted'.yml` — корректные имена POSIX/JSON,
если соответствующие файлы существуют. Честные положительные контроли:

```sh
bash tmp/adversary059k1/valid-path-probe.sh scripts/profile_resolver.sh unicode
# kind=unicode rc=0 stdout=nonempty workflow=ci/ü.yml stderr_lines=0
bash tmp/adversary059k1/valid-path-probe.sh scripts/profile_resolver.sh quote
# kind=quote rc=0 stdout=nonempty workflow=ci/\'quoted\'.yml stderr_lines=0
```

Мутант `tmp/adversary059k1/ascii-unquoted-resolver.sh` делегирует честной
реализации, но после успешной проверки отвергает `ü` и `'`. Он ломает обе
годные ветки:

```sh
bash tmp/adversary059k1/valid-path-probe.sh \
  tmp/adversary059k1/ascii-unquoted-resolver.sh unicode
# kind=unicode rc=1 stdout=empty workflow='' stderr_lines=1
bash tmp/adversary059k1/valid-path-probe.sh \
  tmp/adversary059k1/ascii-unquoted-resolver.sh quote
# kind=quote rc=1 stdout=empty workflow='' stderr_lines=1
```

И всё же батарея зелёная:

```sh
PROFILE_RESOLVER="$PWD/tmp/adversary059k1/ascii-unquoted-resolver.sh" \
  bash fixtures/_krasnye_059.sh
# rc=0; стаб-пак 9/9, честные 12/12
```

Нужны две положительные клетки с реальными файлами: Unicode-компонент и
символ кавычки; каждая должна требовать rc 0, непустой stdout и точное
значение `.ci.value.workflow`.

## FINDING C — внутренний symlink не отличим от запрещающего его мутанта

Граница-3 запрещает симлинк **наружу**, а И-2 разрешает путь, чья
каноническая цель — существующий регулярный файл внутри репо. Следовательно
внутренний `ci/link.yml -> real.yml` корректен. Позитивный контроль:

```sh
bash tmp/adversary059k1/valid-path-probe.sh scripts/profile_resolver.sh symlink
# kind=symlink rc=0 stdout=nonempty workflow=ci/link.yml stderr_lines=0
```

Мутант `tmp/adversary059k1/reject-symlink-resolver.sh` делегирует живому
резолверу, но отвергает любой успешный путь, который сам является симлинком.
Он ломает корректную ветку:

```sh
bash tmp/adversary059k1/valid-path-probe.sh \
  tmp/adversary059k1/reject-symlink-resolver.sh symlink
# kind=symlink rc=1 stdout=empty workflow='' stderr_lines=1
```

Батарея мутант пропускает:

```sh
PROFILE_RESOLVER="$PWD/tmp/adversary059k1/reject-symlink-resolver.sh" \
  bash fixtures/_krasnye_059.sh
# rc=0; стаб-пак 9/9, честные 12/12
```

Нужна положительная клетка для симлинка внутри `REPO_ABS` на регулярный файл
внутри `REPO_ABS`; отрицательная к6 уже покрывает только внешнюю цель.

## FINDING D — И-5 проверен только для `--probe`, live можно нейтрализовать

к9 проверяет отказ в `workshop --probe`, но нет зеркального живого запуска
с тем же некорректным `ci.workflow`. Мутант
`tmp/adversary059k1/probe-only-workshop.sh` делегирует только `--probe`
настоящему `workshop`, а live безусловно завершает rc 0. Поэтому его принимает
вся батарея:

```sh
WORKSHOP="$PWD/tmp/adversary059k1/probe-only-workshop.sh" \
  bash fixtures/_krasnye_059.sh
# rc=0; стаб-пак 9/9, честные 12/12
```

Тот же минимальный git-проект с `.env`, пином, fake `omp/v1` и отсутствующим
`missing.yml` показывает честный live-контроль и обход:

```sh
bash tmp/adversary059k1/live-invalid-workflow-probe.sh workshop reject
# rc=1 stdout=nonempty ci_diagnostic=1
bash tmp/adversary059k1/live-invalid-workflow-probe.sh \
  tmp/adversary059k1/probe-only-workshop.sh accept
# rc=0 stdout=empty ci_diagnostic=0
```

Нужна живая клетка (не `--probe`) с подготовленными предпосылками workshop,
некорректным объявленным путём и требованием rc 1 + P-фразы `ci.workflow`.

## FINDING E — проверка не требует ровно одну P-строку stderr

И-3 требует одну строку stderr. Мутант
`tmp/adversary059k1/extra-stderr-resolver.sh` сохраняет код, пустой stdout и
правильную P-фразу, но добавляет вторую диагностическую строку к каждому
отказу. Он пропускается:

```sh
PROFILE_RESOLVER="$PWD/tmp/adversary059k1/extra-stderr-resolver.sh" \
  bash fixtures/_krasnye_059.sh
# rc=0; стаб-пак 9/9, честные 12/12
```

Форма отказа измерена отдельно:

```sh
bash tmp/adversary059k1/rejection-shape-probe.sh scripts/profile_resolver.sh 1
# rc=1 stdout=empty stderr_lines=1
bash tmp/adversary059k1/rejection-shape-probe.sh \
  tmp/adversary059k1/extra-stderr-resolver.sh 2
# rc=1 stdout=empty stderr_lines=2
```

Нужна проверка полного stderr (либо количества строк ровно 1 и точного
литерала И-3) для каждого класса отказа, а не только `grep -F` ожидаемой
подстроки.

## Вердикт

FAIL: пять обманных реализаций, нарушающих И-2, И-3 или И-5, проходят
scoped-батарею и, по прямой CI-проводке, guard-канал 059. Предмет и проверка
не исправлялись; временные мутанты и пробы находятся только в
`tmp/adversary059k1/` и не добавляются в коммит.

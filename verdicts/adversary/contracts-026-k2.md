FAIL

# Адверсарий контракта 026, круг k2 — TMP-РЕАП

Судимый предмет: свежий `origin`-клон, HEAD `c7d7a4d21130`; судилась только
реализация TMP-РЕАП в `scripts/gc_agent_branches.sh`. Предмет и проверки не
изменялись. Игрушечные репозитории, подставные `git` и `base64`, а также
временные harness-файлы жили вне клона.

## Позитивный контроль

Все семь обязательных проб завершились `rc=0`:

```text
bash fixtures/gc_agent_branches/red_zhnets_reap_stale.sh
bash fixtures/gc_agent_branches/red_zhnets_aktiv_vyzhivaet.sh
bash fixtures/gc_agent_branches/red_zhnets_tracked_netrogat.sh
bash fixtures/gc_agent_branches/red_regress_024_noga2.sh
bash fixtures/gc_agent_branches/case_zhnets_reapstale.sh
bash fixtures/gc_agent_branches/case_zhnets_aktiv_vyzhivaet.sh
bash fixtures/gc_agent_branches/case_zhnets_tracked_netrogat.sh
```

`bash scripts/verify_antiplacebo.sh --scope gc_agent_branches` также дал
`rc=0`: 5/5 fixture получили зелёный контроль и повторный именованный красный.
Следовательно, вывод ниже не является вечно-красной или неисполняемой
проверкой.

## Пять фиксов k1 повторены

1. Анонимный `tmp/boundary-anon/` с `mtime = 7d+1s` при пороге 7 суток
   удалён (`rc=0`). Граница возраста исправлена.
2. Старый `tmp/x0026/` при живом `contracts/026-*.md` и без done-тега 026
   пережил apply (`rc=0`). Перекрывающийся NNN распознан.
3. Done-запись `tmp/$'old\n021'/` удалена (`rc=0`). Внутренний LF больше не
   дробит кандидатный список.
4. Подставной `git`, возвращающий 1 только для `git -C <toy> ls-files
   --others -z -- tmp/`, дал именованный `rc=2`; запись осталась. Отказ источника
   untracked не превращён в пустой успешный список.
5. При `--tmp-reap-age 1` запись возраста 2d удалена (`rc=0`). Порог берётся из
   аргумента, а не из зашитого default 7.

## Новые атаки

### Реальный обход: base64-транспорт не сохраняет идентичность имени с хвостовым LF

Base64 исключил LF из *промежуточной записи*, но не из следующего преобразования:

```bash
entry="$(printf '%s' "$b64_rel" | base64 -d 2>/dev/null)"
```

Bash удаляет все завершающие LF из command substitution. Поэтому разные допустимые
имена `tmp/done021` и `tmp/$'done021\n'` после decode дают одно и то же значение
`entry=tmp/done021`. Это коллизия транспорта пути, а не просто форматирование
вывода.

В toy с done-тегом `done/contracts/021/1` создана свежая запись
`tmp/$'done021\n'/`. Done-правило обязано реапнуть её независимо от возраста.
`--tmp-reap-apply` вернул `rc=0`, напечатал ложный путь `TMP-РЕАП: tmp/done021
done 021`, однако исходная запись с LF **осталась** (`exists=yes`). `rm -rf` по
усечённому несуществующему пути вернул 0, поэтому это молчаливый обход и ложный
успех удаления.

### Реальный обход: отказ источника done-тегов маскируется как пустой done-набор

Подставной `git` делегировал все команды настоящему git, кроме
`git -C <toy> for-each-ref ... refs/tags/done/contracts/`, для которого возвращал
1. Свежая `tmp/fresh021/` обязана удаляться по существующему done-тегу 021, но
apply вернул `rc=0`, `TMP-РЕАП кандидатов 0`, а запись осталась. Ветка

```bash
if g for-each-ref ...; then
    ...
fi
```

не имеет fail-closed `else`: невозможность прочитать необходимый источник
квалификации выглядит как «done-тегов нет». Это нарушает done-инвариант и код
«нечем проверить».

## Прочие исполненные атаки

- `tmp/x025026/` при живом 025 и done 026 пережил apply (`rc=0`): приоритет
  активного номера над done держится и для перекрывающихся NNN.
- Анонимная запись с future `mtime` пережила обычный порог 7d (`rc=0`):
  отрицательный `age_seconds` не стал ложным кандидатом.
- Параметр возраста принимает некорректные значения без отказа:
  - `--tmp-reap-age NaN`: аноним 10d остался, `rc=0`;
  - `--tmp-reap-age inf`: аноним 10d остался, `rc=0`;
  - `--tmp-reap-age -1`: свежая запись 1h удалена, `rc=0`.
  Нечисловое значение корректно обрабатывается только если `float()` выбрасывает
  `ValueError`; `NaN`, infinity и отрицательное число проходят. Для аргумента
  «N дней» они не являются допустимым конечным неотрицательным порогом. Это
  отдельная ошибка валидации, помимо двух воспроизведённых обходов выше.
- Подставной `base64`, завершающийся `127`, дал самому gc `rc=127` без
  `NOT_IMPLEMENTED`, хотя decode пути необходим для квалификации/удаления.
  Инструмент не проверяется заранее и не нормализуется к объявленному `rc=2`.

## Вердикт

`FAIL`: два независимых контрпримера воспроизведены на настоящем предмете.
Первый позволяет done-кандидату с допустимым POSIX-именем пережить apply при
ложном `rc=0`; второй позволяет отказом источника done-тегов превратить
обязательный done-реап в успешное бездействие. Положительный контроль и все
семь предъявлений зелёные, поэтому дефекты находятся в реализации/покрытии,
а не в неисполняемой проверке.

check_no_leak --check /tmp/adversary026-k2: rc=0

СТЕНГРАММА: fresh origin clone HEAD=c7d7a4d21130; 7 direct probes rc=0; scoped gc_agent_branches rc=0 (5/5); k1 age-boundary rc=0 deleted; k1 x0026 active survives; k1 embedded-LF done removed; k1 ls-files stub named rc=2 preserved; k1 --tmp-reap-age 1 reaped 2d; overlap x025026 active025+done026 survives; future mtime survives; base64 terminal-LF done bypass reproduced rc=0 with original entry remaining; done-ref source failure bypass reproduced rc=0 with fresh done entry remaining; NaN/inf accepted and negative age over-reaps; base64 stub rc=127; check_no_leak --check /tmp/adversary026-k2: rc=0.

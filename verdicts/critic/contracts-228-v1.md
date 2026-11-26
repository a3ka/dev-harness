accept
OBJECT=4f2fb415559c9ddb64108f1e90623f3351c8886b
СУД: репо=dev-harness; предмет=228; фаза=контракт; роль=critic; вызов=3 (узкий, по дельте Architect228e; санкция задания на OBJECT); сессия=c907157c/Crit228c; модель-факт=openai-codex/gpt-6.1-terra; автор Architect228e — openai-codex/gpt-6.1-sol. `models_actual.sh --tsv --bind --session` для каждой сессии дал allowed; отдельные сессии и разные авторы коммитов. Вызовы 1 и 2: FAIL 1af3cd3c9 и f60f16ef5; арбитражей нет согласно заданию.

# Узкий суд 228/3

Основание поиска — изменённые CLI-клетки буквального сравнения actor (`contracts/228-sh3-owner-overrides.md:44,66`, `fixtures/workshop_project/owner_overrides_228/probe.py:443-517`), закрытие блока вызова 2 и соседние изменения этой же операции. Историческая граница и остальные блоки ранее признаны, заново не судились. `git diff --numstat f60f16ef5 4f2fb415559c9ddb64108f1e90623f3351c8886b`: probe.py 87 добавлений, 0 удалений. Пять адресных стабов внесены в `stabs/mutations.json:41-45`; положительные равные имена и `*` проверяются в настоящих CLI вместе с отрицательным no-grant контролем.

Предыдущий блок К-08/К-14 закрыт: три воспроизведённых мутанта и два соседних мутанта автора красны полным --model. Из пяти дополнительных атак суффикс, длина и первые три символа красны; сортировка символов и strip остаются зелёными. Для сортировки нет документированного источника такого ошибочного механизма, а допустимость анаграммы по грамматике сама по себе не основание блока по §Порог. Strip на допустимых именах без пробелов эквивалентен буквальному сравнению. Эти результаты не выдаются за доказательство полной различимости произвольных специально добавленных ошибок.

СОВЕТ contracts/228-sh3-owner-overrides.md:44 — при желании добавить сравнение переставленных символов (`fixture` против другого имени с теми же буквами), поскольку специально введённое `sorted(actor) != sorted(author)` прошло батарею. Источника такой ошибки в существующей операции либо документированного дефекта не обнаружено; оснований для блока по §Порог нет.

## Карта классов

К-01: чисто — check_sdacha --run rc 0, дельта=2
К-02: без изменений с вызова 2
К-03: без изменений с вызова 2
К-04: без изменений с вызова 2
К-05: без изменений с вызова 2
К-06: без изменений с вызова 2
К-07: чисто — настоящие Git/CLI-миры probe.py:486-517 и честный --model
К-08: чисто — пять адресных мутаций красны полным --model, --stabs предъявляет каждую связь
К-09: без изменений с вызова 2
К-10: чисто — probe.py:508-517 проверяет rc и отказ конкретного автора/SHA/пути
К-11: без изменений с вызова 2
К-12: без изменений с вызова 2
К-13: без изменений с вызова 2
К-14: чисто — равные actor и wildcard в тех же CLI-мирах зелёны на честном --model
К-15: чисто — source.json 124/44/104, вывод --model и --stabs
К-16: без изменений с вызова 2
К-17: без изменений с вызова 2

## Мутации: команда и сырой итог

Одноразовый клон на OBJECT внутри копии судьи. В `fixtures/workshop_project/owner_overrides_228/model/lib_owner.sh:92` заменялось одно вхождение `actor != author:` на выражение ниже, каждое отдельно; после каждого запускалась `bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --model`, по завершении файл восстановлен. Программа запуска — `python3 "$PWD/tmp/attacks.py"`; её сырой вывод итогов:

```text
=== critic-prefix === rc= 1
KLETKI=124 ZELENYE=121 KRASNYE=3
=== critic-lower === rc= 1
KLETKI=124 ZELENYE=116 KRASNYE=8
=== critic-substring === rc= 1
KLETKI=124 ZELENYE=115 KRASNYE=9
=== author-separators === rc= 1
KLETKI=124 ZELENYE=112 KRASNYE=12
=== author-first === rc= 1
KLETKI=124 ZELENYE=114 KRASNYE=10
=== own-suffix === rc= 1
KLETKI=124 ZELENYE=121 KRASNYE=3
=== own-strip === rc= 0
KLETKI=124 ZELENYE=124 KRASNYE=0
=== own-length === rc= 1
KLETKI=124 ZELENYE=110 KRASNYE=14
=== own-first-three === rc= 1
KLETKI=124 ZELENYE=99 KRASNYE=25
=== own-sorted === rc= 0
KLETKI=124 ZELENYE=124 KRASNYE=0
```

Выражения по порядку: `not author.startswith(actor)`, `actor.lower() != author.lower()`, `actor not in author`, `re.sub(r'[._-]', '', actor) != re.sub(r'[._-]', '', author)`, `re.split(r'[.-]', actor, maxsplit=1)[0] != re.split(r'[.-]', author, maxsplit=1)[0]`, `not author.endswith(actor)`, `actor.strip() != author.strip()`, `len(actor) != len(author)`, `actor[:3] != author[:3]`, `sorted(actor) != sorted(author)`. Полные выводы хранятся в scratch судьи `tmp/attack-*.log`; приведены дословные финальные строки и rc каждого полного запуска.

## Двери

`SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/228-sh3-owner-overrides.md --run`, rc 0:
```text
СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)
```
W = `bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh`; независимые прогоны W --model, W --stabs, W --repo "$PWD", затем precision и pre_critic. Сырой итог:
```text
KLETKI=124 ZELENYE=124 KRASNYE=0
HISTORICAL_SNAPSHOT complete=false REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312 MISMATCHES=0
MODEL_RC=0
STABS=44 BINDINGS=104 ZHIVYH=0
SNAPSHOT_CELLS=9 SNAPSHOT_STABS=6 ZHIVYH=0
HISTORICAL_STABS=4 BINDINGS=4 ZHIVYH=0
STABS_RC=0
KLETKI=124 ZELENYE=48 KRASNYE=76
REPO_RC=1
OK
PRECISION_RC=0
КРИТИК: дверь зелёная
PRE_CRITIC_RC=0
```
`--repo` красен до реализации: отсутствует OWNER_INTERFACE, старые SHA ещё в дверях. `KRASNO snapshot` в --model/--stabs — отрицательный контроль, итог MISMATCHES=0. Полный вывод прогонов — artifact://12315 в сессии суда.

accept

СУД: repo=dev-harness; предмет=154; фаза=узкий по строке приёмки; роль=critic; вызов=7/2; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit154V7; модель-факт=openai-codex/gpt-6.1-terra; SHA=5619d95d0ecef525980441661763e874c6c5625e; предыдущее=verdicts/critic/contracts-154-v1e-fail.md; исключение=слово владельца 17:21 UTC 19.11.2026. Фактическая модель и OBJECT: `bash scripts/models_actual.sh --tsv --bind --session Crit154V7` rc 0, две строки `critic openai-codex/gpt-6.1-terra allowed Crit154V7 5619d95d0ecef525980441661763e874c6c5625e`. Автор OBJECT — architect, судья — critic.

Найден более поздний предыдущий вердикт Crit154V6: `archive/154/crit154v6-verdict`, коммит `b961665f2ecca1f6a338f2777810e151223ec205`, файл `verdicts/critic/contracts-154-v1.md`, accept по узкому исполнению решения Arb154V1, OBJECT `3e1a01ee8e0115510153430834921c8f8279c308`. Ссылка на v1e в задании сохранена в строке СУД; этот accept не переносится на новую семантическую дельту. Область настоящего суда — только строка приёмки семьи 140 и дельта `992cb7f4286302a7a4cf2fbe5cb283d3bc9e4790`, зависимый регресс. Основание нового поиска — замена фиксированного исторического результата сравнением с независимой базой main по слову владельца; остальные поверхности повторно не исследовались.

## Проверки

`bash scripts/check_sdacha.sh "$PWD" contracts/154-schet-vyzovov-kritika.md --run` rc 0: `СДАЧА: лист зелёный (двери=9 карта=17/17 дельта=0)`.

`bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --family140-stabs` rc 0:
```
GREEN family140-identical
STAB_CAUGHT family140-changed-set: FAMILY140_RESULT_CHANGED
STAB_CAUGHT family140-changed-rc: FAMILY140_RESULT_CHANGED
STAB_CAUGHT family140-unreadable: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-truncated: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-missing-case: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-wrong-summary: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-unknown-case: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-conflicting-case: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-inconsistent-rc: FAMILY140_MEASUREMENT_UNKNOWN
```

В изолированном клоне изначально не было origin: первый `W --family140` rc 1, `FAMILY140_MEASUREMENT_UNKNOWN: command rc=128: ['bash', '<корень>/scripts/gitw', 'ls-remote']`; прямой `bash scripts/gitw ls-remote --exit-code origin refs/heads/main` rc 128: `fatal: 'origin' does not appear to be a git repository`. После `git remote add origin ssh://git@github.com/a3ka/dev-harness.git` единственный повтор `W --family140` rc 0:
```
FAMILY140_BASE=6bdf74f2f32c8f6ad2808d5fc0f5db0ad41083e3 rc=1 red=b07-paket-izolirovan-otkat,b08-paket-fakt-kazhdogo-itema,s45-sudja-izolirovan-ne-trebuetsja,s46-sudja-start-fakt-istina,s47-sudja-start-fakt-lozh,w26-rabochij-bez-isolated,w27-rabochij-isolated-lozh,w28-rabochij-isolated-slovo-v-tekste,w29-rabochij-isolated-stroka,w30-rabochij-start-s-faktom
FAMILY140_CANDIDATE rc=1 red=b07-paket-izolirovan-otkat,b08-paket-fakt-kazhdogo-itema,s45-sudja-izolirovan-ne-trebuetsja,s46-sudja-start-fakt-istina,s47-sudja-start-fakt-lozh,w26-rabochij-bez-isolated,w27-rabochij-isolated-lozh,w28-rabochij-isolated-slovo-v-tekste,w29-rabochij-isolated-stroka,w30-rabochij-start-s-faktom
GREEN family140-baseline
```
Это сравнение предреализационного OBJECT, не утверждение о приёмке после реализации.

## Свои мутации дельты

Замена сравнения полного множества красных клеток на сравнение только их числа (патч в памяти; вызов не менял файлы):
```
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c 'import family140 as f; original=f.difference; f.difference=lambda a,b: "FAMILY140_RESULT_CHANGED" if (a[0],len(a[1])) != (b[0],len(b[1])) else ""; print("MUTATION compare-red-count-instead-of-set"); f.controls()'
```
rc 1, сырой вывод:
```
MUTATION compare-red-count-instead-of-set
GREEN family140-identical
Traceback (most recent call last):
  File "<string>", line 1, in <module>
  File "/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t51018caa9/m/fixtures/workshop_project/schet_vyzovov_154/family140.py", line 128, in controls
    raise RuntimeError(f'STAB_SURVIVED family140-{name}')
RuntimeError: STAB_SURVIVED family140-changed-set
```
Ненулевой исход ловит подмену множества при неизменном числе; честный результат остаётся зелёным.

Замена сравнения пары на сравнение только множества:
```
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c 'import family140 as f; f.difference=lambda a,b: "FAMILY140_RESULT_CHANGED" if a[1] != b[1] else ""; print("MUTATION compare-only-red-set"); print("equal-red-distinct-rc:",repr(f.difference((1,frozenset(("a",))),(0,frozenset(("a",)))))); f.controls()'
```
rc 0, сырой вывод:
```
MUTATION compare-only-red-set
equal-red-distinct-rc: ''
GREEN family140-identical
STAB_CAUGHT family140-changed-set: FAMILY140_RESULT_CHANGED
STAB_CAUGHT family140-changed-rc: FAMILY140_RESULT_CHANGED
STAB_CAUGHT family140-unreadable: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-truncated: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-missing-case: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-wrong-summary: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-unknown-case: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-conflicting-case: FAMILY140_MEASUREMENT_UNKNOWN
STAB_CAUGHT family140-inconsistent-rc: FAMILY140_MEASUREMENT_UNKNOWN
```
На синтетической паре эта мутация неразличима, но `measurement` требует `rc == int(bool(red))`, поэтому пара с тем же множеством и другим допустимым rc через существующий механизм не проходит: `family140-inconsistent-rc` пойман. Источник достижимого входа с иным согласованным rc не предъявлен; зелёная синтетическая мутация сама по себе не блок.

## Карта классов

К-01: чисто — `check_sdacha.sh ... --run` rc 0, 9 дверей, карта 17/17.
К-02: чисто — вход: слово владельца 17:21 и contracts/154-schet-vyzovov-kritika.md:63, сравнение с main вместо исторического набора.
К-03: чисто — вход: адресное разрешение изменения frozen-критерия и фактическое сравнение семьи 140 выше.
К-04: чисто — без изменений с вызова 6 — дельта в зоне architect.
К-05: чисто — вход: contracts/154-schet-vyzovov-kritika.md:63, `W --family140` и `W --family140-stabs`, rc 0.
К-06: чисто — вход: строка 63 явно задаёт rc 1 для неизвестного замера; отсутствие origin вызвало именованный отказ, не зелёный результат.
К-07: чисто — `W --family140` rc 0 на текущих кандидатe и main после исправления отсутствующего origin в своей копии.
К-08: чисто — мутация сравнения числа вместо множества выше обнаружена; одинаковый результат зелёный.
К-09: чисто — вход: family140.py `measurement`, множество имён берётся из main source.json, неполное предъявление даёт отказ.
К-10: чисто — вход: family140.py `run_family` исполняет реальную батарею на обеих копиях и сопоставляет rc и множество.
К-11: чисто — вход: family140.py `compare_main`, базовый архив строится из commit main и результат замеряется до кандидата.
К-12: н/п — без изменений с вызова 6 — дельта не вводит новую проверку формата receipt.
К-13: н/п — без изменений с вызова 6 — дельта не вводит обработку секретов.
К-14: чисто — `W --family140-stabs` rc 0, равный набор при другом порядке и деталях принят.
К-15: чисто — сырое сравнение выше: rc 1, 10 одинаковых красных имён на обеих сторонах.
К-16: чисто — без изменений с вызова 6 — риск деньги и модель угроз не менялись.
К-17: н/п — без изменений с вызова 6 — проектная модель 187а не включена.

Вердикт относится только к предъявленному OBJECT и указанной строке; freeze, реализация и потребительская приёмка после реализации не выполнены.

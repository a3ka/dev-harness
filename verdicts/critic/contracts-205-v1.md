accept
OBJECT=8f72a40cb43cd751e68ee2d2797d5bb6696384ec

СУД: repo=dev-harness; предмет=205; роль=critic; вызов=4/4 (форма карты классов; слово владельца 22.11 ~19:20); фаза=v1; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit205V4; модель-факт=openai-codex/gpt-6.1-terra (контекст запуска, сверка трассы оркестратором); SHA=8f72a40cb43cd751e68ee2d2797d5bb6696384ec; предыдущий=вызов 3 accept Crit205V3 48b91afa44 (verdicts/critic/contracts-205-v3.md, ветка wip/205/critic-v3), суждение не меняется; класс риска=обычный.

Предмет вызова — только форма карты классов по санкции владельца. Суждение вызова 3 не меняется: блоков нет. Автор OBJECT — architect, судья — critic. Сверка фактической модели по трассе до материализации остаётся за оркестратором. `git diff 22f33389b9 8f72a40cb4` показывает только изменение SDACHA.md: снята машинная ссылка на прежний вердикт и скорректировано пояснение; контракт, клетки, стабы и probe не менялись.

## Закрытие К-01 вызова 2

`fixtures/workshop_project/provodka_gate_205/stabs.tsv:17` и `probe.py:295`: substring, регистр, LF, лишняя строка, strip-relative/strip-dotdot; `stabs.tsv:27` и `probe.py:312`: ANY-FIELD, IGNORE-ERRORS, GATE-FIRST, OMIT-SUFFIX. Дополнительные исполненные мутации v2 представлены STRIP-VYVODA, DIE-ECHO, STDOUT-STDERR-RAZDEL, LF-V-KONCE. Попытка v1 ignore-guard-existence с нулевым якорем не была исполненной мутацией; дополнительно есть OTSUTSTVIE-GUARD. Для каждой привязки честная модель проверяется отдельно; поимка требует отличия от честного результата и равенства точному ожидаемому кортежу rc и полного вывода (`probe.py:407-423`). Эквивалентные strip-relative/strip-dotdot сохранены как EKVIVALENT: правило суффикса принимает такие токены и без мутации. Состав проверен по stabs.tsv и словарям модели, якоря — при `--stabs`.

## Собственные соседние мутации вызова 3

СОВЕТ fixtures/workshop_project/provodka_gate_205/probe.py:295 — перенести следующие пойманные мутации в адресные стабы; детали в `.review/2026-11-22-144.md`. Ниже — результаты вызова 3, не новые атаки вызова 4. Замены сделаны только в одноразовых копиях модели, по якорям кратности 1; изменения исходных файлов не производились. Команда вызова 3 `TMPDIR="$PWD/.scratch-crit205v3" python3 "$PWD/.scratch-crit205v3/attacks.py"` (одноразовый скрипт удалён после проверки), rc 0. Сырой вывод вызова 3:
```
ATTACK drop-equality ANCHOR 1
CELL {"name": "a1-gate-profilja", "rc": 1, "expected": 0, "matched": false, "output": "проводка: guard не подключён: scripts/red_gate_205.sh не вызывается в .githooks/ или .github/workflows/\n"}
KLETKI=1 ZELENYE=0 KRASNYE=1
ATTACK_RESULT drop-equality rc 1 mismatches a1-gate-profilja
ATTACK drop-last-argv ANCHOR 1
CELL {"name": "a5-gate-py", "rc": 1, "expected": 0, "matched": false, "output": "проводка: guard не подключён: tools/check_source_trace.py не вызывается в .githooks/ или .github/workflows/\n"}
KLETKI=1 ZELENYE=0 KRASNYE=1
ATTACK_RESULT drop-last-argv rc 1 mismatches a5-gate-py
ATTACK lose-reason ANCHOR 1
CELL {"name": "e3-kanon-vne-alfavita", "rc": 1, "expected": 1, "matched": false, "output": "проводка: профиль проекта не распознан: ошибка\n"}
KLETKI=1 ZELENYE=0 KRASNYE=1
ATTACK_RESULT lose-reason rc 1 mismatches e3-kanon-vne-alfavita
ATTACK_SCRIPT_RC=0
```
Замены: `ANCH_EQUAL` → `:`; в `ANCH_JQ` `gate[]?` → `gate[:-1][]?`; `prof_reason="${prof_reason#profile ОТКАЗ: }"` → `prof_reason="ошибка"` соответственно. Н-39: привязки стабов к ветвям определяет architect по коду, не проза контракта.

## Карта классов

К-01: чисто — fixtures/workshop_project/provodka_gate_205/stabs.tsv:17 и :27 содержат адресные мутации прежних вердиктов, --stabs проверяет привязки.
К-02: чисто — contracts/205-provodka-gate-profilja.md разделы «Боль и обещание» и «Существующее», источники 038/994/996.
К-03: чисто — fixtures/check_provodka/external_ci_994/probe.sh, регресс замороженной семьи 994.
К-04: чисто — contracts/205-provodka-gate-profilja.md раздел «Зоны и проводка», зоны architect, implementer и orchestrator.
К-05: чисто — contracts/205-provodka-gate-profilja.md раздел «Приёмка», команды и ожидаемые rc.
К-06: чисто — contracts/205-provodka-gate-profilja.md раздел «Модель угроз», отсутствие субъекта и пустая выборка дают rc 2.
К-07: чисто — --model и честные контроли --stabs, клетки a1–a5 и a6b.
К-08: чисто — --stabs и соседние мутации вызова 3 drop-equality, drop-last-argv, lose-reason.
К-09: чисто — --stabs, LF-GRANITSY и клетки a6/a6c с честным соседом a6b.
К-10: чисто — fixtures/workshop_project/provodka_gate_205/probe.py:407-423, точное сравнение rc и полного вывода.
К-11: чисто — contracts/205-provodka-gate-profilja.md раздел «Приёмка», литеральные ожидания до вызова субъекта.
К-12: чисто — contracts/205-provodka-gate-profilja.md раздел «Frontier», единственный резолвер scripts/profile_resolver.sh.
К-13: н/п — предмет не обрабатывает секреты.
К-14: чисто — --stabs проверяет честные контроли и эквивалентные strip-relative/strip-dotdot.
К-15: чисто — --model, --stabs и --repo . измеряют числа клеток и мутаций.
К-16: чисто — contracts/205-provodka-gate-profilja.md строка «КЛАСС РИСКА» и раздел «Модель угроз», инфраструктура без перечисленных оснований высокого риска.
К-17: н/п — инфраструктурный предмет двери проводки, архитектурная модель 188 к нему не применима.

accept
OBJECT=22f33389b9b55518b7afea0798cf0cdf9d47104e

СУД: repo=dev-harness; предмет=205; фаза=v1; роль=critic; вызов=3/3 (узкий, санкция консультанта ВЫЗОВ-3-205); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit205V3; модель-факт=openai-codex/gpt-6.1-terra (контекст запуска; сверка трассы оркестратором); SHA=22f33389b9b55518b7afea0798cf0cdf9d47104e; предыдущий=verdicts/critic/contracts-205-v2.md FAIL add44016fb; класс риска=обычный.

Предмет суда — К-01 вызова 2 и зависимый регресс; санкция объявлена заданием по ADR 2026-11-17. Автор OBJECT — architect, судья — critic. Запись санкции и фактическую модель по трассе до материализации сверяет оркестратор. Условия accept относятся только к указанному OBJECT.

## Закрытие К-01

`fixtures/workshop_project/provodka_gate_205/stabs.tsv:17` и `probe.py:295`: substring, регистр, LF, лишняя строка, strip-relative/strip-dotdot; `stabs.tsv:27` и `probe.py:312`: ANY-FIELD, IGNORE-ERRORS, GATE-FIRST, OMIT-SUFFIX. Дополнительные исполненные мутации v2 представлены STRIP-VYVODA, DIE-ECHO, STDOUT-STDERR-RAZDEL, LF-V-KONCE. Попытка v1 ignore-guard-existence с нулевым якорем не была исполненной мутацией; дополнительно есть OTSUTSTVIE-GUARD. Для каждой привязки честная модель проверяется отдельно; поимка требует отличия от честного результата и равенства точному ожидаемому кортежу rc и полного вывода (`probe.py:407-423`). Эквивалентные strip-relative/strip-dotdot сохранены как EKVIVALENT: правило суффикса принимает такие токены и без мутации. Состав проверен по stabs.tsv и словарям модели, якоря — при `--stabs`.

## Собственные соседние мутации

СОВЕТ fixtures/workshop_project/provodka_gate_205/probe.py:295 — перенести следующие пойманные мутации в адресные стабы; детали в `.review/2026-11-22-142.md`. Замены сделаны только в одноразовых копиях модели, по якорям кратности 1; изменения исходных файлов не производились. Команда `TMPDIR="$PWD/.scratch-crit205v3" python3 "$PWD/.scratch-crit205v3/attacks.py"` (одноразовый скрипт удалён после проверки), rc 0. Сырой вывод:
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
Замены: `ANCH_EQUAL` → `:`; в `ANCH_JQ` `gate[]?` → `gate[:-1][]?`; `prof_reason="${prof_reason#profile ОТКАЗ: }"` → `prof_reason="ошибка"` соответственно.

## Карта классов

К-01: закрыт — состав и точное сравнение стабов выше.
К-02: без изменений с вызова 2.
К-03: без изменений с вызова 2; регресс семьи 994 ниже.
К-04: без изменений с вызова 2; diff только контракт и батарея.
К-05: без изменений с вызова 2.
К-06: без изменений с вызова 2.
К-07: без изменений с вызова 2; честные контроли стабов.
К-08: закрыт с вызова 2; соседние мутации выше.
К-09: закрыт с вызова 2; LF-GRANITSY в стабе.
К-10: закрыт с вызова 2; точное сравнение кортежей и стабы лишнего вывода.
К-11: без изменений с вызова 2; ожидания до вызова субъекта.
К-12: без изменений с вызова 2.
К-13: без изменений с вызова 2, н/п — секретов нет.
К-14: без изменений с вызова 2; честные контроли и эквивалентные стабы.
К-15: счёт и регресс — прогоны ниже.
К-16: без изменений с вызова 2.
К-17: без изменений с вызова 2, н/п — инфраструктурный предмет.

## Исполненные команды

W = `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh`. Сырые итоговые строки и rc:
```
W --repo .: REPO_RC=1; KLETKI=24 ZELENYE=15 KRASNYE=9
W --model: MODEL_RC=0; KLETKI=24 ZELENYE=24 KRASNYE=0
W --stabs: STABS_RC=0; HONEST_CONTROLS=27 ZELENYE=27 KRASNYE=0; MUTACII=21 SVJAZI=27 POIMANY=25 EKVIVALENT=2 ZHIVYH=0
bash fixtures/check_provodka/external_ci_994/probe.sh: CI_RC=0; CASES executed=76 mismatches=0; LEGACY executed=18 mismatches=0
bash scripts/pre_critic.sh contracts/205-provodka-gate-profilja.md: PRE_RC=0; КРИТИК: дверь зелёная
bash scripts/check_sdacha.sh "$PWD" contracts/205-provodka-gate-profilja.md --run: SDACHA_RC=0; СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=6)
bash scripts/check_spec_ready.sh . contracts/205-provodka-gate-profilja.md: SPEC_RC=0
bash scripts/check_ids.sh .: IDS_RC=0
bash scripts/check_ceilings.sh .: CEIL_RC=0
bash scripts/check_provodka.sh --grammar . contracts/205-provodka-gate-profilja.md: GRAMMAR_RC=0
bash scripts/check_precision_gate.sh . contracts/205-provodka-gate-profilja.md: PRECISION_RC=0
bash scripts/check_threat_model.sh . contracts/205-provodka-gate-profilja.md: THREAT_RC=0
```
Все якоря стабов выдали occurrences=1; все 27 exact=true. Красная реальная дверь соответствует доремонтной приёмке.

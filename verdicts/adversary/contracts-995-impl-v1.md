FAIL
OBJECT=d532f36481ec980f139ededf42d1dfdf9c5072cc
СУД: repo=dev-harness; предмет=995; фаза=реализация; роль=adversary; вызов=один дополнительный узкий по слову владельца 2026-11-18 ~21:09 UTC; сессия=Adv995b; модель-факт=openai-codex/gpt-6.1-terra (allowed; `bash scripts/models_actual.sh --tsv --bind --session Adv995b | cut -f1-3` из `/home/harness/dev-harness`); SHA=d532f36481ec980f139ededf42d1dfdf9c5072cc.

## Блок — матрица зелена при подмене URL

БЛОКИРУЕТ `fixtures/workshop_project/pilot_995/runtime_probe.py:24,110,140-148`. Задание этого узкого вызова прямо требует: регресс, `--stabs` и `--matrix` краснеют именно на подмене URL/константы; честный мир зелёный. Контракт `contracts/995-cmp-mob-001-android-pilot.md:41` задаёт синтетические адреса `.invalid`. Матрица изолирована от нового регресса и запускает поведенческие модели без независимой проверки происхождения переданного URL. Проводка текущей quality в продукте `mobile.yml:242-247` вызывает именно `runtime_probe.py`, не этот отдельный регресс; перепин и правка продукта вне данного суда. Это отсутствие требуемого доказательства, а не утверждение о реальном сетевом запросе: `runtime.test.tsx:37-46` подменяет fetch бросающей функцией.

КЛАСС: К-11; ПРОИСХОЖДЕНИЕ: узкое-закрытие. Вход — прямо заданная в предыдущем вердикте и текущем задании замена существующей константы, не новая искусственная ветвь; механизм — тот же отправляемый в процесс URL без независимого свидетеля в двери матрицы.

ОБХОД: одноразовая копия батареи OBJECT, `SYNTHETIC_API_URL = 'https://example.com'`; команда `python3 /tmp/dev-harness-verify/Adv995b/world-real/runtime_probe.py --repo /tmp/dev-harness-verify/Adv995b/product --matrix` возвращает сырой rc 0:
```text
995 runtime/honest/SHIPPED_INVALID: rc=0
995 runtime/honest/SHIPPED_VALID: rc=0
995 runtime/honest/DEFAULT_VALID: rc=0
995 runtime/honest/HTTP_UNAVAILABLE: rc=0
995 runtime/honest/UNKNOWN_MODE: rc=0
995 runtime/honest/RUNTIME_RESPONSES: rc=0
995 runtime/copied-model/SHIPPED_INVALID: rc=1
995 runtime/any-code/SHIPPED_INVALID: rc=1
995 runtime/env-code/SHIPPED_INVALID: rc=1
995 runtime/http-demo/HTTP_UNAVAILABLE: rc=1
995 runtime/ignore-mode/UNKNOWN_MODE: rc=1
995 runtime/bypass-ports/RUNTIME_RESPONSES: rc=1
995 runtime/wrong-session/RUNTIME_RESPONSES: rc=1
995 runtime/wrong-disclosure/RUNTIME_RESPONSES: rc=1
995 runtime runs=9 mismatches=0
RAW_RC=0
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: адресная матрица отклоняет подмену адреса на не `.invalid`, честный мир и существующие поведенческие клетки остаются зелёными. Арбитраж конечной границы: повторная причина прежнего блока Adv995, но новый свидетель регресса уже работает; спорная граница — должна ли отдельно вызываемая матрица также отвергать подмену, как требует задание. Решение воли не подменяется данным вердиктом.

## Измерения

Рабочий каталог `/tmp/dev-harness-verify/Adv995b/repo`; продукт — отдельная копия `/tmp/dev-harness-verify/Adv995b/product` с зависимостями, исходный продукт `01e081b8dcc95c4f9cba353b656c70301fc4792c`. Копии батареи `world-{real,test,local,localhost,empty}`: в каждой ровно одно вхождение литерала строки `SYNTHETIC_API_URL = 'https://api.example.invalid'` заменено соответственно на `https://example.com`, `https://api.example.test`, `https://api.example.local`, `http://localhost`, пустую строку. Сценарии запускались последовательно без сети; `RAW_RC` — непосредственный код команды, а не переинтерпретация. Стек Jest ниже опущен, выводы в блоках — дословные строки.

Для каждого мира выполнены `python3 world-X/env_override_regression.py --repo product`, та же команда `--stabs` и `python3 world-X/runtime_probe.py --repo product --matrix` (пути относительно `/tmp/dev-harness-verify/Adv995b`). Все 10 вызовов регресса отказали одинаково **до исполнения наблюдения**:
```text
995 env ORACLE_TAMPERED: якорь real-host не единственен (вхождений 0): "SYNTHETIC_API_URL = 'https://api.example.invalid'"
RAW_RC=2
```
Это fail-closed контроль применимости, не предметный красный rc 1. Для матриц `real`, `local`, `localhost`, `empty` получено соответственно по одному:
```text
995 runtime/honest/HTTP_UNAVAILABLE: rc=0
995 runtime runs=9 mismatches=0
RAW_RC=0
```
Для `test` честная HTTP-клетка тоже прошла, но возник нерелевантный таймаут mutant `http-demo`, поэтому rc 1 нельзя приписывать обнаружению адреса:
```text
995 runtime/honest/HTTP_UNAVAILABLE: rc=0
995 runtime/http-demo/HTTP_UNAVAILABLE: rc=1
995 runtime WRONG_RESULT:Error: thrown: "Exceeded timeout of 5000 ms for a test.
995 runtime runs=9 mismatches=1
RAW_RC=1
```

Проверка механизма независимого свидетеля отдельно от предзапускного контроля применимости: `python3 -c "import sys;sys.path.insert(0,sys.argv[1]);import env_override_regression as e;from pathlib import Path; r,f=e.drive(Path(sys.argv[2]),'no-url',None);print('DRIVE_RC=',r);print(e.excerpt(f));sys.exit(r)" world-real product` из `/tmp/dev-harness-verify/Adv995b`:
```text
995 runtime/actual/HTTP_UNAVAILABLE: rc=1
Expected: "https://api.example.invalid"
Received: "https://example.com"
DRIVE_RC= 1
Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://example.com"
RAW_RC=1
```
Это диагностический вызов `drive`, не публичная команда регресса. `env_override_regression.py:75,147-153,170,220` задаёт отдельный литерал, вставляет ожидание в Jest и проверяет класс свидетеля, не читая URL из пробы; прежний механизм «ожидание из субъекта» в этом регрессе закрыт. Встроенный стаб real-host применяется после проверки якоря, поэтому доказывает различимость фактического окружения:
```text
995 env-regress STAB real-host parent=no-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://example.com")
995 env-regress STAB real-host parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://example.com")
995 env-regress SVJAZI 5 zhivykh 0
RAW_RC=0
```

Положительный контроль: `python3 fixtures/workshop_project/pilot_995/env_override_regression.py --repo /tmp/dev-harness-verify/Adv995b/product` дал оба `995 runtime/actual/HTTP_UNAVAILABLE: rc=0` и оба control parent absent/foreign `rc=0`, RAW_RC=0. Та же команда `--stabs` дала вышеуказанные real-host ×2, no-override ×2, setdefault ×1, `SVJAZI 5 zhivykh 0`, RAW_RC=0. `--mutation unapplied`:
```text
995 env ORACLE_TAMPERED: якорь unapplied не единственен (вхождений 0): "env['EXPO_PUBLIC_API_URL'] = SYNTHETIC_API_URL_UNAPPLIED_995"
RAW_RC=2
```
Честный `python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo /tmp/dev-harness-verify/Adv995b/product --matrix` дал те же 6 зелёных и 8 поимённых красных клеток, что в блоке, `runs=9 mismatches=0`, RAW_RC=0. `python3 fixtures/workshop_project/pilot_995/probe.py --repo /tmp/dev-harness-verify/Adv995b/product --check-frozen` — все 14 actual assertions passed, `995 runs=1 mismatches=0`, RAW_RC=0. `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs`:
```text
SVIP itog: N=20, krasnykh 0
SVJAZI 69
zhivykh 0
RAW_RC=0
```
Нейтрализация HTTP override и setdefault адресно ловится вышеназванными встроенными стабами; отсутствие инструмента: `PATH=/nonexistent /usr/bin/python3 .../runtime_probe.py --repo product --case HTTP_UNAVAILABLE` → `995 INFRASTRUCTURE: [Errno 2] No such file or directory: 'node'`, RAW_RC=2. Пустой продукт: `python3 .../runtime_probe.py --repo empty --case HTTP_UNAVAILABLE` → `995 PILOT_ABSENT`, RAW_RC=1.

## Дельта и сдаточный лист

`git diff --name-status 6b22cb4ffd d532f36481` называет лист, `env_override_regression.py` и добавленный прежний вердикт. `git diff --exit-code 6b22cb4ffd d532f36481 -- fixtures/workshop_project/pilot_995/runtime.test.tsx fixtures/workshop_project/pilot_995/runtime_probe.py` пуст, rc 0: throw-fetch, `auth-unavailable`, запреты F02.01/protected-start, восстановление fetch и байты runtime-пробы не изменены. `git diff --exit-code frozen/contracts/995/5 d532f36481 -- contracts/995-cmp-mob-001-android-pilot.md` пуст, rc 0.

`SDACHA_probe_http_unavailable.md:92-109,123-134` достоверно описывает независимый свидетель, `--stabs` rc 2 на подменённом якоре и зелёную матрицу на реальном хосте; авторская развилка о том, что матрица не расширялась, именно и противоречит адресному требованию вызова. Исторические замеры листа не выдаются за новые. Остатка `НЕ ЗАЩИЩАЕТ` с ловцом adversary в адресном срезе нет; no-URL приёмка листа оставлена решению владельца 165/995.

## Развилки

Принята буквальная проверка трёх названных дверей, не подмена её совокупным rc отдельного регресса. Положительное отличие: новый регресс имеет независимый свидетель и ловит real-host в наблюдении; отрицательное: сама матрица пропускает подмену. Не проверялись новый полный суд, живой CI/Android и сетевые обращения; продукт и предмет не менялись, push и тег не выполнялись.

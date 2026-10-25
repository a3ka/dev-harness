accept
OBJECT=5803d57ac2e08f3b17cf2949f59a9bde6fa8aff1
СУД: repo=Complior-mob (+dev-harness); предмет=118; фаза=реализация v2; роль=adversary; вызов=2/2; модель-план=zai/glm-5.3; сессия=Adv118v2c; модель-факт=openai-codex/gpt-5.6-terra; SHA=5803d57ac2e08f3b17cf2949f59a9bde6fa8aff1; предыдущий=/tmp/dev-harness-verify/orch/keep118/adv-v2b-krug1-fail.md; исключение=нет.

БЛОКИРУЕТ

Нет. Блокер вызова 1 закрыт исполнением на неизменённом OBJECT.

ПРОВЕРКА ИСПРАВЛЕНИЯ БЛОКЕРА 1

Позитивный контроль:
```text
$ cd mobile && npm test -- --json --outputFile=e2e-erstinformation/jest-otchet.json
rc=0
Test Suites: 11 passed, 11 total
Tests:       105 passed, 105 total
```

После него оба контракта запуска checker вернули rc=0 без вывода:
```text
$ cd mob && python3 mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-erstinformation --repo . --harness /tmp/dev-harness-verify/Adv118v2c/harness --jest-otchet e2e-erstinformation/jest-otchet.json
rc=0

$ cd mob && python3 mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py --pack /tmp/dev-harness-verify/Adv118v2c/mob/mobile/e2e-erstinformation --repo /tmp/dev-harness-verify/Adv118v2c/mob --harness /tmp/dev-harness-verify/Adv118v2c/harness --jest-otchet e2e-erstinformation/jest-otchet.json
rc=0
```

Формы путей в одноразовой копии также зелёные (каждая rc=0, без вывода): `--repo ..` из `mobile`; корень-симлинк; путь с пробелом; корневая форма `--jest-otchet mobile/e2e-erstinformation/jest-otchet.json`. Следовательно, `kanon()` применяется до `cwd=repo/mobile`, а не только к исходной форме `--repo .`.

Байт-копия продукции и pinned H совпадает:
```text
$ sha256sum mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py harness/fixtures/workshop_project/erstinformation_118/teksty/proverka_text.py
cb4d90412e121f3e3cdfbaf48f511565be56396972a4049db16dee6aeccad3ee  ...proverka_proiskhozdenija.py
cb4d90412e121f3e3cdfbaf48f511565be56396972a4049db16dee6aeccad3ee  ...proverka_text.py
rc=0
```

АТАКИ НА ПРОВЕРКУ

- Позитивный контроль батареи: `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --model` → rc=0; все выведенные `CASE ... ok`, 16 `KADR ... 1.000 0.600 ... OK`, `guard-shag ok`.
- Адресные обманные стабы: та же команда с `--stabs` → rc=0; все `CASE ... ok`, включая шесть форм путей; `s-bez-kanonizacii-puti.py` красен для `.`, симлинка, пробела и корневого отчёта; итог `SVJAZI 73`. Стабы ловят, в частности, константный/чужой admission (`s29_w0_propuskaet.py`), неполные/чужие отчёты (`s54`–`s56`), пропуск expiry и подмену данных (`s44`–`s62`).
- Отказ инструмента вне PATH: `env PATH=/nonexistent /usr/bin/python3 ...proverka...` → rc=1 и единственный содержательный отказ `PRICHINA KOMPOZICIJA_INSTRUMENT_NET bash: [Errno 2] No such file or directory: 'bash'`; ложного успеха и traceback нет.
- Пустой вход: в одноразовой копии `--jest-otchet e2e-erstinformation/empty-report.json` с содержимым `{}` → rc=1, `SROK_OTCHET_NE_USPEH success=None` и `SROK_OTCHET_BEZ_FAJLA zapisej=0`.
- Правильный ответ не на тот вопрос: отчёт с `success=true`, но единственной записью `/tmp/other.test.tsx` → rc=1, `SROK_OTCHET_BEZ_FAJLA zapisej=0`.
- Нейтрализация: удаление только `mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh` в одноразовой копии → rc=1 с ровно соответствующим `PRICHINA KOMPOZICIJA_NET mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh`.

ПЕРЕПИН И РЕГРЕСС-СЕТЬ

```text
$ git diff --name-status cb64b63c..5803d57a
M .github/workflows/mobile.yml
M mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py

$ git diff --stat cb64b63c..5803d57a
.github/workflows/mobile.yml | 13 ++++---
.../batareja/proverka_proiskhozdenija.py | 45 +++++++++++++++++++-----
2 files changed, 42 insertions(+), 16 deletions(-)
```

`.harness118` один перепинен на `5dbcb549dcd226b2bdc858a06aeb2a1be7bcbf04`; общий `.harness` остаётся `b9b4c66f3d84dc8aa7eb7c8e83b466e807817416`, `.harness117` — `8d3f48b886b180689114f15bc90c8d13bcd8480f`, `.harness123` и `.harness135` не изменены. Дифф меняет только комментарий блока 118 и эту `ref`; команды шагов проверки не изменены.

- `npm run typecheck` → rc=0.
- Обычный `npm run lint` на дереве с внешними `.harness` и экранными пачками закономерно rc=1 (`file outside allowed location/type`). В одноразовой копии после ровно того же выноса `.harness`, `e2e-first-run`, `e2e-erstinformation` и `kompozicija.stand-in.sh`, что предшествует lint в `mobile.yml`, `npm run lint` → rc=0, `structure: OK`.
- Замороженные CI-пины: 995 (`b9b4…`) → rc=0 для полного набора `probe --check-frozen`, runtime, bundle, schema, frozen_matrix, transport, admission, stale, types, pins, admission_family, stale_table; в том числе `995 stale-table ... SENTRY_HANDLERS: rc=0`. 108 (`b9b4…`) → rc=0, static 22/22 и honest 336/336. 111 (`b9b4…`) → rc=0, static 16/16 и honest 23/23. 117 (`8d3f…`) → rc=0, static 40/40 и behavioral 26/26.
- `git diff cb64b63c..5803d57a -- mobile/src` пуст: нового именованного обработчика нет.
- `gh pr checks 124 -R a3ka/Complior-mob` на OBJECT: `quality pass` (3m11s), `android-e2e pass` (13m4s), run 40233699476.

СОВЕТ

1. Подтверждён остаток предыдущего вызова о подлинности/свежести JSON: checker потребляет переданный отчёт и сам Jest не запускает. Это не новый блокер: контракт явно относит подделку отчёта/перестановку CI-шагов к `НЕ ЗАЩИЩАЕТ`, а наблюдённые CI-шаги запускают `npm test -- --json --outputFile=...` до checker; внешний CI на OBJECT зелёный.

2. Совет об отсутствии `bash` закрыт: вместо неименованного Python traceback теперь наблюдается fail-closed `KOMPOZICIJA_INSTRUMENT_NET` выше.

ПРОВЕРЕННЫЕ КЛАССЫ: положительный контроль; относительный/абсолютный/`..`/симлинк/пробел/корневой отчёт; отказ rc=1/127-инструмента; пустой вход; чужая запись отчёта; константный admission; нейтрализация; дефектная экранная форма, expiry и хромой Jest-отчёт адресными стабами; перепин и неизменность смежных frozen-пинов; 995/108/111/117; SENTRY_HANDLERS.

НЕ ПРОВЕРЕНО ЛОКАЛЬНО: реальный release-APK/Maestro на Android и загрузка артефактов — не запускались в этой сессии; на OBJECT их `android-e2e` CI наблюдён зелёным.

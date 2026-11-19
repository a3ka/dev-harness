accept
OBJECT=e06e3a84cd9b8b5224c86caf8eab29974795abfe
СУД: repo=dev-harness; предмет=995; фаза=реализация; роль=adversary; вызов=один узкий по слову владельца 2026-11-19 ~10:07 UTC; сессия=Adv995c; предмет содержимого=e6555cacd742af7cee7f7fb44d8c372ef0c90584; diff к OBJECT — только verdicts/arbitration/995-proishozhdenie-oracle-url.md, +137; модель-факт=openai-codex/gpt-6.1-terra, allowed (`bash scripts/models_actual.sh --tsv --bind --session Adv995c | cut -f1-3`, /home/harness/dev-harness, rc 0, две одинаковые строки).

## Узкое закрытие К-11

`url_witness.py:4-18`: независимый от runtime-константы, env и продукта литерал W и проверка HTTPS origin `.invalid`; `runtime_probe.py:59-62,145-148` сравнивает U с W в run и CLI до Jest; `env_override_regression.py:159-171,250-256` использует W для наблюдения внутри процесса и отдельно проверяет U. `runtime.test.tsx:37-47`: throw-fetch, auth-unavailable, запрет F02.01 и protected-start, восстановление fetch в finally. Свидетель не извлекается из проверяемой константы или результата продукта.

В своём клоне запущена отдельная адресная батарея `env PYTHONDONTWRITEBYTECODE=1 python3 -B -c "import sys; from pathlib import Path; sys.path.insert(0, 'fixtures/workshop_project/pilot_995'); import url_witness as w; import env_override_regression as e; print('WITNESS_SYNTHETIC', w.synthetic_origin(w.WITNESS_SYNTHETIC_URL)); print('WITNESS_MATCH', w.matches_witness(w.WITNESS_SYNTHETIC_URL)); e.SCRATCH_ROOT = Path.cwd(); sys.exit(e.url_stabs(Path.cwd()))"`: rc 0, `WITNESS_SYNTHETIC True`, `WITNESS_MATCH True`, `995 url-regress SVJAZI 15 zhivykh 0`. Все 15 отдельных дочерних команд вывели rc=1 URL_TAMPERED: пять подмен (example.com, .test, .local, localhost, пусто) × три двери (matrix, regression, regression-stabs). Проверка выполнялась до доступа к продукту; таймаут не засчитывался.

Дополнительно в одноразовой копии подмена самого `url_witness.py` на `https://example.com`: `python3 .../witness-world/runtime_probe.py --repo .../empty --matrix` → rc 2 `995 INFRASTRUCTURE: WITNESS_NOT_SYNTHETIC: свидетель вне класса .invalid (995:41)`; замена на другой допустимый `https://other.example.invalid` → rc 1 `995 runtime URL_TAMPERED`. Взаимная подмена проверяющего и правила класса вне заявленной границы; это не доказательство внешнего IdP.

## Зависимый регресс и позитивный контроль

Продукт в собственной одноразовой папке `/tmp/dev-harness-verify/Adv995c/product`: дерево `01e081b8dcc95c4f9cba353b656c70301fc4792c` извлечено `git archive` из локально доступного объекта, `npm ci --prefix .../product/mobile --no-audit --no-fund` rc 0. Публичный SSH-клон Complior-mob недоступен (`Repository not found`), использован локальный объект; проверяемый dev-harness клонирован строго из заданного SSH origin.

Последовательно `python3 fixtures/workshop_project/pilot_995/env_override_regression.py --repo /tmp/dev-harness-verify/Adv995c/product --stabs` и `python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo /tmp/dev-harness-verify/Adv995c/product --matrix`: обе команды rc 0 (соединены через `&&`, общий rc 0). Сырой существенный вывод:

```text
995 runtime/actual/HTTP_UNAVAILABLE: rc=0
995 env-regress/control parent=EXPO_PUBLIC_API_URL:absent: rc=0 (nabljudenie vnutri processa + setevaja kletka)
995 runtime/actual/HTTP_UNAVAILABLE: rc=0
995 env-regress/control parent=EXPO_PUBLIC_API_URL:https://foreign-parent.example.com: rc=0 (nabljudenie vnutri processa + setevaja kletka)
995 env-regress STAB no-override parent=no-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: undefined)
995 env-regress STAB no-override parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://foreign-parent.example.com")
995 env-regress STAB real-host parent=no-url KRASEN (URL_TAMPERED)
995 env-regress STAB real-host parent=foreign-url KRASEN (URL_TAMPERED)
995 env-regress STAB setdefault parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://foreign-parent.example.com")
995 env-regress SVJAZI 5 zhivykh 0
995 url-regress SVJAZI 15 zhivykh 0
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
```

`env_override_regression.py --mutation unapplied --repo .../product` → rc 2 `995 env ORACLE_TAMPERED: якорь unapplied не единственен (вхождений 0)`; PATH=/nonexistent `/usr/bin/python3 .../runtime_probe.py --repo .../product --case HTTP_UNAVAILABLE` → rc 2 `995 INFRASTRUCTURE: [Errno 2] No such file or directory: 'node'`; пустой продукт, та же case-команда → rc 1 `995 PILOT_ABSENT`. Провал инструмента не выдаётся за красный стаб.

`git diff --exit-code 10cc58c3f3 e6555cacd7 -- fixtures/workshop_project/pilot_995/runtime.test.tsx contracts/995-cmp-mob-001-android-pilot.md fixtures/workshop_project/pilot_995/restart` → rc 0. SHA256 runtime.test / runtime_probe / env_override_regression / url_witness соответственно c9aa30fa30465406ef55a3bb3df6cd468e6e7020596240e568761f4aaf7594f6, 268e4513a641a043d2ef572fbbf2332eeaf7579b394078f5d8598ab120e6e5a5, 49156aded8857fe088325d52365e31a695794dc9730ba3df6652f217129e78b4, a2842f1637416b84dd08ad818a8c9f226887cf869d2da00ca3e55d005bcd2c79 — совпадают со сдачей. Её результаты URL, обеих родительских конфигураций, мутаций, матрицы и хешей соответствуют собственному измерению; прошлые замеры не выдаются за новые.

Батарея bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs: сырой rc 0; 63 CASE ok; SVIP itog: N=20, krasnykh 0; SVJAZI 69; zhivykh 0. Красные свипы внутри стабов ожидаемы.

## Карта классов

К-01: чисто — адресная сдача и хеши сверены выше.
К-02: чисто — слово владельца и задание: только К-11 и зависимый регресс.
К-03: чисто — diff frozen-контракта и runtime.test rc 0.
К-04: без изменений с Adv995b — вне узкого среза.
К-05: чисто — обе адресные CLI-двери и --stabs исполнены.
К-06: чисто — PATH без node rc 2; unapplied rc 2.
К-07: чисто — два честных родительских входа и честная runtime-матрица rc 0.
К-08: чисто — no-override, setdefault, http-demo красны на назначенных ветвях.
К-09: без изменений с Adv995b — вне узкого среза.
К-10: чисто — живое process.env в Jest и HTTP postconditions.
К-11: чисто — независимый свидетель, 15 URL-подмен × дверей красны.
К-12: без изменений с Adv995b — вне узкого среза.
К-13: без изменений с Adv995b — вне узкого среза.
К-14: чисто — честный `.invalid` зелён на обеих конфигурациях.
К-15: чисто — SVJAZI 5 и 15, runtime runs=9 mismatches=0 из вывода.
К-16: без изменений с Adv995b — вне узкого среза.
К-17: без изменений с Adv995b — архитектурная модель не затронута.

## Развилки

Реальный CI/Android/внешний backend не запускались; сетевую доставку throw-fetch не доказывает. Новых классов вне санкционированного среза не исследовали. Остатка `НЕ ЗАЩИЩАЕТ` с ловцом adversary в адресном срезе контракта нет. Push и тег не выполнялись.

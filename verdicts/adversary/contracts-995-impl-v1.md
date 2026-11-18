FAIL
OBJECT=6b22cb4ffd704be3f6cee4c4c8eb666ab61c0a56
СУД: repo=dev-harness; предмет=995; фаза=реализация; роль=adversary; вызов=один дополнительный узкий по слову владельца ~14:05 UTC 2026-11-18, §2 батча №2; сессия=Adv995; модель-факт=openai-codex/gpt-6.1-terra (allowed; `bash scripts/models_actual.sh --tsv --bind --session Adv995 | cut -f1-3`); SHA=6b22cb4ffd704be3f6cee4c4c8eb666ab61c0a56.

БЛОКИРУЕТ `fixtures/workshop_project/pilot_995/env_override_regression.py:135-137`, `fixtures/workshop_project/pilot_995/runtime_probe.py:24,110` — проверка не доказывает обязательное синтетическое происхождение URL: ожидаемое значение берётся из самой проверяемой константы. `contracts/995-cmp-mob-001-android-pilot.md:41` требует синтетические адреса `.invalid`; санкционированная дельта прямо требует синтетический URL для HTTP_UNAVAILABLE и проверку URL с реальным хостом. Это недостаток доказательства свойства, а не утверждение, что кандидат уже использует реальный хост: в OBJECT стоит `https://api.example.invalid`. КЛАСС: К-11 (оракул из субъекта), ПРОИСХОЖДЕНИЕ: дельта.

СОСТОЯНИЕ: явно названная заданием негативная клетка «URL с реальным хостом»; вместо существующего присваивания константы строки 24 в одноразовой копии подставлено `https://example.com`. Источник механизма — замена именно добавленной операции, а не специальный запрет входа. Проверяемый процесс получает этот URL при отсутствии родительского и при чужом родительском URL; ожидаемое значение одновременно меняется вместе с ним. Сам факт реального сетевого запроса не заявляется: в `runtime.test.tsx:39` fetch подменён throw-fetch.

ВХОД (все команды из `/tmp/dev-harness-verify/Adv995/repo`; продукт — локальная одноразовая копия Complior-mob `01e081b8dcc95c4f9cba353b656c70301fc4792c`, с установленными зависимостями; сеть не использовалась):
```sh
cp -a fixtures/workshop_project/pilot_995 .negative/real-host
python3 -c "from pathlib import Path; p=Path('.negative/real-host/runtime_probe.py'); s=p.read_text(); a=\"SYNTHETIC_API_URL = 'https://api.example.invalid'\"; assert s.count(a)==1; p.write_text(s.replace(a, \"SYNTHETIC_API_URL = 'https://example.com'\"))"
python3 .negative/real-host/env_override_regression.py --repo .product-negative --stabs
python3 .negative/real-host/runtime_probe.py --repo .product-negative --matrix
```
НАБЛЮДЕНИЕ (дословные сигнальные строки; стеки Jest опущены):
```text
995 env-regress/control parent=EXPO_PUBLIC_API_URL:absent: rc=0 (nabljudenie vnutri processa + setevaja kletka)
995 env-regress/control parent=EXPO_PUBLIC_API_URL:https://foreign-parent.example.com: rc=0 (nabljudenie vnutri processa + setevaja kletka)
995 env-regress STAB no-override parent=no-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://example.com" | Received: undefined)
995 env-regress STAB no-override parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://example.com" | Received: "https://foreign-parent.example.com")
995 env-regress STAB setdefault parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://example.com" | Received: "https://foreign-parent.example.com")
995 env-regress SVJAZI 3 zhivykh 0
REAL-HOST STABS rc=0
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
REAL-HOST MATRIX rc=0
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: независимое от значения, предоставленного проверяемой пробой, свидетельство синтетического `.invalid` URL в реально переданном окружении; негативная клетка с реальным хостом не зелёная, честный синтетический URL и оба родительских входа остаются зелёными.

Положительный контроль OBJECT и зависимый регресс (дословные сигнальные строки; стеки Jest опущены):
```text
$ python3 fixtures/workshop_project/pilot_995/env_override_regression.py --repo .product
995 runtime/actual/HTTP_UNAVAILABLE: rc=0
995 env-regress/control parent=EXPO_PUBLIC_API_URL:absent: rc=0 (nabljudenie vnutri processa + setevaja kletka)
995 runtime/actual/HTTP_UNAVAILABLE: rc=0
995 env-regress/control parent=EXPO_PUBLIC_API_URL:https://foreign-parent.example.com: rc=0 (nabljudenie vnutri processa + setevaja kletka)
CONTROL rc=0
$ python3 fixtures/workshop_project/pilot_995/env_override_regression.py --repo .product --stabs
995 env-regress STAB no-override parent=no-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: undefined)
995 env-regress STAB no-override parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://foreign-parent.example.com")
995 env-regress STAB setdefault parent=foreign-url KRASEN (Error: expect(received).toBe(expected) // Object.is equality | Expected: "https://api.example.invalid" | Received: "https://foreign-parent.example.com")
995 env-regress SVJAZI 3 zhivykh 0
STABS rc=0
$ python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo .product --matrix
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
MATRIX rc=0
$ python3 fixtures/workshop_project/pilot_995/probe.py --repo .product --check-frozen
995 actual/DIRECT_unknown: rc=0 assertion=passed
995 actual/DIRECT_incomplete: rc=0 assertion=passed
995 actual/INVALID_CODE: rc=0 assertion=passed
995 actual/RESEND_UNCONFIRMED: rc=0 assertion=passed
995 actual/RESEND_CONFIRMED: rc=0 assertion=passed
995 actual/RESEND_COOLDOWN: rc=0 assertion=passed
995 actual/EMAIL_STALE: rc=0 assertion=passed
995 actual/RECOVERY_A07: rc=0 assertion=passed
995 actual/AUTH_stale: rc=0 assertion=passed
995 actual/AUTH_revoked: rc=0 assertion=passed
995 actual/AUTH_missing_scope: rc=0 assertion=passed
995 actual/SECRET: rc=0 assertion=passed
995 actual/REPLAY: rc=0 assertion=passed
995 actual/DEFAULT_OFFLINE: rc=0 assertion=passed
995 runs=1 mismatches=0
FROZEN rc=0
```
Контракт побайтно: `git diff frozen/contracts/995/5 6b22cb4ffd -- contracts/995-cmp-mob-001-android-pilot.md` — пусто, rc 0. В OBJECT `runtime.test.tsx:37-46` сохраняет throw-fetch, auth-unavailable, запреты F02.01/protected-start и восстановление fetch. Прогон без инструмента: `PATH=/nonexistent /usr/bin/python3 .../runtime_probe.py --repo .product --case HTTP_UNAVAILABLE` → `995 INFRASTRUCTURE: [Errno 2] No such file or directory: 'node'`, rc 2. Пустой продукт: `.../runtime_probe.py --repo .negative/empty --case HTTP_UNAVAILABLE` → `995 PILOT_ABSENT`, rc 1. Неприменённая мутация: `.../env_override_regression.py --repo .product --mutation unapplied` → `995 env ORACLE_TAMPERED: якорь unapplied не единственен (вхождений 0)`, rc 2.

Дополнительное наблюдение той же границы оракула, не отдельный блок: в другой копии после строки присваивания добавлено `if case == 'HTTP_UNAVAILABLE' and model: env.pop('EXPO_PUBLIC_API_URL', None)`. При `env -u EXPO_PUBLIC_API_URL` контроль `--stabs` дал `SVJAZI 3 zhivykh 0`, rc 0, а `--matrix` дал `runs=9 mismatches=0`, rc 0: регресс наблюдает только actual, а runtime-модель не читает URL. Эта специально добавленная ветка сама по себе не предъявляется блоком по §Порог. Заявленный автором остаток о no-URL продуктовой приёмке здесь не закрывается и не переобъявляется доказанным.

Развилки: нового полного поиска, повторов CI, сетевого fetch/push, изменения frozen и продукта не делал. Остатков `НЕ ЗАЩИЩАЕТ` с назначенным ловцом adversary в адресном срезе не обнаружено; остаток no-URL в сдаточном листе назначен решению владельца 165/995, не adversary.

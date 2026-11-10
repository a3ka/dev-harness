FAIL
OBJECT=4e628c5b1f841bc971afa3ababa40661d2e0f0b4
СУД: repo=dev-harness; предмет=184; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=openai-codex/gpt-5.6-terra; SHA=4e628c5b1f841bc971afa3ababa40661d2e0f0b4; предыдущий=нет; исключение=нет

БЛОКИРУЕТ contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:31,45,50,124-125 — заявленный до-done критерий проводки не имеет исполнимого и объявленного CI-входа.
ОБЯЗАТЕЛЬСТВО: перед done `check_provodka.sh` должен вернуть rc 0 после подключения именно батареи 184 в CI; каждая работа и путь такого подключения должны оставаться в названной ЗОНЕ.
КЛАСС ПРИЧИНЫ: отсутствующий исполнимый entrypoint батареи в замкнутой грамматике CI.
СОСТОЯНИЕ: единственный guard — `fixtures/workshop_project/external_connection_184/probe.py`; в его каталоге на OBJECT есть только `.probe-only` и `probe.py`. ЗОНА orchestrator разрешает только `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml`; `package.json` вне её, а имени bash-обёртки контракт не задаёт.
НАБЛЮДЕНИЕ: `registry/ci-steps.tsv`/контракт 083 разрешают только `npm run <key>` или `bash <путь>`. Поиск не находит 184/`external_connection_184`/`probe.py` в реестре, workflow, package.json или scripts; `bash scripts/check_provodka.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md` возвращает rc 1: `проводка: guard не подключён: fixtures/workshop_project/external_connection_184/probe.py не вызывается в .githooks/ или .github/workflows/`. Единственный непосредственный допустимый путь `bash fixtures/workshop_project/external_connection_184/probe.py --model` возвращает rc 2, потому что bash исполняет Python как shell.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: контракт заранее называет принадлежащий объявленной зоне исполнимый CI-entrypoint и его разрешённую команду; этот entrypoint действительно запускает батарею 184, а после его регистрации `check_provodka.sh` возвращает rc 0. Это оставляет автору выбор реализации entrypoint, но не оставляет выбор границ и механизма доказательства исполнителю.

ПРОГОНЫ:
$ bash scripts/pre_critic.sh contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
OK
[rc=0]

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 167 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ python3 fixtures/workshop_project/external_connection_184/probe.py --model
CELL clean: ok (expected=ok, got=ok)
CELL internal-reference: ok (expected=ok, got=ok)
CELL ci-reference: ok (expected=ssylka, got=ssylka)
CELL readme-reference: ok (expected=ssylka, got=ssylka)
CELL configuration-reference: ok (expected=ssylka, got=ssylka)
CELL ignore-reference: ok (expected=ssylka, got=ssylka)
CELL nested-code-reference: ok (expected=ssylka, got=ssylka)
CELL legacy-root-profile: ok (expected=profil, got=profil)
CELL swapped-identity: ok (expected=profil, got=profil)
CELL generator-good: ok (expected=ok, got=ok)
CELL generator-wrong-id: ok (expected=profil, got=profil)
[rc=0]

$ python3 fixtures/workshop_project/external_connection_184/probe.py --stabs
STAB scan-internal@internal-reference: caught (expected=ok, got=ssylka)
STAB no-ci@ci-reference: caught (expected=ssylka, got=ok)
STAB no-docs@readme-reference: caught (expected=ssylka, got=ok)
STAB no-config@configuration-reference: caught (expected=ssylka, got=ok)
STAB no-ignore@ignore-reference: caught (expected=ssylka, got=ok)
STAB root-only@nested-code-reference: caught (expected=ssylka, got=ok)
STAB root-profile@legacy-root-profile: caught (expected=profil, got=ok)
STAB trust-any-profile@swapped-identity: caught (expected=profil, got=ok)
STAB duplicate-profile@generator-good: caught (expected=ok, got=profil)
STAB trust-manifest@generator-wrong-id: caught (expected=profil, got=ok)
[rc=0]

АТАКА — допустимая грамматикой CI непосредственная команда guard:
$ bash fixtures/workshop_project/external_connection_184/probe.py --model
fixtures/workshop_project/external_connection_184/probe.py: line 2: 184: A10 cutover; every world is a disposable git repository, never a product checkout.: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 3: import: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 4: import: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 5: import: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 6: from: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 7: import: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 8: import: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 9: import: command not found
fixtures/workshop_project/external_connection_184/probe.py: line 11: syntax error near unexpected token `('
fixtures/workshop_project/external_connection_184/probe.py: line 11: `TOOLS = Path(__file__).resolve().parents[3]'
[rc=2]

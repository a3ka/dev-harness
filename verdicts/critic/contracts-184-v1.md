FAIL
OBJECT=acb0da9205cfd921fa80eb6a28f52ec30fab49f4
СУД: repo=dev-harness; предмет=184; фаза=контракт; роль=critic; вызов=2/2; модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=openai-codex/gpt-5.6-terra; SHA=acb0da9205cfd921fa80eb6a28f52ec30fab49f4; предыдущий=verdicts/critic/contracts-184-v1-krug1-fail.md; исключение=нет

Статус блока круга 1: исходный класс «нет исполнимого CI-entrypoint» закрыт: на OBJECT есть `red_external_connection_184.sh`, честные `--model` и `--stabs` зелёные, а регистрация команды в одноразовой копии проходит `gen_ci_steps --write/--check` и `check_provodka`.

БЛОКИРУЕТ contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:31,137-138 — зарегистрированная CI-команда считает подмену своего единственного entrypoint успешной и потому не доказывает выполнение `probe.py`.
ОБЯЗАТЕЛЬСТВО: заявленные CI `--model` и `--stabs` должны доказывать выполнение батареи 184; удаление вызова `probe.py` или подмена её статуса не может дать этой команде rc 0.
КЛАСС ПРИЧИНЫ: ложная достаточность самопроверяющегося CI-entrypoint.
СОСТОЯНИЕ: источник входа — поддерживаемая в критерии строка CI `bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --stabs`; она прямо названа в приёмке и должна быть записана оркестратором в `registry/ci-steps.tsv`. Источник ошибочного механизма — существующая предметная операция обёртки `PYTHONDONTWRITEBYTECODE=1 python3 "$HERE/probe.py" "$@"; в одноразовом клоне она заменена на `exit 0`, то есть вызов пробы удалён, а не добавлена новая ветвь.
НАБЛЮДЕНИЕ: после этой замены ровно объявленная CI-цепочка ниже вернула rc 0 без какого-либо вывода: ни `probe.py`, ни красные клетки, ни стабы не были выполнены. Это достижимо в заявленном CI-пути и нарушает названное обязательство.
ОБХОД: файл `red_external_connection_184.sh` из `#!/usr/bin/env bash` и `exit 0` удовлетворяет CI-критерию по коду возврата, хотя батарея 184 не запускалась вообще.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: успех зарегистрированного CI-пути опирается на независимое от изменяемой обёртки свидетельство завершения обеих ветвей пробы; удаление вызова `probe.py` либо поглощение его ненулевого rc обязательно делает CI-путь красным.
МИНИМАЛЬНОЕ ИСПРАВЛЕНИЕ: дополнить контракт и красную батарею независимым от проверяемой обёртки CI-доказательством этого свойства, затем предъявить красную мутацию удаления вызова и зелёный честный путь.

ПРОГОНЫ (сырой вывод):

$ bash scripts/pre_critic.sh contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
OK
[rc=0]

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model
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
CELL ci-entrypoint: ok
[rc=0]

$ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --stabs
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
STAB absent-entrypoint@ci-entrypoint: caught
STAB invalid-entrypoint@ci-entrypoint: caught
STAB swallowed-rc@ci-entrypoint: caught
[rc=0]

$ env PATH=/nonexistent /bin/bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model
NOT_IMPLEMENTED: python3 unavailable
[rc=2]

$ bash scripts/check_provodka.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
проводка: guard не подключён: fixtures/workshop_project/external_connection_184/red_external_connection_184.sh не вызывается в .githooks/ или .github/workflows/
[rc=1; ожидаемо до регистрации CI-шага]

$ bash scripts/gen_ci_steps.sh --write && bash scripts/gen_ci_steps.sh --check && bash scripts/check_provodka.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
[одноразовая копия с добавленной строкой `step\tcheck:external-connection-184-family-selftest\t0\tbash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --stabs`; вывода нет]
[rc=0]

$ bash scripts/run_ci_lane.sh check:external-connection-184-family-selftest
+ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --stabs
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
CELL ci-entrypoint: ok
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
STAB absent-entrypoint@ci-entrypoint: caught
STAB invalid-entrypoint@ci-entrypoint: caught
STAB swallowed-rc@ci-entrypoint: caught
замер: check:external-connection-184-family-selftest 1
[rc=0]

АТАКА — удаление существующей операции вызова пробы во временной обёртке:
$ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --stabs
[вывода нет]
[rc=0]

После атаки исходный `red_external_connection_184.sh` восстановлен из OBJECT до записи вердикта.

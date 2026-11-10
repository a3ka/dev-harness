FAIL
OBJECT=ebc7c8a93f96e3bae293b1259cb48516d9674e7f
СУД: repo=dev-harness; предмет=184; фаза=контракт; роль=critic; вызов=3/2 (исправительный по санкции оркестратора №1); модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=openai-codex/gpt-5.6-terra; SHA=ebc7c8a93f96e3bae293b1259cb48516d9674e7f; предыдущий=verdicts/critic/contracts-184-v1.md; исключение=санкция оркестратора №1 (§Остановка)

# Вердикт критика — контракт 184 «внешняя замена подключения проекта (А10)», исправительный вызов 3/2

## Кандидат, независимость и граница повтора

OBJECT проверен в отдельном одноразовом SSH-клоне: `git fetch origin wip/184/architect` дал `ebc7c8a93f96e3bae293b1259cb48516d9674e7f` и detached `HEAD` установлен на этот SHA. Автор OBJECT — `architect <architect@dev-harness.local>`; судья — отдельная сессия `c907157c`, собственной работы не судит. План модели — `zai/glm-5.3` (тир `apex-sol`); фактическая модель — `openai-codex/gpt-5.6-terra`, разрешённый fallback `apex-sol` (`config/agent_models.json:59-63,94`).

Запуск 3/2 законен только как одноразовая исправительная проверка: `origin/wip/012/orchestrator` содержит коммит `1dd0f3334e697b0d3aa6611330ec9aacd0c3169a` с `САНКЦИЯ-ОРКЕСТРАТОРА` именно для OBJECT и последующей строкой `СУД` 3/2. Поэтому проверены закрытие единственного класса из `verdicts/critic/contracts-184-v1.md` и последствия семантической дельты `acb0da9205cfd921fa80eb6a28f52ec30fab49f4..ebc7c8a93f96e3bae293b1259cb48516d9674e7f`; неизменённые поверхности заново не исследовались. Полный `check_zones.sh` намеренно не запускался по заданию scoped-вызова.

## Закрытие прежнего блока

Прежний класс «ложная достаточность самопроверяющегося CI-entrypoint» закрыт. В `contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:31-32,144` точная регистрируемая CI-цепочка оставляет bash-обёртку проверяемым объектом и затем отдельно вызывает `probe.py --model` и `probe.py --stabs`. В изолированных worktree обе требуемые мутации обёртки сделали эту полную строку красной:

- замена `red_external_connection_184.sh` на `#!/usr/bin/env bash` + `exit 0` дала `CELL ci-entrypoint: RED`, rc 1;
- обёртка, которая вызывает `probe.py "$@"`, подавляет её stderr и всегда делает `exit 0`, дала тот же `CELL ci-entrypoint: RED`, rc 1.

Честная зарегистрированная строка прошла rc 0 через `run_ci_lane.sh`; `gen_ci_steps.sh --write/--check` и `check_provodka.sh` приняли её в отдельном worktree после добавления ровно одной строки в каждый из `registry/ci-steps.tsv` и `registry/ci-zamery.tsv`. Обычные `--model` и `--stabs` также зелёные, включая новые `STAB no-probe@ci-entrypoint: caught` и `STAB swallowed-rc@ci-entrypoint: caught`.

## Новый блок из исправительной дельты

БЛОКИРУЕТ contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:31-32,45-47,144 — новая независимая CI-опора остаётся собственной `probe.py`, но модель угроз не называет подмену этой пробы как `НЕ ЗАЩИЩАЕТ`.
ОБЯЗАТЕЛЬСТВО: правило 8 `AGENTS.md:239-242` требует считать всё на диске во время прогона территорией проверяемого; задание этого вызова прямо требует проверить подмену `probe.py` на `exit 0` и, если контракт её не защищает, назвать это в `НЕ ЗАЩИЩАЕТ`.
КЛАСС ПРИЧИНЫ: ложная достаточность самопроверяющейся новой CI-опоры без объявленной границы доверия.
СОСТОЯНИЕ: источник входа — поддерживаемая и объявленная в приёмке CI-строка из `contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:32`; она допускается грамматикой реестра и исполняется `run_ci_lane.sh` через `bash -c`. Источник ошибочного механизма — существующая предметная операция `fixtures/workshop_project/external_connection_184/probe.py:204-265,268-295`, которая строит клетки/стабы и возвращает их rc; в отдельном worktree она заменена целиком на `raise SystemExit(0)`, то есть удалены уже существующие предметные проверки, а не добавлена новая ветвь. Исправительная дельта делает именно эту операцию отдельным доказательством в CI (`python3 .../probe.py --model && ... --stabs`).
НАБЛЮДЕНИЕ: после этой замены точная полная CI-цепочка вернула rc 0 без stdout: не выполнилась ни одна `CELL` и ни один `STAB`. Два текущих буллета `НЕ ЗАЩИЩАЕТ` описывают только семантику старого имени `harness` и продуктовый CI, не замену самой пробы. Следовательно, положительный rc зарегистрированного пути всё ещё можно получить без исполнения батареи, а остаточный риск не объявлен.
ОБХОД: в одноразовом worktree заменить `fixtures/workshop_project/external_connection_184/probe.py` на `#!/usr/bin/env python3` и `raise SystemExit(0)`; объявленная строка CI остаётся зелёной, хотя батарея 184 не исполняется.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: граница доверия к самой `probe.py` явно названа в `НЕ ЗАЩИЩАЕТ`, либо независимое от неё свидетельство делает точную CI-цепочку красной при этой замене. Выбор реализации не предписывается.

## Выполненные прогоны

```text
$ bash scripts/check_precision_gate.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md && bash scripts/pre_critic.sh contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
OK
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
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
STAB no-probe@ci-entrypoint: caught
STAB swallowed-rc@ci-entrypoint: caught
[rc=0]

$ bash scripts/check_provodka.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md
проводка: guard не подключён: fixtures/workshop_project/external_connection_184/red_external_connection_184.sh не вызывается в .githooks/ или .github/workflows/
[rc=1 — ожидаемое красное состояние до подключения]

$ printf '\nstep\tcheck:external-connection-184-family-selftest\t0\tbash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && python3 fixtures/workshop_project/external_connection_184/probe.py --model && python3 fixtures/workshop_project/external_connection_184/probe.py --stabs\n' | tee -a registry/ci-steps.tsv && printf '\ncheck:external-connection-184-family-selftest\t0\t8\t0\n' | tee -a registry/ci-zamery.tsv && bash scripts/gen_ci_steps.sh --write && bash scripts/gen_ci_steps.sh --check && bash scripts/check_provodka.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md

step	check:external-connection-184-family-selftest	0	bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && python3 fixtures/workshop_project/external_connection_184/probe.py --model && python3 fixtures/workshop_project/external_connection_184/probe.py --stabs

check:external-connection-184-family-selftest	0	8	0
[rc=0]

$ bash scripts/run_ci_lane.sh check:external-connection-184-family-selftest
+ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && python3 fixtures/workshop_project/external_connection_184/probe.py --model && python3 fixtures/workshop_project/external_connection_184/probe.py --stabs
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
STAB no-probe@ci-entrypoint: caught
STAB swallowed-rc@ci-entrypoint: caught
замер: check:external-connection-184-family-selftest 1
[rc=0]

АТАКА 1 — обёртка = `#!/usr/bin/env bash` + `exit 0` в отдельном worktree:
$ bash -c 'bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && python3 fixtures/workshop_project/external_connection_184/probe.py --model && python3 fixtures/workshop_project/external_connection_184/probe.py --stabs'
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
CELL ci-entrypoint: RED
[rc=1]

АТАКА 2 — обёртка вызывает `probe.py "$@"`, подавляет её rc и завершает `exit 0` в отдельном worktree:
$ bash -c 'bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && python3 fixtures/workshop_project/external_connection_184/probe.py --model && python3 fixtures/workshop_project/external_connection_184/probe.py --stabs'
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
CELL ci-entrypoint: RED
[rc=1]

АТАКА 3 — `probe.py` = `#!/usr/bin/env python3` + `raise SystemExit(0)` в отдельном worktree:
$ bash -c 'bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && python3 fixtures/workshop_project/external_connection_184/probe.py --model && python3 fixtures/workshop_project/external_connection_184/probe.py --stabs'
[stdout/stderr пусты]
[rc=0]
```

Вердикт: `FAIL`. Единственный прежний блок закрыт, но исправительная дельта открыла доказанный новый класс: собственная пробы не является независимым доказательством своей целостности, а этот остаточный риск не объявлен в `НЕ ЗАЩИЩАЕТ`.

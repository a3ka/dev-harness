# Adversary 038 — done-gate: два незакрытых обхода

**Вердикт: FAIL.** Судимый HEAD: `31d49d5d2145b378fe51a75a082b656683a1c205`. Предмет: `contracts/038-provodka-done-gejt.md`; реализации: `scripts/check_provodka.sh`, `scripts/done_contract.sh`, `scripts/check_consumers.sh`. Найдено **2 незакрытых обхода**, и каждый живым toy-репро дошёл до настоящего `done_contract.sh` и поставил `done/contracts/001/1`. Предмет и реализация не правились.

Репро лежат только в `/tmp/dev-harness-verify/`: клон `/tmp/dev-harness-verify/adversary038`; исполняемый свидетель `/tmp/dev-harness-verify/adversary038/repro.sh`. `bash repro.sh` строит все toy-репозитории с нуля, сверяет rc и наличие созданного тега.

## Б1 — `role=` принимает цель вне `roles/*.md`

Грамматика требует `role=roles/<роль>.md «<норма-строка>»`. Реализация классифицирует любой префикс `role=`, затем проверяет лишь существование файла и `grep -Fxq`; проверки `roles/*.md` нет.

Toy несёт:

```text
ПРОВОДКА:
- role=policies/r.txt «Active norm.»
```

`policies/r.txt` существует и несёт отдельную `Active norm.`; `roles/` отсутствует. После коммита контракта и reviewer `accept` настоящий reader и writer оба дали rc 0, writer поставил тег:

```text
bypass-role-path: reader=0 done=0 tag=done/contracts/001/1
```

Это нарушение грамматики не является named residual и зелёно принимается done-gate.

## Б2 — отказ `tail` в PATH выдаётся за пустое окно consumers

Реализация использует:

```bash
last_frozen="$(git -C "$ROOT" tag -l 'frozen/contracts/'"$n"'/*' 2>/dev/null | sort -V | tail -n 1 || true)"
```

Нет `pipefail`, а `|| true` маскирует отсутствие/отказ `tail` пустым `last_frozen`; следующая ветвь немедленно возвращает rc 0. PATH не фиксируется и доступность `tail` не проверяется.

Репро создаёт корректный `consumers.d` с тремя обязательными writer-путями, ставит `frozen/contracts/001/1`, меняет `scripts/freeze_contract.sh` после тега и кладёт census-строку, но **не** кладёт обязательную `ПОТРЕБИТЕЛЬ fixtures/reader.sh: …`.

* С обычным PATH настоящий `check_consumers.sh` даёт rc 1 и `нет ПОТРЕБИТЕЛЬ-пробы`.
* С единственным `fakebin/tail`, возвращающим 127, тот же reader даёт rc 0.
* С тем же PATH настоящий `done_contract.sh` даёт rc 0 и создаёт `done/contracts/001/1`.

```text
bypass-PATH-tail: normal-consumers=1 masked-consumers=0 done=0 tag=done/contracts/001/1
```

Это обход шага 6а класса «инструмент мимо PATH»: отказ инструмента превратился в зелёную пустоту.

## Проверенные named residual, не включены в счёт Б1–Б2

* **Consumer-заглушка (§Риски-8):** объявленный `fixtures/reader.sh` реально возвращает 1, но контракт несёт `ПОТРЕБИТЕЛЬ fixtures/reader.sh: true`; настоящий gate даёт 0.

  ```text
  residual-consumer-stub: consumer=1 gate=0
  ```

  Это явная граница механики: семантика команды оставлена reviewer.

* **Fenced role (§Риски-1):** роль содержит `Active norm.` только в fenced code block; reader всё равно даёт 0.

  ```text
  residual-fenced-role: reader=0
  ```

* **Guard-упоминание (§Риски-2):** `scripts/guard.sh` возвращает 99, CI содержит лишь `run: echo guard`; reader и writer зелёные, тег поставлен.

  ```text
  bypass-guard-echo: reader=0 done=0 guard-never-executed
  ```

  Это подтверждает, что утверждение «guard реально вызван» сильнее фактического механизма, но конкретно этот обход назван самим контрактом, поэтому не добавлен как новый defect.

## Контроли

* Позитивный честный done: `bash fixtures/done_contract/green_G_polnoe_derevo.sh` → rc 0, `DG: тег поставлен, реестр байт-в-байт нетронут`.
* Пустая ПРОВОДКА + reviewer `accept` → rc 1, `done: ПРОВОДКА красна: проводка: поле ПРОВОДКА отсутствует`.
* Валидная role-ПРОВОДКА, но reviewer verdict отсутствует → rc 1, `done: вердикт ревьюера не найден: verdicts/review/contracts-001-*.md`.

Общий вывод `bash /tmp/dev-harness-verify/adversary038/repro.sh`:

```text
positive-control: check_provodka rc=0
bypass-role-path: reader=0 done=0 tag=done/contracts/001/1
bypass-guard-echo: reader=0 done=0 guard-never-executed
bypass-PATH-tail: normal-consumers=1 masked-consumers=0 done=0 tag=done/contracts/001/1
residual-consumer-stub: consumer=1 gate=0
residual-fenced-role: reader=0
negative-empty-provodka: rc=1 named
negative-no-review: rc=1 named
live-039: provodka=0 reviewer=accept done-tag-present
ALL REPRODUCTIONS PASSED
```

## Самопроверка 039

`done/contracts/039/1` — аннотированный тег на `52e5d1742b22cc044d12169a60f9fbe9c84aae7a`; первая строка `verdicts/review/contracts-039-k1.md` на этом commit — `accept`. Сверка `git diff --name-only 52e5d174… HEAD -- contracts/039-check-protected-rename.md verdicts/review/contracts-039-k1.md .github/workflows/ci.yml package.json scripts/check_protected.sh` пуста. На живом HEAD `check_provodka.sh <root> contracts/039-check-protected-rename.md` → rc 0.

039 несёт `guard=scripts/check_protected.sh`; alias `check:protected` вызывает именно этот script, CI отдельно вызывает `npm run check:protected`, не просто упоминает basename. Аннотация done-тега также фиксирует critic/reviewer accept и `check_protected.sh rc=0 на main`. Поэтому existing done 039 не пропустил отсутствующий reviewer или guard-сироту; Б1/Б2 относятся к будущим входам механизма 038.

Исправление за implementer: ограничить `role=` точным `roles/*.md`; freeze-границу consumers делать fail-closed при сбое утилиты и фиксировать trusted PATH. Push не выполнялся.

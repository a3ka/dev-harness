FAIL
OBJECT=80c0719176da57aec19be8f6613ae9b3e2af20e1

# Critic107r3 — контракт 107, круг 3

**К ВЛАДЕЛЬЦУ: кап достигнут.** Найден один обход внутри закрытого перечня, **К9′(б): полный снимок `RUNTIME_GATE_SNAPSHOT`**. Это повтор класса Бб4, уже разрешённого арбитром; нового требования и расширения перечня нет. Самостоятельный четвёртый круг не назначаю.

АРБИТР: Arbiter107 — спор о полноте runtime-снимка уже разрешён `verdicts/arbitration/contracts-107-perechen-v1.md` на `origin/main`, Решение 2, К9′, и Решение 3, П4. Применяю установленное им последствие FAIL круга 3 → К ВЛАДЕЛЬЦУ, не созываю повторный арбитраж вместо владельца.

## Блокирующая находка

**БЛОКИРУЕТ contracts/107-cmp-mob-003-erstinformation.md:63 — К9′(б) не доказывает полный объявленный снимок: ожидаемое значение берётся из того же проверяемого mock, который производит фактический результат.** Место дефекта критерия: `fixtures/workshop_project/erstinfo_107/erstinfo.test.tsx:504`:

```tsx
expect(snap).toEqual(gateFor('CURRENT_CONFIRMED', 'EQ'));
```

`runtime.api.getDisclosureGate()` вызывает `gateMock()`, а тот вызывает тот же `gateFor` (`model/mocks.disclosure-mock.ts:62–64`). Поэтому `toEqual` здесь сравнивает два одинаково испорченных снимка, а не результат с независимым семипольным оракулом. `responsible_entity_id` — **существующее обязательное клиентское поле** `DisclosureGateSnapshot` (`model/api.api-client.ts:45`), с объявленным значением `re-001` в `source.json`. Это не дополнительное серверное поле, не HTTP и не app-композиция.

ОБХОД: дерево B с моделью OBJECT и двумя заменами — (1) `mocks/disclosure-mock.ts` не возвращает `responsible_entity_id` из `gateFor`, вследствие чего настоящий runtime тоже отдаёт снимок из шести полей; (2) экран при отсутствии этого поля выводит локальный fallback `re-001`. Обычные поведенческая и статическая пробы возвращают **rc=0, 265/265 и 22/22**; обе матрицы **rc=0, 23 и 4 мутанта, defects 0**; унаследованные свидетели **61/61, 2/2, 16/16 и 1/1 — rc=0**. Полнота снимка К9′ не выполнена: мой независимый свидетель сравнивает настоящий runtime с литеральным семипольным оракулом и возвращает **rc=1: отсутствует `responsible_entity_id`**. На неизменённой модели этот же свидетель возвращает **rc=0**.

Точные замены мутанта `full-bypass-omitted-display-fallback` (скрипт `full_bypass.py`):

```diff
# mobile/src/mocks/disclosure-mock.ts
-    responsible_entity_id: FIXED.responsible_entity_id,
+    ...({} as Pick<DisclosureGateSnapshot, 'responsible_entity_id'>),

# mobile/src/features/onboarding/erstinformation.tsx
-        <Text style={[styles.mono, { color: tokens['on-card'] }]}>{snapshot.responsible_entity_id}</Text>
+        <Text style={[styles.mono, { color: tokens['on-card'] }]}>{snapshot.responsible_entity_id || 're-001'}</Text>
```

Проверен также полностью типизированный вариант без assertion/cast: `responsible_entity_id: ''` с тем же display-fallback. Все обычные пробы и унаследованные свидетели зелёные; независимый свидетель — **rc=1**, ожидает `re-001`, получает пустую строку. Его имя — `full-bypass-empty-display-fallback`.

Fallback введён не для подделки проверяющего процесса: он только делает UI внешне полным при неполном runtime-снимке. Нет ветвления по Jest, имени теста, окружению или порядку вызовов; код проб/оракулов не меняется. Это различает полноту возвращённого снимка и полноту его экранной маскировки — именно различение, обещанное К9′(б).

Минимальный однострочный мутант без display-fallback тоже проходит авторские 265+22, но его ловит исправленный runtime-свидетель круга 2. Поэтому **основание FAIL — усиленный мутант выше, прошедший также унаследованных свидетелей**, а не неполная проверка всей приёмки.

Замена `toMatchObject` на `toEqual` недостаточна, если ожидаемое значение по-прежнему контролируется субъектом. Граница исправления — независимый ожидаемый снимок в уже существующей клетке К9′; нового поля, новой продуктовой политики или нового произведения осей не требуется. Сам контракт и пробы я не правил.

## Измеренная полнота перечня

Отдельный `audit.py` строит множества координат из `source.json` и сравнивает их с именами реально исполненных клеток, а не доверяет строке `honest 265/265`:

| Перечень | Ожидается | Исполнено | Пропущено / лишних |
|---|---:|---:|---:|
| К5′ evidence × admission | 96 | 96 | 0 / 0 |
| К6′ action × state × axis × admission | 100 | 100 | 0 / 0 |
| К7′ outcome × moved × admission | 12 | 12 | 0 / 0 |
| К8′ серверная грамматика | 8 | 8 | 0 / 0 |
| К9′ gateFor→screen + runtime | 21 | 21 | 0 / 0 |

Всего 265 различных поведенческих имён, без дублей. К5′+К6′+К7′+К9′ = 229. Количества верны; дефект — в независимости оракула одной клетки, а не в отсутствии её имени.

Чтением и исполнением проверены: полный четырёхкомпонентный вектор эффектов К6′; журнал `ack-start → settled → recheck`, точки до/после settlement и три исхода К7′; подача настоящего `gateFor` в экран по всем 20 координатам К9′. Границы исполнителей названы, зоны присутствуют. Неполного набора артефактов нет. Вопросы о слабости критерия и доказуемости командой имеют конкретный отрицательный ответ только в описанном К9′.

## Новые мутанты внутри перечня

Команда:

```sh
python3 /tmp/dev-harness-verify/Critic107r3/measure.py mutations
```

Код runner — 0; он сохраняет отдельные реальные rc команд в `summary-mutations.json` и `<имя>-erstinfo_probe.log`. Статическая проба на каждом из следующих мутантов — rc=0.

| Мутант | Что изменено | Поведенческая rc | Красные клетки |
|---|---|---:|---|
| new-evidence-four-invalid | совместно пустой ref, другой документ, UNKNOWN applicability, версия 1 допускаются | 1 | 4 К5′, включая `EVIDENCE_PROD_W0_REF2CHK0DOC1APPL1VER1` |
| new-evidence-empty-check-other-doc | сочетание пустого checked_at и другого документа допускается | 1 | 16 К5′ |
| new-retry-open-instead-recheck | retry вызывает open вместо recheck | 1 | 4 К6′ FAILED×axis×admission×RETRY |
| new-back-extra-recheck | back дополнительно перечитывает gate | 1 | 20 К6′ BACK |
| new-continue-extra-ack | continue дополнительно вызывает ack | 1 | `ACTION_VECTOR_W1A_CURRENT_CONFIRMED_EQ_CONTINUE` |
| new-notaccepted-loses-recheck | recheck потерян только при accepted:false | 1 | 4 К7′ NOT_ACCEPTED |
| new-reject-double-recheck | reject вызывает recheck дважды | 1 | 4 К7′ REJECT |
| new-missing-wrong-notice | MISSING отображается как checking | 1 | `DELIVERY_MISSING_W0`, `DELIVERY_MISSING_W1A` |
| new-runtime-empty-checked | runtime возвращает пустой checked_at | 1 | `RUNTIME_GATE_SNAPSHOT` |
| new-runtime-shared-empty-responsible | gateFor и runtime совместно теряют значение responsible id | 0 | нет; независимый свидетель rc=1 |
| new-runtime-shared-omitted-responsible | gateFor и runtime совместно теряют обязательное поле | 0 | нет; независимый свидетель rc=1 |

Отдельная попытка `full-bypass-checked-suffix` не является обходом: испорченный checked_at с суффиксом ` INVALID` пойман `RUNTIME_GATE_SNAPSHOT`, rc=1. Не включаю её в основание FAIL.

Полные обходы с display-fallback проверены командой:

```sh
python3 /tmp/dev-harness-verify/Critic107r3/full_bypass.py
```

Итоговый запуск runner — rc=0; это означает, что проверены ожидаемые сочетания зелёных критериев и красного независимого свидетеля, а не что обход отсутствует. Полные команды Jest, Python, cwd и rc лежат в `full-bypass-*-*.log`, результаты — `summary-full-bypass.json`.

## Пять мутантов круга 2 — контроль П5

Каждый отдельно на новой модели, обычной пробой без `--model`; все пять пойманы клетками перечня. Матрица проверена отдельно, не используется вместо этого контроля.

| Мутант | Статика rc | Поведение rc | Именованная краснота |
|---|---:|---:|---|
| evidence-coabsent-fallback | 0 | 1 | 4 × `EVIDENCE_PROD_*_REF{1,2}CHK1DOC0APPL0VER0` |
| retry-business-transition | 0 | 1 | 4 × `ACTION_VECTOR_*_FAILED_*_RETRY` |
| recheck-before-settlement | 0 | 1 | все 12 `ACK_OUTCOME_*` |
| recheck-success-only | 0 | 1 | 4 × `ACK_OUTCOME_*_REJECT` |
| runtime-incomplete-gate | 0 | 1 | `RUNTIME_GATE_SNAPSHOT` |

Ack-патчи перенесены на формат новой `.finally(...).catch(...)`, сохраняя их смысл. Отозванный matcher `runtime-composed-current-evidence` из большого witness круга 2 не использован ни как блокер, ни как красный контроль. Отдельный исправленный `runtime-witness.test.tsx` исполнялся.

Совместный контроль четырёх исторических мутантов:

```sh
python3 /tmp/dev-harness-verify/Critic107r3/combined_control.py
```

runner rc=0; статическая проба rc=0, поведенческая rc=1, **21 RED**. Логи `combined-erstinfo_{static_probe,probe}.log`.

## База, честная модель и унаследованный регресс

Оба репозитория клонированы по SSH с GitHub; запасное копирование mob не потребовалось. HEAD mobile: `76ac10fac668a1036371c4b392061ce9b3277ebc`. Зависимости установлены собственным `npm ci` (rc=0), кэш внутри каталога сессии. Коммитов/push нет, основной чекаут не трогался.

```sh
python3 /tmp/dev-harness-verify/Critic107r3/measure.py baseline
python3 /tmp/dev-harness-verify/Critic107r3/audit.py
```

Обе команды runner rc=0. Реальные дочерние результаты:

| Дерево / команда | rc | Вывод |
|---|---:|---|
| B / erstinfo_static_probe.py --repo R | 1 | `ERSTINFO_MODULE_ABSENT` |
| B / erstinfo_probe.py --repo R | 1 | `ERSTINFO_COMPONENT_ABSENT` |
| B / erstinfo_static_probe.py --repo R --model | 0 | `static 22/22` |
| B / erstinfo_probe.py --repo R --model | 0 | `honest 265/265` |
| erstinfo_static_probe.py --repo R --matrix | 0 | `mutants 4, defects 0` |
| erstinfo_probe.py --repo R --matrix | 0 | `mutants 23, defects 0` |
| честная модель / мой literal-oracle witness | 0 | 1/1 |
| честная модель / свидетель круга 1, экран | 0 | 61/61 |
| честная модель / свидетель круга 1, API | 0 | 2/2 |
| честная модель / свидетель круга 2, без отозванной клетки | 0 | 16/16; одна отозванная клетка пропущена |
| честная модель / исправленный runtime-свидетель круга 2 | 0 | 1/1 |

R в командах таблицы — `/tmp/dev-harness-verify/Critic107r3/mob`; каждый полный argv записан дословно в соответствующем `.log`. Независимо проверен исправленный `ui_copy_b` SHA-256: `413acaf2736a16d5627cb089dc49f49a224e5a4544c98b3d12fbfe955a7646a1`, совпадает с B. `git status --short --untracked-files=all` после прогона полного обхода: rc=0, stdout пуст (`full-bypass-restoration.log`).

## Формальные двери на OBJECT — дословные команды и rc

cwd: `/tmp/dev-harness-verify/Critic107r3/repo`.

```sh
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic107r3/repo contracts/107-cmp-mob-003-erstinformation.md
# stdout: OK
# rc=0

bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic107r3/repo contracts/107-cmp-mob-003-erstinformation.md
# модель угроз: секция валидна (ЗАЩИЩАЕТ 11 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))
# rc=0

bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic107r3/repo contracts/107-cmp-mob-003-erstinformation.md
# вывода нет
# rc=0

env TMPDIR=/tmp/dev-harness-verify/Critic107r3 bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic107r3/repo contracts/107-cmp-mob-003-erstinformation.md
# КРИТИК: дверь зелёная
# rc=0
```

Сохранено также в `formal-doors.log`. Формальная зелень не заменяет проверку К9′ независимым оракулом.

## Граница решения и артефакты

Блокер ровно один: **неполный клиентский runtime-снимок проходит полный предъявленный критерий благодаря общему источнику фактического и ожидаемого значения и экранному fallback**. Не предъявляю требований к двойному/конкурентному ack, HTTP, app/http-runtime, серверным полям сверх клиентского типа, resume/reconcile/replay или copy signoff. Maestro и PR/Android-приёмка на C не исполнялись: C в задании не представлен, это названная отложенная приёмка.

Все артефакты находятся в `/tmp/dev-harness-verify/Critic107r3/`: `measure.py`, `audit.py`, `full_bypass.py`, `combined_control.py`, `witness.test.tsx`, `coverage.json`, `summary-*.json`, полные `.log` и Jest JSON. Файлы реализации изменялись только временно в одноразовом mobile-клоне и восстановлены. Отчёт не закоммичен по прямому ограничению задания; перенос вердикта в основной репозиторий — за ведущей сессией.

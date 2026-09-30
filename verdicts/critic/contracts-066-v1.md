FAIL

# Контракт 066 — круг 1, пре-заморозочный суд

## Стенограммы и происхождение

Дата: 2026-09-30. Судимый HEAD: `13d5ed834e9a227d655f3e7c58f3d261ab2e839c`.
Предмет: `contracts/066-extractpin-pochinka.md`, закоммиченный blob
`248664d7022167cabe6bedd3c9b1d9b97471de08`.
Клон суда: `/tmp/dev-harness-verify/krit066c`.

- `bash scripts/check_no_leak.sh --check /home/harness/dev-harness` → rc **1**:
  `ОТКАЗ: основной чекаут загрязнён: verdicts/review/contracts-064-v1.md, scripts/proxy/metering_proxy.ts`
  Проверка выполнена локально до записи вердикта в основной репозиторий. Эти пути
  судья не менял; чужая параллельная дельта не исправлялась и снимок не переснимался.
- Последний завершённый CI: `gh run list --repo a3ka/dev-harness --status completed --limit 1 --json headSha,conclusion,databaseId,url,name`
  → rc 0, run `36776655930`, `success`, SHA `53e2a0b90d22a624264739dfe86234131847f5a4`.
  `bash scripts/check_ci_gate.sh /home/harness/dev-harness 53e2a0b90d22a624264739dfe86234131847f5a4`
  → rc **0**: `ok   CI зелёный: проверок 6, все success, по 53e2a0b90d22 (a3ka/dev-harness)`.
  Это последний завершённый CI, НЕ CI судимого HEAD.

Набор артефактов полон: предмет, исполнимая приёмка, исполнитель architect и
ЗОНА-строка присутствуют на HEAD. Реализация в пачке принята как заданный прецедент;
ни контракт, ни реализация этим судьёй не правились.

## Блокирующие находки

### Б1 — precision-гейт не пропускает объявленную зону

БЛОКИРУЕТ contracts/066-extractpin-pochinka.md:134–142 — пропущено пересечение
`.omp/extensions/path-guard.ts` с implementer-зоной 025. Обязательный живой
`bash scripts/check_precision_gate.sh . contracts/066-extractpin-pochinka.md`
завершился rc **1**, а не заявленным в задании rc 0. По норме 043 это блокер.
ОБХОД: precision-гейт 043: зона-коллизия: .omp/extensions/path-guard.ts заявлен architect (этот контракт, NNN 066), уже в union под NNN 025 для implementer — нужна строка ПЕРЕСЕЧЕНИЕ architect: .omp/extensions/path-guard.ts — 025 <причина>

Строка ОБХОД выше — дословный первый вывод команды, как требует норма роли 043.
Существующие пересечения 032/037 не покрывают отдельную запись 025.

### Б2 — приёмка не различает обещанный порядок источников actual

БЛОКИРУЕТ contracts/066-extractpin-pochinka.md:76–78,181–189 — предмет обещает
`call.actual > args.cwd > process.cwd()`, но Р6 предъявляет только eventActual,
а Р7 — только argsActual. Совместного противоречащего входа нет.
ОБХОД: во всех четырёх присваиваниях фабрики заменить
`eventActual ?? argsActual ?? envActual` на `argsActual ?? eventActual ?? envActual`.
Реализация нарушает объявленный приоритет события, но батарея 066 остаётся
12/12 зелёной (rc 0), регресс 032 — 31/31 (rc 0), регресс 037 — 10/10 (rc 0).

Обход предъявлен исполнением, не предположением. Подмена выполнена только в памяти
временного загрузчика исходника; запись через интерпретатор не использовалась.
Дополнительный различающий tool_call фабрики:

```json
{"toolName":"bash","worktree":"/tmp/dev-harness-worktrees/c907157c/wip-066-tester","actual":"/home/harness/dev-harness","input":{"command":"printf x | tee f.txt","cwd":"/tmp/dev-harness-worktrees/c907157c/wip-066-tester"}}
```

Честный субъект:
`{"block":true,"reason":"пинн WORKTREE не совпадает с фактическим рабочим деревом сессии (пин=/tmp/dev-harness-worktrees/c907157c/wip-066-tester, факт=/home/harness/dev-harness)"}`.
Мутант: фабрика возвращает undefined, драйвер печатает `{"decision":"pass"}`.
Проверялась фабрика; команда записи из JSON не исполнялась.
Нужен различающий критерий порядка источников, а не изменение честной реализации.

### Б3 — нормативная привязка стаба к ветви противоречит Н-39

БЛОКИРУЕТ contracts/066-extractpin-pochinka.md:183,186–189 — приёмка закрепляет
«стаб ст2 красит эту клетку» и требует «именованные красные ветви по списку
(3/1/2/5)». AGENTS.md:131–137, шаг 1, прямо запрещает КОНТРАКТУ утверждать пару
«обманный стаб ↔ ветвь»; привязка делается по коду. Это исключение порога:
противоречие норме AGENTS.md блокирует без отдельного ОБХОДА.

Заявленные мутанты действительно предъявлены этим судьёй по коду (см. таблицу),
их фактическая краснота не оспаривается. Дефект — перенос конкретного распределения
ветвей в замораживаемую обязанность Р6/Р8–Р12. Исторический протокол прогонов и
приёмочное требование различать обманную реализацию — не одно и то же.

## Пять обязательных вопросов

1. **Слабее ли критерий предмета?** Да: Б2 — живой мутант с обратным приоритетом
   проходит все три поведенческие батареи. Формы пина и четыре заявленных мутанта
   различаются; это не компенсирует отсутствие конфликтующего входа actual.
2. **Доказуемо ли «готово» командами?** Команды названы и исполнены. Spec-ready rc 0
   не заменяет precision rc 1. Ошибка приоритета не обнаруживается нынешней приёмкой.
3. **Есть ли решение, оставленное исполнителю?** Приоритет назван однозначно;
   проблема не в выборе исполнителя, а в отсутствии различающей клетки. Остаток
   edit/write без call.actual назван явно, не выдан за реализованный канал.
4. **Названы ли границы?** Исполнитель architect, зона и check_zones названы;
   реально применённый precision выявил неполное объявление пересечений — Б1.
   Генерат проверяется штатным gen:harness; второго источника нормы не заведено.
5. **Противоречит ли AGENTS.md?** Б3. Н-48 соблюдена: полного раннера/полного
   project-wide CI локально не было; использованы scoped-команда и прямые
   probe-only батареи. Модель угроз содержит оба списка; её формальный гейт rc 0.

## Живые проверки

| Команда / сценарий | rc | Наблюдение |
|---|---:|---|
| `bash fixtures/path_guard/red_extract_pin_actual_066.sh .` | 0 | 12 ветвей, красных 0, зелёных 12 |
| `bash scripts/verify_antiplacebo.sh . --scope spawn_agent` | 0 | 1 барьер, 2 фикстуры; это НЕ 31 ветвь 032 |
| `bash scripts/verify_antiplacebo.sh . --scope self_contained_cwd` | 1 | `FAIL scope_select отказал (код 1):`; probe-only семья не является scope-ключом |
| `bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .` | 0 | ИТОГ 032: 31 ветвь, красных 0, зелёных 31 |
| `bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .` | 0 | ИТОГ 037: 10 ветвей, красных 0, зелёных 10 |
| `bash scripts/check_precision_gate.sh . contracts/066-extractpin-pochinka.md` | 1 | Коллизия 025 — Б1 |
| `bash scripts/check_provodka.sh . contracts/066-extractpin-pochinka.md` | 0 | Без отказа |
| `bash scripts/check_spec_ready.sh . contracts/066-extractpin-pochinka.md` | 0 | `OK`; случайные пробы не блокируют эту версию |
| `npm run gen:harness -- --check` | 0 | `харнес соответствует roles/ (9 ролей)` |
| `bash scripts/check_nabludenia.sh .` | 0 | Статусные группы валидны |
| `bash scripts/check_threat_model.sh . contracts/066-extractpin-pochinka.md` | 0 | ЗАЩИЩАЕТ 2 буллета, НЕ ЗАЩИЩАЕТ 3 |
| Мутант без /m | 1 | Красных 3: а0дв/а1/а1б |
| Мутант без исключения двоеточия | 1 | Красных 1: а2 |
| Мутант eventActual=null, argsActual=null | 1 | Красных 2: б2/б3 |
| Мутант без /m + оба источника actual=null | 1 | Красных 5: а0дв/а1/а1б/б2/б3 |
| Мутант argsActual перед eventActual: 066 / 032 / 037 | 0 / 0 / 0 | Обход Б2 |
| Различающая проба конфликта: честный / мутант | 0 / 0 | Проверяющий подтвердил соответственно block / pass |

ДО-краснота пяти клеток взята из предъявленного исторического протокола автора,
не выдаётся за новый прогон прежнего дерева. Повторно прогонялись только мутанты
текущего субъекта и честный текущий субъект.

## Три дословные живые формы пина

Подготовлен настоящий linked worktree на ветке `wip/066/tester`, затем выполнены:

```bash
node .omp/extensions/path-guard.ts --extract-pin $'Complete assignment thoroughly:\nWORKTREE=/tmp/dev-harness-worktrees/c907157c/wip-066-tester\nBRANCH=wip/066/tester'
node .omp/extensions/path-guard.ts --extract-pin $'Complete assignment thoroughly\nWORKTREE=/tmp/dev-harness-worktrees/c907157c/wip-066-tester\nBRANCH=wip/066/tester'
node .omp/extensions/path-guard.ts --extract-pin 'pin:WORKTREE=/tmp/dev-harness-worktrees/c907157c/wip-066-tester:BRANCH=wip/066/tester'
```

Каждая команда → rc 0 и дословно:
`{"worktree":"/tmp/dev-harness-worktrees/c907157c/wip-066-tester"}`.

## ПРОВОДКА, остаток и неизменность

Role-канал честен: норма реально есть в `roles/architect.md:345`, генерат ей
соответствует, check_provodka rc 0. Фантомный guard-путь не заявлен.
Фабрика реально регистрирует tool_call; её решения исполнены батареей и пробой
конфликта. В `.github/workflows/ci.yml` и `package.json` прямого path-guard-провода
нет. Суд не подменяет этим наблюдением доказательство загрузки обновлённого
расширения КАЖДЫМ живым omp-демоном: отдельный daemon-start smoke здесь не выполнялся.

СОВЕТ contracts/066-extractpin-pochinka.md:154–159 — фраза «исполнение на каждом
 tool_call уже сильнее CI-шага» смешивает runtime-энфорсмент с регрессионной
проверкой. Обоснование отсутствия guard-канала именовано (А-238/А-299), role-канал
не фантомен, но автоматический прогон красной батареи этим не доказывается.
Точнее различать эти два свойства, не обещая покрытие CI там, где его нет.

Остаток `contracts/066-extractpin-pochinka.md:199–208` корректно именован:
edit/write без call.actual не открывает М1-п.5; ловец — проба при обновлении omp,
митигация — пин либо bash с cwd. Это не скрытое объявление полной починки omp.
А-304 (`NABLIUDENIA_ARCHITECT.md:7328`) имеет последнюю статусную группу ЗАКРЫТО;
А-305 (:7351) — ОТКРЫТО с адресом «очередь автономности». Грамматика 015 зелёная.
Урок А-298 по ПРОВОДКЕ предъявлен rc 0; урок А-302 — rc 0 spec-ready. Однако
precision не зелёный, поэтому утверждать «все гейты заморозки пройдены» нельзя.

Для каждого NNN=061…065 выполнен `git diff --exit-code frozen/contracts/NNN/1 HEAD -- <соответствующий contracts/NNN-*.md>`:
все пять diff пустые, rc 0. Дополнительно diff кодового коммита
`4e391301cc110ee0d7b1e0b26aed178675bed89e^..4e391301cc110ee0d7b1e0b26aed178675bed89e`
по `scripts fixtures .github package.json contracts/061* … contracts/065*` пуст,
rc 0. Это точные области сверки, не заявление о неизменности всех файлов истории.

Итог: заморозку не разрешать. Б1 — механический отказ, Б2 — исполненный обход
критерия, Б3 — прямое противоречие нормативной приёмки Н-39.

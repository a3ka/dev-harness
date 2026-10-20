accept

# Критик 109 v3 — только дельта путей

OBJECT: `3f129ec91cd34402ef073cfeef3325bf80789db6`.
Предмет: `contracts/109-cmp-bck-004-stend-evidence.md` на HEAD собственного клона; сравнение с `frozen/contracts/109/2^{commit}`. Дата: 2026-10-20. Роль: Critic109v3.

**В пределах порученной дельты действительных блокирующих находок нет.** Предмет, инварианты и восемь строк приёмки совпадают с v2 после перечисленных в свидетельстве замен путей, переноса npm-команд в корень пакета и обозначения версии батареи. Ни причина отказа, ни порог, ни число клеток/фактов в тексте не ослаблены. Потерь покрытия прежних путей не обнаружено. Два замечания ниже — СОВЕТ, а не скрытые условия accept.

Это разрешение дельты контракта, **не приёмка реализации и не утверждение зелёного полного прогона**. Известный форк `forks/n109-pre-critic-036.md` не снят; `pre_critic.sh` и известное красное CI `check:contract-frozen` повторно не проверялись. Основной checkout/worktree и origin не изменялись; push не выполнялся.

## Находки

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:49 — сохранённый пин B и перенесённый historical-хэш сейчас расходятся. Строка 16 продолжает определять B как `9d960a0543eb36696b1d767bf208416e774f0a32`, а батарея HEAD использует для обеих раскладок новый SHA256 `2ea5d921…`; исходный B содержит `8c1922c3…`. Живой прогон на точном B: rc 1, `ROOT_SERVER_PRESENT=false`, `root_server_delete=NOT_REJECTED` (1 REJECTED_EXACT / 51 BLOCKED / 1 NOT_REJECTED). Это не обещанные в строке 49 зелёный historical-факт и отвергнутая клетка. На новой базе `11432a3…` тот же прогон даёт требуемые четыре причины контроля, historical-факт True и 2 REJECTED_EXACT / 51 BLOCKED. Стоит согласовать старый B с раскладочно-зависимым historical-пином либо явно различить старую и новую базу. Это ложное красное/несогласованность воспроизводимости, а не предъявленный обход с выполненным критерием и несделанным предметом; по установленному порогу не блокирует.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:67 — перенос директорий сохраняет все прежние файлы, но разрешённое множество не тождественно прежнему. В новой зоне дополнительно оказываются 10 файлов бывшего `tools/` помимо уже разрешённого `run_backend_ci.py`, например `tests/tools/check_backend_structure.py`, `tests/tools/generate_derived.py`, `tests/tools/verify_handoff.py`, и новый `server/infrastructure/billing/stripe-client.js.obrazec`. Основание появления — объявленное объединение `tools + backend/scripts → tests/tools/` и инфраструктуры под `server/`; это не потеря пути. При раздаче полезно явно сохранить предметную границу для соседних инструментов либо перечислить нужные файлы вместо объединённого каталога. Полный список 11 дополнительно покрытых файлов — `path-audit.json`. Конкретного состояния «критерий выполнен, предмет не сделан» этим замечанием не предъявлено; не блокирует.

## Проверка пяти вопросов

1. **Критерий слабее предмета:** в дельте нет изменения смысла предмета/инвариантов/приёмки после нормализации путей. Старые декои `backend/compose.dev.yml` и `backend/tests/helpers/harness.js` не скрывают удаление действующих новых файлов: живой структурный контроль возвращает соответственно `COMPOSE_MISSING` и `HARNESS_MISSING`.
2. **Доказуемость названными командами:** команды перенесены на действующие пути, rc-требования прежние. Ограничения фактического прогона C и несогласованность B указаны явно ниже и в совете, не заменены заявлением о зелёном.
3. **Необъявленное решение исполнителю:** новых смысловых решений в дельте не найдено. Обновление продуктовых `STEND109_PIN`/`STEND109_TAG` после заморозки прямо отдано implementer строкой 4; существующий продуктовый пин не объявляется уже обновлённым.
4. **Границы:** исполнители и ЗОНА/ПЕРЕСЕЧЕНИЕ названы. Все 111 существовавших на B файлов старой implementer-зоны имеют существующие и покрытые зоной v3 целевые пути на `11432a3…`. Из 19 путей новой зоны 17 существуют, два создаются предметом. Побочное расширение вследствие слияния директорий отмечено советом.
5. **AGENTS.md:** противоречия норме в судимой дельте не установлено. Числа проверены отдельно AST-сверкой замороженной и текущей батарей и подсчётом фактических строк JSON трёх запусков, не только самодекларацией батареи. Precision-гейт и форма модели угроз реально исполнены, оба rc 0.

## Карта implementer-путей v2 → v3

| v2 | v3 |
|---|---|
| `infra/` | `server/infrastructure/` + `docs/infrastructure/` |
| `backend/compose.dev.yml` | `compose.dev.yml` — создаётся предметом |
| `backend/tests/helpers/harness.js` | `tests/helpers/harness.js` — создаётся предметом |
| `backend/tests/integration/` | `tests/integration/` |
| `backend/server/` | `server/` |
| `backend/app/config/` | `app/config/` |
| `backend/scripts/` | `tests/tools/` |
| `backend/package.json` | `package.json` |
| `backend/package-lock.json` | `package-lock.json` |
| `tests/run_sql_3_9_native.py` | `tests/spec-3.14/run_sql_3_9_native.py` |
| `evidence/runs/` | `docs/evidence/runs/` |
| `docs/backend/` | без изменения |
| `tools/run_backend_ci.py` | `tests/tools/run_backend_ci.py` |
| `.github/workflows/ci.yml` | без изменения |
| `FILES.sha256` | без изменения |
| `VERSION_MANIFEST.json` | `docs/VERSION_MANIFEST.json` |
| `VALIDATION.json` | `docs/VALIDATION.json` |
| `README_RU.md` | `docs/README_RU.md` |

Дополнительно сверены пути приёмки: `db/ → migrations/`, `backend/Dockerfile → Dockerfile`, historical `server/ → tests/historical-server/`. Diff historical harness содержит перенос путей; `src/app.ts` не изменён. Исторический каталог и миграции не включены в implementer-зону вместо прежнего runtime server.

## Lane и числа

- В HEAD `LANE_FROZEN_TAG = 'frozen/contracts/109/3'`.
- `git for-each-ref` собственного клона показывает только `109/1` и `109/2`; механизм `scripts/freeze_contract.sh:276–290` вычисляет `max(v)+1`, то есть следующая версия — 3. Согласование имени пина установлено; заморозка не выполнялась и экспериментальный тег не создавался.
- AST замороженной и текущей батарей: **53 → 53**, пары «имя клетки / целевая причина» неизменны; **15 → 15**, имена фактов неизменны.
- Все 53 мутирующие функции на новой структуре фактически меняют байты; ни один их путь не остался под `backend/`, `infra/`, `db/`, старым `evidence/`.
- На C `b73ad11da0c9b74386cd5cafe73eeb110a1fdaff`: **14 True / 1 None**, **52 REJECTED_EXACT / 0 BLOCKED / 1 NOT_REJECTED**, контроль без структурных причин. Единственные неполные элементы — `LANE_HYGIENE_GUARD=None` и `lane_dirty_checkout_ok=NOT_REJECTED`: в клоне ещё нет тега `frozen/contracts/109/3`. Фактический общий **rc 1**, не rc 0 и не rc 2: NOT_REJECTED имеет приоритет при возврате. Это не доказательство зелёной приёмки C и не основание обходить последующую проверку lane после законной заморозки.
- Остальные 14 фактов C действительно измерены, в том числе подъём/re-up PG18 с ledger 14 и неизменными строками, исполнение коллектора/harness, lint и именованный delivery-тест на PG18. Отдельный полный `npm run test:integration` и отдельная команда egress из строки 4 мною не выполнялись.

## Команды и сохранённые свидетельства

Все пути ниже — под `/tmp/dev-harness-verify/Critic109v3/`. `repo` — собственный клон HEAD предмета; `base` — `11432a3…`; `base-old` — точный B `9d960a…`; `back` — C `b73ad11…`.

1. `git -C /tmp/dev-harness-verify/Critic109v3/repo rev-parse HEAD` — rc 0, OBJECT совпал.
2. `git -C /tmp/dev-harness-verify/Critic109v3/repo diff 'frozen/contracts/109/2^{commit}' HEAD -- contracts/109-cmp-bck-004-stend-evidence.md` — rc 0; реальная дельта сохранена как `contract-real.diff`.
3. `python3 /tmp/dev-harness-verify/Critic109v3/audit_paths.py` — rc 0; `path-audit.json`: карта, существование путей через `git cat-file -e`, отсутствие потерь, дополнительные файлы, независимая AST-сверка чисел и нормализация текста приёмки.
4. `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic109v3/repo contracts/109-cmp-bck-004-stend-evidence.md` из `repo` — rc 0, `OK`.
5. `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic109v3/repo contracts/109-cmp-bck-004-stend-evidence.md` из `repo` — rc 0; 8 защищаемых / 4 незащищаемых свойства.
6. Подготовка зависимостей: `npm ci --ignore-scripts` из `back`, `base`, `base-old/backend` — каждый rc 0; предупреждение движка Node 26.5.1 вместо 24.22.0 сохранено в выводе, не подавлялось.
7. `env TMPDIR=/tmp/dev-harness-verify/Critic109v3 python3 /tmp/dev-harness-verify/Critic109v3/repo/fixtures/workshop_project/stend_109/probe.py --repo /tmp/dev-harness-verify/Critic109v3/base --out /tmp/dev-harness-verify/Critic109v3/run-base` — rc 1; `run-base/raw.json`, четыре ожидаемые причины, 53 клетки / 15 фактов, 2 REJECTED_EXACT / 51 BLOCKED.
8. `env TMPDIR=/tmp/dev-harness-verify/Critic109v3 python3 /tmp/dev-harness-verify/Critic109v3/repo/fixtures/workshop_project/stend_109/probe.py --repo /tmp/dev-harness-verify/Critic109v3/base-old --out /tmp/dev-harness-verify/Critic109v3/run-old` — rc 1; `run-old/raw.json`, несогласованность historical-пина из совета.
9. `env TMPDIR=/tmp/dev-harness-verify/Critic109v3 python3 /tmp/dev-harness-verify/Critic109v3/repo/fixtures/workshop_project/stend_109/probe.py --repo /tmp/dev-harness-verify/Critic109v3/back --out /tmp/dev-harness-verify/Critic109v3/run-c` — rc 1; `run-c/raw.json`, 52 REJECTED_EXACT, единственная непроверенная lane-клетка описана выше.
10. `env PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Critic109v3/smoke_paths.py` — rc 0; `smoke-paths.json`, 53 действительные мутации и две красные проверки новых путей при старых декоях.
11. `env TMPDIR=/tmp/dev-harness-verify/Critic109v3 python3 /tmp/dev-harness-verify/Critic109v3/repo/fixtures/workshop_project/stend_109/probe.py --repo /tmp/dev-harness-verify/Critic109v3/base --case nonexistent` — rc 2, `109 UNMEASURABLE: EMPTY_SELECTION`.
12. `python3 /tmp/dev-harness-verify/Critic109v3/summarize.py` — rc 0; `summary.json`, независимый подсчёт фактических клеток/фактов и имён неотвергнутых клеток трёх запусков.

Полный регресс харнесса не запускался: суд ограничен порученной дельтой 109 v3. Вердикт предназначен для переноса оркестратором на ветку предмета; разрешения писать в основной checkout у этого субагента нет.

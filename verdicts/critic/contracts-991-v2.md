accept

# Критик — контракт 991 v2 (дельта Дс5), круг 2

OBJECT=3d4df808193f818a38ec8d8389c4fae91955a56b
Предмет: `contracts/991-complior-repeticiya-p107-p111.md` на `wip/991/architect` @ `3d4df8081` против `frozen/contracts/991/1`. Это коммит `3d4df8081` поверх `ee88443ec`, а `ee88443ec` был предметом круга 1.
Круг 1: `verdicts/critic/contracts-991-v2.md` @ `b2ef4e5e` — FAIL, один БЛОКИРУЕТ: guard `probe.py` из ПРОВОДКИ отсутствовал.
Судья: роль critic. Клон `/tmp/dev-harness-verify/crit991r2-1792262030344293584/repo`, клон Complior-mob (база `8a699d17…`) `/tmp/dev-harness-verify/crit991r2-1792262030344293584/complior`.

## Набор артефактов

Набор полон. Предмет, критерий с командами (`:68–96`), исполнители и `ЗОНА`-строки (`:99–102`, `:107`) на месте, всё закоммичено на HEAD предмета. Дверь `make_task.sh --repo /tmp/dev-harness-worktrees/c907157c/wip-991-architect --role critic --contract 991 --model-trace …` перечитана собственным вызовом, rc 0. Worktree двери стоит на том же HEAD `3d4df8081`.

## Закрытие блокера круга 1 (проверено живьём)

| команда | rc | вывод |
|---|---|---|
| `git ls-tree -r fc8a8898 / HEAD -- fixtures/workshop_project/rehearsal_991/` | 0 | `probe.py` `3a190bf6`, `model.tsx` `822f8465`, `.probe-only` `ee4c3d0f`, `rehearsal.test.tsx` `2661187c` и `rehearsal.yaml` `3097f64b` на HEAD побайтно (по blob-id) равны объекту `fc8a8898`, который судил v1 |
| `git diff --stat ee88443ec HEAD` | 0 | изменены только три восстановленных файла (+118). Текст контракта с круга 1 не менялся |
| `check_provodka.sh <клон@3d4df808> <контракт>` | 1 | `guard не подключён: …probe.py не вызывается в .githooks/ или .github/workflows/` |
| `check_provodka.sh <worktree@fc8a8898> <контракт>` | 1 | тот же вывод, слово в слово: это унаследованное состояние принятого v1 |
| `check_provodka.sh <worktree@ee88443e> <контракт>` | 1 | `guard-файл не существует: …probe.py`: класс блокера круга 1 воспроизведён на старом предмете |
| `python3 -c ast.parse(probe.py)` | 0 | файл разбирается |

Итог: класс отказа сменился с «guard-файл не существует» (нарушение `AGENTS.md:175`, «канал существует») на «guard не подключён». Это ровно то состояние, которое было на принятом v1-объекте. Блокер круга 1 закрыт.

## Пересверка дельты против frozen v1

| команда | rc | вывод |
|---|---|---|
| `git rev-parse frozen/contracts/991/1:<контракт>` | 0 | `fc3ffa9c`. Тот же блоб у `149433ba` и `fc8a8898` |
| `git diff frozen/contracts/991/1 HEAD -- <контракт>` | 0 | 16+/4−: `:1` заголовок, `:115–127` Дс5 + YAML, `:132` фазы, `:134` ограничения. Остальное побайтно v1 |
| `git diff --stat fc8a8898 HEAD -- fixtures/…/rehearsal_991/` | 0 | `compare_carriers.py` +30, `matrix_carriers.py` +50/−1, `smoke_carriers.py` новый +136. Все правки только про Дс5 (`DISK_SPACE`, `disk_required`, соседство KVM→NATIVE, матрица Ds5-*). Прочие фикстуры равны `fc8a8898` |
| `compare_carriers.py --repo <complior> --base 8a699d17… --matrix` | 0 | `executed=63 mismatches=0`. Ds5-missing / duplicate / changed-* / missing-* / extra-if / extra-continue-on-error / extra-env / extra-uses, позиции 0–7 и 9–13, wrong-workflow / job / phase-negative / phase-freeze — каждый rc 1 `CARRIER_CHANGED` |
| `git show 8a699d17:.github/workflows/mobile-cloud-e2e.yml` | 0 | порядок шагов: `Сборка release-APK` → `Maestro` → `KVM` → `Эмулятор API 36 + сценарии Maestro`. Позиция Дс5 «после сборки, между KVM и эмулятором» соответствует реальной базе |
| `python3 fixtures/…/smoke_carriers.py` | 0 | CLI honest-positive 0, missing-Ds5 1, altered-Ds5 1, moved-Ds5 1, synthetic matrix `executed=58 mismatches=0`; `git status` после прогона чист |
| `pre_critic.sh --repo <клон> <контракт>` | 0 | `КРИТИК: дверь зелёная` |
| `check_threat_model.sh` | 0 | ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 4 |
| `check_precision_gate.sh <клон> <контракт>` | 0 | `OK` |
| `check_spec_ready.sh` / `check_consumers.sh` | 0 / 0 | `OK` / — |

Поправка к брифу оркестратора: дельта фикстур против v1 — это не только `compare_carriers.py` и восстановленные guard-файлы. К ней относятся ещё `matrix_carriers.py` (+50/−1) и новый `smoke_carriers.py`. Обе правки лежат в предмете Дс5 и в ЗОНА architect `:99`, поэтому ни один из них не меняет вердикт.

## Находки

Блокирующих нет. Обход, при котором критерий Дс5 выполнен, а предмет не сделан, не найден: литерал сравнивается целиком, позиция и фаза закреплены кодом, 63/0 на реальной базе, а достаточность места доказывает зелёный cloud-run шага 6 (`:134`).

СОВЕТ (оркестратору, к заморозке) — дерево тега `frozen/contracts/991/1` (`28e3a711`) НЕ содержит `fixtures/workshop_project/rehearsal_991/` вообще. Проверено: `git ls-tree -r frozen/contracts/991/1^{commit} fixtures/workshop_project/rehearsal_991/` пуст, а на `origin/main` каталога тоже нет. Причина в способе заморозки v1: «точечный перенос contracts/991-*.md» (`149433ba`). Если v2 заморозить тем же переносом, на замороженном объекте снова не будет `probe.py`/`compare_carriers.py`. Это ровно тот обход, который назвал круг 1: позже в ЗОНА architect можно положить guard, которого критик не видел. Мера: дерево, на котором ставится `frozen/contracts/991/2`, обязано нести все восемь файлов `fixtures/workshop_project/rehearsal_991/` с blob-id, равными `3d4df8081`. Проверка — `git diff --exit-code 3d4df808193f818a38ec8d8389c4fae91955a56b <freeze-commit> -- fixtures/workshop_project/rehearsal_991/ contracts/991-complior-repeticiya-p107-p111.md`, rc 0. Это процедура заморозки, а не текст контракта, и состояние унаследовано от v1, поэтому здесь не блокирует. Но этот accept относится к объекту `3d4df8081` целиком, вместе с фикстурами.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:163–166 — `check_provodka.sh` даёт rc 1 «guard не подключён». `done_contract.sh` (шаг 6) требует rc 0, значит done для 991 при нынешнем тексте механически невозможен. Строка `ПРОВОДКА-ЭНФОРСМЕНТ:` `:166` этот rc не снимает: проверено, вывод тот же. Состояние унаследовано от v1 и в дельту v2 не входит. Решать до done-гейта, а не после реализации.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:172 — замер «`--matrix` → executed=30» устарел: живой прогон на той же базе даёт `executed=63`. Число — вывод раннера, а не критерий. Поправить, чтобы reviewer не сверял его с несуществующим числом.

Остальные пять советов круга 1 остаются в силе и не блокируют (`b2ef4e5e`): `:1` суффикс «(v2, черновик)»; `:134` `df` без rc-меры; `:131–132` недельный cloud после freeze-merge ожидаемо красный без Дс5; `:146–158` Дс5 вне НЕ ЗАЩИЩАЕТ; `smoke_carriers.py` `TemporaryDirectory(dir=HERE)`. Прошлый совет про заголовок `666a229fa` касается истории, а не текста.

## Пять вопросов (сводно)

1. Критерий Дс5 не слабее предмета: обход не предъявлен, 63/0 на реальной базе плюс CLI-smoke через настоящие Git-объекты.
2. Каждый пункт Дс5 проверяется командой с rc: `compare_carriers.py --phase positive`, `--matrix`, cloud-run шага 6.
3. Молча оставленных решений в дельте нет: литерал, позиция, job и фаза названы.
4. Границы: Дс5 лежит в `.github/workflows/mobile-cloud-e2e.yml` (ЗОНА implementer `:107`), фикстуры в ЗОНА architect `:99`.
5. `AGENTS.md:175`, часть «существует»: оба guard-файла на предмете есть. Часть «подключён» — done-гейт, унаследована от v1, см. совет выше.

Причина круга 1 закрыта и не повторена, арбитр не созывается.

## Precision-гейт (норма 043)

`bash scripts/check_precision_gate.sh <клон> contracts/991-complior-repeticiya-p107-p111.md` → rc 0, `OK`.

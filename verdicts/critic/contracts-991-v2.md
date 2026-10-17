FAIL

# Критик — контракт 991 v2 (дельта Дс5)

OBJECT=ee88443ec664732d55139d250c7da44e2cfe9c09
Предмет: `contracts/991-complior-repeticiya-p107-p111.md` на `wip/991/architect` @ `ee88443ec`, против `frozen/contracts/991/1`.
Санкция v+1: `docs/owner/2026-10-17-resheniya-1810.md` §4 (на origin/main, `dfec9fcb`); строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` дословно стоит в теле `666a229fa`.
Судья: роль critic. Клон `/tmp/dev-harness-verify/critic-991-v2-1792261539851475119/repo`.

## Набор артефактов

Полон: предмет, критерий с командами, исполнители, `ЗОНА`-строки (`:99–102`, `:107`) есть, всё закоммичено на HEAD предмета. Разбор по существу проведён.

## Что прогнано (живьём, в клоне)

| команда | rc | вывод |
|---|---|---|
| `python3 -B fixtures/workshop_project/rehearsal_991/smoke_carriers.py` | 0 | CLI: honest-positive 0, missing-Ds5 1, altered-Ds5 1, moved-Ds5 1; matrix synthetic `executed=58 mismatches=0` |
| `python3 -B fixtures/workshop_project/rehearsal_991/compare_carriers.py --repo <клон Complior-mob> --base 8a699d175114f82395e019964ee1fec02a6bb200 --matrix` | 0 | `executed=63 mismatches=0`; каждая позиция Дс5 0–13, кроме честной, — rc 1; изменение/отсутствие каждого из 5 ключей, лишние `if`/`continue-on-error`/`env`/`uses`, дубликат, не тот workflow/job/фаза — rc 1 `CARRIER_CHANGED` |
| `gh api …/mobile-cloud-e2e.yml?ref=8a699d17…` | 0 | в реальной базе шаг `KVM` стоит непосредственно перед `Эмулятор API 36 + сценарии Maestro`: проверка соседства в `compare_carriers.py` опирается на настоящую структуру, а не на синтетическую |
| `bash scripts/pre_critic.sh --repo <клон> <контракт>` | 0 | `КРИТИК: дверь зелёная` |
| `bash scripts/check_threat_model.sh <клон> <контракт>` | 0 | ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 4 |
| `bash scripts/check_precision_gate.sh <клон> <контракт>` | 0 | `OK` |
| `bash scripts/check_spec_ready.sh` / `check_consumers.sh` | 0 / 0 | — |
| `bash scripts/check_provodka.sh <клон> <контракт>` | **1** | `проводка: guard-файл не существует: fixtures/workshop_project/rehearsal_991/probe.py` |

## Сверка, что диф ограничен заявленным

`git diff frozen/contracts/991/1 HEAD -- contracts/991-…md`: 16+/4−, четыре hunk-а — заголовок `:1`, буллет Дс5 с YAML `:115–127`, строка фаз `:132`, абзац ограничений `:134`. Прочий текст контракта побайтно равен v1. Буллеты-ограничения `:135–140` (quality/expo-versions целиком, верхние ключи, набор jobs, ключи job, существующие шаги и порядок, `mobile/scripts/`) не тронуты. Литерал Дс5 в контракте (`:118–127`), `DISK_SPACE` в `compare_carriers.py` и `DISK` в `smoke_carriers.py` дают один и тот же объект: эквивалентность подтверждает honest-positive rc 0 на обеих базах.

`compare_carriers.py` против `fc8a8898` (объект, который судил v1): +30 строк, и все они про Дс5 (docstring, `DISK_SPACE`, `disk_required`, ветка соседства KVM→NATIVE, `missing-Ds5`). `rehearsal.test.tsx` и `rehearsal.yaml` равны `fc8a8898` байт в байт.

## Находки

БЛОКИРУЕТ contracts/991-complior-repeticiya-p107-p111.md:163 — ПРОВОДКА называет `guard=fixtures/workshop_project/rehearsal_991/probe.py`, а на предмете `ee88443ec` этого файла нет. Это прямо противоречит `AGENTS.md:175` («каждый канал нормы существует»), `check_provodka.sh` даёт rc 1. Причина: коммит `ee88443ec` восстановил каталог из `fc8a8898` не целиком. `git diff --stat fc8a8898 ee88443ec -- fixtures/workshop_project/rehearsal_991/` показывает удаление `probe.py` (−86), `model.tsx` (−25) и `.probe-only` (−7). Критик v1 судил дерево, в котором эти файлы были. Регрессия измеряется против принятого v1-объекта, а не против main. Без этих файлов первые два пункта приёмки (`:68`, `:69` — `probe.py --repo R` и `--matrix`) нечем исполнить, а замер `:170` («`probe.py` → rc 1, executed=2; `--matrix` → rc 0, executed=6») не воспроизводится на предмете.
ОБХОД: если заморозить это дерево, H не несёт `probe.py`. Позже architect в своей зоне кладёт новый `probe.py`, которого критик не видел. Например, такой: на базе печатает `executed=2` и rc 1, потому что в `start-screen.tsx` нет строки `Prüfung starten`, а на любом C с этой строкой печатает rc 0, `executed=2` и rc 0 на `--matrix`. Пункты `:68–69` выполнены по букве, но поведение (нажатие, результат, reset) не проверено. По Н-39 привязки контрмоделей живут ТОЛЬКО в коде, и этого кода в предмете нет.
ЗАКРЫТИЕ (дёшево, текст контракта не меняется, санкция владельца не нужна, работа в ЗОНА architect `:99`): `git checkout fc8a8898 -- fixtures/workshop_project/rehearsal_991/probe.py fixtures/workshop_project/rehearsal_991/model.tsx fixtures/workshop_project/rehearsal_991/.probe-only` байт в байт, затем коммит. Проверено в клоне: после восстановления `check_provodka.sh` больше не пишет `guard-файл не существует`. Остаётся `guard не подключён … не вызывается в .githooks/ или .github/workflows/`, но то же состояние было и на принятом v1-объекте (проверено: тот же вывод при файлах из `fc8a8898`); как его закрывает `ПРОВОДКА-ЭНФОРСМЕНТ:` `:166`, решает done-гейт, а не этот круг. В предмет v2 оно не входит и здесь не блокирует.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:1 — суффикс заголовка `(v2, черновик)` к Дс5 не относится, а санкция §4 звучит как «остальной текст без изменений». Слово «черновик» уедет в замороженный блоб. Лучше вернуть заголовок v1: версию и так несёт тег `frozen/contracts/991/2`.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:134 — фразу «сохранённым выводом `df` до/после» не проверяет ни одна rc-команда. Сейчас это диагностика, а критерием остаётся зелёный cloud-run шага 6. Это достаточно: если места не хватит, run покраснеет. Если нужна мера, вот она: reviewer ищет в логе job две строки `df` и видит рост `Avail`.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:131–132 — Дс5 разрешён только в positive. Freeze-PR (Д3 трогает cloud) после merge владельцем попадёт под недельный schedule без Дс5, и этот cloud-прогон ожидаемо упадёт по диску, пока не смёржен positive. Это не обход критерия: freeze судится только station-run, `:43`. Стоит назвать это ожидаемым красным, чтобы никто не принял его за регресс.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:146–158 — Модель угроз не упоминает Дс5. Секция валидна (rc 0), литерал зафиксирован и сравнивается целиком, поэтому пробела в защите нет. Можно добавить в НЕ ЗАЩИЩАЕТ одну строку: достаточность места и то, что удалённые пути не нужны эмулятору, доказывает только живой cloud-run.

СОВЕТ fixtures/workshop_project/rehearsal_991/smoke_carriers.py — временное Git-хранилище создаётся внутри дерева харнеса (`TemporaryDirectory(dir=HERE)`). Его убирает finally, но при SIGKILL внутри fixture-зоны останется `.carrier-smoke-*`. Лучше использовать `dir=None`.

СОВЕТ — заголовок коммита `666a229fa` («not authorized for freeze») противоречит его собственному телу и `docs/owner/…-1810.md` §4. На механику не влияет, но читателю истории мешает.

## Пять вопросов (сводно)

1. Критерий Дс5 не слабее предмета: точное равенство объекта, соседство KVM→NATIVE в B и в C, ровно одно вхождение, только positive/cloud/`android-e2e-cloud`. Каждое отклонение даёт красный в коде (63/0 на реальной базе). Обход, принятый сравнителем, не найден. Блокер — пропавший `probe.py`, см. выше.
2. Каждый пункт Дс5 доказывается командой с rc: `compare_carriers.py --phase positive` и `--matrix`. Достаточность диска доказывает cloud-run шага 6.
3. Молча оставленных решений в Дс5 нет: литерал полный, позиция и фаза названы.
4. Границы: Дс5 лежит в `.github/workflows/mobile-cloud-e2e.yml`, это ЗОНА implementer `:107`. Фикстуры лежат в ЗОНА architect `:99`.
5. Норма `AGENTS.md:175` нарушена отсутствующим guard-файлом. Это блокер.

Повтора причины прежних FAIL (круги 1–2 v1) нет, арбитр не созывается.

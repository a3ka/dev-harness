FAIL

# Критик — контракт 992, круг 1

Предмет: `contracts/992-oshibka-eto-otkaz.md` на `wip/992/architect`, HEAD `e763ec4b7d065704fa40f9f18066193d6dc3844e`.
Клон: `/tmp/dev-harness-verify/critic992r1-3539070/repo` (SSH-клон origin).

Набор артефактов полон: предмет, критерий с командами, исполнители, `ЗОНА`-строки, модель угроз —
есть и закоммичены. Разбор по существу ниже.

## Живые прогоны (cwd = корень клона)

|команда|rc|итог|
|---|---|---|
|`bash scripts/pre_critic.sh --repo . contracts/992-oshibka-eto-otkaz.md`|0|`КРИТИК: дверь зелёная`|
|`bash scripts/check_precision_gate.sh . contracts/992-oshibka-eto-otkaz.md`|0|`OK`|
|`bash scripts/check_threat_model.sh . contracts/992-oshibka-eto-otkaz.md`|0|`секция валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 2)`|
|`python3 fixtures/freeze_contract/fail_closed_992.py --matrix`|0|`cases=24 observations=72 failures=0`|
|`python3 fixtures/freeze_contract/fail_closed_992.py --model`|0|`cases=24 observations=24 failures=0`|
|`python3 fixtures/freeze_contract/fail_closed_992.py`|1|`cases=24 observations=24 failures=16` (8 A зелёные, 16 B красные)|
|`bash fixtures/freeze_contract/red_doc_lifecycle.sh`|1|`cases=24 observations=24 failures=16`, doc-проба не исполнена|
|`python3 fixtures/freeze_contract/fail_closed_992.py --list \| wc -l`|0|`24`|
|`bash scripts/check_spec_ready.sh . contracts/992-oshibka-eto-otkaz.md`|0|`OK` (Н-190 не вернулся: `grep -n '^- \`'` по контракту — 0 строк)|
|**`bash scripts/check_provodka.sh . contracts/992-oshibka-eto-otkaz.md`**|**1**|**`проводка: guard не подключён: fixtures/freeze_contract/fail_closed_992.py не вызывается в .githooks/ или .github/workflows/`**|

Н-39 сверен по коду: все названные строки семи скриптов содержат заявленный паттерн —
`check_charter.sh:443-444` (`ls-tree … 2>/dev/null | … || true`), `:494` (`charter_diff_paths … || continue`);
`gitw_preflight_071.sh:215,252` (`done < <(git … 2>/dev/null)` — rc process substitution теряется), `:399`
(`pkg_content="$(git show … 2>/dev/null)"`); `judge_gate.sh:71-78` (`d98_die` внутри `d98_seq`, вызываемой
в `$(…)` на `:117,:133` — умирает только подоболочка; живьём: `ОТКАЗ: журнал: грамматика: seq` и затем
`policy-строка записана`, rc0); `check_ci_gate.sh:60` `set -euo pipefail` подтверждён, `:140,:143` append без
именованного отказа; `profile_resolver.sh:290,313,466` (`2>/dev/null` в `$(…)` без rc), `:310`
(`if ! jq -e …; then continue`), `:406` (`… = "object" ] || return 0`); `freeze_contract.sh:200`,
`done_contract.sh:167` (`for-each-ref … || true` внутри `< <(…)`). Проза §Существующее по этим местам верна.

## Находки

БЛОКИРУЕТ contracts/992-oshibka-eto-otkaz.md:62 — противоречие норме AGENTS.md (§ПРОВОДКА: «каждый канал
нормы существует и подключён»; «Тег done … только через done_contract.sh: … ПРОВОДКА контракта зелёная»).
Названный guard `fixtures/freeze_contract/fail_closed_992.py` механизмом не подключён: `check_provodka.sh`
(`guard_is_wired`, :356-447) ищет базовое имя `fail_closed_992.py` литерально в `.githooks/`,
`.github/workflows/*.yml` и `registry/ci-steps.tsv`; косвенный вызов через `red_doc_lifecycle.sh` →
`npm run check:document` (ci-steps.tsv:34) им не распознаётся. Живьём rc1 (таблица выше). `done_contract.sh:134-141`
на этом rc умирает `done: ПРОВОДКА красна: …` — объявленный порядок контракта (:3, «… → land → done») по
построению не доходит до done. Исправить внутри контракта нельзя: :43 «Workflow/package.json не правятся»,
:12 «без расширения зоны до workflow/package.json», :57 «Никаких … registry/, workflow» — все три локации,
которые читает барьер, исключены из зон. Это ровно класс, уже оплаченный дважды (HANDOFF.md:237 — 105,
HANDOFF.md:2785-2795 — 093: done заблокирован «guard не подключён» после landing). Обход называть не
требуется (исключение роли «противоречие норме»). Закрытие — решение автора: например, назвать
`registry/ci-steps.tsv` (строка `step … bash fixtures/freeze_contract/red_doc_lifecycle.sh` не годится —
имя другое; нужна строка, литерально несущая `fail_closed_992.py`) в зоне названного исполнителя, либо
явно объявить подключение guard'а после landing с исполнителем (прецедент 105), либо переназначить
`guard=` на уже литерально подключённый файл, который вызывает батарею; и предъявить
`check_provodka.sh` rc0 на дереве, где это уже сделано, или назвать, на каком шаге и кем.

СОВЕТ contracts/992-oshibka-eto-otkaz.md:21 — пункт 3 предмета требует, чтобы stderr называл «jq и
проверяемую ветвь», а оракулы пяти profile-клеток (`fail_closed_992.py:81-85`) — `profile ОТКАЗ: .*jq.*`.
Обобщённая обёртка `jq` с единым `profile ОТКАЗ: jq` удовлетворит все пять клеток, ветвь не названа. Ядро
предмета (профиль не выпущен, stdout пуст, rc1) при этом держится — поэтому совет, не блокер. Дёшево
закрыть: ветвь в регексе каждой клетки (модель уже печатает `defaults:`/`commands:`/`barriers.mandatory:`).

СОВЕТ contracts/992-oshibka-eto-otkaz.md:20 — «seq только после успешного ЧТЕНИЯ/разбора журнала»:
обе B-judge-seq клетки предъявляют только ошибку разбора (строка с `seq=abc`), ошибку чтения журнала
(`<"$JOURNAL"` в `d98_seq`) ни одна клетка не вносит. Реализация `seq="$(d98_seq)" || exit 1` закроет оба
пути сразу, поэтому реальный обход не назван — совет.

СОВЕТ contracts/992-oshibka-eto-otkaz.md:31 — «`model_992.py` … НЕ fallback при обычной приёмке», но
`fail_closed_992.py:266` импортирует `model_992` безусловно, и в режиме без флагов тоже. Fallback не
возникает (кандидат вызывается только при `--model`/`--matrix`), но обычный прогон CI падает
трассировкой, если модель удалят или сломают. Импорт под флагом сделает заявление буквальным.

СОВЕТ contracts/992-oshibka-eto-otkaz.md:45 — «независимый от счётчика observations пересчёт исполнен
архитектором» — пункт без команды. Командная часть (`--list | wc -l` → 24) проверена мной: rc0, 24.

СОВЕТ contracts/992-oshibka-eto-otkaz.md:50-53 — implementer получает `fixtures/freeze_contract/`,
то есть файл собственного оракула. Ограничение «только исправления по находкам» — проза; держит его
норма AGENTS.md шаг 7 (ревьюер: «не переписаны ли проверки под код»), прецедент обычный (28 из 80
контрактов отдают implementer'у fixtures-зону). Не блокер; сужение зоны implementer'а до реально нужных
ему файлов (если таких нет — снять `fixtures/freeze_contract/` из его ЗОНА) убрало бы вопрос целиком.

## Пять вопросов роли

1. **Критерий слабее предмета?** По существу нет: каждая клетка исполняет полный скрипт, требует rc1 +
   предметный регекс + неизменность журнала/тегов/HEAD/реестра + отсутствие success-баннера, а матрица
   предъявляет различимость (родитель A / живой код rc0, модель rc1) на тех же входах. Законный
   пропуск отсутствующего package.json держит регрессия п7в `red_predpolet_071.sh:1086-1099`, названная
   в правиле регрессий. Ослабления — только советы выше (ветвь profile, ошибка чтения журнала).
2. **«Готово» недоказуемо командой?** Все пункты критерия имеют команду с кодом возврата; исключение —
   «независимый пересчёт исполнен архитектором» (:45, совет). Но done-шаг объявленного порядка
   недостижим: `check_provodka.sh` rc1 (блокер).
3. **Решение молча оставлено исполнителю?** Да: кто, где и когда подключает guard так, чтобы
   `check_provodka.sh` дал rc0, — не названо, а все допустимые места запрещены (блокер).
4. **Границы исполнения?** Сверены все файлы §Критерий/§Конструкция: контракт, `fail_closed_992.py`,
   `model_992.py`, `red_doc_lifecycle.sh` — в `ЗОНА architect`; семь scripts-файлов — в `ЗОНА implementer`;
   регрессии исполняет оркестратор без правок. Вне зон — `registry/ci-steps.tsv` (или workflow), без
   которого done недостижим (тот же блокер).
5. **Противоречие AGENTS.md?** Да — норма ПРОВОДКИ (блокер выше). Других не найдено: печати `PASS`
   нет, порог имеет область (24 клетки, `--list`), модель угроз сформулирована по свойству.

Precision-гейт 043 и spec-ready 036 зелёные (rc0, вывод в таблице); Н-190 не вернулся.

FAIL
OBJECT=53405506ae8cc35dc22a5cec905a2e5d3e8a144f
СУД: repo=dev-harness; предмет=162; фаза=контракт; роль=critic; вызов=1/1 (лёгкий, один вызов); модель-план=openai-codex/gpt-6-sol; сессия=Crit162; модель-факт=openai-codex/gpt-6-sol (модель текущей сессии); SHA=53405506ae8cc35dc22a5cec905a2e5d3e8a144f; предыдущий=нет; исключение=автор Sol = судья Sol: слово владельца 2026-11-04 ~19:55 UTC, свежий контекст (HANDOFF.md:3).

БЛОКИРУЕТ contracts/162-standart-koda-mob.md:66 — класс причины: результат `make_task` не доказывает требуемую mandatory-строку стандарта для четырёх ролей, а для объявленной «сверки exact row» не названа команда с ненулевым rc на отрицательной паре. Это дефект проверяемости приёмочного критерия, не требование включить стандарт до merge.
ОБЯЗАТЕЛЬСТВО: инвариант 4 (contracts/162-standart-koda-mob.md:36) требует `kind=rules`, `path=docs/CODING-STANDARDS.md`, `mandatory=true`, роли architect,implementer,reviewer,adversary после merge. Критерий требует rc 1 при удалении строки из профиля.
СОСТОЯНИЕ: профиль продукта PR #158 `harness.project.json` сейчас законно не содержит этой строки (до merge пункт NOT_RUN). После её добавления удаление строки возвращает профиль к наблюдаемому формату; такой пакет строится штатной операцией `make_task --role architect` с существующим продуктовым контрактом 151. Это отрицательный образец ПОСЛЕ указанного в критерии момента, а не обвинение до-merge состояния. Источник входа: существующий профиль продукта `harness.project.json` и рабочий `.harness/contracts/151-standart-koda.md` в `wip/136/standard`.
НАБЛЮДЕНИЕ: настоящий `scripts/make_task.sh:318-352` проходит существующие `contextPack.rows`, печатает RULES из найденных строк, но не утверждает наличие конкретного правила стандарта; при отсутствии этого RULES он завершается rc 0. Исходная операция — сборка `RULES_LINES` из `.rows[]`; удаление mandatory-строки профиля исключает её из этой уже существующей операции, не вызывая отказа. Доказательство ниже; заявленная единственная команда критерия зелена при ложном результате, а «по сверке exact row» не обозначает другой исполняемой команды.
ОБХОД: после merge пропущенная/удалённая строка `docs/CODING-STANDARDS.md` оставляет все четыре пакета без обязательного стандарта; `bash scripts/make_task.sh --repo <корень-продукта> --role architect --contract <номер-контракта-проекта>` возвращает 0. Продуктовый профиль и имеющийся генератор воспроизводят этот случай уже сейчас на действующем номере 151.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка называет исполняемую rc-команду (не просто намерение сверить вывод), которая на пакете КАЖДОЙ из четырёх ролей возвращает 0 только при точной mandatory-строке RULES и сохраняет остальные профильные правила; отсутствие строки у одной роли даёт ненулевой rc. Менять `make_task` — не единственный путь: проверка вывода отдельной явно названной командой допустима.

Сырой вывод проверки отрицательного образца (обёртка `/tmp/dev-harness-verify/Crit162/probe-rule-row.py` вызывает существующий make_task с `--repo /home/harness/dev-harness-projects/complior-mob/wt/wip-136-standard --role architect --contract 151 --model-trace /tmp/dev-harness-verify/orch/trace24f.tsv`; выводит исходные строки блока RULES, код и факт отсутствия; `python3 /tmp/dev-harness-verify/Crit162/probe-rule-row.py`, rc 0):
```
make_task rc=0
=== RULES ===
RULES: docs/context/CONTEXT-POLICY.md
RULES: docs/context/OWNER-DECISIONS.md
RULES: AGENTS.md
RULES: mobile/structure-policy.json
=== REUSE ===
missing RULES docs/CODING-STANDARDS.md: True
```
Источник ошибочного механизма: `scripts/make_task.sh:318-352`; источник поддерживаемого входа: `wip/136/standard:harness.project.json` + действующий `.harness/contracts/151-standart-koda.md`. Здесь нет специально добавленного запрета значений: отсутствует уже названная в контракте mandatory-строка.

СОВЕТ contracts/162-standart-koda-mob.md:34,63 — граница модели угроз «будущий дрейф после снимка» (строка 75) названа и не подменяется обязательством. У текущей scratch-проверки цель g05 («не каждый tap предварён assertVisible») определяется простым наличием `tapOn` в `mobile/.maestro/cmp-mob-004-start.yaml`: исправление ВСЕХ шести пар ожидание/тап на disposable копии оставляет 123/123 зелёными и g05=OK. В текущем снимке целевой долг действительно присутствует, поэтому это не второй блок; при дальнейшем сопровождении учитывать смысловую проверку цели либо сознательно оставлять её ревьюеру. Исходный вход: живой файл Maestro и `docs/CODING-STANDARDS.md` §13; ошибочный механизм: существующая ветка `goal)` в `tmp/verify-standard.sh:235-267` и строка g05 `tmp/claims.tsv`, которая принимает встречу `tapOn` вместо отсутствия `assertVisible` непосредственно перед каждой целью. Проба на одноразовой копии: `bash tmp/verify-standard.sh` из `/tmp/dev-harness-verify/Crit162/mobile`, после добавления `assertVisible: id: <id>` непосредственно перед каждым `tapOn` в названном YAML, без изменения стандарта/таблицы/checker. Сырой относящийся к классу вывод (полный stdout команды включал 123 исхода `OK` и доказательства остальных пяти целей):
```
OK g05
--- ИТОГ ---
утверждений: 123; ok: 123; fail: 0
тип exists: всего 18, ok 18, fail 0
тип goal: всего 6, ok 6, fail 0
тип grep: всего 89, ok 89, fail 0
тип grep-none: всего 6, ok 6, fail 0
тип json: всего 4, ok 4, fail 0
g05 (ЦЕЛЬ: не каждый тап в эталонном сценарии предварён assertVisible по своей цели (start-composer-input, shell-tab-vorgaenge))
  перечень: mobile/.maestro/cmp-mob-004-start.yaml
  шаблон: tapOn
  mobile/.maestro/cmp-mob-004-start.yaml:34:- tapOn:
  mobile/.maestro/cmp-mob-004-start.yaml:43:- tapOn:
  mobile/.maestro/cmp-mob-004-start.yaml:50:- tapOn:
  mobile/.maestro/cmp-mob-004-start.yaml:59:- tapOn:
  mobile/.maestro/cmp-mob-004-start.yaml:63:- tapOn:
  mobile/.maestro/cmp-mob-004-start.yaml:74:- tapOn:
РЕЗУЛЬТАТ: OK
```

Фактические замеры на OBJECT: `git cat-file -t` → `commit`. `bash scripts/pre_critic.sh --repo . contracts/162-standart-koda-mob.md` из worktree автора → rc 0, «КРИТИК: дверь зелёная»; `bash scripts/check_ceilings.sh .` → rc 0, «потолки в порядке»; `bash scripts/check_precision_gate.sh . contracts/162-standart-koda-mob.md` → rc 0, `OK`; `bash scripts/check_threat_model.sh . contracts/162-standart-koda-mob.md` → rc 0, «ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов)»; `bash scripts/check_spec_ready.sh . contracts/162-standart-koda-mob.md` → rc 0, `OK`; `bash scripts/check_provodka.sh . contracts/162-standart-koda-mob.md` → rc 0 (в отличие от ожидаемого в задании rc 1; действующий guard существует); `bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight` → rc 0. `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/orch/zones-base-162.sha .` из worktree → rc 0, но фактически «53405506..53405506 (0 коммитов)», поэтому этот повтор не доказывает покрытие коммитов; автор привёл прошлый успешный прогон по одному коммиту, и оркестратор подтвердил rc 0. `bash tmp/verify-standard.sh` на исходном product worktree → rc 0, «утверждений: 123; ok: 123; fail: 0». `bash /tmp/dev-harness-verify/orch/addstd.sh 53405506a contracts/162-standart-koda-mob.md /tmp/dev-harness-worktrees/c907157c/wip-162-architect` → rc 0, `CITATIONS OK count=5`, `check-context-sources rc=0 (коммит 53405506ae8c)`. Нового продуктового checker и evidence до поставки нет — не объявляю их проходящими. Дельт frozen контрактов харнесса и других зон этот OBJECT не меняет.

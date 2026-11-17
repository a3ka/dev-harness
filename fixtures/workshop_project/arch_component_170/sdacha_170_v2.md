# Сдаточный лист 170 v2 (закрытие блока dd5c16535f, слово владельца 2026-11-17)

Форма по ПРОВОДКЕ roles/architect.md (192/1): rc каждой двери и по строке
`чисто|н/п` с командой или входом на каждый класс К-01…К-17 из
`roles/critic.md §Связка с автором`.

`bash scripts/check_sdacha.sh <корень> <контракт> --run` — СКРИПТ ОТСУТСТВУЕТ
в дереве ветки и в origin/main (`git show origin/main:scripts/check_sdacha.sh`
→ fatal: path … does not exist); лист ручной, каждое rc ниже — из живого
прогона в worktree `/tmp/dev-harness-worktrees/c907157c/wip-170-architect`.

## Двери (команда → rc)

- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` → rc 0, 35 клеток `ok`
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` → rc 0, 22 строки `caught`, ни одного `ZHIV`
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo /tmp/dev-harness-verify/Arch170v2d/main-copy` → rc 0, 35 клеток `ok` на реальной двери 187а (копия main `22a09f3868` + дельта 170 поверх, без коммита)
- `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0
- `bash scripts/check_spec_ready.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0
- `bash scripts/check_precision_gate.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0
- `bash scripts/check_threat_model.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0 (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 6)
- `bash scripts/check_ceilings.sh .` → rc 0
- `bash scripts/check_charter.sh` → rc 0
- `bash scripts/check_contract_frozen.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → rc 1: предсуществующее на ветке (отставание от main по 140/141/147/148/186/187/188/991/999 — вне зоны пачки) плюс сам 170: v2 незаморожен по построению, ждёт critic №7; заморозка — freeze_contract.sh после accept
- `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` → rc 0 (регрессия 095)
- `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` → rc 0 (регрессия 169)

## Карта классов К-01…К-17

- К-01: чисто — `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0; модель угроз rc 0; потолки rc 0; «Незаполненные требования: нет»; precision rc 0; сдаточный лист — этот файл (скрипт-раннер отсутствует в дереве, см. выше).
- К-02: чисто — слово владельца 2026-11-17 процитировано в КОНТЕКСТ контракта; предмет — закрытие блока `dd5c16535f` по пределу «ЗАКРЫВАЕТ» вердикта вызова 6; источник дверей — origin/main `22a09f3868`.
- К-03: чисто — frozen 187/1 не ослаблен: текст v2 приведён к реальной двери (применимость по каталогу, ARCH_PIN, node-CLI брифа, pin без 40-hex), зона двери не тронута; остатки — в «НЕ ЗАЩИЩАЕТ» с именованным владельцем правки (implementer, предмет 187а); ПЕРЕСЕЧЕНИЯ по scripts/make_task.sh перечислены.
- К-04: чисто — файлы пачки: `contracts/170-arch-component-brief-vhod-zadanija.md`, `fixtures/workshop_project/arch_component_170/{probe.py,red_arch_component_170.sh,npm_stub.py,sdacha_170_v2.md}` — все в ЗОНА architect; правка scripts/ не производилась (`git status --short`: только контракт и probe.py).
- К-05: чисто — каждая строка приёмки — правило или сценарий с командой и rc (см. «Двери»).
- К-06: чисто — `red_arch_component_170.sh --repo <путь без make_task.sh>` → rc 2 `170 SUBJECT_ABSENT`; поломанный контроль модели → rc 2 `170 CONTROL_INVALID` (не красная клетка).
- К-07: чисто — достижимость: `--model` rc 0 (35/35) на честном контроле; реальность: `--repo <копия main>` rc 0 против настоящей двери main, не двойника.
- К-08: чисто — `--stabs` rc 0: 22 мутанта честного контроля, каждый красит свою клетку (`caught @ <ветвь>`), ни одного `ZHIV`.
- К-09: чисто — покрыты обе границы брифа (node-CLI закреплённого дерева и npm легаси-ветки), оба режима применимости, все семь ролей (правила только architect/critic/arbiter), пять форм класса предмета, порядок pin-свидетельства против вопроса о флаге, пустой lock/без commit/неразрешимая ревизия/HEAD-клон/локальная копия.
- К-10: чисто — клетки судят rc, пустоту stdout, первую строку stderr и структурные строки секций пака (`grep` самостоятельными строками), не ref и не подстроку из чужой секции.
- К-11: чисто — оракул снимается в память probe.py до вызова субъекта (nonce, ожидаемые маркеры); миры одноразовые, диск субъекта как истина не перечитывается.
- К-12: чисто — протокол locate/brief — протокол РЕАЛЬНОГО `tooling/checks/cli.js` 187а (статусный JSON, matches[].components); самописного дублера формата нет.
- К-13: н/п — секретных входов нет; nonce — синтетический маркер оракула.
- К-14: чисто — для каждой фиксации реального поведения есть честная зелёная запись (`symbolic_pin` rc 0 с REVISION:WRONG-HEAD-170; `lock_without_dir` rc 0 пак без брифа) и красная двусторонность (`--stabs`: `symbolic_refused` красит symbolic_pin, `requirement_removed` красит required).
- К-15: чисто — числа 35/35/22 из вывода прогонов (`grep -c`); счётные утверждения текста совпадают с выводом.
- К-16: чисто — КЛАСС РИСКА: обычный (как v1); модель угроз по свойству, ЗАЩИЩАЕТ 2 / НЕ ЗАЩИЩАЕТ 6, границы названы с ловцами.
- К-17: н/п — предмет не меняет схем операций/semanticInvariant/writers архитектуры продукта; красная батарея — фиксстура харнесса.

## Остаток (честно)

- `scripts/check_sdacha.sh` отсутствует в дереве (ветка и origin/main) — автоматический перезапуск листа критиком невозможен до появления скрипта; лист ручной, все rc воспроизводимы командами выше.
- Заморозка v2 не производилась (ждёт critic №7 по слову владельца 2026-11-17) — `check_contract_frozen` честно красен по 170 до accept+freeze.

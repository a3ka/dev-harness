accept

OBJECT=e6d285b028cb2b08e6fd4481ab6763f4f66040be
СУД: repo=dev-harness; предмет=037; фаза=контракт v3; роль=critic; вызов=2/3 до арбитража; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit037V3b; модель-факт=openai-codex/gpt-6.1-terra (allowed, models_actual --bind); SHA=e6d285b028cb2b08e6fd4481ab6763f4f66040be; предыдущий=verdicts/critic/contracts-037-v3.md на 45781cf5b2, FAIL; исключение=нет.

Повтор ограничен двумя прежними блоками и последствиями ремонта. К-08 закрыт: исполняемый блок останова проверяется на достижимом расхождении и совпадении tip, s08 привязан к ц6 в коде батареи. К-07 закрыт: норма — отдельная строка тела модели, s09 привязан к ц7, дословный перенос тела модели в раздел роли даёт `check_provodka` rc 0. Согласие относится только к OBJECT.

## Выполненные проверки

Рабочий каталог `/tmp/dev-harness-verify/Crit037V3b/repo`. `bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh --model`, rc 0:
```text
ok   c0
ok   c1
ok   c2
ok   c3
ok   c4
ok   c5
ok   c6
ok   c7
ИТОГ 037-М3 (модели-эталоны): клеток 8, красных 0, зелёных 8
ЗЕЛЕНОЕ 037-М3-model
```
`bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh --stabs`, rc 0:
```text
СТАБ 037-М3: s01 ПОЙМАН (клеток 1, красных 1)
СТАБ 037-М3: s02 ПОЙМАН (клеток 1, красных 1)
СТАБ 037-М3: s03 ПОЙМАН (клеток 2, красных 2)
СТАБ 037-М3: s04 ПОЙМАН (клеток 1, красных 1)
СТАБ 037-М3: s05 ПОЙМАН (клеток 1, красных 1)
СТАБ 037-М3: s06 ПОЙМАН (клеток 1, красных 1)
СТАБ 037-М3: s07 ПОЙМАН (клеток 3, красных 3)
СТАБ 037-М3: s08 ПОЙМАН (клеток 1, красных 1)
СТАБ 037-М3: s09 ПОЙМАН (клеток 1, красных 1)
СТАБЫ 037-М3: всего 9, поймано 9, живых 0
ЗЕЛЕНОЕ 037-М3-stabs
```
`bash scripts/check_provodka.sh --grammar . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` rc 0, вывода нет. Без `--grammar` до реализации rc 1:
```text
проводка: норма-строка не найдена в role-файле: roles/orchestrator.md
```
Дословный перенос: копия `scripts`, `roles`, `contracts` в `/tmp/dev-harness-verify/Crit037V3b/provodka`, замена раздела М3 содержимым модели от заголовка до маркера конца; `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit037V3b/provodka contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` rc 0, вывода нет.

Регрессии: `bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .`, `bash fixtures/accept_task_commit/red_accept_task_commit.sh .`, `bash fixtures/accept_task_commit/red_porjadok_diapazona_068.sh .` — общий rc 0, соответственно 11/11, 7/7, 6/6 зелёных. `git diff --exit-code 45781cf5b2 HEAD -- fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md roles/orchestrator.md` rc 0. Семь файлов дельты лежат в зоне architect; зоны и пересечения не менялись; `check_precision_gate.sh` rc 0 (`OK`). Строка разрешения в том же коммите называет путь первым токеном и ограничивает разрешение предметом 199:20.

## Мутации

Соседняя мутация К-08: в исполняемом блоке сохранены сравнение и сообщение об отказе, `exit 1` заменён на `true`:
```bash
python3 -c 'from pathlib import Path; p=Path("fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md"); s=p.read_text(); a="[ \"$(git rev-parse HEAD)\" = \"${OZHIDAEMYJ_TIP:-}\" ] || { printf"; b="[ \"$(git rev-parse HEAD)\" = \"${OZHIDAEMYJ_TIP:-}\" ] || { true; printf"; assert s.count(a)==1; s=s.replace(a,b).replace(" >&2; exit 1; }", " >&2; true; }"); Path("/tmp/dev-harness-verify/Crit037V3b/otkaz-mut.md").write_text(s)' && env S037V_CEREM=/tmp/dev-harness-verify/Crit037V3b/otkaz-mut.md S037V_BLOKI=fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md S037V_PRIV=fixtures/workshop_project/sol_v_izolyacii_199/model/privjazka_sdachi.sh bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh .
```
rc 1, сырой вывод:
```text
ok   c0
ok   c1
ok   c2
ok   c3
ok   c4
ok   c5
FAIL c6 — ц6: расхождение tip не остановлено (rc=0)
ok   c7
ИТОГ 037-М3 (субъекты дерева): клеток 8, красных 1, зелёных 7
КРАСНОЕ 037-М3: красных 1 из 8 (до реализации ожидаемо; после — дефект)
```
Честный эквивалент сравнения:
```bash
python3 -c 'from pathlib import Path; p=Path("fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md"); s=p.read_text(); a="[ \"$(git rev-parse HEAD)\" = \"${OZHIDAEMYJ_TIP:-}\" ] ||"; b="test \"${OZHIDAEMYJ_TIP:-}\" = \"$(git rev-parse HEAD)\" ||"; assert s.count(a)==1; Path("/tmp/dev-harness-verify/Crit037V3b/equiv.md").write_text(s.replace(a,b))' && env S037V_CEREM=/tmp/dev-harness-verify/Crit037V3b/equiv.md S037V_BLOKI=fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md S037V_PRIV=fixtures/workshop_project/sol_v_izolyacii_199/model/privjazka_sdachi.sh bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh .
```
rc 0, сырой вывод:
```text
ok   c0
ok   c1
ok   c2
ok   c3
ok   c4
ok   c5
ok   c6
ok   c7
ИТОГ 037-М3 (субъекты дерева): клеток 8, красных 0, зелёных 8
ЗЕЛЕНОЕ 037-М3
```
Соседняя мутация К-07: норма остаётся целой подстрокой, но больше не отдельной строкой:
```bash
python3 -c 'from pathlib import Path; p=Path("fixtures/accept_task_commit/priem_izolyacii_037/model/orchestrator_ceremony_m3.md"); s=p.read_text(); a="\nШтатный приём изолированной рабочей пачки:"; assert s.count(a)==1; Path("/tmp/dev-harness-verify/Crit037V3b/norma-mut.md").write_text(s.replace(a,"\nПредисловие. Штатный приём изолированной рабочей пачки:"))' && env S037V_CEREM=/tmp/dev-harness-verify/Crit037V3b/norma-mut.md S037V_BLOKI=fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md S037V_PRIV=fixtures/workshop_project/sol_v_izolyacii_199/model/privjazka_sdachi.sh bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh .
```
rc 1, сырой вывод:
```text
ok   c0
ok   c1
ok   c2
ok   c3
ok   c4
ok   c5
ok   c6
FAIL c7 — ц7: норма-строка проводки не является отдельной строкой раздела М3
ИТОГ 037-М3 (субъекты дерева): клеток 8, красных 1, зелёных 7
КРАСНОЕ 037-М3: красных 1 из 8 (до реализации ожидаемо; после — дефект)
```

## Карта классов

К-01: чисто — без изменений с вызова 1; `check_precision_gate.sh` rc 0.
К-02: чисто — без изменений с вызова 1, вход: заявка 199:20 и дельта двух блоков.
К-03: чисто — регрессии М1, М2, 068 rc 0; блоки 199 не менялись.
К-04: чисто — вход: семь файлов дельты, зоны и пересечения контракта :646–670; precision rc 0.
К-05: чисто — вход: команды Р7 и Р9 в contracts/037-samodostatochnyj-cwd-i-priemnik-task.md:710–760.
К-06: чисто — без изменений с вызова 1; вход: проверки зависимостей батареи.
К-07: чисто — дословный перенос в scratch и `check_provodka.sh` rc 0; ц7 и s09.
К-08: чисто — `--stabs` rc 0, s08; соседняя мутация отказа краснит ц6.
К-09: чисто — вход: ц6 на расходящихся и совпадающих tip, ц7 на норме из контракта; иные поверхности без изменений с вызова 1.
К-10: чисто — вход: ц6 проверяет rc и stderr исполнения блока; ц7 проверяет отдельную строку.
К-11: чисто — вход: ожидаемые tip из git-мира, норма из контракта.
К-12: чисто — вход: неизменённая модель блоков 199, `git diff --exit-code` rc 0.
К-13: н/п — секреты не предмет, без изменений с вызова 1.
К-14: чисто — честная эквивалентная запись сравнения даёт батарее rc 0.
К-15: чисто — `--model` rc 0, 8/8; `--stabs` rc 0, 9/9.
К-16: чисто — без изменений с вызова 1; вход: класс риска и модель угроз контракта.
К-17: н/п — без изменений с вызова 1; бриф архитектуры 188 не заявлен.

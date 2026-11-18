accept
OBJECT=3e1a01ee8e0115510153430834921c8f8279c308
СУД: repo=dev-harness; предмет=154; фаза=контракт до заморозки, узкое исполнение resolved Arb154V1; роль=critic; вызов=РОВНО ОДИН узкий №1 из 2 по отдельному счёту ADR, №6 по фактическому накопительному счёту; санкция=Cons154Sign, /tmp/dev-harness-verify/Cons154Sign/otvet.md; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit154V6; модель-факт=openai-codex/gpt-6.1-terra allowed; SHA=3e1a01ee8e0115510153430834921c8f8279c308; предыдущий=verdicts/critic/contracts-154-v1e-fail.md; конечное решение=verdicts/arbitration/154-granica-schet-vyzovov.md, resolved; исключение=адресная санкция консультанта, без нового полного суда.

Автор OBJECT — architect; судья не автор. Модель-факт получена `bash scripts/models_actual.sh --tsv --bind --session Crit154V6 | cut -f1-3` из `/home/harness/dev-harness`, rc 0, обе строки `critic openai-codex/gpt-6.1-terra allowed`. `git fetch --tags origin` rc 0; HEAD при суде = OBJECT. Дельта от 9751dd16604e30653460377b46f02a6cba7bae04 — пять файлов контракта и его батареи, +196/−39. Санкция и граница суда — в ответе консультанта; вне А154-1 и зависимого регресса полный проход не проводился.

А154-1: модель проверяет выбранную строку ISPOLZOVANO для позиции и OBJECT и расходует consultant только по ней; дополнительные разрешения и ARBITRAZH не заменяют выбор. Оракул вычисляет ожидание до вызова, обе фазы содержат положительные и отрицательные контроли. Вывод не объявляет production уже реализованным. Согласованность с принятой границей: явное обещание относится к станционному пути; противоречия принятой владельцем границе проектов не установлено.

СОВЕТ contracts/154-schet-vyzovov-kritika.md:218 — сокращённая формулировка об альтернативных workflowPaths упоминает дополнительные места receipt, но не историю. Принятые владельцем четыре строки арбитража охватывают оба аспекта; дословное приведение текста устранило бы неоднозначность, но само отсутствие копии не является блоком этого суда.

## Проверки

`bash scripts/check_sdacha.sh . contracts/154-schet-vyzovov-kritika.md --run` rc 0: `СДАЧА: лист зелёный (двери=9 карта=17/17 дельта=0)`. В том числе выполнены предъявленные в листе `W --model`, `W --domain-model`, `W --stabs`; сдаточная дверь сравнивает фактические коды с заявленными, но её сводный вывод не содержит числа клеток.

`bash scripts/pre_critic.sh --repo . contracts/154-schet-vyzovov-kritika.md` rc 0: `КРИТИК: дверь зелёная`. `bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md` rc 0: `OK`.

`python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py` rc 0: repo `CELLS=87 GREEN=87`, domain `CELLS=213 GREEN=213`, live `CELLS=9 GREEN=9`, grammar `GRAMMAR=1000 CELLS=2000 GREEN=2000`; все четыре вложенных `INSTALLED_CONTROL ... rc=0`. Это честная вставка в копии CLI, а не поставленная реализация.

До реализации голые режимы, каждый rc 1 с именованными RED: `W --repo` 87/18 (например `spawn-pos3-kap`); `W --domain` 213/19 (`domain-spawn-3`); `W --live` 9/5 (`live-new-tag-door`); `W --grammar` 1000 номеров, 2000 клеток, 0 зелёных (`grammar-000-door` и `grammar-000-freeze`). Внешняя команда печатала отдельные `REPO_RC=1`, `DOMAIN_RC=1`, `LIVE_RC=1`, `GRAMMAR_RC=1`. Полные выводы установленных режимов: artifact://12522 и artifact://12523.

## Адресные мутации

Существующие операции ISPOLZOVANO/арбитража/дублей и лимита проверены на собственном запуске; честный контроль каждого случая предварительно зелёный. Команда:

```sh
env PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; names=('arb-reclassifies-used','owner-reclassifies-used','duplicate-grants-charged','consultant-cap-ignored','selection-conflict-ignored'); cases=[c for c in probe.STAB_CASES if c[0] in names]; [(print(c[0],c[2],'honest=',probe.run_case(c,'model') or 'GREEN','mutant=',probe.run_case(c,'model',mutation=c[0]) or 'SURVIVED',flush=True)) for c in cases]"
```

Сырой вывод, rc 0:

```text
consultant-cap-ignored spawn honest= GREEN mutant= consultant-cap-ignored: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
arb-reclassifies-used spawn honest= GREEN mutant= arb-reclassifies-used: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
owner-reclassifies-used spawn honest= GREEN mutant= owner-reclassifies-used: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
duplicate-grants-charged spawn honest= GREEN mutant= duplicate-grants-charged: expected rc 0, actual 1: ОТКАЗ: KAP_VYZOVOV_KRITIKA: предмет 001: позиция 6 не покрыта; консультантских вызовов=2

selection-conflict-ignored spawn honest= GREEN mutant= selection-conflict-ignored: expected SCHET_NEIZVESTEN, actual rc 0:
arb-reclassifies-used freeze honest= GREEN mutant= arb-reclassifies-used: expected KAP_VYZOVOV_KRITIKA, actual rc 0: OK secrets=0 variables=0 environments=0 settings=0
  ok   заморожено: contracts/001-x.md → frozen/contracts/001/1 («criterion accepted»)
  ok   реестр закоммичен: 001 → f02015ce2d2c91cb427e1ffa431f3d242d0c2309
  ok   реестр записан: 001 → f02015ce2d2c91cb427e1ffa431f3d242d0c2309

owner-reclassifies-used freeze honest= GREEN mutant= owner-reclassifies-used: expected KAP_VYZOVOV_KRITIKA, actual rc 0: OK secrets=0 variables=0 environments=0 settings=0
  ok   заморожено: contracts/001-x.md → frozen/contracts/001/1 («criterion accepted»)
  ok   реестр закоммичен: 001 → 2c9f3b15f3f2299f57d1d7fee7a6965ae7ce714b
  ok   реестр записан: 001 → 2c9f3b15f3f2299f57d1d7fee7a6965ae7ce714b

duplicate-grants-charged freeze honest= GREEN mutant= duplicate-grants-charged: expected rc 0, actual 1:   ok   план не заведён: проверка «вне плана» не применяется
ОТКАЗ: KAP_VYZOVOV_KRITIKA: предмет 001: позиция 6 не покрыта; консультантских вызовов=2
ОТКАЗ: ОТКАЗ бюджета критика (154): см. stderr выше

selection-conflict-ignored freeze honest= GREEN mutant= selection-conflict-ignored: expected SCHET_NEIZVESTEN, actual rc 0: OK secrets=0 variables=0 environments=0 settings=0
  ok   заморожено: contracts/001-x.md → frozen/contracts/001/1 («criterion accepted»)
  ok   реестр закоммичен: 001 → c8a1152b80f822c583764e3d11560da9d21be37f
  ok   реестр записан: 001 → c8a1152b80f822c583764e3d11560da9d21be37f
```

Дополнительно соседняя мутация удаления проверки лимита проверена в обеих фазах и на честном положительном примере двух вызовов:

```sh
env PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; cases=[c for c in probe.ATTRIBUTION_CASES if c[0].endswith(('third-refused','two-from-four'))]; [(print(c[0], 'honest=',probe.run_case(c,'model') or 'GREEN', 'mutant=',probe.run_case(c,'model',mutation='consultant-cap-ignored') or 'GREEN',flush=True)) for c in cases]"
```

Сырой вывод, rc 0:

```text
attribution-spawn-third-refused honest= GREEN mutant= attribution-spawn-third-refused: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
attribution-spawn-two-from-four honest= GREEN mutant= GREEN
attribution-freeze-third-refused honest= GREEN mutant= attribution-freeze-third-refused: expected KAP_VYZOVOV_KRITIKA, actual rc 0: OK secrets=0 variables=0 environments=0 settings=0
  ok   заморожено: contracts/001-x.md → frozen/contracts/001/1 («criterion accepted»)
  ok   реестр закоммичен: 001 → f4136d936f17ca3aba5fb0268ad277cd1cf59ac3
  ok   реестр записан: 001 → f4136d936f17ca3aba5fb0268ad277cd1cf59ac3

attribution-freeze-two-from-four honest= GREEN mutant= GREEN
```

Н-39: привязки стабов к ветвям заданы в коде architect, не прозой контракта. Сырые rc процессов выше — коды команд исследования, текст `actual rc` относится к испытуемой мутации.

## Карта классов

К-01: чисто — `check_sdacha.sh ... --run` rc 0; `pre_critic.sh --repo . ...` rc 0; precision rc 0.
К-02: чисто — вход: решение Arb154V1, ADR и sanction Cons154Sign против И-3…И-6 и дельты А154-1.
К-03: чисто — вход: решение Arb154V1 Б1–Б9; installed_control live rc 0, старый порядок сохранён.
К-04: чисто — вход: `git diff --stat 9751dd1660 3e1a01ee8e`, пять файлов в зоне architect.
К-05: чисто — вход: таблица приёмки contracts/154-schet-vyzovov-kritika.md:49–62; команды и rc до/после реализации.
К-06: н/п — класс среды вне изменённой атрибуции; регресс охвачен сдаточной дверью.
К-07: чисто — installed_control.py rc 0, все четыре настоящие копии CLI зелёные; голые режимы именованно красные.
К-08: чисто — вход: адресные мутации выше, `check_sdacha.sh ... --run` rc 0 включает `W --stabs`.
К-09: чисто — installed_control.py rc 0, grammar 1000/2000, атрибуционные случаи в обеих фазах.
К-10: чисто — вход: probe.py:608–662, снимки ledger/tag/registry и положительные эффекты; installed_control rc 0.
К-11: чисто — вход: probe.py:547–606 и :630, независимое ожидание до вызова субъекта.
К-12: н/п — новая проверка формата не входит в узкую дельту; вход: Arb154V1 и И-5.
К-13: н/п — изменение А154-1 не вводит обработку секретов.
К-14: чисто — парная мутация лимита выше: честные два вызова зелёные в обеих фазах.
К-15: чисто — installed_control и голые режимы выше; вход: sdacha.md и сырой вывод фактических прогонов.
К-16: чисто — вход: риск деньги, contracts/154-schet-vyzovov-kritika.md:205–220 и принятая владельцем граница Arb154V1.
К-17: н/п — `pre_critic.sh --repo . ...` rc 0, `ARCH_187A_SKIP`; продуктовая модель 187а не включена.

Этот accept относится только к OBJECT; freeze, реализация, миграция потребителей и живой платный spawn здесь не выполнялись.

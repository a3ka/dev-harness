accept
OBJECT=c5119b7cb81c9d7da55f0b5f25a89cb76bfda8de
СУД: repo=dev-harness; предмет=201; фаза=реализация frozen/contracts/201/1 — квалификация НЕСЕМАНТИЧЕСКОГО ремонта предпосылок игрушечных миров старых батарей (038 D-семья, ap2 `case_verdikt_fail.sh`, 992 done-клетки); роль=reviewer; вызов=scoped №2 из ≤1 (полный №1 — Rev201, accept `dc991219`/`48cd565937` на `bdf592e098`); класс риска=рисковый (порядок: Adv201d accept `c228a99ae2` на `bdf592e098` → reviewer); сессия=Rev201S; модель-план=config/agent_models.json reviewer → anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 allowed (`bash scripts/models_actual.sh --tsv --bind --session Rev201S | cut -f1-3` из /home/harness/dev-harness → `reviewer	anthropic/claude-opus-5-5	allowed` ×2, rc 0); независимость: авторы ремонтов — implementer (MiniMax/GLM) и architect (Sol), reviewer — Opus; запись СУД до вызова — state-HANDOFF c907157c/wip-011-orchestrator (дописывает оркестратор).
СВЕРКА-АРХИТЕКТУРЫ: дифф `42d0860510..c5119b7cb8` — только три тестовых файла (`fixtures/done_contract/_toy.sh`, `fixtures/done_contract/case_verdikt_fail.sh`, `fixtures/freeze_contract/fail_closed_992.py`); размещение — в существующих батареях, новых файлов/каталогов нет; зависимости — прежние git/python3; писатели и операции продукта не меняются (дверь и реестр байт-в-байт, §1); `bindings.json`/`architecture.lock.json` не тронуты; долг не расширен; уровень diff модели — L0 (модели не касается).
СВЕРКА-СТАНДАРТОВ: AGENTS.md станции не объявляет документ архитектуры и стандарт кода — неприменимо (как в v1).
НАХОДКИ: `.review/2026-11-18-113.md` (status: ready) — блоков 0, советов 2 (С-1, С-2), развилка оркестратору 1 (Р-1: OBJECT этого вердикта ≠ OBJECT accept адверсария; дверь `:674`).

# Предмет и метод

Задание `/tmp/dev-harness-verify/task-rev201s.md` прочитано первым действием целиком; решение
консультанта `/tmp/dev-harness-verify/Cons201Compat/otvet.md` §1–§3 прочитано целиком.
Клон судьи создан мной: `git clone ssh://git@github.com/a3ka/dev-harness.git repo`,
`git fetch --tags origin`, `git checkout wip/201/implementer` → HEAD =
`c5119b7cb81c9d7da55f0b5f25a89cb76bfda8de` = OBJECT. Опорное дерево своей меры —
worktree `wt-before` на `423389cfb9` (до ремонтов `_toy.sh`/992) с подменой
`case_verdikt_fail.sh` из `42d0860510` (до ремонта ap2).

Объём — только ремонт; неизменённые поверхности двери не переоценивались (покрыты Adv201d/Rev201).

# 1. Несемантичность (своя мера)

```text
$ git diff --stat bdf592e098 c5119b7cb8 -- scripts/done_contract.sh registry/mesto-legacy.tsv
(пусто) rc=0
$ git diff --stat frozen/contracts/201/1 c5119b7cb8 -- contracts/201-done-dver-soderzhatelnaja-sverka.md
(пусто) rc=0
$ git diff --name-status bdf592e098 c5119b7cb8 -- fixtures/workshop_project/done_dver_soderzhatelnaja_201/ verdicts/
A verdicts/adversary/contracts-201-impl-v4.md      (Adv201d, c228a99ae2)
A verdicts/critic/contracts-147-v5-vyzov1-fail.md  (из main, merge 42d0860510)
A verdicts/critic/contracts-147-v5-vyzov2-fail.md  (из main)
A verdicts/review/contracts-201-impl-v1.md         (Rev201, dc991219)
A verdicts/review/owner-adr-ekrany-mob-1093-v2.md  (из main)
A verdicts/review/owner-adr-ekrany-mob-1093.md     (из main)
$ git diff --name-status 42d0860510 c5119b7cb8        # все ремонты вместе
M fixtures/done_contract/_toy.sh
M fixtures/done_contract/case_verdikt_fail.sh
M fixtures/freeze_contract/fail_closed_992.py
```

Батарея 201 не тронута ни одним коммитом цепочки; вердикты только добавлены судьями/main, ремонты
их не касаются. Цепочка: все семь SHA задания — предки `c5119b7cb8` (`merge-base --is-ancestor` rc 0
каждый). Merge `42d0860510` (родители `48cd5659` + `725974683f`) — без ручного разрешения
(`git show --cc --format= 42d0860510 | wc -l` → 0); его 36 файлов main не пересекаются с
`done_contract|freeze_contract|done_dver|mesto|201` (grep rc 1). Атомарность: по одному файлу на
коммит, author=committer у каждого (`423389cf` implementer, `082725f1` architect, `c5119b7c`
implementer).

# 2. Критерии сохранены — «меняются предпосылки мира, не критерий»

**`_toy.sh` (`git diff 423389cfb9 082725f1ab`, +17/−8).** Дельта — только тело `make_drepo`
(`:46–53`) и его шапка-комментарий (`:18–32`): контракт получает `КЛАСС РИСКА: обычный` и
`ПРОДУКТ: станция`; после коммита F — `tag -a frozen/contracts/001/1`; accept-вердикт с `OBJECT=F`
пишется ПОСЛЕ заморозки отдельным коммитом V (F ⊊ V). `REPO`-пин (`:6`), `g`, `commit_all`,
`GREEN_PROVODKA`/`GHOST_PROVODKA`, `put_verdict`, `done_tags`, `run_writer`, `refuse`,
`require_absent_subject`, стабы писателей-минимум consumers (`:36–43`) — вне диффа. Файлы
сценариев D5/D6/D10/G и прочих D не менялись (`git log 423389cfb9..c5119b7cb8 -- <файл>` пусто для
каждого), значит EXPECT/фразы отказов прежние. Единственное содержательное различие мира —
accept-вердикт теперь в коммите V, а не в F; сценарии D7/D9 и др., переписывающие вердикт, остались
красными той же фразой (прогон ниже).

**`fail_closed_992.py` (`git diff 423389cfb9 c5119b7cb8`, +38/−18).** Перестроена только ветка
`subject in ('freeze_contract.sh','done_contract.sh')` в `prepare` (`:121–162`), разделённая на
`subject == 'done_contract.sh'` и `else`. Своя сверка:
- `else` (freeze-миры) — построчно та же последовательность, что была для freeze: `# fixture`,
  critic v1, review v1 без OBJECT, commit; `*versions` → `frozen/contracts/001/2`, critic v3,
  условие `for-each-ref … refs/tags/frozen/contracts/001/`; иначе `condition='False'` + стаб
  `check_spec_ready.sh`. Прежний `prefix`-выбор заменён литералом `frozen` — эквивалентно, т.к.
  в CASES у done ровно три клетки (`:67,68,88`), все уходят в done-ветку.
- done-ветка: F = контракт с классом/местом + critic v1; `tag frozen/contracts/001/1` на F; review
  v1 `accept`+`OBJECT=F` отдельным коммитом. A-done-log/A-done-order: второй accept v2 (тоже
  OBJECT=F) отдельным коммитом — два различных коммита вердиктов сохранены; условия шима
  дословно прежние (`'log' … a[-1]=='verdicts/review/contracts-001-v2.md'`,
  `'merge-base' … '--is-ancestor'`). B-done-versions: `done/contracts/001/2` при отсутствии `/1`
  сохранён, critic v3, условие `for-each-ref … refs/tags/done/contracts/001/` — не frozen.
- `CASES` (`:65–90`), regex-ы, oracle, `observe`, `args`, `shim`, CI-write клетки — вне диффа.

**`case_verdikt_fail.sh` (`git diff 42d0860510 423389cfb9`, +41/−3).** Зелёный мир G получает
класс/место (`:36`), `freeze_in` на F (`:68`), accept с OBJECT=F отдельным коммитом (`:69–70`).
Красный мир R не ослаблен: прежний стаб-всегда-OK (`:77–85`) и вердикт `FAIL` (`:87`, теперь
через `put_verdict` без OBJECT — та же первая строка); шапка `# ПРИЧИНА: вердикт ревьюера FAIL`
(`:2`) не тронута. Отказ на R — шагом 5 до 6б, той же причиной (прогон ниже).

# 3. Права авторов

- `_toy.sh` — коммит `082725f1` author/committer `architect`. Зона: `frozen/contracts/038/2`
  `:363` «ЗОНА architect: … fixtures/done_contract/ …». Байт-пин `038:389–395` — норма ПЕРВОГО
  пост-фриз приземления, ловец — reviewer по диффу: дифф предъявлен в §2, смысл таблицы D не
  меняется. Ремонт хрупкой клетки без смены смысла — `roles/architect.md` §«Неисправная проверка»,
  «Хрупкая клетка» (`:147–150`). Согласен.
- `case_verdikt_fail.sh` — `423389cf` implementer; `038/2:387` «ЗОНА implementer: …
  fixtures/done_contract/ …», case_*.sh — его презентации (`:391–392`). Согласен.
- `fail_closed_992.py` — `c5119b7c` implementer; `frozen/contracts/992/1:50` «ЗОНА implementer: …
  fixtures/freeze_contract/», ПЕРЕСЕЧЕНИЕ `:53` «после приёмки конструкции 992 только исправления
  по находкам, не смена критерия» — критерий клеток не сменён (§2). Согласен.
- Механика зон — прогон `scripts/check_zones.sh` (§4) и CI `ap3`/`legkij` на `c5119b7cb8`.
Слово владельца/v+1 не требуются; несогласий нет.

# 4. Зависимый регресс — сырой вывод (мой прогон, клон на OBJECT)

```text
$ EXPECT_RC=0 bash fixtures/_krasnye_038.sh
… (check_provodka 18 строк rc=0)
done_contract/red_D1_verdikt_zagolovok.sh rc=0
done_contract/red_D2_verdikt_fail.sh rc=0
done_contract/red_D3_verdikt_prefiks.sh rc=0
done_contract/red_D4_provodka_krasna.sh rc=0
done_contract/red_D5_v2_bez_razreshila.sh rc=0
done_contract/red_D7_ne_zakommichen.sh rc=0
done_contract/red_D8_prichina_pusta.sh rc=0
done_contract/red_D9_dva_verdikta_svezhij_fail.sh rc=0
done_contract/green_D10_env_gigiena.sh rc=0
done_contract/green_D6_v2_s_razreshilom.sh rc=0
done_contract/green_G_polnoe_derevo.sh rc=0
… (check_consumers 8 строк rc=0, red_atribucija_okna_062 rc=skip — чужой NNN 062)
итог: 37 файлов, расхождений 0 (режим ожидания rc=0)
rc=0

$ PYTHONDONTWRITEBYTECODE=1 python3 fixtures/freeze_contract/fail_closed_992.py
A-freeze-spec subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
A-done-log subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
  done: история вердикта не читается (git log rc=128): verdicts/review/contracts-001-v2.md — проверить невозможно
A-done-order subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
  done: порядок вердиктов не читается (merge-base rc=128): verdicts/review/contracts-001-v2.md — проверить невозможно
… (прочие 19 клеток accepted=1)
B-freeze-versions subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
  ОТКАЗ: перечень версий не читается (git for-each-ref rc=128): refs/tags/frozen/contracts/001/ — проверить невозможно, версия не угадывается
B-done-versions subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
  done: перечень версий не читается (git for-each-ref rc=128): refs/tags/done/contracts/001/ — проверить невозможно, версия не угадывается
B-ci-ok-write subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
  …/registry/candidates.tsv: Permission denied
  ОТКАЗ: журнал: check-строка не записана: …/registry/candidates.tsv
B-ci-fail-write subject: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1
cases=25 observations=25 failures=0
rc=0

$ bash scripts/verify_antiplacebo.sh --scope done_contract
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   done_contract/case_verdikt_fail.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вердикт ревьюера FAIL»
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
rc=0

$ bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --model | tail
CELLS=62 STABS=0 FAILURES=0
rc=0
$ bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh | tail
GREEN karta-jq-vyzovov: механизм _json_one_object × 5, jq вне механизма не читает недоверенные байты
CELLS=62 STABS=0 FAILURES=0
rc=0
```

Fault-операции 992 прежние: log по пути v2 (A-done-log), merge-base --is-ancestor (A-done-order),
for-each-ref по `refs/tags/done/contracts/001/` (B-done-versions) — фразы отказов совпадают с
regex-ами CASES `:67,68,88`.

```text
$ bash scripts/check_zones.sh | tail
  ok   контракт 045: коммит 9c372335 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 045: коммит fc7c536a (implementer) — СПАСЕНО, из суда зон выведен
процессных вне суда:
замороженных контрактов: 181 · объявленных авторов: 5 · коммитов в диапазонах: 64978 · проверено по зонам: 20950
rc=0   (полный, без --incr; 783 с)
```

# 5. Красное до ремонта и «дверь без заморозки по-прежнему отказывает»

Своя мера на `wt-before` (`423389cfb9`; блоб двери тот же, что на OBJECT — §1):

```text
red_D5: ОТКАЗ: D5: отказ не назвал причину дословно «done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине»:
        done: нет заморозки frozen/contracts/001/* — привязка accept к последней версии невозможна   rc=1
green_D6: ОТКАЗ: D6: v2 с РАЗРЕШИЛОМ не поставлен (rc 1): done: нет заморозки frozen/contracts/001/* …  rc=1
green_D10: ОТКАЗ: D10: отравленная среда уронила писателя (rc 1): done: нет заморозки … rc=1
green_G: ОТКАЗ: DG: честное дерево не принято (rc 1): done: нет заморозки … rc=1
A-done-log subject: control_rc=1 fault_rc=1 oracle=1 hit=1 accepted=0   CONTROL: done: нет заморозки frozen/contracts/001/* …
A-done-order subject: control_rc=1 fault_rc=1 oracle=1 hit=1 accepted=0  CONTROL: done: нет заморозки …
B-done-versions subject: control_rc=1 fault_rc=1 oracle=0 hit=0 accepted=0 CONTROL: done: нет заморозки …
ap (case_verdikt_fail.sh из 42d0860510):
  FAIL done_contract/case_verdikt_fail.sh: нет положительного контроля — … ; расхождений: 1  rc=1
```

Это же — подтверждение пункта 4 задания: живая дверь (блоб неизменён) на мирах БЕЗ заморозки
отказывает `done: нет заморозки frozen/contracts/001/* — привязка accept к последней версии
невозможна`; в батарее 201 та же причина — клетка `a-net-zamorozki`
(`dver_probe.py:90,229`), зелёная в обоих прогонах выше. Ремонт сделал контроли зелёными, не
ослабив отказ: отремонтированные миры получают заморозку, а не исключение в двери.

CI: run `44351387164` (`gh run list --branch wip/201/implementer`) на `c5119b7cb8` —
`completed success`; PR #1096 `CLEAN`, statusCheckRollup = 16 SUCCESS + 1 SKIPPED (`vorota`) —
не «17 зелёных», см. С-2. Предыдущие головы `48cd5659`/`42d08605`/`423389cf`/`082725f1` — failure
(тот же рисунок ap2 → l7 → l5, закрываемый поочерёдно).

# 6. Паразитная сложность (контракт 050)

- `_toy.sh::make_drepo` (раздут на 3 строки кода): (1) свойство — достижимость сценариев D
  таблицы `038:442–457` при двери `201:36–44`; (2) новое состояние — тег `frozen/contracts/001/1`
  и коммит V в disposable-мире, явно в коде; (3) при следующей правке предпосылок двери меняются
  вместе 3 файла (`_toy.sh`, `case_verdikt_fail.sh`, `fail_closed_992.py`) — было столько же миров,
  новых связей диффом не добавлено; (4) интерфейс `make_drepo <каталог> <блок>` не изменился;
  (5) потребитель — `_krasnye_038.sh` (lane l7). ESSENTIAL.
- `case_verdikt_fail.sh::put_verdict`, `freeze_in` (новые функции): (1) тот же пункт (а) двери 201
  для зелёного контроля антиплацебо; (2) состояние явно в аргументах; (3) см. выше; (4) 2–3
  позиционных аргумента, без env/флагов; (5) потребитель — `verify_antiplacebo.sh` (ap2). Дубль
  грамматики `_toy.sh::put_verdict` (иная сигнатура) — файл исторически самодостаточен
  (собственный `make_drepo` с `e448f4ed`); совет не выношу — сокращение связало бы презентацию
  implementer с байт-пиненным `_toy.sh` architect. ESSENTIAL.
- `fail_closed_992.py` done-ветка `prepare`: (1) достижимость зелёного контроля клеток
  A-done-log/A-done-order/B-done-versions (`992` критерий accepted=1); (2) состояние явно —
  disposable repo; (3) не выросло; (4) интерфейс `prepare(base, case, source)` прежний;
  (5) потребитель — `red_doc_lifecycle.sh` → `check:document` (lane l5). ESSENTIAL.

# ОСТАТОК (контракт 192)

ОСТАТОК: НЗ-1 (эра внешнего SHA) — не укусил: дифф ремонта не содержит внешних OBJECT.
ОСТАТОК: НЗ-2 (семантика вердикта; правдивость СВЕРКА-АРХИТЕКТУРЫ) — не укусил: судимый предмет —
весь ремонт (три файла), строка СВЕРКА-АРХИТЕКТУРЫ сверена по диффу §1.
ОСТАТОК: НЗ-7 (Git-достижимость ≠ полнота) — не укусил: полнота ремонта сверена по клеткам
(11 потребителей `make_drepo`, 3 done-клетки 992, 1 антиплацебо-фикстура), не по достижимости.
ОСТАТОК: НЗ-8 (правдивость места и legacy-записей) — не укусил: `registry/mesto-legacy.tsv`
неизменён; toy-строки `ПРОДУКТ: станция`/`КЛАСС РИСКА: обычный` — данные disposable-миров
номера 001, не записи станции.
ОСТАТОК: НЗ-9 (семантика внешнего продуктового SHA) — не укусил: внешних OBJECT нет.

# 201 COMPAT

201 COMPAT: исходный OBJECT двери=bdf592e098eaaba9f14616e86751deb1eac2847b; проверенная интеграционная голова=c5119b7cb81c9d7da55f0b5f25a89cb76bfda8de; production blobs двери/реестра и frozen-текст 201 неизменны; критерии D5/D6/D10/G и fault-операции A-done-log/A-done-order/B-done-versions неизменны; изменены только prerequisites disposable-миров; доказательства=`git diff bdf592e098 c5119b7cb8 -- scripts/done_contract.sh registry/mesto-legacy.tsv` пусто, `git diff frozen/contracts/201/1 c5119b7cb8 -- contracts/201-…md` пусто, `git diff 42d0860510 c5119b7cb8` = 3 fixture-файла (§1–§2), сырой вывод `_krasnye_038.sh` 37/0, `fail_closed_992.py` 25/25 failures=0, antiplacebo done_contract 1/1, 201 --model и live 62/0, красное-до на `423389cfb9`/`42d0860510` (§4–§5). Поведение продукта, критерий и разрешённый риск не менялись; старые accept не выдаются за проверку нового test-infra diff.

# Развилки (оркестратору; не блок)

Р-1 — `.review/2026-11-18-113.md`: этот вердикт по заданию несёт `OBJECT=c5119b7cb8…` и станет
свежайшим `verdicts/review/contracts-201-*.md`; дверь у рискового 201 требует тот же OBJECT у
свежего accept адверсария (`scripts/done_contract.sh:440,642–674`), а Adv201d стоит на
`bdf592e098`. [INFERENCE по коду: `done 201` после этого коммита откажет «accept адверсария … на
объект bdf…, ревьюера — на c5119…»; дверь не запускалась — done-тег на копии настоящего репо не
ставлю.] Решение маршрута — оркестратора/владельца (otvet.md §3).

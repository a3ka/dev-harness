accept
OBJECT=5087619f79a34e53e33d887e9f449508abc23146

# Вердикт ревьюера 087, круг 3 (последний по капу) — accept

Находки: `.review/2026-10-19-03.md` (status: ready). Блокирующих нет. Р2-1/BUDGET-121 закрыт
по замеру, а не по весам. Р3-1…Р3-5 — советы и открытые до done пункты, каждый с обходом
либо пометкой «совет».

Клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev087r3/clone`,
detached 5087619f. Мутации — только в одноразовых клонах `../c2` (живое дерево), `../c3`
(дерево после `ci_klass.sh strip`), `../c4`. Основной чекаут не тронут.

## 1. Область правки (зоны сверены живьём с замороженными блобами)

Дифф 2a6d59e27..5087619f — 10 файлов, 4 коммита + land-мерж (сводки по каждому — `git show --stat`):

| коммит | author / committer | пути | зона |
|---|---|---|---|
| eac806974 | architect / architect | NABLIUDENIA_ARCHITECT.md, fixtures/ci_b_087/{_toy.sh, red_ci_b_087.sh} | ЗОНА architect 087/1 |
| 544ace744 | architect / architect | fixtures/pokrytie_083_088_079/{red_istochnik_incr_079.sh, _zamorozka/ROADMAP.md}; fixtures/ops_server/{red_server_obvjazka_074.sh, _zamorozka/HANDOFF_GDE_MY.md}; fixtures/check_runner_hygiene/_zamorozka/contracts-010-v2.md; scripts/check_runner_hygiene.sh; fixtures/ci_b_087/red_ci_b_087.sh | 079/2 `fixtures/pokrytie_083_088_079/`; 074/2 `fixtures/ops_server/`; 011/3 и 012/3 `scripts/check_runner_hygiene.sh`, `fixtures/check_runner_hygiene/` (также 025/5, 067/1); 087/1 — всё внутри объединения |
| bb1804b67 | implementer / implementer | registry/ci-steps.tsv, .github/workflows/ci.yml | ЗОНА implementer 087/1 |
| 10af705b5 | architect / architect | NABLIUDENIA_ARCHITECT.md (откат записи А-922 из eac806974; суммарный дифф по файлу пуст) | ЗОНА architect 087/1 |
| 5087619f | orchestrator | land-мерж (2-й родитель 10af705b5; сверх него только registry/contracts.tsv и ещё 1 учётный файл; H(10af705b5) = H(5087619f) = 0289c48b…) | — |

- 544ace744 (git-plumbing оркестратора под автором architect): пара author/committer —
  architect/architect. Содержимое сверено с клоном `/tmp/dev-harness-verify/Architect087r3/clone`:
  коммит архитектора b883291f — то же сообщение (md5 тела совпал), патч совпадает построчно
  во всех +/- строках; `diff` двух патчей отличается только строкой индекса и контекстной
  строкой `ROLE_CEILING=51200 → 53248` (база main ушла раньше 2a6d59e27). eac806974 —
  `git patch-id --stable` = e220eb26… у обоих (архитекторский 8032d670).
- `bash scripts/check_zones.sh` (клон c4) → rc 0, «замороженных контрактов: 104 … проверено по
  зонам: 3188» (строка FAIL про грамматику 055 — прежняя, на rc не влияет).
- Тексты норм не тронуты: `git diff --name-only 2a6d59e27..HEAD -- contracts roles AGENTS.md`
  — 0 путей; `git diff --quiet frozen/contracts/087/1^{commit} HEAD -- contracts/087-…md` rc 0.
- ci.yml: lane-матрица перегенерирована (`bash scripts/gen_ci_steps.sh --check` rc 0); мой
  подсчёт ключей в -/+ строках `keys:` — каждый прежний ключ ровно в обеих сторонах, новые
  только check:pokrytie-079-family-selftest, check:ops-server-family-selftest,
  check:runner-hygiene (по 1 разу); из run-строки legkij удалены те же три (ci.yml:129).

Превышения зон нет.

## 2. Сырой вывод (мои прогоны на 5087619f)

- `bash fixtures/_krasnye_087.sh` → rc 0, «ИТОГ 087: клеток ok=108 КРАСНО=0; стаб-пак:
  поймано 28/28 (subject)», 66 с. Своя мера по сырому логу: 136 строк `  ok `, из них
  28 `  ok   стаб` → 108 клеток; строк `КРАСНО:` — 0.
- Живое дерево (c2): `bash fixtures/_krasnye_079.sh` rc 0 «ИТОГ 079 (polnyj): rc=0» (12 с);
  `bash fixtures/_krasnye_074.sh` rc 0 «итог 074: красных клеток=0 стабы=7/7» (2 с);
  `npm run -s check:runner-hygiene` rc 0, 19/19 ветвей, porjadok ok (34 с);
  `bash scripts/verify_ci_parity.sh` rc 0 (28 ok); `bash scripts/gen_ci_steps.sh --check` rc 0.
- Дерево после strip (c3, `ci_klass.sh strip 0289c48b…` → «удалено учётных путей 1230»):
  те же три команды rc 0 / rc 0 / rc 0 (12 с / 2 с / 34 с).
- `bash fixtures/_krasnye_083.sh` (c4) → rc 0, «083-батарея: ok=120 FAIL=0».
- `npm run check:antiplacebo -- --scope check_runner_hygiene` (c2) → rc 0, «барьеров: 1 · фикстур: 40 · предъявлено красным повторным прогоном: 40» (279 с);
  фикстуры «вердикт удалён» среди 40 нет — поэтому Р3-1 не видна раннеру.
- `bash scripts/check_provodka.sh . contracts/087-ci-b-klassy-izmenenij-hesh-koda.md` rc 0.

### Замер бюджета legkij (gh api, push-прогоны main; джоба = completed_at − started_at)

| прогон | sha | legkij | стена прогона | тяжёлые |
|---|---|---|---|---|
| 39240153431 | e7cc02c67 (до правки) | 134 с | 138 с | skipped |
| 39243748125 | 2a6d59e27 (до правки) | 134 с | 137 с | skipped |
| 39245598859 | 5087619f7 (land) | 74 с | 78 с | skipped (reuse по H) |
| 39245885487 | b2e0ce963 | 80 с | 83 с | skipped |
| 39248280542 | 02f011435 | 73 с | 75 с | skipped |

Строки `замер:` legkij на трёх push после ленда: charter 45/50/44, zones 12/11/12, ids 0,
protected 0, nabludenia 0, contract-frozen 3/3/4 — сумма run-шага 60–64 с.
Доказательство: артефакт `tyazhelyj-0289c48b…` expired=false, head_sha=10af705b5,
repository_id = head_repository_id; PR#115 head 10af705b5 — check-runs success=16 skipped=1
(vorota на PR); в lane-логах PR-прогона 39243953633 три ключа исполнены на дереве после strip:
`замер: check:pokrytie-079-family-selftest 13`, `check:runner-hygiene 35` (l3),
`check:ops-server-family-selftest 2` (l4).

## 3. Проверки не переписаны под реализацию

- Батарея 087: `git diff 2a6d59e27..HEAD -- fixtures/ci_b_087/red_ci_b_087.sh` чисто
  аддитивен: шапка (К10/К10-исп/К11 + 2 стаба), функции K10/k10_cmd/k10_tree/K10I/K11, 5 вызовов
  `cell`, 2 строки `stab`. Ни одна клетка К1…К9, К-исп, В1/В2 не изменена. `_toy.sh` — только
  добавление (toy-команда и три step-строки модели; ветви M087_STAB).
- Implementer (bb1804b67) батарей и фикстур не касался — только реестр и ci.yml.
- Батареи 079/074/011 на живом дереве: зелены (см. §2) и ЖИВОЕ различают:
  `cell_k7` на живом дереве с удалённым указателем первой секции HANDOFF → `КРАСНО: cell_k7`,
  rc 1; porjadok с первой строкой вердикта `FAIL` → rc 1 «первая строка … — «FAIL», а не accept».
  Отклонения от «копия — только фолбэк»: `build_docs` 074 и toy-мир 079 читают копию
  безусловно; porjadok теряет «вердикт удалён» — Р3-1, Р3-2 (советы, цена варианта (А)).

## 4. Красное предъявлено

- Дерево после strip (c3) со скриптами/фикстурами 2a6d59e27: `_krasnye_079.sh` rc 1 («cp: cannot
  stat …/ROADMAP.md», «ИТОГ 079 (polnyj): rc=1»); `_krasnye_074.sh` rc 1 («итог 074: красных
  клеток=2»); `check_runner_hygiene.sh . porjadok` rc 1 «файла verdicts/critic/contracts-010-v2.md
  нет на дереве».
- Батарея 087 (новая) на состоянии круга 2 (реестр, ci.yml, две фикстуры и скрипт гигиены
  из 2a6d59e27, c3): rc 1, «ИТОГ 087: клеток ok=106 КРАСНО=2»: `КРАСНО: К10 … :legkij …:bez-step`,
  `КРАСНО: К10-исп … отказ — чтение учётного пути: check:pokrytie-079… check:ops-server…
  check:runner-hygiene`. К11 на том же состоянии зелёна (сумма весов 120) — Р3-3.
- Стабы (Н-39, привязка по коду): `legkij-tri-klyucha` — модель с тремя legkij-строками
  (`_toy.sh` ветвь M087_STAB) → K10 красна, диффпроба K11 subject зелёна (45 ≤ 120);
  `chitaet-uchet` — toy-команда `cat ROADMAP.md`, k10_tree удаляет ROADMAP.md (U87) → K10I
  красна, диффпроба K10 зелёна. Шапка и `stab`-строки совпадают с ветвями кода.

## 5. Атомарность

Каждый коммит — один предмет со ссылкой «087 … r3». 544ace744 несёт копии трёх соседних
семей, но это одно свойство (учёт-независимость трёх ключей, вариант (А) форка
n087-budget-legkij). eac806974 + 10af705b5 по NABLIUDENIA_ARCHITECT.md — запись и откат,
суммарно пусто.

## 6. Норма не тронута

contracts/, roles/, AGENTS.md в диффе отсутствуют. Правка барьера 011/012
(`check_runner_hygiene.sh`) — в зоне architect 011/3 и 012/3 и названа мандатом (А) форка
(«правка зон architect 074/079/runner-hygiene»); ослабление ветви — Р3-1.

## 7. Реализованность §Предмет (пункт → место в коде)

1. Хеш и класс — `scripts/ci_klass.sh` (`hash`, `klass`), строки `uchet` реестра (10).
2. Доказательство — `ci_klass.sh dokaz|reshenie|strip`; артефакт `tyazhelyj-<H>` джобы
   tyazhelyj-itog (ci.yml:306-314; живой: tyazhelyj-0289c48b…).
3. Проводка — ci.yml: klass :42/:55, vorota :63/:73, legkij :82, obshchij :190 (strip :200,
   `_krasnye_087.sh` :215), antiplacebo :223 (strip :250), ci :262 (strip :292), tyazhelyj-itog :306;
   `cancel-in-progress` встречается только в комментарии :20. Тяжёлые на push main — skipped.
4. Ворота — `scripts/check_ci_gate.sh` 4б (:209-261, `legkij`, `ci_klass.sh dokaz`);
   `scripts/gitw_preflight_071.sh` чек 5 (:412-440).
5. Веса — `run_ci_lane.sh:68` («замер: <ключ> <сек>»), `scripts/ci_vesa.sh`; веса реестра по
   замерам ещё не записаны — Р3-3 (А8 до done).
Круг 3 правил только п.3 (три ключа step, а не legkij) и учёт-независимость их команд.

ПРОВОДКА: `guard=fixtures/_krasnye_087.sh` — шаг obshchij (ci.yml:215), ключ
`check:ci-b-087-family-selftest` (package.json:81); `check_provodka.sh` rc 0. Guard —
барьер именно этого предмета (батарея 087). ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: предмет —
механизм CI/ворот, поведенческой норма-строки нет.

## 8. Закрытие круга 2 (`.review/2026-10-19-01.md`)

| пункт | статус | мера |
|---|---|---|
| Р2-1 бюджет legkij | закрыт по замеру: 74/80/73 с (было 134/134) | gh api jobs, §2 |
| Р2-2 package.json | не менялся (не ухудшен) | дифф круга 3 без package.json |
| Р2-3 литерал А4 | не ухудшен по существу: ok=108, 28/28 | Р3-5 |
| Р2-4 parity по реестру | не менялся | — |
| Р2-5 ci_klass cwd | не менялся | — |
| Р2-6 sha вердикта адверсария v1 | вне круга 3 | — |
| Р2-7 веса | не ухудшен; А8 rc 1 на логах приёмки | Р3-3 |

## 9. Паразитная сложность (050): (1) свойство; (2) состояние; (3) файлов на правку; (4) глубина; (5) потребитель

- `_zamorozka/` (3 копии: ROADMAP.md 529 строк, HANDOFF_GDE_MY.md 26, contracts-010-v2.md 27)
  — (1) 087 §Frontier «тяжёлый вердикт — функция кодового дерева» + вариант (А); (2) копия —
  явный файл в коде (входит в H); (3) свойство «вход семьи» теперь живёт в копии и в живом
  файле — +1 файл на семью; (4) интерфейса нет; (5) К10-исп, lane-ключи l3/l4. ESSENTIAL
  (более простая форма — чтение через `git show` — отвергнута моделью угроз 087).
- Ветвь фолбэка porjadok (`check_runner_hygiene.sh:710-716`) — (1) то же; (2) нет; (3) 1;
  (4) без нового интерфейса; (5) l3. ESSENTIAL по свойству, узость — Р3-1 (совет).
- `ZAM_HANDOFF` + фолбэк `cell_k7` + `build_docs` (074) — (1) то же; (2) нет; (3) 1 + копия;
  (5) l4. ESSENTIAL; безусловность `build_docs` — Р3-2 (совет).
- К10/К10-исп/К11 (+k10_cmd, k10_tree) — (1) Р2-1/BUDGET-121 (И-2, И-10); (2) временный
  каталог `$T/k10-derevo` батареи, явный; (3) 1; (4) удаление — оракул батареи (`_orakul.u_covers`),
  не субъект — независимость; (5) А4 через obshchij. К10/К10-исп ESSENTIAL; К11 считает угаданные
  веса — Р3-3 (совет: без ci_vesa --write мера слабая, но не ACCIDENTAL — пара 120/121 требуется
  находкой BUDGET-121).
- `_toy.sh` M087_STAB (2 стаба, toy-команда) — семья стабов одним артефактом: (1) Н-39 к К10/К10I;
  (2) env M087_STAB только внутри батареи; (5) стаб-пак 28/28. ESSENTIAL.
- Реестр: три строки legkij → step с комментариями — (1) И-2; (3) реестр + ci.yml (генератор) —
  прежние 2. ESSENTIAL.

ACCIDENTAL-находок нет.

## Итог

accept. Предмет круга 3 (Р2-1) сделан: три ключа — step-строки, исполняются в тяжёлых lane на
дереве без учётных путей и зелены; legkij на push main 73–80 с. Обхода по существу 087 не
найдено. Открыто до done (не блок круга 3): А7 (rc 2 — данных мало, Р3-4) и А8 (rc 1 —
веса не по замерам, Р3-3). Р3-1/Р3-2 — цена варианта (А) для 011/074, к консультанту.

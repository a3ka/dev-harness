accept

# Reviewer 067: круг 3 — isolation.backend: auto (правка Р-2а)

Предмет: `frozen/contracts/067/1` (commit `29aa3ec`), `contracts/067-isolyacija-backend-auto.md`.
Круг 2: `verdicts/review/contracts-067-v2.md` (`d4f863e`): FAIL, единственный блокер Р-2а.
Судимая правка: `a2e054c` (implementer <implementer@dev-harness.local>, родитель `2bcb323`, потомок `d4f863e`),
ленд `4337ed7` (merge оркестратора, второй родитель `a2e054c`).
Судимый HEAD: `00ab79c` (= origin/main). Коммиты `4337ed7..00ab79c` меняют только 070, HANDOFF, ci.yml, registry,
NABLIUDENIA, workshop. `git log d4f863e..HEAD -- scripts/check_runner_hygiene.sh fixtures/check_runner_hygiene/ contracts/067-…`
выдаёт ровно один коммит: `a2e054c`.
Клон суда: `/tmp/dev-harness-verify/rev067k3` (свежий `git clone ssh://git@github.com/a3ka/dev-harness.git`).
Пробы и мутанты лежали в одноразовом `_probe067k3/` внутри клона (`run.sh`, `mutants.sh`). Мутанты работали на копии
`git archive HEAD`, а не на дереве клона. После прогона каталог удалён.

| артефакт | блоб HEAD (`00ab79c` = `4337ed7` = `a2e054c`) | блоб круга 2 (`d4f863e`) |
|---|---|---|
| `scripts/check_runner_hygiene.sh` | `a2e8981` | `91c995c` |
| `fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh` | `e6fd9a7` | `face767` |
| `contracts/067-isolyacija-backend-auto.md` | `269706b` | `269706b` (= freeze) |
| `.omp/config.yml` | `b1f8d3d` | `b1f8d3d` |
| `fixtures/check_runner_hygiene/_lib.sh` | `ca8e5f6` | `ca8e5f6` |

Вердикт связан с этими блобами. Новая редакция любого из них принятия не наследует.

## Стенограммы спавна

- CI: слово оркестратора — 6/6 зелёный на `00ab79c`. Я его не перепрогонял: по Н-48 полный прогон относится к CI.
- Детектор утечки: слово оркестратора — rc 0. Мой клон начат на `00ab79c`.

## Сырой вывод (приёмка scoped, Н-48)

```text
$ bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh .
ВЕТВЬ к1-norma-avto зелёная … ВЕТВЬ к13-chuzhoj-enabled зелёная
ВЕТВЬ к14-hvost-bez-probela зелёная
ИТОГ 067: ветвей 14, красных 0, зелёных 14                                    battery rc=0
$ bash scripts/check_runner_hygiene.sh . izolcfg
  ok   (izolcfg) .omp/config.yml: task.isolation.enabled: true + верхнеуровневая isolation.backend: auto
check_runner_hygiene: ветви «izolcfg» зелены                                   izolcfg rc=0
$ git diff --exit-code frozen/contracts/067/1 HEAD -- contracts/067-isolyacija-backend-auto.md   (пусто) rc=0
$ git diff --stat frozen/contracts/067/1 HEAD -- fixtures/…/red_izolcfg_backend_avto_067.sh
  1 file changed, 191 insertions(+), 21 deletions(-)      = дифф круга 2 (1701ee3→face767, судим в v2) + a2e054c
$ git diff --stat face767 e6fd9a7                         1 file changed, 37 insertions(+), 3 deletions(-)
$ reslop t -- bash scripts/check_provodka.sh . contracts/067-isolyacija-backend-auto.md   exit: 0   provodka rc=0
```

**Дифф батареи в `a2e054c` — только усиление (прецедент 005).** Своя мера: я снял с диффа строки комментариев
(`git diff -U0 a2e054c^ a2e054c -- fixtures/ | grep -E '^[-+]' | grep -vE '^[-+]#'`). Осталось только это:
`ORDER` (дописан `к14-hvost-bez-probela`), `mk_cell к14`, heredoc конфига к14 (`backend: auto#btrfs`) и
`run_cell к14-hvost-bez-probela reject 'PINNED_BACKEND'`. Тело `run_cell`, сводка и клетки к1–к13 не тронуты.

**Число 14 своей мерой** (другая команда, не вывод батареи): `grep -cE '^run_cell '` → 14;
уникальных `к[0-9]+` в `ORDER=(…)` → 14.

## Проба r01 и соседи: барьер HEAD против omp на одном входе (`run.sh`)

Конфиг каждой пробы: `task:`/`  isolation:`/`    enabled: true` + `isolation:`/`  backend: <X>`.

```text
r00  backend: btrfs$               barrier rc=1 PINNED_BACKEND «btrfs»        omp "btrfs"
r01  backend: auto#btrfs$          barrier rc=1 PINNED_BACKEND «auto#btrfs»   omp "auto"   ← моя проба круга 2: теперь ловится
r02  backend: auto#$               barrier rc=1 PINNED_BACKEND «auto#»        omp "auto"
r03  backend: auto # comment$      barrier rc=0 ok                            omp "auto"
r04  backend: auto^I# tab comment$ barrier rc=0 ok                            omp "auto"
r05  backend: auto #$              barrier rc=0 ok                            omp "auto"
r06  backend: auto   $             barrier rc=0 ok                            omp "auto"
r07  backend: auto$                barrier rc=0 ok                            omp "auto"
r08  backend: #auto$               barrier rc=1 PINNED_BACKEND «#auto»        omp "auto"
r09  backend: auto #btrfs$         barrier rc=0 ok                            omp "auto"
r10  backend: btrfs #auto$         barrier rc=1 PINNED_BACKEND «btrfs»        omp "btrfs"
r11  backend: auto^I#btrfs$        barrier rc=0 ok                            omp "auto"
```

Разбор по YAML. `#` без пробела перед ним (r01, r02) — часть скаляра. Барьер сравнивает значение целиком и
отвергает, что соответствует инв. 4. `#` после пробела или таба (r03–r05, r09, r11) — комментарий: барьер срезает его
так же, как YAML, и omp видит auto. r10 честно отвергнут: значение `btrfs`, хвост — комментарий.
r08 (`backend: #auto`, то есть null, и omp откатывается на дефолт) отвергнут с причиной «#auto». Это ложный отказ в
безопасную сторону и не регрессия: до фикса `*` срезал всё до пустой строки, и отказ был PINNED_BACKEND «».

## Красное и мутанты (своя мера, B2d; `mutants.sh` на копии `git archive HEAD`)

```text
== M0 контроль: копия HEAD без мутации                     ИТОГ 067: ветвей 14, красных 0, зелёных 14   rc=0
== M1 квантор назад: [[:space:]]+# → [[:space:]]*#  (дифф мутанта: 1 file changed, 1 insertion(+), 1 deletion(-))
ВЕТВЬ к14-hvost-bez-probela красная: ожидался ОТКАЗ rc=1 … «PINNED_BACKEND», получено rc=0:   ok   (izolcfg) …
ИТОГ 067: ветвей 14, красных 1, зелёных 13                                                              rc=1
== M2 барьер до фикса: блоб 2bcb323:scripts/check_runner_hygiene.sh (= 91c995c круга 2)
ВЕТВЬ к14-hvost-bez-probela красная … получено rc=0: ok (izolcfg) …
ИТОГ 067: ветвей 14, красных 1, зелёных 13                                                              rc=1
== M3 строка среза комментария удалена целиком               ИТОГ 067: ветвей 14, красных 0, зелёных 14   rc=0  ← выжил (С-9)
```

Видно три вещи. Красное ДО предъявлено: к14 краснеет на барьере круга 2. Мутант `*`/`+` батарея теперь различает.
Контрольные клетки к2–к13 на M1 и M2 зелёные, то есть не деградировали. Строгость к2–к13 против их собственных
мутантов измерена в круге 2: барьер в части к1–к13 не менялся (дифф барьера — одна строка), а тело `run_cell` не
тронуто.

## Закрытие находок

- [x] **Р-2а — ЗАКРЫТ.** Фрагмент `scripts/check_runner_hygiene.sh:881` `sub(/[[:space:]]+#.*$/, "", val)` совпадает с
  формой лечения, которую я проверил в круге 2. r01 даёт PINNED_BACKEND «auto#btrfs». Клетка к14 пинует фикс: M1 и M2
  её краснят.

## Находки (reslop)

status: ready

Новых блокеров нет. Открытые пункты круга 2 переносятся: их правка `a2e054c` не трогала и не должна была.

- [ ] **С-9 (совет, батарея; новый).** Направление «честный комментарий после пробела принимается» не пинуется.
  Мутант M3, удаливший срез комментария целиком, проходит 14/0/14. После него барьер отверг бы
  `backend: auto # …` (omp → auto). Отказ при этом безопасный (fail-closed), и живой `.omp/config.yml:76` несёт
  `backend: auto` без комментария, так что рантайм-вреда нет. Чтобы пинить срез, хватит клетки
  `backend: auto # комментарий` → accept (r03 выше).
- [ ] **С-8б (совет; перенос из круга 2, обострён).** Строка приёмки Р5 и раздел «После реализации» контракта
  дословно ждут «ветвей 8, красных 0, зелёных 8». Батарея печатает 14 (8 + к9–к13 + к14 по прецеденту 005). Нужна
  пометка architect'а или владельца о прецеденте 005 для Р5. Норму сам не правлю.
- [ ] **Р-4 (вопрос владельцу; перенос, не блокирует).** Без изменений: дубли ключей, flow-переопределения,
  многодокументный YAML (q05, q12, r09, t03 круга 2).
- [ ] **С-1, С-3, С-6, С-7, С-8а, С-8в (советы; перенос).** Не тронуты. С-8в своей мерой:
  `tail -c 12 … | xxd` → `…WORK".exit 0`, без `0a` в конце — финального перевода строки по-прежнему нет.

## Паразитная сложность (050)

- **квантор среза `#` в правиле `^  backend:` (`*` → `+`)** — (1) инв. 4 (значение сравнивается целиком, хвост не
  совпадает), Р-2а; (2) нового состояния нет: та же локальная `val`, видна в причине PINNED_BACKEND («auto#btrfs»);
  (3) свойство правится одной строкой, число файлов не выросло; (4) интерфейс ветви прежний (`izolcfg`, rc 0/1,
  причина); (5) потребитель — к14 (M1 → красная к14). ESSENTIAL. Сложность не выросла: это 1 символ в существующем `sub`.
- **клетка к14 «хвост-без-пробела»** — (1) инв. 4 и инв. 3 (отказ с именованной причиной PINNED_BACKEND), Р-2а;
  (2) состояние — `$WORK/к14-…` батареи, как у соседей, явно в ORDER и в выводе «ВЕТВЬ к14…»; (3) при правке
  свойства меняются те же 2 файла (барьер + батарея), рост 0; (4) интерфейс `run_cell` прежний, используется
  существующий 3-й аргумент; (5) потребитель — красная дверь ПРОВОДКА-ЭНФОРСМЕНТ (прямые прогоны судей), грамматику
  барьера не копирует (оракул — живой rc). ESSENTIAL.

## Проверки роли по пунктам

1. **Область.** `a2e054c` трогает 2 пути: `scripts/check_runner_hygiene.sh` (одна строка внутри `if want izolcfg`) и
   батарею. Оба в `ЗОНА implementer:` контракта 067 (строка 102). Автор — `implementer`. ✓
2. **Сырой вывод.** Выше, с rc. ✓
3. **Проверка не подогнана.** Батарея изменена автором реализации, но это только усиление: одна клетка reject,
   прочие ожидания не тронуты (своя мера — дифф без комментариев). Контракт не тронут, frozen-diff пуст. ✓
4. **Красное.** к14 красная на барьере до фикса (M2) и на мутанте квантора (M1). ✓
5. **Атомарность.** Один implementer-коммит со ссылкой на 067 и на вердикт круга 2 (`d4f863e`). Ленд `4337ed7` —
   merge оркестратора. ✓
6. **Норма не тронута.** Нормативных документов в диффе нет. ✓
7. **Заявленное = сделанному.** «Один символ, только ветвь izolcfg» — да (дифф барьера 1/1 внутри izolcfg).
   «Батарея 13 → 14, 0 красных» — своя мера 14/14 (`grep run_cell`, `ORDER`) и живой прогон 14/0/14.
   «Контроль `backend: btrfs` покрыт к3» — к3 зелёная, r00 даёт PINNED_BACKEND. ✓

ПРОВОДКА: `guard=scripts/check_runner_hygiene.sh` существует, ветвь izolcfg — барьер именно этого предмета,
provodka rc 0. ПРОВОДКА-ЭНФОРСМЕНТ по-прежнему честна: норма — это состояние конфига. ✓

## Вердикт

**accept.** Р-2а закрыт: `backend: auto#btrfs` даёт PINNED_BACKEND, а к14 пинует фикс (красная на `*` и на барьере
круга 2). Батарея 14/0/14 rc 0, `izolcfg` rc 0, provodka rc 0, контракт не тронут, дифф батареи — только усиление.
Новых блокеров нет. С-9 и перенесённые С-1/С-3/С-6/С-7/С-8 — советы. Р-4 — вопрос владельцу.

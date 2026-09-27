accept

# Контракт 051 — ревью реализации (консолидация кругов 1–2)

Круг 1 (`a5201d7`): FAIL по Б1. Круг 2 (этот): Б1 ЗАКРЫТ фиксом `187d8e9` (ленд `59cb05a`),
блокирующих находок нет → accept. Круг 2 судит ТОЛЬКО закрытие Б1; остальное зелёное кругом 1
не пересуживалось — его строки ниже сохранены как мера круга 1 на дереве `7c40c63`.

## Привязка к блобам

- Круг 2 — дерево `59cb05a` (= origin/main; `git diff --quiet 187d8e9 59cb05a` rc=0: дерево
  ленда = дерево фикса).
- Барьер `scripts/check_fork_route.sh`: blob `25eae08`, sha256
  `66a6ce52e7113823d4b767e224a58ceceba0c413a96a45aa2f82cc2e74900f60` — не изменился с круга 1.
- Клетка Б1 `fixtures/check_fork_route/red_otvechennaja_peredatochnaja.sh`: blob `1747f31`,
  sha256 `f5cad691858243cbf69b29bcdfea5c9fa1c6d0154fbd656b17b895b30f26c512` (круг 1 судил
  `8c3a15c`, `fa6b8cbd…` — принятие к нему не относится). Новая редакция любого из двух блобов
  этого принятия не наследует.
- Мера круга 2: одноразовый SSH-клон `/tmp/dev-harness-verify/review051-r2-59cb05a/repo` @
  `59cb05a`, скрипт `../r2.sh`; мутант вносился `sed` и откатывался `git checkout --` (после
  отката sha барьера `66a6ce52…`, `git status --short` — 0 строк). Основной чекаут не тронут
  (только чтение и живой прогон барьера).
- Круг 1: клон `/tmp/dev-harness-verify/review051-r1-7c40c63/repo` @ `7c40c63`.

## Находки — сводка

| ID | Класс | Круг 1 | Круг 2 |
|---|---|---|---|
| Б1 | блокирует (семантический FAIL, S-grammarscope) | открыт | **ЗАКРЫТ** (`187d8e9`) |
| З1 | совет | заявлен | **СНЯТ как ложная находка круга 1** (см. ниже) |
| З2 | совет | заявлен | **ЗАКРЫТ** (`187d8e9`) |
| З3 | наблюдение, не дефект | заявлено | без изменений (клетка не тронута) |

### Б1 — ЗАКРЫТ

- **Обязательство:** frozen `contracts/051/1`, §«Стабы ↔ клетки», строка S-grammarscope
  (контракт, стр. 71): «`red_otvechennaja_peredatochnaja`, вход 2 (закрытая + не-ISO `ЗАВЕДЁН`,
  ожидание rc 1 «грамматика записи») | rc 0 → клетка красна (М3: rc 1); вход 1 при стабе честен»;
  §Красный протокол (стр. 178): «М3 grammarscope — `red_otvechennaja` rc=1, `red_otkrytaja` rc=0».
- **(а) Область.** `git diff --name-only a5201d7 59cb05a` → ровно
  `fixtures/check_fork_route/red_otvechennaja_peredatochnaja.sh` (+21/−11). Коммит `187d8e9`,
  автор `implementer <implementer@dev-harness.local>`, один предмет (Б1 + З2 в той же клетке);
  путь — в `ЗОНА implementer` frozen/051/1. `bash scripts/check_zones.sh .` (клон) → rc=0,
  «замороженных контрактов: 50 … проверено по зонам: 1434» (круг 1: 1432; +2 = фикс и вердикт
  круга 1). Барьер, контракт, прочие клетки не тронуты.
- **(б) Вход 2 = объявлению.** Фрагмент: `zapis "$R1" ci-closed-bad "КЛАСС: инженерный"
  "МАРШРУТ: консультант" "ОТВЕЧЕНО: да" "ЗАВЕДЁН: 18-09-2026 not-ISO"` → `zhdu_rc 1` +
  `zhdu_text 'грамматика записи'`. Закрытая — да; не-ISO `ЗАВЕДЁН` — да; rc 1 — да; текст
  «грамматика записи» — да. Вход 1 (закрытая передаточная, валидный ISO, rc 0) не изменён;
  прежний положительный контроль сохранён входом 3 (перед ним `rm -f …/ci-closed-bad.md`, иначе
  грамматика маскировала бы «передаточное касание»). Маршрут «консультант» у битой записи
  уводит её из 4в-батча — rc 1 даёт только секция 0, что и требует стаб.
- **(в) М3 красит клетку — измерено.** Мутант (клон, `bash -n` ok), дифф:
  ```
  @@ -157,2 +157,3 @@ for f in "${RECORD_FILES[@]}"; do
     zavedjon_val="$(record_field "$f" "ЗАВЕДЁН")"
  +  [ "$(record_field "$f" "ОТВЕЧЕНО")" = "да" ] && continue  # M3
     if [ -n "$zavedjon_val" ] && ! iso_is_valid "$zavedjon_val"; then
  ```
  ```
  M3-cell rc=1 :: bash fixtures/check_fork_route/red_otvechennaja_peredatochnaja.sh
      | ОТКАЗ: закрытая запись с не-ISO ЗАВЕДЁН всё равно судится грамматикой (инв. 2) — барьер вернул rc 0, ожидался 1. Вывод:
  M3-otkr rc=0 :: bash fixtures/check_fork_route/red_otkrytaja_peredatochnaja.sh
  M3-P15 rc=1 :: bash scripts/verify_antiplacebo.sh --scope check_fork_route/case_zakrytaja_bitaja_grammatika_rc1
      |   FAIL …case_zakrytaja_bitaja_grammatika_rc1.sh: барьер остался зелёным на обманном дереве — красное не предъявлено
  M3-live rc=0 :: bash scripts/check_fork_route.sh --root .
  ```
  Краснеет ассерт ВХОДА 2 (не 1) — «вход 1 при стабе честен» исполнено; `red_otkrytaja` rc=0 —
  как объявлено. Прямая проба и батарейный двойник Р15 теперь ловят S-grammarscope оба.
  Дополнительно (S-nofilter не потерян правкой клетки): ДО-барьер `e935aef` →
  `red_otvechennaja_peredatochnaja` rc=1, отказ ассерта 1 «закрытая передаточная не красит
  обычный режим … вернул rc 1, ожидался 0».
- **(г) Честный барьер (клон, `59cb05a`):**
  ```
  H-cell  rc=0 :: bash fixtures/check_fork_route/red_otvechennaja_peredatochnaja.sh
  H-otkr  rc=0 :: bash fixtures/check_fork_route/red_otkrytaja_peredatochnaja.sh
  H-scope rc=0 :: bash scripts/verify_antiplacebo.sh --scope check_fork_route
      | барьеров: 1 · фикстур: 5 · предъявлено красным повторным прогоном: 5
  H-P15   rc=0 :: bash scripts/verify_antiplacebo.sh --scope check_fork_route/case_zakrytaja_bitaja_grammatika_rc1
      | барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
  H-live  rc=0 :: bash scripts/check_fork_route.sh --root .
  H-schet rc=0 :: bash scripts/check_fork_route.sh --root . --schet
      | просмотрено 9
      | передаточных 2
  R-cell  rc=0 :: (после отката М3) bash fixtures/check_fork_route/red_otvechennaja_peredatochnaja.sh
  ```
  Живой в ОСНОВНОМ чекауте (`59cb05a`, `git status --short` — 0 строк):
  `bash scripts/check_fork_route.sh --root .` → пустой вывод, `live-main rc=0`.
  Счёт «фикстур: 5» своей мерой: `git ls-files fixtures/check_fork_route | cut -d/ -f3 |
  cut -d_ -f1 | sort | uniq -c` → `5 case`, `11 red`, `1` (`_forks.sh`) — сходится.

### З1 — СНЯТ: ложная находка круга 1

Круг 1 назвал в `case_ta_zhe_otvetchennaja_rc0.sh` опечатку `перед=аточная`. Проверка байтами
круга 2: `git show a5201d7:…/case_ta_zhe_otvetchennaja_rc0.sh | sed -n 31p | od -c` — байта
`=` (0x3D) в строке нет, текст `закрытая передаточная красит обычный режим — ожидался rc 0:
ci-dual-pered`; `git grep -n 'перед=' a5201d7 -- fixtures/` → rc=1. Файл с `63b0258` не менялся
(единственный коммит — implementer). Дефекта не было; фикс его и не трогал — правильно. Ошибка
меры круга 1 (артефакт отображения), записана, чтобы не наследовалась.

### З2 — ЗАКРЫТ

Заголовок клетки: «S-onlyflus» удалён, привязки — `S-nofilter` (вход 1, ассерт 1) и
`S-grammarscope` (вход 2, ассерт 2), обе совпадают с измеренным (ДО-барьер → ассерт 1, М3 →
ассерт 2). Незаявленных в контракте стабов в заголовке нет.

### З3 — наблюдение, не дефект (круг 1, без изменений)

Контракт предсказал для М4 `red_otvechennaja_dvojnaja_rol rc=0`; измерено rc=1 — клетка несёт
положительный контроль (вход 2, открытая двойная роль), которого прототип не имел. Строже
объявленного; различимость S-4afilter/М4 сохранена.

## Паразитная сложность (050) — дифф круга 2

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| вход 2 в `red_otvechennaja_peredatochnaja.sh` (+1 запись, +`rm -f`) | frozen 051/1 S-grammarscope, вход 2 этой клетки — объявлен дословно | временный `$R1` каркаса `_forks.sh`; `rm -f` явный, в теле клетки | 1 (только клетка), не выросло | интерфейс клетки не менялся (нет флагов/env; rc 0/1) | строка стабов + Красный протокол М3; хелперы `zapis`/`zhdu_*` каркаса переиспользованы, второй грамматики нет | ESSENTIAL |

## Мера круга 1 (дерево `7c40c63`, не пересуживалась)

### (а) Область правки — принято

`git diff --stat e935aef 7c40c63`: 9 файлов. `63b0258` (author implementer) — ровно 8 путей
`ЗОНА implementer` frozen/051/1 (`scripts/check_fork_route.sh` + 7 клеток); `7c40c63`
(adversary) — `verdicts/adversary/`. `check_zones.sh` rc=0 (1432). Правка барьера — две вставки
(+11/−0): `otvecheno=…; [ "$otvecheno" = "да" ] && continue` в 4а и 4в. Секция 0, `--schet`,
`--flush`, 4б — без изменений. Предикат — тот же литерал, что в `--flush`.

### (б) Р1–Р15 живьём — все rc=0

```
Р1 rc=0 :: bash fixtures/check_fork_route/red_otvechennaja_peredatochnaja.sh
Р2 rc=0 :: bash fixtures/check_fork_route/red_otkrytaja_peredatochnaja.sh
Р3 rc=0 :: bash fixtures/check_fork_route/red_schet_schitaet_zakrytye.sh
Р4 rc=0 :: bash scripts/verify_antiplacebo.sh --scope check_fork_route
    | барьеров: 1 · фикстур: 5 · предъявлено красным повторным прогоном: 5
Р5 rc=0 :: bash scripts/check_fork_route.sh --root .
Р6 rc=0 :: bash scripts/check_fork_route.sh --root . --schet
    | просмотрено 9
    | передаточных 2
Р7 rc=0 :: git diff --exit-code --diff-filter=MD --no-renames 7680606 HEAD -- fixtures/check_fork_route
Р8 rc=0 :: bash -n scripts/check_fork_route.sh
Р9a rc=0 :: bash scripts/check_provodka.sh . contracts/051-zhivoj-rezhim-fork-route-otvetchennye.md
Р9b rc=0 :: bash scripts/check_consumers.sh . contracts/051-zhivoj-rezhim-fork-route-otvetchennye.md
Р10 rc=0 :: git diff --exit-code 7680606 HEAD -- forks/
Р11 rc=0 :: bash fixtures/check_fork_route/red_otvechennaja_dvojnaja_rol.sh
Р12 rc=0 :: bash fixtures/check_fork_route/red_zapret_dvojnoj_roli.sh
Р13 rc=0 :: …--scope check_fork_route/case_otkrytaja_peredatochnaja_rc1   (1/1, «передаточное касание»)
Р14 rc=0 :: …--scope check_fork_route/case_ta_zhe_otvetchennaja_rc0       (1/1, «передаточное касание»)
Р15 rc=0 :: …--scope check_fork_route/case_zakrytaja_bitaja_grammatika_rc1 (1/1, «грамматика записи»)
FROZEN rc=0 :: git diff --exit-code frozen/contracts/051/1 HEAD -- contracts/051-zhivoj-rezhim-fork-route-otvetchennye.md
MINT  rc=0 :: git log --format=%h -- forks/mint-030-kanal.md  → 850400f (единственный коммит — владельца)
```

### (в) Формулы владельца — соблюдены в барьере

| Формула | Мера | Итог |
|---|---|---|
| грамматика судит ВСЕ (Р15 + вход 2 Р1 после круга 2) | секция 0 не тронута; М3 краснит Р15 и (круг 2) Р1 | да |
| маршруты только открытые (Р1/Р11/Р14) | фильтр в 4а и 4в; ДО-барьер краснит все три; S-4afilter краснит Р11 | да |
| `--schet` все (Р3/Р6) | `--schet` не тронут; живой 9/2; М2 → Р3 rc=1 | да |
| история и mint-030-kanal не тронуты | Р10 rc=0; `forks/mint-030-kanal.md` = `850400f` | да |

### (г) Приёмка владельца в теле `eb379c9` — принято

Живой обычный режим — пустой вывод, rc=0; `--schet` — `просмотрено 9` / `передаточных 2`, rc=0;
совпадает с телом ленда. Замечание (не блокирует): тело — выжимка без команд; rc у `--schet`
не назван.

### (д) Сэмпл мутантов (круг 1; строка М3 перемерена кругом 2)

| Мутант | red_otv_per | red_otkr | red_schet | red_otv_dual | red_zapret | Р13 | Р14 | Р15 | живой |
|---|---|---|---|---|---|---|---|---|---|
| честный `66a6ce52` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ДО / S-nofilter (`e935aef`) | **1** | 0 | 0 | **1** | 0 | 0 | **1** | 0 | **1** |
| М1 overfilter | 1 | **1** | 0 | 0 | 0 | **1** | **1** | 0 | 0 |
| М2 schetfilter | 0 | 0 | **1** | 0 | 0 | 0 | 0 | 0 | `--schet` 9/**0** |
| М3 grammarscope | ~~0~~ → **1** (круг 2) | 0 | — | — | — | — | — | **1** | 0 |
| S-4afilter | 0 | 0 | 0 | **1** | 0 | 0 | 0 | 0 | 0 |
| М4 no4a | 0 | 0 | 0 | 1 (З3) | **1** | 0 | 0 | 0 | 0 |

Все объявленные стабы различимы в семье; расхождений с заморозкой после круга 2 нет.

### ПРОВОДКА (038) — принято

`guard=scripts/check_fork_route.sh` — ровно барьер предмета; Р9 rc=0/rc=0. ПРОВОДКА-ЭНФОРСМЕНТ
обоснована честно (норма — свойство артефакта; поведенческой нормы 029-класса нет).

### Паразитная сложность (050) — дифф круга 1

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| ветви-фильтры 4а/4в | инв. 1 (S-4afilter: одного мало) | локальная `otvecheno`; явно | предикат «да» в 4 местах (было 2) | интерфейс не вырос | Р1/Р5/Р11/Р14; литерал `--flush` намеренно | ESSENTIAL; совет: общий `record_closed` (не блокирует) |
| 4 клетки `red_*` | Р1–Р3, Р11 | `$WORK` каркаса; явно | 1 на свойство | нет интерфейса | прямые пробы приёмки | ESSENTIAL |
| семья 3 `case_*` | Р4, Р13–Р15 | `mktemp`; явно | 1 на клетку | нет интерфейса | CI-шард ap4 `--scope check_fork_route` | ESSENTIAL |

## Итог

accept. Б1 закрыт: клетка `red_otvechennaja_peredatochnaja` (blob `1747f31`) несёт замороженный
вход S-grammarscope; М3 → клетка rc=1 (ассерт входа 2), честный барьер → rc=0, scoped 5/5,
живой rc=0 в клоне и основном чекауте. Дифф круга 2 — одна клетка зоны implementer. З2 закрыт,
З1 снят как ошибка меры круга 1, З3 — наблюдение. Блокирующих находок нет.

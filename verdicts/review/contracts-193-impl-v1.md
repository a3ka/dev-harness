FAIL
OBJECT=ed1955ba1b3fe1b755ecffcaee4dcef42ecd1d37
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался — frozen 193/1)
СУД: repo=dev-harness; предмет=193; фаза=реализация (контракт ЗАМОРОЖЕН `frozen/contracts/193/1`; `git diff 'frozen/contracts/193/1^{commit}' origin/main -- contracts/193-svyazka-sdatochnyj-list.md` пуст, rc 0); роль=reviewer; вызов=1 (полный); последний судья; сессия=Rev193; модель-план=config/agent_models.json reviewer → @opus; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --all | grep -F <OBJECT>` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev193	ed1955ba1b3fe1b755ecffcaee4dcef42ecd1d37`); СУД-запись оркестратора — HANDOFF state-ветки строка 4 (`предмет=193 … роль=reviewer … OBJECT=ed1955ba1b…`, сессия «ожидается»); предыдущие=нет; исключение=нет.
Находки: `.review/2026-11-18-108.md` (4 блока, 6 советов).

# Вердикт reviewer — 193 «Л2: сдаточный лист и карта классов вердикта», реализация, вызов 1

## Итог

**FAIL: четыре блока.** Каждый блок — доказанное нарушение инварианта на достижимом входе. Батарея эти нарушения пропускает: все ряды 43/43 и 24/24 зелёные. Для каждого блока есть простая форма. Она проверена на копии дерева: голый прогон 43/43.

- **Б-1.** Нога карты в `freeze_contract.sh` молча не работает на контракте больше 64 КиБ: `printf | grep -q` под `pipefail` даёт SIGPIPE 141 (И8). Сам контракт 193 весит 67 407 Б, нога взвелась в 0 из 20 прогонов.
- **Б-2.** Та же причина в `check_verdict_karta.sh:51`. На честном вердикте больше 64 КиБ с картой в начале дверь даёт ложный отказ «без раздела» (И7, ложный отказ ноги).
- **Б-3.** `check_sdacha.sh` исполняет ряд через `bash -c`. Поэтому `bash scripts/progiban_rc1.sh || true · 0 · 0` проходит зелёным, хотя скрипт честно даёт rc 1 (И3, «ложные rc»).
- **Б-4.** `timeout` без `-k`. Команда, которая игнорирует SIGTERM, держит дверь дольше бюджета: при `TIMEOUT=2 BUDZHET=4` дверь не завершилась за 25 с (И3, «от неограниченного прогона»).

Подтверждено своими прогонами:

- область правки (5 + 3 файла в зонах);
- вставки ног только в объявленных местах;
- перенос с модели: lib байт в байт, двери отличаются строкой шапки;
- батарея: голый, `--repo .`, `--model` — 43/43; `--stabs` 24/24; `--repo model` 36/43 (К-11);
- чистый main без реализации: 4/43, `--model` 43/43, `--stabs` 24/24;
- п.5 приёмки: rc 0, 6 мин 20 с;
- гейты п.6 зелёные (9 из 9, включая `check_charter` и `gen_ci_steps --check`);
- регресс п.7 совпадает с чистым main покомандно: красные `_krasnye_038`, `_krasnye_078` и `external_connection_184` красны и там.

## Объект и судимое дерево

```
клон: /tmp/dev-harness-verify/Rev193/repo (git clone ssh://git@github.com/a3ka/dev-harness.git; свой .git)
git fetch origin main wip/193/implementer wip/193/architect
origin/main                     = 2fe2c51dd9 (land: wip/int-2011/architect)
origin/wip/193/architect (OBJECT)= ed1955ba1b3fe1b755ecffcaee4dcef42ecd1d37  parent 0ddebafb57, author=committer=architect
origin/wip/193/implementer      = 9a9203b909317ce054084253dee1a6eb9422a72e  parent 0ddebafb57, author=committer=implementer
git diff --stat 0ddebafb57 origin/main -- <5 скриптов> fixtures/workshop_project/sdacha_193/  → пусто (main их не трогал)
судимое дерево: ветка rev193-judged = origin/main + git checkout 9a9203b909 -- <5> + git checkout ed1955ba1b -- <3>
  локальный коммит 9ad55217c8 (не публикуется); hash-object каждого из 8 файлов == блоб источника:
  check_sdacha 360e0a60, check_verdict_karta d55bceef, lib 8a29aaee, pre_critic 37f7f5bf, freeze b3e10212,
  SDACHA.md d093bef6, probe.py 69f43513, stabs.tsv f68acc37
```

## 1. Область правки и ПЕРЕСЕЧЕНИЯ

- `git show --stat 9a9203b909`: ровно 5 файлов, +453/−0. Это `scripts/{check_sdacha.sh, check_verdict_karta.sh, lib_karta_sdachi.sh, pre_critic.sh, freeze_contract.sh}` — ровно строка `ЗОНА implementer`. Автор и коммиттер — implementer.
- `git show --stat ed1955ba1b`: 3 файла `fixtures/workshop_project/sdacha_193/{SDACHA.md, probe.py, stabs.tsv}`, +136/−24. Все ⊆ `ЗОНА architect`. Автор и коммиттер — architect. `check_zones.sh` не запускался: зоны сверены построчно по ЗОНА замороженного текста.
- `git diff 0ddebafb57 9a9203b909 -- scripts/pre_critic.sh`: один ханк `@@ -333,5 +333,18 @@`, только `+`. Нога (к) стоит после ноги (и) (`check_provodka --grammar`) и перед `printf 'КРИТИК: дверь зелёная'`.
  - Ноги (а)–(и), CLI `--repo`, маркер и `exit 0` не тронуты.
  - Нога использует канонический `noga_formy` 191: вооружение `-x "$BASE/…"`, `refuse` на любом rc ≠ 0.
- `git diff … -- scripts/freeze_contract.sh`: один ханк `@@ -326,6 +326,24 @@`, только `+`. Вставка стоит после `esac` §6 (первая строка вердикта) и перед `# ── 6а. SPEC-PREFLIGHT`.
  - Порядок секций, фразы `die` и rc остальных секций не тронуты.
  - Заголовок вставки `# ── 6. КАРТА…` повторяет номер «6.». Это косметика.
- Перенос с модели — эталон по контракту:
  - `diff model/scripts/lib_karta_sdachi.sh scripts/lib_karta_sdachi.sh` пуст;
  - двери отличаются от модели одной строкой шапки (`— модель предмета` снято), `diff` 1−/1+.
- `bash -n` всех пяти скриптов: rc 0 ×5.

## 2. Обязательства (И1–И10) — сверка кода

| Инв. | Где | Итог |
|---|---|---|
| И1 | `check_sdacha.sh:59–70,108` | закрыто: одна строка, алфавит и сегмент `..` (s17 ловит, M02 поймана). Дубль СДАЧА → отказ, но без клетки (С-1, M01 жива). |
| И2 | `:115–242` | секции, ряды, статусы, способы и rc в норме. **Отклонения:** нет проверки наличия `## Дельта` при `ПРЕДЫДУЩИЙ ВЕРДИКТ` (С-2); `·` внутри поля принимается (С-3). |
| И3 | `:165–182,266–281` | **Б-3** (`bash -c` исполняет хвост ряда как оболочку), **Б-4** (`timeout` без `-k`). Минимум из таймаута и остатка бюджета — верно (s22/s23). |
| И4 | `:72–106` | закрыто: plans/, теги, блоб; запасной путь `contracts/<NNN>-*.md` без клетки (С-1, M08). |
| И5 | `:245–260` | закрыто: только HEAD-блоб, lib, «блок» → ряд Дельта (s20–s26 и мутации IZ-* в `--stabs`). |
| И6 | `pre_critic.sh:345–347` | закрыто: BASE, `SDACHA_OKRUG`, fail-closed через `noga_formy`. rc 2 без клетки (С-1, M14). |
| И7 | `check_verdict_karta.sh`, `lib_karta_sdachi.sh` | **Б-2** (ложный отказ на вердикте больше 64 КиБ). Префикс `verdicts/critic/` и «вне секции не судятся» верны, но без клеток (С-1: M09–M11). |
| И8 | `freeze_contract.sh:329–345` | **Б-1** (нога не взводится на контракте больше 64 КиБ). Развилка 3: `|| true` — мёртвый код, §4:262–265 уже требует HEAD == рабочий (С-4); fail-open создаёт не он, а пайплайн. |
| И9 | диффы выше; регресс п.7 | закрыто: вставки только в объявленных местах, 103/191 зелёные. |
| И10 | — | дверь смысла не судит, соответствует. |

## 3. Прогоны (сырой вывод, rc)

Батарея 193, судимое дерево (абсолютные пути клона; `env -u GIT_AUTHOR_* -u GIT_COMMITTER_*`):
```
red_sdacha_193.sh                                  → ИТОГ 193: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0   RC=0 (12,7 с)
red_sdacha_193.sh --repo .                         → ИТОГ 193: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0   RC=0
red_sdacha_193.sh --model                          → ИТОГ 193: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0   RC=0
red_sdacha_193.sh --stabs                          → ИТОГ 193: rc=0 OBMANOK=24 POIMANY=24 ZHIVYH=0  RC=0 (2 мин 19 с)
red_sdacha_193.sh --repo …/sdacha_193/model        → ИТОГ 193: rc=1 KLETKI=43 ZELENYE=36 KRASNYE=7   RC=1
   красны ровно s19 (pre_critic нет в model/), f01 f02 f03 p01 p02 p03 (rc 127) — К-11, ожидаемо
```
Чистый origin/main 2fe2c51dd9 без реализации (копия `mut/clean`), батарея main:
```
red_sdacha_193.sh  → ИТОГ 193: rc=1 KLETKI=43 ZELENYE=4 KRASNYE=39  (ok: f02 f03 p02 p03)
red_sdacha_193.sh --model → ИТОГ 193: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0
```
Чистый main с батареей OBJECT, без реализации (копия `mut/cleanbat`):
```
голый   → ИТОГ 193: rc=1 KLETKI=43 ZELENYE=4 KRASNYE=39
--model → ИТОГ 193: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0
--stabs → ИТОГ 193: rc=0 OBMANOK=24 POIMANY=24 ZHIVYH=0
```
Остаток Impl193 «`--stabs` 22/24» закрыт починкой Arch193Fix: 24/24 и на дереве с реализацией, и в окне.

п.5 приёмки:
```
bash scripts/check_sdacha.sh <клон> contracts/193-svyazka-sdatochnyj-list.md --run
СДАЧА: лист зелёный (двери=3 карта=17/17 дельта=6)
real 6m19.959s   RC=0
```
Census, своя мера (python glob, не `ls|wc`): `mir/*.md`=27, `mirskripty/*.sh`=7, `stabs/*.sh`=10, `model/scripts/*.sh`=3. Строк привязок в stabs.tsv (не `#`, не пустых) — 24, `K.append(Kletka(` в probe.py — 43. Всё совпадает с контрактом.

п.6 и п.7 (судимое дерево против чистого main; `mut/regress.sh`):
```
команда                                         судимое   чистый main   строка итога (судимое)
pre_critic.sh contracts/193-…md                 rc 0      rc 0          КРИТИК: дверь зелёная  (на судимом нога (к) гоняет лист 193 целиком)
check_threat_model.sh . <193>                   rc 0      rc 0
check_ceilings.sh .                             rc 0      rc 0          ok раздел требований: 182 черновик(ов) судится
check_provodka.sh . <193>                       rc 0      rc 0          (CI-строка 193 уже подключена)
check_provodka.sh --grammar . <193>             rc 0      rc 0
check_spec_ready.sh . <193>                     rc 0      rc 0          OK
check_precision_gate.sh . <193>                 rc 0      rc 0          OK
check_charter.sh .                              rc 0      rc 0
gen_ci_steps.sh --check                         rc 0      rc 0
fixtures/_krasnye_103.sh                        rc 0      rc 0          ИТОГ 103: rc=0
fixtures/_krasnye_072.sh                        rc 0      rc 0          итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0
fixtures/_krasnye_094.sh                        rc 0      rc 0          ИТОГ 094: rc=0
fixtures/_krasnye_095.sh                        rc 0      rc 0          ИТОГ 095: rc=0
fixtures/_krasnye_060.sh                        rc 0      rc 0          итог 060: rc=0
fixtures/_krasnye_084.sh                        rc 0      rc 0          клеток 59, красных 0, зелёных 59
fixtures/_krasnye_038.sh                        rc 1      rc 1          итог: 37 файлов, расхождений 37  (красна и на main — не регрессия)
fixtures/_krasnye_043.sh                        rc 0      rc 0          итог: 18 файлов, провалов 0 (Impl193 видел rc 1 под нагрузкой)
fixtures/_krasnye_078.sh                        rc 1      rc 1          ИТОГ 078 (лимит активных) …  (красна и на main)
191 --model / голый                             rc 0/0    rc 0/0        ИТОГ 191: rc=0 KLETKI=14 ZELENYE=14
192 --model                                     rc 0      rc 0          AGENTS_PARITY=ok (последняя строка)
189 --model                                     rc 0      rc 0          ИТОГ 189: rc=0 KLETKI=58 ZELENYE=58
190 --model                                     rc 0      rc 0          клеток 34, зелёных 34, красных 0
ci_proekta_122 --model                          rc 0      rc 0          клеток 49, зелёных 49, красных 0
ekrannyj_nabor_158 --model                      rc 0      rc 0          клеток 37, зелёных 37, красных 0
external_connection_184 (голый)                 rc 1      rc 1          (красна и на main)
rezhim_996/probe.sh                             rc 0      rc 0
время набора: судимое 1090,7 с; чистый main 702,8 с
```

## 4. Мутации и зонды (своя мера, вне 24 привязок)

Зонды в `/tmp/dev-harness-verify/Rev193/mut/`. Каждый строит мир тем же `probe.postroit_mir` из дерева-аргумента.

```
repro_big_freeze.py <судимое>    contract bytes = 1008    freeze rc = 1  ОТКАЗ: карта классов вердикта … красна (rc=1) …; tags=<нет>
repro_big_freeze.py <mut/big>    contract bytes = 117967  freeze rc = 1  ОТКАЗ: spec-preflight 036 красен (rc=127) …; tags=<нет>
                                  karta door rc = 1 на том же вердикте  ← нога пропущена (Б-1)
pipefail-проба на contracts/193 (67 407 Б): printf|grep -q → LEG-SKIPPED; PIPESTATUS 141 0; взведено 0/20
голый прогон на mut/big (раздут mir/kontrakt_chestnyj.md): ИТОГ 193: rc=1 KLETKI=43 ZELENYE=42 KRASNYE=1 (f01 KRASNO)
repro_big_verdict.py <судимое>   1737 Б → (0, КАРТА: 17/17 зелёный); 121354 Б → (1, ОТКАЗ: вердикт без раздела «## Карта классов») (Б-2)
repro_dver.py <судимое>
  P1  `bash scripts/progiban_rc1.sh || true · 0 · 0` → (0, СДАЧА: лист зелёный …)   (Б-3; progiban_rc1.sh: exit 1)
  P1b `…; exit 0` → (1, команда не существует)                                       (алфавит второго слова ловит `;`)
  P2  ПРЕДЫДУЩИЙ ВЕРДИКТ без «## Дельта» → (0, лист зелёный)                          (С-2)
  P3  trap "" TERM, TIMEOUT=2 BUDZHET=4 → НЕ ЗАВЕРШИЛАСЬ за 25,0 с                    (Б-4)
repro_tochka.py: поле «вход: контекст·контракта» → (0, лист зелёный)                 (С-3)
```
Простые формы проверены на копии `mut/fix`: here-string в обеих точках Б-1/Б-2, argv-исполнение (Б-3), `timeout -k 2` (Б-4).
```
голый: ИТОГ 193: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0
голый с раздутым toy-контрактом: 43/43, f01 ok; repro_big_freeze → «карта классов вердикта … красна»
repro_big_verdict: 121354 Б → (0, КАРТА: 17/17 зелёный)
P1 → (1, фактический rc=1 ≠ заявленного 0); P3 → (1, фактический rc=137 ≠ заявленного 0) за 4,1 с
--stabs: ORACLE_TAMPERED: мутация не применена: JAKOR_NE_UNIKALEN: PATERN:BEZ-NOGI  RC=2
```
Последняя строка значит: исправление Б-1 требует парной правки якоря `USLOVIE_REAL_FREEZE` в probe.py (зона architect, С-5).

Адресные мутации реализации (`mutate.py`, голый прогон на копии `mut/m`; файл восстанавливается после каждой):
```
M01-I1-dubl-sdacha          ЖИВА      43/43
M02-I1-dotdot               ПОЙМАНА   s17
M03-I3-oba-rc-dveri         ЖИВА      43/43
M04-I3-put-vne-kornja-bash  ЖИВА      43/43
M05-I2-rjad-vne-sekcii      ЖИВА      43/43
M06-I3-bjudzhet-break       ЖИВА      43/43   (исправленный вариант; первый вариант был ошибочен)
M07-I3-ot-kornja            ПОЙМАНА   9 клеток
M08-I4-fallback-teg         ЖИВА      43/43
M09-I7-prefiks-critic       ЖИВА      43/43
M10-I7-vne-sekcii-suditsja  ЖИВА      43/43
M11-I7-konec-sekcii         ЖИВА      43/43
M12-I8-rc2-propuskaet       ЖИВА      43/43
M13-I8-rc1-propuskaet       ПОЙМАНА   f01
M14-I6-noga-rc2-maskiruet   ЖИВА      43/43
M15-I5-sposob-ne-sveren     ПОЙМАНА   s09
```
Живые мутации — пробелы покрытия батареи, а не дефекты реализации: код на каждой из них честный. Они идут советом С-1 к architect: НЕ ЗАЩИЩАЕТ «универсальную полноту набора мутаций» ловит reviewer.

## 5. Неподгонка

- В трёх скриптах реализации нет ни ветвления по именам миров, ни `777`, ни `toy`. Единственное вхождение `fixtures/` — `check_sdacha.sh:209`: префикс алфавита команды в поле карты (`bash*|scripts/*|fixtures/*`), это не имя мира. Проверено чтением целиком: `check_sdacha.sh` 285 строк, `check_verdict_karta.sh` 56, `lib` 81, плюс диффы ног.
- Файлы проверок и фикстур implementer не трогал: его коммит — только `scripts/`.
- Починка батареи (Arch193Fix) лежит в зоне architect. Она не ослабляет клетки: ожидания `Kletka(...)` в диффе `0ddebafb57..ed1955ba1b` не менялись.
  - Изменено: опознание реальной ноги по функциональному якорю и применение 5 ног-мутаций к реальной ноге.
  - Красное предъявлено: Impl193 замерил 22/24 до починки, после неё 24/24.

## 6. Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые файлы | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `check_sdacha.sh` | И1–И6 | env-швы SDACHA_TIMEOUT_SEK/BUDZHET_SEK/OKRUG объявлены контрактом, видны в шапке | дверь + `model/` + якоря `MUTACII_DVERI` = 3 | 3 арг., rc 0/1/2, 3 env против 285 строк работы — глубокий | нога (к), нормы 192, п.5 | ESSENTIAL |
| `check_verdict_karta.sh` | И7 | нет | дверь + model + якоря KARTA-* | 2 арг. — глубокий | нога freeze | ESSENTIAL |
| `lib_karta_sdachi.sh` | И7 единый источник | нет | 1 (+model) | 1 функция | 2 двери | ESSENTIAL |
| нога (к) | И6 | маркер SDACHA_OKRUG явный | 1 (+якоря probe) | 3 строки через `noga_formy` | п.6 pre_critic | ESSENTIAL |
| нога карты freeze | И8 | `_k193_head`, `_k193_rc`, `_k193_out` — локальные | 1 (+якорь probe) | 8 строк | f01/f03 | ESSENTIAL; `|| true` — ACCIDENTAL, совет С-4 |
| probe.py якоря реальных ног (Arch193Fix) | К-11/`--stabs` на реальных ногах | нет | правка формы ноги → 3 файла (рост: был 2) | — | `--stabs` | ESSENTIAL по Arb193V1 р.2; цена названа в С-5 |

## 7. Строки сверок

СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`, обоих файлов в дереве нет: `ls` даёт «No such file», grep по AGENTS.md пуст.

СВЕРКА-АРХИТЕКТУРЫ: н/п. Нет `tooling/checks/cli.js`, `bindings.json` и брифа 188: `ls tooling/checks/cli.js` даёт «No such file», К-17 листа и вердикта критика — «н/п». Поэтому `finding new` недоступен. Находки — в `.review/2026-11-18-108.md`. Расширения долга модели нет: модели нет.

Проводка (038): `guard=fixtures/workshop_project/sdacha_193/red_sdacha_193.sh` — барьер именно этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: норм ролей предмет не вводит, они заморожены 192/1. CI-строка — работа оркестратора; `check_provodka` без `--grammar` — в таблице п.6.

Режим проекта (996): sourceCanon не объявлен, неприменимо. Исключение — граница С-6.

## 8. Остаток контракта (НЕ ЗАЩИЩАЕТ с ловцом reviewer)

- ОСТАТОК: К-10/К-16 (смысловая достаточность доказательств, честность «чисто» в листе 193) — не укусил. Лист 193 перепрогнан дверью целиком, rc 0. Ряды «Дельта» указывают на клетки, которые существуют и зелёны (s20–s26, v07–v11, p03/f03, s22/s23).
- ОСТАТОК: К-04 (полнота охвата дверей формы и место листа в зоне автора) — не укусил. `SDACHA.md` лежит в `fixtures/workshop_project/sdacha_193/` — ЗОНА architect.
- ОСТАТОК: К-08 (универсальная полнота мутаций, сговор субъекта с батареей) — **укусил.**
  - Своя мера `mutate.py`: 11 из 15 мутаций живы (С-1).
  - Четыре дефекта реализации на входах, которых нет в батарее: Б-1…Б-4 (`freeze_contract.sh:339`, `check_verdict_karta.sh:51`, `check_sdacha.sh:273` ×2).
  - Сговора нет: implementer батарею не правил.
- ОСТАТОК: исторические FAIL-вердикты без карты — не укусил. Предыдущий вердикт листа 193, `contracts-193-v1-krug1-fail.md`, проходит `karta_proverit` на HEAD (п.5 rc 0).
- ОСТАТОК: проектные `--repo`-деревья (996) — **укусил как граница, не блок.** Помимо названного сопоставления блоба есть ещё путь вердикта `verdicts/critic/…` против профильного `_PROFILE_VERDICTS_DIR` (С-6).

## 9. Что не проверено

- `scripts/check_zones.sh` целиком не запускался. Зоны сверены построчно по замороженной строке ЗОНА.
- Живая заморозка реального контракта больше 64 КиБ до тега не воспроизводилась: в toy-мире нет `check_spec_ready.sh`. Пропуск ноги доказан выходом за §6 к §6а и пробой пайплайна на самом контракте 193 (0/20).

## Развилки

1. Б-3 и Б-4 буквально перенесены с модели, которую критик принял (Crit193V4). Тем не менее это блоки: они нарушают замороженные И3 и ЗАЩИЩАЕТ, а модель — эталон переноса, а не норма. Атаки на `bash -c` и SIGTERM в кругах критика не предъявлялись (grep по `verdicts/critic/contracts-193-*` и арбитражу пуст).
2. Исправление Б-1 ломает якорь `--stabs` (rc 2). Значит, правка нужна парой: implementer — дверь и нога, architect — якорь и клетки. Новые клетки в рамках счёта 43/24/27 замороженной приёмки возможны раздутием существующих фикстур (f01 и v01/v08). Иначе нужна v2 контракта. Выбор оставляю architect и оркестратору.
3. С-2 (`## Дельта` при `ПРЕДЫДУЩИЙ ВЕРДИКТ`) и С-3 (`·` в поле) — буквальные отклонения от И2, которые не снимают ни одной защиты ЗАЩИЩАЕТ. По триажу задания они идут советами, не блоками.

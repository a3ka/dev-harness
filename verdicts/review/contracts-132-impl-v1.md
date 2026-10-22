accept
OBJECT=cc98c4e0d4703e616b970ec5e286c92dc804f286
Суд реализации 132 «ekran-shablon», один круг. Ревьюер: Rev132 (anthropic/claude-opus-5-5).
Контракт: `frozen/contracts/132/1` → 80872afca (`git rev-parse` даёт тот же SHA, что у `HEAD^`).
Субъект: `scripts/ekran_shablon.py`, blob `4b6dc28873edd6ad28c48ff195fafe8e0cbee649`, sha256 `0444e81f…a89c`.
Блокирующих находок 0, советов 3. Находки в формате reslop (status: ready) — `.review/2026-10-22-01.md`
в клоне `/tmp/dev-harness-verify/Rev132`. По заданию в этот коммит идёт только файл вердикта, поэтому
текст находок продублирован ниже, в §Находки.
Клон со своим .git: `/tmp/dev-harness-verify/Rev132` (clone из J132). Мутанты гонялись в копии
`/tmp/dev-harness-verify/Rev132mut`, логи лежат в `/tmp/dev-harness-verify/Rev132out/`. Push не делался.

## 1. Область правки

- `git diff --name-status 80872afca HEAD` → `A scripts/ekran_shablon.py`, один файл, 662 строки добавлено.
  Он совпадает с ЗОНА implementer контракта (`scripts/ekran_shablon.py`).
- `git diff --quiet frozen/contracts/132/1 HEAD -- contracts/ fixtures/ verdicts/ roles/ docs/ registry/` → rc 0.
  Контракт, батарея, фикстуры, стабы, source.json и эталон после заморозки не менялись.
- Автор коммита: `implementer <implementer@dev-harness.local>`, коммиттер — `orchestrator` (положил в поезд).
  `check_zones` различает исполнителей по `%an`.
- Атомарность: один коммит, одна задача, тема ссылается на предмет («субъект 132: экранная пачка по шаблону …»).
- Норма не тронута: roles/, docs/, contracts/ в diff нет.
- `bash scripts/check_zones.sh` (дерево клона) → см. §6.

## 2. Сырые прогоны (мои, на клоне HEAD cc98c4e0d)

| Команда | rc | Вывод (своя мера по логам) |
|---|---|---|
| `bash …/red_ekran_shablon_132.sh` (без флага, субъект) | 0 | 35 строк, `grep -c ' ok$'` = 35, не-ok 0, stderr пуст |
| `bash …/red_ekran_shablon_132.sh --model` | 0 | 35/35 ok |
| `bash …/red_ekran_shablon_132.sh --stabs` | 0 | 68 строк: 35 ok + 32 `^STAB .* KRASEN$` + `SVJAZI 32`; PROSHYOL/STAB_ZHIV 0; уникальных стабов 20 |
| `python3 …/probe.py` (без обёртки) | 0 | 35/35 ok |

Вторая мера — другой командой, по source.json: `kejsy` = 35, `stab_vhod` = 20 стабов,
сумма входов = 32 связи. Файлов `stubs/s*.py` 20. Множество имён `CASE` безфлагового прогона
совпадает с ключами `kejsy` (True). Меры оркестратора (35 / 35 / 32 / 35, rc 0) подтверждены.

## 3. Красное предъявлено (против сломанной реализации; копия дерева Rev132mut)

| Порча субъекта | rc обёртки без флага | Красные входы |
|---|---|---|
| `scripts/ekran_shablon.py` удалён | 1 | `SHABLON_ABSENT` + 35 `CASE … KRASNO (SHABLON_ABSENT)` |
| на месте субъекта стаб s19 (построчный скан литералов) | 1 | `literal-cveta-mnogostrochnyj`, `literal-razmera-nuli`, `literal-cveta-funkc-nuli` |
| мутант: `otkaz('KADR_USTAREVSHIJ'…)` заглушён (1 место) | 1 | `kadry-ustarevshie` (prichiny=[] против ожидаемых KADR_USTAREVSHIJ) |
| мутант: `_zhivye_v_korne` не сканирует корень `--repo` | 1 | `zhivaja-pachta-v-repo` (rc 0 против 1, ZAMENJAET_NE_POLON нет) |
| исходный субъект возвращён | 0 | 35 ok |

Безфлаговый режим судит именно субъект. `probe.py:54` задаёт `SUBJECT = H_ROOT/'scripts'/'ekran_shablon.py'`,
`:605` выбирает MODEL только при `--model`/`--stabs`, `judge` сравнивает rc, отсортированный набор
строк `PRICHINA\t…` из stderr и stdout с оракулом построчно.

## 4. Проверка не подогнана под реализацию

- Implementer не трогал ни одного файла батареи (см. §1).
- В субъекте нет имён входов `kejsy`: перебор всех 35 имён по тексту `scripts/ekran_shablon.py`
  совпадений не дал. Нет и `r1423`, `Splash`, `Fiktura`, `kejsy`, `stab`, `os.environ`.
  Слова `fiktura` (9) — имя поля формы, `fixtures/workshop_project` — корень обнаружения живых
  пачек по контракту (§Нарезка Ж). Упоминание `probe.py`/`ekran_shablon_132` есть только в шапке-комментарии.
- Чистый stdlib (hashlib, json, re, subprocess, sys, time, pathlib). `shell=True`, `os.system`,
  сеть, env не используются. Приёмка исполняется через `subprocess.run(razbit_argv(...))` — argv без shell (инвариант 4).
- Порядок `main()` соответствует инварианту 5: alfavit → (rc2-гейт) → kadry/fajly → (rc2-гейт) →
  razdely/objem/zony/literal/kljuchi/operacii/scenarij/priemka-форма/tselikom/chuzhie/polnota →
  исполнение e2e только при нуле отказов → сверка → исполнение priemka.sverka.

## 5. Совпадение с эталоном и «реализован, а не оттестирован»

`diff -u model/ekran_shablon.py scripts/ekran_shablon.py` даёт 19 добавленных строк и 6 удалённых. Расхождения:
(а) шапка-комментарий и абзац докстринга «это реализация, не эталон»;
(б) опечатка «ОБЕИХ→ОБОИХ» в докстринге `check_polnota`;
(в) повтор `any(o.split('\t')[1] in RC2 for o in otkazy)` ×3 вынесен в `_est_rc2`.
Поведенческих различий в diff нет.

Вне батареи — свои входы, собственный каталог `revoff-*`, `--harness` = корень клона:

| Вход | rc | stderr субъекта |
|---|---|---|
| честная пачка | 0 | stdout `KADR Splash dark 0.783 …`/`KADR Splash light 0.782 …`/`SHABLON demo-vkhod OK` |
| `kontrakt.md` + многострочный `hsl(\n 120,\n 50%, 50%)` | 1 | `PRICHINA LITERAL_VNE_AUDITA kontrakt.md:47` (строка начала) |
| `batareja` + `12vmin` | 1 | `PRICHINA LITERAL_VNE_AUDITA batareja/red_ekrana.sh:7` |
| `batareja` + `oklch(0.7 0.1 200)` | 1 | `PRICHINA LITERAL_VNE_AUDITA batareja/red_ekrana.sh:7` |
| `batareja` + обособленное hex-слово 24 с буквами | 0 | — (маска дайджеста по контракту) |
| лишний ключ формы | 2 | `PRICHINA SHABLON_NEVEREN состав ключей != шаблон: ['lishnij']` |
| `fiktura: true` у судимой | 2 | `PRICHINA SHABLON_NEVEREN fiktura: судимая пачка — не фикция` |
| `zony: ['../x']` | 2 | `PRICHINA SHABLON_NEVEREN zony` |
| `ekran` с TAB | 2 | `PRICHINA SHABLON_NEVEREN ekran` |
| `priemka` = `true`/`true` | 1 | `PRICHINA SAMODELNAYA_SVERKA команда сверки не запускает механизм 123` |
| CLI без `--repo/--harness` | 2 | `CLI: ekran_shablon.py --pack DIR --repo DIR --harness DIR` |

Тот же набор, прогнанный на эталоне, даёт побайтно тот же rc+stderr: md5 свёртки `94d63fd2…` у обоих.
Батарейные выводы отказов (stderr) я смотрел сам по 7 входам: `literal-cveta-mnogostrochnyj` →
`LITERAL_VNE_AUDITA batareja/red_ekrana.sh:7`; `kollizija-zamenjaet` → `NE_TSELIKOM Old screen only`;
`kadry-ustarevshie` → 2× `KADR_USTAREVSHIJ <путь кадра>`; `sverka-lozhnaya` → stdout раннера +
`SAMODELNAYA_SVERKA`; `kontrakt-shirokij` → `NE_ODNA_STRANICA ширина: 6900` + `байт: 16038`;
`zhivaja-pachta-v-repo` → `ZAMENJAET_NE_POLON fixtures/workshop_project/old_screen_001/kadry.json`.
Формат `PRICHINA<TAB>имя<TAB>подробности` соблюдён (приёмка п.5).

Числа честных кадров 0,783/0,782 воспроизводят замер 123 (инвариант 7).

## 6. Гейт зон

`bash scripts/check_zones.sh` (клон, HEAD cc98c4e0d) → rc 1. Итог: «замороженных контрактов: 131 · объявленных
авторов: 5 · коммитов в диапазонах: 28042 · проверено по зонам: 4731». FAIL-строк ровно две, обе
к предмету не относятся:
- `строка ЗОНА вне объявленной грамматики в contracts/055-…` — текст контракта 055, в diff его нет;
- `коммит вне зоны: orchestrator eb5df006 registry/contracts.tsv — дверь минта 031 …` — коммит
  оркестратора ниже поезда.
FAIL-строки по `implementer`/`cc98c4e0` нет: коммит предмета лежит в диапазоне
`frozen/contracts/132/1..HEAD`, и его единственный путь входит в ЗОНА implementer заморозки.
Обе красные строки существовали до предмета и в эту находку не включаются: diff их не создаёт
(вне зоны предмета).

## 7. ПРОВОДКА (038)

Канал `guard=fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh` существует.
Это барьер именно этого предмета: в безфлаговом режиме он судит `scripts/ekran_shablon.py`
и без субъекта красен (rc 1, см. §3). В CI канал пока не подключён: в `registry/ci-steps.tsv`,
`package.json` и `ci.yml` совпадений нет. Контракт отдаёт подключение оркестратору интеграционным
коммитом после ленда, так что это не дефект реализации → совет R132-A2.

## 8. Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `scripts/ekran_shablon.py` (новый скрипт) | весь предмет: §Предмет, инв. 1–8, приёмка п.5 | своего состояния нет; исполняет `priemka` в cwd=репо (запись кадров — работа команды пачки, по контракту) | 2: субъект + эталон (было 1, эталон); рост задан заморозкой §Нарезка В/Г | интерфейс: 3 обязательных флага, rc 0/1/2, env не читает; за ним 17-польная форма, литералы, полнота двух корней, исполнение и сверка — глубокий | приёмка п.1/5/6, guard ПРОВОДКА; грамматику эталона повторяет дословно → совет R132-A1 | ESSENTIAL |
| функция `_est_rc2` | инвариант 5 (гейт дорогих) + rc-группа отказов | нет | 1 | один аргумент, одно выражение; заменила 3 копии | `main()` ×3; дерево не дублирует | ESSENTIAL (рефакторинг дубля) |

## Находки

- R132-A1 — СОВЕТ (architect/оркестратор). Субъект почти дословно повторяет эталон, грамматика живёт
  в двух копиях: следующая правка свойства меняет два файла. Это задано заморозкой (§Нарезка В/Г,
  прецедент 123), и строки приёмки, где критерий зелен, а предмет не сделан, нет. Для v+1 предлагаю
  меру равенства поведения субъекта и эталона в одном шаге CI.
- R132-A2 — СОВЕТ (оркестратор, ПРОВОДКА). guard в CI не подключён. Подключать надо БЕЗФЛАГОВЫМ
  режимом: `--stabs` судит только эталон (`probe.py:605`), при порче или отсутствии субъекта он зелен.
- R132-A3 — КОСМЕТИКА (implementer). В докстринге `_est_rc2` удвоено слово («отказ отказ»), и функция
  описана как только гейт дорогих проверок, хотя решает и финальный rc.

Ни одна находка не блокирует: на всех проверенных состояниях входа и дерева предмет сделан,
зона, нормы и заморозка не нарушены.

Семейство моделей: ревьюер — Anthropic. Implementer по временному канону 73f15ddf7
(task → @glm) [INFERENCE: из `.omp/config.yml`, сам прогон implementer я не видел] — другое семейство.

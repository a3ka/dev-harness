FAIL
OBJECT=f2a6d20920a91f2666959cb76be79e6aab373403
СУД: repo=dev-harness; предмет=148; фаза=контракт v2 (после арбитража, scoped: перечень П1–П6 + зависимый регресс); роль=critic; вызов=3 по v2 (сверх капа, слово владельца 01.11 ~11:20; перезапуск на независимом критике — прежний запуск Crit148v3 на Terra отозван владельцем как зависимый, его вердикт не читан и не использован); модель-план=anthropic/claude-opus-5-5; сессия=Crit148v3b; модель-факт=anthropic/claude-opus-5-5; SHA=f2a6d20920a91f2666959cb76be79e6aab373403; предыдущие=verdicts/critic/contracts-148-v2-fail.md (df5fdfc3d), verdicts/critic/contracts-148-v2c-fail.md (8063fe2a5), verdicts/arbitration/contracts-148-arbitraz.md; исключение=да

Сверка счёта: в HANDOFF.md основного чекаута (чтение, без записи) строки `СУД: … предмет=148` для этого вызова нет (grep «СУД: .*предмет=148» — 0 совпадений). Строка выше взята из задания и поправок Main (модель-план anthropic/claude-opus-5-5); дописать её в HANDOFF должен оркестратор (`roles/critic.md §Счёт`).

Независимость: автор конструкции — architect, `%an = architect` на f2a6d2092, модель-факт по отчёту автора `/tmp/dev-harness-verify/Arch148d/report.md` — openai-codex/gpt-6-sol (семейство gpt); судья — anthropic/claude-opus-5-5 (семейство anthropic). Семейного совпадения с автором нет. Арбитр предмета — anthropic/claude-fable-5-1: модель другая, роль арбитра я не совмещаю.

## Источники и порядок

- `git cat-file -t f2a6d20920a91f2666959cb76be79e6aab373403` → `commit`. Одноразовый клон `/tmp/dev-harness-verify/Crit148v3b/repo` (`git clone /home/harness/dev-harness`, `fetch … wip/148/architect`, `FETCH_HEAD` = f2a6d2092, `checkout -q`). Цепочка: 33f3e80d7 (main, предок — `merge-base --is-ancestor` rc 0) → a9306880a → 52e5c6cf9 → f2a6d2092. Основной чекаут не трогался, GIT_DIR/GIT_WORK_TREE не использовались, push нет, эмуляторы и нативные сборки не запускались (jest продукта — только внутри `produkt_sud` на копии).
- Предмет суда: `git diff 52e5c6cf9..f2a6d2092`, 10 файлов (contracts/148-vkladki-tabov.md; produkt_sud.py; probe.py; source.json; osi.md; red_vkladki_tabov_148.sh; stubs s85/s86/s87; эталонный e2e.sh). Нормы: `roles/critic.md` (§Быстрый-процесс, §ПОРОГ, §Атака до кода, §Счётные и механические расхождения), арбитраж `verdicts/arbitration/contracts-148-arbitraz.md` (П1–П6, НЕ ЗАЩИЩАЕТ), задание `/tmp/dev-harness-verify/orch/task-critic148v3.md`.
- Неполного набора нет: предмет, критерий с командами (`W`, приёмки 1–12), исполнители и ЗОНА-строки на HEAD.

## Перемер (сырые команды, rc) — всё в клоне судьи на OBJECT

| команда | rc | итог (дословно) |
|---|---|---|
| `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model` | 0 | `клеток 52, зелёных 52, красных 0` (80 с) |
| `… red_vkladki_tabov_148.sh --stabs` | 0 | `клеток 52, зелёных 52, красных 0`; `SVJAZI 42`; строк `STAB … KRASEN` — 42, не-KRASEN — 0 (327 с) |
| `… red_vkladki_tabov_148.sh` (без флага) | 1 | `клеток 52, зелёных 35, красных 17` (40 с); зелёные: 34 формы + `pr-pachka-net`; красные: `pr-chestnaja` + 16 мутаций, у всех 17 stdout `PACHKA_ABSENT` |
| `… --repo <копия референса>` (`probe.sobrat_referens`, attacks.py --full baseline) | 0 | `CASE pr-chestnaja ok`, `клеток 35, зелёных 35, красных 0` |
| `… --repo /tmp/dev-harness-verify/Crit148v3b/mob147` (rsync копии клона PR #147 `/tmp/dev-harness-verify/Arch148v2/mob-v2`, head 9955af5 + рабочие правки e2e.sh/kadry_profil.json, node_modules — симлинк) | 0 | `клеток 35, зелёных 35, красных 0` |
| `python3 …/produkt_sud.py --repo …/mob147` | 0 | KADR×8 1.000, `SHABLON vkladki OK`, `ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4`, мутанты tabs/badge/skroll `UBIT` (2/1/1) |
| `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` | 0 | `КРИТИК: дверь зелёная` |
| `bash scripts/check_ceilings.sh` | 0 | `потолки в порядке` |
| `bash scripts/check_precision_gate.sh <клон> contracts/148-vkladki-tabov.md` | 0 | `OK` |
| `bash scripts/check_threat_model.sh <клон> contracts/148-vkladki-tabov.md` | 0 | `ЗАЩИЩАЕТ 12 буллет(ов), НЕ ЗАЩИЩАЕТ 12 буллет(ов)` |
| `bash scripts/check_spec_ready.sh <клон> contracts/148-vkladki-tabov.md` | 0 | `OK` |
| `bash scripts/check_provodka.sh <клон> contracts/148-vkladki-tabov.md` | 1 | `guard не подключён: …red_vkladki_tabov_148.sh не вызывается в .githooks/ или .github/workflows/` — ожидаемо до окна freeze (проводку подключает оркестратор), НЕ блокер по заданию |
| `bash scripts/check_zones.sh <клон>` | 0 | `замороженных контрактов: 146 · объявленных авторов: 5 · коммитов в диапазонах: 40391 · проверено по зонам: 9561` (381 с; совпадает с заявлением автора) |

Стабы П4 доводят до своей лжи (`/tmp/dev-harness-verify/Crit148v3b/stab_lozh.py`, стаб напрямую `--repo <референс+его вход>`): s85 на pr-emuljatory-odnovremenno, s86 на pr-ostanovka-neispolnima / pr-echo-emu-kill / pr-if-false-kill / pr-emuljatory-odnovremenno, s87 на pr-port-393-sosednij — каждый **rc 0**, последняя строка `SHABLON	vkladki	OK`, Traceback нет. Обязательные свойства матрицы П4 выполнены (s86 зеленит обе новые клетки П3 и pr-emuljatory-odnovremenno; s87 — порт).

П5: тело эталонного e2e.sh не изменено — `grep -v '^ *#' | md5sum` до (52e5c6cf9) и после: `adbabec185c086c53b14edefc6fbcec7` оба; пин `piny.etalon_raskladka` совпадает с байтами (все 12 пинов раскладки и 23 пина носителей сверены sha256 — расхождений 0). П1: статический разбор удалён — `grep _razobrat_e2e|_posledovatelnost|_ostanovka|_porty|OSTANOVKA_NE_ISPOLNIMA` по батарее — 0 совпадений (в контракте — только исторический замер :254).

## Атаки (сырые выводы)

`python3 /tmp/dev-harness-verify/Crit148v3b/attacks.py 5` — прямой вызов `produkt_sud.proverka_emuljatorov` на копии эталонного e2e.sh с подстановкой единственной строки `adb -s "$SERIAL_390" emu kill` (5 повторов каждой):

```text
baseline               rc=0 x5 otkazy=[]
bg-sleep-kill          rc=0 x5 otkazy=[]
bg-sleep-kill-nowait   rc=0 x5 otkazy=[]
bg-maestro-kill        rc=0 x5 otkazy=[]
hybrid-abs-path        rc=0 x5 otkazy=[]
env-branch             rc=0 x5 otkazy=[]
log-forge              rc=0 x5 otkazy=[]
adb-shadow-fn          rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
adb-alias              rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
adb-var                rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
path-shadow            rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
for-empty              rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
while-false            rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
case-nomatch           rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
wrong-serial           rc=1 x5 otkazy=["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]
exit-before            rc=1 x5 otkazy=["EMULJATORY_NA_VHODE_PAROJ: нет START в журнале; цикл пары отсутствует или запуск обошёл PATH/ANDROID_HOME"]
false-or-kill          rc=0 x5 otkazy=[]
kill-and-wait          rc=0 x5 otkazy=[]
two-spaces             rc=0 x5 otkazy=[]
```

Подстановки: `bg-sleep-kill` — `( sleep 600; adb -s "$SERIAL_390" emu kill ) &`; `bg-sleep-kill-nowait` — то же, а цикл ожидания эталона заменён на `for _ in $(seq 1 20); do adb devices >/dev/null; done`; `bg-maestro-kill` — `( maestro --e2e-serial "$SERIAL_390" test mobile/.maestro/vkladki.yaml; adb -s "$SERIAL_390" emu kill ) &`; `hybrid-abs-path` — `/opt/android-sdk/emulator/emulator -avd x -port 5576 >/dev/null 2>&1 &` перед честной остановкой; `env-branch` — `if [ -n "${E2E148_LOG:-}" ]; then … emu kill; fi`; `log-forge` — `echo "KILL emulator-5570" >>"$E2E148_LOG"`; тени: `adb() { :; }` / `alias adb=true` / `ADB="echo adb"` / `PATH="$PWD/sh:$PATH"` с пустым sh/adb; пустые `for x in;` / `while false` / `case x in y)`; `adb -s emulator-5572 emu kill`; `exit 0`.

`python3 /tmp/dev-harness-verify/Crit148v3b/attacks2.py 20` — 20 повторов:
```text
abs-path-only      x20 varianty=1 ["EMULJATORY_NA_VHODE_PAROJ: нет START в журнале; цикл пары отсутствует или запуск обошёл PATH/ANDROID_HOME", "E2E_PESOCHNICA_RC: скрипт rc=1"]
bg-sleep-kill      x20 varianty=1 []
bg-maestro-kill    x20 varianty=1 []
```

`python3 /tmp/dev-harness-verify/Crit148v3b/attacks.py --full baseline bg-sleep-kill bg-maestro-kill` — ПОЛНАЯ батарея `W --repo <копия референса с подстановкой>`:
```text
FULL baseline rc=0 ['CASE pr-chestnaja ok', 'клеток 35, зелёных 35, красных 0'] stderr_tail= []
FULL bg-sleep-kill rc=0 ['CASE pr-chestnaja ok', 'клеток 35, зелёных 35, красных 0'] stderr_tail= []
FULL bg-maestro-kill rc=0 ['CASE pr-chestnaja ok', 'клеток 35, зелёных 35, красных 0'] stderr_tail= []
```

На копии РЕАЛЬНОГО продукта PR #147 (`/tmp/dev-harness-verify/Crit148v3b/mob147-bg`, та же подстановка `bg-sleep-kill` в его e2e.sh:34): `python3 …/produkt_sud.py --repo …/mob147-bg` — **rc 0**, хвост `SHABLON	vkladki	OK` + `ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4` + три `UBIT`.

Контроль «CI-время» (`python3 /tmp/dev-harness-verify/Crit148v3b/ci_vremja.py`: тот же судья, единственное отличие — двойник `sleep` спит реальные `N×0.01` с вместо мгновенного выхода):
```text
baseline       CI-время x0.01: []
bg-sleep-kill  CI-время x0.01: ['EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе']
false-or-kill  CI-время x0.01: []
kill-and-wait  CI-время x0.01: []
```

`python3 /tmp/dev-harness-verify/Crit148v3b/attacks3.py` — честные формы вне объявленного позитивного набора:
```text
list-avds-diag       ['EMULJATORY_ODNOVREMENNO: START  при живом эмуляторе', 'PORT_393_NE_5576: START , требуется 5576']
platform-tools-adb   ['EMULJATORY_NA_VHODE_PAROJ: нет START в журнале; цикл пары отсутствует или запуск обошёл PATH/ANDROID_HOME', 'E2E_PESOCHNICA_RC: скрипт rc=127']
```

`python3 /tmp/dev-harness-verify/Crit148v3b/attacks4.py` — формы :258 (`true ||`, `echo '…emu kill'`, here-doc):
```text
true-or-kill   ['EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе']
quoted-kill    ['EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе']
heredoc-kill   ['EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе']
```

Гонка неизменённой мутации (`povtor_odn.py`): pr-emuljatory-odnovremenno ×20 — `varianty=1 ['["EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе"]']` — заявление автора «20/20 одно сообщение» подтверждено.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:63 (И-11), :88 (приёмка 12), :223 (ЗАЩИЩАЕТ), :235 (НЕ ЗАЩИЩАЕТ «модель двойников судит порядок команд»); механизм — fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py:98-140 (двойники `sleep`/`maestro` выходят мгновенно) и :142-163 (`_sudit_zhurnal` судит порядок строк журнала песочницы) — двойники сжимают время, и фоновая остановка, которая в CI выпускается ПОСЛЕ старта второго AVD, в журнале песочницы стоит ДО него.
ОБЯЗАТЕЛЬСТВО: И-11 (:63) «второй эмулятор профиля 393 запускается ТОЛЬКО после остановки первого — не одновременно»; ЗАЩИЩАЕТ (:223) «от одновременного старта AVD (И-11) … отвергает START при живом первом»; НЕ ЗАЩИЩАЕТ (:235) исключает лишь семантику настоящих adb/emulator и прямо утверждает «модель двойников судит порядок команд»; закрывающее свойство арбитража (П1/пункт 2) — «скрипт, который пойдёт в CI, вообще останавливает первого до старта второго».
КЛАСС ПРИЧИНЫ: новая семантика дельты П1 — модель песочницы с мгновенными двойниками длительных команд (`sleep`, `maestro`; также ожидание загрузки) не сохраняет порядок событий между основным потоком и фоновым заданием. Это не ветвление на среде (:233), не подделка журнала (:234), не семантика adb/emulator (:235) и не обход PATH (:236): все команды идут через двойники, журнал пишут только двойники, ветвлений нет. Класс в НЕ ЗАЩИЩАЕТ не назван — атака внутри объявленной границы.
СОСТОЯНИЕ: допустимый вход по демаркации :243 (bash-скрипт e2e.sh, грамматика shell не ограничена) — эталон, где единственная строка `adb -s "$SERIAL_390" emu kill` заменена на `( sleep 600; adb -s "$SERIAL_390" emu kill ) &`. В CI: цикл ожидания эталона (30 × `sleep 2` = 60 с) истекает без break, `$ANDROID_HOME/emulator/emulator -port 5576` стартует при живом emulator-5570, остановка первого приходит через 600 с — два AVD одновременно, ровно то, что запрещает И-11. В песочнице двойник `sleep` возвращается сразу, KILL emulator-5570 пишется раньше START 5576.
НАБЛЮДЕНИЕ: `proverka_emuljatorov` → `[]` 20/20; полная `W --repo <референс+подстановка>` — rc 0, «клеток 35, зелёных 35, красных 0»; на копии реального продукта PR #147 — `produkt_sud --repo` rc 0. Тот же класс — `( maestro … test …; adb … emu kill ) &` (rc 0 20/20, полная W rc 0 35/35). Контроль: тот же судья с двойником `sleep`, сохраняющим порядок времени (×0.01), даёт на том же входе `EMULJATORY_ODNOVREMENNO`, а честные базу, `false || kill`, `kill & wait` оставляет зелёными — ложное зелёное порождено сжатием времени, а не входом.
ОБХОД: `( sleep 600; adb -s "$SERIAL_390" emu kill ) &` вместо остановки первого проходит все 52 клетки `--model`/`--stabs` и `W --repo` rc 0, при этом в CI второй AVD 60 с… 600 с живёт одновременно с первым; ни одна клетка/стаб этого не ловит.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: вход, у которого остановка emulator-5570 не завершена в основном потоке скрипта до START второго при ЛЮБЫХ длительностях команд, сжатых двойниками (`sleep`, `maestro`, ожидание загрузки), не получает rc 0 — в батарее есть красная клетка с дословным входом `( sleep 600; adb -s "$SERIAL_390" emu kill ) &` (rc 1 именованной причиной) и стаб, зеленящий её; честные формы `false || kill`, `kill & wait`, два пробела и эталон остаются rc 0. Реализацию выбирает architect (Н-39; один из измеренных вариантов — второй прогон с двойниками, сохраняющими порядок длительностей, как в ci_vremja.py). Иначе — только решением полномочной роли (владелец через оркестратора; арбитраж по предмету уже использован) класс «фоновая остановка при сжатом времени двойников» переносится в НЕ ЗАЩИЩАЕТ с ловцом, а :223 и :235 перестают утверждать «судит порядок команд» без оговорки.

## САМООПИСАНИЕ (полный список «число/утверждение в тексте → живое»)

Сверено всё счётное в контракте, osi.md и шапке батареи. Совпадающие (для учёта): 52 клетки = 34 формы + 18 `pr-` (`len(kejsy)`); 2 базы rc 0 (`chestnyj-vkladki`, `pr-chestnaja`) + 50 негативов (43 rc 1, 7 rc 2); без флага 52/35/17, `--model` 52/52, `--stabs` 52/52 SVJAZI 42 живых 0, `--repo` 35/35 (референс и PR #147); 25 стабов s65–s89 (12 A: s65–s74, s84, s88; 13 B: s75–s83, s85–s87, s89); 42 привязки (`sum(len(stab_vhod))`); 16 PNG = 923 860 байт (≈ 924 КБ десятичных); 12 файлов эталонной раскладки; оси osi.md 5/5/6/7/3/4/3 + «Продукт (18)» = 52 с учётом обеих баз; «четыре независимых входа» EMULJATORY_ODNOVREMENNO = 4 клетки; шапка `red_*.sh` «s65–s89 (SVJAZI 42)»; ожидаемые сообщения приёмки 12 (`EMULJATORY_ODNOVREMENNO: START 5576 при живом эмуляторе`, `PORT_393_NE_5576: START 5571`) = stdout source.json и живой вывод.

Расхождения:

1. САМООПИСАНИЕ contracts/148-vkladki-tabov.md:71 (приёмка 1) — «(34 клетки формы зелены, все 17 продуктовых мутаций … получают PACHKA_ABSENT)» при «красных 17» → живое: продуктовых мутаций 17 (18 `pr-` минус `pr-chestnaja`), из них КРАСНЫ 16, а `pr-pachka-net` ЗЕЛЕНА (её ожидание и есть PACHKA_ABSENT) — это 35-я зелёная клетка; 17 красных = 16 мутаций + честная база `pr-chestnaja`. PACHKA_ABSENT получают все 17 красных и `pr-pachka-net`.
2. САМООПИСАНИЕ contracts/148-vkladki-tabov.md:3 (шапка, ВЕРСИЯ v2) — «+2 красные клетки — §Приёмка 11/12» → живое против `frozen/contracts/148/1`: клеток 44 → 52 (+8: 2 слова 31.10 + 4 правки Crit148v2 + 2 дельты арбитража), стабов 19 → 25 (+6), привязок 33 → 42 (+9) (`git show frozen/contracts/148/1:…/source.json`). Построчные :266/:267 считают верно, шапка — нет.
3. САМООПИСАНИЕ contracts/148-vkladki-tabov.md:264 «реальные байты трёх источников (1.3 МБ, пины)» — проверено по требованию задания: `nositeli/d24-real/{manifest,poses,spec}.json` = 409 727 + 398 094 + 505 822 = **1 313 643 байт** = 1.31 МБ десятичных (1.25 МиБ); «1.3 МБ» **совпадает** с живым числом, расхождения нет. Остальные числа строки :264 (52; 2 + 50; 25 = 12 + 13; 42; 16 макетов; 923 860 байт = 924 КБ; 12 файлов) совпадают.

Иных счётных расхождений не найдено. Адресов строк (`файл:N`) в дельте нет; единственный в контракте — `mobile.yml:136` (:18, продукт, вне дельты, не перемерялся).

## СОВЕТ

- СОВЕТ contracts/148-vkladki-tabov.md:236 и :63 — обход абсолютным путём назван свойством («распознавание обхода PATH/ANDROID_HOME абсолютным путём»), но пояснение и И-11 говорят только о пустом журнале. Гибрид «абсолютный путь ДО остановки + честный цикл-приманка» (`hybrid-abs-path`) даёт **rc 0**, а не именованный отказ. Граница названа, поэтому это совет: пояснение стоит дополнить фразой «при наличии цикла через двойники — rc 0, ловец reviewer». Чистый обход (`abs-path-only`) честно даёт `EMULJATORY_NA_VHODE_PAROJ` + `E2E_PESOCHNICA_RC` 20/20, как и обещано.
- СОВЕТ produkt_sud.py:134-140 — любой вызов `emulator` считается START, даже без `-port`. Честная диагностическая строка `emulator -list-avds` даёт `EMULJATORY_ODNOVREMENNO: START  при живом эмуляторе` + `PORT_393_NE_5576: START , требуется 5576`: отказ консервативный, но диагноз по правилу 7 ложен. Аналогично частая форма `"$ANDROID_HOME/platform-tools/adb"` даёт `EMULJATORY_NA_VHODE_PAROJ` + rc 127, потому что в песочнице нет `platform-tools/adb`. Стоит либо назвать это в демаркации :243 («только adb/emulator из PATH и `$ANDROID_HOME/emulator`»), либо дать двойникам эти формы.
- СОВЕТ contracts/148-vkladki-tabov.md:88 — позитивные входы приёмки 12 (`false || kill`, `kill & wait`, два пробела, «каждый rc 0») не имеют клетки в `W`; сейчас они зелены только при прямом вызове (attacks.py). Стоит добавить зелёные клетки, иначе пункт проверяется вне названной команды.
- СОВЕТ produkt_sud.py:152-155 / П1 арбитража — сообщение `EMULJATORY_ODNOVREMENNO` называет порт, но не живых по журналу (П1: «сообщение называет порт и живых»). Автор сознательно убрал детали ради детерминизма гонки (20/20 подтверждено). Это расхождение с формулировкой перечня, на безопасность не влияет.
- СОВЕТ osi.md:59 — «журнал может содержать два нарушения порядка на двух START одного входа» верно о журнале, но судья после правки сообщает только первое (`narushen_porjadok`). Лучше написать: «судья называет первое».

## Что НЕ проверено

- Реальное поведение adb/emulator/maestro в CI и диаг-PR приёмки 10: вне батареи, эмуляторы запрещены правилом станции. Факты «CI» в блоке выведены из текста эталона (`sleep 2` ×30, `&`) и из контроля ci_vremja.py, а не из живого CI. [INFERENCE] Длительность фактического сосуществования двух AVD в CI (60–600 с) не измерялась.
- Соседние батареи 143/146/147/149 — не предмет scoped-суда.
- Маска 48, ПЕРЕСЕЧЕНИЕ cmp-mob-002-tabs.yaml и CI-часть — по заданию не пересуживались.

## Процесс

Блок содержательный, поэтому стоячее правило 31.10 о FAIL только по самоописанию неприменимо. Вызов 3 по v2 — сверх капа, арбитраж по предмету уже использован (`roles/critic.md §Остановка`). Дальнейший путь к freeze — только явное решение владельца: новая дельта architect с ещё одной подписью критика либо перенос класса в НЕ ЗАЩИЩАЕТ. Это решение владельца, а не следующий автоматический круг.

Скрипты атак (одноразовые, вне репо автора): `/tmp/dev-harness-verify/Crit148v3b/{attacks.py,attacks2.py,attacks3.py,ci_vremja.py,povtor_odn.py,stab_lozh.py,schet.py,gates.sh,run.sh}`; сырые выводы батареи — `/tmp/dev-harness-verify/Crit148v3b/runs/`. Правок в репо автора нет.

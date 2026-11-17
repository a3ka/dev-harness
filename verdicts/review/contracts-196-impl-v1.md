accept
OBJECT=9e2da12e5bbf39309b0aeb3c3aa65c328d1595b0
КЛАСС=кодовый; КЛАСС РИСКА=обычный — подтверждён (локальные каталоги станции и чистка внутри своего корня; права БД/авторизация/деньги/ПД не затронуты; адверсарий по заданию не вызывался)
СУД: repo=dev-harness; предмет=196; фаза=реализация; роль=reviewer; вызов=1/1; модель-план=по config/agent_models.json (reviewer: @opus); сессия=Rev196Impl; модель-факт=anthropic/claude-opus-5-5; SHA=9e2da12e5bbf39309b0aeb3c3aa65c328d1595b0; контракт=frozen/contracts/196/1 (28b1b714887e13adc3976bbb099288b7e1c1e42c → c0ec72e343); предыдущий=нет; исключение=нет

# Вердикт reviewer — 196 «локальное хранилище артефактов CI на станции», реализация, вызов 1/1

**accept.** Блоков нет. Советы и наблюдения — `.review/2026-11-17-100.md` (`status: ready`), тем же коммитом.

| Находка | Класс | Адресат | Суть |
|---|---|---|---|
| С-1 | совет (приоритетный) | implementer + architect 074 | `ARTIFACTS_UNITS` (install.sh:177) никто не читает. Биекция №2 к5 засчитывает его как «ставится и сверяется». Мутант с юнитом, объявленным только там, проходит и 074 (к5 зелёная), и 196 (25/25), хотя юнит не ставится. На OBJECT такого состояния нет. |
| С-2 | совет | architect 196 (модель) | Срез `date -u` без зоны против `find -newermt` в локальной зоне: при TZ=America/New_York удаляется молодой прогон (13 сут 21 ч). Станция Etc/UTC, поэтому здесь недостижимо. Сбой `find` (`2>/dev/null`) толкает к удалению. |
| С-3 | совет | architect 196 (модель) | `CI_ARTIFACTS_ROOT=<ссылка>/` обходит И-3 (rc 0, удаление в цели). Умолчание защищено, подмену базы может сделать только root. |
| С-4 | совет | architect 196 (батарея) | install-artifacts пинит субъект к модели побайтно (probe.py:752,757). Из-за этого в продакшн-файле стоит шапка «НЕ продакшн», а грамматические мутанты краснят только по байтам, не поведенческой клеткой. |
| С-5 | совет | architect 196 (модель) | Glob в `CI_ARTIFACTS_REPOS` раскрывается по cwd до проверки грамматики (`'*'` → чистка `zzz`), за пределы корня это не выходит. |
| С-6 | совет, ACCIDENTAL по 050 | implementer | provision_base и provision_root — дубли; check_root повторяет ciart_matches; фраза «репо — символьная ссылка» стоит у базы и у не-каталога; `exit $?` недостижим. |
| Н-1…Н-4 | наблюдения | — | молчаливый пропуск отсутствующего репо и пустой срок → 14; правка орфографии в комментарии install.sh; `origin/wip/196/architect` ушёл на 2163e380; шаг 12 (живая установка) ещё впереди. |

## Клон и объект

- `git clone git@github.com:a3ka/dev-harness.git /tmp/dev-harness-verify/Rev196Impl` (свой `.git`), `git fetch origin wip/196/orchestrator`, `git checkout --detach 9e2da12e5b`, `git status --short | wc -l` → `0`.
- `git ls-remote`: `refs/heads/wip/196/orchestrator` = `9e2da12e5bbf39309b0aeb3c3aa65c328d1595b0`; `refs/tags/frozen/contracts/196/1` = `28b1b714…`, `^{}` = `c0ec72e343…`.
- `git diff --quiet 'frozen/contracts/196/1^{commit}' 9e2da12e5b -- contracts/196-lokalnye-artefakty-ci-stanciya.md fixtures/workshop_project/ops_ci_artifacts_196` → `contract-battery-identical-to-freeze`.
- История: `9e2da12e d824d528 69ee069c orchestrator` (merge); `69ee069c 41de61a2 architect` (074); `d824d528 42ece65b implementer`; `42ece65b 41de61a2 implementer`. Подписи: `implementer <implementer@dev-harness.local>` ×2, `architect <architect@dev-harness.local>`, `orchestrator <orchestrator@dev-harness.local>`.
- Сравнительные деревья (main 41de61a2de, перекрёстные батареи 074, мутанты) — `git archive | tar -x` в `/tmp/dev-harness-verify/Rev196Impl-x/`, не worktree.

## 1. Область правки

```
$ git diff --stat 41de61a2de 9e2da12e5b
 fixtures/ops_server/red_server_obvjazka_074.sh     | 108 +++++++++--
 ops/server/README.md                               |  42 +++++
 ops/server/install.sh                              | 205 ++++++++++++++++++++-
 ops/server/root/ci-artifacts-clean                 | 120 ++++++++++++
 .../root/gh-runner-complior-ci-artifacts.conf      |   2 +
 ops/server/root/systemd/ci-artifacts-clean.service |   6 +
 ops/server/root/systemd/ci-artifacts-clean.timer   |  10 +
 7 files changed, 480 insertions(+), 13 deletions(-)
```
Семь файлов. Шесть из них — ровно ЗОНА implementer контракта 196, седьмой — батарея 074 (ЗОНА architect frozen 074). Контракта, реестра, CI и чужих скриптов в диффе нет. Merge — чистое объединение: `git diff --stat d824d528fb 9e2da12e5b` даёт только файл 074, `git diff --stat 69ee069c94 9e2da12e5b` — только шесть файлов ops. Содержательных разниц с родителями нет (`git diff 69ee069c94 9e2da12e5b -- fixtures/ops_server | wc -l` → `0`, `git diff d824d528fb 9e2da12e5b -- ops | wc -l` → `0`).
По коммитам: 42ece65b48 трогает 4 файла ops, d824d528fb — README и install.sh, 69ee069c94 — только батарею 074. Implementer не трогал фикстуры, architect не трогал ops.
Строки `UNITS=` в install.sh не тронуты: `git diff … -- ops/server/install.sh | grep -c '^[-+]UNITS'` → `0`. Удалено ровно две строки: орфография в комментарии швов (Н-2) и строка usage, расширенная на `|artifacts`. Удалённых строк в README — `0`.
Зоны своей мерой — против ЗОНА-строк замороженных блобов. Шесть файлов implementer (42ece65b48, d824d528fb, user.name `implementer`) дословно перечислены в `ЗОНА implementer` frozen/contracts/196/1. Файл `fixtures/ops_server/red_server_obvjazka_074.sh` (69ee069c94, user.name `architect`) лежит под `ЗОНА architect: … fixtures/ops_server/ …` у frozen/contracts/074/1 и 074/2 (строка 250 блоба). Коммит orchestrator — merge, check_zones merge-коммиты не судит. `bash scripts/check_zones.sh` (полная история, OBJECT): первый прогон убит таймаутом 600 с, второй завершился за 760.93 с — `замороженных контрактов: 175 · объявленных авторов: 5 · коммитов в диапазонах: 63727 · проверено по зонам: 20403`, `RC_zones=0`.

## 2. Сырой вывод (перепрогон в клоне на OBJECT)

```
$ bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh; echo RC=$?
— young-kept: OK … (все 25 клеток OK)
ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25 KRASNYE=0
RC=0
$ … --model
ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25 KRASNYE=0
RC=0
$ … --stabs
— s01_molodost_po_verhnej_papke.sh на входе young-inside-file: POIMAN … — s34_bez_rezhima_kornej.sh на входе install-roots-preinstalled: POIMAN
ИТОГ 196: rc=0 OBMANOK=34 POIMANY=34 ZHIVYH=0
RC=0
$ … --repo /nonexistent-root-196
NOT_IMPLEMENTED: корень не существует: /nonexistent-root-196
RC_nonexist=2
$ bash -n ops/server/root/ci-artifacts-clean; bash -n ops/server/install.sh
RC_n_clean=0
RC_n_install=0
$ bash fixtures/ops_server/red_cikl_perezapuska_085.sh
стаб-пак: 40/40 поймано, диффпроба: 32/32
итог 085: красных=0, стабы=40/40, диффпроба=32/32
RC_085=0
$ bash fixtures/_krasnye_074.sh     # OBJECT
k5b: станция /usr/local/sbin/orch-peak разошлась со снимком 2026-10-02
  КРАСНО: cell_k5b
честная часть: 7/7 зелёная
стаб-пак: 7/7 поймано, диффпроба: 7/7
  посторонний юнит красен по имени: биекция №2 не ослаблена (UNITS ∪ ARTIFACTS_UNITS)
биекция №2: честная-196 зелёная 1/1, посторонний красный 1/1
к1b-каналы: честные 6/6, ленивые пойманы 6/6
итог 074: красных клеток=1 стабы=8/8
RC_074=1
```
Счёт своей мерой, а не выводом автора. Замеры контракта: `ls …/stabs/* | wc -l` → `34`, `ls …/model/* | wc -l` → `6` (README-ops-server.md, ci-artifacts-clean, .service, .timer, gh-runner-complior-ci-artifacts.conf, install-artifacts.sh). Словарь STUBS в probe.py — другой мерой: `grep -cE "^\s+'s[0-9]{2}_[^']+': \('" probe.py` → `34`. Все 34 привязаны к входам кодом батареи, живых 0.

090 и 093 — красны одинаково на OBJECT и на main 41de61a2de, то есть это не новое:
```
$ (OBJECT) bash fixtures/_krasnye_090.sh
КЛЕТКА-ОТКАЗ(090): герметичность нарушена: НОВЫЕ/ИЗМЕНИВШЕЕСЯ пути под множеством чтения реального orch-peak во время прогона (… /home/harness/.local/state/dev-harness-sessions/c907157c/…/2026-11-16T09-25-37-872Z_….jsonl; …)
ИТОГ 090: rc=1
$ (main 41de61a2de) bash fixtures/_krasnye_090.sh
КЛЕТКА-ОТКАЗ(090): герметичность нарушена: … (тот же путь живой сессии c907157c) …
ИТОГ 090: rc=1
$ (OBJECT) bash fixtures/_krasnye_093.sh | grep '^— .*: rc='
— battery_stubs.sh: rc=0 … — red_net_osirotevshih_detej.sh: rc=0   (9 из 10 rc=0)
— red_germetichnost_semi.sh: rc=1
ИТОГ 093: rc=1
$ (main 41de61a2de) bash fixtures/_krasnye_093.sh | grep '^— .*: rc='
— battery_stubs.sh: rc=0 … — red_net_osirotevshih_detej.sh: rc=0   (9 из 10 rc=0)
— red_germetichnost_semi.sh: rc=1
ИТОГ 093: rc=1
```
Причина 090 — запись параллельных сессий станции под множеством чтения orch-peak. 093 красна той же клеткой герметичности `red_germetichnost_semi.sh` на обоих деревьях, остальные 9 прогонов rc 0. К диффу 196 ни то, ни другое не относится.

## 3. Проверка не подогнана; красное предъявлено

- Батарея 196 и контракт на OBJECT побайтно равны тегу заморозки (см. «Клон»). Implementer фикстур не трогал.
- Батарея 196 красна на дереве без реализации (main 41de61a2de, `--repo`): все 25 клеток `KRASNO (субъект отсутствует: …)`, `ИТОГ 196: rc=1 KLETKI=25 ZELENYE=0 KRASNYE=25`, `RC_196_main=1`.
- Красные множества 074 до и после правки, своими перекрёстными прогонами:
```
=== main  (батарея 074 main × дерево main)
  КРАСНО: cell_k5b
итог 074: красных клеток=1 стабы=7/7
=== obj-oldbat  (батарея 074 main × дерево OBJECT) — зачем правка
k5: юнит ci-artifacts-clean.service вне инвентаря install.sh — не ставится, verify слеп
  КРАСНО: cell_k5
  КРАСНО: cell_k5b
итог 074: красных клеток=2 стабы=7/7
=== main-newbat  (батарея 074 OBJECT × дерево main)
  КРАСНО: cell_k5b
  стаб s8 пойман (вход cell_k5, биекция №2): комментарий — не объявление
итог 074: красных клеток=1 стабы=8/8
=== OBJECT (батарея 074 OBJECT × дерево OBJECT)
итог 074: красных клеток=1 стабы=8/8    (только cell_k5b)
```
До правки {к5b}, после правки {к5b}; новых красных нет. Прежние стабы 074: 7/7 пойманы в обоих вариантах.
- Гейт не ослаблен по названным осям — доказано прогонами мутантов (копии OBJECT):
```
=== mut-rogue   (лишний root/systemd/orch-rogue-rev.timer, нигде не объявлен)
k5: юнит orch-rogue-rev.timer вне инвентарей install.sh (UNITS=/ARTIFACTS_UNITS) — не ставится, verify слеп
  КРАСНО: cell_k5
итог 074: красных клеток=3 стабы=8/8
=== mut-weak    (биекция №2: `return 1` → `:` — «принимает что угодно»)
  КРАСНО: биекция №2 ослаблена: посторонний юнит (ни в UNITS, ни в ARTIFACTS_UNITS) не краснит к5 именем
  КРАСНО: стаб s8 жив: биекция №2 принимает что угодно (комментарий-«объявление» зелёнит юнит) (Н-39)
итог 074: красных клеток=3 стабы=7/8
=== mut-greedy  (inventory_of снимает «# » перед разбором — неякорный разбор)
  КРАСНО: стаб s8 жив: биекция №2 принимает что угодно (комментарий-«объявление» зелёнит юнит) (Н-39)
итог 074: красных клеток=2 стабы=7/8
```
Остаток — С-1: членство в `ARTIFACTS_UNITS` не связано с установкой (`mut-dead`: к5 зелёная, `итог 074: красных клеток=1` (к5b), `ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25`).
- Свои мутации субъекта 196 (не из набора стабов), батарея краснеет на каждой:
```
m196-d (два дефиса в имени прогона принимаются)  → install-artifacts: KRASNO (скрипт не установлен байт-в-байт (755)); ИТОГ 196: rc=1 … KRASNYE=1
m196-e (срок 0 допустим)                          → install-artifacts: KRASNO (скрипт не установлен байт-в-байт (755)); ИТОГ 196: rc=1 … KRASNYE=1
m196-f (verify бэка без владельца/группы)          → verify-roots: KRASNO (сверка не смотрит корни (владелец бэка) …); ИТОГ 196: rc=1 … KRASNYE=1
m196-g (drop-in ставится только первому юниту)     → verify-runner-dropin + install-runner-dropin: KRASNO (… gh-runner-complior-2); ИТОГ 196: rc=1 … KRASNYE=2
```
d и e ловит только побайтовый пин к модели, поведенческие клетки молчат (С-4). Поэтому поведение реального субъекта я проверил напрямую (`Rev196Impl-x/edge.sh`):
```
[multi-hyphen] rc=1  ОТКАЗ: имя прогона вне грамматики <число>-<число>: …/Complior-mob/1-2-3   удалено: …/5-1   ci-artifacts: репо Complior-mob: удалено 1, хранится 1   (остались 1-2-3, 6-1)
[ret=[0]] rc=1 ОТКАЗ: срок не целое ≥1: 0   [00] [-1] [abc] [' 3'] [1e2] — rc=1 тем же отказом;  [ret=[]] rc=0 (умолчание 14, Н-1)
[repos=[.]] [..] [a/b] [-x] [.hidden] — rc=1 ОТКАЗ: недопустимое имя репо: <имя>
[root-symlink] rc=1 ОТКАЗ: корень не каталог: …/r3      [root-symlink-slash] rc=0 удалено: …/r3//Complior-mob/7-1   (С-3)
[repos=*] rc=0 удалено: …/r4/zzz/9-1   (С-5)
[TZ=UTC] 10-1 (13 сут 21 ч) хранится; [TZ=America/New_York] удалено: …/10-1; [TZ=Asia/Singapore] хранится   (С-2)
```

## 4. Контракт 196 — инварианты в коде

- И-1 — `ops/server/root/ci-artifacts-clean` (git-режим 100755); швы `CI_ARTIFACTS_ROOT/RETENTION_DAYS/REPOS` с умолчаниями `/var/lib/ci-artifacts`, `14`, `Complior-mob Complior-back`; коды 0/1/2 (NOT_IMPLEMENTED на отсутствующие `date/find/rm/sort`) — соответствует.
- И-2 — срок `''|*[!0-9]*` и `-ge 1`; имя репо — `.`/`..`/`*/*`, затем `[!A-Za-z0-9]*|*[!A-Za-z0-9._-]*`; обе проверки стоят до `[ -L "$ROOT_ENV" ]` — соответствует. Оговорка о glob — С-5.
- И-3 — `:47` соответствует; оговорка о слеше — С-3.
- И-4/И-5 — три `case` грамматики (один дефис), `-L`, затем `! -d`; запись не трогается, цикл продолжается (`continue`, `refuse=1`) — соответствует, доказано прогоном `[multi-hyphen]`.
- И-6 — `find "$entry" -newermt` по всему дереву без `-L` (символьные ссылки не обходятся), `rm -rf -- "$entry"` по литеральному пути, строки `удалено:` и сводка по репо — соответствует (на UTC-станции; С-2).
- И-7 — цикл только по `$REPOS`; репо-ссылка или не-каталог → `ОТКАЗ: репо не каталог` без обхода — соответствует.
- И-8 — `.service`: `[Service] Type=oneshot`, `ExecStart=/usr/local/sbin/ci-artifacts-clean`; `.timer`: `OnCalendar=*-*-* 04:30:00 Asia/Singapore`, `Persistent=true`, `[Install] WantedBy=timers.target` (плюс `AccuracySec=1min`, есть и в модели); `HOME` в чистильщике не читается (`no-home-service-env: OK`) — соответствует.
- И-9 — поадресный проход по `install_ci_artifacts` (то, что контракт в «Остатке» поручает ловцу-ревьюеру):
  - euid-гард стоит первой строкой функции.
  - Источники ×4 (`-f`) и getent ×3 проверяются до первого `mkdir`.
  - Скрипт: `cp → chmod 755 → chown root:root → check_one`. Service и timer: `cp → chmod 644 → chown root:root`, затем `check_one` каждого. Каждая запись идёт с `die_write`.
  - База: `-L` → отказ; существующая — `ciart_matches 755 root:root` либо `ОТКАЗ: существующий корень расходится`; новая — `mkdir/chown/chmod` с `die_write`. Моб и бэк — так же, `2750` и `<владелец>:$CIART_GROUP`.
  - Drop-in: цикл по ОБОИМ `RUNNER_UNITS`, условие `-f "$ETC_DST/$unit.service"`, `mkdir .d → cp → chmod 644 → chown root:root → check_one`. Всё это до `daemon-reload`.
  - systemctl: `command -v` (rc 2 `NOT_IMPLEMENTED: нет <имя>`), затем `daemon-reload` и `enable --now ci-artifacts-clean.timer` с именованными отказами.
  - Строка успеха побайтно по контракту. check_one и обработка отказов применены ко всем семи адресатам: 3 файла, база, 2 корня, 2 drop-in. Соответствует.
- И-10 — тройка `! -e` → «не установлены» rc 0; иначе `check_one` ×3 (частичная → `ОТКАЗ: расхождение <путь> (нет файла)`), корни (режим 2750, затем `%U:%G`), drop-in по каждому присутствующему юниту; «сверка 3/3»; базовая «сверка: 10/10» не тронута (`verify_ci_artifacts` вызван после неё) — соответствует.
- Drop-in байт-в-байт: `cmp ops/server/root/gh-runner-complior-ci-artifacts.conf fixtures/workshop_project/ops_ci_artifacts_196/model/gh-runner-complior-ci-artifacts.conf` → `dropin-bytes-equal-model`; `cat -A` → `[Service]$` / `ReadWritePaths=/var/lib/ci-artifacts/Complior-mob$`.
- И-11 — README: раздел `## Локальные артефакты CI (контракт 196)` со всеми якорями (`readme-anchors: OK`), разделы 074 не переписаны (удалённых строк 0) — соответствует.
- И-12 — живая установка вне этого объекта (Н-4).

## 5. Безопасность и надёжность чистильщика

Удаление идёт только по `"$ROOT_ENV/$repo/<имя-в-грамматике>"`. Имя прогона — только цифры и один дефис, имя репо — замкнутый алфавит без `/`, `.`, `..`. Ссылки на месте корня, репо и прогона дают отказ без обхода. Возраст `find` считает без `-L`. Пустой корень даёт умолчание (`:-`), пустой список репо — `ОТКАЗ: список репо пуст`. Относительный корень контракт не запрещает. Нарушения обязательства на достижимом состоянии не найдено. Пограничные входы описаны в С-2, С-3 и С-5: все требуют не-UTC зоны станции, слеша в шве или glob в шве, который задаёт root. Hardlink и гонки — в НЕ ЗАЩИЩАЕТ контракта.

## 6. Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) совместные правки | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `root/ci-artifacts-clean` | И-1…И-7 | нет; 3 env-шва видны в README | 2 (субъект + `model/`, из-за пина С-4) — рост из-за батареи | 3 env, rc 0/1/2 против полной политики чистки: глубокий | service-юнит; клетки 196 | ESSENTIAL |
| `.service` + `.timer` | И-8 | нет | 2 (+модель) | данные | install/verify; unit-grammar | ESSENTIAL |
| `gh-runner-complior-ci-artifacts.conf` | И-9(е) | нет | 2 (+модель) | данные | install/verify drop-in | ESSENTIAL |
| install.sh `artifacts` + `install_ci_artifacts` | И-9 | явное: швы в шапке и README, rc/фразы | 1 | одна подкоманда, 5 швов (все названы контрактом) против 7 адресатов | install-*; шаг 12 | ESSENTIAL |
| `verify_ci_artifacts` | И-10 | нет | 1 | условная ветка в существующем verify | verify-*; шаг 12 | ESSENTIAL |
| `ciart_matches` / `ciart_refuse_existing` | И-9(г) идемпотентность | нет | 1 | мелкие помощники | install-roots-preinstalled | ESSENTIAL |
| `ciart_provision_base` + `ciart_provision_root` | И-9(г) | нет | 2 при правке приёма корня | дубль, разница в двух аргументах | install-* | ACCIDENTAL (С-6, совет: одна функция `<каталог> <режим> <владелец:группа>` проходит те же строки) |
| `ciart_check_root` | И-10 корни | нет | 2 (повтор `ciart_matches`) | — | verify-roots | ACCIDENTAL (С-6, совет: `[ -d ] && ciart_matches … 2750 …`) |
| `ciart_install_dropin`, `RUNNER_UNITS` | И-9(е) | нет | 1 | — | install/verify-runner-dropin | ESSENTIAL |
| `ARTIFACTS_UNITS` | грабли-074 (контракт требует переменную) | объявление без потребителя в install.sh | 2 (список + жёсткие пути) — источник дрейфа | мёртвая в install.sh, живая только для 074 | к5 074 | ESSENTIAL по контракту; несвязанность с установкой — С-1 |
| README-раздел | И-11 | — | 1 | — | readme-anchors | ESSENTIAL |
| 074: `inventory_of` (обобщение `units_of`), `artifacts_units_of`, `run_k5_on`, `run_k5_bij2_pack`, стаб s8 | расширение биекции №2 при грабле-074 + красное предъявление | нет; миры в `$SCRATCH` | 1 | одна грамматика на обе переменные | `_krasnye_074.sh` | ESSENTIAL |

Блокирующих ACCIDENTAL нет: С-6 называет фрагмент и более простую форму, но не отсутствующее свойство.

## 7. Атомарность и норма

Оба коммита implementer ссылаются на предмет 196. Коммит architect — на 074/196. Merge orchestrator лишнего не вносит. Нормативные документы (roles/, AGENTS.md, contracts/) в диффе не тронуты.

ПРОВОДКА 196: `guard=fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh` существует, и это барьер именно этого предмета. По контракту CI-шаг `--stabs` подключает orchestrator после реализации, в объект суда он не входит.

СВЕРКА-СТАНДАРТОВ: неприменимо — `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`ls` → `No such file or directory` для обоих).

ПРОВЕРКИ ДЛЯ ОРКЕСТРАТОРА: перед приземлением `bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh` (и `--stabs`) и `bash fixtures/_krasnye_074.sh` на свежей интеграции с текущим main — красное множество 074 должно остаться {к5b}. Шаг 12 (живая установка) — отдельная приёмка.

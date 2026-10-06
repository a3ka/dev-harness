# Контракт 088 — «в полёте ничего»: дверь видит живых субагентов сессии omp; pre-commit держит строку-указатель HANDOFF

## Существующее

- **scripts/orch_restart.sh, нога (1)** (080, инв. 3): «живые субагенты: <имена>» — свежий (<120 с)
  `.jsonl` в каталоге текущей сессии; каталог даёт `current_session_dir`, список —
  `live_subagents_in` из **scripts/lib_session.sh** (080, инв. 13 — единый источник; умолчание
  `ORCH_SESS_GLOB=$HOME/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/*.jsonl`,
  швы `ORCH_SESS_DIR`/`ORCH_SESS_GLOB`). Механизм ЕСТЬ — «нормы без механизма» (слово владельца)
  дерево не подтверждает: механизм есть, но слеп в живой среде.
- **Замер отказа 17:53 (журнал сессии 2026-10-06T14-01-09).** Дверь вызвана 17:53:23.492, ответ
  «ПЕРЕЗАПУСК: маркер поставлен» 17:53:32; последняя запись `Implementer086.jsonl` — 17:53:21.322
  (2 с до вызова); 17:53:52 субагент убит (`session_exit sigterm`). Две причины, обе измерены:
  (1) под omp `HOME=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev`
  (`echo $HOME` в сессии) → глоб пуст → `current_session_dir` пусто → `live_subagents_in ""` rc 0;
  (2) дверь живёт под `set -uo pipefail` (orch_restart.sh:44), а `current_session_dir` —
  `f="$(ls -t … | head -1)" || return 0`: при листинге больше буфера SIGPIPE даёт rc 141 →
  пусто. Живьём: 40 session-файлов, 7880 байт листинга — под pipefail пусто 5 из 5, без pipefail
  — каталог найден. Любая одна причина делает ногу (1) живым no-op.
- **ops/server/root/orch-peak** (085, живая зона implementer): дом — `UHOME="$(getent passwd "$U" | cut -d: -f6)"`
  (строка 18), сторож простоя — `find <сессия> -maxdepth 1 -name '*.jsonl' -newermt "-${SUB_LIVE} seconds"`
  (`SUB_LIVE=300`, строки 33, 248); ветка 600K (CTX_HARD) — `current_session_dir`/`live_subagents_in`
  из lib_session.sh; режим — `set -u` (строка 16), pipefail нет. 088 эти строки не трогает.
- **roles/orchestrator.md:424-427** — «Маркер при живых субагентах/джобах ЗАПРЕЩЁН» (cognitive);
  088 даёт ему механизм в живой среде.
- **Клетка k7** (`fixtures/ops_server/red_server_obvjazka_074.sh:505-516`, строки 143, 511-512):
  `HANDOFF_PTR` + `awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f'` +
  `grep -Fxq`. Это ЕДИНСТВЕННАЯ реализация проверки в дереве: в `scripts/` и `.githooks/` строки
  `HANDOFF_PTR`/«Серверная обвязка станции» нет (grep — 0 совпадений); библиотеки нет.
  Ловит только на CI после пуша — отсюда три красных main за 2 дня (Н-209 и повторы 06.10).
- **scripts/check_staged.sh** (016/018/019/023/031/049/080): staged — `git diff --cached --name-only -z`
  (строка 244), затем ранние выходы rc 0 «нечего судить»/«не судится» (строки 250-268) — оркестратор в заморозках
  не объявлен, поэтому его коммит HANDOFF.md не судится ничем (замер: тоу-репо `_repo.sh`,
  `не судится: автор «orchestrator» не объявлен ни в одной заморозке`, rc 0).
- **.githooks/pre-commit** (016): `exec bash "$ROOT/scripts/check_staged.sh" "$ROOT"` — правки
  не требует (честная симуляция без неё зелёная).
- **Батареи двери** `fixtures/_krasnye_072.sh`, `fixtures/dver_bugfiks_080/red_dver_bugfiks_080.sh`:
  на дереве 592fc4e и на честной симуляции 088 — rc 0 обе (072: «честные 6/6»; 080: «честные 31/31»).

## Предмет

А. Нога (1) двери в живой среде omp видит журналы субагентов ТЕКУЩЕЙ сессии и отказывает
rc 1 «ОТКАЗ: живые субагенты: <имена>» (грамматика 080), пока хоть один свежий.

Б. Коммит, в котором staged корневой `HANDOFF.md`, отказывается pre-commit'ом (через
`scripts/check_staged.sh`), если в первой секции «## ГДЕ МЫ» индекса нет строки-указателя k7.

Один названный отказ: «механизм перед перезапуском/пушем молча пропускает то, что норма
запрещает» — оба плеча измерены сегодня, оба закрываются красным критерием одной батареи.

## Frontier

1. **Дом журналов — passwd, не `$HOME`.** Тот же источник, что `UHOME` orch-peak (строка 18):
   `getent passwd "$(id -un)"`, поле 6. Отвергнуто: (i) `$PI_CODING_AGENT_DIR` — внутренняя
   переменная omp, механизмы станции её не читают, вторым признаком разошлись бы с orch-peak;
   (ii) своя копия глоба в двери — вторая грамматика пути (080 инв. 13).
2. **Глоб — только из lib_session.sh.** Дверь подключает библиотеку с `HOME` = дом из passwd
   на время подключения (`HOME="$uh" . lib_session.sh`), умолчание глоба вычисляется прежней
   строкой библиотеки. Швы 080 (`ORCH_SESS_DIR`, `ORCH_SESS_GLOB`) заданы → берутся как есть.
3. **pipefail-слепота закрывается в двери**, lib_session.sh остаётся байт-в-байт: вызов
   `current_session_dir` — в подоболочке без pipefail. Отвергнуто: правка lib_session.sh — она
   источник ветки 600K orch-peak, которую 088 не трогает (слово владельца); честная симуляция
   варианта «только дверь» зелёная при `cmp` lib_session.sh = 0.
4. **Окно свежести (120 с), признак и формат имён — прежние** (080). Расхождение с окном
   сторожа простоя (`SUB_LIVE=300`) — не предмет 088 (§Открытые вопросы).
5. **Б — одна производственная реализация в check_staged.sh**, ДО ранних выходов «не судится»,
   над блобом индекса `:HANDOFF.md`. Грамматика — побайтово клетки k7: строка-указатель и
   граница секции. Отвергнуто: (i) библиотека `lib_handoff.sh`, общая с фикстурой 074 —
   фикстура лежит в живой зоне architect 085/1, и оракул k7 брал бы ожидание из субъекта
   (правило 8); (ii) суд рабочего дерева — коммит несёт индекс; (iii) суд при любом коммите —
   предмет говорит «коммит, в котором staged HANDOFF.md».
6. **Связь с k7 держит батарея:** `PTR_088` читается из присваивания `HANDOFF_PTR` фикстуры 074
   (ровно одно совпадение, иначе rc 2) — второй копии строки в тестовом слое нет; расхождение
   производственной строки с k7 краснит клетки B0/B1.

## Инварианты

1. **А, источник дома.** Ни `ORCH_SESS_DIR`, ни `ORCH_SESS_GLOB` не заданы → дверь подключает
   `scripts/lib_session.sh` при `HOME` = поле 6 `getent passwd "$(id -un)"`; пустой ответ →
   rc 2 `NOT_IMPLEMENTED`, маркер не ставится. `$HOME`, `$USER`, `$LOGNAME` источником не служат.
2. **А, число сессий.** Каталог текущей сессии находится при любом числе session-журналов под
   `set -o pipefail` двери (клетка D2: 500 файлов, листинг > 64 КиБ).
3. **А, отказ.** Свежий журнал субагента в каталоге текущей сессии → rc 1, строка stderr
   `ОТКАЗ: живые субагенты: <имена через запятую, LC_ALL=C sort>`, маркер не ставится. Окно
   120 с, `live_subagents_in`, швы 080, ноги (0), (а)–(д) — прежние.
4. **А, неприкосновенность 600K.** `scripts/lib_session.sh` и `ops/server/root/orch-peak` не
   правятся (`git diff --exit-code <база> -- scripts/lib_session.sh ops/server/root/orch-peak` rc 0).
5. **Б, суд.** staged-выборка check_staged.sh (строка 244, с удалениями) содержит путь
   `HANDOFF.md` → судится блоб индекса `:HANDOFF.md`: первая секция — строки после первой
   строки, начинающейся `## ГДЕ МЫ`, до следующей строки `^## ` или конца; в ней обязана быть
   самостоятельная строка, побайтово равная `HANDOFF_PTR` клетки k7. Нет (включая удаление) →
   rc 1, коммит не создан.
6. **Б, место.** Проверка исполняется для любого автора ДО выходов «нечего судить» и «не
   судится» (строки 250-268) — в частности для оркестратора с `-c user.name=orchestrator` и
   пустым file-config.
7. **Б, грамматика отказа** (единый источник — check_staged.sh; батарея несёт побайтово):
   `ОТКАЗ: HANDOFF.md — в первой секции «## ГДЕ МЫ» нет строки-указателя (контракт 088)`.
8. **Б, границы.** Коммит без staged корневого `HANDOFF.md` этой проверкой не судится (B9, B13);
   прочие ветви check_staged.sh прежние; `.githooks/pre-commit` не правится.

## Демаркация контрпримеров

Конформные входы А: omp-сессия с `HOME`, отличным от дома passwd; любое число session-журналов;
имена субагентов — basename `.jsonl`, включая ведущую точку; швы 080 заданы или нет; любые
`USER`/`LOGNAME`. Конформные входы Б: HANDOFF.md — любой UTF-8 текст с LF; секций «## ГДЕ МЫ»
сколько угодно; подразделы `###`; staged-типы A/M/D; автор — любой. Валидный контрпример —
реализация, зелёная на всех клетках семьи, но расходящаяся с инвариантом на ДРУГОМ конформном
входе (значения имён, путей, числа файлов, порядок секций) — инвариантность к значениям и
расхождение на конформном входе. Не контрпример: `--no-verify`, `core.hooksPath` не задан,
CRLF, переименование HANDOFF.md с rename-детекцией, подложный `getent` в PATH вызывающего.

## Модель угроз

ЗАЩИЩАЕТ:
- перезапуск сессии дверью, пока субагент текущей сессии omp пишет журнал, при любом HOME сессии и любом числе журналов сессий
- коммит HANDOFF.md, где строка-указатель удалена, укорочена, дополнена или вынесена из первой секции, при любом авторе
- подмену проверки рабочим деревом: судится то, что попадёт в коммит
НЕ ЗАЩИЩАЕТ:
- субагента, молчащего дольше окна свежести 120 с (долгий вызов инструмента) — признак 080 прежний
- ветку 600K orch-peak: её резолв сессий под root не предмет 088
- коммит с no-verify и репо без core.hooksPath — ловец остаётся k7 на CI
- подлинность ответа getent и журналов omp — доверие к хосту станции

## Приёмочный критерий

Н-39: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды.

Привязка стабов — таблица PAK в шапке и коде `fixtures/strazh_088/red_stuby_088.sh`. Оракул —
`fixtures/strazh_088/_toy.sh` (PTR_088 из фикстуры 074, строка отказа И-7, в памяти батареи).

- `bash fixtures/_krasnye_088.sh fast` → красная: КРАСНО: D1
- `bash fixtures/strazh_088/red_dver_088.sh` → красная: КРАСНО: D1
- `bash fixtures/strazh_088/red_ukazatel_088.sh` → красная: КРАСНО: B1
- `bash fixtures/strazh_088/red_stuby_088.sh`
- `bash fixtures/_krasnye_088.sh` → красная: КРАСНО: B1

Сценарии (грамматика 050; ДО — HEAD 592fc4e, замер этой пачки; ПОСЛЕ — дерево с реализацией):

- П1. когда: `bash fixtures/_krasnye_088.sh fast`; ДО: rc 1 (D1, B1 красны); ПОСЛЕ: rc 0 за < 60 с
  (честная симуляция — 0,25 с).
- П2. когда: `bash fixtures/strazh_088/red_dver_088.sh`; ДО: rc 1, КРАСНО L1 D1 D2 D3, ЗЕЛЕНО D0 D4;
  ПОСЛЕ: rc 0, 6/6. D1 — HOME сессии пуст, дом passwd: ZhivojA, ZhivojB свежие, Staryj час →
  «ОТКАЗ: живые субагенты: ZhivojA,ZhivojB». D2 — шов над 500 журналами → «…: ZhivojMnogo».
  D3 — D1 при `USER=LOGNAME=chuzhoj088` → тот же отказ. Пары-негативы: D0 — только старый журнал →
  нога (1) пройдена, отказ (а) «HEAD расходится с origin/main», маркера нет; D4 — шов 080 →
  «…: SeamAgent». L1 — живая среда omp: список двери ⊇ субагентов моложе 60 с по
  `$PI_CODING_AGENT_DIR` (другая мера); вне omp (CI) — ПРОПУСК, не зелёное.
- П3. когда: `bash fixtures/strazh_088/red_ukazatel_088.sh`; ДО: rc 1, КРАСНО B1 B2 B3 B4 B6 B7 B11,
  ЗЕЛЕНО B0 B5 B8 B9 B13; ПОСЛЕ: rc 0, 12/12. Отказ И-7 и HEAD не сдвинут: B1 нет строки, B2
  укорочена, B3 с хвостом, B4 только во второй «## ГДЕ МЫ», B6 после конца первой секции, B7 индекс
  без строки при исправленном дереве, B11 staged-удаление. Коммит создан: B0 строка в первой
  секции, B5 в подразделе `###`, B8 индекс со строкой при испорченном дереве, B9 HANDOFF.md не
  staged, B13 staged `docs/HANDOFF.md`.
- П4. когда: `bash fixtures/strazh_088/red_stuby_088.sh`; тогда ДО и ПОСЛЕ: rc 0, «стаб-пак 088:
  15/15 поймано, диффпроба 15/15».
- П5. когда: `bash fixtures/_krasnye_088.sh`; ДО: rc 1 (4,2 с); ПОСЛЕ: rc 0; честная симуляция
  (дверь + check_staged.sh, lib_session.sh байт-в-байт) — rc 0 за 4,8 с, L1 зелёная живьём.
- П6. правило: смежные механизмы прежние — итог каждой команды ПОСЛЕ равен ДО; когда: `bash
  fixtures/_krasnye_072.sh` (ДО rc 0), `bash fixtures/dver_bugfiks_080/red_dver_bugfiks_080.sh`
  (ДО rc 0, «честные 31/31»), `bash fixtures/_krasnye_074.sh` (ДО — как в HANDOFF, k5b
  станционная), `bash scripts/verify_antiplacebo.sh --scope check_staged` (ДО rc 1: 33 фикстуры,
  1 расхождение), `bash scripts/verify_antiplacebo.sh --scope orch_restart` (ДО rc 1: 1 фикстура,
  1 расхождение). Оба rc 1 — на 592fc4e и на честной симуляции 088 одинаковы, не предмет 088.
- П7. правило: И-4; когда: `git diff --exit-code 592fc4e -- scripts/lib_session.sh
  ops/server/root/orch-peak`; тогда: rc 0.
- П8. правило: формы черновика; когда: `bash scripts/pre_critic.sh
  contracts/088-v-polete-nichego-dver-i-ukazatel-handoff.md`, `bash scripts/check_threat_model.sh .
  contracts/088-v-polete-nichego-dver-i-ukazatel-handoff.md`, `bash scripts/check_ceilings.sh .`;
  тогда: rc 0.

## Зоны

Живая сверка зон (выполнено этой пачкой; вывод дословно, каждая строка вывода сдвинута на два
пробела — иначе цитата чужих ЗОНА-строк читалась бы lib_zones и гейтом 043 как зоны 088):

```
$ git show frozen/contracts/083/3:contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md | grep '^ЗОНА'
  ЗОНА architect: contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md fixtures/_krasnye_083.sh fixtures/ci_gen_083/red_ci_a_083.sh fixtures/ci_gen_083/diff_verdicts_083.sh fixtures/ci_gen_083/timing_083.sh fixtures/ci_gen_083/.probe-only docs/owner/2026-10-05-a3-pr-vs-push-analiz.md
  ЗОНА implementer: scripts/gen_ci_steps.sh scripts/run_ci_lane.sh registry/ci-steps.tsv .github/workflows/ci.yml package.json scripts/verify_ci_parity.sh
  ЗОНА implementer: scripts/lib_incr.sh scripts/check_charter.sh scripts/check_zones.sh scripts/check_ids.sh scripts/check_protected.sh fixtures/ci_gen_083/do_check_charter_083.txt fixtures/ci_gen_083/do_check_zones_083.txt fixtures/ci_gen_083/do_check_ids_083.txt fixtures/ci_gen_083/do_check_protected_083.txt
$ git show frozen/contracts/085/1:contracts/085-cikl-perezapuska-repo.md | grep '^ЗОНА'
  ЗОНА architect: contracts/085-cikl-perezapuska-repo.md fixtures/ops_server/red_cikl_perezapuska_085.sh fixtures/ops_server/cikl_085/ fixtures/ops_server/red_server_obvjazka_074.sh NABLIUDENIA_ARCHITECT.md
  ЗОНА implementer: ops/server/user/orch-loop ops/server/root/orch-peak ops/server/README.md
$ git show frozen/contracts/086/1:contracts/086-gejty-svedenija-integracii.md | grep '^ЗОНА'
  ЗОНА architect: contracts/086-gejty-svedenija-integracii.md fixtures/_krasnye_086.sh fixtures/gejty_svedenija_086/ fixtures/parsing_hygiene_battery/profiles/gejt_svedenija.sh
  ЗОНА implementer: scripts/gejt_svedenija.sh scripts/accept_task_commit.sh scripts/land_agent.sh scripts/spawn_agent.sh scripts/check_zones.sh scripts/check_charter.sh .githooks/pre-merge-commit
```

Сверка расширена на все живые заморозки (без done-тега: 082/2, 083/3, 084/1, 085/1, 086/1, 087/1):
`scripts/orch_restart.sh`, `scripts/check_staged.sh`, `fixtures/_krasnye_088.sh`,
`fixtures/strazh_088/` — ни в одной; **`.githooks/pre-commit` — в живой зоне implementer 084/1**
(`git show frozen/contracts/084/1:contracts/084-reestr-plana.md | grep '^ЗОНА'`, строка 2):

```
  ЗОНА implementer: scripts/lib_plan.sh scripts/gen_plan.sh scripts/check_plan.sh scripts/track_digest.sh scripts/freeze_contract.sh registry/plan.tsv ROADMAP.md .githooks/pre-commit
```

ЗОНА architect: contracts/088-v-polete-nichego-dver-i-ukazatel-handoff.md fixtures/_krasnye_088.sh fixtures/strazh_088/

ЗОНА implementer: scripts/orch_restart.sh scripts/check_staged.sh

Зона implementer раздаётся ПОСЛЕ заморозки (прецедент 070/078/080/085/086).

ПЕРЕСЕЧЕНИЕ implementer: scripts/orch_restart.sh — 072 done, файл в union исторически; 088 меняет только подключение lib_session.sh и вызов current_session_dir ноги (1), ноги (0), (а)–(д) не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/orch_restart.sh — 080 done, файл в union исторически; 088 меняет только подключение lib_session.sh и вызов current_session_dir ноги (1), ноги (0), (а)–(д) не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 016 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, прочие ветви не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 018 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, страж ветки не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 019 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, делегирование устава не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 023 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, дверь draft-пуска не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 031 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, dual-control не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 049 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, прочие ветви не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_staged.sh — 080 done, файл в union исторически; 088 добавляет одну проверку перед ранними выходами, ногу (д') не трогает

РАБОТА НЕ РАЗДАЁТСЯ: `.githooks/pre-commit` (живая зона 084/1; правка не нужна —
§Незаполненные требования, О-1); CI-шаг батареи (`.github/workflows/ci.yml`,
`registry/ci-steps.tsv` — живые зоны 083/3, 084/1, 087/1) — после их лендинга словом
оркестратора; `scripts/lib_session.sh` и `ops/server/root/orch-peak` — И-4.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/_krasnye_088.sh
ПРОВОДКА-ЭНФОРСМЕНТ: предмет — механизм двух точек (нога (1) двери, pre-commit-суд HANDOFF.md) и их батарея; норм-строк ролей нет — норма «маркер при живых субагентах запрещён» (roles/orchestrator.md:427) и «строка-указатель в первой секции» (Н-NEW-9) получают механизм без правки текста. CI-шаг батареи — в зонах живых заморозок 083/084/087 (прецедент 086); до подключения потребитель guard-строки — строки приёмки П1-П8.

## Остаточный риск

- L1 судима только из живого субагента omp: вне omp и без субагента моложе 60 с — пропуск;
  D-клетки держат логику детерминированно, L1 — дрейф раскладки omp.
- Окно 120 с: субагент в вызове инструмента дольше окна невидим двери (признак 080).
- PTR_088 читается из фикстуры 074: правка строки HANDOFF_PTR там без правки check_staged.sh
  краснит B0/B1 — так и задумано, правка — architect.

## Незаполненные требования:
- О-1 (форк консультанту, решение не за architect): `.githooks/pre-commit` в живой зоне implementer 084/1; предложение — 088 хук НЕ правит, точка входа остаётся `scripts/check_staged.sh`, которую хук уже вызывает (`exec`); честная симуляция без правки хука зелёная 12/12 B-клеток; если 084 изменит хук так, что `check_staged.sh` не вызывается, — B1 красна на ленде второго.
- О-2 (вне предмета, отдельный номер): ветка 600K orch-peak — `current_session_dir` из lib_session.sh переопределяет локальную (строки 152 → 165-167), умолчание глоба от `$HOME` процесса root; [INFERENCE] под root глоб пуст и ожидание субагентов `ORCH_HARD_GRACE` не исполняется (под root не прогонялось).
- О-3 (вне предмета): окно «живого» у двери 120 с (lib_session.sh), у сторожа простоя 300 с (`SUB_LIVE`) — два признака одного свойства.

accept
OBJECT=db02e83242822f75e44593c9d61fbfd7dc81a0da
СУД: один scoped reviewer по Б-4, вызов 2 (scoped-повтор в базовом бюджете; слово владельца 21.11; класс 095 обычный); роль=reviewer; сессия=Rev095B4b; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии); SHA=db02e83242822f75e44593c9d61fbfd7dc81a0da; прежний вердикт=archive/095/reviewer-b4-fail-13b845d263 (13b845d2630c40c609392c3e74668c9ac91c2b10):verdicts/review/contracts-095-impl-v1.md — FAIL по OBJECT f352937cf89936a97df081ff0dd1656ed97fe3aa; класс задачи=кодовый; класс риска=обычный (не повышал, не понижал); PR a3ka/dev-harness#1224, wip/int-095/orch-b4t; советы=.review/2026-11-22-136.md.

ПОМЕТКА О ВЕРСИИ. В main (947facdff3) нет `verdicts/review/*095*`: `git ls-tree --name-only 947facdff3 verdicts/review/ | grep 095` → пусто. v1 (FAIL вызова 1) живёт только в архивной ветке станции. Этот файл — v2, суд вызова 2 по новому OBJECT.

ИТОГ: accept. Все четыре блока вызова 1 закрыты, и это видно на OBJECT. Прямой вызов резолвера на `pack={maxBytes:130000,rowz:1}` даёт rc 0, ровно одно предупреждение о `pack.rowz` в stderr и stdout без `rowz`. Батарея М-0 зелёная: 48/0. Каждый из четырёх ремонтных мутантов краснит свою клетку. Область правки чистая. Потребители М-0 на профиле с `pack.maxBytes` ведут себя так же, как на чистом профиле. Остались советы С-1…С-5 и перенесённые из вызова 1 С-1…С-5 (`.review/2026-11-22-136.md`). Слияние они не блокируют.

ИДЕНТИФИКАЦИЯ. pwd копии: /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t200aa011f/m. TMPDIR=<pwd>/.scratch-rev095b4b (вне коммита, перед докладом удалён).
  `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/095/orch-b4t` → FETCH_HEAD = db02e83242822f75e44593c9d61fbfd7dc81a0da. `git switch --detach db02e8324…`, затем `git rev-parse HEAD` → db02e83242822f75e44593c9d61fbfd7dc81a0da (= OBJECT).
  Граф. db02e8324 (orchestrator) — merge 88effccb1 + bedaa57e1 (a=c=architect, Arch184M0e). 88effccb1 (orchestrator) — merge 947facdff3 + ee356ddde (a=c=implementer), над ним 573456a1c (a=c=architect), над ним f352937cf. Своих правок у merge-коммитов нет: `git show --cc --format= 88effccb1 | wc -l` → 0, `git show --cc --format= db02e8324 | wc -l` → 0.
  Неподгонка. ee356ddde меняет только scripts/profile_resolver.sh (14 строк). 573456a1c меняет только fixtures/_krasnye_095.sh и fixtures/context_pack_095/* (7 файлов). bedaa57e1 меняет только m0_probe.py и sdacha_m0.md. Implementer клеток не трогал, architect не трогал двери (`git show --stat` каждого коммита).

══ ОБЛАСТЬ ══
`git diff --name-status 947facdff3 db02e83242` → 16 путей:
  M fixtures/_krasnye_095.sh;
  fixtures/context_pack_095/: A SDACHA_pack_maxbytes.md, M _toy.sh, M battery_stubs.sh, M model/dover.sh, A pack_maxbytes_probe.py, A red_pack_maxbytes{,_bez_preduprezhdenija,_boundary,_brief,_merged,_values}.sh;
  M fixtures/workshop_project/external_connection_184/{m0_probe.py,sdacha_m0.md};
  M scripts/make_task.sh; M scripts/profile_resolver.sh.
Всё лежит в объявленной области задания, посторонних путей нет. registry/, contracts/, docs/, roles/ и .github/ не тронуты: `git diff --stat 947facdff3 HEAD -- registry/` пуст. Шаг CI `check:context-pack-095-family-selftest` (registry/ci-steps.tsv:240, `bash fixtures/_krasnye_095.sh`) уже был в main и не менялся.

══ ЗАКРЫТИЕ БЛОКОВ ВЫЗОВА 1 (наблюдение на OBJECT) ══

Б-1 — ЗАКРЫТ. Клетка values (fixtures/context_pack_095/pack_maxbytes_probe.py:124-136, вход :128) ждёт на `{"maxBytes":130000,"foo":1}` rc 0 и пак по капу 130000. Модель (fixtures/context_pack_095/model/dover.sh:122-129, строка предупреждения :128-129) печатает предупреждение и не отказывает.
  `bash fixtures/_krasnye_095.sh` → rc 0: «B4 values unknown key warned (M-0) and pack issued by declared cap; …», «— red_pack_maxbytes_values.sh: rc=0», «ИТОГ 095: rc=0».
  `bash fixtures/_krasnye_095.sh --model` → rc 0, «ИТОГ 095: rc=0».
  Мутанты ниже: дверь «предупреждение → отказ» и модель «предупреждение → refuse» краснят клетку values.

Б-2 — ЗАКРЫТ. scripts/profile_resolver.sh:1065: `{ value: ($r.pack | with_entries(select(.key == "maxBytes"))), origin: "repo" }`. Комментарии :211-215, :901-905 и :1057-1063 описывают предупреждение и rc 0.
  Своя проба: одноразовый toy-мир `_t95_world` и прямой вызов `HARNESS_PROJECT_LAYER_ROOT=<W>/repo bash scripts/profile_resolver.sh --repo <W>/repo`, stdout и stderr пишутся в разные файлы.
    pack={"maxBytes":130000,"rowz":1} → rc=0. stderr — 1 строка `профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack.rowz`. stdout `.pack` = {"value":{"maxBytes":130000},"origin":"repo"}, `grep -c rowz` → 0.
    pack={"rowz":1} → rc=0, та же одна строка, `.pack` = {"value":{},"origin":"repo"}, rowz 0.
    pack={"maxBytes":130000} → rc=0, stderr 0 строк, `.pack` = {"value":{"maxBytes":130000},"origin":"repo"}.
    pack={} → rc=0, stderr 0 строк, `.pack` = {"value":{},"origin":"repo"}. pack отсутствует → rc=0, stderr 0 строк, `.pack` = null.
  Клетка fixtures/context_pack_095/red_pack_maxbytes_merged.sh → rc 0, «B4 merged pack.value только maxBytes; предупреждение одно; rc 0».

Б-3 — ЗАКРЫТ. Батарея М-0 больше не берёт `pack.maxBytes` за неизвестный ключ: теперь это `zzprobe.maxBytes`, неизвестный корень (m0_probe.py:64-68, 105-107, 282-284, 316, 326, 335, 372, 413-416, 517, 531-532).
  `bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --repo . --m0` → rc 0: M0_CELLS=31 GREEN=31 RED=0; M0B_CELLS=14 GREEN=14 RED=0; M0D_CELLS=3 GREEN=3 RED=0. Итого 48/0.
  Расширение зоны из вызова 1 закрыто: путь external_connection_184/{m0_probe.py,sdacha_m0.md} объявлен в области задания вызова 2.

Б-4 — ЗАКРЫТ. Клетка fixtures/context_pack_095/red_pack_maxbytes_bez_preduprezhdenija.sh вызывает резолвер напрямую, потоки раздельные. Она требует 0 строк `ПРЕДУПРЕЖДЕНИЕ` и `.pack.value.maxBytes == 130000`. Стаб B4-S9 (fixtures/context_pack_095/battery_stubs.sh:204-208) снимает якорь `^  repo:pack:maxBytes:optional$` прямо в коде (Н-39). На OBJECT клетка → rc 0. Мутант M7 своей мерой ниже → КРАСНЫЙ.

══ МУТАНТЫ (одноразовая копия `git archive HEAD | tar -x` в scratch, по одному; файл между мутантами восстанавливался `cp` и сверялся `cmp`; копия удалена) ══
Каждая порча — точная литеральная замена (якорь встречается ровно 1 раз). После порчи `bash -n` → rc 0. Клетки запускались из копии (ROOT = копия).
  M-pack-целиком (scripts/profile_resolver.sh:1065 → `{ value: $r.pack, origin: "repo" }`). Клетка red_pack_maxbytes_merged.sh → rc=1, «КРАСНО: pack-maxbytes/merged: неизвестный ключ pack.rowz в stdout merged». Проба: stdout `.pack` = {"value":{"maxBytes":130000,"rowz":1},…}. bez_preduprezhdenija и values → rc 0 (эти свойства мутант не задевает). КРАСНЫЙ.
  M7 (удалена строка `  repo:pack:maxBytes:optional`, :217). Клетка red_pack_maxbytes_bez_preduprezhdenija.sh → rc=1, «КРАСНО: pack-maxbytes/bez-preduprezhdenija: предупреждение о известном ключе pack.maxBytes: профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack.maxBytes». Клетка merged → rc=1, «предупреждений 2, ожидается ровно одно». red_pack_maxbytes.sh и values → rc 0. Проба: 1 строка о pack.maxBytes. КРАСНЫЙ (в вызове 1 выжил).
  «Предупреждение заменено отказом» (в warn_unknown вставлено `case "$2" in pack.*) die_p "неизвестный ключ $1: $2" ;; esac`). merged → rc=1, «отказ rc=1: profile ОТКАЗ: неизвестный ключ репо-слой: pack.rowz». values → rc=1, «успех rc=1: ОТКАЗ: неизвестный ключ репо-слой: pack.foo». bez_preduprezhdenija → rc 0. КРАСНЫЙ.
  Тот же отказ в модели (dover.sh: `print('профиль ПРЕДУПРЕЖДЕНИЕ…` → `refuse(…)`, CP095_MODE=model, CP095_SUBJECT=<копия>/model/dover.sh). values → rc=1 «…pack.foo», merged → rc=1 «модель отказалась rc=1». КРАСНЫЙ: возврат Б-1 в модели тоже ловится.
  «zzprobe → pack в m0_probe.py» (замена 20 вхождений, то есть содержимое до bedaa57e1). `red_external_connection_184.sh --repo <копия> --m0` → rc=1. M0 31/0. M0B 12/2: RED m0-b1g-warning-repo, m0-b1d-merged-repo. M0D 1/2: RED m0-b3a-pty-terminal, m0-b3a-pty-split. Это ровно четыре клетки Б-3 вызова 1. КРАСНЫЙ.

══ ПОТРЕБИТЕЛИ М-0 НА ПРОФИЛЕ С pack.maxBytes (п.4 задания) ══
Тот же мутантный прогон «zzprobe → pack», в котором грязный ключ — `pack.maxBytes` = 40000. Клетки потребителей m0-b1a-ci-{repo,project} (gen_ci_workflow.sh), m0-b1b-merge-{repo,project} (check_merge_gate.sh) и m0-b1v-connection-{repo,project} (check_project_connection.sh) → «ok (subject_rc=0)», все шесть. Судья клетки (m0_probe.py judge_m0b) требует, чтобы (rc, stdout, workflow) побайтно совпали с замороженным чистым оракулом m0b_baseline.json, а stderr был пуст либо равен строке предупреждения.
Повтор со значением 130000 (`target['pack'] = {'maxBytes': 130000}`): те же шесть клеток → ok (subject_rc=0). Потребители на профиле с `pack.maxBytes` ведут себя как на чистом.

══ СЫРОЙ ВЫВОД (OBJECT, по одной команде, TMPDIR=<pwd>/.scratch-rev095b4b) ══
  `bash fixtures/_krasnye_095.sh` → rc 0. «STABS 095: CAUGHT=40 LIVE=0», «— battery_stubs.sh: rc=0», 25 строк «— red_*.sh: rc=0», «ИТОГ 095: rc=0» (wall 100.5 с).
  `bash fixtures/_krasnye_095.sh --model` → rc 0. «ИТОГ стаб-пак 095: rc=0», 25 клеток rc=0, «ИТОГ 095: rc=0».
  `bash fixtures/_krasnye_095.sh --stabs` → rc 0. «STABS 095: CAUGHT=40 LIVE=0», «ИТОГ стаб-пак 095: rc=0».
  `bash fixtures/_krasnye_054.sh` → rc 0. «честная часть: проверено предъявлений 37», «054-батарея зелёная», «итог 054: rc=0».
  `bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --repo . --m0` → rc 0: 31/31/0, 14/14/0, 3/3/0.
  `… --m0 --model` → rc 0: 31/31/0, 14/14/0, 3/3/0. Задание пишет эту форму с `--repo .`, и тогда раннер даёт rc 2 «argument --model: not allowed with argument --repo». Засчитана форма без `--repo` (совет С-5).
  `… --m0 --stabs` → rc 0: M0_STABS=8 LIVE=0, M0B_STABS=4 LIVE=0, M0D_STABS=3 LIVE=0.
  `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → rc 0, «итог 4/4 классов закрыто».
  `bash -n scripts/profile_resolver.sh` → rc 0. `bash -n scripts/make_task.sh` → rc 0.
  Счётные утверждения проверены своей мерой.
    «25 клеток»: `ls fixtures/context_pack_095/red_*.sh | wc -l` → 25.
    «CAUGHT=40»: в battery_stubs.sh 40 вызовов стабов (`grep -cE '^(zapest|zapest_resolver) '` → 40: zapest 38 + zapest_resolver 2).
    «66 строк «— »» в SDACHA: 26 строк раннера (battery_stubs + 25 клеток) + 40 ПОЙМАН = 66. Совпадает.
    «48/0» в sdacha_m0.md: 31+14+3 = 48, RED 0. Совпадает.

ОСТАТОК: в контракте 095 нет строк «НЕ ЗАЩИЩАЕТ» с ловцом reviewer и номером К-NN (contracts/095-profil-i-vhod-agenta-contextpack.md:133-136, 198-201 — без ловца и без К-NN). Проверять нечего.

СВЕРКА-АРХИТЕКТУРЫ:
  Размещение не изменилось. Ключи pack судит единственный резолвер: SCHEMA :216-217, значения :901-930, merged :1064-1067. make_task берёт кап только из MERGED (:582).
  Ремонт добавил одну проекцию `with_entries` в merged. Это та же форма, что у contextPack (:1043), отдельной ветви нет.
  Новых зависимостей (jq, bash, python3 в фикстурах — как прежде) и новых писателей состояния нет. Операции, `bindings.json` и потребители резолвера не тронуты.
  Долг не расширен: батарея М-0 сменила только канонический ключ, привязки стабов Н-39 те же (M0 8, M0B 4, M0D 3, LIVE 0).
  `tooling/checks/cli.js` в дереве нет (`ls` → нет файла). Расхождения модели и работы не найдено, находка не заводилась, diff модели L0.
СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (`grep -c` → 0), сверять не с чем. «Заявлено = сделано»: шапка М-0 :222-228 и комментарии :211-215, :901-905, :1057-1063 совпадают с наблюдением. Неточность одна: в :1061 написано «как defaults.contextPack ниже», а contextPack стоит выше, на :1043 (С-1).
ПРОВОДКА (038): дельта не вводит поведенческой нормы и канала роли, неприменимо. sourceCanon (996): harness.project.json его не объявляет (`grep sourceCanon` → 0), неприменимо.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), только новое или раздутое в ремонте после вызова 1. Пять вопросов: (1) свойство; (2) состояние; (3) файлы, меняющиеся вместе; (4) глубина; (5) потребитель или повтор логики.
  Проекция `with_entries(select(.key == "maxBytes"))` (profile_resolver.sh:1065).
    (1) М-0: merged перечисляет только известные листы (Б-2). (2) Нет. (3) 1 файл; при новом ключе pack меняются SCHEMA и проекция, как у contextPack. (4) Интерфейс не вырос. (5) Клетка merged и стаб B4-S8; повторяет уже живую форму :1043.
    ESSENTIAL.
  Клетки red_pack_maxbytes_merged.sh и red_pack_maxbytes_bez_preduprezhdenija.sh (одна семья).
    (1) Закрывающие свойства Б-2 и Б-4 требуют прямого вызова: make_task прячет stderr резолвера (make_task.sh:569-572). (2) Одноразовый мир под TMPDIR, оракул в памяти. (3) Клетки, census раннера, стаб-пак. (4) Флагов нет; env CP095_RESOLVER и CP095_MODE видны в вызове. (5) `_krasnye_095.sh`, шаг CI :240.
    ESSENTIAL.
  `zapest_resolver` (battery_stubs.sh:56-84, функция :62-84).
    (1) Стабы двери, привязанные к коду (Н-39), LIVE 0. (2) Копия резолвера в $WORK, явно передаётся через CP095_RESOLVER. (3) 1 файл + целевые клетки. (4) 6 позиционных аргументов, как у `zapest`. (5) `--stabs`. Учёт caught/live повторяет `zapest` (~10 строк), но субъект другой: дверь, а не модель.
    ESSENTIAL. Повтор — не находка: более простой формы, которая проходит те же строки и не смешивает субъекты, не видно.
  `export CP095_MODE` (_krasnye_095.sh:45).
    (1) Без него клетки двери в `--model` судили бы реальный резолвер, а не модель-эталон. (2) Явная env раннера. (3) Раннер + 2 клетки. (5) `--model`.
    ESSENTIAL.
  Замена ключа в m0_probe.py. Нового артефакта нет, 16 строк переименования. (1) Ключ батареи обязан остаться неизвестным после Б-4.
    ESSENTIAL.
  SDACHA_pack_maxbytes.md и sdacha_m0.md — сдаточные листы, состояния не вводят. Счётные строки сверены выше.

АТОМАРНОСТЬ: Б-2 — один коммит implementer (ee356ddde). Б-3 — один коммит architect в зоне 184 (bedaa57e1). Б-1 и Б-4 (клетки) и клетка двери для Б-2 собраны в одном коммите architect 573456a1c: один круг ремонта одной зоны по одному вердикту, со ссылкой на 13b845d263. Принято, это совет С-4.

НОРМА: contracts/, roles/, docs/ в дельте не тронуты.

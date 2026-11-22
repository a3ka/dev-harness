# СДАЧА 140 — К-03б (A2e, FAIL Adv140A2b); предыдущие исправления сохранены

## A2f: матрица недоступности (К-03б — общее закрытие, слово владельца 22.11 ~12:09)

OBJECT: `5f31ee3dc11311a212eae7350cad3e7b45056192` (wip/int-140/orch-sh2f).
Вердикт: `archive/140/adversary-a2c-fail-f65b05da10:verdicts/adversary/contracts-140-v12.md`.
Дверь `scripts/zamok_predmeta.sh` и контракты этой пачкой НЕ меняются:
правка двери — отдельный шаг implementer; здесь клетки, модель и стабы.

§Существующее: `reestr_140.py` (r01–r19, k03b01–k03b07 — недоступность
ЗАПИСИ профиля), `probe.Mir`/`sudit`/`snimok_fajlov`, настоящий
`project_paths_resolve` с его гардами (вне репо, алфавит workflowPaths,
FALLBACK-NO-WORKFLOW). Всё переиспользовано, новый парсер не вводится.
Новое — одна таблица данных `matrix_nedostupnosti` в
`matrix_nedostupnosti_140.py` (клетка на строку, 20 строк) и её прогонщик.

Обещание: источник паузы читается ТРЁХЗНАЧНО. ЕСТЬ — читаемый файл,
цель всех ссылок внутри репо; НЕТ — лист заведомо отсутствует по
ЗАМКНУТОМУ правилу (`-e`/`-L` ложь по листу и вся цепочка родителей до
корня репо — настоящие каталоги без ссылок, с правом обхода); НЕДОСТУПНО —
любое иное состояние → rc 1 `PROFIL_NEDOSTUPEN`, учёт пуст, санкция PAUZA
не расходуется (строка события входит в миры «плохих» строк и обязана
остаться нетронутой). Чтение — одним открытием. Наблюдение: rc,
самостоятельная строка отказа, побайтовая неизменность состояния;
оракул снят в память до вызова двери.

| клетка | форма | rc на OBJECT | после ремонта модели |
|---|---|---|---|
| n01-registry-dangling | `.x/reg` → висячий симлинк | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| n02-registry-cycle | `.x/reg` → цикл | 1 PROFIL_NEDOSTUPEN — уже честна | тот же отказ |
| n03-registry-external-symlink | `.x/reg` → вне репо | 1 PROFIL_NEDOSTUPEN — уже честна | тот же отказ |
| n04-parent-dangling | `.x` → висячий симлинк | 1 PROFIL_NEDOSTUPEN — уже честна | тот же отказ |
| n05-parent-cycle | `.x` → цикл | 1 PROFIL_NEDOSTUPEN — уже честна | тот же отказ |
| n06-pause-dangling | pauzy.tsv → висячий симлинк | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| n07-pause-cycle | pauzy.tsv → цикл | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| n08-pause-directory | pauzy.tsv — каталог | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| n09-pause-chmod000 | pauzy.tsv chmod 000 | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| n10-registry-dir-chmod000 | `.x/reg` chmod 000 | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| n11-registry-empty-string | registry = "" | 1 (вне алфавита резолвера) | тот же отказ |
| n12-registry-number | registry = 42 | 1 (вне алфавита) | тот же отказ |
| n13-registry-array | registry = [".x/reg"] | 1 (вне алфавита) | тот же отказ |
| n14-registry-dotdot | registry = ../outside | 1 (вне репо) | тот же отказ |
| n15-registry-absolute-outside | registry = абсолютный вне репо | 1 (вне репо) | тот же отказ |
| n16-contracts-dangling | contracts.tsv → висячий симлинк | 1 PAUZA_VLADELTSA — честна | тот же отказ (охр.) |
| n17-profile-dangling | запись профиля → висячий симлинк | 1 PROFIL_NEDOSTUPEN — честна (прежний К-03б) | тот же отказ |
| n18-profile-invalid-json | запись = {broken | 1 PROFIL_NEDOSTUPEN — честна (r14) | тот же отказ |
| n19-profile-without-workflowpaths | профиль без workflowPaths | 0 PUSCHEM + START — честна | тот же допуск (охр.) |
| n20-race-chitaem-potom-ischez | пауза исчезает между проверкой и чтением | 1 PAUZA_VLADELTSA — честна | тот же отказ (охр.) |

Развилки (выбор по коду, ожидания зафиксированы явно):
· n19: по коду `scripts/next_id.sh:393-419` (FALLBACK-NO-WORKFLOW) профиль
  без объявленных ключей — НЕ битый профиль: реестр — дефолтный registry/,
  в нём пауз нет → rc 0 START с собственным START в учёте. Замкнутое
  правило НЕТ живо и без объявления workflowPaths.
· n09/n10 (chmod 000): эффективные права ОС, прецедент k03b05 — если 000
  не запрещает текущему uid, клетка печатает SKIP и доказательством не
  служит; в этом прогоне запрещает (uid не root), пропусков не было.
· n20: подменяемая обёртка `cat` в PATH мира удаляет pauzy.tsv при чтении
  именно его; модель читает ОДНИМ открытием (перенаправление), cat не
  вызывает → пауза судится rc 1 PAUZA_VLADELTSA. Ловит s102 (проверка и
  чтение раздельно). Исчезновение листа ДО проверки — не гонка, а
  замкнутое правило НЕТ (n19); обе стороны покрыты раздельными клетками.
· n16: контрактный файл реестра не участвует в суде паузы — ожидание
  rc 1 PAUZA_VLADELTSA (та же картина в пробах вердикта v12).
· n02–n05, n11–n15 уже fail-closed на OBJECT (гарды резолвера) — охрана
  регресса, не выдуманная краснота (Н-39).

Стабы (Н-39, привязки — только код `matrix_nedostupnosti_140.BINDINGS`
→ source.json:.stab_vhod): s99-pauza-r — «`[ -r "$f" ] || return 1`»
(поведение OBJECT внутри единой функции) красит n01/n06/n08;
s100-pauza-L — проверка симлинка только на листе → n01;
s101-pauza-second — цикл :1081 читает мимо единой функции → n01/n06;
s102-pauza-race — чтение через cat (второе открытие) → n20;
s103-pauza-warn — недоступно → предупреждение + START → n01/n06;
s104-pauza-all — fail-closed для adversary/critic без автора, нарушение
«предупреждения» К-02 (охранный) → r12/r13. s15-bez-pauzy перепривязан
к восстановленному телу [D63] (прежний якорь «[ -r ] || return 1» ушёл из
модели вместе с дефектом); семантика прежняя, красит w10-pauza.
Честные эквиваленты адресно зелёны (8 пар: s99×k03b06/n16/n19,
s100×k03b07, s101×w10, s102×w10, s103×k03b07, s104×r11 — CELL_RC 0).

Счёт семьи: W 222 → 242 (динамические 221 → 241); стабы 99 → 105,
связи 185 → 196, носители 104 → 110, sintaksis 100 → 106. Прежние клетки
не удалены и не переименованы; --domain (r-семья) 19/0 без изменения.

Сырой адресный замер двери OBJECT и модели — командой
`python3 fixtures/workshop_project/odin_agent_140/matrix_nedostupnosti_140.py`
(rc/stdout/stderr/ledger на каждую форму). Независимое воспроизведение
блока вердикта на OBJECT выполнено ДО правок сырыми пробами в scratch
(вывод — в докладе сдачи); scratch удалён до коммита.

Фактическая приёмка (последовательно, `TMPDIR="$PWD/.scratch-a2f"`,
`PYTHONDONTWRITEBYTECODE=1`; боевой замок и реальные журналы НЕ
запускались — только песочницы батареи):

| команда | rc | наблюдённый итог |
|---|---|---|
| W (безфлагово) | 1 | KLETKI 242 KRASNYH 6 — красны РОВНО n01,n06,n07,n08,n09,n10; прежние 236 зелены |
| W --model | 0 | MODEL_KLETKI 241 KRASNYH 0 |
| W --stabs | 1 | SVJAZI 196, MODEL_ZHIVYH 0; s99–s104 и s15 пойманы каждый своим входом; SUBJEKT_KRASNO: 6 (до правки двери) |
| W --domain | 0 | KLETKI 19 KRASNYH 0 |
| W --grammar | 0 | CASE r10-sh2-bez-literalov ok |
| W --sintaksis | 0 | SINTAKSIS FILES 106 |
| bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta | 0 | итог 4/4 классов закрыто |
| bash -n scripts/zamok_predmeta.sh | 0 | дверь дерева не менялась |
| bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo | 0 | проба обрыва + merge зелены на чиненой модели |
| bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --stabs | 0 | якоря 167 живы после [D63] |
| python3 fixtures/workshop_project/obryv_167/merge_probe.py --repo | 0 | merge_167 зелёный |
| bash scripts/check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run | 0 | СДАЧА: лист зелёный (двери=17 карта=17/17 дельта=4) |

Строки «Двери» W-stabs/W-production переведены в честное до-реализационное
состояние (1 · 1: субъект красен ровно на шести новых клетках) — этого
требует фактический rc `check_sdacha --run` на данном шаге; после правки
двери implementer они возвращаются к 0 · 0 по пункту 3 приёмки
frozen 140/5 (прецедент A2c). Матрица над production до исправления двери
не исполняется: существующий контроль слоя останавливает её на
SUBJEKT_KRASNO: 6; это не зелёная production-матрица и не замена
дальнейшему прогону ведущего.

## К-03б (FAIL Adv140A2b)

OBJECT: `14e3fb2ac987e6e56c2feff9d4226ea46acd02ab`.
Вердикт: `44b1d32ac99c878553191464e5c8af5bf2a4d237`,
`archive/140/adversary-a2b-fail-44b1d32ac9:verdicts/adversary/contracts-140-v11.md`.
Существующее: `reestr_140.py` r14/r15, `probe.Mir`, реальный `--sudit`,
снимок состояния до вызова и настоящий `project_paths_resolve`.
Они переиспользованы; production и frozen-контракт не менялись.

Обещание: резервный registry/ допустим только при полном отсутствии
пути harness.project.json. Существующая нечитаемая запись — rc 1,
самостоятельная строка `ОТКАЗ: PROFIL_NEDOSTUPEN:`, без START/override.
В новых мирах корректный профиль сначала находится за симлинком,
пауза 140 — только в .x/reg/pauzy.tsv, резервный registry/ пуст.
После построения мира изменяется одна форма записи. Оракул rc/причины
и снимок долговечных файлов взяты в память до вызова двери.

| клетка | форма | rc на OBJECT | rc после исправления модели |
|---|---|---|---|
| k03b01-profil-dangl-symlink | цель симлинка удалена | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| k03b02-profil-cikl-symlink | ссылка сама на себя | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| k03b03-profil-katalog | каталог вместо файла | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| k03b04-profil-symlink-na-katalog | ссылка на каталог | 0 PUSCHEM + START — красна | 1 PROFIL_NEDOSTUPEN, учёт пуст |
| k03b05-profil-bez-prav | ссылка на файл 000, uid=1004 | 1 PROFIL_NEDOSTUPEN — уже честна | тот же отказ, учёт пуст |
| k03b06-profil-valid-symlink-pauza | валидный симлинк, пауза 140 | 1 PAUZA_VLADELTSA | тот же отказ, учёт пуст |
| k03b07-profil-valid-symlink-bez-pauzy | валидный симлинк без паузы | 0 PUSCHEM, собственный START | тот же допуск |
| прежние r03/r08/r09 | самого пути профиля нет | прежний допуск/пауза из registry/ | без изменения |

Развилка задания: no-perm на OBJECT уже даёт честный именованный отказ,
поэтому k03b05 — охрана регресса, не выдуманная краснота OBJECT (Н-39).
Права проверяются через effective_ids до двери; если 000 не запрещает
чтение текущему uid, клетка печатает SKIP с причиной. В этом прогоне
Permission denied получен реально; пропуска не было.
Новые имена k03b сохраняют прежний `--domain` (r-семья, 19 клеток);
новая семья целиком входит в W, --model и --stabs.

Привязки трёх стабов задаёт только код `reestr_140.BINDINGS`, носители
производит `--sgeneriruj-staby`: s96 (S-dangl, прежний `[ -f ]`),
s97 (S-any, резерв при любой ошибке чтения), s98 (S-all, ложный отказ
при полном отсутствии профиля). Необязательная по effective-правах
k03b05 не используется как доказательство обязательной гибели стаба.
Соседняя битая JSON-форма r15 различает S-any независимо от прав.

Адресные прогоны всех новых клеток на модели подтвердили столбец «после»;
production после исправления здесь не предъявляется. Для implementer
критерий — те же наблюдения на scripts/zamok_predmeta.sh.
Сырой вывод OBJECT воспроизводится существующей командой
`python3 fixtures/workshop_project/odin_agent_140/reestr_140.py`;
ниже также записан адресный замер модели:

```text
OBJECT k03b01-profil-dangl-symlink
RAW rc=0 stdout='PUSCHEM ProfileEntry140 dev-harness/140 (rabochij/architect)\n' stderr='' ledger=[{'t': 'START', 'repoId': 'dev-harness', 'subjectId': '140', 'group': 'harness', 'holder': 'ProfileEntry140', 'klass': 'rabochij', 'rol': 'architect', 'object': '-', 'worktree': '/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/te653b8da3/m/.scratch-a2e/odin140-9806j9fo/wt140', 'branch': 'wip/140/avtor', 'at': '2026-11-22T02:17:06Z', 'isolated': True}]
MODEL k03b01-profil-dangl-symlink
RAW rc=1 stdout='' stderr='ОТКАЗ: PROFIL_NEDOSTUPEN: путь реестра паузы предмета 140 не удостоверен\n' ledger=[]
CELL_RC=0 errors=[]
```

Фактическая приёмка A2e выполнена последовательно в своей копии
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/te653b8da3/m`,
с TMPDIR="$PWD/.scratch-a2e" и PYTHONDONTWRITEBYTECODE=1.
В таблице W — `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh`.

| команда | rc | наблюдённый итог |
|---|---|---|
| W | 1 | KLETKI 222 KRASNYH 4; красны ровно k03b01–k03b04, прежние 215 зелены |
| W --model | 0 | MODEL_KLETKI 221 KRASNYH 0 |
| W --stabs | 1 | SVJAZI 185, MODEL_ZHIVYH 0; s96/s97/s98 пойманы; SUBJEKT_KRASNO: 4 |
| W --domain | 0 | KLETKI 19 KRASNYH 0 |
| bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta | 0 | итог 4/4 классов закрыто |
| W --sintaksis | 0 | SINTAKSIS FILES 100 |

Честные эквиваленты адресно проверены и под мутациями: s96 — no-perm,
валидный симлинк с паузой/без неё и отсутствие профиля r03/r08;
s97 — обе валидные ссылки и r03/r08; s98 — все новые формы.
Каждый такой вход дал CELL_RC=0/errors=[].
Матрица над production до исправления двери не исполняется:
существующий контроль останавливает её на SUBJEKT_KRASNO: 4.
Это не зелёная production-матрица и не замена дальнейшему прогону ведущего.

Счёт семьи: W 215 → 222, динамические клетки 214 → 221;
стабы 96 → 99, связи 174 → 185, носители 101 → 104,
синтаксические носители 97 → 100. Счёт source.json независимо подтверждён
jq и обходом исполняемой батареи. Новых LIVE-клеток нет (0).
Строки «Двери» 0·0 оставлены после-реализационными и не откатывались.
check_sdacha/pre_critic в этой дельте не запускались: их исполняет ведущий
после реализации; судья в этом вызове не вызывался. Scratch удаляется до
коммита, скрипт последовательного замера и его логи не поставляются.

Рефлексия процесса: адрес WORKTREE был ошибочно принят мной за свою
копию в начале вызова; ведущему сообщено. Сдаточный коммит создаётся
только в собственной te653b8da3/m, не в delivery. Общий журнал А-NNN
не меняется: вне зоны и допускает запись только коммитом main.

## Исправление FAIL Adv140A2

OBJECT: `60463b6dab6407b30de4f2d33ec989069e71f412`.
База продолжения: `5a458a6f7a75a94761226fe956ea6a34a23657df`.
Вердикт: `ee9dd0af773db495dc40bcb2bcfb695ef2249f60`,
`verdicts/adversary/contracts-140-v10.md` в архивном ref станции.
Production, frozen-контракт и чужие зоны не меняются.

§Существующее: `probe.Mir`, `m.sobytie`, `p.item`, `p.sudit` и
`p.snimok_fajlov` дают независимые .git-миры, реальный --sudit и снимок
состояния ДО вызова. `reestr_140.py` строит профиль и pin frozen;
`uproshchenie_140.py` проверяет разовую санкцию o01-pauza-once/bound.
Переиспользован настоящий project_paths_resolve, новый парсер не введён.

Обещание: отсутствие автора не отменяет порядок reviewer/adversary;
ошибка чтения профиля не снимает паузу; некорректный дубль общей строки
не расходует санкцию; каталог frozen берётся из workflowPaths.contracts.
Наблюдение: rc/именованный отказ, START/warn/override и побайтовая
неизменность долговечных файлов при отказе. Ожидания снимаются до двери.

| блок / клетка | rc двери на OBJECT | rc честной модели после исправления |
|---|---|---|
| К-02 / r11-noauthor-reviewer | 0, START reviewer — красен | 1 ADVERSARIJ_DO_REVJUERA, без записей |
| К-02' / r12-noauthor-adversary, r13-noauthor-critic | 0, RABOCHEGO_NET + START | тот же 0 + warn + START |
| К-03 / r14-profile-broken-pauza | 0, START при паузе — красен | 1 PROFIL_NEDOSTUPEN, без записей |
| К-03' / r15-profile-broken-bez-pauzy | 0, START — красен | 1 PROFIL_NEDOSTUPEN, без записей |
| К-04 / r16-override-dubl-extra, r17-override-dubl-object | 0, override + START — красны | 1, без расходования override и записей |
| К-04' / прежние o01-pauza-once/bound | 0, одна санкция + START; повтор 1 | прежнее поведение |
| К-05 / r18-kontrakty-profil-obychnyj | 0; мутант contracts: 1 — красен | 0, START, без KLASS_RISKA_NET |
| К-05 / r19-kontrakty-profil-riskovyj | 1; мутант contracts: 1 + KLASS_RISKA_NET — красен | 1 ADVERSARIJ_DO_REVJUERA без KLASS_RISKA_NET |

Клетки r14/r15 принимают только PROFIL_NEDOSTUPEN либо PAUZA_VLADELTSA,
rc 1 и неизменное состояние, не произвольную ошибку парсера.
К-05 — дефект достаточности батареи, а не product-двери: новые входы
на OBJECT зелены; красен её реальный мутант konstanta contracts.
Frozen-миры несут только объявленный нестандартный каталог
(.x/contracts / .other/contracts); отсутствие contracts/ в frozen
удостоверяется Git plumbing до вызова. Значения имён/SHA не оракул.
Привязки s90–s93 к различающим ветвям — код BINDINGS, не проза контракта.
Честные эквиваленты — обе раскладки/полярности К-05, adversary/critic
К-02', штатный профиль/отсутствующий профиль прежних r03/r08/r09,
существующая одиночная санкция К-04'.

## К-01 (слово консультанта 00:22)

«К-01 остаточным НЕ принимаю: база отказывает, A2 впервые вытесняет живого
держателя — это регресс, чини в той же ветке до вызова 2». Прежнее
обязательство этого листа «К-01 НЕ чиним: решение владельца 21.11 12:06
„брошенный замок освобождается автоматически“; таймерная красная клетка не
добавлена» СНЯТО: слово владельца авто-освобождения не упоминает —
формулировка была интерпретацией; действует frozen 140/5 :46 (TTL-автоосвобождение
ОТКЛОНЕНО, именованный отказ ZAMOK_BROSHEN + явный --osvobodit).

Факт (дверь меняется аргументом; миры батареи): база f9f029592b на возрастах
120 и 100000 мин — rc 1 «ОТКАЗ: ZAMOK_BROSHEN … только --osvobodit, НЕ
авто-перезапуск», учёт без изменений; A2 3611ad996f — rc 0, «ПРЕДУПРЕЖДЕНИЕ:
ZAMOK_BROSHEN … замок освобождается автоматически», фиктивный RELEASE и новый
START: второй рабочий допущен по одному таймеру.

Целевое поведение = база. Возраст >порога без сдачи → rc 1 ОТКАЗ:
ZAMOK_BROSHEN, учёт БЕЗ новых записей (нет RELEASE/START), занятие прежнего
держателя; возраст ≤порога → RABOCHIJ_ZHIV; выход — явный --osvobodit.
Клетки: w04 восстановлена базой (rc/причина/START-ровно-1); новая
w04b-gluboko-broshennyj — возраст 100000 мин, предъявления rc, причина,
START-ровно-1, нет-RELEASE, занятие-прежнего-держателя; охранные клетки
прежние: w02 (0 мин → RABOCHIJ_ZHIV), w05 (--osvobodit освобождает и
допускает), станционная p09 — блок ZAMOK_BROSHEN. Обманные стабы — мутации
модели КОДОМ (Н-39), входы — source.json:.stab_vhod: s03-avto-relis-broshennogo
(S1 «авто-освобождение по таймеру», поведение A2) красит w04/w04b;
s94-broshennyj-start-bez-release (S2 «предупреждение с START без RELEASE»)
красит w04b; s95-broshennyj-ljuboj-vozrast (S3 «отказ при любом возрасте
включая живого») красит w02; s85-broshennyj-bez-release перепривязан к w05 —
RELEASE обязан писать явный --osvobodit. LIVE-клеток не добавлено (0).

Дверь правит implementer в той же ветке до вызова 2; ниже — фактические rc
этой копии на двери A2 (до правки) и заявленные ПОСЛЕ реализации (строки
дверей «Двери» ниже — 0·0, выставленные Arch140A2c, не откатывались):

| прогон этой копии | rc на A2 3611ad996f | ожидание после правки двери |
|---|---|---|
| bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh | 1: KLETKI 215 KRASNYH 2 — ровно w04/w04b, остальные зелены | 0: KLETKI 215 KRASNYH 0 |
| то же --model | 0: MODEL_KLETKI 214 KRASNYH 0 | 0 (от двери не зависит) |
| то же --stabs | 1: SUBJEKT_KRASNO 2 (w04/w04b); SVJAZI 174, MODEL_ZHIVYH 0 | 0: SUBJEKT_SVJAZI 174, живых 0 |
| то же --domain | 0: KLETKI 19 KRASNYH 0 | 0 |
| bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta | 0: итог 4/4 классов закрыто | 0: 4/4 |

Счёт семьи A2d: клетки 213 → 214 динамических (W 215 с r10); стабы 94 → 96
(+s94/s95); связи 171 → 174 (s03 +w04b, s94 +1, s95 +1; s85 перепривязан 1→1);
носители 99 → 101; sintaksis 97 файлов. К-02…К-05-клетки не краснеют
(единственные красные — w04/w04b). Замеры сняты последовательно в этой копии,
TMPDIR=.scratch-a2d, scratch удалён перед коммитом.

## Замер пачки A2c (история; счёт семьи до A2d)

Сырой адресный замер воспроизводится командой
`python3 fixtures/workshop_project/odin_agent_140/reestr_140.py`:
RAW rc/stdout/stderr/ledger для каждого нового входа и отдельного
К-05-мутанта; CELL_RC — вердикт клетки. TMPDIR под собственной копией.
На OBJECT r11/r14/r15/r16/r17: RAW rc=0, CELL_RC=1;
r12/r13/r18: RAW rc=0, CELL_RC=0; r19: RAW rc=1, CELL_RC=0.
На К-05-мутанте r18/r19: RAW rc=1, CELL_RC=1.
После исправления модели: MODEL_KLETKI 213 KRASNYH 0, rc 0.
После production-реализации те же клетки обязаны стать зелёными;
результат production после реализации здесь НЕ утверждается.

Счёт семьи: прежние W 205 → 214 (213 динамических + r10);
профильный W-domain 10 → 19; прежние клетки не удалены.
Фактические последовательные прогоны продолжения (TMPDIR=.scratch-a2c):
W rc 1, KLETKI 214 KRASNYH 5; --domain rc 1, KLETKI 19 KRASNYH 5.
В обоих красны РОВНО r11/r14/r15/r16/r17; прежние 205 зелены.
--model rc 0, MODEL_KLETKI 213 KRASNYH 0.
--stabs rc 1: SVJAZI 171, MODEL_ZHIVYH 0; все s90–s93 пойманы
своими кодовыми привязками; слой production даёт SUBJEKT_KRASNO: 5.
Матрица над production до исправления двери не исполняется — так
устроен существующий контроль слоя, он не выдаётся за зелёный.
--grammar rc 0; --sintaksis rc 0, SINTAKSIS FILES 95.
parsing_hygiene rc 0, итог 4/4 классов закрыто.
Независимый jq source.json: cases=213, mutants=94, bindings=171,
carriers=99; численность динамических клеток подтверждена --model,
связей — --stabs. S/stancija_* из этой копии не запускались.
`bash scripts/check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run`
завершился rc 0: `СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)`.
Прогоны выполнены последовательно; scratch удалён перед коммитом.

## Переход к приёмке после реализации

Impl140A2c сообщил результаты на `272f8b9734`:
W rc 0, KLETKI 214 KRASNYH 0; --domain rc 0, KLETKI 19 KRASNYH 0;
--stabs rc 0, SVJAZI 171, MODEL_ZHIVYH 0, SUBJEKT_SVJAZI 171.
Адресные s90–s93 пойманы и над production. Поэтому три машинных
ряда W-stabs/W-production/W-domain переведены в после-реализационные
rc 0 согласно пункту 3 приёмки frozen 140/5. Это замер implementer,
не повторный прогон architect; красные замеры OBJECT выше исторические.
После интеграции кода и этой правки check_sdacha/pre_critic запускает
ведущий. На одной базе architect без реализации эти три rc не применимы.

## Развилки исправления Adv140A2

§16 прежнего задания требовал rc 0 для битого профиля без паузы;
§9 запрещает пропуск при неопределимости пути реестра. Решение
оркестратора в task-a2b-architect-2.md: §9 приоритетнее, именованный
fail-closed разрешён. Битый JSON не доказывает отсутствие паузы,
поэтому r15 теперь требует тот же отказ, что r14. Модель различает
ошибку резолвера (2) и отсутствие записи (1); спавн при ошибке
отказывает PROFIL_NEDOSTUPEN до START/override. Production не менялась.
Новых развилок за пределами решения не вводится.

Процессная рефлексия: содержательный конфликт был остановлен без
самовольного fallback; явное решение позволило исправить полярность
двух клеток и модель, не нарастив контракт или парсер. Общий А-NNN
журнал вне зоны и пишется только в main; здесь он не меняется.

## Предыдущая пачка Ш-2 (история)

### Пачка Ш-2 (2026-11-21, до Adv140A2)

БАЗА сборки Ш-2 после реализации: 92a4a8e3187b82eeb020953f754d48606104d931.
Прежние замеры «до» сохранены ниже как история, не rc текущего кандидата.
Замороженный контракт и production этой пачкой не изменяются.

§Существующее: Mir.worktree/pin_frozen уже создают annotated frozen и pin;
Mir.start/zhurnal — сданного рабочего; --sudit и START/warn — наблюдаемый шов.
project_paths_resolve в scripts/next_id.sh уже читает закрытый профиль.
Модель использует именно этот резолвер, новых ключей и парсера нет.
Все миры и временные стабы — внутри TMPDIR своей копии, со своей .git.

Обещание: contracts.tsv и pauzy.tsv берутся из объявленного реестра;
без профиля — прежний registry/. Reviewer обычного frozen допускается со
START; рискового — ADVERSARIJ_DO_REVJUERA без изменения состояния.
KLASS_RISKA_NET не принимается за доказательство чтения pin: после A2 он
означает рисковый по умолчанию и маскирует пропущенный реестр.
Демаркация: действительный двухслойный профиль существующей грамматики,
полный workflowPaths, annotated frozen с pin, сданный рабочий, точный OBJECT.
Значения SHA/имени/пути не являются ожиданием; различение — допуск/причина,
START, отсутствие предупреждения неизвестного риска и неизменность отказа.

Клетки (а)–(г) и ожидаемое состояние до/после:

| вход | до Ш-2 | после Ш-2 |
|---|---|---|
| r01 (.x/reg, обычный) | красен: reviewer отвергнут | rc 0, START, без KLASS_RISKA_NET |
| r02 (.x/reg, рисковый) | красен: риск не прочитан | rc 1 ADVERSARIJ_DO_REVJUERA, без записей |
| r03 (без профиля) | зелён | прежний rc 0, START |
| r04 (.x/reg, пауза 140) | красен: пауза пропущена | rc 1 PAUZA_VLADELTSA, без записей |
| r05 (.x/reg, пауза 141) | красен: pin не прочитан | rc 0, START |
| r06/r07 (штатный профиль, пауза 140/141) | зелены | соответственно отказ/допуск |
| r08/r09 (без профиля, пауза 140/141) | зелены | соответственно отказ/допуск |
| r10 (точный статический критерий) | красен | rc 0, исходный критерий без сужения |

Привязки s87/s88/s89 — код reestr_140.py и производный source.json.
Каждый стаб предъявляется только своему различающему входу.
--model проверяет семантику; r10 — отдельная --grammar, также обязательная
часть W/--domain и слоя production в --stabs. Исходный критерий не ослаблен.
Машинные rc ниже приведены к состоянию ПОСЛЕ реализации Ш-2;
оба столбца — фактический rc кандидата (формат check_sdacha).

## Развилки Ш-2

S-station ОТЛОЖЕН по поправке задания: запустит оркестратор вне /zones/.
Прямой и косвенный запуск S из этой копии запрещён; поэтому S не включён
в машинную секцию дверей этой сдачи. Обязательство S контракта сохранено.
Режим --live отсутствовал на базе; --domain и --grammar добавлены этой
пачкой. --sintaksis — существующий синтаксический режим, не подмена --grammar.

Историческая развилка до реализации: точный критерий (г) находил также
executable-упоминания .harness/contracts и registry/pauzy.tsv в диагностике.
Предложенное сужение критерия НЕ применено. Реализация Ш-2 устранила
литералы: kontrakt_kat использует workflowPaths.contracts существующего
резолвера, без профиля — contracts/. Поэтому исходная r10 зелена.
У s35 прежний якорь выбора каталога заменён на блок вызова kontrakt_kat
для production; модель сохраняет прежний якорь. Обе формы мутации читают
класс из рабочего каталога станции, а не из закреплённого дерева владельца.
Прежние шесть различающих входов и их кодовые привязки сохранены.

## История legacy-пачки

БАЗА: 971a5dfc2b681e519dbd544f2ffc6c72110239a8.
Исторический FAIL verdicts/critic/contracts-140-v5-r2.md (блоки К-02/К-16) закрыт в «## Дельта».
Исторический FAIL Crit140Combined находится в verdicts/critic/contracts-140-v5.md;
его OBJECT и текст не изменяются. Исправительный Crit140Fix6 вынес полный
вердикт с картой классов на принятую пачку; текущая дельта закрывает его
legacy-ветвь, не меняя прежних обязательств.

## Предмет и существующее

Обещание: blob-привязка старого frozen берётся из registry/risk-legacy.tsv
владельца предмета при прямом и переданном пути. Наблюдение — допуск reviewer
обычного продукта, ADVERSARIJ_DO_REVJUERA рискового и KLASS_RISKA_NET при
отсутствующей привязке владельца, без записи START при отказе. Станционный
legacy сохраняет прежние допуск и порядок. Frozen-обязательства 140,
104/167/197/199, fail-closed и batch-атомарность не ослабляются.

Существующее: klass_riska уже получает репозиторий владельца как wt и точный
commit frozen; frozen_predmeta и проверяемый receipt уже выбирают владельца.
Перечень файлов, Git blobs, литеральное blob-сравнение и алфавит класса
сохраняются. Исправлены только корни проверки файла и чтения legacy-реестра.
Формат/механика самого реестра, production, frozen-текст и вердикты неизменны.

Существующие продуктовые миры теперь имеют необязательный legacy-вариант:
старый frozen без декларации и отдельный реестр продукта. Прямой START и
настоящая --peredat предъявляются отдельно. Обе полярности класса проверяются
при противоположной станционной записи того же blob; отдельно предъявлены
отсутствие станционной записи и отсутствие привязки владельца при допустимой
станционной. Станционные контроли имеют старый frozen с привязкой станции,
противоположные декларацию OBJECT и локальную привязку кандидата.

Демаркация: конформный вход — прежняя грамматика 140, действительный annotated
frozen и pin владельца, старый файл без декларации, TSV-привязка его Git blob
с классом обычный|рисковый. Валидное различение не зависит от SHA/пути/имени:
при том же входе подмена владельца реестра меняет допуск либо именованную
причину. Старые клетки и связи сохраняются; привязки мутаций к входам живут
только в produkt_140.py/source.json, не в прозе контракта.

## Среда и результаты legacy-дельты (исторический замер)

Рабочая копия:
/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t3f0d5ee84/m
Ветка wip/140/architect-v5; своя .git; база выбрана после fetch через gitw.
TMPDIR=/tmp/dev-harness-verify, PYTHONDONTWRITEBYTECODE=1; каждый Git-мир имеет
свою .git. Delivery WORKTREE не используется для записи; push не выполняется.

Собственный red-до на точной БАЗЕ: OWNER140_FAILURES 8, rc 1. После реализации
на ae5dbf6b8137f8c1b8c192611a6fc710613cbfce: W --model rc 0,
MODEL_KLETKI 172 KRASNYH 0; W --owner-check rc 0, OWNER140_FAILURES 0.
W --stabs rc 0, MODEL_ZHIVYH 0; безфлаговый W rc 0, KRASNYH 0.
Прежняя предметная краснота production до реализации — исторический замер,
не ожидаемый результат текущего кандидата.

jq по source.json: cases=172, mutants=82, bindings=159, carriers=87,
legacy_cases=10. Независимый обход исполняемой батареи — MODEL_KLETKI 172;
матрица дала SVJAZI 159. Числа старого вердикта — исторические, не эта пачка.
Rc в рядах ниже проверяет фактический check_sdacha --run; сами ряды не
подменяют прогон.

## Двери

- Owner-before — legacy-дефект точной базы · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-before · 1 · 1
- Owner-check — продукт, станция и адресные мутации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- W-model — честная fail-closed модель · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- W-stabs — A2f до правки двери: модель зелёна, стабы пойманы, субъект красен ровно на 6 новых клетках · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs · 1 · 1
- W-production — A2f до правки двери: красны ровно n01/n06/n07/n08/n09/n10, прежние 236 зелены · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh · 1 · 1
- W-domain — профиль/пауза/каталог зелёные · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --domain · 0 · 0
- W-grammar — исходный критерий Ш-2 без подгонки · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --grammar · 0 · 0
- W-sintaksis — все носители · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --sintaksis · 0 · 0
- Obryv-167-repo — соседняя батарея 167 на чиненой модели (проба обрыва + merge) · bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Provodka · bash scripts/check_provodka.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа и предыдущий закоммиченный вердикт с полной картой; штатный SDACHA_OKRUG=1 разрывает рекурсию pre_critic · - · -
- К-02 · чисто · вход: --owner-before читает точную БАЗУ; --owner-check предъявляет legacy-привязку соответствующего владельца на обоих путях · - · -
- К-03 · чисто · вход: frozen-текст, production и прежние инварианты 104/167/197/199 неизменны; прежние клетки входят в W-model · - · -
- К-04 · чисто · вход: модель, миры, лист и производные носители только в fixtures/workshop_project/odin_agent_140/ architect-зоны · - · -
- К-05 · чисто · вход: каждая дверь несёт команду и rc, соответствующие прежней приёмке 140 · - · -
- К-06 · чисто · вход: W/stabs ожидаемо rc 1 на шести новых дефектах OBJECT (n01,n06–n10); --domain 19/0, grammar зелена внутри W; production/frozen не менялись · - · -
- К-07 · чисто · вход: W 242 (241 динамическая + r10), прежние 222 сохранены; красны ровно n01/n06/n07/n08/n09/n10; S из этой копии не запускался · - · -
- К-08 · чисто · вход: s99–s104 и перепривязанный s15 привязаны кодом к различающим ветвям, s90–s98 и К-05 literal r18/r19 сохранены; MODEL_ZHIVYH 0 · - · -
- К-09 · чисто · вход: n01–n20 (матрица недоступности как данные) добавляют формы реестра паузы и честные полярности; прежние k03b01–k03b07 и r01–r19 сохранены, --domain 19/0 · - · -
- К-10 · чисто · вход: реальный --sudit/--peredat в независимых .git; сверяются rc/причина, START, proof и неизменность состояния при отказе · - · -
- К-11 · чисто · вход: ожидания и source.json снимаются в память до вызова двери; материализация носителей выполняется до приёмки · - · -
- К-12 · чисто · вход: прежние Git plumbing и JSON Schema; TSV-сравнение не меняется, новый парсер не вводится · - · -
- К-13 · н/п · новые секретные входы и наружные строки с секретами не вводятся · - · -
- К-14 · чисто · вход: MODEL_KLETKI 241 KRASNYH 0; честные эквиваленты под s99–s104 проверены адресно; w04/w04b, k03b01–k03b07 и охранные прежних исправлений зелены · - · -
- К-15 · чисто · вход: source.json cases=241 mutants=105 bindings=196 carriers=110; независимые W 242, SVJAZI 196 и sintaksis 106 носителей · - · -
- К-16 · чисто · вход: класс берётся по blob закреплённого frozen в реестре владельца, не станции/OBJECT продукта; отсутствие привязки не открывает reviewer · - · -
- К-17 · н/п · схема операций/writers/isolationKeys 188 не меняется; исправляется исполняемая модель батареи 140 · - · -

## Дельта

- К-01 · клетка · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- К-02 · канон/инструмент · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0

К-02/К-16: существующие проверка файла и awk используют wt владельца,
уже передаваемый в klass_riska на прямом и переданном пути. Это применение
существующего канона, не новый запрет/парсер; снятия обещания или границы нет.

К-09: клетки нужны как наблюдение эффекта двух разных репозиториев —
статическая сверка пути не доказывает допуск и порядок. Проба критика
предъявляется обычным legacy-продуктом без станционной записи; соседние
входы — конфликт классов обоих направлений, прямой/переданный путь,
fail-closed и станционный legacy. Обратная подмена wt на REPO красна;
отдельно красны подмены каждого из двух изменённых выражений. Честные
эквиваленты (реестр владельца при отсутствующей/посторонней станционной
привязке и прежняя станционная привязка) зелены теми же командами.
Новых дверей и обязательств сверх блока нет.

К-01 (A2d): регресс авто-освобождения закрыт клеткой — w04 восстановлена
базой, w04b добавлена; стабы s03/s94/s95/s85 привязаны кодом к различающим
входам (раздел «К-01 (слово консультанта 00:22)»). После правки двери
implementer заявленные rc W-stabs и W-production равны 0 по приёмке 3
контракта; пояснения К-06/К-07 отражают то же состояние. Прежняя дельта
К-02/К-09/К-16 не менялась.

## Границы и процессная рефлексия

В прежней legacy-дельте S/normalizacija, живой omp и настоящий pre_judge
--prepare были NOT_RUN из-за внешнего /zones/. Станция, normalizacija и
--prepare теперь проверены в безопасном runtime-клоне (замер ниже);
живой omp не запускался. Production не изменялась.
Чистая env -i проба отдельно — NOT_RUN в этой дельте; прежняя приёмка сохранена.

Наблюдение процесса: прежнее перенесение frozen к владельцу не перенесло
смежный legacy-источник, а декларативные миры этого не различали. Закрыто
ветвлением миров по существующей blob-операции, не ростом контракта.
Первый собственный owner-check обнаружил ошибочную привязку read-only
мутации к входу без файла владельца: проверка наличия не пускала к чтению.
Она удалена только из этой пары; сами fail-closed клетки сохранены и
различают полную подмену корня. Общий NABLIUDENIA_ARCHITECT не изменяется:
вне зоны; А-NNN допустима только коммитом в main.

## Фактические ворота legacy-дельты (исторический замер)

С TMPDIR=/tmp/dev-harness-verify выполнены последовательно:
`bash scripts/check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run`
→ rc 0, затем
`bash scripts/pre_critic.sh --repo "$PWD" contracts/140-odin-agent-na-predmet.md`
→ rc 0. Сырой вывод:

```text
СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3)
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```

## Ремонт станционного frozen-мира — 2026-11-20

База поезда: dd60a5a3b38f8cb4fb8421e709b5bbb79eb66053 (PR #1160).
Рабочая копия:
/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tee0b4d018/m
Ветка wip/140/implementer; автор и коммиттер architect.
Все приёмочные команды запущены в независимом клоне с собственной .git:
/tmp/dev-harness-verify/arch140world-1717276/runtime
TMPDIR=/tmp/dev-harness-verify/arch140world-1717276,
PYTHONDONTWRITEBYTECODE=1. Полный сырой вывод:
/tmp/dev-harness-verify/arch140world-1717276/acceptance.log

Обещание и наблюдение: станционные p05/p10/p16 доходят до исходного
порядка adversary→reviewer, допуска после yield и смешанного пакета,
не меняя ожиданий START/isolated/занятий. Существующее: дверь уже требует
закреплённый annotated frozen владельца; одинаковый origin RE/WT выбирает
RE. Построитель теперь коммитит контракт 141 в RE, замораживает его тегом
frozen/contracts/141/1 и отдельным коммитом закрепляет tag-object SHA
в registry/contracts.tsv. В p16 добавлен ранее отсутствовавший контракт
в RE. WT сохраняет непустой OBJECT; дверь, хук и frozen140/5 неизменны.

«Было» ниже — KLASS_RISKA_NET из исходного вывода задания/консультанта,
не повторный запуск заведомого отказа. «Стало» — полный собственный S:

| клетка | было | стало |
|---|---|---|
| p05-int-porjadok-adv-rev | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-false | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-true | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-missing | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-string | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-number | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-object | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-false | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-string | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-number | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-object | KLASS_RISKA_NET | OK |

Сырые хвосты выполненных команд (rc самого процесса, не последнего
звена конвейера):

```text
COMMAND: bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh
PROBA p20-int-pervyj-rabochij-true OK
PROBA m01-huk-bez-dveri OK
PROB VSEGO 45 KRASNYH 0
COMMAND_RC=0

COMMAND: python3 fixtures/workshop_project/odin_agent_140/normalizacija_140.py
PROB VSEGO 45 KRASNYH 29
NORMALIZACIJA constant RAZLICHENO 5
COMMAND_RC=0

COMMAND: bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh
KLETKI 172 KRASNYH 0
COMMAND_RC=0

COMMAND: bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs
SUBJEKT_SVJAZI 159
COMMAND_RC=0

COMMAND: python3 fixtures/workshop_project/odin_agent_140/object_140.py --prepare
PREPARE published ok
PREPARE leak ok
PREPARE unpublished ok
COMMAND_RC=0
```

Нормализация: strict rc 0, 45/0; truthy rc 1, 45/18,
RAZLICHENO 9; constant rc 1, 45/29, RAZLICHENO 5. Краснота мутантов —
ожидаемое доказательство ловимости, общий rc normalizacija равен 0.
Все привязки остаются в normalizacija_140.py, не в контракте.

Наличие isolated-хука существенно: p10 и p16 судят собственный START-факт,
p15/p17/p18/p19 — отказ неизолированным рабочим, p20 — честный первый START.
Проба удаления хука не запускалась и в эту дельту не входит.

Процессная рефлексия: смена authoritative-источника риска с OBJECT на frozen
не была проведена через станционные построители. Исправлена реальная
предпосылка мира, не ожидания теста и не честный fail-closed двери.
Общий NABLIUDENIA_ARCHITECT не меняется: он вне зоны, А-NNN допускается
только отдельным коммитом main.

Ворота после ремонта (отдельный сырой вывод — gates.log в том же TMPDIR):

```text
COMMAND: bash scripts/check_sdacha.sh . contracts/140-odin-agent-na-predmet.md --run
СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)
COMMAND_RC=0

COMMAND: bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
COMMAND_RC=0
```

## Собственный замер Ш-2

pwd:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tc48dcbb0c/m`
TMPDIR — `.scratch-sh2` под этой копией; scratch не коммитится.
Полный сырой вывод: `.scratch-sh2/base.log`, `.scratch-sh2/sh2.log`.

```text
БАЗА ddbd3bfc5ea99198934b2bf14648be2b27fc426b:
W: KLETKI 195 KRASNYH 0; COMMAND_RC=0
W --model: MODEL_KLETKI 195 KRASNYH 0; COMMAND_RC=0
W --sintaksis: SINTAKSIS FILES 88; COMMAND_RC=0
W --stabs: SVJAZI 162; MODEL_ZHIVYH 0; SUBJEKT_SVJAZI 162; COMMAND_RC=0

С НОВЫМИ КЛЕТКАМИ, production на той же базе:
W: KLETKI 205 KRASNYH 5; COMMAND_RC=1
W --model: MODEL_KLETKI 204 KRASNYH 0; COMMAND_RC=0
W --sintaksis: SINTAKSIS FILES 91; COMMAND_RC=0
W --stabs:
STAB s87-reestr-literal-proekta r01-reestr-profil-obychnyj KRASEN
STAB s88-pauza-ignoriruet-profil r04-pauza-profil-svoj KRASEN
STAB s89-reestr-tolko-stancija r01-reestr-profil-obychnyj KRASEN
SVJAZI 165
MODEL_ZHIVYH 0
SUBJEKT_KRASNO: 5 — поставленная дверь красна (свидетель критика пойман)
COMMAND_RC=1
W --domain: KLETKI 10 KRASNYH 5; COMMAND_RC=1
W --grammar:
CASE r10-sh2-bez-literalov KRASNO: Ш-2-без-литералов: rc 1 ≠ 0; stderr=
COMMAND_RC=1
check_sdacha --run:
СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)
COMMAND_RC=0
```

Красные production-входы ровно r01/r02/r04/r05/r10. Прежние входы зелены.
r04 на базе отказывает не из-за паузы, а ADVERSARIJ_DO_REVJUERA после
KLASS_RISKA_NET; клетка различает причину, а не засчитывает любой rc 1.
Это исторический замер ДО реализации; текущие rc приведены в дверях выше.

Рефлексия процесса: широкий grep-критерий смешивает путь реестра с
законным каталогом contracts; барьер оставлен точным и красным, конфликт
назван до передачи implementer. Отдельно неизвестный риск после A2
маскирует неполученный pin — поэтому наблюдаются warn и именованная причина,
а не только rc. Общий журнал А-NNN не изменён: вне зоны и только main.

## Сборка после реализации Ш-2 — 2026-11-21

pwd:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tef18fd95d/m`
База: `92a4a8e3187b82eeb020953f754d48606104d931`.
TMPDIR — `.scratch-sh2c` под этой копией; scratch не коммитится.
Полный сырой вывод приёмки: `.scratch-sh2c/acceptance.log`.
Контракт, production, профиль parsing_hygiene_battery и source.json неизменны.
Материализованный s35 модели побайтно прежний; меняется только выбор
строгого якоря при наложении той же мутации на production.

```text
W:
KLETKI 205 KRASNYH 0
COMMAND_RC=0
W --domain:
KLETKI 10 KRASNYH 0
COMMAND_RC=0
W --grammar:
CASE r10-sh2-bez-literalov ok
COMMAND_RC=0
W --model:
MODEL_KLETKI 204 KRASNYH 0
COMMAND_RC=0
W --sintaksis:
SINTAKSIS FILES 91
COMMAND_RC=0
W --stabs:
SVJAZI 165
MODEL_ZHIVYH 0
SUBJEKT STAB s35-klass-iz-main s39-main-riskovyj-kandidat-obychnyj KRASEN
SUBJEKT STAB s35-klass-iz-main s40-main-obychnyj-kandidat-riskovyj KRASEN
SUBJEKT STAB s35-klass-iz-main s41-kandidat-bez-stroki KRASEN
SUBJEKT STAB s35-klass-iz-main s42-risk-legacy-blob-kandidata KRASEN
SUBJEKT STAB s35-klass-iz-main s43-klass-iz-dereva-ne-gryazi KRASEN
SUBJEKT STAB s35-klass-iz-main s44-klass-otkaz-bez-starta KRASEN
SUBJEKT_SVJAZI 165
COMMAND_RC=0
bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta:
БАТАРЕЯ zamok_predmeta: итог 4/4 классов закрыто
COMMAND_RC=0
```

STAB_ZHIV и SUBJEKT_KRASNO в выводе отсутствуют: живых стабов и красных
входов честного субъекта нет. S-station не запускался.

Рефлексия: текстовый якорь стаба отстал от замены операции выбора каталога.
Исправлена привязка к реальному блоку двери, не ослаблены r10 или входы;
история красного замера не подменяет текущие rc машинного листа.
Общий журнал А-NNN вне зоны и допускает запись только в main.

Ворота этой сборки, полный сырой вывод `.scratch-sh2c/gates.log`:

```text
check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run:
СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)
COMMAND_RC=0
pre_critic.sh --repo "$PWD" contracts/140-odin-agent-na-predmet.md:
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
COMMAND_RC=0
```

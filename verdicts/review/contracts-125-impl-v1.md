FAIL
Реализация 125, круг 1: батарея на дереве зелёная 70/0, зоны и workshop в границах. Две блокирующие находки, обе в `review.md`:
Рв125-1 — сев в `workshop` пишет в зону dev сквозь ссылку, которую сессия проекта сажает в своём доме (против И-2);
Рв125-2 — `CONNECT_HERE` в двери: паразитная env-ручка без свойства и без потребителя (050).
OBJECT=cb04074f9652d6c671d90349d2bcbb8fb595e910

Роль: reviewer (Rev125). Контракт: frozen/contracts/125/1. Находки (reslop, status: ready): /tmp/dev-harness-verify/Rev125/review.md
Клон: /tmp/dev-harness-verify/Rev125/h = OBJECT + `git checkout 9a39f607c -- fixtures/workshop_project/sessii_125 contracts/125-sessii-proektov.md` + `git reset -q`.
Батарея 9a39f607c по путям батареи и контракта побайтно равна frozen/contracts/125/1: `git diff --stat` пуст. Её автор — architect (f73c4cd01).
Блобы субъектов (sha256): workshop 999a32ba…748e4a; scripts/connect_project.sh 90489ae0…562735; scripts/check_project_session.sh 28016de3…2ad6c3.

## 1. Область правки — в границах
`git diff --name-only 4ebea3468 cb04074f9` → ровно `scripts/check_project_session.sh scripts/connect_project.sh workshop` (+490/−0). Это ЗОНА implementer.
Три коммита, у каждого автор `implementer`, каждый — одна задача со ссылкой на 125: c1e007b84 workshop, dc3ae5def сверщик, cb04074f9 дверь.
`git diff 4ebea3468 cb04074f9 -- workshop` — ровно три вставки:
- `load_env "$PROJECT/.harness"` до `load_env "$PROJECT"`;
- переопределение ENV_FILE/PIN_FILE на `.harness/` перед проверкой P8;
- блок сева перед шагом 058.
Резолвер, класс projectId, N2, 058, argv, PID-лок и проба не тронуты.
`diff workshop model/workshop.sh` отличается только комментариями и формой тех же трёх точек (`|| die`, имя временного файла). Семантика ENV/PIN та же.
`bash scripts/check_zones.sh` → rc=0 («замороженных контрактов: 126 · … проверено по зонам: 3989»).
Норма не тронута: реализация не правит ни одного нормативного файла.

## 2. Проверки не переписаны под код
Коммиты implementer не касаются `fixtures/`, батарея — блоб architect, равный заморозке.

## 3. Прогоны (сырой вывод — /tmp/dev-harness-verify/Rev125/run_*.txt)
- `red_sessii_125.sh` (дерево OBJECT) → rc=0, «s125 red: зелёных 70, красных 0».
  Своя мера: `grep -c '^ЗЕЛЕНО '` = 70, уникальных 70, `^КРАСНО` = 0.
- `--model` → rc=0, «зелёных 70, красных 0».
- `--stabs` → rc=0, «стабов 37, привязок 128, непойманных привязок 0» (313 с).
  Своя мера: строк `ПОЙМАН` 128, различных стабов 37, файлов `stabs/stab_*.sh` 37, `jq '[.stab_vhod[]|length]|add'` = 128.
- Негатив п.4 (копия `h2`: блок сева вырезан, −18 строк) → rc=1, «зелёных 66, красных 4».
  Красны ровно `b02-sev-pobajtno b08-sverka-chestnaya b03-drejf b04-zapis-ne-v-dev`.
- Правило 5. 11 батарей, база 4ebea3468 (`hbase`) против OBJECT (`h`):
  - profil_dva_sloja 0/0, izoljacija_projectid 1/1, config_do_overlay_105 0/0, ext_ustanovki_105 0/0, otkaz_flagov_105 0/0, proba_odin_kod_105 0/0, roli_v_profil_105 0/0, samodostatochnost_repo_060 0/0, github_token_070 0/0, sverka_puti_profylja 0/0;
  - sharing_agentdb: первый прогон 1/0 — на базе «честная клетка к11 красная», параллельно шли --stabs и check_zones. Повтор на базе в тишине дважды rc=0 («честная часть: 16/16 зелёная»), значит это флейк под нагрузкой, а не дельта. На OBJECT — rc=0.
  - Итог правила 5: rc до и после совпадают, 10 × 0/0 и izoljacija 1/1, как в замере «Сдачи».
- `pre_critic.sh contracts/125-sessii-proektov.md` → rc=0, «КРИТИК: дверь зелёная».
- verify_antiplacebo: scoped неприменим — `scope_select.sh . --changed 4ebea3468` → «SCOPED: не для приёмки / MODE: full».
  Полный прогон на OBJECT (`verify_antiplacebo.sh --changed 4ebea3468` под `timeout 900`) → rc=124: упёрся в таймаут 900 с, итога нет. До обрыва — только строки `ok`.
  Своя мера барьеров без фикстур: база 24, OBJECT 26 (+connect_project.sh, +check_project_session.sh). Полный прогон базы красен по коду [INFERENCE] — Рв125-6, наблюдение.
- Шапки: обе новые `scripts/*` несут `# Коды возврата:` (connect_project.sh:28, check_project_session.sh:41) — Н-391 соблюдено.

## 4. ОБХОД — что проверено
- Узнавание стенда: grep трёх субъектов по `s125|dev-harness-verify|complior|toy|_mir_|red125|RUNDIR|WORLDS|stab|CONNECT_SUBJECT|W105` находит только комментарий workshop:45 (ap-фикстуры 996). Узнавания миров нет.
- Сверщик читает факты exec: argv/env, дом по HOME. Т-2 решается обходом с realpath и inode, а также sha непустых файлов. stdout — только `РАСХОЖДЕНИЕ <поле>` в порядке POLYA.
- Дверь: значения секретов — через файл `grep -f`, не в argv. В отказе только имя файла. `env-v-indekse` срабатывает до записи. `sekret-v-dereve` проверяется на каждом входе. Сев безусловен — `exec`/`exit 0` между PSTATE и севом нет, значит он идёт при КАЖДОМ старте.
- НАЙДЕНО — Рв125-1: состояние, при котором батарея зелёная, а И-2 нарушен.
  Сессия проекта сажает в своём доме ссылку `agent/.models.db.sev` → `<dev>/agent/history.db`. Следующий старт переписывает `history.db` dev: sha `a1be5a42…` → `868e8488…`, и оставляет `models.db` проекта ссылкой в dev.
  Вариант: каталог агента проекта сделан ссылкой на `<dev>/agent/sessions`; после старта там появляется `config.yml`.
  Пробы: /tmp/dev-harness-verify/Rev125/sev_probe.sh, sev_probe2.sh. Блок сева берётся из workshop OBJECT дословно.
- Остаток Т-1 «под другим именем только в индексе» не переоткрывается.

## 5. Паразитная сложность (050), по артефакту диффа
- workshop, 3 точки. (1) И-1 и 054 P8/P9 с раскладкой `.harness/`. (2) Новое состояние — только файлы сева в `$PSTATE/home`, оно видно баннером `SEV:`. (3) Число файлов, которые надо менять вместе с перечнем сева, — workshop + сверщик + source.json, дифф его не увеличил. (4) Интерфейс не вырос. (5) Потребитель — группа B. Итог: ESSENTIAL.
- scripts/check_project_session.sh. (1) И-3. (2) Только чтение, состояния нет. (3) Перечень полей — шапка и POLYA, одна точка. (4) 4 флага против суда по 14 полям и Т-2 — модуль глубокий. (5) Потребитель — группа A и ПРОВОДКА role-строки. Итог: ESSENTIAL.
- scripts/connect_project.sh. (1) И-5…И-7. (2) Пишет `.harness/`, профиль, `.git/info/exclude`, `receive.denyCurrentBranch` — всё это названо в И-6. Временный файл значений удаляется. `HARNESS_PROJECT_LAYER_ROOT` требует 054 И-2 у workshop. (3) Список ключей bootstrap дублирует `bootstrap_env` (workshop:148), сверку держит c09. (4)–(5) Потребитель — группа C. Итог: ESSENTIAL, КРОМЕ:
- env `CONNECT_HERE` (connect_project.sh:33): ACCIDENTAL, блокирует — Рв125-2. Свойства нет, потребителя нет. Более простая форма (копия `h4`) → `red_sessii_125.sh` rc=0, «зелёных 70, красных 0».

## Находки, все
- Рв125-1 — дефект против И-2, БЛОКИРУЕТ (implementer).
- Рв125-2 — ACCIDENTAL 050, БЛОКИРУЕТ (implementer).
- Рв125-3 — дыра батареи и модели: тот же класс, что у Рв125-1. Совет, вопрос владельцу (architect).
- Рв125-4 — `CONNECT_HERE` в модели. Совет (architect).
- Рв125-5 — `sekret-v-dereve`: значения короче 8 символов и значения в кавычках. Совет (implementer).
- Рв125-6 — два новых барьера без фикстур антиплацебо: долг 24→26, вне зон 125. Наблюдение (оркестратор/architect).

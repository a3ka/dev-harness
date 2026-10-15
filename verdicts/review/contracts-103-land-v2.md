FAIL

# Review PR#96 `wip/103/implementer2`: контракт 103 «профильные пути вместо harness-layout», круг 2 (land-v2)

Находки с чекбоксами лежат в `.review/2026-10-15-06.md` (prev: `.review/2026-10-15-05.md`). Круг 1 — `verdicts/review/contracts-103-land-v1.md` (FAIL).
Вердикт adversary круга 2 (`Adversary103R2`) на момент суда не готов, этот вердикт написан независимо.

**Модели.** Судья — `anthropic/claude-opus-5-5`. Авторы круга 2:
- architect — `Architect103Fix2.jsonl`, 99 записей `claude-fable-5-1` (Anthropic);
- implementer — `Implementer103Fix2.jsonl`, 80 записей `glm-5.3` (zai).

Для фикстур суд не межсемейный (Рв96-11).

**Предмет.** `git ls-remote origin wip/103/implementer2` → `dc094da152445b8bb4029fbba316c9e95ed02333`. origin/main на момент суда `21f394f4`, merge-base `60d82e94`.
Тег `frozen/contracts/103/1` → `28b26c64`. `git diff frozen/contracts/103/1 origin/wip/103/implementer2 -- contracts/` пуст (0 строк), всего в диффе 26 путей.

```
$ git log --format='%h a=%an %ad | c=%cn %cd' 3936e061..origin/wip/103/implementer2
dc094da1 a=architect 12:57:23 | c=architect 13:03:54   fixtures/…/{_toy,battery_stubs,model/check_project_standard,red_pre_critic_cwd,red_spawn_reestr_proekta,red_standart_etalon,red_standart_narushenija}.sh
bdfd8e8d a=architect 12:57:08 | c=architect 13:03:54   fixtures/…/model/{dver_reestra,pre_critic_proekta}.sh
5f2301f5 a=architect 12:56:59 | c=architect 13:03:54   NABLIUDENIA_ARCHITECT.md fixtures/…/_toy.sh
b52a10fe a=architect 12:54:54 | c=architect 13:03:54   fixtures/…/.probe-only
5cd8274a a=implementer 12:56:46 | c=implementer 13:03:22 scripts/pre_critic.sh
24f6ab2e a=implementer 12:47:27 | c=implementer 13:02:31 scripts/pre_critic.sh scripts/spawn_agent.sh
56c8abbc a=implementer 12:44:35 | c=implementer 13:02:31 scripts/check_project_standard.sh
171229b1 a=implementer 12:43:50 | c=implementer 13:02:31 scripts/check_project_standard.sh
```

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/r103v2-1792080035-594035/repo`. Worktree-снимки:
- `tip` — голова;
- `pre` — фикстуры головы и scripts 60d82e94 без `check_project_standard.sh`;
- `r1` — фикстуры головы и scripts 3936e061, то есть реализация круга 1;
- `c5cd` — 5cd8274a;
- `mut_pc3`, `mut_ph` — мутанты;
- `mrg` — слияние в 21f394f4.

Основной чекаут я не трогал, push не делал.

## 0. Авторство круга 2 по session-трассе: Рв96-1 закрыт по существу, хвост и транспорт неблокирующие

Коммиты в сессиях находил так: `jq` по toolCall `git … commit` в JSONL подсессий Main `2026-10-15T11-51-23-414Z_…`.
Исходные коммиты нашлись в клонах сессий. Patch-id: `git show X | git patch-id --stable`.

| голова | исходный (клон сессии) | сессия, модель | patch-id |
|---|---|---|---|
| b52a10fe | b9d51386 (`architect103fix2-2008520947`) | Architect103Fix2, fable | 4d2733301b09 = |
| 5f2301f5 | c261a59c | Architect103Fix2 | eb5c02a85051 = |
| bdfd8e8d | c9f6e8f0 | Architect103Fix2 | 4221223ad8f8 = |
| dc094da1 | f6206f46 | Architect103Fix2 | beb892fa2e31 = |
| 171229b1 | 00d18491 (`implementer103fix2-7741`) | Implementer103Fix2, glm-5.3 | 162efd6fb8af = |
| 56c8abbc | c45f1689 | Implementer103Fix2 | ecc663965eed = |
| 24f6ab2e | 3cafa058 | Implementer103Fix2 | 77680d521677 = |
| 5cd8274a | 91cee97d | Implementer103Fix2 | 11b67496e0fb = |

- `.probe-only` переписан и закоммичен architect-сессией: commit-вызов `git add fixtures/project_paths_103/.probe-only && git -c user.name=architect … commit`.
- Строку `# Коды возврата:` вписала сама implementer-сессия: edit-вызов «Deduplicating return-codes header line», `PUT 7.=11` содержит эту строку.
- Хвост остался в истории: b72388fb и 3936e061 (оркестратор под чужим именем). `git blame`: `.probe-only` — 14 строк b52a10fe и 1 строка b72388fb, `check_project_standard.sh:10` → 3936e061, потому что перезапись байт-в-байт blame не двигает. Это неблокирующий хвост Рв96-1.
- Транспорт снова под ролевыми именами: Main `#580 git -c user.name=implementer … cherry-pick -x 91cee97d…` и `#589 git -c user.name=architect … cherry-pick 7619ca94 7717fb58 4d12c8ba 393f58e8…` (Рв96-6, повтор).

## 1. Область правки: PASS

ЗОНА взята из живого блоба `git show frozen/contracts/103/1:contracts/103-…md`. Круг 2:
- implementer — только `scripts/{check_project_standard,pre_critic,spawn_agent}.sh`;
- architect — только `fixtures/project_paths_103/**` и `NABLIUDENIA_ARCHITECT.md`.

`bash scripts/check_zones.sh` (tip) → `замороженных контрактов: 96 · объявленных авторов: 2 · коммитов в диапазонах: 11657 · проверено по зонам: 2840`, rc=0.
Единственная FAIL-строка — самотест грамматики в `contracts/055-…`, к диффу она не относится, как и в круге 1.

## 2. Сырой вывод своими прогонами: PASS

**Приёмка 3** (tip): `bash fixtures/_krasnye_103.sh`. Стабы s1…s21 все «пойман», `ИТОГ стаб-пак 103: rc=0`, 11 клеток `rc=0`.
Входы внутри клеток:
- i2а/б, i2в;
- i3а–i3г;
- i4а: etalon, prioritet, sloj-vne, sloj-vne-cli, env-vrag (rc=1, profil), pustoj-repo (rc=2, NOT_IMPLEMENTED);
- i4б: 11 канонических миров + 5 вариантов (lint, typecheck, build, schemaVersion, indeks);
- i4v ×3.

Итог `ИТОГ 103: rc=0`, `RC=0`.

**Приёмка 1** (`pre`: фикстуры головы, scripts базы):
```
ИТОГ стаб-пак 103: rc=0
КРАСНО: i1d: G′ из корневого registry/plan.tsv попала в GOAL           red_brief… rc=1
КРАСНО: i1v: байты приманки K …                                        red_frozen_iz… rc=1
КРАСНО: i1g: заморозка из корневого contracts/ тега принята …          rc=1
КРАСНО: i1a: … ОТКАЗ: черновик контракта не найден: 777                 rc=1
КРАСНО: i1b: контракт из корневого contracts/ принят …                  rc=1
КРАСНО: i2 ×4, i2в ×2: … NOT_IMPLEMENTED: контракт не найден: --repo    rc=1
КРАСНО: puti-vne-repo / standart-etalon / standart-narushenija / standart-polnyj-nabor: предмет отсутствует: scripts/check_project_standard.sh   rc=1 ×4
КРАСНО: i3а/i3в: дверь ищет корневой registry/contracts.tsv …; i3б/i3г: дверь зачла корневой …   rc=1
красная: предмет отсутствует ( scripts/check_project_standard.sh, …)
ИТОГ 103: rc=1   RC=1
```

**Приёмка 2** (`--model`): `ИТОГ стаб-пак 103: rc=0`, 11 клеток rc=0, `ИТОГ 103: rc=0`, RC=0.

**Приёмка 4** (tip):
- `_krasnye_095` → `ИТОГ стаб-пак 095: rc=0`, `ИТОГ 095: rc=0`, rc=0;
- `_krasnye_072` → `итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0`, rc=0;
- `pre_critic.sh contracts/103-…md` → `КРИТИК: дверь зелёная`, rc=0.

Соседи spawn/pre_critic:
- `npm run check:antiplacebo -- --scope pre_critic spawn_agent check_judge_gate` → `барьеров: 3 · фикстур: 7 · предъявлено красным повторным прогоном: 7`, rc=0;
- `fixtures/spawn_agent/red_gejt_{javnogo_nomera,manifest_tolko_na_origin,stroka_frozen_sha}.sh` → rc=0 ×3.

**Приёмка 5** (`HARNESS_PROJECT_LAYER_ROOT=. … --repo .`) → rc=1. Строки: `lockfile`, `komandy-true` ×4, `kontekst-karta: файла нет: map=ARCHITECTURE.md`. Все имена из списка 11.

**Приёмка 6** (grep контракта дословно) → пусто, rc=1.

**Барьеры дерева** (tip):
- `check_ceilings.sh .` → `потолки в порядке`, rc=0;
- `gen_ci_steps.sh --check` → rc=0;
- `check_provodka.sh . contracts/103-…md` → rc=0.

**Слияние в origin/main 21f394f4:** `CONFLICT (content): Merge conflict in NABLIUDENIA_ARCHITECT.md`, merge rc=1. Конфликт append-append в одном блоке, строки 8456–8540.
После объединения обеих сторон:
- `check_nabludenia.sh` → rc=0;
- `_krasnye_103.sh` → `ИТОГ 103: rc=0`;
- `gen_ci_steps --check` → rc=0;
- `check_ceilings` → rc=0;
- `check_provodka` → rc=0.

Номер А-917 занят дважды: ветка 103 и `origin/wip/104/implementer2:NABLIUDENIA_ARCHITECT.md:8506` (Рв96-15).
**CI:** `gh pr checks 96` → `no checks reported on the 'wip/103/implementer2' branch`, `mergeable: UNKNOWN`. На голове CI не исполнялся, доказательство здесь только мои прогоны.

## 3. Проверка не переписана под реализацию: PASS

В круге 2 implementer фикстур не касался (§1). Архитекторские правки клеток **усиливают** проверку: новые входы и варианты, плюс 7 стабов.
Своей мерой: фикстуры головы против реализации круга 1 (`r1`) краснеют ровно на дефектах круга 1:
```
КРАСНО: i2в: нога (г) не вооружена профильным реестром по резолверу при слое вне репо (rc=0, ждали 1 «форма»)
КРАСНО: i3в: дверь не видит эффективный workflowPaths.registry резолвера (… ОТКАЗ: профиль без workflowPaths.registry)
КРАСНО: i3г: дверь зачла корневой registry/contracts.tsv вместо профильного (… rc=0 …)
КРАСНО: i4а/pustoj-repo: --repo "" дал rc=1 (ждали 2 и NOT_IMPLEMENTED): … line 31: 2: parameter null or not set
ИТОГ 103: rc=1
```
Модель стандарта и продукт: список условий `git-main…harness-pin` побайтово равен (`diff` пуст). Расхождения шапки и CLI-грамматики описаны в Рв96-17.

## 4. Красное предъявлено: по Рв96-2/4/5 PASS, по Рв96-3 FAIL (Рв96-13)

Мутанты на **реальных** субъектах головы: `../mutants.sh` (каркас круга 1) и `../mutant_list.sh` (круг 2).
Якорь заменяется python-ом и обязан встретиться ровно один раз. Копия субъекта лежит в `tip/scripts/_rv_<id>.sh`, батарея гоняется через `PP103_*`.
```
[C0pc] red_pre_critic_cwd.sh=rc0      [C0sp] red_spawn_reestr_proekta.sh=rc0
[C0st] etalon=rc0 narushenija=rc0 polnyj_nabor=rc0 puti_vne_repo=rc0          ← позитивный контроль
[PC4]  нога (г): registry своим jq по R                   → red_pre_critic_cwd rc1   пойман (Рв96-2)
[PC5]  резолвер с HARNESS_PROJECT_LAYER_ROOT=R принудительно → red_pre_critic_cwd rc1   пойман (Рв96-2)
[SP3]  spawn: registry своим jq по R (+defaults под R)    → red_spawn rc1           пойман (Рв96-2)
[SP4]  spawn: резолвер с HARNESS_PROJECT_LAYER_ROOT=ROOT   → red_spawn rc1           пойман (Рв96-2)
[SP1]  манифест registry/contracts.tsv зашит              → red_spawn rc1           пойман
[ST2]  komandy-true только test                            → narushenija rc1         пойман (Рв96-4)
[ST2b] komandy-true без build                              → narushenija rc1         пойман
[ST3]  «.env в индексе» снят                               → narushenija rc1         пойман (Рв96-4)
[ST6]  «schemaVersion = 1» снят                            → narushenija rc1         пойман (Рв96-4)
[ST7]  LAYER="$R"                                          → etalon rc1              пойман (Рв96-4, A103-1)
[ST7b] env > CLI                                           → etalon rc1              пойман
[ST7c] env игнорируется                                    → etalon rc1              пойман
[ST10c] ${2:?} (как в круге 1)                             → etalon rc1              пойман (Рв96-5)
[ST1]/[ST4]/[ST5]/[ST8] (регрессия круга 1)                → rc1                     пойманы
[ST10]/[ST10b] снят guard пустого/отсутствующего --repo     → etalon rc0  эквивалентны на "" (ловит [ -n "$REPO" ]); «--repo» без значения не пришпилен — Рв96-18 (совет)
[PC3a] нога (а) пропущена на --repo                        → red_pre_critic_cwd rc0  НЕ ПОЙМАН
[PC3b] нога (б) пропущена на --repo                        → red_pre_critic_cwd rc0  НЕ ПОЙМАН
```
Оба PC3 сразу (`../mut_pc3`) дают `ИТОГ 103: rc=0`. Проба `probe_pc3.sh` под ними: `спек-гейт 036: замер расходится: заявлено 99, команда даёт 2` rc=1, а `pre_critic --repo R` → `КРИТИК: дверь зелёная` rc=0.
Это ровно дефект круга 1, и батарея его не видит (Рв96-13). На голове без мутанта та же проба → `ОТКАЗ: spec-ready красен: tasks/h/998-lozhnyj-zamer.md` rc=1, то есть код верен.

Живые пробы круга 1 на голове, слой вне репо:
```
probe2 drop:  resolver {"value":"tasks/reg","origin":"project"} rc=0 · spawn BRANCH=wip/777/implementer rc=0     (было: ОТКАЗ профиль без workflowPaths.registry)
probe3 drop:  spawn ОТКАЗ: тег 777 не выдан авторитетом: sha манифеста (000…007) ≠ sha тега … (3в) rc=1          (было: rc=0 по корневому реестру)
probe_pc4:    ОТКАЗ: форма: контракт без строк КОНТЕКСТ: rc=1                                                    (было: дверь зелёная)
probe_pc3:    ОТКАЗ: spec-ready красен rc=1                                                                       (было: дверь зелёная)
```
Своей мерой: `grep -cE '^zapest s[0-9]+ '` = 21. Различных маркеров в стабах 16, в моделях тоже 16. Клеток `find … -name 'red_*.sh'` = 11, `case_*.sh` = 0.
Это сходится с заявленным в dc094da1 («21 стаб на 16 маркерах», «замер 11 не меняется»). Контракт в §Приёмка говорит «14 на 10», см. Рв96-19.

## 5. Атомарность: PASS с повтором замечания (Рв96-7)

Каждая находка закрыта своим коммитом со ссылкой «Рв96-N».
5cd8274a в изоляции красный: `c5cd`, `red_pre_critic_cwd.sh` → `КРАСНО: i2: полный контракт … rc=1 (ждали 0): ОТКАЗ: precision-gate красен`. Проба probe_pc2 на нём → `precision-гейт 043: паритет CI красен (verify_ci_parity.sh rc 2): NOT_IMPLEMENTED: нет …/.github`.
Причина: починка toy 5f2301f5 стоит позже по истории.

## 6. Норма не тронута молча: PASS

Контракты, роли и нормы не правились. Отступление круга 1 от Frontier И-2 (Рв96-3) снято в коде.
Решение «ноги вооружены, toy чинится» записано А-917 в NABLIUDENIA, в зоне architect. Открытой остаётся только коллизия номера (Рв96-15).

## 7. Заявленное равно сделанному: PASS с замечанием (Рв96-16)

- Заявления 24f6ab2e подтверждены своими прогонами (§4): probe2 → rc0 BRANCH, probe3 → rc1 «не выдан авторитетом», probe_pc4 → rc1 «форма».
- Заявление 5f2301f5 «`check_precision_gate.sh R tasks/h/777-toy.md` → OK rc 0» подтверждено: probe_pc2 на голове, precision `OK` rc=0.
- Заявления 5cd8274a «probe_pc2 (пустой контракт) → rc 1» и «probe_pc3 → precision-gate красен» на голове **не** подтверждаются. probe_pc2: precision OK, spec OK, `КРИТИК: дверь зелёная` rc=0. probe_pc3 отказывает по spec-ready.
  Замеры сняты на toy до починки (Рв96-16).
- Заголовок 171229b1 «строка … переписана реальной implementer-сессией»: сессия вписала строку сама, но байт-в-байт, поэтому blame остаётся за 3936e061 (хвост Рв96-1).

## ПРОВОДКА (038)

Не менялась: `guard=fixtures/_krasnye_103.sh`, строка `check:project-paths-103-family-selftest` (`registry/ci-steps.tsv:79`), `check_provodka.sh` → rc=0 на tip и на слиянии.
Guard — барьер именно этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно. На голове guard в CI не исполнялся (§2).

## Паразитная сложность (050), артефакты круга 2

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| вызов `profile_resolver.sh` в spawn (`MANIFEST_REG`) и pre_critic (`_arm_reg_dir`) | Предмет «resolver — единственный источник», И-2/И-3 | явное: MERGED, отказ резолвера печатается | было 4 (resolver, spawn, pre_critic, модель), стало 1 источник + 3 вызова | интерфейс не вырос | клетки i2в, i3в, i3г | ESSENTIAL |
| placeholder `ci.workflow` в spawn:183-202 и pre_critic:188-207 (`jq .ci.workflow` репо-слоя, `mkdir -p`, `: >`, `rm -f` без trap) | никакое: Предмет — чтение, toy несёт ci-файл (А-917), модели без него | **скрытое**: пишет в дерево проекта, оставляет каталоги, гасит отказ резолвера (`probe_ph.sh`) | 3 копии одной обвязки (make_task, spawn, pre_critic) | мелкий: 10 строк ради невидимого побочного эффекта | ни одной строки приёмки (`mut_ph`: 103/095/072 rc 0) | **ACCIDENTAL — блок Рв96-14** (фрагмент + отсутствующее свойство + более простая форма) |
| безусловные ноги (а)/(б) в pre_critic | Frontier И-2 | нет | 1 | ветка `GATE_ROOT=""` удалена, модуль стал проще | нет клетки (Рв96-13) | ESSENTIAL |
| `--repo`/`--layer-root` guard в `check_project_standard.sh` (+10) | rc-таксономия И-4 «rc 2 — нечем проверить» | нет | 2 (продукт + модель), не выросло | +0 флагов | клетка pustoj-repo | ESSENTIAL |
| `_t103_world_sloj_vne` и CI-поверхность паритета в `_t103_world` | Рв96-2 (слой вне репо), Остаточный риск И-2 | миры в `/tmp/dev-harness-verify/project-paths-103-*` | 1 | — | i2в, i3в, i3г; ноги (а)/(б) на toy | ESSENTIAL |
| вызов резолвера в моделях `dver_reestra`/`pre_critic_proekta` + чтение env `PP103_ROOT` | анти-тавтология `--model` по Рв96-2 | env `PP103_ROOT` экспортирует раннер (`_krasnye_103.sh:30`, `battery_stubs.sh:41`) | 1 | — | приёмка 2, стабы s20/s21 | ESSENTIAL |
| семья клеток и стабов (+7 стабов, входы в 4 клетках), одним артефактом | И-2, И-3, И-4а/б (Рв96-4) | — | 1 семья | — | ПРОВОДКА guard | ESSENTIAL; полнота — Рв96-13 |
| `NABLIUDENIA_ARCHITECT.md` А-917 | ПЕРЕСЕЧЕНИЕ architect 015 | — | 1 | — | — | ESSENTIAL; номер — Рв96-15 |

## Итог

| находка | класс | блок |
|---|---|---|
| Рв96-1 | закрыт по существу: содержимое переписали реальные сессии (patch-id в §0); хвост — b72388fb/3936e061 в истории, blame 1+1 строки | нет (хвост → orchestrator) |
| Рв96-2 | закрыт: spawn и нога (г) берут registry из резолвера; probe2/probe3/probe_pc4 перевёрнуты; PC4/PC5/SP3/SP4 пойманы клетками i2в/i3в/i3г | — |
| Рв96-3 | код закрыт: ноги вооружены, toy починен, probe_pc3 → rc1. Барьерный хвост → Рв96-13 | — |
| Рв96-4 | закрыт: ST2/ST3/ST6/ST7 (+ST7b/c) пойманы, слой вне репо в клетках | — |
| Рв96-5 | закрыт в продукте: `--repo ""` / `--repo` / без аргументов → rc 2 NOT_IMPLEMENTED; `--layer-root` без значения → usage rc 2 | — |
| **Рв96-13** | дыра батареи: снятие ног (а)/(б) на `--repo` (PC3a/PC3b, реализация круга 1) — `ИТОГ 103: rc=0` | **да** (architect) |
| **Рв96-14** | 050 ACCIDENTAL с полной тройкой: placeholder `ci.workflow` в spawn/pre_critic пишет в дерево проекта и гасит отказ резолвера; без него приёмки 3/4/6 зелёные | **да** (implementer) |
| Рв96-6 | повтор: транспорт cherry-pick-ом Main под ролевыми committer | нет |
| Рв96-7 | повтор: 5cd8274a красный в изоляции | нет |
| Рв96-8/9/12 | советы круга 1 без изменений | нет |
| Рв96-10 | закрыт 171229b1 | — |
| Рв96-11 | фикстуры — fable (Anthropic), судья — Anthropic | нет |
| Рв96-15 | конфликт NABLIUDENIA с main; А-917 занят дважды (103 и 104); CI на голове не исполнялся | нет (→ orchestrator, до ленда) |
| Рв96-16 | заявления 5cd8274a о probe_pc2/probe_pc3 не подтверждаются на голове | нет |
| Рв96-17 | шапка продукта без приоритета слоя; `--layer-root` без значения расходится с моделью | нет |
| Рв96-18 | `--repo` без значения не пришпилен клеткой | нет (совет) |
| Рв96-19 | «14 стабов на 10 маркерах» в замороженной прозе, факт 21/16 | нет |

Для ленда нужно:
- клетка и стаб на ноги (а)/(б) `--repo` (Рв96-13);
- убрать placeholder из spawn и pre_critic (Рв96-14);
- до слияния: снять конфликт NABLIUDENIA и коллизию А-917, прогнать CI на голове (Рв96-15).

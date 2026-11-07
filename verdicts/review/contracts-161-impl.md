FAIL

OBJECT=1301af07d5d013b661aae3f5bf5f05f64995c4f5
НОСИТЕЛЬ=origin wip/161/implementer-r5 tip 3782c619d94092f77e8baa0e1b1b97218c7390bb (PR #584; merge-base с main 847674bf3). Блобы предмета равны OBJECT: scripts/make_task.sh=bef551cc, scripts/spawn_agent.sh=cd3846b3, fixtures/workshop_project/proektnaja_raskladka_161=cf55c5df (`git rev-parse HEAD:<путь>` в клоне и `1301af07d:<путь>` в общем .git дают одинаковые значения).
КЛАСС=КОДОВЫЙ, РИСКОВЫЙ
СУД: repo=dev-harness (контракт frozen/contracts/161/1); предмет=161; фаза=реализация; роль=reviewer; вызов=1 (полный); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; сессия=Reviewer161Opus; предыдущий=verdicts/adversary/contracts-161-impl-r4.md (accept, scoped)
НЕЗАВИСИМОСТЬ: автор реализации — implementer (MiniMax-M3), автор клеток — architect; адверсарий — openai-codex/gpt-5.6-terra (r2 FAIL, r3 FAIL, r4 accept); судья — Anthropic. Двухвендорная пара вне семейства автора соблюдена.
НАХОДКИ: блок implementer Р161-1 — reslop-блок «Находки» в конце этого файла (status: ready). Файл .review/2026-11-07-82.md с тем же текстом отклонён pre-commit-гейтом зон («ОТКАЗ: вне зоны: .review/2026-11-07-82.md»), поэтому оркестратор переносит блок в .review/ сам. Советы С-1…С-8 — ниже.
Испытания: одноразовый клон /tmp/dev-harness-verify/Reviewer161Opus/clone (ssh://git@github.com/a3ka/dev-harness.git, ветка wip/161/implementer-r5). GIT_DIR и GIT_WORK_TREE на основной чекаут не использовались.

## Вердикт

FAIL. Блокирующая находка одна.

- **Р161-1** (контракт 161 п. 2 «манифест … вне основного checkout и его .git; живой main …
  неизменными»; закрывающее свойство FAIL r2 «канонически вне всех его checkout/.git»).
  Безопасность внешнего state проверяется только для канонической базы TMPDIR
  (`make_task.sh:344-356,365`). Итоговый путь `$base/dev-harness-project-state/$KEY/context`
  строится конкатенацией (`:371,780`) и пишется без повторной канонизации (`:781-783`). Пусть база
  TMPDIR безопасна, а `dev-harness-project-state` в ней — ссылка внутрь main. Тогда настоящий
  `make_task` из project-worktree даёт rc 0 и пишет манифест в рабочее дерево main:
  `main status after: [?? .omp-trap/369b6d406219a363/context/761.tsv]`. Это тот же класс,
  что TMPDIR→main в r2, на один уровень глубже. Актор, который выбирает TMPDIR, распоряжается и его
  содержимым. Полное ОБЯЗАТЕЛЬСТВО/СОСТОЯНИЕ/НАБЛЮДЕНИЕ/закрывающее свойство — в блоке «Находки» ниже.

Всё остальное, что назначено ревьюеру, проверено и соответствует (ниже). Советы не блокируют.

## 1. Область правки

Своя мера — `git diff --name-only origin/main...HEAD` в клоне и `git diff --name-only bcba1eec4 1301af07d`
в общем .git дают одинаковый результат:

```text
fixtures/workshop_project/proektnaja_raskladka_161/SPEC.md
fixtures/workshop_project/proektnaja_raskladka_161/probe.py
scripts/make_task.sh
scripts/spawn_agent.sh
```

ЗОНА-строки frozen-блоба: `ЗОНА architect: contracts/161-…md fixtures/workshop_project/proektnaja_raskladka_161/`,
`ЗОНА implementer: scripts/make_task.sh scripts/spawn_agent.sh`. Авторы по коммитам
(`git log --format='%h %an' origin/main..HEAD --name-only`): implementer — 3782c619, 0d7e23dc,
d2422c70, 6e583df6, только scripts/make_task.sh и scripts/spawn_agent.sh. Architect — 61b0f26e,
0a480a30, 151d4688, c20d3379, bed6aeec, только SPEC.md и probe.py. Чужих путей нет. Нормативные
документы не тронуты.

## 2. Сырой вывод (свой прогон в клоне, HEAD 3782c619)

```text
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh
mode=bare rc=0 secs=7          (stdout 0 байт, stderr 0 байт)
$ … --model
mode=--model rc=0 secs=3
CONTROL: honest product green
$ … --stabs
mode=--stabs rc=0 secs=22
CONTROL: honest product green
STAB_CAUGHT: optional-skipped: CONTEXT_FOREIGN: missing exact REUSE: docs/reuse.md
STAB_CAUGHT: foreign-make: CONTEXT_FOREIGN: make_task
STAB_CAUGHT: foreign-write: FOREIGN_DIRTY: make_task changed foreign project
STAB_CAUGHT: missing-spawn: MANIFEST_MISSING:
STAB_CAUGHT: collision-spawn: STATE_KEY_COLLISION: second project accepted first manifest
STAB_CAUGHT: git-path-spawn: GIT_PATH_COLLISION: second project accepted first manifest
STAB_CAUGHT: tmpdir-write: STATE_SAFE_MAIN_DIRTY: issued packet wrote into checkout
STAB_CAUGHT: hash-ignored: HASH_TOOL_UNUSABLE: packet issued with failing hash tool
```

Регрессы затронутых frozen-барьеров:

```text
$ bash fixtures/_krasnye_095.sh .                              → 095 rc=0 (последняя строка «ИТОГ 095: rc=0»)
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh  → 136 rc=0 («sessii_136: клеток 87, зелёных 87, красных 0»)
$ bash fixtures/_krasnye_103.sh <клон>                          → 103 rc=0 («ИТОГ 103: rc=0»)
$ bash fixtures/spawn_agent/red_gejt_javnogo_nomera.sh          rc=0
$ bash fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh rc=0
$ bash fixtures/spawn_agent/red_gejt_stroka_frozen_sha.sh       rc=0
$ bash fixtures/context_pack_095/red_dver_spawn_manifest.sh     rc=0
$ bash fixtures/project_paths_103/red_spawn_reestr_proekta.sh   rc=0
```

`case_*.sh` семьи spawn_agent запускаются только через раннер verify_antiplacebo (каналы WORK и BARRIER).
Их судит CI-шард ap3 (`keys: … spawn_agent`), он pass.

CI PR #584 (`gh pr checks 584 --repo a3ka/dev-harness`, после `--watch`): rc=0. Pass у ap1–ap5,
l1–l7, klass, legkij, obshchij, tyazhelyj-itog; vorota — skipping. `gh run view 42411547238`:
`{"conclusion":"success","headSha":"3782c619d94092f77e8baa0e1b1b97218c7390bb","status":"completed"}`.

## 3. Проверка не подогнана под реализацию

Своя мера — `git diff frozen/contracts/161/1^{commit} 1301af07d -- fixtures/…/proektnaja_raskladka_161/`.
Изменение существующих проверок одно: снимок для `FOREIGN_DIRTY: spawn` берётся
непосредственно перед spawn (`foreign_spawn_before`), а не перед make_task (bed6aeec). Это не ослабление.
Запись make_task в чужой проект ловит своя проверка `FOREIGN_DIRTY: make_task`, запись spawn —
новый снимок. Прежняя форма засчитывала одну запись дважды, и подсчёт кратности в `--stabs`
ломался. Остальное в дельте только добавляет клетки: две пары коллизии ключа (PATH-`sha256sum` и
PATH-`git`), TMPDIR в main, symlink на main, `.git` main с `tree_fingerprint`, безопасный TMPDIR, sha256sum rc 127
и четыре новых стаба. `--repo/PROBE_161_ROOT` меняет только корень дверей. Без флага корень
прежний. Клетки ловят обманные подмены TMPDIR/PATH/HASH/GIT на собственных входах, а не
выход реализации: см. п. 4.

## 4. Красное предъявлено (тот же барьер с `--repo` на worktree клона в базовых SHA)

```text
red base=847674bf (до реализации)  bare rc=1  --model rc=0  --stabs rc=1
  bare: MANIFEST_MAIN_ONLY: no unique external manifest before spawn
        PROFILE_PATH_MISSING: absent optional row accepted
        TMPDIR_INSIDE_MAIN: checkout|symlink|gitdir: package not refused before output
        HASH_TOOL_UNUSABLE: packet issued with failing hash tool
  --model: CONTROL: honest product expected red: MANIFEST_MAIN_ONLY, PROFILE_PATH_MISSING
  --stabs: 4 базовых STAB_CAUGHT, затем «STAB_ZHIV: collision-spawn: []»  (см. С-2)
red base=d2422c70 (r1 реализации)  bare rc=1  --model rc=0  --stabs rc=0
  bare: STATE_KEY_COLLISION (worktree …/dev-harness-worktrees/00000000/wip-761-architect),
        GIT_PATH_COLLISION, TMPDIR_INSIDE_MAIN+TMPDIR_MAIN_DIRTY ×3, HASH_TOOL_UNUSABLE ×2
red base=0d7e23dc (r2 реализации)  bare rc=1  --model rc=0  --stabs rc=0
  bare: GIT_PATH_COLLISION: second project accepted first manifest; second branch created; second worktree created
```

Каждый барьер, добавленный после заморозки, красный против кода, который он закрывает. Красная
база контракта даёт ровно двухклассовый контроль.

## 5. Атомарность

Девять коммитов. Каждый несёт номер предмета и один шаг круга: implementer r1 и r1-доводка,
r2 (TMPDIR/sha256), r3 (git). Architect r2/r3 — клетки и SPEC. Связок нет.

## 6. Соответствие предмету 161

- Манифест вне основного checkout. Вход из project-worktree пишет в
  `<канон. TMPDIR>/dev-harness-project-state/<sha256(common .git)[:16]>/context/<NNN>.tsv`. Клетка
  `MAIN_DIRTY` и `tree_fingerprint` зелёные. Обход через symlink подкаталога — **Р161-1**.
- LAYER_FOREIGN до выдачи пакета. make_task: проверка (`make_task.sh:392-400`) стоит до HEALTH,
  placeholder, profile_resolver и записи. spawn: до `_project_state_prepare`, i15 и dual-control
  (`spawn_agent.sh:249-262`). Клетки `LAYER_FOREIGN: … partial pack / branch / worktree` зелёные.
- spawn читает манифест до тега и worktree. `i15_gate` стоит первым в ветви явного `--nnn`, до
  `show-ref id/CONTRACT`. Номер 762 без манифеста → «нет манифеста make_task: 762», ветки нет
  (клетка `MANIFEST_MISSING` и стаб missing-spawn).
- Legacy-поток станции из main сохранён. make_task с `--repo <main>` пишет `<repo>/.omp/context/<NNN>.tsv`,
  spawn читает его запасным путём. 095 rc=0, red_dver_spawn_manifest rc=0. Поток Н-301 со
  станционным worktree меняется — см. С-1.
- Dual-control не ослаблен: три red_gejt_* семьи spawn_agent rc=0, ap3 pass. Изменения 023-блока
  только заменяют `git` на `$GIT_BIN`.

## 7. Счётные утверждения своей мерой

- «8 STAB_CAUGHT»: grep-инструментом по `^STAB_CAUGHT: ` в stderr своего `--stabs` — 8 строк
  (4 базовых + 4 новых). Подсчёт ветвей `stub_invoke` в исходнике — 7 ветвей на 8 имён:
  collision-spawn и git-path-spawn делят одну ветвь. Сходится.
- «136: 87/87»: своя строка вывода — «клеток 87, зелёных 87, красных 0».
- Заявка адверсария r4 о блобах (`make_task.sh=bef551cc…`, `spawn_agent.sh=cd3846b3…`) сверена
  `git rev-parse` в двух деревьях — совпадает.
- SPEC.md соответствует коду: семь bare-исходов `__main__` равны перечню SPEC «Внешний state /
  подмена git / неприемлемый TMPDIR», четыре новых стаба — абзацу про `--stabs`. Расхождение — С-2.

## ПРОВОДКА (контракт 038)

`guard=fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh` — барьер
именно этого предмета: он запускает настоящие make_task/spawn_agent/zamok. При этом:

```text
$ bash scripts/check_provodka.sh . contracts/161-revizija-mekhanizmov-proektnaja-raskladka.md
проводка: guard не подключён: fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh не вызывается в .githooks/ или .github/workflows/
rc=1
```

В registry/ci-steps.tsv строки 161 нет. Подключение — интеграционный коммит оркестратора
(прецедент 136, ci-steps.tsv:130). Это вне зон 161. Блок done, не реализации — С-3.
Строка ПРОВОДКА-ЭНФОРСМЕНТ («механическая проверка внешнего манифеста и запрета worktree без него»)
обоснована честно: поведенческой нормы 029-класса в предмете нет.

## Паразитная сложность (контракт 050)

- `GIT_BIN` из закрытого списка /usr/bin→/bin→/usr/local/bin (оба скрипта). (1) GIT_PATH_COLLISION
  (п. 2, «spawn находит именно манифест этого проекта»). (2) Состояние неявное: выбор бинарника нигде
  не печатается, только rc 2 при отсутствии. (3) Два файла, как и до диффа. (4) Интерфейс не вырос, нового
  флага или env нет. (5) Потребитель — клетка git-path-spawn и bare GIT_PATH_COLLISION. ESSENTIAL.
- `_hash_*`: двойной хеш — PATH-sha256sum проверяется на rc и форму, значение берётся из доверенного.
  (1) STATE_KEY_COLLISION и HASH_TOOL_UNUSABLE. (2) Явно: отказ HASH_TOOL_UNUSABLE. (3) Два файла.
  (4) Мелко: результат PATH-инструмента вычисляется и выбрасывается. (5) Без него краснеют клетки
  HASH_TOOL_UNUSABLE и hash-ignored: более простая форма «только доверенный» строки приёмки не проходит.
  ESSENTIAL относительно клеток. Сама клетка — С-4.
- Блок state (`_git_common_dir`, `_state_base_canonical`, `_state_worktree_paths`, `_state_base_is_safe`,
  `_project_state_prepare`, ~70 строк) дословно в обоих скриптах. (1) п. 2, общий каталог двух дверей.
  (2) Новый каталог `$TMPDIR/dev-harness-project-state/<key>/context`. Он виден только побочным
  эффектом: путь манифеста не печатается ни в stdout пака, ни в отказе spawn. (3) Правка ключа
  требует двух файлов. Раньше их тоже было два (`.omp/context` в обоих), объём вырос. (4) Без новых флагов,
  читает TMPDIR. (5) Общая библиотека потребовала бы файл вне ЗОНЫ implementer, поэтому дубль
  вынужден зоной. ESSENTIAL под зоной, С-5.
- LAYER_FOREIGN (оба скрипта). (1) п. 1. (2) Явно: отказ с путём. (3) Два файла. (4) Без интерфейса.
  (5) Клетки CONTEXT_FOREIGN/LAYER_FOREIGN. ESSENTIAL. Граница маркера — С-6.
- `_PACK_FROM_WORKTREE` и ветвь PROFILE_PATH_MISSING (make_task). (1) п. 1 и И-3 095 для main.
  (2) Явно по входу (git-dir ≠ common-dir). (3) Один файл. (5) Клетка PROFILE_PATH_MISSING и 095.
  ESSENTIAL. Последствие — С-1.
- Запасное чтение `<root>/.omp/context` в `i15_gate`. (1) Legacy-поток и замороженная клетка 095
  red_dver_spawn_manifest. (5) Она же. ESSENTIAL.
- Клетки architect (семья collision/tmpdir/safe/hash, `tree_fingerprint`, `--repo`). (1) Классы FAIL r2/r3.
  (5) bare/`--stabs` и раннер распаковки носителя. ESSENTIAL.

## СВЕРКА-СТАНДАРТОВ

СВЕРКА-СТАНДАРТОВ: не применяется. AGENTS.md dev-harness не объявляет документ архитектуры и
стандарт кода (grep `ARCHITECTURE\.md|CODING-STANDARDS\.md` по AGENTS.md пуст). sourceCanon в
harness.project.json не объявлен (`jq .sourceCanon` → нет), поэтому сверка 996 не применяется.

## Советы (не блокируют; автор закрывает по усмотрению либо передаёт владельцу)

- **С-1 (вопрос владельцу/оркестратору — станционный Н-301).** На самой станции
  `make_task --repo <linked worktree станции> --role architect` теперь отказывает:
  `ОТКАЗ: источник недоступен: ARCHITECTURE.md (PROFILE_PATH_MISSING)`, rc 1, stdout 0 байт. До
  реализации (скрипты 847674bf) тот же вызов давал rc 0 и 3809 байт. Причина — профиль станции
  объявляет optional-строки без файлов (CODING-STANDARDS.md, ARCHITECTURE.md, consumers.d нет ни
  в клоне, ни в живом main). Поведение буквально требует п. 1 контракта, дефекта реализации нет. Но
  документированная процедура бутстрапа Н-301 (NABLIUDENIA.md:7838, HANDOFF 2026-10-20 для 111/115)
  на станции для architect/implementer/reviewer перестанет работать, а механизм 161a неприменим к
  станции, пока профиль не приведён к дереву. Решение — гигиена профиля или слово владельца, не зона 161.
- **С-2 (architect).** Вне фазы. Четыре стаба после заморозки (collision-spawn, git-path-spawn,
  tmpdir-write, hash-ignored) не различающие на базе до реализации. На 847674bf `--stabs` даёт rc 1
  `STAB_ZHIV: collision-spawn: []`, а правило контракта «`W --stabs` … rc 0, если каждая подмена
  поймана» относится к обоим честным состояниям. После слияния база недостижима, поэтому это совет.
- **С-3 (оркестратор).** Подключить guard в ci-steps.tsv и сгенерировать ci.yml до done (check_provodka rc 1).
- **С-4 (architect).** Клетка HASH_TOOL_UNUSABLE требует исправный PATH-`sha256sum`, хотя его
  значение не используется. Для `git` такого требования нет: PATH-git игнорируется. Асимметрия
  сохраняет вычисление ради клетки.
- **С-5 (implementer).** Дубль ~70 строк state-блока в двух скриптах и молчаливый путь манифеста. Путь
  внешнего манифеста стоит назвать хотя бы в отказе spawn «нет манифеста make_task», чтобы
  состояние было видно в выводе.
- **С-6 (implementer).** Маркер LAYER_FOREIGN — git-корень слоя плюс `harness.project.json` в корне
  слоя. Копия чужого слоя вне git или в подкаталоге чужого проекта проходит без отказа. Это
  совместимо со слоем-клоном 054, но остаётся остатком; его стоит назвать в «НЕ ЗАЩИЩАЕТ»
  следующей версии.
- **С-7 (implementer, переносимость).** Закрытый список /usr/bin, /bin, /usr/local/bin для git и
  sha256sum: хосты без них (NixOS, Homebrew-Linux, macOS без coreutils) получат rc 2 и в legacy-потоке
  станции. На текущей станции и CI-ubuntu это недостижимо.
- **С-8 (implementer, док).** Шапка `spawn_agent.sh` «ОТКАЗЫ rc 1 (поимённо)» не перечисляет новые
  отказы `HASH_TOOL_UNUSABLE`, `TMPDIR_UNAVAILABLE`, `TMPDIR_INSIDE_MAIN`. В make_task имя
  legacy-манифеста теперь всегда `%03d` (`--contract 95` → `095.tsv`, раньше `95.tsv`) — изменение
  к лучшему, совпадает с чтением spawn, но не названо. Строковая (без канонизации) проверка
  worktree-базы spawn (`spawn_agent.sh:519-536`) — прежнее поведение, к Р161-1 не относится.

## Находки (reslop; status: ready; для переноса в .review/2026-11-07-82.md)

```yaml
status: ready
subject: 161 — revizija-mekhanizmov-proektnaja-raskladka (161a), суд реализации
object: 1301af07d5d013b661aae3f5bf5f05f64995c4f5 (локальная wip/161/implementer; на origin тот же код — wip/161/implementer-r5 tip 3782c619d94092f77e8baa0e1b1b97218c7390bb, PR #584; блобы make_task.sh=bef551cc, spawn_agent.sh=cd3846b3, каталог батареи=cf55c5df совпадают)
verdict: verdicts/review/contracts-161-impl.md (FAIL)
reviewer: reviewer (сессия Reviewer161Opus; anthropic/claude-opus-5-5; вызов 1, полный)
```

### Блоки implementer


- [ ] **Р161-1 — внешний state проверяется «вне checkout» только по базе TMPDIR; итоговый
  каталог манифеста может разрешаться внутрь main.**
  ОБЯЗАТЕЛЬСТВО: контракт 161 п. 2 (frozen/contracts/161/1): «Живой main и его индекс
  остаются неизменными после подготовки пакета, манифест живёт во внешнем state (вне основного
  checkout и его `.git`)». Это же закрывающее свойство назвал FAIL адверсария r2
  (`verdicts/adversary/contracts-161-impl-r2.md`): «база state и её ключ … канонически вне всех
  его checkout/.git». Класс r2 (TMPDIR) объявлен закрытым коммитом 0d7e23dc; он закрыт только
  на уровне базы.
  Класс причины: канонизация и проверка безопасности (`_state_base_is_safe`,
  `scripts/make_task.sh:344-356`, вызов `:365`) применяются к `pwd -P` базы TMPDIR. Путь
  записи строится конкатенацией `$base/dev-harness-project-state/$KEY/context`
  (`:371`, `:780`). Затем `mkdir -p` и запись идут без повторной канонизации (`:781-783`). Компонент
  `dev-harness-project-state` (или `<KEY>`, или `context`) внутри безопасной базы может быть
  символьной ссылкой в checkout или в `.git`. Тогда запись проходит через неё.
  Источник входа: тот же, что у принятой r2-атаки «TMPDIR указывает на main / на symlink на
  main». Тот, кто задаёт TMPDIR, распоряжается и его содержимым. Ссылка с фиксированным
  именем `dev-harness-project-state` в выбранной им базе — то же действие на один уровень
  глубже. Содержимое проекта конформно: валидный профиль, черновик только в отдельном worktree,
  main без черновика.
  СОСТОЯНИЕ: проект `main` + worktree `draft` (ветка wip/759/architect, черновик 761 только
  там). `T=<каталог вне проекта>`, `mkdir "$M/.omp-trap"` (пустой каталог, `git status` пуст),
  `ln -s "$M/.omp-trap" "$T/dev-harness-project-state"`.
  НАБЛЮДЕНИЕ (одноразовая проба `/tmp/dev-harness-verify/Reviewer161Opus/probe_symlink_state.sh`
  на скриптах OBJECT):
  ```text
  $ TMPDIR="$T" bash scripts/make_task.sh --repo "$D" --role architect --kind task --contract 761
  make_task rc=0 stdout_bytes=1200 stderr=
  main status before: []
  main status after:  [?? .omp-trap/369b6d406219a363/context/761.tsv]
  ```
  Пакет выдан с rc 0, а манифест записан внутрь рабочего дерева main. Статус main изменился.
  Тот же путь через ссылку в `$M/.git/…` пишет в `.git`.
  Закрывающее свойство: каталог, в который фактически пишется манифест, после создания и
  канонизации (`pwd -P` итогового `context`) лежит вне каждого checkout проекта и вне его
  общего `.git`. Иначе дверь отказывает `TMPDIR_INSIDE_MAIN` до записи и без stdout. Более
  простой формы, проходящей те же строки приёмки, нет: проверка базы уже есть, и не хватает
  ровно проверки итогового пути.
  Клетка для architect (в его зоне `fixtures/workshop_project/proektnaja_raskladka_161/`):
  вход «безопасная база TMPDIR, `dev-harness-project-state` — symlink в main и в `.git` main»
  с тем же снимком `tree_fingerprint`/HEAD/index/status, что у `tmpdir_must_not_enter_main`.
  Сейчас эта клетка зелёной на OBJECT не будет — это и есть предъявленное красное.

  Позиция автора: — (заполняет оркестратор)

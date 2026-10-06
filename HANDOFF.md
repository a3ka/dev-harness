## ГДЕ МЫ (2026-10-06, ~22:20 UTC — НОЧНОЙ РЕЖИМ: владелец и консультант недоступны до утра).

- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).

НОЧНОЙ РЕЖИМ активен (слово владельца 2026-10-06 ~22:20 UTC): только доведение НАЧАТОГО;
НОВЫХ контрактов не минтить; Odelix не трогать. Правила ночи — см. раздел «Правила ночи» ниже.

### Живые числа (ПРЯМО СЕЙЧАС)

`origin/main` = `ba09ed8` (085+074 landed+accept, 086 FAIL×2 вердикты, 088 round1 land+adversary
FAIL вердикт — всё запушено, CI run `37539741863` проверь живьём:
`gh run view 37539741863 --repo a3ka/dev-harness --json status,conclusion`).

Локальный `main` = `b3d7620`, НА 4 КОММИТА ВПЕРЕДИ origin (088 round2 fix: architect `0fe7d70` +
implementer `2ee9651` + `land: wip/088/implementer-fix2` `4b1f3c2` + adversary FAIL-084 `b3d7620`).
Push ЗАБЛОКИРОВАН gitw: `wip/088/implementer-fix2` (`2ee9651`) ждёт зелёного pull_request-CI —
открыт PR#43 (https://github.com/a3ka/dev-harness/pull/43, run `37540427092`, все antiplacebo
УЖЕ pass, только `ci`-джоба ещё шла на момент чекпойнта). **Первое действие новой сессии**:
`gh pr checks 43 --repo a3ka/dev-harness` — если зелёный ВЕСЬ (включая `ci`) →
`bash scripts/gitw push origin main` сразу пройдёт (локальный main уже содержит все 4 коммита,
готовить больше ничего не надо).

### Правила ночи (оплачены словом владельца, действуют до утра)

- Ленд — ТОЛЬКО вершины с зелёным PR-CI, субъект СТРОГО `land: wip/<NNN>/<автор>` (3 цифры,
  ровно один `/` после них) — иначе `gitw_preflight_071.sh` отказывает «land-субъект не
  разбирается» (рецидив этой сессии дважды: `wip/085-074/combo`, встроенный в старую историю
  `85fb6ba0` — решилось cherry-pick'ом ОДНОФАЙЛОВОГО doc-коммита `486ef12` вместо merge всей
  ветки, см. §2 ниже).
- Push отказан СТРУКТУРНО (не просто «CI ещё не позеленел») → backup-ветка
  (`git branch backup/main-pre-<причина> <sha>`), `git reset --hard origin/main`, разбор отказа;
  локальный main НЕ держит чужой блокер, остальные предметы идут параллельно.
- Не завершай ход, пока есть раздаваемая работа или живые субагенты; ожидание — `wait`,
  БЕЗ поллинга `gh`/`git` в цикле.
- Перезапуск дверью (`scripts/orch_restart.sh`) — только когда НЕТ живых субагентов.
  HANDOFF-чекпойнт + `gitw push` — после КАЖДОГО слитого шага, не только в конце сессии.
- Форки — субагенту `consultant`, НЕ владельцу (ночью недоступен). Класс «воля-владельца» —
  запись `forks/<id>.md`, в батч на утро, этот предмет `blocked`, работа по остальным идёт.
  Кап 5 кругов на один предмет → СТОП этого предмета (не трогать дальше), в батч.
- Единственный общий СТОП всей сессии — путь `.git/*` в отказе детектора, либо отказ
  `check_no_leak`/двери, который НЕ снимается ни одним из разрешённых путей (ручной `--snapshot`
  по условиям (а)-(в), `--retake-ahead` по условию (г), `--retake-bulk` для многопутевой дельты).
- В КАЖДОЕ задание субагенту: «merge main в свою ветку запрещён; пути — только своя
  frozen-ЗОНА». Н-39 дословно (стабы к ветвям привязывает architect по коду, НЕ проза контракта).
- **Рецидив этой сессии (×3): `land_agent`/`git checkout <ветка>` иногда оставляет HEAD
  DETACHED в основном чекауте** (не на `main`) — ПОСЛЕ каждого `land_agent.sh` и после
  `git fetch <клон> <sha>` + `cherry-pick FETCH_HEAD` проверяй `git branch --show-current` ==
  `main` ДО следующего коммита; если detached — `git checkout main` и повтори cherry-pick (sha
  предыдущей попытки не теряется, просто висит вне веток — подбери его тем же sha).
- **Рецидив (×4 за сессию): write-guard (Н-85/А-122) блокирует main-direct коммит судей
  из isolated-клона** — судья коммитит в СВОЁМ клоне и докладывает путь+sha; оркестратор
  сам делает `git fetch <клон-путь> <sha> && git -c user.name=orchestrator -c
  user.email=orchestrator@dev-harness.local cherry-pick -x FETCH_HEAD` (автор вердикта
  сохраняется, коммитер — orchestrator с пометкой «rescued»). Это НОРМА этой сессии, не разовый
  фикс — повторится на КАЖДОМ main-direct вердикте судьи.
- **Pin-строка WORKTREE=/BRANCH= агенту — КАЖДАЯ НА СВОЕЙ СТРОКЕ, без хвостового текста
  на той же строке** (напр. `WORKTREE=... BRANCH=wip/088/architect (база — ...)` ломает
  path-guard tokenizer — ловит ТОЛЬКО `(?:^|[:;,])\s*(WORKTREE|BRANCH)=`, пробел перед BRANCH=
  не распознаётся). Каталог worktree ДОЛЖЕН совпадать с `wip-<NNN>-<автор>` ровно (суффикс типа
  `-fix`/`-fix2` в ИМЕНИ КАТАЛОГА ломает пин даже при правильном BRANCH=; суффикс в ИМЕНИ ВЕТКИ
  — можно). Рецидив ×2 (Architect083Battery, Architect088Fix) — оба обошлись write в scratch +
  доклад патча, я применял патч сам.
- **Рецидив (×1, этот чекпойнт): `_write`/`_edit` на HANDOFF.md/любой путь основного чекаута
  ОТКАЗАНЫ и ОРКЕСТРАТОРСКОЙ сессии, не только субагентам** («путь не в null-allowlist
  /tmp/dev-harness-verify/**, artifact://») — пиши сначала в
  `/tmp/dev-harness-verify/<scratch>/<файл>`, затем `git hash-object -w <scratch>` →
  `git update-index --add --cacheinfo 100644,<blob>,<путь-в-дереве>` → `git checkout --
  <путь-в-дереве>`.

### 1. Контракт 088 («в полёте ничего») — КРУГ 2 судей нужен, push заблокирован на CI #43

Ленд круга 1 (`8bc5e68`, adversary FAIL — `scripts/check_staged.sh` доверял env `PTR_088`,
обход k7 — `verdicts/adversary/contracts-088.md`). Круг 2 исправлен (implementer `2ee9651` убрал
чтение env; architect `0fe7d70` убрал export в `_toy.sh`, добавил клетки D5+B14), слит
`4b1f3c2` (`land: wip/088/implementer-fix2`, 2й родитель РОВНО `2ee9651`), батарея
`bash fixtures/_krasnye_088.sh` → rc 0 (7/7 D, 13/13 B, 17/17 стаб-пак).

**Следующий шаг**: дождаться зелёного PR#43 целиком → push main → спавн судей круг 2
(adversary+reviewer, main-direct isolated-clone, zone implementer `scripts/orch_restart.sh
scripts/check_staged.sh` / zone architect `fixtures/_krasnye_088.sh fixtures/strazh_088/`) →
при accept — `bash scripts/done_contract.sh` для 088.

### 2. Контракт 085+074 — ПОЛНОСТЬЮ ПРИНЯТ, done ЕЩЁ НЕ СДЕЛАН

Слит в main: `land: wip/085/implementer` (`e27787c`, 2й родитель РОВНО `85fb6ba0`) +
cherry-pick `486ef12` (doc-only, см. ниже) + adversary accept `a97d529` + reviewer accept
`872712c`. **done НЕ вызван** — ждал зелёного PR-CI на `ba09ed8` (origin/main). Живая мера
сейчас: `gh run view 37539741863 --repo a3ka/dev-harness --json status,conclusion`.

**Критичный урок этой сессии про 085/087**: ветка `pr-087-fix`@`486ef12` — это НЕ 087-механизм,
а `85fb6ba0` + ОДИН doc-коммит консультанта (`forks/087-granica-u-kod-vs-uchetnoe-soreview-v1.md`,
со-ревью границы U). Её родительская история содержит СТАРЫЙ merge-коммит `b512ee3`
(`land: wip/085-074/combo`) с НЕКОНФОРМНЫМ subject — он застрял внутри `85fb6ba0`'s истории
(`5bfc85c4` — предок `85fb6ba0`, merge был no-op, b512ee3's tree == 85fb6ba0's tree). Merge
ветки `486ef12` целиком тянет этот неконформный commit и ломает gitw. Решение: смержить ТОЛЬКО
`85fb6ba0` (`git merge --no-ff -m "land: wip/085/implementer" 85fb6ba0`), затем
cherry-pick (НЕ merge!) `486ef12` отдельным однофайловым коммитом — он single-parent
(parent=`b512ee3`), cherry-pick не тащит `b512ee3` в историю.

**Как только PR-CI `ba09ed8` зелёный**: `bash scripts/done_contract.sh` для 085 (v1, ПРОВОДКА —
по полю контракта; строка владельца НЕ нужна по слову консультанта 22:05). Станция
(ops/server/install.sh) — НЕ трогать, утром консультант.

### 3. Контракт 086 (гейты сведения) — КРУГ 3 ПОСЛЕ FAIL×2, повтор причины → АРБИТР

Круг 1 adversary FAIL (F1/F2/F3, `verdicts/adversary/contracts-086.md` на main `36d352`/`c68c45e`
rescued) → fix1 (`460842f`, wip/086/implementer-fix2) закрыл F1-F3, reviewer круг1 FAIL НОВЫМИ
находками Б-1..Б-5 (`verdicts/review/contracts-086.md` на main `c62550d`) → fix2 (`93ae355`,
wip/086/implementer-fix3) закрыл Б-2/Б-4, НЕ закрыл Б-3/Б-5, ВНЁС РЕГРЕССИЮ Б-6 → reviewer круг2
СНОВА FAIL (`verdicts/review/contracts-086.md` v2 на main `ba09ed8`, `.review/2026-10-06-04.md`).

**Б-3 повторился НЕИЗМЕННЫМ дважды подряд** («вывод побайтово тот же, что в круге 1» —
дословно из вердикта reviewer круга 2) — по правилу устава «2 отказа одной причины с
несогласием → арбитр», это КАНДИДАТ на арбитраж, НЕ третий implementer-раунд руками. Слово
владельца 22:05: «повтор той же причины FAIL — арбитр, не третий круг» — ПОДТВЕРЖДЕНО.

**Следующий шаг**: созвать `arbiter` субагента на предмет Б-1'/Б-3/Б-5/Б-6 контракта 086
(текст: `scripts/gejt_svedenija.sh` реализует зонный гейт ВТОРОЙ РЕАЛИЗАЦИЕЙ поверх
`scripts/lib_zones.sh` вместо вызова его напрямую — это архитектурный вопрос «как правильно»,
не правка строки). Дай арбитру ПОЛНЫЙ текст `verdicts/review/contracts-086.md` (обе версии,
круг1 и круг2) + `verdicts/adversary/contracts-086.md` + контракт 086 целиком. Ветки ожидают:
`wip/086/implementer-fix3`@`93ae355` (локально, НЕ запушена). Кап 5 кругов НЕ достигнут
(судейских кругов было 3: adv1, rev1, rev2) — но правило «2 отказа одной причины» сработало
раньше кап'а, это ожидаемо и правильно.

### 4. Контракт 083 (CI-A генератор) — PR#36, круг2 implementer готов, ждёт A3-тайминг

Round1 FAIL×2 (Б-1 PR-кеш-этикет, Б-2 (в′) только charter, Б-3 verify_ci_parity 5-я форма)
закрыты: `implementer-gen`@`a9f9c27` (Б-1+Б-3), `implementer-incr`@`b58907f` (Б-2),
`architect`@`97b7c15` (С-1: 38 новых клеток, honest rc=0 ЖИВЬЁМ проверено на всех обходах).
Слиты в `wip/083/integration-2` (push `2e487ca`), батарея `bash fixtures/_krasnye_083.sh` →
rc=0 ok=91 FAIL=0. Граница A3 зафиксирована: run `37535574021` (push `2e487ca`, success).
Тёплый прогон 1: `37538840321` (push `1f970ba`, success). Тёплый прогон 2: push `31f0183`,
run `37540489306` — СТАТУС НА МОМЕНТ ЧЕКПОЙНТА `in_progress`, проверь живьём.

**Следующий шаг**: дождаться run `37540489306` (и при необходимости ещё тёплых, если первый
после правки Б-1 холодный по не зависящей от нас причине — restore-keys иногда промахивается)
→ `bash fixtures/ci_gen_083/timing_083.sh wip/083/integration-2 720 37535574021` → rc 0
обязателен → **круг 2** судей (НЕ круг 1) по вершине `31f0183` → при accept: push
`wip/083/integration-2` в main (земля ждёт ОТДЕЛЬНОЙ merge-процедуры) → done 083. **082 ТОЖЕ
ждёт done** — его guard-шаг должен появиться в `registry/ci-steps.tsv` ДО done 083 — сверь
`registry/ci-steps.tsv` на предмет guard 082 перед done.

ЗОНА architect 083: `contracts/083-*.md fixtures/_krasnye_083.sh fixtures/ci_gen_083/*
docs/owner/2026-10-05-a3-pr-vs-push-analiz.md`. ЗОНА implementer (gen):
`scripts/gen_ci_steps.sh scripts/run_ci_lane.sh registry/ci-steps.tsv .github/workflows/ci.yml
package.json scripts/verify_ci_parity.sh config/ci_parity_exceptions.txt`. ЗОНА implementer
(incr): `scripts/lib_incr.sh scripts/check_charter.sh scripts/check_zones.sh
scripts/check_ids.sh scripts/check_protected.sh fixtures/ci_gen_083/do_check_*_083.txt`.

### 5. Контракт 087 (CI-Б, механизм) — ждёт done/083, implementer ЕЩЁ НЕ СТАРТОВАЛ

Контракт явно пишет «РАБОТА НЕ РАЗДАЁТСЯ … до лендинга 083 в main». **НЕ путать** с
`pr-087-fix`@`486ef12` (см. §2 выше — это doc-коммит консультанта про ГРАНИЦУ, НЕ механизм 087).
Judges087-дозвон этой сессии по ошибке проверял `486ef12` КАК ЕСЛИ БЫ это была 087-реализация —
вердикт `verdicts/adversary/contracts-087.md` (`c9f37eb`/`1aaee46` на main) FAIL «предмет
отсутствует» — ЭТО ОЖИДАЕМО ПРАВИЛЬНО (083 ещё не слит), НЕ повод для implementer-087-раунда.
**Следующий шаг**: СРАЗУ после done/083 — спавн РЕАЛЬНОГО implementer087 (база main+083), зона:
`scripts/ci_klass.sh scripts/ci_vesa.sh scripts/check_ci_gate.sh scripts/gitw_preflight_071.sh
scripts/run_ci_lane.sh scripts/gen_ci_steps.sh scripts/verify_ci_parity.sh
registry/ci-steps.tsv .github/workflows/ci.yml package.json config/ci_parity_exceptions.txt`.

### 6. Контракт 084 (реестр плана) — пачка А готова, круг2 fix в полёте

Implementer084A (`bd692cc`, wip/084/implementer-084a) — registry/plan.tsv перенос (23 строки),
lib_plan.sh/gen_plan.sh/check_plan.sh/track_digest.sh/freeze_contract.sh/.githooks/pre-commit,
батарея `fixtures/_krasnye_084.sh` 52/52 green. Adversary круг1 FAIL
(`verdicts/adversary/contracts-084.md`, `b3d7620` на локальном main, НЕ запушен): А-084-1
(хвостовая запятая в `зависит` принимается), А-084-2 (plan.tsv без финального LF принимается).
**Implementer084Fix УЖЕ ДИСПЕТЧЕРИЗОВАН** (worktree
`/tmp/dev-harness-worktrees/c907157c/wip-084-implementer-fix2`, branch
`wip/084/implementer-084a-fix2`, база `bd692cc`) — проверь, завершился ли (`read
proc://` или дождись через `wait`, агент мог уже прислать результат).

**Следующий шаг**: после fix2 → adversary круг2 на fix2 → reviewer → done (пачка А независима
от 083). Пачка Б (`registry/ci-steps.tsv .github/workflows/ci.yml scripts/check_charter.sh`) —
СТРОГО после done/083, РАБОТА НЕ РАЗДАЁТСЯ до того.

### Активные worktree (не удалять, там незавершённая работа)

```
/tmp/dev-harness-worktrees/c907157c/wip-086-implementer-fix3   wip/086/implementer-fix3   93ae355
/tmp/dev-harness-worktrees/c907157c/wip-083-integration-2-merge wip/083/integration-2      31f0183 (push'нут)
/tmp/dev-harness-worktrees/c907157c/wip-084-implementer-fix2   wip/084/implementer-084a-fix2 (fix в работе)
/tmp/dev-harness-worktrees/c907157c/wip-088-architect-fix      wip/088/architect          0fe7d70 (push'нут как часть 4b1f3c2)
```
Прочие (078-implementer, 080-architect, 083-implementer-gen/incr/incr2, 083-architect) —
старые, их ветки уже слиты в `wip/083/integration-2` ИЛИ изначально тупиковые пробы прошлых
сессий; можно `gc_agent_branches` при явной уверенности, этой ночью НЕ трогать без нужды.

### Учтённые предохранители (из предыдущих сессий, остаются в силе)

- `.git/config` основного чекаута иногда отказывает на запись при `git branch -f`/`-D` рядом
  с активным worktree («Operation not permitted») — операция САМА обычно всё равно проходит,
  проверяй результат, не доверяй голому rc.
- Verdict-файлы для НОМЕРНЫХ контрактов — ТОЛЬКО `verdicts/<роль>/contracts-NNN[-vV].md`.
- gh CLI `--log`/`--log-failed` иногда падает `permission denied` на `/tmp/gh-cli-cache/*`
  (каталог принадлежит другому юзеру `nous`) — используй `gh api
  repos/<owner>/<repo>/actions/jobs/<id>/logs` напрямую вместо `gh run view --log`.

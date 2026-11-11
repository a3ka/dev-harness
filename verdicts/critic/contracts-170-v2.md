FAIL
OBJECT=dd5c16535fe9413b0282eadd9c3232d5850ab335
КЛАСС=кодовый (v+1 замороженного контракта + красная батарея; суд ПО ДЕЛЬТЕ Б-1/Б-2); КЛАСС РИСКА: обычный — подтверждаю (сборка контекста задания; права/роли БД, авторизация, деньги, ПД/health и согласия, юридически значимые действия не затронуты; адверсарий по классу не вызывается)
СУД: repo=dev-harness; предмет=170; фаза=контракт (v+1 → v2 после правки Arch170v2c по Б-1/Б-2; суд ПО ДЕЛЬТЕ; слово владельца 2026-11-10 ~20:44 «д да», строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в изменяющем коммите); роль=critic; вызов=6 (СВЕРХ капа 5 — слово владельца 2026-11-11 ~12:20 UTC через консультанта: «шестой вызов критика ДА, предмет — Б-1 и Б-2, ТОЛЬКО по дельте, модель — свой тир GLM, НЕ Opus»); модель-план=zai/glm-5.3; сессия=Crit170v6; модель-факт=zai/glm-5.3; SHA=dd5c16535fe9413b0282eadd9c3232d5850ab335 (tip wip/170/architect); предыдущий=Crit170v2b (FAIL, НЕ материализован: модель-факт вне цепочки тира, Н-270); исключение=слово владельца (вызов сверх капа 5)

# Вердикт критика — контракт 170 v2 «бриф из закреплённого коммита architecture.lock.json», вызов 6 ПО ДЕЛЬТЕ

## Рамка, счёт, независимость

- Объект. Одноразовый клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Crit170v6/repo`; `git fetch origin wip/170/architect`; `git rev-parse origin/wip/170/architect` = `dd5c16535fe9413b0282eadd9c3232d5850ab335` = OBJECT (строка OBJECT задания верна). Один коммит `dd5c1653` поверх `994c68ea` (merge-base с main); задание называет базу «main `11451c183`» — фактический родитель `994c68ea` (main ушёл вперёд); дельта по судимым путям (`contracts/170-…` + `fixtures/workshop_project/arch_component_170/`) побайтно идентична в обеих базах (сверено diff'ом двух диффов → IDENTICAL). Файлы дельты: контракт, `npm_stub.py`, `probe.py` — всё из `ЗОНА architect` (:59). `git log -1 --format=%B dd5c1653 | grep -c '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'` → 1.
- СУД-запись вызова 6: `origin/main` (`bcf3c5f3`) `HANDOFF.md` строка 2 — сверена: вызов=6 (сверх капа 5), модель-план=zai/glm-5.3 (fallback gpt-5.6-terra), SHA=OBJECT, предыдущий=Crit170v2b (FAIL, не материализован, Н-270). Совпадает с заданием.
- Счёт. v1 — 4 платных вызова (`contracts-170-v1-krug1-fail.md` … `contracts-170-v1.md`); v2 — вызов 1 оборван без вердикта (Crit170v2, учитывается), вызов 2 = Crit170v2b (FAIL, НЕ материализован), этот вызов — 6-й платный по предмету. Общий кап 5 превышен; единственное основание — слово владельца 2026-11-11 ~12:20 UTC, записано в СУД-строке вызова 6.
- Независимость. Модель-факт этой сессии — `zai/glm-5.3`, тир роли critic (apex-sol), автофолбэк не срабатывал; совпадение с моделью автора отказа не даёт (контракт 166). Автор `dd5c1653` — architect (Arch170v2c), не эта сессия; собственную работу не сужу.
- Набор полон: предмет (:28–37), критерий готовности с rc-командами (:38–47), исполнители и `ЗОНА`-строки (:59–64), `## Модель угроз` (041: 2 ЗАЩИЩАЕТ + 4 НЕ ЗАЩИЩАЕТ, гейт rc 0), `КЛАСС РИСКА` (:4). Разбор по существу правомерен. Имя вердикта `contracts-170-v2.md` в main отсутствует (`git ls-tree origin/main verdicts/critic/ | grep 170` — только v1-файлы); vmax=1 → v2.
- Связь дополнительного поиска с дельтой (§Быстрый-процесс §Контракт): судимы ТОЛЬКО изменённые поверхности — konstrukция мира (`ARCH_LINE`, `MODEL_CLI`, pin-binding `npm_stub`), правило шва в честном контроле, клетки/стабы пустого lock и применимости, формулировки :30/:32/:34/:43. Реальная реализация 187а в main гонялась как источник истины по прямому пункту 1 задания оркестратора. Неизменённые поверхности (батареи 095/169, чужие зоны) заново не исследовались.

## Гейты (команды, rc)

- `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0 (`гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3`; `гейт трека`; `КРИТИК: дверь зелёная`).
- `bash scripts/check_precision_gate.sh . contracts/170-…` → rc 0 (`OK`).
- `bash scripts/check_threat_model.sh . contracts/170-…` → rc 0 (`модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))`).
- `bash scripts/check_ceilings.sh .` → rc 0 (`персоны: 12 …; правила: 1 …; раздел требований: 170 черновик(ов) судится…; потолки в порядке`).
- `bash scripts/check_provodka.sh . contracts/170-…` → rc 0.

## Батарея — команды, rc, сырые выводы

1. `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` (OBJECT) → **rc 0, 34/34 ok**. Ключевые сырые строки: `170 empty_lock ok rc=1 stderr='ОТКАЗ: ARCHITECTURE_NET: нет закреплённого коммита' npm_calls=0`; `170 lock_without_commit ok rc=1 … npm_calls=0`; `170 empty_lock_required ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'`; `170 symbolic_pin ok rc=1 … 'ОТКАЗ: ARCHITECTURE_NET: lock не указывает на коммит архитектуры'`; `170 model_root_unset ok … 'ОТКАЗ: ARCHITECTURE_NET: нет репозитория архитектуры ARCHITECTURE_ROOT'`; все положительные клетки ok (brief `REVISION:PINNED-170`, STRUCTURE.md, правила ровно трём ролям).
2. `… --stabs` (OBJECT) → **rc 0, 22 строки `170 STAB <name> caught @ <ветвь>`, ни одного `ZHIV`**. Оба мутанта критика из Б-2 встроены стабами и пойманы: `170 STAB empty_lock_head_fallback caught @ empty_lock`, `170 STAB applicability_valid_pin_only caught @ empty_lock_required`; привязка стаб→ветвь задана кодом (кортеж `mutants`), не прозой контракта (Н-39).
3. `… --repo .` (OBJECT; make_task = локальный источник) → **rc 1, 30 KRASNO, зелёны ровно `legacy`, `document`, `brief_kind`, `model_root_unset`** — первая половина :43 сходится дословно.
4. `… --repo /tmp/dev-harness-verify/Crit170v6/main-impl` (worktree `bcf3c5f3` = origin/main, реальная принятая реализация 187а, только чтение) → **rc 1, 31 KRASNO / 3 ok (`legacy`, `document`, `brief_kind`)**. Сырые строки — в блокирующей находке.
5. Post-cutover слияние (main `bcf3c5f3` + дельта `dd5c1653` по судимым путям, отдельный worktree, правки без коммита): `probe.py --repo <это дерево>` → **rc 1, та же картина 31 KRASNO** — вливание фикстур v2 в текущий main красит `--all` по построению.

## Блокирующая находка

БЛОКИРУЕТ contracts/170-arch-component-brief-vhod-zadanija.md:43 (также :30, :32, :34) — обещание «После cutover make_task по 187а и этому тексту та же команда и `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --all` → rc 0» опровергнуто живым прогоном на реальной ПРИНЯТОЙ реализации 187а: cutover уже влит в main, и та же команда даёт rc 1 (31 клетка KRASNO из 34). Класс тот же, что Б-1 вызова 2/2 — критерий «после 187а → rc 0» недостижим на честной существующей двери; манифестация сменилась с `ARCH_LINE_MISSING` (мир без строки) на `ARCH_ZONE`/`ARCH_PIN`/молчаливый rc 0.
ОБЯЗАТЕЛЬСТВО: :43 (вторая половина); :34 «её backend-миры конформны 187а»; :30 (применимость: «для любого проекта с файлом `architecture.lock.json` … отсутствие флага даёт rc 1 … `ARCH_COMPONENT_NET` … Наличие/отсутствие локального `R/architecture/` не решает применимость»); :32 (имена отказов `ARCHITECTURE_NET: …`, грамматика pin «ровно 40 строчных hex», форма брифа `npm --prefix <дерево закреплённого коммита> run brief …`); модель угроз :148 («от подмены закреплённого SHA … символьной ссылке»); пункт 1 задания вызова 6 («rc 0 ожидается; если красный — это блок»).
СОСТОЯНИЕ (достижимо и достигнуто): реализация 187а влита в main и принята ревьюером (вызов 2/2; HANDOFF `11451c183`: «187а реализация влита (accept ревьюера вызов 2/2)»); копии только чтение: worktree `bcf3c5f3`; merged-дерево (main + дельта dd5c1653).
НАБЛЮДЕНИЕ (команды и сырой вывод):
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo /tmp/dev-harness-verify/Crit170v6/main-impl` → rc 1. 22 клетки (`required`, `architect_rules`, `critic_rules`, `arbiter_rules`, `implementer_plain`, `adversary_plain`, `reviewer_plain`, `multi_component`, `malformed_id`, `local_wrong`, `brief_failure`, `implementer_brief_failure`, `adversary_brief_failure`, `reviewer_brief_failure`, `brief_over_budget`, `class_dot`, `class_parens`, `class_semicolon`, `class_risk_tail`, `class_upper_c`, `second_malformed_id`, `symbolic_pin`):
  `ОТКАЗ: ARCH_ZONE: путь scripts/toy.sh отнесён моделью к компоненту api.identity, а строка «АРХИТЕКТУРА:» называет api.identity,worker.events`.
  Причина: реализация 187а (`scripts/check_architecture_contract.sh:352`, `case " $ARCH187_COMPONENTS " in *" $comp "*`) не режет список строки по запятым — строка ` api.identity,worker.events ` не содержит ` api.identity ` с пробелом, поэтому ЛЮБАЯ строка с двумя компонентами при любом пути зоны отказывает `ARCH_ZONE`. Честный контроль батареи режет по запятым (`tr ',' '\n' | grep -Fxq`) — чтение архитектора расходится с реальной дверью.
- Изоляция (одноразовый скрипт `/tmp/dev-harness-verify/Crit170v6/exp_single_line.py`: патчит `probe.ARCH_LINE` на `АРХИТЕКТУРА: L1 api.identity`, субъект — тот же main; живой прогон):
  (1) применимость: `170 required KRASNO rc=0 stderr=''`, `170 wrong_project KRASNO rc=0 stderr=''`, `170 empty_lock_required KRASNO rc=0 stderr=''`, `170 class_dot KRASNO rc=0 stderr=''` — реальная дверь отказывает по отсутствию флага только при локальном каталоге `architecture/` (`scripts/make_task.sh` bcf3c5f3:941, `elif [ -d "$_arch_dir" ] …`), что противоречит :30;
  (2) имена: `170 empty_lock KRASNO rc=1 stderr='ОТКАЗ: ARCH_PIN: в architecture.lock.json нет закреплённого коммита'`, `170 invalid_pin KRASNO … 'ОТКАЗ: ARCH_PIN: коммит 0000000000000000000000000000000000000000 не разрешается в клоне модели: …'`, `170 model_root_unset KRASNO … 'ОТКАЗ: ARCH_PIN: закреплённый клон модели не задан (ARCHITECTURE_ROOT)'` — вместо предписанных :32 `ОТКАЗ: ARCHITECTURE_NET: …` (то же в полном прогоне для `lock_without_commit`);
  (3) граница брифа: `170 architect_rules KRASNO rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (закреплённая модель не отдала бриф)'`, `170 multi_component KRASNO` (то же) — реальная дверь зовёт `node tooling/checks/cli.js brief --compact [--with-rules] --component` напрямую (`check_architecture_contract.sh:184,186`), :32 предписывает `npm --prefix <дерево> run brief …`; модель батареи отвечает бриф только через `npm run brief`, стаб перехватывает только npm;
  (4) символьный pin: `170 symbolic_pin KRASNO rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (закреплённая модель не отдала бриф)'` — клетка дошла до стадии брифа, т.е. `commit:"HEAD"` РАЗРЕШЁН реальной дверью (`arch187_pin` без проверки 40-hex; `git cat-file -e 'HEAD^{commit}'` проходит) — вопреки :32 и обещанию :148.
- CI-шаг :52 реально исполняет батарею без аргумента (= `--all`) уже в main (`registry/ci-steps.tsv:295`, вес 85): вливание фикстур v2 в текущий main красит CI, а фраза «до него --all красный по построению» описывает порядок, которого больше нет.
ЗАКРЫВАЕТ (свойство, не единственная реализация): живой прогон `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo <одноразовая копия main>` даёт rc 0 — либо миры/текст v2 приведены в соответствие с реальной дверью (форма строки `АРХИТЕКТУРА:`, имена отказов, применимость, граница брифа, грамматика pin) в пределах зон этого контракта, либо расхождение закрыто решением полномочной роли, которое явно называет владельца правки `scripts/make_task.sh` при сохранении зелёными батареи 187а и CI. Утверждение :34 «её backend-миры конформны 187а» обязано быть истинным для реальной двери, а не только для чтения архитектора.

Порядок после FAIL: спора нет — автор письменно СОГЛАСЕН с Б-1/Б-2 (:13–14), арбитра не созываю. По §Остановка: позиция автора по блоку; при письменном согласии — один исправительный вызов по санкции оркестратора; вопрос «кто правит make_task под текст v2» при споре — владельцу. Счёт вызовов продолжается; шестой вызов уже сверх капа, седьмой требует отдельного слова владельца.

## Б-2 — закрыт в рамках честного контроля

Клетки `empty_lock`, `lock_without_commit`, `empty_lock_required` подают субъекту именно этот вход (`lock='empty'` — существующий пустой файл; `'no_commit'` — lock без значения `commit`; пустой lock без флага в non-backend проекте), ждут предписанные отказы, `npm_calls=0`; оба мутанта критика из ОБХОДА Б-2 встроены стабами батареи и пойманы (`empty_lock_head_fallback caught @ empty_lock` — подстановка `rev-parse HEAD` при пустом lock; `applicability_valid_pin_only caught @ empty_lock_required` — применимость по «валидному SHA»); привязка стаб→ветвь — кодом (Н-39). Краснота этих же клеток на реальной двери — часть блокирующей находки (расхождение имён :32), не отдельный класс.

## Счётные и механические расхождения — полным списком (слово владельца 2026-10-31)

1. :40 «rc 0 и 34 клетки `ok`» — сходится (34/34 в `--model`).
2. :44 «22 строки `170 STAB … caught @ …`, ни одного `ZHIV`» — сходится (22 caught).
3. :43 «rc 1: 30 клеток красны, зелёны `legacy`, `document`, `brief_kind`, `model_root_unset`» — сходится на до-cutover двери (`--repo .` на OBJECT).
4. :52 «шаг CI … уже исполняет red_arch_component_170.sh без аргумента» — сходится (`registry/ci-steps.tsv:295`); продолжение «до него --all красный по построению» на текущем main неверно по смыслу — красный теперь устойчивое расхождение текста с реальной дверью (блок выше), а не «до PR».
5. :51 «git grep ARCHITECTURE_ROOT -- scripts roles ops .omp config на main пуст» — на текущем main (`bcf3c5f3`) ЛОЖНО: `scripts/check_architecture_contract.sh` использует `ARCHITECTURE_ROOT` (ровно 1 файл). Премиса написана до влития 187а — С-1.
6. `probe.py:14` комментарий `IDS = … # architecture/README.md and checks/test/workflow-v242.test.js` ссылается на старый локальный источник; в v2 ID определяются кодом самой батареи (`MODEL_CLI`) — С-2.
7. Гарантии frozen 170/1: 19 клеток — все сохранены в 34 (проверено сравнением множеств CASES); локальный режим жив (`legacy` зелёна); `--repo .` на до-cutover реализации rc 1 как в v1.
8. Задание оркестратора (не кандидат): «ОДИН коммит поверх main `11451c183`» — фактический родитель `994c68ea`; дельта по судимым путям побайтно идентична обеим базам (проверено). Доложено, дефектом кандидата не является.

## Советы (едут с вердиктом, автор закрывает по своему усмотрению)

- С-1 (:51): переписать премису под текущий main (источник `ARCHITECTURE_ROOT` появился в `scripts/check_architecture_contract.sh` от 187а).
- С-2 (`probe.py:14`): убрать ссылку комментария на несуществующий в v2 локальный источник ID.
- С-3 (:52): после закрытия блока переформулировать порядок влития — «одним PR с cutover» более невозможен, cutover влит раньше фикстур.

## Итог

FAIL — блокирующая находка одна (класс Б-1: критерий :43 «после cutover → rc 0» опровергнут на реальной принятой реализации 187а, пять изолированных расхождений текста v2 с дверью). Б-2 закрыт в контрольном мире. Гейты rc 0; `--model` rc 0 (34/34); `--stabs` rc 0 (22 caught, 0 ZHIV); `--repo .` rc 1 (30 красных, 4 зелёных — дословно :43).

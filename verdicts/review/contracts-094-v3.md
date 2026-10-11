FAIL — Р3-1 (--policy-dir в двери обходит доверенную политику base: PUBLISHED без единой строки обязательных ci-a/ci-b), Р3-2 (land_agent/land_project сами пишут verdict accept и check ok — LANDED вопреки targetBranches=dev и без единой исполненной проверки), Р3-3 (land_agent в мире харнеса: «mandatory: unbound variable», rc=1), Р3-4 (check_consumers rc=1 на сборке, на main rc=0 — регресс приёмки 5), Р2-2 и Р2-3 не закрыты. Р2-4 закрыт (история пересобрана, check_zones rc=0, красное барьера предъявлено). Р2-1 закрыт по мере барьеров (land_agent 9/9, check_charter 13/13, 063 rc=0), но ценой Р3-2/Р3-3.

# Review 094, круг 3

**Находки (reslop):** `.review/2026-10-11-06.md`. Блокирующих 6 (Р3-1…Р3-4, Р2-2, Р2-3), неблокирующих 6 (Н3-1…Н3-6).

**Предмет.** Контракт 094, `frozen/contracts/094/2`. `git diff --stat frozen/contracts/094/2 HEAD -- 'contracts/094-*.md'` на сборке пуст. Субъект — `origin/wip/094/implementer-final` @ `fbd558a166fd2cbb5c987901cabd2718faf707c2`. Батарея — `origin/wip/094/architect` @ `07dcebc3220e0d49fc395886c5ad488c713c00d0`. Прошлый круг — `verdicts/review/contracts-094-v2.md`: FAIL, Р2-1…Р2-4.

**Поправка к заданию.** В задании сказано, что ветка «получила РОВНО ОДИН новый коммит fbd558a1 поверх того, что уже судил круг 2». Это неверно. Круг 2 судил `wip/094/implementer` @ e289d7a5. `implementer-final` — это пересобранная ветка (Н-261): e289d7a5, 59184a7f, e3541682 и 618717dc **не** её предки. Против origin/main она несёт новые коммиты субъекта: 03c0e809, c138c7f9, 6e306c18, c1c83997, e553bd39, а также b7a0c276 (merge батареи) и 3 merge оркестратора. Всё это судится здесь впервые.

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/review094v3-1791732488359`, ветка `assemble094v3`:

- origin/main `cb039a89`;
- `merge --no-ff fbd558a1` дал **конфликт** в `NABLIUDENIA_ARCHITECT.md`: хвост А-382…А-388 от 095 на main против А-383/А-392 от 094. Я разрешил его объединением обеих сторон → `2b2135dc`;
- `merge --no-ff 07dcebc3` — «Already up to date»: 07dcebc3 уже предок через b7a0c276.

Итог сборки — `2b2135dc`. Нетто-дифф против main — 17 путей. Прогоны шли в отдельном worktree сборки (`…-asm`), чтобы `./tmp/charter.*` от параллельного check_charter не загрязнял `$WORK`. База для сравнения — worktree origin/main (`…-main`).

МОДЕЛЬ: anthropic/claude-opus-5-5

## Сырой вывод (мои прогоны; сборка 2b2135dc, если не сказано иное)

```text
git show --stat fbd558a1                         scripts/check_charter.sh | 20 +++  (1 file); author=owner committer=architect
sha256 check_charter.sh: fbd558a1 = origin/main = HEAD = 4c8c10eb…aed7; git diff origin/main fbd558a1 -- scripts/check_charter.sh | wc -l → 0
git merge-base --is-ancestor 0f7591b3 origin/main → yes
merge-base --is-ancestor {e3541682,618717dc,59184a7f,e289d7a5} HEAD → no ×4
bash scripts/check_zones.sh                      … «замороженных контрактов: 90 · коммитов в диапазонах: 8646 · проверено по зонам: 2533», rc=0
  + проба: коммит implementer c harness/policy   FAIL коммит вне зоны: implementer a366556e harness/policy …, rc=1 (откатан, HEAD 2b2135dc, дерево чисто)
bash scripts/check_charter.sh .                  752с; «уставных документов: 91 · изменений в них: 194 · с разрешения: 193», rc=1:
                                                 FAIL … contracts/094-…md в 2b2135dc (мой merge сборки, обычный git merge без переноса санкций 065) — Н3-6;
                                                 b7a0c276/41f80d3b/484e8c12/a20547bc и 095 ae8836c6/5c4752bc/6d1d23d4 — ok (грандфазер fbd558a1 работает)
bash fixtures/_krasnye_094.sh                    стабы s1…s19 ПОЙМАН; 18 клеток rc=0; ИТОГ 094: rc=0
bash fixtures/_krasnye_094.sh --model            ИТОГ стаб-пак 094: rc=0; ИТОГ 094: rc=0
git ls-tree … accept_publish_094/ | grep -c red_ 18;  grep -c 'zapest s' battery_stubs.sh 19
verify_antiplacebo --scope land_agent            фикстур 9 · предъявлено 9, rc=0
verify_antiplacebo --scope check_charter         фикстур 13 · предъявлено 13, rc=0
bash fixtures/check_judge_gate/krasnye_063.sh    к1…к14 ok, итог 063: rc=0
verify_antiplacebo --scope check_judge_gate      3/3, rc=0
verify_antiplacebo --scope done_contract         1/1, rc=0
verify_antiplacebo --scope check_ci_gate         8/8, rc=0
verify_antiplacebo --scope gitw_preflight_071    FAIL нет фикстур, rc=1        (main: то же, rc=1)
bash fixtures/_krasnye_087.sh                    КРАСНОЕ 087: нет scripts/ci_klass.sh …, rc=1   (main: то же — v2)
bash scripts/check_consumers.sh . contracts/094-…  «потребители 116: писатель scripts/done_contract.sh изменён,
                                                 потребитель scripts/check_spec_ready.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы», rc=1
                                                 (main: rc=0)
bash scripts/check_nabludenia.sh                 rc=0
git grep -nE 'update-ref .?refs/heads' -- scripts/   accept_publish.sh:394, accept_task_commit.sh:242 (wip/*)
ls scripts/land_agent.sh scripts/land_project.sh     оба есть
git ls-files registry/candidates.tsv | wc -l     0
git grep T094_ вне judge_gate/check_ci_gate/gitw_preflight и семьи 094   (пусто)
git grep -i targetbranch -- scripts/profile_resolver.sh harness.project.json registry/harness-project.json   (пусто), rc=1
grep -n 'repoId="dev-harness"\|branches="main"' scripts/accept_publish.sh   147,148,181,182
grep -c policy-dir model/dover.sh → 0; grep -rl policy-dir fixtures/ → (пусто)
dover.sh prepare … --policy-dir /tmp/x          usage: dover.sh object|prepare|publish … (без --policy-dir), rc=1
git log --no-merges origin/main..HEAD -- fixtures/ contracts/   07dcebc3 41f80d3b 484e8c12 a20547bc — все architect|architect
```

Проба `/tmp/dev-harness-verify/review094v3-1791732488359-probe/probe.sh <сборка>` (одноразовая, не коммитится):

```text
=== P1: дверь, --policy-dir подменяет доверенную политику base (И-6)
base policy: repoId=toy-094 mandatory=ci-a,ci-b targetBranches=main
prepare rc=0 M=c0854a4f…   object rc=0 O=58c0b7cc…
--- контроль: тот же журнал БЕЗ --policy-dir
ОТКАЗ: нет обязательной проверки: ci-a
publish(без policy-dir) rc=1
--- обход: --policy-dir (mandatory=noop)
PUBLISHED target=main merge=c0854a4f…
publish(--policy-dir) rc=0 ==M:yes
ci-a/ci-b строк в журнале: 0
=== P2: land_agent в toy-мире: base targetBranches=dev, ни одна проверка не исполнена, вердикта нет
base policy: repoId=toy-094 mandatory=ci-a,ci-b targetBranches=dev
PUBLISHED target=main merge=20bdb991…
LANDED main=20bdb991… branch=wip/x/implementer
land_agent rc=0 main_moved=yes
=== P3: land_agent в харнес-мире (registry/ci-steps.tsv на base)
…/scripts/land_agent.sh: line 176: mandatory: unbound variable
land_agent rc=1 main_moved=no
```

Повторный прогон P1 воспроизвёл то же самое: отказ без флага, PUBLISHED с флагом.

## Решение по находкам круга 2

| Находка | Решение | Основание (живое) |
|---|---|---|
| Р2-1 регресс CI (land_agent / check_charter / 063) | **закрыт по мере барьеров**, способ порождает Р3-2/Р3-3 | 9/9, 13/13 и 063 rc=0 на сборке. Зелень достигнута тем, что обёртка сама сочиняет журнал (P2). В мире харнеса обёртка падает (P3). |
| Р2-2 журнал без проводки | **не закрыт** | Писатели срабатывают только при заданных T094_* — нигде в дереве они не ставятся. `registry/candidates.tsv` отсутствует, обёртки пишут во временный журнал. done_contract для 094 всегда падает «кандидатов нет». |
| Р2-3 И-7 зашитый allowlist | **не закрыт** | `accept_publish.sh:147-148,181-182` прежние. Заявленный ключ `targetBranches` в profile_resolver отсутствует. Взамен появился `--policy-dir`, а с ним новый обход (Р3-1). |
| Р2-4 check_zones e3541682/618717dc | **закрыт** | Обоих нет в истории сборки, check_zones rc=0. Красное барьера на этом диапазоне предъявлено (a366556e → rc=1). |

## Семь проверок ревьюера

1. **Область правки — допустимо с замечанием (Н3-4).** Нетто-дифф против main — 17 путей. В ЗОНУ/ПЕРЕСЕЧЕНИЕ 094 входят: `scripts/{accept_publish,land_agent,land_project,judge_gate,check_ci_gate,gitw_preflight_071,done_contract}.sh`, `fixtures/accept_publish_094/**`, `fixtures/_krasnye_094.sh`, `contracts/094-*`, `NABLIUDENIA_ARCHITECT.md` — все пути диффа. Коммиты implementer 6e306c18/c1c83997 трогали `verdicts/critic/` (судейский канал), но с нулевым нетто; барьер зон rc=0. fbd558a1 тронул ровно `scripts/check_charter.sh` (+20) и побайтно равен main (sha256 4c8c10eb…). Санкция — канал владельца 0f7591b3, identity owner сохранена.
2. **Сырой вывод — у автора нет; мой — выше.** Сообщения коммитов несут только числа («18/18 rc=0, land_agent 9/9, krasnye_063 14/14»), вывода нет. Сами числа я подтвердил своими прогонами. Утверждение 03c0e809 «targetBranches уже ВВЕДЁН» опровергнуто (п.7).
3. **Проверку под код не переписывали — подтверждено.** `git log --no-merges origin/main..HEAD -- fixtures/ contracts/` даёт только architect: a20547bc, 484e8c12, 41f80d3b, 07dcebc3. `git diff 07dcebc3 HEAD -- fixtures/accept_publish_094 fixtures/_krasnye_094.sh` пуст. Но субъект расширил CLI двери флагом `--policy-dir`, которого нет в модели (`dover.sh … --policy-dir` → usage, rc=1). Он вышел из замороженной грамматики (Решение 1) туда, куда батарея не смотрит. Это не подгонка проверки, а уход от неё (Р3-1).
4. **Красное предъявлено — для батареи да, для фиксов круга нет.** 18 клеток и 19 стабов ловятся (`battery_stubs.sh` rc=0). Красное check_zones на диапазоне 094 предъявил я. Для новых поверхностей круга (`--policy-dir`, синтез журнала в обёртках, T094_*-писатели, ветка 094 в done_contract) нет ни одного красного прогона: ни клетки, ни фикстуры, ни стаба.
5. **Атомарность — замечание (Н3-3).** 03c0e809 одним коммитом несёт всю дверь (+398) и фиксы Р2-1/Р2-3/Р2-4. Задача одна (094), ссылка на предмет есть, поэтому это не отказ. Сообщение c138c7f9 называет «architect-battery(07dcebc3…)», которой в этом коммите нет.
6. **Норма не тронута молча — да.** Текст контракта = `frozen/contracts/094/2`. `check_charter.sh` — механизм; грандфазер-пары с санкцией владельца, байты равны main. Тихое сужение объёма Р2-3 («отдельный контракт на миграцию SCHEMA_LEVELS») — это не правка нормы, а невыполнение ПЕРЕСЕЧЕНИЯ; оно отнесено в Р2-3.
7. **Заявленное = сделанное — FAIL.**
   - «18 клеток, 19 стабов, --model rc 0» — подтверждено (`ls-tree` 18, `zapest` 19).
   - «land_agent 9/9, 063 14/14» — подтверждено.
   - «check_charter rc=0 на ветке (fbd558a1)» — на самой ветке я не перемерял (прогон 12+ мин); на сборке единственный FAIL — мой merge-коммит 2b2135dc (Н3-6), грандфазер-пары 24–28 срабатывают.
   - «land_agent/land_project собирают РЕАЛЬНЫЙ журнал» — опровергнуто: журнал сочинён (Р3-2).
   - «Profile_resolver: targetBranches уже ВВЕДЁН» — опровергнуто (0 вхождений).
   - «Р2-2 закрыт» — опровергнуто: у журнала нет ни одного производственного писателя.
   - «конфликтов не жди» (задание) — опровергнуто (Н3-1).

## Сверка обязательств (семантика)

| Обязательство | Фрагмент результата | Наблюдение |
|---|---|---|
| И-6, Frontier «политика из ПРИНЯТОЙ версии», Решение 1 (CLI = модель) | `accept_publish.sh:129-175` `--policy-dir` | Политику задаёт вызывающий; base требует ci-a,ci-b, а P1 публикует при 0 строк ci-a/ci-b (Р3-1). |
| Решение 3 («verdict пишет судейский канал», «check — CI-обвязка» с wfsha/деревом ИСПОЛНЕННОГО); И-1; И-4; Модель угроз «умолчание отсутствующей обязательной проверки» | `land_agent.sh:167-188`, `land_project.sh:145-166` | Обёртка сама пишет accept и ok без судьи и без прогона (Р3-2). |
| И-7 (allowlist из доверенной политики как данные) | `land_agent.sh:124-157` `branches_allow="main"`; `accept_publish.sh:147-148,181-182` | P2: base `targetBranches=dev` → LANDED на main; production — зашитый `main` (Р3-2, Р2-3). |
| Решение 6 (тонкий вызов двери, «с сохранением зелёного CI») | `land_agent.sh:176` | В мире харнеса — unbound variable, rc=1 (Р3-3). |
| Решение 3, ПЕРЕСЕЧЕНИЯ judge_gate/check_ci_gate/gitw_preflight (поставка строк) | env-гейт T094_* + `[ -f journal ]` | Поставщики инертны, `registry/candidates.tsv` нет (Р2-2). |
| ПЕРЕСЕЧЕНИЕ done_contract («остаётся потребителем журнала published, сам объект не судит») | `done_contract.sh:146-169` `if [ "$NNN" = "094" ]` | Проверяет «файл не пуст», а не `published`. Ломает check_consumers (Р3-4). |
| Приёмка 5 (check_consumers rc 0) | — | rc=1, на main rc=0 (Р3-4). |
| ПЕРЕСЕЧЕНИЕ profile_resolver 054/055/057/059 (`targetBranches` ВВОДИТСЯ этой пачкой); Предмет 2.1 | `profile_resolver.sh` | Ключа нет (Р2-3). |
| Приёмка 6 (087 rc 0 — оговорённая зависимость; 063 rc 0) | — | 087 rc=1 как на main (зависимость от landing 087); 063 rc=0. |

## ПРОВОДКА (038)

`guard=fixtures/_krasnye_094.sh` существует и является барьером именно этого предмета (раннер семьи `fixtures/accept_publish_094/`). В CI он **не подключён**: 0 вхождений 094 в `registry/ci-steps.tsv`, `ci.yml` и `package.json`. В круге 2 строка была на e289d7a5, при пересборке ветки её не стало. Контракт сам откладывает подключение («Guard подключается в CI ТОЛЬКО ПОСЛЕ landing предмета»), поэтому это не нарушение, а Н3-2. Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: норма — отказы двери, поведенческий хвост идёт существующим role-каналом `roles/orchestrator.md`.

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| флаг `--policy-dir` двери | Ни одно: контракт требует политику из base/пина, флага в модели нет | Каталог вызывающего — внешнее состояние, видно только по аргументу | дверь + 2 обёртки (выросло с 1) | интерфейс растёт (новый флаг), свойство теряется | только обёртки, клетки нет | дефект Р3-1 |
| синтез политики и журнала в `land_agent.sh`/`land_project.sh` | Решение 6 требует ТОНКИЙ вызов | `mktemp`-журнал и policy-dir — неявные, в выводе не видны | 2 копии одной логики (+ дверь) | ≈60 строк скрытой работы, которой не должно быть | фикстуры 016/022/063/065 | дефект Р3-2 |
| `T094_*`-блоки в judge_gate / check_ci_gate / gitw_preflight_071 (3 копии) | Решение 3 (поставка строк) | Env + файл журнала; без env — тихий no-op | 3 файла | 3 env-переменные на скрипт, работы 0 в производстве | в дереве никто не ставит env | дефект Р2-2 (свойство требуется, проводки нет) |
| ветка `NNN=094` в `done_contract.sh` | ПЕРЕСЕЧЕНИЕ 038 (потребитель `published`) | Читает `registry/candidates.tsv` | done_contract + consumers-манифест (не обновлён) | номер контракта зашит в общий гейт | done 094 | ACCIDENTAL. Фрагмент `:154`; нужное свойство — потребление строк `published`, его нет. Более простая форма, проходящая приёмку: без ветки (main rc=0 на check_consumers). Блок через Р3-4. |
| `reset --hard HEAD` в `land_agent.sh` после publish (e553bd39) | 016 И-7 (чистое главное дерево после ленда), 065 фикстура | Явный побочный эффект на ROOT, чистота на входе проверена | 1 | 1 строка | land_agent / check_charter фикстуры | ESSENTIAL |
| `scripts/accept_publish.sh` (398 стр.) | Решение 1 — одна дверь | Журнал/ref в аргументах | — | 3 глагола (+ лишний флаг — см. выше) | батарея 094 | ESSENTIAL (за вычетом `--policy-dir`) |
| `_t94_identity_check` (через `lib_zones.sh`) | Решение 5 / 016 И-7, И-9 | Реестр зон, не дубль | 1 | без флагов | prepare/publish | ESSENTIAL |

## Итог

Р2-4 закрыт честно. Батарея architect не тронута и зелёна (18/19), подгонки проверок нет. Но зелень CI для Р2-1 куплена подменой доказательства. Обёртки сами пишут «судья принял» и «проверка прошла», а дверь получила флаг `--policy-dir`, через который вызывающий подставляет свою политику вместо доверенной. Оба пути живьём публикуют то, что по контракту 094 обязано быть отказано (P1, P2). Обёртка при этом не работает в настоящем репозитории харнеса (P3). Журнал так и не получил производственного писателя (Р2-2), allowlist по-прежнему зашит (Р2-3), а правка done_contract сломала check_consumers (Р3-4).

Маршрут — норма 050:
- Р3-1, Р3-3, Р3-4, Р2-2, Р2-3 → implementer;
- Р3-2 → сначала architect или владелец. Решение 6 против приёмки 5 и судьбы чужих семей 016/022/063/065: обёртка, которая не сочиняет журнал, неизбежно краснит их положительные контроли. Это то же решение, которого требовал маршрут Р2-1 круга 2 и которое не было принято;
- батарее нужна клетка на `--policy-dir`, если флаг останется (architect). Правильнее флаг убрать.

Ревьюер: reviewer.

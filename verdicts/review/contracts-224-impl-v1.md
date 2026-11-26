accept
OBJECT=50837d4eaad406f212f433ab95448debb0b5e753
СУД: репо=dev-harness; предмет=224; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev224; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Impl224 — implementer (MiniMax), Architect224d; предыдущие адверсарные: archive/224/adversary-v1-fail-0968979ed5, archive/224/adversary-v2-fail-6544febde7; правило остановки R-0115 п.1

# Reviewer 224 — дверь done выбирает свежий вердикт по кругу, реализация, вызов 1

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 6** — файл `.review/2026-11-25-2241.md` (`status: ready`):

- С-1…С-4: architect после done, К-08 — живые мутанты production без своей клетки.
- С-5: orchestrator → владелец — открытые предметы 043, 141 и 201 после ленда.
- С-6: orchestrator — CI-шаг без `--sintaksis`.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

Правило остановки R-0115 п.1. Адверсарий дважды (вызовы 1 и 2) дал FAIL только по К-08. Честную production он признал честной, нового адверсария нет. Его accept заменяет owner-аттестат консультанта после этого accept. Дыры К-08 из Adv224/Adv224b я воспроизвёл сам (раздел «Названные дыры»). Ни одна не даёт вреда на честной production; всё, что живо в батарее, ушло в советы architect.

Для done 224 нужен свежий accept адверсария на том же OBJECT. Это инв. 7 и `scripts/done_contract.sh:891–895`. Сейчас свежие у адверсария — FAIL `impl-v1` (1,0) и `impl-v2` (2,0). Значит, аттестат должен лечь носителем с ключом больше (2,0), например `verdicts/adversary/contracts-224-impl-v3.md`: первая строка accept, `OBJECT=` этот OBJECT. Иначе дверь откажет «свежий вердикт адверсария … не accept». Это наблюдение, не находка.

## Область правки

Команда: `git diff --name-status $(git merge-base origin/main HEAD) HEAD`. Merge-base `a32c577f292a2e925417d78a85cdb00abf25fae3` — это origin/main на старте ветки. Нынешний origin/main — `99e3f0d17`.

```
M	.github/workflows/ci.yml
M	fixtures/workshop_project/svezhest_verdikta_done_224/SDACHA.md
M	fixtures/workshop_project/svezhest_verdikta_done_224/build.py
M	fixtures/workshop_project/svezhest_verdikta_done_224/probe.py
M	fixtures/workshop_project/svezhest_verdikta_done_224/source.json
A	fixtures/workshop_project/svezhest_verdikta_done_224/stabs.tsv
A	fixtures/workshop_project/svezhest_verdikta_done_224/stabs/st22-lexical-order/done_contract.sh
A	fixtures/workshop_project/svezhest_verdikta_done_224/stabs/st23-eight-digit-limit/done_contract.sh
M	registry/ci-steps.tsv
M	registry/ci-zamery.tsv
M	scripts/done_contract.sh
```

`git log --format='%h %an %cn %s'`, коммит → файлы (`git show --stat`):

```
50837d4ea orchestrator orchestrator orchestrator: 224 CI-шаг — вес 650 / замер 570 после ремонта батареи (100 клеток, 23 стаба); пересчёт JOBS ci.yml; gen_ci_steps
   → .github/workflows/ci.yml, registry/ci-steps.tsv, registry/ci-zamery.tsv
9be668fbe architect orchestrator 224: различать числовой порядок и девятизначный круг в батарее
   → только fixtures/workshop_project/svezhest_verdikta_done_224/ (7 файлов)
4841a1a06 orchestrator orchestrator orchestrator: 224 CI-шаг … (--repo, --model и --stabs; вес 500 …)
   → .github/workflows/ci.yml, registry/ci-steps.tsv, registry/ci-zamery.tsv
fc7e7ed3a implementer orchestrator implementer 224: дверь done выбирает свежий вердикт по номеру круга
   → scripts/done_contract.sh (+184/−48)
```

Зоны frozen 224/1 (`git show 'frozen/contracts/224/1^{commit}':contracts/224-svezhest-verdikta-done.md | grep '^ЗОНА'`):

- implementer — `scripts/done_contract.sh`;
- architect — контракт и `fixtures/workshop_project/svezhest_verdikta_done_224/`;
- orchestrator — `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml`.

Каждый автор остался в своей зоне. Вне зон изменений нет. Атомарность: четыре коммита — четыре задачи, у каждого в сообщении ссылка на 224. В `ci.yml` изменён только генерируемый блок JOBS (083): `gen_ci_steps --check` rc 0.

Контракт после заморозки не менялся: `git diff --stat frozen/contracts/224/1^{commit} HEAD -- contracts/224-svezhest-verdikta-done.md` пуст. Заморозка `69b882418` — предок HEAD. Норм `roles/`, `AGENTS.md` и вердиктов дифф не трогает: `git diff --name-only a32c577f2 HEAD -- verdicts | wc -l` = 0. Удалений вердиктов в истории нет: `git log --diff-filter=D a32c577f2..HEAD -- verdicts` = 0 строк.

## Проверки не переписаны под код

- Батарея архитектора `20cf3d796` — предок коммита реализации `fc7e7ed3a` (`git merge-base --is-ancestor` rc 0).
- Ремонт Architect224d `9be668fbe` лёг после реализации, но он чисто аддитивный. `git diff 4841a1a06 HEAD -- probe.py build.py`:
  - добавлены 4 сценария;
  - числа 3/4 прежних сценариев вынесены в `old_round/new_round` без смены значений;
  - добавлены 2 строки `MUTATIONS` и самопроверка `stabs.tsv`;
  - ни одна прежняя клетка или ожидание не удалены и не ослаблены.
- Implementer батарею не трогал. `git diff 4841a1a06 HEAD -- scripts contracts` = 0 строк.
- Ожидания — литералы в `make_world`: `expected_rc`, marker, tag, head снимаются до вызова двери.
- Параллельность носителей проверяется `merge-base --is-ancestor` в обе стороны до merge (`probe.py:298-302`). Регрессии сверяются побайтно с до-224 дверью (`model/station.sh`).

## Регресс

Всё ниже — в чистом клоне с origin `ssh://git@github.com/a3ka/dev-harness.git`. Клон `git clone --dissociate`, без alternates, собственный `.git`, HEAD = OBJECT. `TMPDIR` внутри моей копии, вне клона. Шеллчек — пин 0.11.0. Команды шли по одной, в цепочке; `--stabs` первым. `W=bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh`.

| Команда | rc | Числа |
|---|---|---|
| `W --stabs` | 0 | CONTROL 100/100 GREEN; `STABY 23 SVJAZI 62 ZHIVYH 0` (230 с) |
| `W --repo .` | 0 | `KLETKI 100 KRASNYH 0` (139 с) |
| `W --model` | 0 | `KLETKI 100 KRASNYH 0` (123 с) |
| `W --sintaksis` | 0 | `SINTAKSIS 26 SHELLCHECK 2` (2 с) |
| `W --catalog` | 0 | `KLETKI 100 STABY 23 SVJAZI 62` |
| `W --compatibility` | 0 | `world201.live (0, '')`; historic186/129/190 GREEN |
| `W --independent-mutants` | 0 | `INDEPENDENT_MUTANTS 4 ZHIVYH 0` |
| `python3 …/context.py` | 0 | непустой каталог ИСТОЧНИК/ЗОНА/ПЕРЕСЕЧЕНИЕ |
| `W --repo <scripts main a32c577f2>` (красное-до) | 1 | `KLETKI 100 KRASNYH 59` — красны parallel/late-fail/duplicate/missing/conflict/date-order/nine-ten/ten-digit обеих ролей, historic186-phase-*/bad-call-name, record-*-конфликты; регрессии/OBJECT/historic-положительные зелёные (у Adv224 на 92 клетках было 53, +6 новых) |
| `python3 fixtures/freeze_contract/fail_closed_992.py` | 0 | `cases=25 observations=25 failures=0 not_applicable=0` |
| `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .` | 0 | `CELLS=62 STABS=0 FAILURES=0` |
| `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` | 0 | `CELLS=111 STABS=0 FAILURES=0` |
| `bash fixtures/check_consumers/red_C6_pisateli_minimum_net.sh` | 0 | — |
| `bash fixtures/freeze_contract/red_consumers_gejt_038.sh` | 0 | — |
| `bash fixtures/workshop_project/potrebiteli_116_195/red_potrebiteli_116_195.sh` | 1 | 14/13. Красная `k187a`: `NOT_IMPLEMENTED: реестр заморозок missing-remote`. На main `a32c577f2` в том же клоне (worktree) — тот же rc 1 и та же клетка. Это среда клона, 224 тут ни при чём |
| `bash scripts/verify_antiplacebo.sh --scope done_contract` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash scripts/check_provodka.sh . contracts/224-svezhest-verdikta-done.md` | 0 | — |
| `bash scripts/check_spec_ready.sh . contracts/224-svezhest-verdikta-done.md` | 0 | `OK` |
| `bash -n` по `scripts/done_contract.sh`, `stabs/st22…`, `stabs/st23…`, `red_…224.sh` | 0 ×4 | — |
| `shellcheck -S warning scripts/done_contract.sh` (пин) | 1 | только унаследованные SC2034 ×4 и SC1010. Множество предупреждений `-f gcc` на main `a32c577f2` и OBJECT совпадает поштучно: NEXT_ID_LIB, dir, vmax, ARCH187_LIB, SC1010, SC2295(note). Новых нет; контракт помечает их как baseline |
| `bash scripts/validate_std.sh bash scripts/done_contract.sh` | 1 | те же унаследованные предупреждения плюс SC2295 info, новых нет |

Счёт сверил своей мерой (другой командой, не `--catalog`):

- `jq '.stab_vhod|length' source.json` = 62.
- Уникальных стабов `jq -r '.stab_vhod[].stab' | sort -u | wc -l` = 23; `ls stabs | wc -l` = 23; `wc -l stabs.tsv` = 62.
- Клетки по `probe.py`: 19 сценариев × 2 роли + 24 именованные + 19 записей × 2 = 100.

С SDACHA и докладом адверсария 2 (100/23/62) всё сходится.

## Названные дыры: ручная проверка

Мутант — копия `scripts/` клона с одной заменой (`tmp/scratch-rev224/mutate.py`, якорь ровно один). Полная батарея: `W --repo <копия>`, по одному. Собственные клетки — `cells.py`. Он строит мир через `probe.make_world(role-nine-ten-accept)` на настоящих параллельных Git-носителях, правит имя и СУД носителя, коммитит и вызывает `probe.suite`: полный CLI, rc, обе трубы, HEAD, цель тега. `probe.py` не правился.

| Мутант (место) | `W --repo` | Свои клетки, 16 на роль ×2 | Вред на честной production |
|---|---|---|---|
| m1 `-gt` → `[[ > ]]` лексикографически (`:280`) | rc 1, `KRASNYH 4` (nine-ten-late-fail/accept обеих ролей) | 0 | пойман (st22) |
| m2 `${#version} -le 9` → `-le 8` (`:164`) | rc 1, `KRASNYH 2` (nine-digit обеих ролей) | 0 | пойман (st23) |
| m3 `${#number} -le 9` → `-le 8` (`:164`, Adv224b) | rc 0, `KRASNYH 0` — **живой** | 10 красных: k9-accept `RC,TAG_TARGET,STDERR rc=1 VERDICT_ROUND_INVALID …vyzov999999998` | нет: честная принимает `vyzov999999999` (k9-accept GREEN) → С-1 |
| m4 предел K снят (`:164`) | rc 0, `KRASNYH 0` — **живой** | 4 красных: k10/k10-overflow `RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0` — ложный done | нет: честная отказывает INVALID → С-1 |
| m5 ведущий ноль `-v0*N` + `10#` (`:151`) | rc 0, `KRASNYH 0` — **живой** | 4 красных: leading-zero-v09 rc=0 с тегом | нет: честная отказывает INVALID → С-2 |
| m6 `sort -V` вместо `-gt` (`:280`) | rc 0, `KRASNYH 0` | 0 | эквивалент на канонических ключах (цифры, без ведущих нулей) — не дыра |
| m7 гейт `merge-base rc>1` снят (`:277`) | rc 0, `KRASNYH 0` | 0 | ловит сосед 992: на m7 `A-done-order … oracle=0`, `failures=1`, rc 1 |
| m8 снятие CR удалено | rc 0, `KRASNYH 0` | 0, crlf-accept тоже GREEN | эквивалент на проверенном CRLF; CRLF контрактом не назван |
| m9 предел поколения фазы снят (`:225`) | rc 0, `KRASNYH 0` — **живой** | phase-10digit: rc=0 с тегом | нет: честная даёт CONFLICT → С-4 |
| m10 инверсия дат только в одну сторону (`:256`) | rc 0, `KRASNYH 0` — **живой** | date-inversion-desc: rc=0 с тегом | нет: честная даёт ORDER → С-3 |

Честная production на всех своих клетках, обе роли:

```
HONEST review:k9-accept GREEN … review:leading-zero-v09 GREEN
HONEST adversary:k9-accept GREEN … adversary:leading-zero-v09 GREEN
HONEST RED 0 OF 16
HONEST review:date-inversion-desc GREEN / adversary GREEN — RED 0 OF 2
HONEST review:phase-10digit GREEN / adversary GREEN — RED 0 OF 2
HONEST review:crlf-accept GREEN / adversary GREEN — RED 0 OF 2
```

Ключевой сырой вывод мутантов:

```
m3-number-le8 review:k9-accept RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: VERDICT_ROUND_INVALID: review: verdicts/review/contracts-777-impl-v1-vyzov999999998.md\n'
m3-number-le8 RED 10 OF 16
m4-number-unbounded review:k10-overflow RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
m4-number-unbounded RED 4 OF 16
m5-leading-zero review:leading-zero-v09 RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
m10-date-one-side review:date-inversion-desc RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
m9-phase-unbounded review:phase-10digit RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
=== RC=1 MUTANT m1-lexical (121s)      KLETKI 100 KRASNYH 4
=== RC=1 MUTANT m2-version-le8 (124s)  KLETKI 100 KRASNYH 2
=== RC=0 MUTANT m3-number-le8 (130s)   KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m4-number-unbounded    KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m5-leading-zero        KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m6-sort-v              KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m7-no-mergebase-gate   KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m8-no-cr-strip         KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m9-phase-unbounded     KLETKI 100 KRASNYH 0
=== RC=0 MUTANT m10-date-one-side      KLETKI 100 KRASNYH 0
992 на m7: A-done-order subject: control_rc=0 fault_rc=1 oracle=0 hit=1 accepted=0 … cases=25 observations=25 failures=1 → RC=1
```

Равенство координат `V×10⁹+K`:

- При конформных K (1 ≤ K ≤ 999999999) отображение инъективно: (1,999999999) → 1999999999 < (2,0) → 2000000000.
- Клетки `bigk-cross-accept` и `bigk-cross-late-fail` обеих ролей на честной зелёные. Старший accept (2,0) поверх FAIL (1,999999999) принят. Поздний FAIL (2,0) поверх accept (1,999999999) отказан с именем `impl-v2`.
- Максимум 999999999999999999 меньше 2⁶³.
- Коллизия появляется только у мутанта m4 (десятизначный K).

## Свои мутанты и дефекты честной production

Дефектов честной production на достижимом конформном состоянии не нашёл.

- Обе роли идут через одну функцию `_select_round_verdict` (`:394`, `:891`). Асимметрия ролей в выборе структурно невозможна. «v02: review отказал, adversary принял» у Adv224 объясняется формой имени, а не ролью. Фаза `реализация v02` вне грамматики и считается прозой. Тогда у `impl-v3` вызов 1 расходится с N=3 и даёт CONFLICT. У `impl-v2-vyzov2` K=2 совпадает с вызовом и проходит.
- Все кандидаты роли проверяются до выбора, отказ срабатывает до тега. Подстановки в шаблоны (`${rest#*"…"}`, `${token%%"…"*}`) экранированы. Regex из данных не строится (инв. 3).
- Ключи без ведущих нулей, поэтому восьмеричной ловушки `$((…))` нет.

Своя мера на НАСТОЯЩИХ вердиктах HEAD — функция из OBJECT по всем NNN обеих ролей (`realdata.sh`, `realdata_old.sh`). Ложного done нет. Есть новые именованные отказы у открытых предметов 043, 141 и 201, где старая дверь выбирала accept. Они предписаны грамматикой frozen 224 и вынесены в С-5 владельцу:

```
== review 043 → OLD verdicts/review/contracts-043-v3.md | accept
REFUSE done: VERDICT_ROUND_MISSING: review: verdicts/review/contracts-043-round2-fix-d1-n1n3.md
== review 141 → OLD verdicts/review/contracts-141-impl-v3.md | accept
REFUSE done: VERDICT_ROUND_CONFLICT: review: verdicts/review/contracts-141-impl-v4.md
== review 201 → OLD verdicts/review/contracts-201-mesto-v1.md | accept
REFUSE done: VERDICT_ROUND_CONFLICT: review: verdicts/review/contracts-201-mesto-v1.md
== adversary 201 → OLD/NEW verdicts/adversary/contracts-201-impl-v4.md | accept
```

## Остатки

- ОСТАТОК: К-16 — не укусил. Дифф не трогает `verdicts/`: 0 файлов, удалений в истории 0. Ложных согласованных метаданных в диффе нет. Граница «номер/дата не удостоверяют авторитет» сохранена: дверь не вводит аутентификацию.
- ОСТАТОК: К-11 — не укусил. Батарея исполняет копию `scripts/` в отдельном tools-каталоге, мир — отдельный Git. `probe.suite` очищает `GIT_*` и ставит `GIT_CONFIG_GLOBAL/SYSTEM=/dev/null`. Свидетель — rc, трубы и цель тега, снятые снаружи субъекта.
- ОСТАТОК: К-03 — не укусил. Production-дифф (`scripts/done_contract.sh`) — это функция `:113–287` и две замены цикла на её вызов: `:391–395` и `:890–892`. Связи F/CID/OBJECT, tree-равенство, влитость, класс риска, same-OBJECT, профиль, клапан v>1 и ПРОВОДКА не тронуты (хунков нет). Соседи 992 (25/25), 201 (62/0), 187 (111/0), C6, 038 и antiplacebo done_contract зелёные. Красная k187a в 116/195 совпадает с main.

## Норма 050 (паразитная сложность)

- `_select_round_verdict` (`scripts/done_contract.sh:113–287`):
  - (1) инв. 1–6, одна грамматика для обеих ролей;
  - (2) вводит глобальные `_rv_file`, `_rv_cid`, `_rv_first` — объявлены в шапке и сразу разобраны в месте вызова `:395`/`:892`;
  - (3) было два дублированных цикла (review и adversary), стала одна функция: число совместно меняемых мест сократилось 2 → 1;
  - (4) интерфейс — 2 аргумента и 3 выхода против ≈170 строк работы, модуль глубокий;
  - (5) потребители — `W --repo`, CI-шаг.
  - ESSENTIAL.
- CI-шаг и замер (`registry/ci-steps.tsv:332`, `ci-zamery.tsv:133`, генерируемый `ci.yml`):
  - (1) ПРОВОДКА/ПРЕДПОСЫЛКИ;
  - (2) состояния не вводит;
  - (3) стандартная тройка 083, без роста;
  - (4) н/п;
  - (5) потребитель — CI.
  - ESSENTIAL. Отклонение от ПРЕДПОСЫЛОК (`--sintaksis`) — С-6.
- Семья ремонта: 8 клеток, стабы st22/st23, 6 связей:
  - (1) инв. 2/3 — числовой порядок и предел девяти цифр (К-08 Adv224);
  - (2) состояния нет, носители генерирует `build.py`;
  - (3) правка одного источника `MUTATIONS`;
  - (4) н/п;
  - (5) потребители — `--repo`, `--stabs`, CI.
  - ESSENTIAL.
- `stabs.tsv`:
  - (1) конвенция станции Н-39 (привязки читаются из `stabs.tsv`; производный каталог, как в 206);
  - (2) производное от `source.json` состояние; расхождение даёт явный отказ `STAB_CATALOG_CHANGED` rc 2;
  - (3) генерируется тем же `build.py`, ручной правки рядом не добавилось;
  - (4) н/п;
  - (5) потребитель — самопроверка `carriers()` и чтение судьями.
  - ESSENTIAL по конвенции. Совет не выдвигаю: более простая форма без `stabs.tsv` нарушает требование задания Architect224d («требуемый stabs.tsv», SDACHA:33).

## Сверки

- СВЕРКА-АРХИТЕКТУРЫ: н/п. Контракт объявляет «АРХИТЕКТУРА: н/п — ремонт существующего станционного писателя, продуктовой модели 188 нет». В диффе нет `bindings.json`, новых писателей и операций. Писатель тега прежний (`done_contract.sh`). Долг не расширен, диффа модели нет.
- СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (`grep -c` = 0).
- Режим проекта 996: sourceCanon не объявлен (контракт, строка КОНТЕКСТ), сверка карты н/п. Мобильного экрана нет.
- ПРОВОДКА (038): guard `red_svezhest_verdikta_done_224.sh` существует и подключён. `check_provodka` rc 0. Guard — барьер именно этого предмета: CI-шаг 224 зовёт его `--repo/--model/--stabs`. Поведенческой нормы роли нет, ПРОВОДКА-ЭНФОРСМЕНТ обоснована чистой механикой выбора.

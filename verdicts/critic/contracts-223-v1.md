FAIL
OBJECT=7ad42a6cf380cac99e8ebc1074ffd39e7acdf5f1
СУД: репо=dev-harness; предмет=223; фаза=контракт; роль=critic; вызов=1 (полный; новый предмет); сессия=Crit223; модель-факт=openai-codex/gpt-6.1-terra; автор Architect223 — openai-codex/gpt-6.1-sol.

Модели подтверждены `bash scripts/models_actual.sh --bind --session Crit223` и `--session Architect223`, rc 0; автор и судья — разные сессии. Обязательная строка учёта запуска из §Счёт роли в задании не предъявлена и в доступных HANDOFF предмета и основного дерева не найдена. Поэтому этот файл — диагноз, а не материализованный вердикт до восстановления и сверки учёта оркестратором; отсутствующий счёт не считается нулём. Попытка сообщения `agent://Main` отклонена стражем Н-85. Самостоятельно писать чужой HANDOFF судья не вправе.

БЛОКИРУЕТ contracts/223-arch-ci-review.md:36,39,53,62 — критерий не различает потерю условия непустой дельты.
ОБХОД: в одноразовом клоне взять честную модель и удалить существующий предикат `[ "$_a187_npaths" -eq 0 ] ||` из условия остановки подъёма (`scripts/done_contract.sh:536`). `B --repo .` возвращает rc 0, `KLETKI 39 KRASNYH 0`. При этом достижимый Git-мир с двухродительским merge, дерево которого равно дереву первого родителя (создан `git commit-tree <p1^{tree}> -p <p1> -p <p2>`, пустота подтверждена `git diff --name-only`), с успехом arch только на первом родителе: честная дверь запрашивает HEAD и отказывает rc 1 без тега, мутант поднимается к первому родителю и возвращает rc 0 с done-тегом. Это меняет сохранённую семантику 187 и прямо нарушает требование непустого списка, независимо от того, есть ли продуктовая дельта в этом отдельном merge. Проверка должна различать пустую дельту и непустую служебную на настоящих Git-историях и требовать выбор верного SHA*; способ реализации клетки автор выбирает сам.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-08

Команда мутации в клоне: `python3 -c 'from pathlib import Path; r=Path("fixtures/workshop_project/arch_ci_review_223/model/done_contract.sh").read_text(); a="[ \"$_a187_npaths\" -eq 0 ] || [ \"$_a187_only\" -ne 1 ]"; b="[ \"$_a187_only\" -ne 1 ]"; assert r.count(a)==1; Path("scripts/done_contract.sh").write_text(r.replace(a,b,1))'`, затем `TMPDIR="$PWD/tmp" bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --repo .`:
```
KLETKI 39 KRASNYH 0
```
Проверка контрпримера: `TMPDIR="$PWD/tmp" python3 -B "$PWD/empty223.py"`; она использует `probe.py`/настоящий CLI, заменяет только созданный merge на commit-tree с деревом первого родителя, принудительно обновляет локальный origin и проверяет пустую дельту до вызова:
```
ATTACK honest-empty
honest-empty review-merge GREEN rc=1
RED 0
ATTACK mutant-empty
mutant-empty review-merge RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_ON_REFUSAL rc=0
RED 1
```

## Карта классов
К-01: чисто — check_sdacha --run rc 0; pre_critic rc 0; precision rc 0.
К-02: чисто — вход: затравка origin/main и письмо back-1190; sourceCanon не объявлен.
К-03: чисто — вход: frozen 187/3 и 201/1, объявлены неизменные ноги; регрессии включены в приёмку.
К-04: чисто — вход: зоны контракта и precision-gate rc 0.
К-05: чисто — вход: раздел приёмки и команды B, регресса, проводки.
К-06: чисто — вход: probe.py отклоняет посторонний отказ и исключения как rc 2.
К-07: чисто — вход: контроль модели в --stabs, 39 зелёных реальных Git-миров.
К-08: блок — пустая дельта проходит критерий с удалённым условием остановки.
К-09: чисто — вход: CASES probe.py, перечисленные операции и наследуемые регрессы; отсутствие пустой дельты входит в блок К-08.
К-10: чисто — вход: probe.py проверяет запрос к SHA, две трубы, настоящий annotated-тег и HEAD.
К-11: чисто — вход: ожидания и carrier считываются до вызова проверяемого процесса.
К-12: чисто — вход: git plumbing и настоящий CLI, jq у двери.
К-13: н/п — новые секретные входы не вводятся.
К-14: чисто — --stabs rc 0, девять эквивалентных предъявлений зелены.
К-15: чисто — --stabs выводит SVJAZI 23, --repo OBJECT KLETKI 39 KRASNYH 22; precision rc 0.
К-16: чисто — вход: риск авторизации приёмки заявлен; границы содержимого каталогов и доверенной среды названы.
К-17: н/п — станционный механизм, модель продукта 188 не объявлена.

## Проверки и атаки

`check_sdacha.sh "$PWD" contracts/223-arch-ci-review.md --run` с `SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400` и пинованным shellcheck: rc 0, `СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=0)`; `pre_critic` с теми же переменными, изолированный TMPDIR: rc 0, `КРИТИК: дверь зелёная`; `check_precision_gate.sh "$PWD" contracts/223-arch-ci-review.md` с отдельным TMPDIR: rc 0, `OK`. Первый параллельный precision имел ошибки временных файлов, первый pre_critic был запущен без переменной shellcheck; изолированные повторы выше исправляют условия запуска, не кандидат.

`B --stabs` rc 0: честный контроль 39 зелёных, `ZHIVYH 0 SVJAZI 23`. `B --repo .` на OBJECT rc 1: `KLETKI 39 KRASNYH 22`; причина review-служебных клеток — старая дверь ещё останавливается на `.review/`, в негативных API-клетках не совпадает SHA запроса. Исполнитель в своей зоне должен расширить существующий классификатор, сохранив прочие операции, не заменить всю дверь моделью.

Независимая проба в одноразовом клоне (`TMPDIR="$PWD/tmp/scratch-crit223" python3 -B "$PWD/tmp/clone-crit223/attack223.py"`), сырые результаты:
```
ATTACK prefix CASE reviewx
prefix reviewx RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_ON_REFUSAL rc=0
RESULT prefix red 1
ATTACK case-fold CASE review-uppercase
case-fold review-uppercase RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_ON_REFUSAL rc=0
RESULT case-fold red 1
ATTACK any-dot CASE review-other-dot
any-dot review-other-dot RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_ON_REFUSAL rc=0
RESULT any-dot red 1
ATTACK rename CASE product-rename-out
rename product-rename-out GREEN rc=1
RESULT rename red 0
ATTACK harness CASE harness-merge
harness harness-merge RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_TARGET rc=1
RESULT harness red 1
ATTACK empty-delta CASE review-merge
empty-delta review-merge GREEN rc=0
RESULT empty-delta red 0
ATTACK newline CASE review-newline
newline review-newline RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_TARGET rc=1
RESULT newline red 1
ATTACK missing-run CASE review-missing-run
missing-run review-missing-run RED RC,REFUSAL_DIAGNOSIS,TAG_ON_REFUSAL rc=0
RESULT missing-run red 1
```
Это адресные пробы отдельных клеток, не утверждение о зелёности всей батареи для rename: авторский `--stabs` ловит ту же операцию на `product-rename-in`. Отдельная пустая Git-дельта и полный прогон мутанта приведены в блоке выше.

Scoped 224 на OBJECT: rc 0, `KLETKI 100 KRASNYH 0`. Проводка guard заявлена на этап orchestrator после freeze и до done; `AGENTS.md` шаг 8 требует зелёной проводки для done, не требует преждевременно подключить её до работы implementer. Риск принятия семантически продуктового содержимого внутри служебного каталога назван в НЕ ЗАЩИЩАЕТ, новую границу не предлагаю.

Scoped-регрессы на OBJECT: `187 --repo .` rc 0, `CELLS=111 STABS=0 FAILURES=0`; `201 --repo .` rc 0, `CELLS=62 STABS=0 FAILURES=0`.

Докоммитная команда `bash scripts/check_verdict_karta.sh "$PWD" verdicts/critic/contracts-223-v1.md` вернула rc 1: `ОТКАЗ: вердикт не закоммичен (AGENTS п.9): verdicts/critic/contracts-223-v1.md нет на HEAD`. Скрипт читает исключительно HEAD-блоб, поэтому требуемый заданием rc 0 до коммита недостижим; проверка после коммита необходима. `pre_judge.sh verdict` до коммита rc 0 (`VERDICT_BRANCH=wip/223/critic`).

Тот же мутант дополнительно предъявлен scoped-регрессам из контракта в одноразовом клоне: `187 --repo .` rc 0 `CELLS=111 STABS=0 FAILURES=0`; `201 --repo .` rc 0 `CELLS=62 STABS=0 FAILURES=0`; `224 --repo .` rc 0 `KLETKI 100 KRASNYH 0`. Следовательно ни один названный регресс не закрывает обход.

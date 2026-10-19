accept
OBJECT=1228d6f6bd51d883670e897f314ddbd50e68dc32

# Контракт 996 — единственный микро-круг после арбитража

Предмет: `contracts/996-rezhim-proekta-polnyj-cikl.md` на указанном OBJECT, ветка `wip/996/architect`. Проверены только закрытый перечень К1–К20 и правки П1–П8 из `origin/main:verdicts/arbitration/contracts-996-closed-preserved-v1.md`. Допуск — задание на этот микро-круг в пределах tri-slota §2 п.2. Нового круга или расширения предмета этот вердикт не разрешает.

Набор артефактов полон: предмет закоммичен, критерий и команды есть, исполнители и границы названы. Прочитаны roles/critic.md, AGENTS.md, три предыдущих вердикта из origin/main, арбитраж и решение tri-slota. Заморозка, реализация и ноутбучная приёмка этим вердиктом НЕ объявляются выполненными. Санкция владельца на ролевые строки по-прежнему требуется.

## Решение

Блокирующих обходов по закрытому перечню не осталось. П1–П8 выполнены в пределах предреализационного предмета арбитража. Честная модель проходит 75 сценариев; матрица проверяет 56 именованных мутантов, расхождений нет. Продукт до реализации ожидаемо красен: 63 расхождения из 75 сценариев.

Вывод основан не только на авторской матрице. Шесть дефектов круга 3 внесены БЕЗУСЛОВНО в отдельную копию нового эталона, без переключателя MUTANT_996. Каждый прогнан против всех 75 сценариев: корневые закрытия, чтение плана рабочего дерева, незакоммиченный реестр, автор architect, принятие критиком всего кроме FAIL и аналогичная грамматика done. Все пойманы именно соответствующими новыми сценариями, не падением инфраструктуры или посторонним гейтом. Отдельно воспроизведены прежние три мира closures_decoy.py и проверка автора: A rc1, B rc0 с frozen-тегом, C rc1; автор нового эталона — orchestrator. Два дополнительных мутанта арбитра, refuse-after-tag и cap-ignores-history, также остались красными.

## Сверка П1–П8

Ссылки `:N` ниже относятся к `contracts/996-rezhim-proekta-polnyj-cikl.md` на OBJECT.

| Правка | Результат и место |
|---|---|
| П1 / К5, К6 | `:51,77,87`: источник закрытий — профильный HEAD-блоб; роль plan_adapter названа точно. freeze-closures-preserved и freeze-head-plan-preserved зелены на честном эталоне, красны на безусловных прежних обходах. В gate_test после отказа проверяются HEAD/refs/байты, затем исправляется тот же вход и требуется успешная заморозка. Три прежних мира закрытий дали A=1/B=0/C=1. |
| П2 / К3, К14 | `:51,87`; `fixtures/workshop_project/rezhim_996/probe.py:658–663`: проверяется HEAD-блоб реестра и `%an=orchestrator`, а не только рабочий файл. Оба безусловных мутанта убиты на freeze-profile. Прежний model_author теперь показывает orchestrator. |
| П3 / К10 | `:87`; `probe.py:412–441`: четыре отказа по грамматике, неизменность HEAD/refs/байтов, исправление первой строки на accept и успешный тег. Оба прежних обхода убиты на обеих своих строках. Нормализация эталона: freeze — strip с точным accept; done — strip/lower. |
| П4 / К7 | `:117,122–125`: выбран разрешённый арбитром вывод check_charter из 996; файл убран из зоны и пакета B. В НЕ ЗАЩИЩАЕТ указан остаток и ловец reviewer через diff с frozen-тегом. Это разрешённый способ В, отдельная проба charter-project не требуется. |
| П5 / К14 | `:51`: авторство определено как identity коммита реестра freeze/mint и identity зон check_zones/check_staged. |
| П6 / К20 | `:51`: check_plan/gen_plan/track_digest проектную раскладку не получают; изоляция reserve/mint/print-context передана ноутбучному check_no_leak. Вывод явный, а не молчаливое отсутствие пробы. |
| П7 / К17–К19 | `:51`: один код дверей, запрет второй копии грамматики/гейтов/капа/свежести/v>1/чистоты/main, действующие семьи и reviewer как ловец. В `:87` записан закрытый перечень К1–К16 со сценариями и К17–К20 со способами закрытия. Реализацию инварианта проверит reviewer; пакеты ещё не предъявлены. Два редакционных совета ниже не образуют механического обхода. |
| П8 | Новый OBJECT проверен; pre_critic rc0; матрица rc0; продукт rc1; прежние closure/author-репро дали требуемые значения; threat-model и precision rc0. check_provodka rc1 из-за отсутствующей санкционируемой строки — ожидаемая граница, не блокер. |

## Закрытый перечень К1–К20

Для способов С «зелёный» означает честную модель, «красный» — пробу на дефектном субъекте. Это не утверждение готовности ещё не реализованного продукта. Для способов Л/В применён именно разрешённый арбитром способ, без дополнительного требования проектного мутанта.

| Пункт | Проверенное закрытие |
|---|---|
| К1 | freeze-profile/done-profile зелены; root-verdict красен на обоих; root-layout красен на paths. Прежний объём пункта «есть» сохранён. |
| К2 | freeze-root-only/done-root-only, freeze-cap и обе arbitration-пробы зелены; fallback-root, ignore-project-cap, root-arbitration красны на своих входах. Безусловный cap-ignores-history пойман на freeze-cap и freeze-root-arbitration. |
| К3 | freeze-profile различает закоммиченный реестр правильного автора от обоих прежних дефектов; корневого registry в честном мире нет. |
| К4 | freeze-plan-preserved: root-plan и skip-plan красны. |
| К5 | freeze-head-plan-preserved: worktree-plan красен, честный HEAD-блоб даёт отказ до коммита и успех после исправления. |
| К6 | freeze-closures-preserved: root-closures красен; независимые прежние миры подтвердили обе стороны границы и отсутствие закрытий. |
| К7 | Разрешённый вывод П4б, с риском и ловцом. |
| К8 | zones-project/staged-project/lib-zones-project ловят root-contracts-only; zones-green/staged-green ловят reject-all-zones. |
| К9 | Сумма К1/К2/К4/К6/К8; mint-project ловит mint-root-registry; precritic-context/existing проверяются с профильным реестром. |
| К10 | Четыре грамматических сценария зелены; два безусловных прежних мутанта красны на соответствующих ESCALATE и внеграмматической строке. |
| К11 | done-fresh зелён; old-review красен. |
| К12 | gate_test проверяет снимок HEAD/refs/байтов; безусловный refuse-after-tag пойман на 12 сценариях с PROJECT_GATE_REFUSAL_MUTATED. |
| К13 | spec/consumers/precision/doc/provodka: соответствующие skip-* и skip-gates красны на своих входах; честные отказы и исправления проходят. |
| К14 | Определение П5, проверка К3, mint-project и zones/staged. |
| К15 | precritic-spec/precision/n39/context/existing зелены; соответствующие skip-* красны. |
| К16 | freeze-/done-committed-preserved зелены; skip-committed красен на обоих. |
| К17 | Способ Л: единый gitw/resolver, прежние семьи и parsing-батарея названы. На этом прогоне рабочая команда 045, семья 054 и parsing-батарея зелены; ограничения дополнительного прогона 071 указаны ниже, зелёный результат ему не приписывается. |
| К18 | Способ Л: общий freeze/done, явно перечислен клапан v>1, действующие семьи и обязательный ловец reviewer. Проектный негатив сверх этого арбитраж не требует. |
| К19 | Способ Л: общий mint_line, чистота/main включены в инвариант; mint-project/mint-no-authority и их мутанты проверены. |
| К20 | Способ В: обе исключённые области прямо названы; ноутбучная изоляция остаётся обязательной, NOT_RUN не превращён в доказательство. |

## Советы, не блокируют

СОВЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:83 — буквальная команда `bash fixtures/_krasnye_045.sh` требует обязательного аргумента и возвращает rc1. Исполняемая команда существующей семьи — `bash fixtures/_krasnye_045.sh scripts/gitw`, она дала rc0. Указать этот аргумент, чтобы исполнитель не восстанавливал команду по usage. Это ложное красное команды, не обход, при котором невыполненный предмет объявляется готовым; основанием FAIL в этом микро-круге не является.

СОВЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:87 — скобочные имена мутантов в перечислении К3/К6/К10 избыточны для требуемого арбитром списка «сохраняется → сценарий». Для ясности П7б оставить в прозе сценарии, а имена мутантов и их привязку — в MUTANTS. Пробы проверены исполнением независимо от этих скобок; нового механического обхода они не образуют.

## Команды и сырой вывод

Клон: `/tmp/dev-harness-verify/critic996r4/clone`, получен SSH-clone с origin. Основной чекаут не использован, коммит/пуш вердикта не выполнялся. Последующие репро помещены под `/tmp/dev-harness-verify/critic996r4/`; TMPDIR задан в scratch, Python sitecustomize перенаправляет явный tempfile dir=/tmp туда же. Обвязка меняет размещение временных каталогов, не исходники OBJECT и не логику дверей.

### Объект и обязательный первый предполёт

```text
$ git fetch origin wip/996/architect
From ssh://github.com/a3ka/dev-harness
 * branch              wip/996/architect -> FETCH_HEAD
$ git checkout --detach 1228d6f6bd51d883670e897f314ddbd50e68dc32
HEAD is now at 1228d6f6 996: closures/registry/grammar project negatives per arbitration K1-K20
$ git rev-parse HEAD
1228d6f6bd51d883670e897f314ddbd50e68dc32
$ git fetch origin --tags
RC=0
$ bash scripts/pre_critic.sh --repo . contracts/996-rezhim-proekta-polnyj-cikl.md
КРИТИК: дверь зелёная
RC=0
$ bash scripts/check_threat_model.sh . contracts/996-rezhim-proekta-polnyj-cikl.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
RC=0
$ bash scripts/check_precision_gate.sh . contracts/996-rezhim-proekta-polnyj-cikl.md
OK
RC=0
```

### Матрица и продукт

Полный вывод: `matrix.log`, `product.log`, `provodka.log` рядом с вердиктом. Ниже дословные итоговые строки и новые различающие строки, не весь журнал.

```text
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
mutation root-closures: freeze-closures-preserved: rc=1 PROJECT_GATE_BYPASSED:closures rc=0 stdout='' stderr=''
mutation worktree-plan: freeze-head-plan-preserved: rc=1 PROJECT_GATE_BYPASSED:worktree-plan rc=0 stdout='' stderr=''
mutation registry-uncommitted: freeze-profile: rc=1 REGISTRY_NOT_COMMITTED_AS_ORCHESTRATOR rc=0 stdout='' stderr=''
mutation registry-author-architect: freeze-profile: rc=1 REGISTRY_NOT_COMMITTED_AS_ORCHESTRATOR rc=0 stdout='' stderr=''
mutation critic-not-fail-is-accept: freeze-escalate: rc=1 VERDICT_GRAMMAR_BYPASSED:freeze-escalate rc=0 stdout='' stderr=''
mutation critic-not-fail-is-accept: freeze-ungrammatical: rc=1 VERDICT_GRAMMAR_BYPASSED:freeze-ungrammatical rc=0 stdout='' stderr=''
mutation review-grammar: done-escalate: rc=1 VERDICT_GRAMMAR_BYPASSED:done-escalate rc=0 stdout='' stderr=''
mutation review-grammar: done-ungrammatical: rc=1 VERDICT_GRAMMAR_BYPASSED:done-ungrammatical rc=0 stdout='' stderr=''
996: examined=75 mutants=56 mismatches=0
RC=0
$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=75 mutants=0 mismatches=63
996: проектный цикл не замкнут
RC=1
$ bash scripts/check_provodka.sh . contracts/996-rezhim-proekta-polnyj-cikl.md
проводка: норма-строка не найдена в role-файле: roles/orchestrator.md
RC=1
```

### Прежние обходы безусловно внесены в новый эталон

`python3 /tmp/dev-harness-verify/critic996r4/replay_round3.py` → rc0. В нём перенесены прежние closures_decoy.py и legacy_closures_author.py с заменой только scratch-пути; безусловные мутации перенесены на новые текстовые якоря модели. Каждая отдельно исполняет `bash fixtures/workshop_project/rezhim_996/probe.sh --model` на всех 75 сценариях. Полный вывод каждого — `unconditional-<имя>.log`.

```text
A root-decoy closes 775 (expect rc1)     model freeze rc=1 tags=[] err='ОТКАЗ: контракт вне плана: 777'
B project closes 775 (expect rc0)        model freeze rc=0 tags=[frozen/contracts/777/1] err=''
C no closures (expect rc1)               model freeze rc=1 tags=[] err='ОТКАЗ: контракт вне плана: 777'
honest model project freeze rc=0 tags=[frozen/contracts/777/1] registry-author=orchestrator
root-closures: rc=1 killed_by=1 ['996: examined=75 mutants=0 mismatches=1', '996: проектный цикл не замкнут']
  freeze-closures-preserved: rc=1 PROJECT_GATE_BYPASSED:closures rc=0 stdout='' stderr=''
worktree-plan: rc=1 killed_by=1 ['996: examined=75 mutants=0 mismatches=1', '996: проектный цикл не замкнут']
  freeze-head-plan-preserved: rc=1 PROJECT_GATE_BYPASSED:worktree-plan rc=0 stdout='' stderr=''
registry-uncommitted: rc=1 killed_by=1 ['996: examined=75 mutants=0 mismatches=1', '996: проектный цикл не замкнут']
  freeze-profile: rc=1 REGISTRY_NOT_COMMITTED_AS_ORCHESTRATOR rc=0 stdout='' stderr=''
registry-author-architect: rc=1 killed_by=1 ['996: examined=75 mutants=0 mismatches=1', '996: проектный цикл не замкнут']
  freeze-profile: rc=1 REGISTRY_NOT_COMMITTED_AS_ORCHESTRATOR rc=0 stdout='' stderr=''
critic-not-fail-is-accept: rc=1 killed_by=2 ['996: examined=75 mutants=0 mismatches=2', '996: проектный цикл не замкнут']
  freeze-escalate: rc=1 VERDICT_GRAMMAR_BYPASSED:freeze-escalate rc=0 stdout='' stderr=''
  freeze-ungrammatical: rc=1 VERDICT_GRAMMAR_BYPASSED:freeze-ungrammatical rc=0 stdout='' stderr=''
review-grammar: rc=1 killed_by=2 ['996: examined=75 mutants=0 mismatches=2', '996: проектный цикл не замкнут']
  done-escalate: rc=1 VERDICT_GRAMMAR_BYPASSED:done-escalate rc=0 stdout='' stderr=''
  done-ungrammatical: rc=1 VERDICT_GRAMMAR_BYPASSED:done-ungrammatical rc=0 stdout='' stderr=''
```

### Контроли арбитра К2 и К12

`python3 /tmp/dev-harness-verify/critic996r4/replay_arbitration.py` → rc0. Взяты точные две дополнительные замены из `/tmp/dev-harness-verify/arbiter996/measure.py`, также без MUTANT_996. Полные выводы — `unconditional-refuse-after-tag.log` и `unconditional-cap-ignores-history.log`.

```text
refuse-after-tag: rc=1 killed_by=12
cap-ignores-history: rc=1 killed_by=2
freeze-cap: rc=1 PROJECT_CAP_BYPASSED rc=0 stdout='' stderr=''
freeze-root-arbitration: rc=1 PROJECT_CAP_BYPASSED rc=0 stdout='' stderr=''
```

### Дополнительные scoped legacy-контроли и ограничения прогона

Полные завершённые журналы — `legacy-045-as-written.log`, `legacy-045.log`, `legacy-054.log`, `legacy-105.log`, `legacy-profile-parser.log`. Ниже дословные фрагменты.

```text
$ bash fixtures/_krasnye_045.sh
fixtures/_krasnye_045.sh: line 14: 1: использование: fixtures/_krasnye_045.sh <guard-путь>
RC=1
$ bash fixtures/_krasnye_045.sh scripts/gitw
gitw/red_gitw_obmen.sh rc=0
итог: 1 файлов, провалов 0
RC=0
$ bash fixtures/_krasnye_054.sh
стаб-пак: просмотрено 20, поймано 20
честная часть: проверено предъявлений 37
054-батарея зелёная
итог 054: rc=0
RC=0
$ bash fixtures/_krasnye_105.sh
105 стаб-пак: мутантов 7, поймано на своей клетке 7, ускользнуло: нет
105 стаб-пак: честных входов мутантов 28, зелёных 28, красных: нет
ИТОГ 105: rc=0
RC=0
$ bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver
БАТАРЕЯ profile_resolver: класс delimiter-collision      — закрыт (rc 0)
БАТАРЕЯ profile_resolver: класс regex-injection          — закрыт (rc 0)
БАТАРЕЯ profile_resolver: класс silent-drop              — закрыт (rc 0)
БАТАРЕЯ profile_resolver: класс self-application-green   — закрыт (rc 0)
БАТАРЕЯ profile_resolver: итог 4/4 классов закрыто
RC=0
```

071 была запущена дополнительным раннером, но завершённый результат не получен: раннер и оставшаяся scoped-дочерняя команда остановлены. Наблюдаемый итог фонового задания — `Command exited with code 143`, не результат батареи 071. Причина остановки дальнейшей последовательности: следующая 103 жёстко задаёт scratch вне разрешённого каталога (`fixtures/project_paths_103/_toy.sh:124,173`, `battery_stubs.sh:40`), TMPDIR это не исправляет. 103 не запущена. Зелёного результата ни 071, ни 103 этот вердикт не утверждает. Требования их успешного послереализационного прогона не сняты. Общая CI-приёмка, семьи freeze/done целиком и ноутбучный цикл здесь не запускались.

Офлайн-пробы подтверждают различимость критерия, а не реальный цикл Complior-back. Ноутбучный прогон, CI реализации и санкции владельца остаются условиями последующих этапов. Условного accept и дополнительных обязательных правок этим вердиктом не вводится.

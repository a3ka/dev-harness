FAIL

СУД: repo=dev-harness; предмет=167; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Critic167Glm1; модель-факт=zai/glm-5.3 (workstation); SHA=5c184138d9eb53c7607107d96f224a88ec1117b0; предыдущий=нет; исключение=нет. Независимость: автор конструкции openai-codex/gpt-6-sol, судья zai/glm-5.3 — разные семейства. Одноразовый клон /tmp/dev-harness-verify/Critic167Glm1/repo из ssh://git@github.com/a3ka/dev-harness.git @ origin/main=adeeba0b6; blob контракта 68ca3f76e5 побайтно равен blob на OBJECT — судится закоммиченный текст.

## Что сошлось (живые прогоны в одноразовом клоне)

- `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo` → rc 1: `CASE interrupted KRASNO` (RELEASE `yield` вместо `obryv_bez_verdikta`), `CASE verdict/verdict_no_receipt-контроль`, `MERGE separate KRASNO`/`MERGE registry KRASNO` с причиной «merge main в ветку запрещён» — красный контроль честный, ровно по критерию (:20).
- `--model` → rc 0 (5 CASE + 5 MERGE ok); `--stabs` → rc 0, 11 строк `STAB ... caught` (6 судейских + 5 merge), `STAB_ZHIV` нет.
- `bash scripts/pre_critic.sh --repo . contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md` → rc 0; `bash scripts/check_threat_model.sh . contracts/167-…` → rc 0 (ЗАЩИЩАЕТ 2 / НЕ ЗАЩИЩАЕТ 2); `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic167Glm1/repo contracts/167-…` → rc 0 «OK» (норма 043: новые ЗОНА-строки и семья case-файлов obryv_167 — гейт прогнан живьём).
- Счётные утверждения сверены ВСЕ, расхождений нет: `.githooks/pre-push:188–239,323–337`; `scripts/check_charter.sh:46–51` (merge судится по первому родителю); `scripts/zamok_predmeta.sh:219–240,437–468,557–596` (D11 «любой START», D11 внутри проверки `zanyat`, osvobodit с причинами yield/broshen/ZAMOK_ZHIV); `verdicts/critic/contracts-161-v3.md:1–3` (формат: первая строка FAIL, `OBJECT=<sha>`, `СУД: …роль=…; сессия=…`); Н-213 = сломанный инкрементальный кеш CI, Н-294 = повтор merge с неточным ярлыком, Н-191/Н-281/Н-286 = источник запрета, Н-62 = урок без механизма, Н-315 = подмена роли после отказа (NABLIUDENIA.md:462/7689/1133/5254/7255/7416/8053); арбитраж merge-wip-protiv-main-konflikt-norm.md отклонил выборочное разрешение «только конфликтующие файлы» (замер 4) и предложил исправить ярлык на Н-191/281/286; `registry/contracts.tsv:174` несёт 167, `registry/plan.tsv:68` несёт 140; грамматика строки реестра `^[0-9]{3} → [0-9a-f]{40}$` совпадает с живым файлом; другого предмета с `obryv_bez_verdikta` в contracts/ нет.
- Прозы «стаб↔ветвь» в контракте нет — стабы привязаны кодом архитектора (probe.py/merge_probe.py), контракт несёт инварианты и rc-команды. ЗОНА-строки (:30–35) покрывают все затрагиваемые файлы (zamok_predmeta.sh, .githooks/pre-push, roles/orchestrator.md, probe.py 140, CI-файлы, verdicts/*), между ЗОНА-строками пересечений нет; precision-гейт зона-коллизии закрыл rc 0. КЛАСС РИСКА: обычный — строка есть, основание названо. Сужение запрета merge ровно до названного случая в тексте выдержано: полный `merge --no-ff`, wip первым родителем, main вторым = живой origin/main, без force, непересекающиеся пути либо реестр с объединением строк; прочее — отказ; check_charter независим (:14). Счёт кругов в покрытой части не ослаблен: закоммиченный вердикт → `verdikt_zakommiten`, повтор rc 1 `OBJECT_UZHE_SUZHEN` (включая случай «commit есть, release ещё не сделан»); yield-без-commit → ровно один повтор, второй повтор без собственного release rc 1; живой судья `ZAMOK_ZHIV`; недоступность судейских refs → rc 2 `NOT_IMPLEMENTED` без записи RELEASE.

## Блокирующие находки

БЛОКИРУЕТ contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md:16 (критерий :19–24) — критерий W не различает удаление ни одного из аутентичностных гейтов verdict_sessii (author=роль; путь `verdicts/<роль>/contracts-<N>-v*`; строка `OBJECT=`; поле `сессия=`), тогда как предмет объявляет их истинностью вердикта: критерий слабее предмета.
ОБЯЗАТЕЛЬСТВО: «Истинность verdict доказывается Git-коммитом в refs судейской ветки и blob: … точная самостоятельная строка OBJECT=<sha>, литеральные поля роль=<роль>; и сессия=<holder>; … author коммита совпадает с ролью; одной подложной строки в ledger/журнале/рабочем файле недостаточно» и «Судья START без закоммиченного вердикта данной роли/сессии/OBJECT … не тратит круг D11» (:16).
СОСТОЯНИЕ: реализация `scripts/zamok_predmeta.sh` (или контрольная модель), у которой удалён/расширен любой один из четырёх гейтов, проходит W --repo/--model/--stabs целиком зелёным — доказано мутациями M1/M2/M3/M6 (команды и сырой вывод ниже).
НАБЛЮДЕНИЕ: на конформном входе (законченная сессия, явный release, доступный Git-commit, блоб-вердикт с точными объектом и сессией, отклонение ровно в одном гейте) честный контроль даёт `RELEASE.prichina=obryv_bez_verdikta` + повтор rc 0, мутант — `verdikt_zakommiten` + rc 1 `OBJECT_UZHE_SUZHEN`: законный круг предмета сжигается чужим или подложным коммитом. Источники входа документированы: вердикты под чужим %an уже случались (замер 4 в verdicts/arbitration/reglament-ispolnitel.md — два вердикта критика ушли в историю с %an=architect); сам контракт признаёт «существование сессии или текста scratch не равно коммиту вердикта» (:11) и запрещает считать подложную строку в рабочем файле.
ОБХОД: удалить из verdict_sessii строку `  [ "$(git -C "$REPO" log -1 --format=%an "$c")" = "$3" ] || continue` — все 5 официальных CASE остаются ok (то же подтверждено для удаления проверок `сессия=`, `OBJECT=` и расширения пути до `verdicts/"$dir"/*.md`); различающий вход: блоб `FAIL / OBJECT=<obj> / СУД: …сессия=Critic167First`, закоммиченный `user.name=Critic167First` → контроль obryv+rc0, мутант verdikt_zakommiten+rc1. Закрывающее свойство: красные клетки на вердиктах, отклоняющихся ровно в одном гейте (author/путь/OBJECT/сессия), с ожиданием `obryv_bez_verdikta` и rc 0 повтора; реализация обязана сохранять все гейти. Четыре примера — один класс причины.

БЛОКИРУЕТ contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md:14 (критерий :19–24) — критерий W не различает расширение merge-исключения за пределы именованной wip PR-ветки.
ОБЯЗАТЕЛЬСТВО: «только для именованной wip PR-ветки» и «Любые остальные пересечения, неполный merge, иная ветка или неопределённость — отказ; другие merge main→wip остаются запрещены» (:14).
СОСТОЯНИЕ: реализация pre-push с исключением без реф-условия (для любой пушимой ветки) проходит W целиком зелёным — доказано мутацией M7.
НАБЛЮДЕНИЕ: батарея пушит только `refs/heads/wip/167/architect`; различающий вход — конформный двухродительский merge с актуальным origin/main, запушенный на `refs/heads/feature/other-branch`: честная модель отказывает rc 1 «merge main в ветку запрещён», мутант разрешает rc 0. Вход — поддерживаемая операция: кольцо судит каждый `refs/heads/*` кроме main (`.githooks/pre-push:323–337`); грамматика критерия (:19) исключает из конформных входов только «любой JSON с VERDICT», «частичный merge» и «устаревшую локальную main» — иная ветка не исключена, обязательство названо в том же предложении, что и исключение.
ОБХОД: в исключении модели убрать условие `[ "$ref" = 'refs/heads/wip/167/architect' ]` — все 5 MERGE-форм официальной батареи дают те же исходы (separate/registry ok; overlap/registry_drop/partial отказ), различающий вход разделяет (honest rc 1 / mutant rc 0). Закрывающее свойство: красная клетка на push конформного merge в не-wip ветку с ожиданием отказа, либо иная клетка, различающая реф-условие.

## Советы (едут с исправлением, отвечать не обязан)

- СОВЕТ contracts/167-…md:14 — проводка «живого origin/main» не пришита клеткой: мутация M8 (политике передан `refs/heads/main` вместо `$LIVE_MAIN`) проходит официальную батарею зелёным; на входе с ушедшим вперёд live main (локальный main откачен назад) честная модель отказывает rc 1, мутант разрешает rc 0. Грамматика критерия исключает «устаревшую локальную main» из валидных контрпримеров, поэтому находка не блокирующая; красная клетка дешёвая, если владелец захочет пришить и её.
- СОВЕТ contracts/167-…md:14 — остаток Н-191 не назван: 167-merge при уставных правках в main-дельте (пути не пересекаются → merge разрешён) упрётся в check_charter, судящий merge по дельте к первому родителю; штатный путь до ленда в этом случае не доезжает (fail-closed, риска нет) — назвать остаток в норме или в НЕ ЗАЩИЩАЕТ.
- СОВЕТ критерий :21 — брошенный holder (broshen, без yield) нормой назван, но клеткой не покрыт; seam тот же, случай дешёвый.
- СОВЕТ :36–118 — 87 строк ПЕРЕСЕЧЕНИЕ механически корректны (precision gate rc 0), но одна строка на файл покрывала бы то же обязательство.

## Атаки до кода (одноразовый клон, команды и сырой вывод)

Судейская сторона — мутации контрольной модели, прогон официальных 5 CASE на каждом мутанте + различающий вход (harness /tmp/dev-harness-verify/Critic167Glm1/mut/mutations_judge.py, запуск `python3 …/mutations_judge.py` из клона):

```
CONTROL official cases green: True
M1_no_author_check: battery_green_on_mutant=True; distinct input verdict_wrong_author: control(prichina=obryv_bez_verdikta, repeat_rc=0) mutant(prichina=verdikt_zakommiten, repeat_rc=1)
M3_no_session_check: battery_green_on_mutant=True; distinct input verdict_wrong_session: control(prichina=obryv_bez_verdikta, repeat_rc=0) mutant(prichina=verdikt_zakommiten, repeat_rc=1)
M6_no_object_check: battery_green_on_mutant=True; distinct input verdict_wrong_object: control(prichina=obryv_bez_verdikta, repeat_rc=0) mutant(prichina=verdikt_zakommiten, repeat_rc=1)
M2_broader_path: battery_green_on_mutant=True; distinct input verdict_wrong_path: control(prichina=obryv_bez_verdikta, repeat_rc=0) mutant(prichina=verdikt_zakommiten, repeat_rc=1)
BLOCKER_CLASS_MUTATIONS: ['M1_no_author_check', 'M3_no_session_check', 'M6_no_object_check', 'M2_broader_path']
```

Merge-сторона — мутации model-hook (harness …/mutations_merge.py):

```
M7_ref_widened: official battery green on mutant = True
   separate: ok rc=0 / registry: ok rc=0 / overlap: ok rc=1 ОТКАЗ: … merge main в ветку запрещён / registry_drop: ok rc=1 / partial: ok rc=1
   distinct input: honest rc=1 (ОТКАЗ: pre-push: merge main в ветку запрещён … ref=refs/heads/feature/other-branch) | mutant rc=0 ()
M8_stale_local_main: official battery green on mutant = True
   separate: ok rc=0 / registry: ok rc=0 / overlap,registry_drop,partial: ok rc=1 ОТКАЗ
   distinct input: honest rc=1 (ОТКАЗ: … merge main в ветку запрещён …) | mutant rc=0 ()
```

Оба harness исполняемы повторно из клона; имена мутаций соответствуют находкам выше (M1/M2/M3/M6 → блокирующий класс 1, M7 → блокирующий класс 2, M8 → совет).

## Итог

Красный контроль, контрольная модель, стабы, гейты 041/043 и все счётные утверждения зелёные/сходятся; сужение Н-191/Н-294-запрета до названного случая и защита счёта кругов в тексте выдержаны. Но два доказанных класса ложной достаточности критерия (удаление аутентичностных гейтов verdict_sessii; расширение merge-исключения на иные ветки) позволяют пройти W зелёным реализацией, нарушающей именованные обязательства предмета. Оба закрываются красными клетками в зоне architect (fixtures/workshop_project/obryv_167/). FAIL.

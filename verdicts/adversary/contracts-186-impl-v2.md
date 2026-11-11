accept
OBJECT=61b2b2bf8cdde8199cd2b7ea23650ea83beea20a
КЛАСС=рисковый
СУД: repo=a3ka/dev-harness; предмет=186; фаза=реализация; роль=adversary; вызов=2/2; модель-план=openai-codex/gpt-5.6-terra (advisor; fallback anthropic/claude-opus-5-5, autoFallback); сессия=Adv186v2b; модель-факт=openai-codex/gpt-5.6-terra; SHA=61b2b2bf8cdde8199cd2b7ea23650ea83beea20a; предыдущий=verdicts/adversary/contracts-186-impl-v1.md

Вердикт `accept`: достижимого контрпримера обязательствам `contracts/186-hranitel-arhitektury.md` §Предмет 1–4а и §Приёмка не найдено. Атаки выполнены production-дверью `bash scripts/merge_architecture_pr.sh <toy> 42` в независимых Git toy; fake `gh` воспроизводит документированные поля GitHub, а после каждого отказа проверялись rc и отсутствие merge.

## ДО / ПО: три блока вызова 1

| Блок вызова 1 | ДО (`ce0f706…`, из `contracts-186-impl-v1.md`) | ПО (`OBJECT`) |
|---|---|---|
| Два ID в title; автор и сливающий отличаются только регистром | `title_two_ids` и `author_casefold`: `rc=0`, PR слит | `rc=1`, соответственно `NO_COMPLIOR_ID` и `AUTHOR_IS_MERGER`; merge отсутствует |
| Второе ложное поле `модель-факт=`; `accept` не первой строкой | `model_second_field` и `accept_not_first`: `rc=0`, PR слит | оба `rc=1 NO_CRITIC_ACCEPT_ON_HEAD`; merge отсутствует |
| Чужой `architecture` и красный run на второй странице | `foreign_architecture_app` и `paginated_red_run`: `rc=0`, PR слит | оба `rc=1 CI_NOT_GREEN_ON_HEAD`; merge отсутствует |

Это шесть входов прежнего вызова, перепущенные батареей против OBJECT: каждый отказался без `gh pr merge`.

## Новые атаки на дверь L1

Отказались с `rc=1` и без merge: `COMPLIOR-186` рядом с `COMPLIOR-1860`; Unicode-hyphen и Unicode-цифры; ID на второй строке title; `Straße`/`STRASSE`; BOM и пустая ведущая строка перед `accept`; `> accept`; две строки `СУД:`; `SHA=` в середине строки; модель с пробелами либо иным регистром; review от автора PR; старый accept на чужом SHA вместе с новым `CHANGES_REQUESTED` на head; `DISMISSED` review; `app=null`; пустой массив check-runs. Именованные отказы — `NO_COMPLIOR_ID`, `AUTHOR_IS_MERGER`, `NO_CRITIC_ACCEPT_ON_HEAD` либо `CI_NOT_GREEN_ON_HEAD`.

Постраничный красный check-run проверен отдельно существующей клеткой `paginated_red_run`: `gh api --paginate` прочёл вторую страницу и отказался `CI_NOT_GREEN_ON_HEAD`. Отказы запускаемого инструмента не выданы за успех: подмена `gh` на `exit 127` и `npm` на `exit 1` дали по `rc=2 DOOR_INFRA_ERROR`, без merge.

Не удалось сломать контракт следующими входами. Корректный CRLF review прошёл и слил toy PR; это положительный контроль разбора строк. `İ`/`i`, zero-width-суффикс, пробел и `[bot]` у автора прошли как разные логины — по явно заданному правилу сравнения только `casefold`, без NFKC/trim/срезания суффикса. ID внутри backticks или URL и произвольная строка после валидно завершённой строки `СУД:` также проходят: контракт требует ровно один ID в title и окончание именно строки `СУД:`, но не запрещает Markdown-контекст ID и не требует, чтобы `СУД:` была последней строкой всего body. Наконец, `architecture` с `app.slug=github-actions` и посторонним полем `app.owner` проходит, потому что обязательство контракта ограничено `app.slug`; это не подмена PATH/`gh` и не расширяется в неуказанную проверку владельца приложения.

## Положительный контроль и регрессии

- `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo .` — rc 0, 61 клетка; в том числе production-дверь `l1_merge` действительно слила честный toy PR с точным `--match-head-commit`.
- `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --model` — rc 0; честные L1 и post-merge pin controls зелёные.
- `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --stabs` — rc 0, 69 `caught`, ни одного `ZHIV`: нейтрализация каждой отдельной ветви поймана своей клеткой.
- `npm run check:ceilings`, `npm run check:gen`, `bash fixtures/_krasnye_074.sh` — каждый rc 0.
- Предметные пути OBJECT и `origin/wip/186/orchestrator` идентичны: `git diff --exit-code OBJECT origin/wip/186/orchestrator -- scripts/merge_architecture_pr.sh scripts/check_architecture_pin.sh fixtures/workshop_project/architecture_steward_186/ roles/architecture-steward.md config/agent_models.json .omp/agents/architecture-steward.md .omp/config.yml scripts/findings_status.py scripts/architecture_review.py` — rc 0. На дереве PR `9209e817` команда `bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md` — rc 0.

Вне контракта и не использовались как доказательства: подложный PATH вне изолированной contract-toy, реальный GitHub ruleset/права станции и семантическая ошибка модели.

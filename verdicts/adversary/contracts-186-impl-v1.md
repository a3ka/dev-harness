FAIL
OBJECT=ce0f7068536bac1e66619d512289417e5ca88341
КЛАСС=рисковый
СУД: repo=a3ka/dev-harness; предмет=186; фаза=реализация; роль=adversary; вызов=1/2; модель-план=openai-codex/gpt-5.6-terra (advisor; fallback anthropic/claude-opus-5-5, autoFallback); сессия=Adv186v1; модель-факт=openai-codex/gpt-5.6-terra; SHA=ce0f7068536bac1e66619d512289417e5ca88341; предыдущий=нет

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:4,27,44,47 — дверь L1 принимает неконформный идентификатор работы и самослияние при отличающемся только регистре логине.
ОБЯЗАТЕЛЬСТВО: L1 принимает решение о праве слияния только для адресного PR `COMPLIOR-<NNN>` и при `автор ≠ сливающий`.
СОСТОЯНИЕ: GitHub возвращает title `COMPLIOR-186 and COMPLIOR-187 architectural correction` либо author.login `Station-Orchestrator` при operator.login `station-orchestrator`; прочие поля конформного PR #42 остаются теми же.
НАБЛЮДЕНИЕ: изолированный toy с публичным `bash scripts/merge_architecture_pr.sh <toy> 42` в обоих случаях слил PR: `title_two_ids: rc=0; merged=True` и `author_casefold: rc=0; merged=True`. Механизм — `scripts/merge_architecture_pr.sh:96` ищет один match вместо ровно одного, а :106 сравнивает логины побайтно. Встроенная батарея не имеет этих клеток: её `--repo .` зелёная, как и `--stabs`.

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:4,27,44,47 — проверка critic accept принимает текст, где фактическая модель не GLM.
ОБЯЗАТЕЛЬСТВО: accept критика на том же head содержит фактическую модель GLM, а не Sol хранителя.
СОСТОЯНИЕ: APPROVED review критика на текущем SHA имеет body `accept\nСУД: модель-факт=openai-codex/gpt-6-sol; модель-факт=zai/glm-5.3; SHA=<head>`; то есть единственное фактическое поле модели ложно, а GLM подставлен вторым полем.
НАБЛЮДЕНИЕ: публичная дверь слила такой PR: `model_second_field: rc=0; merged=True`. Она также слила body с посторонней первой строкой перед `accept`: `accept_not_first: rc=0; merged=True`. Причина — нерегламентированный поиск строк `scripts/merge_architecture_pr.sh:126-129` с `.*`, вместо разбора единственной структуры СУД. Это не подмена `gh`/PATH: toy подаёт документированные поля review, а собственно дверной процесс — production script.

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:4,27,44,47 — проверка CI проверяет имя, а не происхождение architecture check, и читает лишь первую страницу check-runs.
ОБЯЗАТЕЛЬСТВО: на head зелёный CI архитектурного репозитория; красный check-run не может быть скрыт выдачей GitHub.
СОСТОЯНИЕ: (1) единственный зелёный run называется `architecture`, но имеет `app.slug=evil-ci`, `app.owner.login=attacker`; (2) первая GitHub-страница несёт 100 зелёных runs включая architecture, `total_count=101` и `_links.next`, а в следующей странице есть `security` с `conclusion=failure`.
НАБЛЮДЕНИЕ: production door слила оба PR: `foreign_architecture_app: rc=0; merged=True` и `paginated_red_run: rc=0; merged=True`. `scripts/merge_architecture_pr.sh:136-143` вызывает `gh api` один раз, не проверяет `app` и не следует pagination. Это не ложный gh/PATH-обход: ответ моделирует документированные поля GitHub API, а достижимый механизм — отсутствие `--paginate`/постраничного обхода в production door.

Позитивный контроль: `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --model` завершился rc 0; `door l1_merge` и `pin pin_merged` зелёные, остальные именованные отрицательные клетки вернули ожидаемый rc 1.

Проверки кандидата: `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo .` rc 0 (37 клеток); `--stabs` rc 0 (45 caught). Новая изолированная атака выполнена через temporary Python harness и удалена до вердикта; сырой вывод шести входов приведён выше.

Регрессии: `npm run check:ceilings && npm run check:gen` rc 0. `bash fixtures/_krasnye_074.sh` rc 0. `bash fixtures/_krasnye_080.sh` rc 1 с `стаб-пак: 8/9 поймано`; тот же rc 1 и тот же вывод воспроизведены на `origin/main` cd991344e, поэтому это не регрессия OBJECT. `bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md` на origin/wip/186/orchestrator (372df6f) rc 0.

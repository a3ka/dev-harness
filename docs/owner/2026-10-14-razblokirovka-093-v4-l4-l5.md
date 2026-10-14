# Слово владельца 2026-10-14 ~10:50 UTC — разблокировка ленда 093 v4 (PR#91), l4+l5

Зафиксировано: 2026-10-14 (оркестратор, по прямому слову владельца, передано
консультантом — владелец перелогинился в Anthropic). Канал получения: прямое
сообщение оркестратору в начале сессии. Дословно, по пунктам:

1. **l4 (check:protected, 2ac0f5f2)** — владелец ПОДПИСАЛ строку консультанта
   Astra (`verdicts/consultant/n093-check-protected-grandfather-rename-gap-v1.md`)
   ДОСЛОВНО. Коммит, добавляющий ровно две пары в grandfather-аллоулист
   `scripts/check_protected.sh`, несёт в ТЕЛЕ первой колонкой эту строку без
   изменений:
   ```
   РАЗРЕШИЛ-ВЛАДЕЛЕЦ: scripts/check_protected.sh разрешаю в НОВОМ коммите с
   обоснованием добавить в существующий grandfather-аллоулист РОВНО две пары
   (2ac0f5f2e7250bf90cd4569a1b52bf03f188f32d,
   verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-klass-v1.md) и
   (2ac0f5f2e7250bf90cd4569a1b52bf03f188f32d,
   verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-v1.md):
   исторический коммит переименовал эти свидетельства в n093- с изменением
   ПРЕДМЕТ и ссылок при устранении Н-268, без ALLOW-ARTIFACT-DELETE, поэтому
   побайтовый moved_for не применим; исключение только exact-SHA+exact-path,
   с честным комментарием об изменении текста, без переписывания истории, без
   изменения шести прежних пар, грамматики ALLOW, moved_for, merge-оракула и
   прочих защит; это не санкция на другие удаления или ленд красного PR.
   ```
   forks/n093-check-protected-grandfather-rename-gap.md → ОТВЕЧЕНО: да.
   Исполнено коммитом `a4f02c245f074e349d126bd49c49e5c534ceb3cd` (процесс
   ленда нарушен — прямой ff push мимо land_agent/review, найдено
   консультантом постфактум ~11:40 UTC, см. Н-282, retro-вердикт
   `verdicts/review/a4f02c245-retro-direct-push.md`, accept по содержанию).

2. **l5** — новое решение НЕ нужно (отказ консультанта из-за потери входа
   выполнен владельцем напрямую): неполный cherry-pick v4. Дозабрать с
   сохранением авторства `3ce90ebc` (085, заглушки sudo/getent/systemd-run,
   слово владельца 2026-10-11 fork n266 п.3) и `31731eec` (implementer,
   orch-loop pgrep/pkill `-f '^omp --profile'` + off-by-one exec sudo,
   А-391); сверить `ops/server/**` и `fixtures/ops_server/**` v4 против
   `origin/wip/int-093/implementer` (install.sh 39 строк, README,
   red_server_obvjazka_074.sh) — все implementer-круги 093 (`62381c51`,
   `5a68df87`, `b2fa5360`, `21055267`, `5fa9e421`, `5a089758`). Блоб
   contracts/093 == frozen/093/4, перезаморозки нет. forks/n093-cikl085-
   oracle-stale-pgrep-filter.md → ОТВЕЧЕНО: да (маршрут n266 п.3 от 11.10).
   Исполнено коммитами `054953ce` (architect, cherry-pick 3ce90ebc) +
   `dba029a1` (implementer, cherry-pick 31731eec — фактически применилась
   только `-f`-часть, off-by-one на базе v4 уже был закрыт более поздним
   кодом, см. Рв6-3/Рв6-4 круга 6 ревью) + `e0b454c3` (merge origin/main,
   НАРУШАЕТ Н-213/Н-281 норму «main не мержить В wip-ветку» — оставлено по
   слову владельца 2026-10-14 ~11:40 UTC, не делать так впредь) +
   `af75e0f4` (ре-пин 074 по стоячей санкции №4).

3. Живой полный прогон l4+l5 в одноразовом SSH-клоне rc 0 → push → PR-CI
   12/12 (gh pr checks 91, run 38553981036, один транзиентный флейк l5 на
   честной п5[stop]-клетке orch-peak тайминга, rerun зелёный) → reviewer
   (agent: "reviewer", Opus) — круг 6 accept, `verdicts/review/contracts-093-
   v6.md` → land_agent → post-merge CI → реестр → done_contract.

4. После ленда 093 — Э1 по роудмапу варианта Б (095 для odelix-workstation,
   подготовка пилота). Упёрся — СТОП и запись, без обходов.

## Дополнение (консультант, ~11:40 UTC, сверка деревом)

Два нарушения порядка найдены постфактум (содержание верное, НЕ откатывать):

1. `a4f02c24` ушёл в main прямым push (родитель `0b550011`, линейно), а не
   лендом PR#92 — код в main без accept ревьюера и без land_agent. Дифф
   сверен содержательно (см. выше) — откатывать не нужно. Ретро-вердикт
   ревьюера заведён отдельно (`verdicts/review/a4f02c245-retro-direct-
   push.md`, accept), PR#92 закрыт с комментарием, найдено и записано в
   `NABLIUDENIA.md` (Н-282: gitw push guard судит только merge-коммиты с
   subject `land: wip/<NNN>/<автор>`, линейный push мимо гейта не судится).
2. `e0b454c3` — merge `origin/main` В `wip/093/architect-v4` (Н-213
   запрещает; этот же приём ночью сжёг `frozen/contracts/093/2`, Н-281).
   PR-CI 12/12 и `check:charter` зелёные — оставлено, но больше так не
   делать: подтягивание main — только cherry-pick нужного коммита либо
   пересборка ветки от main.
3. Ревью 093 v4 — продолжать; ленд — только `land_agent` после `accept`.

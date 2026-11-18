# СДАЧА 037 v+1 — расширение ceremony М3 на изолированные рабочие пачки

Кандидат: `contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` на ветке
`wip/037/architect`, один коммит поверх main `29c4a03779` (author=committer=
architect). Пачка = текст контракта v+1 + красная батарея + этот лист;
реализация НЕ входит (implementer-круг v+1). Красное-до снято на дереве
кандидата, где субъекты побайтно равны main (`git diff main -- roles/
scripts/ .omp/` пуст). Чистый ssh-клон дверями этой пачки не создан:
кандидат не пушится (Н-85), локальный file-clone стерегомого дерева —
смена маршрута без слова оркестратора (контракт 045); двери прогнаны в
своей копии на чистом porcelain, оркестратор повторит их на чистом клоне.

Предыдущий критический вердикт по предмету (`verdicts/critic/
contracts-037-v2.md`, accept) написан до машинной карты классов 192/193 —
грамматикой lib_karta_sdachi не разбирается («карта 0 строк»), блоков не
несёт; строка ПРЕДЫДУЩИЙ ВЕРДИКТ и секция «## Дельта» опущены по этой
причине (закрывать нечего), сужения обязательств нет.

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- precision-гейт · bash scripts/check_precision_gate.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- модель угроз · bash scripts/check_threat_model.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- проводка-грамматика · bash scripts/check_provodka.sh --grammar . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- батарея-красная · bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh . · 1 · 1
- батарея-модель · bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh --model · 0 · 0
- батарея-заглушки · bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh --stabs · 0 · 0
- регресс-М1 · bash fixtures/self_contained_cwd/red_self_contained_cwd.sh . · 0 · 0
- регресс-М2 · bash fixtures/accept_task_commit/red_accept_task_commit.sh . · 0 · 0
- регресс-порядок · bash fixtures/accept_task_commit/red_porjadok_diapazona_068.sh . · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- К-02 · чисто · вход: КОНТЕКСТ цитирует слово владельца 2026-11-18 ~14:05 UTC (§4 батча №2) и заявку 199:20 дословно · - · -
- К-03 · чисто · вход: §Существующее п.1–5 — сверка с деревом по живым замерам этой пачки (frozen 037/2 == main, модель и батарея 199, отсутствие privjazka_sdachi.sh) · - · -
- К-04 · чисто · вход: зоны v+1 — новые пути только в зонах architect/implementer; ПЕРЕСЕЧЕНИЕ по чужим живым заморозкам объявлены (гейт 043 зелёный) · - · -
- К-05 · чисто · bash scripts/check_spec_ready.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- К-06 · чисто · вход: батарея требует bash/git/jq — отсутствие даёт rc 2 NOT_IMPLEMENTED именованный до миров · - · -
- К-07 · чисто · вход: клетки судят живые файлы дерева (roles/orchestrator.md, scripts/accept_task_commit.sh) настоящим git станции; миры — mktemp /tmp/dev-harness-s037v1.*, двойников нет · - · -
- К-08 · чисто · bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh --stabs · 0 · 0
- К-09 · чисто · вход: ц0–ц5 покрывают пункты заявки по ветви — текст раздела, синхробаза, сверка до приёма, чистота носителя, фиксация tip, дозвон от принятого tip · - · -
- К-10 · чисто · вход: суд клетки сверяет rc, sha ветки/копии/принятого tip, porcelain-чистоту носителя и main, stdout root= — наблюдаемые эффекты · - · -
- К-11 · чисто · вход: ожидания (авторские tip, sha работы) снимаются в переменные клетки ДО вызова блоков и сверы; оракул — git-состояние мира · - · -
- К-12 · чисто · вход: байты блоков и сверы — модель 199 (единый источник), батарея v+1 собственной копии не несёт; церемония — своя модель · - · -
- К-13 · н/п · секреты не предмет · - · -
- К-14 · чисто · bash fixtures/accept_task_commit/red_priem_izolyacii_037.sh --model · 0 · 0
- К-15 · чисто · вход: числа клеток/заглушек берутся из строк ИТОГ/СТАБЫ вывода движка; census-замеры контракта пересчитывает гейт 036 · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры 188 в объекте отсутствуют · - · -

## Замечания формата

Строка `ПРОВОДКА-ЭНФОРСМЕНТ:` не пишется: v+1 несёт поведенческую норму
(role-канал, строка в §ПРОВОДКА контракта), чистого энфорсмента не вводит.
Привязка обманных заглушек к различающим прогонам — КОД раннера
(`stab_kletki`/`stub_sreda`), проза контракта пары не связывает (Н-39).

Живые прогоны этой пачкой (raw, дерево кандидата, субъекты == main).
Безфлаговый прогон: FAIL c0 … FAIL c5, затем «ИТОГ 037-М3 (субъекты дерева):
клеток 6, красных 6, зелёных 0» и «КРАСНОЕ 037-М3: красных 6 из 6», rc 1.
Режим --model: ok c0 … ok c5, «ИТОГ … клеток 6, красных 0, зелёных 6»,
«ЗЕЛЕНОЕ 037-М3-model», rc 0. Режим --stabs: s01…s07 «ПОЙМАН», «СТАБЫ
037-М3: всего 7, поймано 7, живых 0», «ЗЕЛЕНОЕ 037-М3-stabs», rc 0.
Регрессии: М1 «ветвей 11, красных 0» rc 0; М2 «ветвей объявлено 7, прогнано
7, красных 0» rc 0; 068a «красных 0, зелёных 6» rc 0.

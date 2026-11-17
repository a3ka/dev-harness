accept

OBJECT=09e5c11543423b7d25e053ac54f4db192908e79b
СУД: repo=dev-harness; предмет=187; фаза=контракт v+1 (до заморозки v2); роль=critic; вызов=1/1 (ОДИН узкий вызов по дельте, слово владельца 2026-11-16 ~09:39 UTC «187 v2 — да, но сначала убедись по правилам», через консультанта); модель-план=apex-sol (openai-codex/gpt-6.1-sol); модель-факт=zai/glm-5.3 (по окружению сессии судьи; расхождение с планом — вопрос маршрутинга харнесса, семейный запрет снят контрактом 166, на предмет суда не влияет); сессия=Crit187V2; SHA=09e5c11543 (tip origin/wip/187/architect-v2-1116); предыдущий=verdicts/critic/contracts-187-v1…v3 → frozen/contracts/187/1; исключение=слово владельца.

# Предмет

Дельта `git diff frozen/contracts/187/1^{commit} 09e5c11543 -- contracts/187-arhitektura-v-processe.md`: пять добавленных строк (четыре `ПОТРЕБИТЕЛЬ …` + census-замер) в конце раздела «Приёмочный критерий», перед «## Модель угроз». Инварианты, код, красные тесты, Модель угроз и Зоны 187 не тронуты. Ничего вне этих пяти строк не рассматривалось — неизменённые поверхности без нового риска по §Порог не исследуются (roles/critic.md §Контракт).

# Проверка пяти пунктов задания (всё живыми прогонами)

Клон ssh://git@github.com/a3ka/dev-harness.git → /tmp/dev-harness-verify/Crit187V2/repo, свой .git, detached HEAD = OBJECT, `git status --porcelain` пуст. Push не делался, в общий чекаут не писалось, коммитов не создавалось, identity owner не использовалась.

(1) Дельта ровно +5/−0, остальное байт-в-байт — ДА.
  $ git diff --stat frozen/contracts/187/1^{commit} 09e5c11543 -- contracts/187-arhitektura-v-processe.md
   contracts/187-arhitektura-v-processe.md | 5 +++++
   1 file changed, 5 insertions(+)
  Один hunk, удалений нет, других hunks нет (унифицированный diff показал бы любое иное расхождение байтов). Старый файл 140 строк, новый 145. Добавленные строки — 45–49, без хвостовых пробелов (cat -A).

(2) Четыре пробы живые и различающие — ДА.
- Механизм гейта: scripts/check_consumers.sh:395-417 — проба извлекается из рабочего файла контракта регексом ^ПОТРЕБИТЕЛЬ <consumer>:, исполняется ( cd "$ROOT" && sh -c "$probe_line" ), таймаут 60×1 с с kill -9, требуется rc 0; п1-b требует census-строку. Потребители берутся ровно из scripts/consumers.d/*.tsv.
- Census-маппинг на дереве: freeze_contract.sh → fixtures/check_check_contract_ready/, fixtures/drill_contract_change/, scripts/spawn_agent.sh; done_contract.sh → scripts/check_spec_ready.sh — ровно четыре пары, ровно четыре ПОТРЕБИТЕЛЬ-строки (45–48), пути побайтово совпадают с TSV. lib_registry.sh в окне не тронут (git log frozen/contracts/187/1..HEAD -- scripts/lib_registry.sh пуст) — его пары окном не судятся, проб на них не требуется.
- Живой прогон гейта: `bash scripts/check_consumers.sh . contracts/187-arhitektura-v-processe.md` → rc=0 за 24.31 с. Непустота доказана xtrace: touched_writers+= ×2 (scripts/freeze_contract.sh, scripts/done_contract.sh — оба покрыты своей ЗОНА-строкой frozen 187/1, ветка И-6 zone_covers → return 0), извлечены и исполнены все четыре probe_line=, итог rc=0 ×4. Гейт не vacuous. Xtrace сохранён: /tmp/dev-harness-verify/Crit187V2/xtrace.log.
- Индивидуальные пробы (последовательно, замок verify_antiplacebo):
  $ bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh
    ok (зоны) без зон → RC≠0, названо «зон»; ok (зонаформ); ok (проба); ok (пробаф); ok (счёт); ok (арбитраж); ok (готов) готовый контракт → RC=0 + «OK»
    check_check_contract_ready: ветви «all» зелены  [rc=0]
  $ bash scripts/verify_antiplacebo.sh --scope drill_contract_change
    ok drill_contract_change/case_procedura_ne_prinjata.sh: повторный прогон красный кодом 1
    барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1  [rc=0]
  $ bash scripts/verify_antiplacebo.sh --scope spawn_agent
    ok spawn_agent/case_bez_identichnosti.sh: красный кодом 1 — «HEAD не main»
    ok spawn_agent/case_octal_sdvig_znachenija.sh: красный кодом 1 — «уже существует»
    барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2  [rc=0]
  $ bash scripts/check_spec_ready.sh . contracts/187-arhitektura-v-processe.md → OK [rc=0]
- Различаемость (правило 3 AGENTS.md): пробы 1–3 предъявляют красное внутри себя. Проба 4 различает мутацией числа census в изолированном NNN-файле: bash scripts/check_spec_ready.sh <корень> contracts/999-mutacija-census.md (= 7 вместо 6) → «спек-гейт 036: замер расходится: заявлено 7, команда даёт 6» [rc=1]; файл без NNN-имени → rc 2. После проб мутант удалён, git status чист.

(3) Census-строка по форме прецедента и значением 6 — ДА. Строка 49 побайтово той же формы, что frozen/122/4:63: замер: `cat scripts/consumers.d/*.tsv | wc -l` = 6 census scripts/consumers.d/*.tsv; размещение — в конце раздела критерия, как в 122/4. Живой пересчёт на дереве: 6. Сам check_consumers проверяет наличие строки (любое N); число живо перепроверяется веткой В2 пробы 4 и freeze-шагом §6а (036, две меры) — композиция замкнута.

(4) РАЗРЕШИЛ-ВЛАДЕЛЕЦ — ДА. В теле 09e5c115 (автор и коммиттер architect <architect@dev-harness.local>, не owner), первая колонка:
  РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/187-arhitektura-v-processe.md 187 v2: четыре пробы потребителей писателей freeze_contract.sh и done_contract.sh и census; остальной текст сохранён (слово владельца 2026-11-16 ~09:39 UTC «187 v2 — да, но сначала убедись по правилам», через консультанта)
Путь дословен, причина непуста, цитата дословно совпадает со словом владельца в задании; дата и «через консультанта» — фактические уточнения маршрута. Механически: CHARTER_LIB=1 source scripts/check_charter.sh; razreshil 09e5c115… contracts/187-arhitektura-v-processe.md → rc=0. Тексто-меняющих коммитов после frozen/187/1 ровно один (09e5c115) — требование (б) check_contract_frozen закрыто целиком.

(5) Законность заморозки v2 и отсутствие «тихо зелёного done» — ДА.
- scripts/freeze_contract.sh:347-355: check_consumers исполняется ДО создания тега (g tag -a — строка 562), окно = последний frozen-тег..HEAD на момент вызова = frozen/contracts/187/1..HEAD — непустое (380 не-merge коммитов; оба писателя тронуты судимыми коммитами 3a75e2d4, 56a4747b, de86f2d8, f387542d, автор implementer, своя ЗОНА 187). Заморозка v2 РЕАЛЬНО исполняет все четыре пробы по старому окну — доказано живым прогоном на точном SHA кандидата.
- check_contract_frozen.sh:151-193: путь к v2 — (а) accept-вердикт критика v+1 на HEAD (этот вердикт) ∧ (б) razreshil в каждом текстовом коммите (rc=0). Ручной тег не нужен и запрещён.
- После freeze окно done = frozen/187/2..HEAD пустое → check_consumers на done даёт vacuous rc 0 — штатная ветка контракта 038 (п2), не обход: пустое окно означает отсутствие непроверенных правок писателей ПОСЛЕ верифицированной заморозки; любая новая правка писателя вновь раскрыла бы окно и потребовала пробы. Доказательство старого окна живёт в зелёном прогоне check_consumers до тега (воспроизведён на SHA кандидата); выдавать будущий зелёный done за повторное исполнение проб не следует, но обязательств сверх этого не нарушено.

# Находки

БЛОКИРУЮЩИХ нет.

СОВЕТ contracts/187-arhitektura-v-processe.md:48 — различаемость пробы потребителя scripts/check_spec_ready.sh опирается на то, что 187 несёт census-строку 49 (ветка В2 срабатывает на ней): на NNN-файле без замер-строк гейт даёт vacuous OK (измерено на изолированном файле). Текст v2 строку несёт и она замораживается вместе с контрактом — свойство держится; замечание защищает строку 49 от «чистки» в будущих версиях без понимания этой связки.

СОВЕТ contracts/187-arhitektura-v-processe.md:45 — пять строк вставлены без пустой строки-разделителя после последнего «Дано:»-буллета (строка 44); размещение в конце раздела критерия совпадает с прецедентом 122/4, парсинг гейта по ^ПОТРЕБИТЕЛЬ/^замер: не зависит от разделителя — чистая косметика.

# Остаток

Миграция клетки k187 в fixtures/workshop_project/potrebiteli_116_195/ — зона architect 195, вне объекта этого суда (контракт 195 §Следствия :423-439 её предусматривает; bare/--model проверка клетки — на рефриз-пути 195). Прогоны сделаны в одноразовом SSH-клоне /tmp/dev-harness-verify/Crit187V2/repo (клон и xtrace-лог сохранены до лендинга вердикта); коммитов и push не было; identity owner не использовалась.

# Маршрут после accept (для оркестратора, не предмет суда)

Текст вердикта кладётся файлом verdicts/critic/contracts-187-v2.md (первая строка accept) коммитом в зоне critic, затем до нового тега: bash scripts/check_consumers.sh . contracts/187-arhitektura-v-processe.md и bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md (зафиксировать rc=0 при старом непустом окне, вывод четырёх проб сохранить), затем штатно bash scripts/freeze_contract.sh contracts/187-arhitektura-v-processe.md с причиной, несущей РАЗРЕШИЛ-ВЛАДЕЛЕЦ по грамматике. Ручной git tag недопустим.

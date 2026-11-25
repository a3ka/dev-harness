accept
OBJECT=c8be57f10578ff2ad2d0216ab1537f4b5a5862f4
СУД: репо=dev-harness; предмет=203; фаза=v1; роль=critic; вызов=1 (полный; контракт переписан v2); модель-план=GLM (по роли); модель-факт=zai/glm-5.3; предыдущий=нет (черновик 8190ca542 судей не проходил); класс риска=обычный (заявленный архитектором — подтверждаю)

# Вердикт критика 203 v1 — дверь закреплённого брифа архитектуры (R-0071, четыре пункта)

Судится `contracts/203-dver-brifa-arhitektury.md` и красная батарея
`fixtures/workshop_project/dver_brifa_203/` на OBJECT `c8be57f10578ff2ad2d0216ab1537f4b5a5862f4`
(main `e767f5132` + перенос черновика `3c55aedbc` + переписывание v2 `c8be57f10`).
Набор артефактов полон: предмет (четыре инварианта), критерий готовности (rc-команды),
исполнители (ЗОНА-строки шести ролей + ПЕРЕСЕЧЕНИЕ 74 строки), СДАЧА, модель угроз
(ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ по свойству), КЛАСС РИСКА назван и обоснован.

## Решение

`accept`. Порог (§Быстрый-процесс §Порог) не сработал ни на одном классе: воспроизводимого
нарушения названного обязательства на достижимом состоянии не найдено. Все заявленные
architect числа воспроизведены живыми прогонами дословно (см. «Сырые прогоны»), мои семь
мутаций вне `stabs.py` пойманы батареей (ZHIVYH=0), замороженные соседи 170/187 зелёные
на актуальном дереве. Ниже — карта классов, остатки и советы.

## Карта классов

К-01: чисто — вход: check_sdacha --run под наблюдением rc 0 (11 дверей листа, ~9 мин), pre_critic --repo . rc 0 «КРИТИК: дверь зелёная», precision/provodka rc 0, расхождений с листом нет
К-02: чисто — вход: Н-454 (NABLIUDENIA.md:8503 «выгрузка без зависимостей и бриф вне капа») и R-0071 п.3 ровно четыре пункта = четыре инварианта предмета, упаковка крупного брифа явно вынесена в v+1 170, Л10 явно вне
К-03: чисто — вход: frozen-блобы живьём git show frozen/contracts/{170/1,187/3,095/1,002/1,083/1,114/1,998/1}^{commit} — зоны совпадают с выборкой ПЕРЕСЕЧЕНИЕ-строк, регресс 187-семьи CELLS=111 FAILURES=0 rc 0 и 170-семьи rc 0 на OBJECT
К-04: чисто — вход: у каждого затрагиваемого файла назван исполнитель (ЗОНА architect/implementer/critic/adversary/reviewer/orchestrator), overlaps.py rc 0 MISSING=0, производные (ci-steps/ci-zamery/ci.yml) в зоне orchestrator
К-05: чисто — вход: каждый пункт «Приёмочного критерия» несёт команду с кодом возврата (make_task/freeze/дверь/батарея/регресс/gen_ci_steps --check), CI-шаг check:dver-brifa-203-family-selftest назван
К-06: чисто — вход: probe.py check_tools rc 2 NOT_IMPLEMENTED по отсутствующему инструменту, rc 1 в клетках только как наблюдаемое расхождение, кап/dep-free клетки — зелёный контроль
К-07: чисто — вход: --model 21/21 зелёных на эталоне-оверлее реальных дверей из точной БАЗЫ e767f5132 (materialize), честный мир после реализации позеленит --repo . той же командой без ослабления 187/188 (дельта make_task по капу пуста)
К-08: чисто — вход: --stabs rc 0 (16 стабов, все caught, ZHIVYH=0) и 7 собственных мутаций критика M1–M6+M3f все CAUGHT (см. «Атаки»), игнор отказа brief ловится клетками reason-json/reason-empty по побайтовой форме ОТКАЗ: ARCH_BRIEF_OTKAZ
К-09: чисто — вход: 21 клетка покрывает ветви каждого из четырёх предметов — зависимости 7 (совпал/иной/равный-размер/нет донорского lock/нет модулей/нет lock пина/free), причина 4 (JSON rc17/не-JSON/пустой/второй компонент), элементы 7 (строка/флаг/пин-не-HEAD/заморозка/дверь + 2 known), кап 3 (внутри/сверх/умолчание)
К-10: чисто — вход: предикаты построчные (префикс/равенство), полный состав пака с маркерами и суффиксом BUDGET, тег заморозки, сохранность донора — не один токен
К-11: чисто — вход: Expected(frozen dataclass) строится в памяти из CASES до вызова субъекта, диск субъекта после вызова не читается
К-12: чисто — вход: lock сравнивается cmp -s побайтово до первого вызова CLI, членство отвечает настоящий CLI пина (brief --compact --component), JSON разбирается jq, второго парсера модели нет
К-13: н/п — предмет секретных входов и публикаций не добавляет (совпадает с SDACHA)
К-14: чисто — вход: deps-free/element-line-known/element-freeze-known/cap-within зелёные на эталоне, честные эквивалентные записи (не-JSON stderr, пустой stderr, валидная строка, профиль 260000) красными не становятся
К-15: чисто — вход: из прогонов CELLS=21 STABS=16 FAILURES=13 ZHIVYH=0 (--repo) и 21/16/0/0 (--stabs), overlaps.py FROZEN=193 BLOBS=193 OVERLAPS=74 MISSING=0 rc 0 (193 против 192 в SDACHA — локальный fetch принёс тег frozen/contracts/219/1, в дереве OBJECT его нет, состав 74 совпал)
К-16: чисто — вход: КЛАСС РИСКА строка есть, «обычный» подтверждаю — гейт freeze получает только отказную ветку, ложный PASS равен статус-кво до 203, ложный REFUSE ловят клетки element-line-known/element-freeze-known и регресс 187-семьи до первой заморозки, доменов списка риска предмет не задевает
К-17: н/п — станция проектной модели не несёт (АРХИТЕКТУРА: н/п в самом контракте), writers/isolationKeys и полнота брифа остаются за 188 и ревьюером

## Блоки

Блокирующих находок нет.

## Ключевые проверки гейта freeze (задание п.3а)

- валидный id проходит: element-line-known rc 0 (пак собран), element-freeze-known rc 0
  и тег `frozen/contracts/777/*` поставлен — ложный REFUSE различается батареей;
- неизвестный id: make_task rc 1 `ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity`,
  freeze rc 1 + тег не ставится (element-freeze-unknown), публичная дверь rc 1 с именем id;
- модель недоступна: именованные fail-closed ARCH_PIN (клетки pin-* 187-семьи, rc 1) и
  ARCH_BRIEF_DEPS (клетки deps-*, rc 1) — молчаливого пропуска нет (правило 7 AGENTS);
- «АРХИТЕКТУРА: н/п» и контракты без строки: гейт членства стоит ПОСЛЕ грамматики
  arch187_line (contracts/203-…:инвариант 3 «после грамматики строки»), ARCH187_COMPONENTS
  пуст → arch187_element_ids return 0, прежнее поведение держат зелёные клетки 187-семьи
  task-line-missing/freeze-no-line (rc 1 ARCH_LINE_MISSING, как до 203); станционный
  профиль вне режима 187а — ARCH_187A_SKIP (pre_critic, живой прогон).
- причины целиком: jq-разбор всего stderr, нормализация CR/LF/TAB без обрезки —
  «{» невозможна на JSON-ответе (клетки reason-json/reason-second; стаб reason-json-ignored
  ловит возврат к первой строке).
- кап: 91445-байтный бриф при 260000 собирается (cap-within, END_OF_COMPLETE_BRIEF),
  60000 → `режь задачу: 93054 > 60000`, без ключа → `> 40000` (frozen 170/1:29, клетка
  cap-default и регресс 170 brief_over_budget `42797 > 40000` зелёный).

## Как implementer позеленит --repo без расширения объёма

Эталон model.py — работающий оверлей реальных дверей БАЗЫ: перенос трёх блоков
(DEPENDENCIES в arch187_model_prepare, REASON_NEW в arch187_brief, ELEMENT_IDS+вызов
в arch187_check_text) в production-скрипты делает все 13 красных зелёными той же командой
`--repo .`. Дельта make_task по капу пуста (Б-4 уже в main), дельта freeze_contract не
нужна (гейт членства живёт в общем шве arch187_check_text — один якорь MEMBER_OLD,
встречается ровно один раз, что доказывает прогон --model). Судятся клетки, не совпадение
текста (Зоны и исполнители: «судят клетки, не совпадение текста»). Ослабления 187/188
нет: 111 клеток 187-семьи и 170-семья зелёные на текущем дереве, побайтовые формы
ARCH_BRIEF_STDERR/ARCH_BRIEF_OTKAZ держат клетки reason-nonjson/reason-empty и
замороженная brief_stderr.py (в составе 187-регресса).

## Атаки мутациями (одноразовые эталоны, НЕ из stabs.py)

Команда: `python3 /tmp/dev-harness-verify/scratch-crit203/mut203.py "$PWD"` →
`MUTACII=6 ZHIVYH=0 []`, rc 0. Сырые исходы:

- M1-grammar-only @ element-line-unknown: CAUGHT — rc=0 expected=1, нет строки «ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity» (модель не спрашивается)
- M2-substring @ element-line-unknown: CAUGHT — членство по подстроке brief-data.json пропускает неизвестный id, клетка красна
- M3-flag-skipped @ element-flag-unknown: CAUGHT (синтаксический вариант) — семантический вариант M3f `|| _arch_rc=0`: на клетке флага ZHIV (rc 1 + код + id приходят другим швом — ровно критерий владельца), но та же мутация красит reason-json и reason-empty (потеря строки «ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity») — обязательство имеет различающие клетки, живого мутанта нет
- M4-no-lockcmp @ deps-lock-differs: CAUGHT — донор сравнивается с собой, симлинк без сравнения lock пропускает расхождение, клетка красна
- M5-first-line @ reason-json: CAUGHT — причина «{» вместо код+сообщение
- M6-cap-40000 @ cap-within: CAUGHT — жёсткая граница 40000 режет честный пак 93019 при 260000

## НЕ ЗАЩИЩАЕТ (остатки с ловцами — принимаю)

- повреждённый/злонамеренный node_modules клона при совпавшем lock — равенство файла
  не доказывает npm ci, клон доверенная предпосылка, ловец verify-pin/CI проекта/reviewer;
- молчание модели без кода членства (иной код, пустой ответ) — ловец реальный CLI
  всегда отвечает кодом, ревьюер реализации;
- семантическая неполнота брифа — 188 и reviewer по пину;
- слишком малый pack.maxBytes профиля — owner-слой профиля.

## Советы (не блокируют)

- С-1 (оркестратору/владельцу, до freeze): строки 203 в registry/plan.tsv нет ни в OBJECT,
  ни в текущем origin/main (проверено `git show origin/main:registry/plan.tsv`); #1367
  (dbcce81b7) снял паузу (registry/pauzy.tsv) и добавил строки 218/223, но не 203. Гейт
  084 (freeze_contract.sh:281) откажет заморозке «контракт вне плана: 203 — не в
  текущей/следующей паре», пока owner не добавит строку 203 в пару P0/P1.
- С-2: клетке element-flag-unknown стоит добавить any_contains('ОТКАЗ: ARCH_BRIEF_OTKAZ:
  resource.identity') — потеря побайтовой формы только на пути флага сейчас держится
  клетками reason-* на том же шве (M3f).
- С-3: probe.py не обрабатывает subprocess.TimeoutExpired — зависший субъект даст
  traceback и rc 1 вместо rc 2 среды (край К-06, на этой станции не наблюдался).
- С-4: записи «СУД (ДО ВЫЗОВА)» для этого вызова (OBJECT c8be57f10) в HANDOFF.md нет —
  процессный зазор оркестратора, заданием не остановлен; строка СУД восстановлена в этом
  вердикте по фактической модели.

## Сырые прогоны (команда → rc / сводка)

- `bash scripts/check_sdacha.sh "$PWD" contracts/203-dver-brifa-arhitektury.md --run` → rc 0 (все 11 дверей листа, под наблюдением, ~9 мин)
- `bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --repo .` → rc 1, `CELLS=21 STABS=0 FAILURES=13 ZHIVYH=0`; красные: deps-linked, deps-lock-differs, deps-lock-same-size, deps-donor-lock-missing, deps-donor-modules-missing, deps-pin-lock-missing, reason-json, reason-second, element-line-unknown, element-flag-unknown, element-pin-not-head, element-freeze-unknown, element-door-unknown; зелёные контроли 8 (deps-free, reason-nonjson, reason-empty, element-line-known, element-freeze-known, cap-within, cap-over-profile, cap-default) — «красное ДО» до реализации честно
- `…red_dver_brifa_203.sh --stabs` → rc 0, `CELLS=21 STABS=16 FAILURES=0 ZHIVYH=0` (все 16 caught, 21 клетка эталона зелёная = заявленное --model 21/0)
- `…red_dver_brifa_203.sh --sintaksis` → rc 0, `SINTAKSIS OK`
- `bash scripts/pre_critic.sh --repo . contracts/203-dver-brifa-arhitektury.md` → rc 0, «КРИТИК: дверь зелёная» (пределки/модель угроз/потолки/провока/сдаточный лист красны, 187а SKIP)
- `bash scripts/check_precision_gate.sh . contracts/203-dver-brifa-arhitektury.md` → rc 0 OK
- `bash scripts/check_provodka.sh . contracts/203-dver-brifa-arhitektury.md` → rc 0
- `python3 fixtures/workshop_project/dver_brifa_203/overlaps.py` → rc 0, `FROZEN=193 BLOBS=193 OVERLAPS=74 MISSING=0`
- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` → rc 0, `CELLS=111 STABS=0 FAILURES=0` (включая brief-stderr-* побайтовые, pin-* ARCH_PIN, task-line-missing/freeze-no-line)
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo .` → rc 0 (26 ok, включая brief_over_budget `режь задачу: 42797 > 40000`)
- атаки критика: `python3 /tmp/dev-harness-verify/scratch-crit203/mut203.py "$PWD"` → rc 0 `MUTACII=6 ZHIVYH=0`; M3f-повтор на трёх клетках — reason-json/reason-empty CAUGHT, element-flag-unknown ZHIV (пояснено выше)

Живые якоря «Существующего» сверены: check_architecture_contract.sh:173–232/214–218
(git archive), :509–542/:536–537 (первая непустая строка), :626–678 (грамматика без
членства), :864–869, :947; make_task.sh:576–589 (один вызов profile_resolver),
:1039, :1170–1171; freeze_contract.sh:315; profile_resolver.sh:901–930 (диапазон
40000..1000000). ARCH_BRIEF_DEPS/ARCH_BRIEF_BUDGET в production-скриптах отсутствуют
(grep по scripts/ .githooks/ — только батарея).

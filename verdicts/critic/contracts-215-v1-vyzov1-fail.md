FAIL
OBJECT=ec34eaf53944f11efa6c986f81e555f15d50db37
СУД: репо=dev-harness; предмет=215; роль=critic; вызов=1 (полный); фаза=v1; модель-план=zai/glm-5.3 (по роли, слово владельца «критики на GLM»); модель-факт=zai/glm-5.3; предыдущий=нет; класс риска=рисковый (заявлен architect: безопасность — автоматическая смена модели исполнителя/судьи и свидетельство этой смены в доверенном потоке; основание совпадает с предметом, подтверждаю)

# Контракт 215 (отказ по содержанию → запасная модель тира), вызов 1, полный проход

Набор артефактов полон: контракт и батарея закоммичены на OBJECT (10 файлов, +900/−16,
все внутри ЗОНА-строк), предмет/критерий готовности/исполнители названы, ЗОНА-строки
и РАБОТА РАЗДАЁТСЯ есть, КЛАСС РИСКА объявлен, модель угроз по форме 041, ПРЕДПОСЫЛКИ
и «Незаполненные требования: нет» на месте. Н-39 соблюдена: контракт пары «стаб ↔ ветвь»
не утверждает, census — код probe215.py и source.json.

## Карта классов

К-01: чисто — вход: precision-gate `bash scripts/check_precision_gate.sh <клон> contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md` → rc 0 «OK», pre_critic 5 гейтов ok, `bash scripts/check_sdacha.sh "$PWD" contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md --run` → rc 0 «СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=0)» — первый прогон листа упёрся в бюджет 900 с на первой двери при конкурентной нагрузке (именованный отказ шва 193, повтор отдельными строками и с SDACHA_BUDZHET_SEK=1800 расхождений не дал)
К-02: чисто — вход: слово владельца 23.11 «переключать модели агентам на лету… автоматом… резервные» и поручение «отказ провайдера по содержанию… переводит на запасную модель тира, батарея 129 расширяется» названы в КОНТЕКСТ, замер Critic190K08 (omp 18.18.8, три cyber-отказа, errorId 53248, chain в session_init) принят как факт, registry/plan.tsv:134 «215 4 … autonomy»
К-03: чисто — вход: git show frozen/contracts/{129/2,104/2,166/2,186/2,198/1} сверены — квотная ветвь 129 (инвариант 4 «прочие ошибки подмены не вызывают») не отменена, содержимый отказ объявлен новой ветвью, TSV-грамматика 3/5 полей и native true→denied не сужены, реестр/роли/конфиг пачкой не тронуты (дифф = 10 файлов зон)
К-04: чисто — вход: `python3 fixtures/workshop_project/otkaz_po_soderzhaniyu_215/catalog.py --zones` → 46 строк ПЕРЕСЕЧЕНИЕ, diff с текстом контракта пуст (живой zones_load, А-962), производные (source.json, sha256 model-файлов) в architect-зоне
К-05: чисто — вход: все 7 пунктов приёмки несут исполнимые команды и ожидаемые rc (red --repo/--model/--stabs/--sosed/--sintaksis/--catalog, catalog.py+pre_critic+check_sdacha, gen:harness+check_provodka)
К-06: чисто — `bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --repo .` → rc 1, KLETKI=14 KRASNYH=5 (живой прогон на OBJECT)
К-07: чисто — `bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --model` → rc 0 KLETKI=14 KRASNYH=0, шов живой: omp 18.18.8, sha256 bfb7a85cceade6e5580fad59ff87570b4de50039b0428ed30339cf4286bd052f, `python3 …/runtime_evidence.py` → rc 0 sources=7, все байтовые окна и FILE/строки совпали с §«Измеренный шов»
К-08: блок — квиток расширения не привязан к настоящему model_change (Б-1)
К-09: чисто — вход: 14 клеток различают входы — flagged/cyber/filter переходят на glm с completed, other/error500/short429/near-token/healthy/no-chain/auto-off/same-provider/foreign-sibling не переключают, счёт агентских ходов ловит цикл (мутант M3 красен, 12+ ходов)
К-10: блок — Б-1: оракул trace судит привязку квитка по полям самого квитка, а не по наблюдаемому факту сессии
К-11: чисто — вход: ожидания исхода/selector/TSV собраны в памяти probe215.py до запуска субъекта, source.json sha256 сверяется до прогона (порча → ORACLE_TAMPERED rc 2), журнал провайдера и маркер задания независимы от subject-файлов
К-12: чисто — вход: настоящий omp против loopback HTTP-провайдера без credentials, адаптер 129 для task-result, источник сигнала — встроенный исходник бинаря по байтовым адресам (совпал живьём), стаб-провайдер расширяет HTTP-handler 129, а не мок-эхо
К-13: н/п — loopback 127.0.0.1 auth none, платных вызовов нет, pre_critic PREDPOSYLKI_OK secrets=0 variables=0 environments=0
К-14: блок — Б-1: нечестная запись квитка (поддельный modelChangeId, чужой target) остаётся зелёной — мутанты M1/M5 живы
К-15: чисто — вход: числа сверены живьём — RED 14/5, MODEL 14/0, STABY=15 SVJAZI=19 ZHIVYH=0, SOSED 6/0, SINTAKSIS=0, sha бинаря и 7 байтовых окон шва, зоны 46=46, models order (opus первая) делает wrong-target стаб неэквивалентным
К-16: чисто — вход: класс рисковый-безопасность обоснован доверенным потоком, суд реализации adversary → reviewer на одном OBJECT (критерий 7), НЕ ЗАЩИЩАЕТ с ловцами, порядок 222→215 и РАЗРЕШИЛ-ВЛАДЕЛЕЦ объявлены prerequisite, а не молчаливой правкой
К-17: н/п — станционный предмет без новых CI-шагов и схем 188 (АРХИТЕКТУРА: не применимо, продуковая модель не меняется)

## Блоки

БЛОКИРУЕТ contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md:62 (И5, «data.modelChangeId (id
настоящего model_change этой сессии)») и :159 (ЗАЩИЩАЕТ, «буквальная привязка квитанции
к настоящему model_change») — обязательство писателя квитка не имеет различающей клетки:
оракул выводит ожидание paired-варианта из полей самого квитка
(fixtures/workshop_project/otkaz_po_soderzhaniyu_215/probe215.py:77
`change_id = receipt['data']['modelChangeId']`), а клетка trace в --repo-режиме всегда
прогоняет честную модель, не субъект-расширение (probe215.py:275
`extension = HERE / 'model/fallback-route.ts' if args.model or name == 'trace' else
subject / old.EXT_REL`); квиток SWITCH субъект-расширения не читает ни одна клетка
(клетка exhausted читает только запись CONTENT_FALLBACK_EXHAUSTED).
ПРОИСХОЖДЕНИЕ: вызов 1 (полный), мутация критика — класс пропущен батареей.
КЛАСС: К-08 (вторичные проявления К-10, К-14).
ОБЯЗАТЕЛЬСТВО: И5/И6 и ЗАЩИЩАЕТ «От потери автофолбэка в трассе…» — квиток
fallback-route-215 обязан нести id настоящего model_change и полный target, расширение —
писатель квитка, реализацию которого implementer пишет заново (контракт: модель «НЕ
эталон побайтного переноса в production»).
СОСТОЯНИЕ: реализованное дерево, расширение честно переключает сессию на запасную и
продолжает задание, но пишет квиток с modelChangeId вне множества id model_change этой
сессии (или с чужим target) — все двери батареи 215 зелёные.
НАБЛЮДЕНИЕ (живые прогоны в одноразовом клоне ec34eaf53944f11efa6c986f81e555f15d50db37,
мутанты применялись по одному и удалены):
- M1 «поддельный id»: в model/fallback-route.ts правдивый захват
  `const modelChangeId = [...ctx.sessionManager.getEntries()].reverse().find((entry) => entry.type === 'model_change')?.id;`
  заменён на `const modelChangeId = 'forged-215-id';`; команда
  `python3 fixtures/workshop_project/otkaz_po_soderzhaniyu_215/probe215.py --model --case trace`
  → вывод `ok trace`, `KLETKI=1 KRASNYH=0`, rc 0 — мутант ЖИВ.
- M5 «чужой target»: в appendEntry CONTENT_FALLBACK_SWITCH поле `target` заменено на
  `'forged/fallback-x'` при реальном завершении ребёнка на stub-zai/glm (OBS: gpt-sol
  flagged → glm ok) — та же команда → `ok trace`, rc 0 — мутант ЖИВ.
Источник входа: штатный поддерживаемый путь предмета — квиток пишет само расширение в
доверенной JSONL-зоне 028/104, сценарий судьи/критика на запасной явно утверждён
(КОНТЕКСТ, Н-270/166), т.е. достижимость не «допустимость по грамматике», а объявленный
рабочий случай.
Источник ошибочного механизма: замена уже имеющейся предметной операции честной модели
(правдивый захват id/target) — живые M1/M5; зеркальные потребительские стабы
no-receipt/receipt-any-id/receipt-any-model пойманы (--stabs ZHIVYH=0), т.е. буквальность
ПОТРЕБИТЕЛЯ проверена, правдивость ПИСАТЕЛЯ — нет.
Последствие на достижимом состоянии: models_actual.sh не спарит квиток → model_change
перехода остаётся allowed → scripts/check_sud_model.sh:322 «ОТКАЗ: вердикт не
материализуется: судья … на модели … (Н-270)» на каждом автопереключённом судье/критике
при полностью зелёной батарее 215 — обещание «от потери автофолбэка в трассе» молча не
выполняется, станция теряет материализацию вердиктов ровно в сценарии слова владельца.
ОБХОД (ложная достаточность критерия): ожидание paired-варианта вычислено из полей
квитка и никогда не сверяется с id настоящих model_change сессии, а клетка trace в
--repo субъект-расширение не прогоняет — батарея зелёна и при декларированном
инварианте, и при его нарушении.
Закрывающее свойство (не предписывает единственную реализацию): любая подмена правдивого
захвата modelChangeId/target в квитке расширения обязана краснить клетку — например,
paired-ожидание требует denied на настоящем model_change перехода (id из native-событий
сессии, модель — фактический selector завершения) и/или отдельная клетка прогоняет
субъект-расширение и сверяет его квиток с настоящим model_change этой сессии.

## НЕ ЗАЩИЩАЕТ

- До закрытия Б-1: подделка/расхождение квитка расширения (modelChangeId или target вне
  настоящего model_change) батареей не ловится — ловец: закрывающая красная клетка после
  правки архитектора плюс adversary/reviewer суда реализации по командам критерия 7.
- Неизвестная форма upstream-отказа вне закрытого списка или ошибка, не доставленная в
  message_end — ловцы по контракту: логи omp и станционная проба при смене версии.
- Фактический отказ всех объявленных моделей, отсутствие цепочки/autoFallback, недоступная
  цель — ловец: исходная ошибка и CONTENT_FALLBACK_EXHAUSTED (отказ, не спасение).
- Компрометация установки/JSONL-зоны доверенным писателем, платный провайдер, субъект,
  распознающий стенд — ловец: независимый adversary/reviewer и фактическая трасса
  станции (граница 028/104 сохраняется).
- Независимость/качество суждения переключённой модели и политика назначений — отдельные
  обязательства 166/186/198/222, провайдерский отказ не меняет инструкцию задания.

## Советы

1. СОВЕТ contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md:62 — прямой мутант «native
   true → allowed» внутри этой батареи неразличим (клетки не порождают native-true
   событий), покрытие держится на объявленных в И6 дверях 104/173: в суде реализации
   прогнать `bash fixtures/_krasnye_104.sh` и
   `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh` обязательно.
2. СОВЕТ scripts/check_sdacha.sh — полный лист при конкурентной нагрузке падает по бюджету
   900 с на первой двери (именованный отказ, шов 193): SDACHA.md это предсказывает, но
   двери стоило бы сортировать по стоимости или поднимать бюджет для behavioural-дверей.
3. СОВЕТ contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md (Приёмочный критерий 7) — rc
   дверей 104/173 названы прозой в И6, а в задание судьи реализации попадают только
   «обе станционные батареи»: стоит назвать их явно командами.

## Красное ДО и обязательный путь к зелёному (без расширения списка маркеров и без ослабления независимости судьи)

Красное ДО подтверждено живьём: `--repo .` → rc 1, 5 красных — flagged/cyber/filter
(«ребёнок failed (exit 1), ожидался completed»: субъект-расширение 129 содержимый отказ не
переводит), exhausted («CONTENT_FALLBACK_EXHAUSTED absent»), trace (потребитель
scripts/models_actual.sh не помечает парный model_change denied: got allowed, expected
denied у stub-zai/glm). Реализация обязана позеленеть так: (1) implementer добавляет в
.omp/extensions/fallback-route.ts обработчик message_end с ЗАКРЫТЫМ списком И1
(предложение + самостоятельные токены cyber_policy/content_filter с границей; errorId и
HTTP-статус сигналом не являются — клетки other/error500/short429 остаются зелёными
контролями, расширение списка не нужно и запрещено), с проверками И2 (modelRole,
autoFallback===true установленного реестра, цель в session_init.retryFallback.chain,
провайдер цели отличен) и терминальным на сессию переходом И3 (setModel + followUp,
повторный содержимый отказ запасной = исходная ошибка + CONTENT_FALLBACK_EXHAUSTED, ≤2
агентских ходов); (2) узкая дельта scripts/models_actual.sh помечает model_change как
denied только при буквальном совпадении id и target с квитанцией (И5), форматы 3/5 полей
и native true→denied не меняются (И6, двери 104/173). Независимость судьи не ослабляется:
квиток лишь восстанавливает для автопереключённых сессий статус denied на объявленном
фолбэке тира, который check_sud_model и так принимает (scripts/check_sud_model.sh:331
ловит denied вне списка тира), ложных «allowed» не появляется. Именно эта цепочка и есть
незакрытая сторона Б-1: батарея проверила потребителя квитка, но не писателя.

## Сырые выводы ключевых прогонов

- `bash …red_otkaz_po_soderzhaniyu_215.sh --repo .` → `KLETKI=14 KRASNYH=5`, rc 1;
  красные: flagged/cyber/filter «ребёнок failed (exit 1), ожидался completed»,
  exhausted «CONTENT_FALLBACK_EXHAUSTED absent», trace
  «TRACE_paired_False … expected='…stub-zai/glm\tdenied' got='…allowed'».
- `bash …red_otkaz_po_soderzhaniyu_215.sh --model` → `KLETKI=14 KRASNYH=0`, rc 0
  (flagged/cyber/filter: gpt-sol → glm completed, exhausted: 2 хода glm cyber-отказ +
  EXHAUSTED, trace: ok, error500/short429: повторы без переключения).
- `bash …red_otkaz_po_soderzhaniyu_215.sh --stabs` → `STABY=15 SVJAZI=19 ZHIVYH=0`, rc 0
  (в хвосте: caught wrong-target/same-provider/no-receipt/receipt-any-id/receipt-any-model/all-denied).
- `bash …red_otkaz_po_soderzhaniyu_215.sh --sosed` → `cells=6 red=0`, rc 0
  (c1…c6 батареи 129 с reference-расширением 215).
- `--sintaksis` → `SINTAKSIS=0`, rc 0; `--catalog` → `KLETKI=14 STABY=15 SVJAZI=19`, rc 0.
- `bash scripts/check_precision_gate.sh <клон> contracts/215-…md` → `OK`, rc 0.
- `python3 …/catalog.py --zones` → 46 строк, diff с контрактом пуст; `catalog.py` →
  frozen 129/2 104/2 166/2 186/2 198/1 разрешены, FROZEN_VERSION_CHANGED нет.
- `python3 …/runtime_evidence.py` → binary sha256 bfb7a85c…bd052f, sources=7, все FILE и
  байты совпали с §«Измеренный шов omp» (messages.ts 175311716/2,
  lifecycle-mirror.ts 181151861/23, compact-handler.ts 181067002/7,
  runtime-init.ts 181069552/39, model-api.ts 180919513/2, flags.ts 170372763/125 и
  170372712/124).
- `bash scripts/check_sdacha.sh "$PWD" contracts/215-…md --run`: попытка 1 → rc 1
  «ОТКАЗ: строка 41: бюджет листа 900 исчерпан на команде: … --repo .» (конкурентная
  нагрузка, именованный шов 193), повтор отдельных дверей по одной + полный прогон с
  SDACHA_BUDZHET_SEK=1800 → rc 0 «СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=0)».
- Мутации критика (одноразовый клон, по одной, удалены):
  - M1 поддельный modelChangeId: `--model --case trace` → `ok trace`, `KLETKI=1
    KRASNYH=0`, rc 0 — ЖИВ (блок Б-1).
  - M5 чужой target в квитке: `--model --case trace` → `ok trace`, rc 0 — ЖИВ (Б-1).
  - M3 снята терминальность (`if (false)` у ветки исчерпания): `--model --case exhausted`
    → `KRASNO exhausted: нет результата с маркером M129`, rc 1 — пойман (12+ ходов glm).
  - M4 переключение на любой 400 (условие `&& m.errorStatus !== 400`): `--model --case
    other` → `KRASNO other: ребёнок completed, ожидался failed … model glm`, rc 1 —
    пойман.

Вердикт: FAIL — один блокирующий класс Б-1 (К-08/К-10/К-14): привязка квитка расширения
к настоящему model_change заявлена обязательством и защитой, но не обеспечена ни одной
клеткой батареи, живые мутанты M1/M5 проходят зелёными. Остальная поверхность предмета
проверена и расхождений не дала.

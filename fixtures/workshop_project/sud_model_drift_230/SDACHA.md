# СДАЧА 230 — пригодное свидетельство модели судьи

База main fcaff8bf2bc602bbe1fac7a6b7b507d84cc93041; production не меняется. Контракт — contracts/230-sud-model-drift.md. Reference берёт настоящие check_sud_model.sh/judge_gate.sh из этого неизменяемого предка, resolver из кандидата; собственный native-JSON producer — контроль достижимости нового шва, не полный replacement legacy human-отчёта. Утрата ни одной строки/приёмка каждой модели доказывается поведением полной цепочки, не происхождением произвольного переданного TSV.

Измерено на финальном каталоге: --repo . rc 1 `KLETKI=57 KRASNYH=27`; --model rc 0 (отдельная дверь check_sdacha и честные контроли --stabs); --catalog rc 0 `KLETKI=57 STABS=23 SVJAZI=38`; --stabs rc 0 `STABS=23 ZHIVYH=0`; --sintaksis rc 0. pre_critic rc 0, check_sdacha rc 0 `двери=13 карта=17/17 дельта=0`. Проверка pins.py дважды прошла как дверь листа: origin-only BASE-предок, чистый checkout, --model/--stabs rc 0.

Красные до реализации: empty-jsonl, broken-jsonl, broken-after-good, event-missing-model, event-bad-boolean; duplicate/duplicate-reverse/duplicate-allowed в режимах tsv, bind, bind-alias, human, all-human; duplicate-global-bind; honest/drift в сериализациях spaces, reordered, runtime. Это наблюдённый список до-230, не дополнительный фильтр будущего --repo. Базовая компактная недопущенная смена уже отказывает через настоящую дверь 222: задача не выдумывает отсутствующий баг check_sud_model.

Первая попытка pre_critic закончилась на грамматике листа (python3 <файл> не разрешён, исправлено на настоящий executable путь); следующая была остановлена внешним timeout 60 с. Изолированный повтор с SDACHA_TIMEOUT_SEK=600/SDACHA_BUDZHET_SEK=2400 прошёл за 99.39 с; uptime перед ним: load average 8.74, 5.73, 6.56, 22 users. Отдельный check_sdacha прошёл за 71.91 с. Это не повтор до случайного зелёного: первый исправил форму, второй поднял только внешний deadline, содержательные пороги неизменны.

Ожидания rc и диагностических причин — immutable Case; ожидаемые полные TSV/append-байты и исходный журнал захватываются в родительскую память до вызова. Дубли создаются в разных датированных каталогах; mtime задаётся явно в обоих порядках; оба пути обязательны в диагностике. У ошибочного producer stdout пуст, journal не изменён; реальный writer не вызывается без пригодной трассы. У отказа двери полный журнал остаётся тем же, честный accept добавляет ровно одну строку. Git-OBJECT — реальный empty commit автономного мира, с тестовой architect identity, не SHA из головы. Все temp-миры удаляются TemporaryDirectory.

Конфиг тестового мира remap-ит models через настоящую грамматику; динамические контроли меняют только значения primary/fallback с effort/route. Terra — положительное историческое предъявление, не production whitelist. Отдельные prefix/provider/effort-варианты fallback остаются отрицательными. Leading-zero и длинный ID остаются буквальными самостоятельными именами, не числовым порядком. JSON spaces/reordered/nested-runtime имеют честную зелёную пару и недопущенный промежуточный fallback.

Н-39: source.json и stabs/ — единственный исполняемый реестр адресных мутаций. Прямые порчи настоящей двери/писателя проверяют свободу назначения 222, bare/full 173, каждый denied и отказ append; producer-порчи различают потерю события и неоднозначность, а не только ошибочную маркер-строку. Синтаксис мутантов проверяется до предъявления, нет исполнимого носителя/пина/якоря — rc 2. В первой пробе substring-session имел лишнее неразличимое предъявление длинного имени; привязка исправлена до сдачи: длинный сосед проверяет отдельное усечение, substring предъявляется только различимому входу. Сам предмет/полярность не менялись.

Чистые пины: pins.py клонирует только origin через scripts/gitw в TMPDIR внутри своей копии, checkout BASE, проверяет BASE-предка origin/main и remote=origin. Батарея запускается из текущей сдачи с --source-root этого чистого checkout; ни fixture-overlay, ни локального fetch/самоссылочного origin нет. После --model/--stabs git status чист; origin-only clone удаляется. Собственный неопубликованный commit не выдается за доступный origin.

Среда: TMPDIR=$PWD/tmp/scratch-arch230; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck; PYTHONDONTWRITEBYTECODE=1; budget/timeout берутся из профиля либо SDACHA_TIMEOUT_SEK/SDACHA_BUDZHET_SEK. pins.py использует сеть GitHub, НЕ модельные запросы. Новые credentials не нужны.

Проводка done до CI orchestrator не объявляется завершённой. Production-зона ровно scripts/models_actual.sh: крючок модели уже исправен в 222, переносить/дублировать его не нужно. Frozen 174 единственная дельта — неоднозначность вместо объединения; остальные frozen-свойства проверяет прежний регресс. 215 ещё не реализован на BASE; его id/target-квитанция обязательна при будущей последовательной интеграции, не стирается reference-копированием.

## Двери

- Red-before · bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --repo . · 1 · 1
- Honest-control · bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --model · 0 · 0
- Bound-mutations · bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --stabs · 0 · 0
- Native-syntax · bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --catalog · 0 · 0
- Origin-only-pins · fixtures/workshop_project/sud_model_drift_230/pins.py · 0 · 0
- Frozen-ownership · fixtures/workshop_project/sud_model_drift_230/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/230-sud-model-drift.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/230-sud-model-drift.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/230-sud-model-drift.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/230-sud-model-drift.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/230-sud-model-drift.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: все двери формы выше, pre_critic/check_sdacha выполняются последовательно; done-проводка не подделана · - · -
- К-02 · чисто · вход: m2477 и задание 230, существующая затравка, запрет менять модели/цепочки, R-0102; устаревший autoFallback затравки явно отделён от BASE · - · -
- К-03 · чисто · вход: git show frozen 222/1, 198/1, 173/1, 104/2, 166/2, 028/3, 095/1, 174/1, 215/1; адресная дельта 174 и сохранение 215 в контракте · - · -
- К-04 · чисто · вход: architect новая семья/контракт, implementer только models_actual.sh, CI orchestrator, судейские зоны; context.py читает высшие frozen-блобы · - · -
- К-05 · чисто · вход: каждая приёмка содержит rc-команду, красное сейчас отделено от после реализации; нет мнимого fork_route агрегатора · - · -
- К-06 · чисто · вход: отсутствующая зависимость/пин/якорь/синтаксис/таймаут даёт 2 NOT_IMPLEMENTED, ошибочный JSON — отдельный названный предметный вход · - · -
- К-07 · чисто · вход: --model; настоящие Git/bash/node/jq, реальные producer/door/writer; pins.py проверяет origin-only источник без overlay · - · -
- К-08 · чисто · вход: --stabs выполняет каждую source.json связь отдельно, honest controls обязательны; first/last/substring/ignore-event и длины/ведущие нули различимы · - · -
- К-09 · чисто · вход: human/all/tsv/bind/bind-alias, selected/global-bind, обе mtime-полярности, одинаковые дубли, все судейские роли, per-call/fallback, malformed/empty, spaces/reordered/runtime · - · -
- К-10 · чисто · вход: полные TSV и журнал, пустой stdout отказа producer, все пути неоднозначности; не сообщение об append · - · -
- К-11 · чисто · вход: Case/ожидаемые байты в памяти до субъекта; исходный журнал после вызова не перечитывается как ожидание · - · -
- К-12 · чисто · вход: native json.loads для JSONL, настоящий roles.ts для назначения, bash -n/pinned shellcheck и ast; не самописный JSON-парсер · - · -
- К-13 · н/п · секреты не вход/выход предмета, платные provider-вызовы отсутствуют; origin SSH использует существующую среду без печати credentials · - · -
- К-14 · чисто · вход: terra-singleton/terra-bare, per-call, declared-fallback, literal zero/long IDs, честные JSON эквиваленты остаются зелёными при запрещающих парных входах · - · -
- К-15 · чисто · bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --catalog · 0 · 0
- К-16 · чисто · вход: рисковый класс — безопасность свидетельства, граница доверенной JSONL/TSV/назначения и CI/независимый суд названы · - · -
- К-17 · н/п · станционный ремонт, sourceCanon/продуктовая модель не объявлены; архитектурные операции/писатели продукта не меняются · - · -

## Рефлексия

174 явно сохранял смешение одинаковых basename, поэтому его frozen-текст нельзя молча назвать совместимым: 230 адресно заменяет только эту фразу. Второй процессный риск — кодовая затравка уже устарела по autoFallback из-за owner R-0120; дерево и живые frozen-блобы использованы как истина. Нумерованный общий журнал architect не меняется в wip-ветке; эти выводы передаются оркестратору без самовольной записи в main.

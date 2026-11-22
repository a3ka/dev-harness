# СДАЧА 206 — среда изолированного судьи

Новый предмет. База db56f44d1012854b6098a7076fccdae0855badeb.
Пачка содержит контракт, исполняемый эталон дельты, красную батарею,
адресные мутации и наблюдатель живой приёмки. Production/роли/CI не менялись.

## Двери

- модель · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- каталог-канон · fixtures/workshop_project/sreda_sudji_206/catalog.py --check · 0 · 0
- наблюдатель-контроли · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/206-sreda-sudji.md · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/206-sreda-sudji.md · 0 · 0
- ids · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- проводка-грамматика · bash scripts/check_provodka.sh --grammar . contracts/206-sreda-sudji.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/206-sreda-sudji.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/206-sreda-sudji.md · 0 · 0
- pre-critic · bash scripts/pre_critic.sh contracts/206-sreda-sudji.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери формы этого листа, обязательный pre_critic rc0 до сдачи · - · -
- К-02 · чисто · вход: task-arch206, четыре свойства задания и ТЕГ 4 сохранены; live требует реальных судов, локальная модель не выдаётся за них · - · -
- К-03 · чисто · вход: М1 037, pin/actual 032/066, чужой state и detached/main отказы 172 сохраняются; чтение cp исправляется без нового allowlist · - · -
- К-04 · чисто · вход: отдельные зоны author/implementer/orchestrator; три производные роли объявлены; пересечения полным списком cross-author из zones_load базы · - · -
- К-05 · чисто · вход: приёмка несёт команды и rc; live.py требует параметры настоящего одноразового проекта · - · -
- К-06 · чисто · вход: авария Node/git и неуникальная мутация rc2; она не засчитывается за красную ветвь · - · -
- К-07 · чисто · вход: модель вызывает настоящие Node/git/pre_judge в реальных disposable репозиториях; канон поведения — те же публичные швы после C · - · -
- К-08 · чисто · вход: адресные операции и входы заданы MUTATIONS, каталог генерируется catalog.py; честный контроль обязателен до атаки · - · -
- К-09 · чисто · вход: cp/mkdir с именем и абсолютным бинарником; цитирование, LF, NUL, пустая команда/owner, односимвольная цель; три роли отдельно · - · -
- К-10 · чисто · вход: полный rc/stdout/stderr побайтово; настоящие verdict-коммиты под identity судьи; live требует парные RELEASE и не принимает пустую выборку · - · -
- К-11 · чисто · вход: ожидаемые байты сняты в память до субъекта; state/foreign снимки до операций; модель из immutable BASE, не из продукта · - · -
- К-12 · чисто · вход: JSON — json.loads, Git — настоящий plumbing, shell — существующая токенизация guard; норма из одного примитива, каталог сверяется побайтово · - · -
- К-13 · н/п · секреты в предмет не входят, новых секретов нет · - · -
- К-14 · чисто · вход: положительные пары mkdir absolute/cwd/quoted, cp read-to-own, право собственного пина, честные роли и observer honest; запрет не заменён allow-all · - · -
- К-15 · чисто · вход: численные итоги печатает раннер, stabs.tsv сравнивается с кодом; отсутствие повторного измерения исходной боли явно названо · - · -
- К-16 · чисто · вход: риск безопасности записи/путей; граница 032 не объявляет shell песочницей; живой gate нельзя заменить статикой роли · - · -
- К-17 · н/п · harness не имеет pinned проектного архитектурного брифа 187а/188 для этого предмета · - · -

## Доказательства и границы

Сырые rc модели, мутаций, красного-до и отдельных дверей передаются в докладе
с полным SHA. Машинные ряды листа — проверяемые требования, не утверждение
о выполненном до запуска результате. --repo . до реализации ожидаемо красен;
его rc не включён как зелёная дверь авторской конструкции.

Живая тройка — NOT_RUN до C, установки и рестарта ТЕГ 4. live_control.py
пишет только synthetic.jsonl под собственным scratch и не касается настоящего
учёта; его зелень проверяет наблюдателя, не имитирует исполнение судьи.
Настоящий журнал передаётся live.py только наблюдателем; запись START/RELEASE
остаётся за существующим zamok_predmeta. Текст роли — cognitive-only до этого
живого прогона, ловцы critic/reviewer по настоящим трейсам.

Рефлексия процесса: старый пакет Б содержит явный зелёный контроль записи в
назначенный пин. При проектировании «WORKTREE только доставка» это необходимо
развести с чужим WORKTREE, иначе новый запрет противоречил бы frozen-пробе.
Конструкция сохраняет старое право, правило судьи выбирает свою копию;
подлинно чужое дерево остаётся охранным отказом. Общий журнал наблюдений main
не менялся: изолированная ветка не имеет права раздавать общие А-номера.

## Фактический замер авторской пачки

| Команда | Сырой rc | Наблюдение |
|---|---|---|
| `red_sreda_sudji_206.sh --repo .` | 1 | KLETKI=42 ZELENYE=21 KRASNYE=21 |
| `red_sreda_sudji_206.sh --model` | 0 | KLETKI=42 ZELENYE=42 KRASNYE=0 |
| `red_sreda_sudji_206.sh --stabs` | 0 | OBMANOK=19 POIMANY=19 ZHIVYH=0 |
| `catalog.py --check` | 0 | STABS=19 NORM_CONSUMERS=3 |
| `live_control.py` | 0 | OBSERVER_CONTROLS=12 KRASNYE=0; LIVE_JUDGES_NOT_RUN |
| `check_precision_gate.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_spec_ready.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_ids.sh .` | 0 | номера уникальны и согласованы с регистром выдачи |
| `check_ceilings.sh .` | 0 | потолки в порядке |
| `check_provodka.sh --grammar . contracts/206-sreda-sudji.md` | 0 | без вывода |
| `check_threat_model.sh . contracts/206-sreda-sudji.md` | 0 | ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 5 |
| `check_predposylki.sh . contracts/206-sreda-sudji.md` | 0 | PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2 |
| `check_sdacha.sh . contracts/206-sreda-sudji.md --run` | 0 | двери=12 карта=17/17 дельта=0 |
| `pre_critic.sh contracts/206-sreda-sudji.md` | 0 | КРИТИК: дверь зелёная |
| `validate_std.sh bash red_sreda_sudji_206.sh` | 0 | bash -n и настоящий shellcheck 0.11.0, бинарь проверен штатной обёрткой по пину |

Последний ряд исполнен полными путями: `bash scripts/validate_std.sh bash
fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh`, со швом
VALIDATE_STD_SHELLCHECK на скачанный официальный бинарь под собственной
.scratch-206. Первоначально PATH-команда дала rc127, штатная обёртка —
rc2 VALIDATOR_MISSING; после локальной установки ровно pinned 0.11.0 —
rc0, пины и окружение станции не менялись. Временный бинарь удаляется
вместе с собственным scratch до сдачи.

Ранние отказы конструкции: precision rc1 по производной
.omp/agents/reviewer.md/050 (путь добавлен после первого снимка);
spec-ready rc1 по чтению исходников из §Существующее как проб без
канонического заголовка §Приёмочный критерий. Обе причины исправлены
до последних зелёных дверей. Цена — два холостых прогона, класс —
повтор А-378: изменив набор зон, надо переснять весь список, а не
доверять прежнему снимку. Закрыто здесь полной сверкой fresh zones_load
и каноническим заголовком. Нового предмета или новой общей нормы нет.

Legacy-пробы, живая тройка, генерация production-ролей и CI-проводка —
NOT_RUN в этой авторской пачке. Старые path_guard-пробы имеют жёсткий
внешний /tmp/dev-harness-worktrees; запуск из этой изоляции записал бы
вне разрешённой собственной копии. Их неизменённые команды сохранены
в приёмке реализации; механический запрет не обходился.

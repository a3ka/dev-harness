# СДАЧА 140 — исправление FAIL Adv140A2: К-02…К-05

## Исправление FAIL Adv140A2

БАЗА: `60463b6dab6407b30de4f2d33ec989069e71f412`.
Вердикт: `ee9dd0af773db495dc40bcb2bcfb695ef2249f60`,
`verdicts/adversary/contracts-140-v10.md` в архивном ref станции.
Production, frozen-контракт и чужие зоны не меняются.

СТОП: пачка НЕ ГОТОВА к передаче implementer/суду. §16 задания требует
для битого профиля без паузы прежний rc 0, а §9 допускает fail-closed
при неопределимости паузы. Битый произвольный профиль не доказывает
отсутствие паузы в другом workflowPaths.registry. Самостоятельно ослаблять
один из этих критериев нельзя; точный запрос решения отправлен Main.
Клетка r15 пока строго сохраняет заданный rc 0; модель К-03 не изменена,
чтобы не узаконить необоснованный fallback. W-model фактически rc 1:
MODEL_KLETKI 213 KRASNYH 1, ровно r14. Все остальные модельные клетки зелены.
W-stabs/check_sdacha после этого содержательного блока — NOT_RUN;
MODEL_ZHIVYH=0 и зелёная сдача НЕ утверждаются. Прежние замеры ниже —
только история. Возобновление требует решения о точном критерии r15.

§Существующее: `probe.Mir`, `m.sobytie`, `p.item`, `p.sudit` и
`p.snimok_fajlov` уже дают независимые .git-миры, реальный --sudit и снимок
состояния ДО вызова. `reestr_140.py` уже строит профиль и pin frozen;
`uproshchenie_140.py` уже проверяет разовую санкцию o01-pauza-once/bound.
Переиспользован настоящий project_paths_resolve, новый парсер не введён.

Обещание: отсутствие автора не отменяет порядок reviewer/adversary;
ошибка чтения профиля не снимает паузу; некорректный дубль общей строки
не расходует санкцию; каталог frozen берётся из workflowPaths.contracts.
Наблюдение: rc/именованный отказ, START/warn/override и побайтовая
неизменность долговечных файлов при отказе. Ожидания снимаются до двери.

| блок / клетка | rc двери на OBJECT | ожидаемый rc честной двери |
|---|---|---|
| К-02 / r11-noauthor-reviewer | 0, START reviewer — красен | 1 ADVERSARIJ_DO_REVJUERA, без записей |
| К-02' / r12-noauthor-adversary, r13-noauthor-critic | 0, RABOCHEGO_NET + START | тот же 0 + warn + START |
| К-03 / r14-profile-broken-pauza | 0, START при паузе — красен | 1 PAUZA_VLADELTSA либо именованный отказ профиля, без записей |
| К-03' / r15-profile-broken-bez-pauzy | 0, START | прежний rc 0 + START (блокер смысла назван выше) |
| К-04 / r16-override-dubl-extra, r17-override-dubl-object | 0, override + START — красны | 1, без расходования override и записей |
| К-04' / прежние o01-pauza-once/bound | 0, одна санкция + START; повтор 1 | прежнее поведение |
| К-05 / r18-kontrakty-profil-obychnyj | 0; мутант contracts: 1 — красен | 0, START, без KLASS_RISKA_NET |
| К-05 / r19-kontrakty-profil-riskovyj | 1; мутант contracts: 1 + KLASS_RISKA_NET — красен | 1 ADVERSARIJ_DO_REVJUERA без KLASS_RISKA_NET |

К-05 — дефект достаточности батареи, а не product-двери: новые входы
на OBJECT зелены; красен её реальный мутант konstanta contracts.
Frozen-миры несут только объявленный нестандартный каталог
(.x/contracts / .other/contracts), отсутствие contracts/ в frozen
удостоверяется Git plumbing до вызова. Значения имён/SHA не оракул.
Привязки s90–s93 к различающим ветвям — код BINDINGS, не проза контракта.
Честные эквиваленты — две раскладки/полярности К-05, adversary/critic
К-02', отсутствие паузы К-03' и существующая одиночная санкция К-04'.

К-01 НЕ чиним: решение владельца 21.11 12:06 «брошенный замок
освобождается автоматически». Прежние ZAMOK_BROSHEN-клетки и их
warn/RELEASE/START сохранены; таймерная красная клетка не добавлена.

Сырой адресный замер воспроизводится командой
`python3 fixtures/workshop_project/odin_agent_140/reestr_140.py`
(TMPDIR под собственной копией): RAW rc/stdout/stderr/ledger для
каждого нового входа и отдельного К-05-мутанта; CELL_RC — вердикт клетки.
S/stancija_* из этой копии не запускаются.

Счёт семьи: прежние W 205 → 214 (213 динамических + r10);
профильный W-domain 10 → 19; source.json: cases=213, mutants=94,
bindings=171, carriers=99. Независимые меры: W печатает KLETKI 214,
--domain KLETKI 19, --sintaksis SINTAKSIS FILES 95.
Собственный прогон на OBJECT: W rc 1, 214/4; --domain rc 1, 19/4;
красны РОВНО r11/r14/r16/r17. Все прежние 205 зелены, К-01 сохранён.
--grammar rc 0; --sintaksis rc 0; parsing_hygiene rc 0, 4/4.
Сырой адресный замер: r11/r14/r16/r17 возвращают 0, CELL_RC=1;
r12/r13/r15/r18 CELL_RC=0 при rc двери 0; r19 CELL_RC=0 при rc двери 1.
На К-05-мутанте обе r18/r19 дают CELL_RC=1, в обоих случаях rc двери 1.

Процессная рефлексия: противоречащие полярности положительного контроля
нельзя разрешать ростом самописного fallback либо ослаблением клетки.
Содержательный конфликт предъявлен до изменения К-03-модели и матрицы;
требуется решение смысла. Общий А-NNN-журнал не меняется: вне зоны и
допустим только коммитом в main.

## Предыдущая пачка Ш-2 (история)

### Пачка Ш-2 (2026-11-21, до Adv140A2)

БАЗА сборки Ш-2 после реализации: 92a4a8e3187b82eeb020953f754d48606104d931.
Прежние замеры «до» сохранены ниже как история, не rc текущего кандидата.
Замороженный контракт и production этой пачкой не изменяются.

§Существующее: Mir.worktree/pin_frozen уже создают annotated frozen и pin;
Mir.start/zhurnal — сданного рабочего; --sudit и START/warn — наблюдаемый шов.
project_paths_resolve в scripts/next_id.sh уже читает закрытый профиль.
Модель использует именно этот резолвер, новых ключей и парсера нет.
Все миры и временные стабы — внутри TMPDIR своей копии, со своей .git.

Обещание: contracts.tsv и pauzy.tsv берутся из объявленного реестра;
без профиля — прежний registry/. Reviewer обычного frozen допускается со
START; рискового — ADVERSARIJ_DO_REVJUERA без изменения состояния.
KLASS_RISKA_NET не принимается за доказательство чтения pin: после A2 он
означает рисковый по умолчанию и маскирует пропущенный реестр.
Демаркация: действительный двухслойный профиль существующей грамматики,
полный workflowPaths, annotated frozen с pin, сданный рабочий, точный OBJECT.
Значения SHA/имени/пути не являются ожиданием; различение — допуск/причина,
START, отсутствие предупреждения неизвестного риска и неизменность отказа.

Клетки (а)–(г) и ожидаемое состояние до/после:

| вход | до Ш-2 | после Ш-2 |
|---|---|---|
| r01 (.x/reg, обычный) | красен: reviewer отвергнут | rc 0, START, без KLASS_RISKA_NET |
| r02 (.x/reg, рисковый) | красен: риск не прочитан | rc 1 ADVERSARIJ_DO_REVJUERA, без записей |
| r03 (без профиля) | зелён | прежний rc 0, START |
| r04 (.x/reg, пауза 140) | красен: пауза пропущена | rc 1 PAUZA_VLADELTSA, без записей |
| r05 (.x/reg, пауза 141) | красен: pin не прочитан | rc 0, START |
| r06/r07 (штатный профиль, пауза 140/141) | зелены | соответственно отказ/допуск |
| r08/r09 (без профиля, пауза 140/141) | зелены | соответственно отказ/допуск |
| r10 (точный статический критерий) | красен | rc 0, исходный критерий без сужения |

Привязки s87/s88/s89 — код reestr_140.py и производный source.json.
Каждый стаб предъявляется только своему различающему входу.
--model проверяет семантику; r10 — отдельная --grammar, также обязательная
часть W/--domain и слоя production в --stabs. Исходный критерий не ослаблен.
Машинные rc ниже приведены к состоянию ПОСЛЕ реализации Ш-2;
оба столбца — фактический rc кандидата (формат check_sdacha).

## Развилки Ш-2

S-station ОТЛОЖЕН по поправке задания: запустит оркестратор вне /zones/.
Прямой и косвенный запуск S из этой копии запрещён; поэтому S не включён
в машинную секцию дверей этой сдачи. Обязательство S контракта сохранено.
Режим --live отсутствовал на базе; --domain и --grammar добавлены этой
пачкой. --sintaksis — существующий синтаксический режим, не подмена --grammar.

Историческая развилка до реализации: точный критерий (г) находил также
executable-упоминания .harness/contracts и registry/pauzy.tsv в диагностике.
Предложенное сужение критерия НЕ применено. Реализация Ш-2 устранила
литералы: kontrakt_kat использует workflowPaths.contracts существующего
резолвера, без профиля — contracts/. Поэтому исходная r10 зелена.
У s35 прежний якорь выбора каталога заменён на блок вызова kontrakt_kat
для production; модель сохраняет прежний якорь. Обе формы мутации читают
класс из рабочего каталога станции, а не из закреплённого дерева владельца.
Прежние шесть различающих входов и их кодовые привязки сохранены.

## История legacy-пачки

БАЗА: 971a5dfc2b681e519dbd544f2ffc6c72110239a8.
Исторический FAIL verdicts/critic/contracts-140-v5-r2.md (блоки К-02/К-16) закрыт в «## Дельта».
Исторический FAIL Crit140Combined находится в verdicts/critic/contracts-140-v5.md;
его OBJECT и текст не изменяются. Исправительный Crit140Fix6 вынес полный
вердикт с картой классов на принятую пачку; текущая дельта закрывает его
legacy-ветвь, не меняя прежних обязательств.

## Предмет и существующее

Обещание: blob-привязка старого frozen берётся из registry/risk-legacy.tsv
владельца предмета при прямом и переданном пути. Наблюдение — допуск reviewer
обычного продукта, ADVERSARIJ_DO_REVJUERA рискового и KLASS_RISKA_NET при
отсутствующей привязке владельца, без записи START при отказе. Станционный
legacy сохраняет прежние допуск и порядок. Frozen-обязательства 140,
104/167/197/199, fail-closed и batch-атомарность не ослабляются.

Существующее: klass_riska уже получает репозиторий владельца как wt и точный
commit frozen; frozen_predmeta и проверяемый receipt уже выбирают владельца.
Перечень файлов, Git blobs, литеральное blob-сравнение и алфавит класса
сохраняются. Исправлены только корни проверки файла и чтения legacy-реестра.
Формат/механика самого реестра, production, frozen-текст и вердикты неизменны.

Существующие продуктовые миры теперь имеют необязательный legacy-вариант:
старый frozen без декларации и отдельный реестр продукта. Прямой START и
настоящая --peredat предъявляются отдельно. Обе полярности класса проверяются
при противоположной станционной записи того же blob; отдельно предъявлены
отсутствие станционной записи и отсутствие привязки владельца при допустимой
станционной. Станционные контроли имеют старый frozen с привязкой станции,
противоположные декларацию OBJECT и локальную привязку кандидата.

Демаркация: конформный вход — прежняя грамматика 140, действительный annotated
frozen и pin владельца, старый файл без декларации, TSV-привязка его Git blob
с классом обычный|рисковый. Валидное различение не зависит от SHA/пути/имени:
при том же входе подмена владельца реестра меняет допуск либо именованную
причину. Старые клетки и связи сохраняются; привязки мутаций к входам живут
только в produkt_140.py/source.json, не в прозе контракта.

## Среда и результаты legacy-дельты (исторический замер)

Рабочая копия:
/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t3f0d5ee84/m
Ветка wip/140/architect-v5; своя .git; база выбрана после fetch через gitw.
TMPDIR=/tmp/dev-harness-verify, PYTHONDONTWRITEBYTECODE=1; каждый Git-мир имеет
свою .git. Delivery WORKTREE не используется для записи; push не выполняется.

Собственный red-до на точной БАЗЕ: OWNER140_FAILURES 8, rc 1. После реализации
на ae5dbf6b8137f8c1b8c192611a6fc710613cbfce: W --model rc 0,
MODEL_KLETKI 172 KRASNYH 0; W --owner-check rc 0, OWNER140_FAILURES 0.
W --stabs rc 0, MODEL_ZHIVYH 0; безфлаговый W rc 0, KRASNYH 0.
Прежняя предметная краснота production до реализации — исторический замер,
не ожидаемый результат текущего кандидата.

jq по source.json: cases=172, mutants=82, bindings=159, carriers=87,
legacy_cases=10. Независимый обход исполняемой батареи — MODEL_KLETKI 172;
матрица дала SVJAZI 159. Числа старого вердикта — исторические, не эта пачка.
Rc в рядах ниже проверяет фактический check_sdacha --run; сами ряды не
подменяют прогон.

## Двери

- Owner-before — legacy-дефект точной базы · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-before · 1 · 1
- Owner-check — продукт, станция и адресные мутации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- W-model — красная К-03 до разрешения блокера r15 · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 1 · 1
- W-stabs — модель, адресная матрица и красные К-02/03/04 на базе · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs · 1 · 1
- W-production — прежняя семья зелена, новые адресные дефекты красны · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh · 1 · 1
- W-domain — профиль/пауза/каталог и новые адресные дефекты · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --domain · 1 · 1
- W-grammar — исходный критерий Ш-2 без подгонки · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --grammar · 0 · 0
- W-sintaksis — все носители · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --sintaksis · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Provodka · bash scripts/check_provodka.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа и предыдущий закоммиченный вердикт с полной картой; штатный SDACHA_OKRUG=1 разрывает рекурсию pre_critic · - · -
- К-02 · чисто · вход: --owner-before читает точную БАЗУ; --owner-check предъявляет legacy-привязку соответствующего владельца на обоих путях · - · -
- К-03 · чисто · вход: frozen-текст, production и прежние инварианты 104/167/197/199 неизменны; прежние клетки входят в W-model · - · -
- К-04 · чисто · вход: модель, миры, лист и производные носители только в fixtures/workshop_project/odin_agent_140/ architect-зоны · - · -
- К-05 · чисто · вход: каждая дверь несёт команду и rc, соответствующие прежней приёмке 140 · - · -
- К-06 · чисто · вход: W/domain/stabs ожидаемо rc 1 на адресных дефектах OBJECT; grammar rc 0; production/frozen не менялись · - · -
- К-07 · чисто · вход: W 214/4, все прежние 205 зелены; четыре адресные красные r11/r14/r16/r17; S запрещён из этой копии · - · -
- К-08 · чисто · вход: s90–s93 привязаны кодом к собственным различающим входам; К-05 literal красен отдельно на r18/r19 · - · -
- К-09 · чисто · вход: r11–r19 добавляют автора-нет, битый профиль, некорректный дубль и не-default contracts; прежние r01–r09 сохранены · - · -
- К-10 · чисто · вход: реальный --sudit/--peredat в независимых .git; сверяются rc/причина, START, proof и неизменность состояния при отказе · - · -
- К-11 · чисто · вход: ожидания и source.json снимаются в память до вызова двери; материализация носителей выполняется до приёмки · - · -
- К-12 · чисто · вход: прежние Git plumbing и JSON Schema; TSV-сравнение не меняется, новый парсер не вводится · - · -
- К-13 · н/п · новые секретные входы и наружные строки с секретами не вводятся · - · -
- К-14 · чисто · вход: все прежние модели и новые эквиваленты зелены; r14 модели красна до разрешения блокера r15, это не готовая сдача · - · -
- К-15 · чисто · вход: source.json cases=213 mutants=94 bindings=171 carriers=99; независимые W 214 и sintaksis 95 носителей · - · -
- К-16 · чисто · вход: класс берётся по blob закреплённого frozen в реестре владельца, не станции/OBJECT продукта; отсутствие привязки не открывает reviewer · - · -
- К-17 · н/п · схема операций/writers/isolationKeys 188 не меняется; исправляется исполняемая модель батареи 140 · - · -

## Дельта

- К-02 · канон/инструмент · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0

К-02/К-16: существующие проверка файла и awk используют wt владельца,
уже передаваемый в klass_riska на прямом и переданном пути. Это применение
существующего канона, не новый запрет/парсер; снятия обещания или границы нет.

К-09: клетки нужны как наблюдение эффекта двух разных репозиториев —
статическая сверка пути не доказывает допуск и порядок. Проба критика
предъявляется обычным legacy-продуктом без станционной записи; соседние
входы — конфликт классов обоих направлений, прямой/переданный путь,
fail-closed и станционный legacy. Обратная подмена wt на REPO красна;
отдельно красны подмены каждого из двух изменённых выражений. Честные
эквиваленты (реестр владельца при отсутствующей/посторонней станционной
привязке и прежняя станционная привязка) зелены теми же командами.
Новых дверей и обязательств сверх блока нет.

После реализации заявленные rc W-stabs и W-production приведены к 0
по приёмке 3 контракта; пояснения К-06/К-07 отражают то же состояние.
Команды, классы, численность машинных секций и прежняя дельта неизменны.

## Границы и процессная рефлексия

В прежней legacy-дельте S/normalizacija, живой omp и настоящий pre_judge
--prepare были NOT_RUN из-за внешнего /zones/. Станция, normalizacija и
--prepare теперь проверены в безопасном runtime-клоне (замер ниже);
живой omp не запускался. Production не изменялась.
Чистая env -i проба отдельно — NOT_RUN в этой дельте; прежняя приёмка сохранена.

Наблюдение процесса: прежнее перенесение frozen к владельцу не перенесло
смежный legacy-источник, а декларативные миры этого не различали. Закрыто
ветвлением миров по существующей blob-операции, не ростом контракта.
Первый собственный owner-check обнаружил ошибочную привязку read-only
мутации к входу без файла владельца: проверка наличия не пускала к чтению.
Она удалена только из этой пары; сами fail-closed клетки сохранены и
различают полную подмену корня. Общий NABLIUDENIA_ARCHITECT не изменяется:
вне зоны; А-NNN допустима только коммитом в main.

## Фактические ворота legacy-дельты (исторический замер)

С TMPDIR=/tmp/dev-harness-verify выполнены последовательно:
`bash scripts/check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run`
→ rc 0, затем
`bash scripts/pre_critic.sh --repo "$PWD" contracts/140-odin-agent-na-predmet.md`
→ rc 0. Сырой вывод:

```text
СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3)
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```

## Ремонт станционного frozen-мира — 2026-11-20

База поезда: dd60a5a3b38f8cb4fb8421e709b5bbb79eb66053 (PR #1160).
Рабочая копия:
/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tee0b4d018/m
Ветка wip/140/implementer; автор и коммиттер architect.
Все приёмочные команды запущены в независимом клоне с собственной .git:
/tmp/dev-harness-verify/arch140world-1717276/runtime
TMPDIR=/tmp/dev-harness-verify/arch140world-1717276,
PYTHONDONTWRITEBYTECODE=1. Полный сырой вывод:
/tmp/dev-harness-verify/arch140world-1717276/acceptance.log

Обещание и наблюдение: станционные p05/p10/p16 доходят до исходного
порядка adversary→reviewer, допуска после yield и смешанного пакета,
не меняя ожиданий START/isolated/занятий. Существующее: дверь уже требует
закреплённый annotated frozen владельца; одинаковый origin RE/WT выбирает
RE. Построитель теперь коммитит контракт 141 в RE, замораживает его тегом
frozen/contracts/141/1 и отдельным коммитом закрепляет tag-object SHA
в registry/contracts.tsv. В p16 добавлен ранее отсутствовавший контракт
в RE. WT сохраняет непустой OBJECT; дверь, хук и frozen140/5 неизменны.

«Было» ниже — KLASS_RISKA_NET из исходного вывода задания/консультанта,
не повторный запуск заведомого отказа. «Стало» — полный собственный S:

| клетка | было | стало |
|---|---|---|
| p05-int-porjadok-adv-rev | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-false | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-true | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-missing | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-string | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-number | KLASS_RISKA_NET | OK |
| p10-int-propusk-posle-yield-object | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-false | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-string | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-number | KLASS_RISKA_NET | OK |
| p16-int-smeshannyj-paket-object | KLASS_RISKA_NET | OK |

Сырые хвосты выполненных команд (rc самого процесса, не последнего
звена конвейера):

```text
COMMAND: bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh
PROBA p20-int-pervyj-rabochij-true OK
PROBA m01-huk-bez-dveri OK
PROB VSEGO 45 KRASNYH 0
COMMAND_RC=0

COMMAND: python3 fixtures/workshop_project/odin_agent_140/normalizacija_140.py
PROB VSEGO 45 KRASNYH 29
NORMALIZACIJA constant RAZLICHENO 5
COMMAND_RC=0

COMMAND: bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh
KLETKI 172 KRASNYH 0
COMMAND_RC=0

COMMAND: bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs
SUBJEKT_SVJAZI 159
COMMAND_RC=0

COMMAND: python3 fixtures/workshop_project/odin_agent_140/object_140.py --prepare
PREPARE published ok
PREPARE leak ok
PREPARE unpublished ok
COMMAND_RC=0
```

Нормализация: strict rc 0, 45/0; truthy rc 1, 45/18,
RAZLICHENO 9; constant rc 1, 45/29, RAZLICHENO 5. Краснота мутантов —
ожидаемое доказательство ловимости, общий rc normalizacija равен 0.
Все привязки остаются в normalizacija_140.py, не в контракте.

Наличие isolated-хука существенно: p10 и p16 судят собственный START-факт,
p15/p17/p18/p19 — отказ неизолированным рабочим, p20 — честный первый START.
Проба удаления хука не запускалась и в эту дельту не входит.

Процессная рефлексия: смена authoritative-источника риска с OBJECT на frozen
не была проведена через станционные построители. Исправлена реальная
предпосылка мира, не ожидания теста и не честный fail-closed двери.
Общий NABLIUDENIA_ARCHITECT не меняется: он вне зоны, А-NNN допускается
только отдельным коммитом main.

Ворота после ремонта (отдельный сырой вывод — gates.log в том же TMPDIR):

```text
COMMAND: bash scripts/check_sdacha.sh . contracts/140-odin-agent-na-predmet.md --run
СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)
COMMAND_RC=0

COMMAND: bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
COMMAND_RC=0
```

## Собственный замер Ш-2

pwd:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tc48dcbb0c/m`
TMPDIR — `.scratch-sh2` под этой копией; scratch не коммитится.
Полный сырой вывод: `.scratch-sh2/base.log`, `.scratch-sh2/sh2.log`.

```text
БАЗА ddbd3bfc5ea99198934b2bf14648be2b27fc426b:
W: KLETKI 195 KRASNYH 0; COMMAND_RC=0
W --model: MODEL_KLETKI 195 KRASNYH 0; COMMAND_RC=0
W --sintaksis: SINTAKSIS FILES 88; COMMAND_RC=0
W --stabs: SVJAZI 162; MODEL_ZHIVYH 0; SUBJEKT_SVJAZI 162; COMMAND_RC=0

С НОВЫМИ КЛЕТКАМИ, production на той же базе:
W: KLETKI 205 KRASNYH 5; COMMAND_RC=1
W --model: MODEL_KLETKI 204 KRASNYH 0; COMMAND_RC=0
W --sintaksis: SINTAKSIS FILES 91; COMMAND_RC=0
W --stabs:
STAB s87-reestr-literal-proekta r01-reestr-profil-obychnyj KRASEN
STAB s88-pauza-ignoriruet-profil r04-pauza-profil-svoj KRASEN
STAB s89-reestr-tolko-stancija r01-reestr-profil-obychnyj KRASEN
SVJAZI 165
MODEL_ZHIVYH 0
SUBJEKT_KRASNO: 5 — поставленная дверь красна (свидетель критика пойман)
COMMAND_RC=1
W --domain: KLETKI 10 KRASNYH 5; COMMAND_RC=1
W --grammar:
CASE r10-sh2-bez-literalov KRASNO: Ш-2-без-литералов: rc 1 ≠ 0; stderr=
COMMAND_RC=1
check_sdacha --run:
СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)
COMMAND_RC=0
```

Красные production-входы ровно r01/r02/r04/r05/r10. Прежние входы зелены.
r04 на базе отказывает не из-за паузы, а ADVERSARIJ_DO_REVJUERA после
KLASS_RISKA_NET; клетка различает причину, а не засчитывает любой rc 1.
Это исторический замер ДО реализации; текущие rc приведены в дверях выше.

Рефлексия процесса: широкий grep-критерий смешивает путь реестра с
законным каталогом contracts; барьер оставлен точным и красным, конфликт
назван до передачи implementer. Отдельно неизвестный риск после A2
маскирует неполученный pin — поэтому наблюдаются warn и именованная причина,
а не только rc. Общий журнал А-NNN не изменён: вне зоны и только main.

## Сборка после реализации Ш-2 — 2026-11-21

pwd:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tef18fd95d/m`
База: `92a4a8e3187b82eeb020953f754d48606104d931`.
TMPDIR — `.scratch-sh2c` под этой копией; scratch не коммитится.
Полный сырой вывод приёмки: `.scratch-sh2c/acceptance.log`.
Контракт, production, профиль parsing_hygiene_battery и source.json неизменны.
Материализованный s35 модели побайтно прежний; меняется только выбор
строгого якоря при наложении той же мутации на production.

```text
W:
KLETKI 205 KRASNYH 0
COMMAND_RC=0
W --domain:
KLETKI 10 KRASNYH 0
COMMAND_RC=0
W --grammar:
CASE r10-sh2-bez-literalov ok
COMMAND_RC=0
W --model:
MODEL_KLETKI 204 KRASNYH 0
COMMAND_RC=0
W --sintaksis:
SINTAKSIS FILES 91
COMMAND_RC=0
W --stabs:
SVJAZI 165
MODEL_ZHIVYH 0
SUBJEKT STAB s35-klass-iz-main s39-main-riskovyj-kandidat-obychnyj KRASEN
SUBJEKT STAB s35-klass-iz-main s40-main-obychnyj-kandidat-riskovyj KRASEN
SUBJEKT STAB s35-klass-iz-main s41-kandidat-bez-stroki KRASEN
SUBJEKT STAB s35-klass-iz-main s42-risk-legacy-blob-kandidata KRASEN
SUBJEKT STAB s35-klass-iz-main s43-klass-iz-dereva-ne-gryazi KRASEN
SUBJEKT STAB s35-klass-iz-main s44-klass-otkaz-bez-starta KRASEN
SUBJEKT_SVJAZI 165
COMMAND_RC=0
bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta:
БАТАРЕЯ zamok_predmeta: итог 4/4 классов закрыто
COMMAND_RC=0
```

STAB_ZHIV и SUBJEKT_KRASNO в выводе отсутствуют: живых стабов и красных
входов честного субъекта нет. S-station не запускался.

Рефлексия: текстовый якорь стаба отстал от замены операции выбора каталога.
Исправлена привязка к реальному блоку двери, не ослаблены r10 или входы;
история красного замера не подменяет текущие rc машинного листа.
Общий журнал А-NNN вне зоны и допускает запись только в main.

Ворота этой сборки, полный сырой вывод `.scratch-sh2c/gates.log`:

```text
check_sdacha.sh "$PWD" contracts/140-odin-agent-na-predmet.md --run:
СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)
COMMAND_RC=0
pre_critic.sh --repo "$PWD" contracts/140-odin-agent-na-predmet.md:
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
COMMAND_RC=0
```

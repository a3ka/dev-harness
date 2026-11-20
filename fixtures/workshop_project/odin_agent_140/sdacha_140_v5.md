# СДАЧА 140 v5 — legacy-реестр владельца, К-02 / К-09 / К-16

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
- W-model — все прежние и новые клетки · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- W-stabs — адресная матрица и production после реализации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs · 0 · 0
- W-production — настоящая дверь после реализации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh · 0 · 0
- S-station — поставленный хук и frozen-миры владельца · bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh · 0 · 0
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
- К-06 · чисто · вход: после реализации ожидаемый rc 0 W-stabs, MODEL_ZHIVYH 0; rc 1 предметной красноты и rc 2 ошибки среды/оракула не считаются успехом · - · -
- К-07 · чисто · вход: полный W-stabs, W-production и S-station зелены; normalizacija различает адресные мутации при зелёном строгом контроле · - · -
- К-08 · чисто · вход: полный W-stabs; подмена обоих legacy-корней и отдельные подмены проверки/чтения красны адресными входами · - · -
- К-09 · чисто · вход: legacy-продукт прямой/переданный, обе полярности, отсутствующая и конфликтующая станция, отсутствующая привязка владельца; отдельный станционный контроль обеих полярностей · - · -
- К-10 · чисто · вход: реальный --sudit/--peredat в независимых .git; сверяются rc/причина, START, proof и неизменность состояния при отказе · - · -
- К-11 · чисто · вход: ожидания и source.json снимаются в память до вызова двери; материализация носителей выполняется до приёмки · - · -
- К-12 · чисто · вход: прежние Git plumbing и JSON Schema; TSV-сравнение не меняется, новый парсер не вводится · - · -
- К-13 · н/п · новые секретные входы и наружные строки с секретами не вводятся · - · -
- К-14 · чисто · вход: честные legacy-миры зелены при отсутствии и противоположном классе станции; обычная станция продолжает допускать, рисковая сохраняет отказ · - · -
- К-15 · чисто · вход: jq source.json cases=172 mutants=82 bindings=159 carriers=87 legacy_cases=10; исполняемый обход MODEL_KLETKI 172 и SVJAZI 159 · - · -
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

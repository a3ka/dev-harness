accept
OBJECT=3f95c73c6f9d2b6d4f922313de88a7d599eddc5f
СУД: repo=dev-harness; предмет=162; фаза=контракт v+1 (повторный суд изменённого кандидата); роль=critic; вызов=3/5 (базовый бюджет 1+1 исчерпан вызовами 1–2; санкция владельца — коммит 0c53191aa, docs/owner/2026-11-09-arhitektura-i-poryadok-stancii.md:11 «162 — v+1 контракта: путь … в зону; + критик»); модель-план=@glm (тир apex-sol, config/agent_models.json roles.critic); сессия=Critic162v2; модель-факт=zai/glm-5.3 (сверку трейса и дописку СУД-строки в HANDOFF делает оркестратор); SHA=3f95c73c6f9d2b6d4f922313de88a7d599eddc5f; предыдущий=accept на 4dc0a5294 (архивирован как contracts-162-v2-staryj-accept-4dc0a529.md — кандидат семантически изменён, прежний accept неприменим); исключение=нет (совпадение семейства glm автора-архитектора и судьи не препятствие: контракт 166, слово владельца 2026-11-07; собственной работы судья не судил).

## Область

Scoped-повтор по §Контракт (Быстрый процесс): закрытие названных классов (Critic162 вызов 1 — FAIL; Rev162 Э-1/Э-2/Э-3) и последствия дельты 4dc0a5294..3f95c73c6f — один файл contracts/162-standart-koda-mob.md (+30/−8), автор architect, коммит = tip wip/162/architect. Состав дельты: измеренное основание про check-structure.cjs (:18), отвергнутая альтернатива Frontier (:27), разрешение в Предмете (:31), проза Док-приёмки (:42), структурный подвопрос (:65) и новый пункт о диффе к 932ee4a (:66), замена критерия 4 на живые валидаторы 027 (:68–86), --task-file в критерии 5 (:87), маршрут (:100), ЗОНА implementer + mobile/structure-policy.json (:103) и ПЕРЕСЕЧЕНИЕ (:104). Инварианты И-1–И-4, ИСТОЧНИК-пины (5), модель угроз (:91–96) и JSON-спека дельтой не тронуты и повторно не судились; пины живьём подтверждены Crit162b (CITATIONS OK count=5, байты неизменны).

## Закрытие классов

- **Э-1** (блок слияния: `.tsv` вне политики, правка вне ЗОНЫ implementer) — ЗАКРЫТ: основание :18 сверено живьём (check-structure.cjs:20 — регулярка исполняемых расширений; mobileFiles на 932ee4a строки не содержит); :31 допускает ровно одну строку; :103–104 зона с пересечением (143 владеет файлом — contracts/143-mob-ci-razdelenie.md:166); приёмка :65 (rc 0 `structure: OK` / rc 1 с точным сообщением) и :66 (дифф к 932ee4a — ровно 1 файл, numstat `1<TAB>0`). Все три состояния измерены Rev162 живьём: база rc 0 / кандидат rc 1 / кандидат+строка rc 0.
- **Э-2** (буквальная команда критерия 4 давала rc 2 NOT_IMPLEMENTED по конструкции загрузчика 027) — ЗАКРЫТ: команда заменена на cmp с frozen-тегом + экспортированные валидаторы 027 (:68–86; node --input-type=module, импорт `./scripts/doc_contract.ts`; node v26.5.1 исполняет). Батарея ниже: зелёный rc 0, обе названные пары красные с дословными сообщениями, отсутствие evidence — не зелень. Проза :42/:86 честно фиксирует rc 2 у `--check` как не-приёмку (сверено живьём, дословно).
- **Э-3** (make_task для reviewer требует --task-file) — ЗАКРЫТ: :87 называет `--task-file` для reviewer; make_task.sh:119,128 поддерживает флаг; поведение подтверждено прогоном B Rev162 (без --task-file rc 1 «нет выданного задания»).
- **Класс Crit162 вызова 1** (приёмка mandatory-строки без исполняемой rc-команды на отрицательной паре) — остаётся закрытым: критерий 5 (:87) усилен (замороженный проектный контракт с тегом в git продукта, `.harness/registry/trace.tsv`, --task-file), NOT_RUN до merge #158 сохранён.

## Инварианты стандарта

И-1–И-4 дельтой не изменены. Живые опоры (сверка, не пере-суд): таблица на 932ee4a — 123 строки + заголовок, разбиение exists 18 / grep 89 / grep-none 6 / json 4 / goal 6 (awk по 4-й колонке TAB-формата — совпало); «Checker/table/evidence уже поставлены в 932ee4a» — diff 1e9b07ce..932ee4a = ровно 4 файла; «в своей секции», отслеживаемость носителя, пустая выборка, ЦЕЛЬ-маркер — красные пары P4/P6/P7/P9/P11/P22 Rev162.

## Сырые прогоны (одноразовый клон /tmp/dev-harness-verify/crit162v2/repo, HEAD=3f95c73c6f, статус чист)

```
$ bash scripts/pre_critic.sh --repo . contracts/162-standart-koda-mob.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 159 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
$ bash scripts/check_precision_gate.sh . contracts/162-standart-koda-mob.md
OK
rc=0
$ bash scripts/check_threat_model.sh . contracts/162-standart-koda-mob.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
rc=0
$ bash scripts/check_spec_ready.sh . contracts/162-standart-koda-mob.md   → OK, rc=0
$ bash scripts/check_provodka.sh . contracts/162-standart-koda-mob.md     → rc=0 (вывода нет; guard подключён)
$ bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight
rc=0
$ git rev-parse 3f95c73c6f^        # 21f1bd808fcb4100594a895f400c019f42219ef7 → zone-baseline.sha
$ bash scripts/check_zones.sh --incr zone-baseline.sha /tmp/dev-harness-verify/crit162v2/repo
incr: check_zones судит 21f1bd80..3f95c73c (1 коммит)
  ok   contracts/162-standart-koda-mob.md — предстоящее v2: ЗОНА-строки читаются из рабочего файла ветки …
… (все строки ok) …
замороженных контрактов: 158 · объявленных авторов: 5 · коммитов в диапазонах: 157 · проверено по зонам: 157
rc=0
```

Красные/обманные пары зоны architect (одноразовые копии; каждая мутация на отдельной копии):

```
# критерий 1, заявленная пара: вырезан раздел ## Док-приёмка
$ bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight
ОТКАЗ DOC: contract: нет раздела «## Док-приёмка»
rc=1
# обманный: "profile": "architecture" → "bogus" (форма doc-профиля — не резиновая)
$ bash scripts/check_document.sh … --preflight
ОТКАЗ DOC: schema: spec.profile не product|architecture: bogus
rc=1
# заявленный отказ загрузчика (не-приёмка) — дословно совпал
$ bash scripts/check_document.sh --root <P-green> --contract .harness/contracts/162-standart-koda-mob.md --check
NOT_IMPLEMENTED: нет frozen-спеки для .harness/contracts/162-standart-koda-mob.md
rc=2
# критерий 4 (замена): node-валидаторы 027 на синтетическом <P> с побайтовой копией контракта
импорт 6 именованных функций из ./scripts/doc_contract.ts → IMPORT_OK
PARSE_OK type=documentation profile=architecture; SCHEMA_ERR=none
полный пакет (5 компонентов / 3 связи / 3 решения / 3 отказа)  → rc=0
без failures.Пустая-выборка → ОТКАЗ DOC: package.failures не покрывает required: Пустая-выборка   rc=1
без links.Скрипт-к-таблице    → ОТКАЗ DOC: package.links не покрывает required: Скрипт-к-таблице    rc=1
evidence-файл отсутствует    → ENOENT docs/CODING-STANDARDS.evidence.json                        rc=1
```

## Счётные и механические утверждения — полным списком (сверено всё; 0 расхождений)

1. `check-structure.cjs:20` — живьём: строка 20 = `/^scripts\/[a-z0-9-]+\.(?:cjs|mjs|js|ts|sh|py)$/`.
2. «.tsv без записи → `outside allowed location/type`» — логика allowed() (mobileFiles → regex) + живой замер Rev162.
3. «Rev162: база rc 0, кандидат 932ee4a rc 1» — verdicts/review/contracts-162-impl-v1.md §Структура, дословно.
4. 932ee4a54352a8731fbb6570da30faae7406c10a — commit существует; зеркало origin/wip/162/implementer = 932ee4a5.
5. «Checker/table/evidence уже поставлены implementer в 932ee4a» — diff 1e9b07ce..932ee4a = 4 файла.
6. «123/123» и разбиение exists 18 / grep 89 / grep-none 6 / json 4 / goal 6 — awk по таблице на 932ee4a.
7. «--check … rc 2 NOT_IMPLEMENTED» — живьём, дословно.
8. Шесть именованных валидаторов doc_contract.ts — живой импорт исполняется.
9. «`--check` принимает лишь `contracts/(0+\d+)-…`» — doc_contract.ts:465, совпало.
10. `--task-file` у make_task — make_task.sh:119 (usage), :128 (разбор).
11. «plan.tsv содержит запись 162 (complior, до V-2)» — registry/plan.tsv:93.
12. «батареи 162 в fixtures/workshop_project/ нет; standarty_115 — другой продукт» — живьём: каталог 162-батареи отсутствует, standarty_115 существует.
13. «contracts/158-ekrannyj-nabor.md уже есть в этом checkout» — живьём.
14. ПЕРЕСЕЧЕНИЕ «143 владеет структурной политикой» — contracts/143-mob-ci-razdelenie.md:166 (mobile/structure-policy.json в ЗОНЕ implementer 143); «blanket-исключением всех e2e НЕ расширяется» (143:158) совместимо с «одной точной строкой» 162.
15. ИСТОЧНИК = 5 строк — в тексте; байты пинов неизменны с проверки Crit162b (CITATIONS OK count=5).
16. numstat `1<TAB>0<TAB>mobile/structure-policy.json` — стандартный вывод git; согласован с «ровно одной новой строкой» и reviewer-сверкой содержимого строки.
17. «С-2 (c102/c16/c17)» — .review/2026-11-05-62.md:89–95, состав С-2 совпал.
18. «этот отказ единственный новый» (раскладка quality) — Rev162 §Структура: в CI-раскладке отказ один, предсуществующие пути выносятся до lint.

## Советы (не блокируют)

- СОВЕТ contracts/162-standart-koda-mob.md:65 — «раскладка `quality` после выноса временных каталогов и пачек действующим workflow продукта» не называет шаг/строки mobile.yml; воспроизводимость сегодня держится прецедентом Rev162 (mobile.yml:410-432, затем :434) и scoped-повтором reviewer на новом SHA. В следующей редакции назвать точный шаг выноса.
- СОВЕТ contracts/162-standart-koda-mob.md:100 — перенос С-1 Rev162 (строка таблицы с пустым id молча выпадает, «122 из 122», P10) открыт и заявлен; И-1 требует идентификатор в каждом утверждении, но checker пустой id не отвергает. Закрыть при ближайшей редакции чекера/таблицы (естественно вместе с перепином С-3).

## Учёт и материализация

СУД-строка вызова 3/5 в HANDOFF на момент суда не материализована; санкция проверена судом по коммиту 0c53191aa и docs/owner/2026-11-09-arhitektura-i-poryadok-stancii.md:11 — дописку в HANDOFF делает оркестратор, вердикт строку несёт сам. Прежний accept (SHA 4dc0a5294) архивирован файлом contracts-162-v2-staryj-accept-4dc0a529.md (прецедент contracts-118-v3-staryj-accept-dd77d84e.md); имя версии v2 занимает настоящий вердикт — именно его прочитает freeze_contract.sh при заморозке 162/2. Красный `check:contract-frozen` в CI до заморозки — ожидаем, не предмет ремонта. Стабы к ветвям привязаны кодом (Н-39): контракт несёт инварианты и rc-команды; продуктовые стабы S1–S5/C0–C8/B — зона Rev162, процитированы, не пере-запускались (поверхность не изменена). Запись вердикта в основной чекаут выполнена пиннованной сессией оркестратора по выверенным байтам судьи (Н-85/А-122 запрещает судье прямую запись в чужой чекаут); контроль байтов — sha256 обеих сторон.

## Независимость

Автор OBJECT — architect (тир slow → glm, сессия архитектора). Судья — назначение roles.critic → apex-sol → glm; фактическая модель сессии zai/glm-5.3 совпадает с назначением. Совпадение семейства с автором отказа не даёт (контракт 166, слово владельца 2026-11-07); собственной работы судья не судил; с consultant/arbiter на предмете не совмещён (не вызывались). Окончательную сверку трейса делает оркестратор.

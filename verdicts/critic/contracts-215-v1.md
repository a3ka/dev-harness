accept
OBJECT=394bee9d0c76eacb2c45d1829a854e3edc559b48
СУД: репо=dev-harness; предмет=215; фаза=контракт; роль=critic; вызов=3 (исправительный; SANKCIJA по заданию); сессия=Crit215d; модель-факт=openai-codex/gpt-6.1-terra (контекст запуска); автор Architect215c — gpt-6.1-sol, другая сессия; предыдущий=archive/215/critic-v2-fail-db5c459b51

Предмет предъявлен на OBJECT. Предыдущий вызов остановился на К-01 без предметной проверки; поэтому по заданию проверены также незавершённые закрытие Б-1 вызова 1 и зависимый регресс. Новая дельта касается пересечений с замороженным 222/1 и сдаточного листа, а не нового проверяющего кода. Сравнение `git diff 6e3a6aa5eab4355db2942b8f4209e1a002c9fd85 394bee9d0c76eacb2c45d1829a854e3edc559b48` и предыдущие вердикты прочитаны. Разрешение третьего вызова сообщено заданием; фактическое дополнение записи HANDOFF и независимость для материализации проверяет оркестратор по трассе.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход: слово владельца и замер Critic190K08 в КОНТЕКСТ контракта
К-03: чисто — catalog.py rc 0 сверил frozen 129/2 104/2 166/2 186/2 198/1 и отдельно прочитан frozen 222/1
К-04: чисто — precision-gate rc 0 и catalog.py --zones rc 0 показывают оба пересечения 222
К-05: чисто — вход: семь пунктов приёмки contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md содержат команды и ожидаемые rc
К-06: чисто — вход: probe215.py различает rc 2 NOT_IMPLEMENTED и предметный rc 1
К-07: чисто — --model rc 0 KLETKI=14 KRASNYH=0 на реальном omp
К-08: чисто — --stabs rc 0 STABY=17 SVJAZI=21 ZHIVYH=0 и отдельно проверены M1 и M5
К-09: чисто — входы flagged cyber filter other error500 short429 near-token no-chain auto-off same-provider foreign-sibling
К-10: чисто — вход: trace_checks сравнивает полные TSV с настоящим model_change и selector из журнала провайдера
К-11: чисто — вход: ожидание trace берёт id из native записи сессии а не из квитанции
К-12: чисто — вход: настоящий omp и loopback стенд 129 без платного провайдера
К-13: н/п — предмет не вводит секреты или внешние credentials
К-14: чисто — --model rc 0 и отрицательные контроли other near-token no-chain auto-off same-provider зелёные
К-15: чисто — --catalog KLETKI=14 STABY=17 SVJAZI=21 и прогоны repo model stabs подтвердили счёт
К-16: чисто — вход: заявлен рисковый класс безопасности и граница модели угроз с ловцами
К-17: н/п — станционный предмет не меняет продуктовую модель архитектуры или CI-схемы

## Закрытие ранее открытых классов

Б-1 вызова 1 закрыт: `probe215.py:75–115` выбирает последнюю native-запись `model_change`, сверяет модель с фактическим selector из журнала провайдера и выводит ожидаемую denied-строку из её id. `probe215.py:287–295` в `--repo` запускает субъектный писатель, а не модель. Адресные стабы писателя M1-forged-id и M5-forged-target каждый дали `STABY=1 SVJAZI=1 ZHIVYH=0`, rc 0: подложные id и target пойманы. Соседняя независимая мутация `modelChangeId = undefined` также поймана trace. В честной модели тот же trace зелёный.

Блок К-01/К-04 вызова 2 закрыт: `bash scripts/check_precision_gate.sh "$PWD" contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md` напечатал `OK`, rc 0. `catalog.py --zones` rc 0 выдал среди прочих оба пути `.omp/agents/orchestrator.md — 222` и `roles/orchestrator.md — 222`; строки контракта уточняют регенерацию и дополнение блока 129 после приземления 222. Frozen 222/1 прочитан живьём: свобода модели из конфига, per-call назначение из запроса и сверка факта/session/OBJECT сохраняются. `git diff frozen/contracts/222/1 930152af85e2610fb4a83523e14340c9729755b4 -- roles/orchestrator.md .omp/agents/orchestrator.md` пуст, rc 0. Сдаточный лист и отдельный pre_critic теперь зелёные.

## Блоки

Нет доказанного блокирующего нарушения в проверенном объёме.

## Независимые мутации

Мутации выполнялись по одной во временной копии OBJECT с настоящим стендом, через `probe215.run`, без записи в контракт и без дополнения реестра стабов. Команды запускались как `TMPDIR="$PWD/.scratch-critic215" python3 .scratch-critic215/mutations.py` и `TMPDIR="$PWD/.scratch-critic215" python3 .scratch-critic215/terminal.py`; программы rc 0. В выводе первой `rc 0` на строке MUTATION означает, что мутант пойман проверкой, а не код запущенного omp.

Сырой предметный вывод:
```
MUTATION any-error-condition case other result 'ребёнок completed, ожидался failed: <output> { "marker": "M129", "model": "glm" } </output> <merge-summary> Isolation: no changes captured. </merge-summary>' rc 0
MUTATION token-boundary case near-token result 'ребёнок completed, ожидался failed: <output> { "marker": "M129", "model": "glm" } </output> <merge-summary> Isolation: no changes captured. </merge-summary>' rc 0
MUTATION remove-seen-target case exhausted result None rc 1
TERMINAL_MUTATION 'нет результата с маркером M129' caught True
```
Для missing-change-id сырой результат содержит `TRACE_paired_False rc=0`, фактический fallback `allowed`, ожидаемый `denied`, и такое же расхождение `TRACE_paired_True`; мутант пойман. Удаление только `seen.add(target)` не объявляется обходом: при повторном отказе запасной `seen.add(current)` всё равно помещает тот же selector в множество до проверки `seen.has(target)`, а исход и два запроса на проверенном входе не изменились. Для самостоятельной атаки на терминальность отключён сам предикат остановки: возвращается названный выше красный исход. Остальные изменения заменяли существующие операции проверки маркера, границы токена и получения id, а не добавляли искусственный запрет входа.

## Сырые выводы дверей

```
$ bash scripts/check_precision_gate.sh "$PWD" contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md
OK
rc=0

$ bash scripts/check_sdacha.sh "$PWD" contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md --run
СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=2)
rc=0

$ bash scripts/pre_critic.sh contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
rc=0

$ bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --repo .
KRASNO flagged: ребёнок failed (exit 1), ожидался completed
KRASNO cyber: ребёнок failed (exit 1), ожидался completed
KRASNO filter: ребёнок failed (exit 1), ожидался completed
KRASNO exhausted: CONTENT_FALLBACK_EXHAUSTED absent
KRASNO trace: ребёнок failed (exit 1), ожидался completed
KLETKI=14 KRASNYH=5
rc=1

$ bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --model
KLETKI=14 KRASNYH=0
rc=0

$ bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --stabs
STABY=17 SVJAZI=21 ZHIVYH=0
rc=0

$ bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --sosed
ok c1-zhivoj-perehod
ok c2-sosed-cooldown
ok c3-zdorovyj-primary
ok c4-validacija-soseda
ok c5-vse-ischerpany
ok c6-zapasnaja-validacija
cells=6 red=0
rc=0

$ bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --sintaksis
SINTAKSIS=0
rc=0

$ python3 fixtures/workshop_project/otkaz_po_soderzhaniyu_215/probe215.py --catalog
KLETKI=14 STABY=17 SVJAZI=21
rc=0
```

Поведенческие двери и стабы запущены во временном локальном клоне с единственным origin, установленным на исходный репозиторий. Клон использовал локальный Git object-alternate, поэтому это не доказательство независимости от всех локальных объектов. Единственный 40-символьный литерал в probe — синтетический OBJECT для bind, не Git-пин; база дельты `6e3a6aa5eab4355db2942b8f4209e1a002c9fd85` проверена как предок OBJECT, rc 0. Нагрузка при начале: `load average: 11.24, 17.08, 23.13`; средовых отказов в перечисленных итоговых прогонах нет. Отдельная первая попытка в клоне с несуществующим TMPDIR дала rc 2 `No such file or directory`; путь исправлен, результаты выше получены повтором.

## НЕ ЗАЩИЩАЕТ

Границы неизвестных форм upstream, недоступного fallback, доверенной JSONL-зоны и качества/независимости суждения остаются по контракту; ловцы — станционные логи и probe при смене omp, исходная ошибка и EXHAUSTED, а также независимые adversary/reviewer и протокол трассы. Реализация и её приёмка этим вердиктом не утверждаются.

## Советы

СОВЕТ contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md:78 — до реализации `--repo` на trace красен уже на неуспешном продолжении ребёнка, поэтому отдельно досягаемость проверки самой TSV-проекции показана моделью и адресными стабами, а не этим до-реализационным сообщением. При суде реализации полезно сохранить конкретный TRACE-вывод наряду с общей краснотой клетки.

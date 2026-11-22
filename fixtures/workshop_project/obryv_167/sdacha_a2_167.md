# A2 167 — перепривязка к текущей модели 140

База: `wip/int-140/orch-sh2c`, `34c50563eb0f2e4a66fcb18f58e7177649ce28e8`.
Рабочая копия:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tf15cb0f35/m`.
Ветка: `wip/167/architect-a2`. Push не выполняется.

## Существующее и граница

`krugov_suda` в `odin_agent_140/model/zamok_predmeta.sh:649–665`
сопоставляет RELEASE последнему открытому START держателя; только
`obryv_bez_verdikta` исключает попытку из числа кругов. ANCHORS теперь
содержит именно эту ветку, с прежним требованием ровно одного вхождения.
Остальные якоря классификации вердикта и синхронизации refs сохранены.
Дверь, модель, контракты и реестр CI не изменены.

Слово владельца 21.11 12:06 уже заменило отказ OBJECT_UZHE_SUZHEN
предупреждением. Точный перечень в этой базе находится в
`fixtures/workshop_project/odin_agent_140/osi.md:849–873`, а не в
`sdacha_140_v5.md` (там лишь ссылки на пониженные коды A2).

Удалены, НЕ переписаны на другой ожидаемый rc:

- самостоятельная `verdict_no_receipt`: её единственное наблюдение —
  прежний отказ повторного суда без RELEASE;
- отказ второго повтора внутри `interrupted`;
- отказ повтора после RELEASE внутри `verdict` и `reviewer_verdict`.

Это прежние обязательства `contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md:16,23`
и `contracts/140-odin-agent-na-predmet.md:65`, заменённые указанным словом
владельца. Классификация RELEASE у critic/reviewer сохранена, как и допуск
первого повтора после обрыва, START этого повтора, все отдельные проверки
аутентичности вердикта, недоступность remote и все merge-клетки.

Удалены стабы `ignore_all_starts` и `no_retry_limit`, наблюдавшиеся через
отменённый отказ; их старое выражение `any(.[]; . != "interrupted")`
также отсутствует в текущем счётчике. Предупреждение и его учёт уже судит
батарея 140 (в частности s06); здесь не добавляется дублирующая клетка.
`always_block` перепривязан к текущей функции: теперь он действительно
отказывает, а не возвращает истину предиката, который лишь предупреждает.
Все оставшиеся соответствия стаб → различающий вход находятся только в коде
`probe.py`/`merge_probe.py`, не в контракте. Исторические количества в
комментарии `registry/ci-steps.tsv:293` этим ремонтом не обновляются: реестр
вне разрешённой зоны.

## Сырой замер до

Первой пробой после переключения на базу была команда:
`bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo`.
Код возврата процесса: **1**.

```text
Traceback (most recent call last):
  File "/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tf15cb0f35/m/fixtures/workshop_project/obryv_167/probe.py", line 211, in <module>
    sys.exit(main())
             ^^^^^^
  File "/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tf15cb0f35/m/fixtures/workshop_project/obryv_167/probe.py", line 138, in main
    model(control)
  File "/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tf15cb0f35/m/fixtures/workshop_project/obryv_167/probe.py", line 42, in model
    raise RuntimeError('MODEL_ANCHOR_MISSING: ' + name)
RuntimeError: MODEL_ANCHOR_MISSING: subekt_suzhen_sudej_obj reduce (контракт 167)
MERGE separate ok
MERGE registry ok
MERGE overlap ok
MERGE registry_drop ok
MERGE partial ok
MERGE other_ref ok
```

После одной лишь перепривязки якоря `W --model` дал rc **1**:
`CHECKED 9 CASES; FAILURES 4`. Красны interrupted/verdict/verdict_no_receipt/
reviewer_verdict: дверь возвращала rc 0 с предупреждением OBJECT_UZHE_SUZHEN
вместо прежнего rc 1. Это подтверждает причину удаления именно отменённых
предъявлений, а не изменение ожидаемых кодов оставшихся проверок.

## Команды и rc после

`W = bash fixtures/workshop_project/obryv_167/red_obryv_167.sh`.
Все пробы после изменения выполнялись с `TMPDIR=/tmp` (вне дерева),
`PYTHONDONTWRITEBYTECODE=1`, последовательно; временные Git-миры удаляются
через TemporaryDirectory. `stancija_*` не запускались.

| Команда | rc | Наблюдение |
|---|---:|---|
| `W --repo` | 0 | CHECKED 8 CASES; FAILURES 0; все MERGE ok |
| `W --model` | 0 | CHECKED 8 CASES; FAILURES 0; все MERGE ok |
| `W --stabs` | 0 | все оставшиеся STAB caught; STAB_ZHIV нет |
| `bash -n scripts/zamok_predmeta.sh` | 0 | без вывода |
| `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` | 0 | MODEL_KLETKI 204 KRASNYH 0 |
| `bash fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh --model` | 0 | ZELENO: клеток 31, зелёных 31 |

Режим 140 взят из `registry/ci-steps.tsv:283`. Поиск литерала
`odin_agent_140/model` в fixtures обнаружил 167, историческое чтение модели
в produkt_140.py семьи 140 и комментарий в модели семьи 152. У 152 нет строки
в текущем CI-реестре; предъявлен её собственный контрольный режим --model,
не выданный за production-прогон. Список семей исчерпывает результаты поиска.

Сырой итог 167 --stabs (без переменных sha/времени диагностических деталей):

```text
CHECKED 8 CASES; FAILURES 0
MERGE separate ok
MERGE registry ok
MERGE overlap ok
MERGE registry_drop ok
MERGE partial ok
MERGE other_ref ok
```

Полные диагностические строки caught находятся в выводе выполненной команды;
они различают RELEASE-причину, отказ первого повтора, remote и merge-исходы,
а не сам факт изменения текста стаба.

## Процессная рефлексия

Строгий текстовый якорь правильно остановил контроль, но скрывал следующий
устаревший слой — отказ, уже заменённый предупреждением. Ремонт разделён:
сначала актуальная операция модели, затем удаление только отменённых
предъявлений с явным источником решения; оставшиеся стабы проверены живьём.
Общий NABLIUDENIA_ARCHITECT не изменён: он вне зоны этой пачки, а записи
А-NNN допускаются только отдельным коммитом main.

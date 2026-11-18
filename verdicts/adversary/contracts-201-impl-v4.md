accept
OBJECT=bdf592e098eaaba9f14616e86751deb1eac2847b
СУД: repo=dev-harness; предмет=201; фаза=реализация frozen/contracts/201/1 (done-дверь содержательной сверки); роль=adversary; вызов=4 (единственный дополнительный адресный по слову владельца ~14:05 UTC 2026-11-18 §5 батча №2, формулировка Cons201c §4; бюджет 1+1+№3 исчерпан: Adv201 FAIL, Adv201b FAIL, Adv201c FAIL dcb26084b4); модель-план=config/agent_models.json adversary → openai-codex/gpt-6.1-terra; сессия=Adv201d; модель-факт=openai-codex/gpt-6.1-terra allowed (`bash scripts/models_actual.sh --tsv --bind --session Adv201d | cut -f1-3` из /home/harness/dev-harness → `adversary openai-codex/gpt-6.1-terra allowed` ×2); SHA=bdf592e098eaaba9f14616e86751deb1eac2847b; предыдущие=verdicts/adversary/contracts-201-impl-v1.md (FAIL), Adv201b (текст не сохранён), contracts-201-impl-v3.md (FAIL, ref archive/201/adv201c-verdict-dcb26084b4), арбитраж verdicts/arbitration/201-granica-done-dveri-2.md; исключение=нет; следующий автоматический вызов не разрешён — при accept первый ПОЛНЫЙ reviewer на том же OBJECT.

# Предмет и метод

OBJECT `bdf592e098` сверен в собственном одноразовом SSH-клоне `/tmp/dev-harness-verify/Adv201d/repo` (ветка `wip/201/implementer`, HEAD == OBJECT). Дельта кандидата: `git diff ce2c54dd04 bdf592e098 --stat` → только `scripts/done_contract.sh` +76/−28 (заявленное совпадает). Атаки — одноразовые миры батареи (`dver_probe.build()/live()`, шим curl, тела `write_bytes` ВНЕ мира, TMPDIR изолирован для замера утечек), плюс доремонтный снимок `b4d46ec66b` для красного-до. Мутации и прогоны — только в клоне и скретч-каталогах рядом; тег done на настоящем репозитории не ставился; push не выполнялся.

# Базовые прогоны (заявленное автором — подтверждено сырым выводом)

```text
201 --repo .  → CELLS=62 STABS=0 FAILURES=0 + GREEN karta-jq-vyzovov: механизм _json_one_object × 5
201 --model   → CELLS=62 STABS=0 FAILURES=0
201 --stabs   → CELLS=62 STABS=27 FAILURES=0 (ZHIV-строк 0; новые
                s-b-nul-transport-terjaet-bajty / s-b-status-vne-slovarya-kak-otsutstvie /
                s-g-nul-transport-terjaet-bajty — все caught @ свои клетки)
187 --repo .  → CELLS=54 STABS=0 FAILURES=0
996 --matrix  → examined=111 mutants=76 mismatches=1 (базлайн Adv201c, тот же единственный skip-committed)
красное-до (дверь b4d46ec66b, батарея круга): CELLS=62 STABS=0 FAILURES=5 —
  RED b-vneshnij-nul-hvost / nul-v-znachenii / nul-v-klyuche (rc=0, ложный тег; warning line 539)
  RED b-vneshnij-status-chislo (rc=1, «ответ API без поля status»)
  RED g-arch-nul-hvost (rc=0, ложный тег; warning line 295)
  karta GREEN ×5 (механизм существовал до ремонта)
утечка /tmp/done-contract.* — 452 до и 452 после прогонов (совпадает с заявкой)
```

# Блок 1 Adv201c (NUL-байты до jq, оба маршрута) — ЗАКРЫТ

Собственные заглушки заимствованием build()/live() шима (curl rc 0, исходные байты тела; ожидания вне мира), сырой вывод:

```text
compare nul-tail   rc=1 tag=- 'done: влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON (jq rc=5))'
compare nul-value  rc=1 tag=- (та же причина)   # {"status":"beh\0ind"}
compare nul-key    rc=1 tag=- (та же причина)   # {"sta\0tus":"behind"}
compare nul+мусор  rc=1 tag=- (та же причина)   # {"status":"behind"}\0junk
check   nul-tail   rc=1 tag=- 'ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON (jq rc=5)): …'
check   nul-value  rc=1 tag=- (та же причина)   # completed→com\0pleted
check   nul-key    rc=1 tag=- (та же причина)   # check_runs→check\0_runs
check   nul+мусор  rc=1 tag=- (та же причина)
```

Ложного done нет ни в одном входе; транспорт `_json_one_object <var> <file>` байт-точен (jq читает временный файл напрямую, без `read -r -d ''`). Различающая клетка `b-vneshnij-nul-hvost`/`g-arch-nul-hvost` на доремонтной двери красна ровно этим (см. выше), на кандидате зелёна. Резолверный/профильный маршрут не сломан: клетки `g-profil-povrezhdyon-fajl`, `g-profil-dva-dokumenta`, `g-profil-bez-canonical-remote` зелёны (батарея). Позитивные контроли: честный behind/identical — rc 0 + `done/contracts/777/1`; BOM (`\xEF\xBB\xBF {"status":"identical"}`) и whitespace-обёртки — rc 0 + тег на ОБОИХ маршрутах (собственный прогон + клетки батареи).

# Блок 2 Adv201c (правдивая причина для status) — ЗАКРЫТ

```text
{"status":5}          rc=1 tag=- '…не проверена: неподдерживаемое значение status'
{"status":true}       rc=1 tag=- (та же фраза)
{"status":["behind"]} rc=1 tag=- (та же фраза)
{}                    rc=1 tag=- '…не проверена: ответ API без поля status'   # прежняя ветвь сохранена
```

Поле с вне-словарным значением больше не объявляется отсутствующим; различающая клетка `b-vneshnij-status-chislo` на доремонтной двери красна ложной фразой, на кандидате зелёна; стаб-двойник `s-b-status-vne-slovarya-kak-otsutstvie` caught.

# Fail-closed callsite на новом транспорте (скоуп-п.2) — чисто

Адресные заглушки вне батареи, оба маршрута, curl rc 0 если не сказано иное:

```text
curl rc=127 при положительном stdout  → compare: '…не проверена: curl rc=127'; check: 'ARCH_CI: … (curl rc=127)'; rc 1, тега нет
пустое тело                           → 'не разобран (пустой ввод: JSON-документов нет)', rc 1
усечённое '{"status":'                → 'не разобран (синтаксическая ошибка JSON (jq rc=5))', rc 1
два документа (второй {})             → 'не разобран (в ответе несколько JSON-документов…)', rc 1
'null'                                → 'не разобран (ответ не JSON-объект)', rc 1
```

Временные файлы НОВОГО транспорта: созданы `mktemp` (случайные имена, предсказуемых путей нет), зарегистрированы в `_DONE_TMP_FILES`, удалены EXIT-trap'ом на всех выходах — в изолированном TMPDIR после каждого прогона `done-contract.*`-файлов не остаётся; `/tmp/done-contract.*` на машине 452→452.

## СОВЕТ (не блокирует; поверхность НЕ менялась ремонтом)

`_a187_txt` (копия текста контракта, `done_contract.sh:238` доремонтной нумерации) создаётся голым `mktemp` ВНЕ `_new_done_tmp` и удаляется только по штатному пути (`rm -f` после блока); каждый `die` внутри 187а-блока оставляет один `/tmp/tmp.XXXXXXXXXX`. Наблюдение: в изолированном TMPDIR после каждого отказного check-runs-прогона (включая curl rc=127) остаётся ровно один `tmp.*`; compare-маршрут чист (там 187а вне скоупа, файл не создаётся). Код идентичен до/после ремонта (`b4d46ec66b:scripts/done_contract.sh:238` — тот же голый mktemp), ложного done и предсказуемых путей нет, заявленный автором замер (`/tmp/done-contract.*` 452→452) точен для измеряемых им файлов — поэтому по §Контроль (неизменённые поверхности не пересуживаются) совет, а не блок. Закрывающее свойство на усмотрение автора: регистрация `_a187_txt` в том же trap.

# Клетки, стабы, применённость (скоуп-п.3) — чисто

- Новые 5 клеток различают именно эти дефекты: на доремонтной двери красны РОВНО они (FAILURES=5, перечень выше), старые 57 зелёны; на кандидате 62/0.
- Новые 3 стаба применены (модель мутирует: `body.replace('\x00','')` до `json_one_object` — двойник `$(curl)`; catch-all «без поля» — двойник :559-565) и пойманы `--stabs` (caught-строки выше, ZHIV=0).
- Ни одна старая клетка не ослаблена: `git diff b4d46ec66b ce2c54dd04 -- …/dver_probe.py` — только добавления в CASES/STABS и новые ветки модели, старые кортежи ожиданий не менялись; все старые клетки зелёны с прежними фразами.
- Зависимый регресс (скоуп-п.4): 187 `CELLS=54 FAILURES=0`; 996 `examined=111 mismatches=1` — базлайн.

# Остаток контракта (контракт 192)

Строк остатка вида `НЕ ЗАЩИЩАЕТ … К-NN … ловец adversary` в замороженном тексте 201 нет: ОСТАТОК с ловцом adversary по К-NN — отсутствует, укусов не было. Прозаические ловцы-строки (семантическая полнота accept :100, классификация места :101, эра внешнего SHA :94) — неизменённая поверхность, по режиму скоупа не атакуются заново; клетки места (`b-legacy-*`) зелёны.

# Развилки

- Утечка `_a187_txt` (см. СОВЕТ) найдена при разрешённой проверке гигиены временных файлов, но код вне дельты ремонта: между «блок по чек-листу скоупа» и «совет по §Контроль неизменённых поверхностей» выбран совет — санкция владельца §5 ограничивает вызов «только эти блоки и зависимый регресс», а замороженные обязательства 201 гигиену /tmp не называют.
- Причина «(jq rc=5)» в разборе считается правдивой (класс + фактический rc инструмента); отдельного семейства фраз под системные rc не требуется (арбитраж 2, РЕШЕНИЕ 1).

# Среда

Клон судьи: `/tmp/dev-harness-verify/Adv201d/repo` (ssh-origin `ssh://git@github.com/a3ka/dev-harness.git`, ветка `wip/201/implementer`), pwd прогонов — корень клона, HEAD=`bdf592e098eaaba9f14616e86751deb1eac2847b`; доремонтный снимок `../pre` (git archive `b4d46ec66b`) — только для красного-до. Скретч-миры одноразовые, вне коммита. Вердикт — единственный коммит author=committer=adversary; push не выполнялся; тег done на настоящем репозитории не ставился.

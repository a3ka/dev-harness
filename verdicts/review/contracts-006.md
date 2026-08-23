FAIL

# Ревьюер-круг: контракт 006 — финальный гейт

Проверен HEAD `eda8b578bfc3b7ece6f637e55f736cdb48be011c` в отдельном клоне `/tmp/review-006`; все воспроизведения выполнялись там. Единственная блокирующая находка ниже достаточна для `FAIL`. Чужой код и приёмка не правились.

## Находка

1. **[РЕГЛАМЕНТ / заморозка приёмки — FAIL]** Замороженный контракт не менялся, но замороженные приёмочные тесты менялись *после* `frozen/contracts/006/1`, что прямо нарушает критерий данного финального гейта «замороженный контракт/тесты НЕ правлены после заморозки».

   Реф `frozen/contracts/006/1` указывает на `4775f8cc9210a25044574128c5c411b37d264a60`. Сравнение текста контракта дало `RC=0`, а сравнение приёмки — `RC=1`:

   ```text
   $ git diff --exit-code frozen/contracts/006/1 HEAD -- contracts/006-scoped-izolirovannyj-gejt.md; rc=$?; printf 'RC=%s\n' "$rc"
   RC=0

   $ git diff --quiet frozen/contracts/006/1 HEAD -- scripts/check_scope_select.sh scripts/check_scoped_run.sh fixtures/check_scope_select fixtures/check_scoped_run; rc=$?; printf 'RC=%s\n' "$rc"
   RC=1
   ```

   Именованные послезаморозочные изменения приёмки включают `1aa64d1` (`scripts/check_scope_select.sh` и семь новых `fixtures/check_scope_select/case_vetv_{u,f,h,c,ch,sh,shch}_*.sh`), а также ранее в диапазоне — `ac750a2`, `ebd455c3`, `99f01c6`. В частности, независимый журнал дал:

   ```text
   $ git log --format='%H %an %s' frozen/contracts/006/1..HEAD -- contracts/006-scoped-izolirovannyj-gejt.md scripts/check_scope_select.sh scripts/check_scoped_run.sh fixtures/check_scope_select fixtures/check_scoped_run
   1aa64d16929d8b195aa072a1d9bfdd155dec3f1e architect 006 арбитраж (ea138fb): 7 приёмочных ветвей у–щ check_scope_select + 7 фикстур ...
   ac750a2f21729420b6b4568d1378db835e31d5a4 architect 006 круг 2 пробы: ветви check_scope_select п ...
   ebd455c3ff9f5af0596f5e43463e3c7a4f62585e architect 006 адверсарий-пробы: ветви check_scope_select м/н/о ...
   99f01c694bb7136073559ca5b687e10729201a02 architect 006 4а: фикс фикстур l/case ...
   RC=0
   ```

   Это не замечание о качестве новых ветвей: они поведенчески зелёные. Это отказ по области нормы: финальный ревьюер не может принять работу, когда тест, по которому она принимается, изменён после зафиксированной версии без новой заморозки.

## Неблокирующие проверки, выполненные до решения

### Область и авторы

`bash scripts/check_zones.sh` на изолированном HEAD завершился `RC=0`; итог его сырого вывода:

```text
замороженных контрактов: 6 · объявленных авторов: 2 · коммитов в диапазонах: 170 · проверено по зонам: 113
RC=0
```

Точечная независимая проверка четырёх названных коммитов подтвердила атомарные пути и имена:

```text
COMMIT=85ce6f7ce879ffad92d3deac08713bd2dc309434
AUTHOR=implementer <implementer@dev-harness.local>
M	scripts/scope_select.sh
RC=0

COMMIT=1aa64d16929d8b195aa072a1d9bfdd155dec3f1e
AUTHOR=architect <architect@dev-harness.local>
A	fixtures/check_scope_select/case_vetv_c_dyncfg.sh
A	fixtures/check_scope_select/case_vetv_ch_literal.sh
A	fixtures/check_scope_select/case_vetv_f_symlink.sh
A	fixtures/check_scope_select/case_vetv_h_exec.sh
A	fixtures/check_scope_select/case_vetv_sh_comment.sh
A	fixtures/check_scope_select/case_vetv_shch_pozitiv.sh
A	fixtures/check_scope_select/case_vetv_u_midline.sh
M	scripts/check_scope_select.sh
RC=0

COMMIT=21568bc8d307a4875d66d508238c8ee72fa3f183
AUTHOR=architect <architect@dev-harness.local>
M	NABLIUDENIA.md
RC=0

COMMIT=eda8b578bfc3b7ece6f637e55f736cdb48be011c
AUTHOR=adversary <adversary@dev-harness.local>
A	verdicts/adversary/contracts-006-scoped-gate-v4.md
RC=0
```

### Поведенческие прогоны

Перед каждым из следующих прогонов был выполнен `pkill -9 -f 'verify_antiplacebo|check_scop'`; целевой корень — изолированный `/tmp/review-006`, не рабочее дерево предмета.

```text
$ bash scripts/check_scope_select.sh "$PWD"
  ok   (а) неизвестный ключ отвергнут
  ok   (б) пустой --scope отвергнут
  ok   (в) неизвестный case отвергнут
  ok   (г) доки-only → needs-full код 2, маркер SCOPED:
  ok   (д) нерезолвимая база и не-git дерево → 2
  ok   (е) правка b → scoped, ровно ключ b
  ok   (ж) правка библиотеки → full
  ok   (з) add/delete/rename/смена-роли → full
  ok   (и) case-уровень выбирает ровно свой case
  ok   (к) scoped и needs-full помечены SCOPED: (неавторитетность — у потребителя)
  ok   (л) git-отсутствие (PATH без git) → код 2 + SCOPED:
  ok   (м) правка барьера, сорсимого другим барьером → full
  ok   (н) динамический source → full
  ok   (о) не-барьер как --scope ключ → код 1
  ok   (п) смена шапки/кода барьера → full
  ok   (р) source через переменную → full
  ok   (т) traversal в case → код 1
  ok   (у) mid-line source (после ;) → full
  ok   (ф) source через симлинк → full
  ok   (х) exec-ребро (bash b.sh) → full
  ok   (ц) видимый динамический source → full
  ok   (ч) имя цели в строке-литерале → full
  ok   (ш) имя цели только в полном комментарии → scoped
  ok   (щ) правка независимого барьера → scoped ровно он
check_scope_select: ветви «all» зелены
RC=0

$ bash scripts/verify_antiplacebo.sh "$PWD" --scope check_scope_select
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_scope_select/case_vetv_c_dyncfg.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «невычислимая цель»
  ok   check_scope_select/case_vetv_ch_literal.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «по имени»
  ok   check_scope_select/case_vetv_f_symlink.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «через ссылку»
  ok   check_scope_select/case_vetv_h_exec.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «выборка полная»
  ok   check_scope_select/case_vetv_sh_comment.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вычет комментариев»
  ok   check_scope_select/case_vetv_shch_pozitiv.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «позитив жив»
  ok   check_scope_select/case_vetv_u_midline.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «полной»

барьеров: 1 · фикстур: 24 · предъявлено красным повторным прогоном: 24
RC=0

$ git ls-files 'fixtures/check_scope_select/case_*.sh' | wc -l
24
RC=0

$ bash scripts/check_scoped_run.sh
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)
check_scoped_run: ветви «all» зелены
RC=0

$ bash scripts/verify_ci_parity.sh
workflow-команд: 19 · скриптов в приёмке: 31 · объявленных исключений: 12 · расхождений: 0
RC=0

$ bash scripts/check_ci_gate.sh /home/aka/Documents/dev-harness 21568bc
  ok   CI зелёный: проверок 1, все success, по 21568bc8d307 (a3ka/dev-harness)
RC=0
```

### Приёмка против реализации и решение арбитра

Семь новых фикстур не повторяют реализацию: каждая сначала подставляет честный стаб и требует зелёный барьер, затем подставляет противоположный обманный результат и требует названную причину. Повторный `verify_antiplacebo` выше предъявил их все красными; независимый подсчёт `git ls-files … | wc -l` дал 24, не повторяя счётчик раннера.

Сверка `scripts/scope_select.sh` с `verdicts/arbitration/source-porog-scoped.md` установила: N1 строит `k.sh` плюс basename симлинков, канонизированных `readlink -f` к `scripts/k.sh`, откатывается в full на непрозрачном/внешнем симлинке и сканирует `scripts/*.sh` и `fixtures/*/*`, исключая саму цель и её fixtures, после вычета только полнострочных комментариев. N2 ищет `source`/`.` в начале и после `;`, `&&`, `||`, `|`, `&`, `(`, `{`, backtick; нелитеральный basename вызывает full. Это соответствует обязательному минимуму решения `ea138fb` в наблюдаемой реализации. Подтверждающий adversary-вердикт v4 существует на HEAD и начинается `accept`; внешний CI для `21568bc` отдельно подтверждён командой выше.

## Вердикт

Поведение, области арбитраж-фиксов, красные предъявления и N1/N2 проверены; однако найти послезаморозочное изменение приёмочных тестов означает, что критерий заморозки не выполнен. До санкционированной новой версии/заморозки контракта 006 предмет **не готов для `done/contracts/006/1`**.

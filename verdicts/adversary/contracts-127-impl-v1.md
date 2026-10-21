FAIL
OBJECT=b3aa41d2813411ee436291b95a89f88477b02c9d
Класс: КОДОВЫЙ

Найден обход красной батареи: скрытая табличная константа вместо подсчёта `app/schemas/openapi.json` проходит все 13 миров. В одноразовом клоне `cheat` обе функции `countOperations` были заменены на:

```js
const countOperations = (doc) => doc.paths['/partner/v1/onboarding-applications']
  ? Number('23' + '3')
  : doc.paths['/v1/evb/{evb_id}/issuance']
    ? Number('16' + '3')
    : Number('16' + '2');
```

Это не считает пары путь×метод с `operationId`: оно распознаёт три заранее известные формы миров и возвращает зашитые числа. Литералы разделены, поэтому требуемый grep по `163|233` их не видит. Несмотря на нарушение инварианта 1, прогон

```text
HTTP_CHISLO_127_BACK=/tmp/dev-harness-verify/Adv127/back \
  bash fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh \
  --candidate /tmp/dev-harness-verify/Adv127/cheat
```

завершился rc 0: `ИТОГ 127 (кандидат): миров 13, сошлось 13, расхождений 0`.

Следовательно, батарея не ловит обязательный класс «литерал спрятан в вычисляемом выражении», прямо названный в задании. Указанный в контракте остаточный риск R-2 не устраняет противоречие: предмет требует, чтобы число бралось из производного файла, а проверка принимает реализацию, которая этого не делает. Нужна правка батареи/приёмочного барьера автором; предмет и исходные T/S я не правил.

Прогоны:
- честная модель: rc 0, `миров 13, сошлось 13, расхождений 0`;
- штатный кандидат OBJECT: rc 0, `миров 13, сошлось 13, расхождений 0`;
- штатные lane-команды: `node --test tests/contract/http.test.js` и `node tests/tools/smoke-http.js` — rc 0 (14/14, затем `smoke:http — пройден`);
- штатная батарея стабов: rc 0, `стабов 12, поймано 12, непойманных 0`; она ловит literal-233, счёт из operation-index, счёт через загрузчик, удаление отдельных сверок и нейтрализации;
- стаб недоступного инструмента: `execFileSync('definitely-not-on-path-127')` с проглоченным отказом — rc 1, единственное расхождение `T:wgen-check:ozhidalsya-red-fakt-green`; ловец gen-contracts работает;
- запиненный старый продукт: rc 1, `миров 13, сошлось 10, расхождений 3`;
- `--world net-takogo` — rc 2; `HTTP_CHISLO_127_BACK=/nonexistent ... --model` — rc 2 `NOT_IMPLEMENTED`;
- frozen contract и fixture относительно `frozen/contracts/127/1`: оба `git diff --quiet` rc 0; дифф OBJECT ограничен `tests/contract/http.test.js` и `tests/tools/smoke-http.js` (19+/5-), против `ARCHITECTURE.md` и `CODING-STANDARDS.md` несоответствий не найдено.

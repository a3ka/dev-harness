FAIL

# Ревью контракта 027 — круг к4 (проверка фиксов F8 и класса F5/F9)

Предмет круга: фиксы `9f5a952` (`freeze_contract.sh`, блокер F8) и `2149547`
(`doc_contract.ts`, класс F5/F9 по арбитражу `c1b747e`), land `022ea2b`.
Судимый HEAD — `022ea2bf532a05cd459b0bb749d4236d54584cda`; клон собственной
рукой — `/tmp/dev-harness-verify/rev-027/repo2` (свежий `git clone`). Все rc
получены в этом клоне.

| файл | блоб на HEAD | было (к3) |
|---|---|---|
| `scripts/freeze_contract.sh` | `eb1833adf4` | `67f302e971` |
| `scripts/doc_contract.ts` | `7d55d1210f` | `4e11da682a` |
| `scripts/check_contract_ready.sh` | `e8b281aaff` | без изменений |

Замороженный текст не тронут: `git diff frozen/contracts/027/3 HEAD --
contracts/027-doc-priemka.md` → rc=0, 0 байт. Фиксы лежат в ЗОНА implementer,
барьеры и `_doc027.py` не тронуты.

## Матрица предъявления (согласована с арбитражем c1b747e), `probe_round4.py`

```
[CTRL conform   ] --type rc=0 stderr=ПУСТОЙ  | ready rc=0 | freeze rc=0 | теги: frozen/contracts/001/1
[CODE no-section] --type rc=1 stderr=непустой | ready rc=0 | freeze rc=0 | теги: frozen/contracts/001/1
[TYPO type      ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[G    array     ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[H    string    ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[D    good+bad  ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[E    bad+good  ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[F    2 sections] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[A    split/empty] --type rc=0 stderr=ПУСТОЙ | ready rc=1 | freeze rc=0 | теги: frozen/contracts/001/1
```

## ЗАКРЫТО: класс F5/F9 (фикс `2149547`)

`TYPO`, `G`, `H` дают ровно профиль, названный арбитражем: `--type` rc=2 с
непустым stderr и именованной причиной («fenced json-блок — type="documentaton"
(требуется "documentation")», «fenced json-блок не является объектом (требуется
объект с полем type)»), ready rc=1 с той же причиной, freeze rc=1 без тега.
`D`/`E`/`F` сохранили поведение к3 («неоднозначный блок: fenced-блоков … = 2»,
«разделов … = 2»). Третий, латентный экземпляр класса (опечатка в `type`),
названный арбитром, закрыт вместе с остальными — измерен мной, не пересказан.

## ЗАКРЫТО: F8 (фикс `9f5a952`)

`CODE` — кодовый контракт без раздела «## Док-приёмка» — замораживается:
freeze rc=0, тег `frozen/contracts/001/1` записан (в к3 было rc=1 при пустых
stdout/stderr). Мера самого проекта на том же клоне:
`bash scripts/verify_antiplacebo.sh --scope check_document render_document
freeze_contract check_check_contract_ready` → **rc=0**,
`барьеров: 4 · фикстур: 22 · предъявлено красным повторным прогоном: 22`
(в к3 было rc=1, 8/22, 14 расхождений). Приёмочная строка контракта по
antiplacebo выполняется.

## F10 — НОВЫЙ БЛОКЕР. Фикс F8 вернул последствие F1: валидный doc-контракт замораживается БЕЗ doc-preflight

Обязательство (§Freeze, charter, zones и проводка): «Freeze повторяет тот же
preflight ДО записи тега, даже при accept критика. Отказ не меняет refs».

Точный фрагмент результата (`scripts/freeze_contract.sh`, блоб `eb1833adf4`):

```
269  _doc_type_rc=1
273    _doc_type_out="$(cd "$ROOT" && node "$SELF_DIR/doc_contract.ts" --type "$_doc_type_tmp" 2>&1)" || _doc_type_rc=$?
274    _doc_type_rc="${_doc_type_rc:-0}"
```

Переменная инициализирована ЕДИНИЦЕЙ, а присваивание реального кода стоит в
`|| `-ветви: при УСПЕХЕ CLI (`--type` rc=0, то есть валидный doc-контракт)
ветвь не исполняется, и `_doc_type_rc` остаётся `1`. `case` (`:275-291`) уходит
в ветвь `1) : ;;` — «не doc-контракт, пропустить», и doc-preflight на freeze не
запускается никогда для валидных doc-контрактов. Это зеркальная форма той же
ловушки, от которой избавлялся фикс F8; прежний комментарий этого же файла
называл её дословно («`var=… || rc=$?`, который на успехе оставлял старое
значение»).

Мои измерения:

1. `probe_round4.py`, строка `A`: doc-контракт с пустыми `required.sections` —
   ready отказывает именованно (`ОТКАЗ doc-preflight: ОТКАЗ DOC: schema:
   product: spec.required.sections пуст`), а **freeze возвращает rc=0 и пишет
   тег** `frozen/contracts/001/1`. В к3 тот же вход давал freeze rc=1 без тега.
2. Строка `CTRL`: в выводе freeze отсутствует строка
   `ok   doc-preflight: заморозка … прошла проверку`, которая печаталась в к2/к3
   — подтверждение, что ветвь preflight не исполняется и на конформном входе.
3. Мера самого проекта, тот же клон:
   `bash fixtures/freeze_contract/red_doc_lifecycle.sh` → **rc=1**:
   `ОТКАЗ DOC-lifecycle/freeze-preflight: поведение rc=0, требуется 1;
   ok заморожено: contracts/001-yozh.md → frozen/contracts/001/1 («Ёж»)`.
   Как следствие `npm run check:document` → **rc=1**. Обе приёмочные строки
   контракта («перечисленные прямые команды rc=0» и `npm run check:document
   rc=0`) на этом HEAD НЕ выполняются.

Класс совпадает с F1 круга к1 (doc-preflight обходится на freeze), причина —
иная строка кода, внесена судимой дельтой `9f5a952`. По рамке арбитража
(`c1b747e`) повтор класса после реструктуризации — законный FAIL без нового
арбитража.

## Собственные прогоны (сырые коды, мой клон)

```
rc=0 fixtures/check_check_contract_ready/red_doc_obligations.sh
rc=0 fixtures/check_check_contract_ready/red_doc_product.sh
rc=0 fixtures/check_check_contract_ready/red_doc_architecture.sh
rc=0 fixtures/check_check_contract_ready/red_doc_evidence.sh
rc=0 fixtures/check_check_contract_ready/red_doc_assertions.sh
rc=0 fixtures/check_check_contract_ready/red_doc_status_render.sh
rc=0 fixtures/check_check_contract_ready/red_doc_oracle.sh
rc=1 fixtures/freeze_contract/red_doc_lifecycle.sh          ← F10
rc=0 python3 fixtures/check_check_contract_ready/_doc027.py regressions
rc=1 npm run check:document                                  ← F10
rc=0 npm run check:contract-ready
rc=0 npm run check:ci-parity
rc=0 scoped antiplacebo (4 барьера, 22 фикстуры, красным 22)
rc=0 git diff frozen/contracts/027/3 HEAD -- contracts/027-doc-priemka.md (0 байт)
```

Замечание о пределах мер: на этом HEAD antiplacebo зелёный, а батарея 027
красная — зеркально к3, где было наоборот. Ни одна из двух мер поодиночке не
покрывает обе стороны doc-ветви freeze; обе строки приёмки обязаны быть
зелёными одновременно.

## Перенесённые находки (не блокеры, состояние не изменилось)

- **F2** — «нечем проверить» в `resolveGitSource` (`doc_contract.ts:510-512`)
  даёт rc=1 с именем «дрейфует» вместо rc=2.
- **F3** — residual argv назван только в комментарии кода; адресат (ревьюер при
  freeze) его не получает.
- **F4** — residual по регистру OID без носителя; комментарий объявляет
  «40/64 hex» при lower-case-регулярке.
- **F6** — ветвь `mktemp` в freeze (`:268-271`) пропустила бы doc-гейт при
  отказе `mktemp`; недостижима (раньше падает `:169`).

## Граница вердикта

F8 и класс F5/F9 закрыты по собственным измерениям; F10 — дефект, внесённый
судимой дельтой и предъявленный, помимо моего контрпримера, барьером самого
проекта. Чужой код не правил. Полный CI, содержательный суд конкретного
doc-пакета и предметы 020/026/028 этим вердиктом не закрываются.

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта;
контракт несёт инварианты + rc-команды».

Н-101: блоб этого текста записан `git hash-object -w` и добавлен в индекс
`update-index --cacheinfo`; identity коммита задана явно как `reviewer`.
Н-73: использована нейтральная терминология контрольных экспериментов и
контрпримеров.

accept

# Ревью контракта 027 — круг к5 (проверка фикса F10; механизм doc-приёмки принят)

Предмет круга: фикс `b9976de` (`scripts/freeze_contract.sh`, единственный файл)
против блокера F10 вердикта `verdicts/review/contracts-027-k4.md` (`a55cce7`).
Судимый HEAD — `b9976de9f00f7eee52a9a3a55e2ad8e82b9d655b`; клон собственной
рукой — `/tmp/dev-harness-verify/rev-027/repo2` (свежий `git clone`). Все rc
получены в этом клоне.

Привязка блобами (Н-101; вердикт связан с ЭТИМИ блобами, новая редакция
принятия не наследует):

| файл | блоб на HEAD |
|---|---|
| `contracts/027-doc-priemka.md` | `5d3f9f31aa` (тег `frozen/contracts/027/3`) |
| `scripts/doc_contract.ts` | `7d55d1210f` |
| `scripts/check_document.ts` | `cbe4282cb4` |
| `scripts/render_document.ts` | `f4b657ca49` |
| `scripts/check_contract_ready.sh` | `e8b281aaff` |
| `scripts/freeze_contract.sh` | `e731102345` (было `eb1833adf4`) |

Замороженный текст не тронут: `git diff frozen/contracts/027/3 HEAD --
contracts/027-doc-priemka.md` → rc=0, 0 байт. Фикс лежит в ЗОНА implementer;
барьеры, фикстуры и каркас `_doc027.py` не тронуты ни одним коммитом реализации
за все пять кругов — мера, по которой судится реализация, автором реализации не
правилась.

## F10 — ЗАКРЫТ

`freeze_contract.sh:240,269` инициализируют `_doc_type_rc` НУЛЁМ, поэтому при
успехе `--type` (валидный doc-контракт) `case` уходит в ветвь `0)` и
doc-preflight исполняется. Предъявление на моей матрице (`probe_round4.py`,
игрушка та же, что в фикстуре `lifecycle`):

```
[CTRL conform   ] --type rc=0 stderr=ПУСТОЙ  | ready rc=0 | freeze rc=0 | теги: frozen/contracts/001/1
[CODE no-section] --type rc=1 stderr=непустой | ready rc=0 | freeze rc=0 | теги: frozen/contracts/001/1
[TYPO type      ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[G    array     ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[H    string    ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[D    good+bad  ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[E    bad+good  ] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[F    2 sections] --type rc=2 stderr=непустой | ready rc=1 | freeze rc=1 | теги: (нет)
[A    split/empty] --type rc=0 stderr=ПУСТОЙ | ready rc=1 | freeze rc=1 | теги: (нет)
```

Ключевые строки против к4: `A` (doc-контракт с пустыми `required.sections`)
теперь даёт freeze **rc=1** с причиной `ОТКАЗ: doc-preflight: ОТКАЗ DOC:
schema: product: spec.required.sections пуст` и БЕЗ тега (в к4 было rc=0 с
записью тега); `CTRL` снова печатает
`ok doc-preflight: заморозка contracts/001-yozh.md прошла проверку` перед
записью тега — ветвь preflight исполняется, а не пропускается. `CODE` (кодовый
контракт без раздела) по-прежнему замораживается — фикс F8 не регрессировал.
Матрица совпадает со строка-в-строку с профилем, согласованным арбитражем
`c1b747e`.

## Собственные прогоны (сырые коды, мой клон)

```
rc=0 fixtures/check_check_contract_ready/red_doc_obligations.sh
rc=0 fixtures/check_check_contract_ready/red_doc_product.sh
rc=0 fixtures/check_check_contract_ready/red_doc_architecture.sh
rc=0 fixtures/check_check_contract_ready/red_doc_evidence.sh
rc=0 fixtures/check_check_contract_ready/red_doc_assertions.sh
rc=0 fixtures/check_check_contract_ready/red_doc_status_render.sh
rc=0 fixtures/check_check_contract_ready/red_doc_oracle.sh
rc=0 fixtures/freeze_contract/red_doc_lifecycle.sh
rc=0 python3 fixtures/check_check_contract_ready/_doc027.py regressions
rc=0 npm run check:document
rc=0 npm run check:contract-ready
rc=0 npm run check:ci-parity
rc=0 scoped antiplacebo (барьеров 4 · фикстур 22 · красным повторным прогоном 22)
rc=0 git diff frozen/contracts/027/3 HEAD -- contracts/027-doc-priemka.md (0 байт)
```

Все приёмочные строки контракта выполняются ОДНОВРЕМЕННО — того совпадения не
было ни в к3 (antiplacebo красный, батарея зелёная), ни в к4 (наоборот).

## История кругов и что каждый закрыл

| круг | вердикт | блокер | закрыт фиксом |
|---|---|---|---|
| к1 `c5d5c84` | FAIL | F1 — тип определялся построчным `grep`, doc-контракт замораживался без preflight | `d47b0a5` |
| к2 `8bd4475` | FAIL | F5 — неоднозначный doc-контракт (2 блока / 2 раздела) замораживался | `b4f40f3` |
| к3 `89d226d` | FAIL | F8 — `set -e` рвал freeze кодовых контрактов (14/22 фикстур без положительного контроля); F9 — класс F5 | `9f5a952`, `2149547` (арбитраж `c1b747e`) |
| к4 `a55cce7` | FAIL | F10 — `_doc_type_rc=1` + `\|\| rc=$?`: doc-preflight на freeze не запускался | `b9976de` |
| к5 (этот) | **accept** | — | — |

## Остаточные риски, названные и НЕ закрытые этим принятием

Ни один не блокирует, но каждый наследуется тем, что построят поверх:

- **F2** — `resolveGitSource` (`doc_contract.ts:510-512`) отображает «нечем
  проверить» в rc=1 с именем «дрейфует» вместо rc=2 (fail-closed, ветвь на
  Linux недостижима).
- **F3** — residual по argv назван только в комментарии `doc_contract.ts`;
  адресат (ревьюер при freeze doc-контракта) его не получает: ни
  `roles/reviewer.md`, ни §Мандат контракта, ни вывод preflight про
  «судить argv как код» не говорят.
- **F4** — долг текста по написанию OID (канонический lower-case) не имеет
  носителя в дереве; комментарий `doc_contract.ts:29-32` объявляет класс
  «40/64 hex» при lower-case-регулярке.
- **F6** — ветвь `mktemp` в freeze (`:268-271`) пропустила бы doc-гейт при
  отказе `mktemp`; недостижима, потому что раньше падает `:169`.
- **Покрытие:** регресс к3 поймал только `verify_antiplacebo`, регресс к4 —
  только батарея 027. Ни одна из двух мер поодиночке не покрывает обе стороны
  doc-ветви freeze; обе строки приёмки обязаны проверяться вместе.

## Что этот вердикт НЕ означает

Принят МЕХАНИЗМ doc-приёмки относительно замороженного текста 027 и
перечисленных блобов. Это не содержательный суд какого-либо doc-ПАКЕТА
(принимаемых документов ещё нет), не полный CI (мера оркестратора; мои прогоны
scoped), не закрытие предметов 020/026/028 и не подтверждение церемонии Н-98.
Реестр документов и внедрение в проект остаются следующими предметами, как и
объявлено §Демаркацией контракта.

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта;
контракт несёт инварианты + rc-команды».

Н-101: блоб этого текста записан `git hash-object -w` и добавлен в индекс
`update-index --cacheinfo`; identity коммита задана явно как `reviewer`.
Н-73: использована нейтральная терминология контрольных экспериментов и
контрпримеров.

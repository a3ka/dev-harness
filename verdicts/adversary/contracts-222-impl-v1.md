FAIL
OBJECT=465b42261ed6b1964da3121cfee50ba43349e85b
СУД: репо=dev-harness; предмет=222; фаза=реализация; роль=adversary; вызов=1; сессия=c907157c/Adv222; модель-факт=openai-codex/gpt-6.1-terra; автор Impl222 — implementer (MiniMax); класс=рисковый

## Блоки

### БЛОКИРУЕТ К-08 — denied при явном назначении не различается батареями

ОБЯЗАТЕЛЬСТВО: contracts/222-sudja-ljubaja-model.md, И2 и «Предмет»: denied всегда сверяется с объявленным fallback тира, в том числе при per-call назначении. Источник входа: явно предусмотренные per-call назначение и autoFallback, пять полей трассы, все значения и привязки из тестового конформного конфига. Источник ошибочного механизма: замена существующей проверки `scripts/check_sud_model.sh` в ветви denied, а не изменение оракула. В отдельном клоне заменена единственная строка:

```bash
# до
if [ -z "$fbexpected" ] || ! sud_same_model "$m" "$fbexpected"; then
# после: дефект пропускает только denied с переданным назначением
if [ -z "$assigned" ] && { [ -z "$fbexpected" ] || ! sud_same_model "$m" "$fbexpected"; }; then
```

СОСТОЯНИЕ: primary `primary-vendor/base-1`, fallback `reserve-vendor/reserve-2`, отдельно объявленная `other-vendor/other-family-9`; `--assigned-model other-vendor/other-family-9`, в трассе critic / эта же модель / denied / Judge222_A / `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`. Честная дверь rc 1, `ОТКАЗ: фолбэк вне списка тира`; мутант rc 0, `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется`. Следовательно, изменение не эквивалентно: отвергнутый честной реализацией не-фолбэк становится подтверждённым свидетельством.

НАБЛЮДЕНИЕ: на мутанте, по очереди, `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --repo .` rc 0 (`SUBJEKT 222: KLETKI 76 KRASNYH 0`), `--model` rc 0 (`MODEL 222: KLETKI 76 KRASNYH 0`), `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --repo .` rc 0 (`REPO_CELLS=12 FAILURES=0`); все шесть `fixtures/zashchita_main_104/red_*.sh` rc 0, `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo` rc 0 (19 ZELENO). Отдельная позитивная проверка честной двери и полноценный `--model` зелёны. Причина: в 222 есть per-call allowed и denied без per-call, но нет комбинации denied + per-call с чужим fallback; сосед 198 не передаёт новый аргумент. Закрывающее свойство: различать при явном назначении корректный fallback и другую объявленную модель для denied; не заменять проверку назначением.

### БЛОКИРУЕТ К-09 — явно пустое назначение молча превращается в отсутствие аргумента

ОБЯЗАТЕЛЬСТВО: contracts/222-sudja-ljubaja-model.md «Инварианты и граница входов»: selector непустой, назначение при вызове должно быть объявлено; отсутствие аргумента и явно переданное назначение — разные случаи. В `scripts/check_sud_model.sh` разбор `--assigned-model` записывает пустую строку, а последующий `if [ -n "$assigned" ]` трактует её как отсутствие флага; проверка алфавита не вызывается. Состояние воспроизводимо через публичный CLI в отдельном мире с фиктивным конфигом и правильной primary-трассой:

```text
--verdict critic --trace <trace> --session Judge222_A --object aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa --root <world> --assigned-model ''
rc=0
СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется
```

Ожидается отказ на пустой selector, а не подстановка назначения роли. `judge_gate.sh` отдельно отклоняет пустой аргумент, но публичная общая дверь вызывается и самостоятельно; это не доказывает append через judge_gate. Закрывающее свойство: отличать наличие флага от отсутствия и fail-closed проверять его значение.

## Остатки

Граница НЕ ЗАЩИЩАЕТ о подлинности доверенного назначения/JSONL, платном runtime, удостоверении личности актора и изменении оракула в доверенной установке сохранена: эти возможности не выдаются за блок. Строк `НЕ ЗАЩИЩАЕТ` с ловцом adversary и идентификатором К-NN в контракте нет; последняя строка называет critic/adversary ловцами конечной батареи — адресная атака описана блоком К-08. Код и проверка предмета в кандидатной ветке не изменены; изменения для атак производились только в одноразовых клонах.

## Регресс

Честная production: `--repo .` rc 0, `SUBJEKT 222: KLETKI 76 KRASNYH 0`; независимая честная модель `--model` rc 0, `MODEL 222: KLETKI 76 KRASNYH 0`; `--catalog` rc 0, `KLETKI=76 STABS=33 SVJAZI=60`. `npm run gen:harness -- --check` rc 0, `харнес соответствует roles/ (13 ролей)`; `bash scripts/gen_ci_steps.sh --check` rc 0. Зоны и авторы проверены по frozen/222/1 и трём коммитам: два implementer-коммита в его зоне, orchestrator меняет только три разрешённых пути. `bash -n` изменённых shell rc 0; pinned shellcheck `-s bash -S warning`: все, кроме judge_gate, rc 0; judge_gate rc 1, три SC2034 f2/f3/f4, те же три в базе 880ff787e; `node --check scripts/roles.ts` rc 0.

## Мутации

| Самостоятельная замена | Вход / результат |
|---|---|
| denied вне fallback принимается только с per-call | жив: полная 222 `--repo` 76/0, 198 `--repo` 12/0, 104 и 173 `--repo` зелёные; честная дверь на том же входе rc 1 |
| любой allowed принимается | `--repo . --case verdict-fact-not-assigned` rc 1, `KLETKI 1 KRASNYH 1` |
| `-` принимается за OBJECT | `--repo . --case verdict-object-dash` rc 1, `KLETKI 1 KRASNYH 1` |
| константа `drc=0` вместо проверки объявленности | `--repo . --case spawn-unconfigured` rc 1, `KLETKI 1 KRASNYH 1` |
| judge_gate не передаёт назначение | `--repo . --case gate-critic-per-call` rc 1, `KLETKI 1 KRASNYH 1` |
| PATH: node найден, но выходит 127 | `--repo . --case spawn-critic-other-family` rc 1: субъект rc 2 вместо 0; положительная клетка не принимает отказ за успех |
| пустой selector | честная production rc 0 с пустым явным назначением; блок К-09 выше |

Для воспроизведения живого мутанта: в отдельном клоне от OBJECT сделать указанную точечную замену, создать тестовый мир по `install()` из `fixtures/workshop_project/lyubaja_model_222/probe.py`, записать указанную пятиколоночную строку и вызвать `bash <world>/scripts/check_sud_model.sh --verdict critic --trace <world>/trace --session Judge222_A --object aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa --root <world> --assigned-model other-vendor/other-family-9`. Затем запустить указанные команды семей в том же клоне. Тестовые миры использовали собственные `.git` и фиктивные трассы/конфиги; настоящая трасса сессии как вход двери не использовалась.

## НЕ ЗАЩИЩАЕТ

Этот суд не удостоверяет реальный удалённый runtime или честность доверенного назначения, не тестирует все возможные селекторы и не доказывает тождество акторов. Мутант — свидетельство дыры различения теста, не утверждение, что честная ветвь denied дефектна.

## Советы

Нет.

accept
OBJECT=becd5bd8d8932794ac5bdef15a5bff22b6f6d39e
КЛАСС=смешанный (v+1 замороженного контракта + красные тесты), суд ПО ДЕЛЬТЕ; КЛАСС РИСКА: обычный — ПОДТВЕРЖДЁН (дельта = текст контракта + probe.py батареи; прав/ролей БД, авторизации, денег, ПД/health, юридически значимых действий не касается)
СУД: repo=dev-harness; предмет=188; фаза=v+1 (адресный, frozen/contracts/188/1 → v2); роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit188v2 (харнесс-сессия c907157c); модель-факт=zai/glm-5.3; SHA=becd5bd8d8932794ac5bdef15a5bff22b6f6d39e; предыдущий=нет по v2 (первый суд v2; v1 суд закрыт accept в verdicts/critic/contracts-188-v1.md); исключение=нет

# Вердикт критика — 188 v2 «пара roles/implementer-glm.md в ЗОНУ implementer», вызов 1/2, суд ПО ДЕЛЬТЕ

Клон: `/tmp/dev-harness-verify/Crit188v2/repo` (единственный источник `ssh://git@github.com/a3ka/dev-harness.git`; теги и `wip/188/architect` fetched). Объект — один коммит `Arch188Vplus` «188 v+1: пара roles/implementer-glm.md в ЗОНУ implementer», родитель `ba7bed37` — предок origin/main (перебазирование подтверждено). `git log -1 --format=%B becd5bd8 | grep -c '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'` → 1; строка первой колонкой. Дельта ровно два файла: `contracts/188-roli-po-arhitekture.md`, `fixtures/workshop_project/roles_architecture_188/probe.py`.

## Что изменяется — свержено с frozen 188/1 дословно

`git diff frozen/contracts/188/1^{commit}:contracts/188-… becd5bd8:contracts/188-…`: ВЕРСИЯ-строка (6), раздел «Адресный v+1» (16–28) с инвариантами и rc-командами, §Предмет 17→22 координат (33), +2 буллета модели угроз (ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ), переписанный приёмочный критерий, ЗОНА implementer +2 файла (74), +2 ПЕРЕСЕЧЕНИЯ с 998 (75–76), ПРОВОДКА +4 role-канала roles/implementer-glm.md (202–205). Иное в контракте не тронуто: «Позиции автора» v1, прежние 17 координат, guard-канал (191), ЗОНЫ прочих ролей — без изменений. v1 ЗОНА implementer сверена: glm-файлов не несла (утверждение v2 «в ЗОНЕ v1 оба отсутствовали» — верно). Каналы: v1 17 role= → v2 21 role= (+1 guard), прибавка ровно 4 glm-канала; цитаты glm-каналов побайтово равны цитатам implementer-каналов и литералам `norms.tsv` (грамматика «…» без вложений — правка круга 2 v1 унаследована).

## rc-команды — все предъявленные состояния воспроизведены живьём

```
$ bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --model
CELLS=22 HONEST=22 RED_NEGATIVES=22 HTML_NEGATIVES=22 FENCE_NEGATIVES=22   rc=0
$ … --stabs
STABS=13 CAUGHT=13 (8 прежних меток + 5 glm; ZHIV нет; встроенный repo-html-comment → rc 1, GREEN=21, RED architect/cells)   rc=0
$ … --repo .           (дерево OBJECT; роли = main)  rc=1, CELLS=22 GREEN=1 (зелена только implementer-glm/pair)
$ … --repo <чистый main, git archive origin/main>    rc=1, CELLS=22 GREEN=1; тела пары на main равны (frontmatter расходится только role:)
$ … --repo <состояние PR #771: 7 ролей вставлены, glm нет>  rc=1, CELLS=22 GREEN=17, красны ровно 4 литеральные glm-координаты + implementer-glm/pair
$ … --repo <честная реализация с парой>              rc=0, CELLS=22 GREEN=22
$ PROBE_SUBJECT_ROOT=<дерево #771> python3 fixtures/pravila_modelei_998/probe.py --case role_pair_glm
CASE role_pair_glm: РАСХОЖДЕНИЕ — тело roles/implementer-glm.md не байт-в-байт с roles/implementer.md  rc=1
  (контроль: чистое дерево → ok rc=0) — измеренная причина v+1 (CI PR #771) воспроизведена
```

Критерий не ослаблен: прежние 17 литеральных клеток и 8 предъявлений сохранены дословно, добавлены 4 литеральные glm-клетки + клетка пары; каждая из 22 клеток прошла honest/missing/html/fence-контроли (`--model` 22/22/22/22/22).

## Семантика клетки implementer-glm/pair против пина 998 — сверка «тела»

`role_body` (probe 188) и `split_role_file` (probe 998): один и тот же `re.match(r'^---\n(.*?)\n---\n(.*)$', …, re.S)`, возврат `group(2)`, сравнение строк байт-в-байт, без тримминга краёв; нет frontmatter → весь файл. Дивергенции семантики нет. Мутация М9 (лишняя строка ТОЛЬКО в frontmatter glm): батарея 188 rc 0 (клетка пары зелена — тела равны), пин 998 rc 1 («frontmatter … отличается числом строк») — разделение обязанностей ровно как заявлено в v2 («frontmatter расходится только полем role:» — домен 998). Ложного зелёного в целом конвейере нет.

## Мутации критика — каждая краснеет своей клеткой (одноразовые копии, --repo)

| мутация | RED |
|---|---|
| M1 норма только в implementer.md, glm без секции (форма #771) | implementer-glm/{finding,placement,engine,bindings} + implementer-glm/pair |
| M2 лишний байт «x\n» в теле пары вне литералов | ТОЛЬКО implementer-glm/pair (литеральные glm-клетки зелёны) |
| M2b перенос строки в конце тела пары | ТОЛЬКО implementer-glm/pair |
| M2c снятие последнего \n тела пары | ТОЛЬКО implementer-glm/pair |
| M3 engine-литерал пары в многострочном HTML-комментарии | implementer-glm/engine (+pair) |
| M4 engine-литерал пары в fenced code | implementer-glm/engine (+pair) |
| M5 engine-литерал пары в необязательной секции «## Справка» | implementer-glm/engine (+pair) |
| M6 engine удалён из glm, вставлен в чужую роль (architect) | implementer-glm/engine (+pair) |
| M7 bindings-литерал удалён из glm | implementer-glm/bindings (+pair) |
| M8 опечатка в литерале пары (1 байт внутри литерала) | implementer-glm/engine (+pair) |
| M9 frontmatter-only расхождение | 188: зелена (тела равны); 998: red — граница заявлена |
| M10 engine удалён из БАЗОВОГО implementer.md (пара сохраняет) | implementer/engine + implementer-glm/pair |

Батарея ловит расхождение пары в обе стороны и любым байтом; литеральные клетки независимы (нет зелёного по соседям).

## ПЕРЕСЕЧЕНИЯ/ЗОНЫ — спан всех 311 тегов frozen/contracts/* (169 контрактов)

Живой `git grep -l 'implementer-glm' <все теги>`: в `contracts/` упоминают только `frozen/contracts/998/1` (ЗОНА implementer: roles/implementer-glm.md, .omp/agents/implementer-glm.md; ПЕРЕСЕЧЕНИЯ 002/003/005/010/011 — агент как производная генератора) и `frozen/contracts/140/2` (implementer-glm ТОЛЬКО в алфавите ролей грамматики замка, зон не держит). Числа v2 (311/169, единственный владелец 998) совпали с живым спаном. Оба файла объявлены в v2: ЗОНА (74) + 2 ПЕРЕСЕЧЕНИЯ (75–76), семантика пересечений зеркалит 998 (тело байт-в-байт; агент — производная, перегенерация). Незаявленных пересечений нет. Потолок: PERSONA_LIMIT=73728; glm-файл 10455 байт + вставка 1543 байта ≈ 11998 ≤ 73728; `check_ceilings.sh` rc 0 (12 персон).

## Гейты (дерево OBJECT)

```
$ bash scripts/pre_critic.sh contracts/188-roli-po-arhitekture.md        → ok, rc=0
$ bash scripts/check_precision_gate.sh . contracts/188-…                 → OK, rc=0
$ bash scripts/check_threat_model.sh . contracts/188-…                   → секция валидна (3/3), rc=0
$ bash scripts/check_ceilings.sh                                         → потолки в порядке, rc=0
$ bash scripts/check_provodka.sh . contracts/188-…                       → rc=1 «guard не подключён»
```

provodka-красное — ОЖИДАЕМОЕ до-реализационное (guard ещё не в реестре/CI; тот же класс, что 17 каналов v1 до вставки). Исполнимость нормы-строки ПРОВОДЕНА живьём: копия с честной вставкой пары + строка реестра `step check:roles-architecture-188-family-selftest …` → check_provodka rc 0 (21 role-канал + guard); точное состояние #771 → red ровно «норма-строка не найдена в role-файле: roles/implementer-glm.md». Порядок поставки ясен: implementer правит пару (ЗОНА 74, ПЕРЕСЕЧЕНИЯ 75–76) и перегенерирует `.omp/agents/implementer-glm.md`; три состояния дерева в rc-командах дают ревьюеру однозначный scoped-контроль по дельте.

## Находки

БЛОКИРУЮЩИХ НЕТ. Советы:

- СОВЕТ (коммит becd5bd8, не файл контракта) — строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` дословно отличается от предписанной в задании оркестратора: фактическая `contracts/188-roli-po-arhitekture.md v+1 — … в ЗОНУ implementer (парный файл implementer); …` против предписанной `contracts/188 v+1 — … в ЗОНУ (парный файл implementer); …`. Все существенные поля (предмет, v+1, файл, зона, слово владельца с дословной цитатой «188 v+1 ДА: …», дата, канал консультанта) на месте и точнее; механическое условие (`grep -c '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'` → 1) выполнено. Нарушения обязательства нет; впредь сверяй дословно либо помечай «по существу полей».
- СОВЕТ contracts/188-roli-po-arhitekture.md:13 (текст v1, дельтой не тронут) — «Текущие размеры ролей … orchestrator 61353» устарело: на базе OBJECT `wc -c roles/orchestrator.md` = 61713 (main ушёл на 30 коммитов). Запас до потолка 73728 всё ещё ≈ 12 КБ; для v2 действия не требует, при следующем адресном круге обновить замер.

## Порог

Оба совета не нарушают названных обязательств (§Порог: воспроизводимого нарушения обязательства в дельте не предъявлено; специально написанные мутации закрыты клетками батареи, вход каждой — наблюдавшееся состояние #771/main либо прямая правка файлов пары). Основание поиска дополнительных поверхностей — дельта v+1 (новая ЗОНА-строка и семейство входов glm), всё иное не исследовалось заново (§Контракт).

Вердикт: заморозка v2 разрешена.

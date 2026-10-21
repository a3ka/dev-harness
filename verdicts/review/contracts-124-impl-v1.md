FAIL
Суд реализации 124 «push-produkta», круг 1 из 3, ревьюер Rev124. Объект: OBJECT=9cf50668def256303d77dbca42ccbe28b0f95374
(ветка wip/124/implementer). Контракт: frozen/contracts/124/1. Находки (reslop, status: ready):
/tmp/dev-harness-verify/Rev124/review.md

## Итог

Область правки в порядке: только два пути зоны. Батарею автор не трогал. Батарея 57/57 зелёная, до
двери 27 красных. Порядок г1…г8 подтверждён на составных входах. Токен не утекает, refspec
`<sha>:refs/heads/<ветка>` верный, PR идемпотентен, канон берётся из профиля клона. Тем не менее две
блокирующие находки, обе вне покрытия батареи:

- **R124-1 (блокирует, implementer):** г2 «без хвоста `.` у сегмента» выполнен только для последнего
  сегмента. На `--branch foo./bar` дверь отвечает rc 0 ОК: ветка запушена, PR создан. По контракту
  должен быть rc 1 «ветка вне грамматики». Исправление — `*./*` в `case` на стр. 69.
- **R124-2 (блокирует, implementer):** `url.*.insteadOf` / `url.*.pushInsteadOf` в `.git/config` клона
  уводят push мимо канона профиля. На настоящем git ref оказался в `dev-harness.git` (в обход г5) и в
  `Complior-back.git`. Нарушены инвариант 1 и ЗАЩИЩАЕТ п.1/п.2 на конформном входе. В дереве этот класс
  уже известен: gitw:464-487, 045-Б2. Исправление в алфавите г7: отказывать «push отказан: …», если
  `git -C <клон> config --get-regexp '^url\.'` непуст.

Советы: С-1 и С-2 — клетки батареи для architect, С-3 — причины вне алфавита. Наблюдение Н-1: правка
roles — одна норма-строка байт-в-байт плюс заголовок и метка в принятом в файле обрамлении (996/1, 996/2).
Строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ нет; это вопрос форка n124-razreshil-roles, не предмет суда.

## Прогоны (rc — сырые)

Клон: `git clone --local /tmp/dev-harness-worktrees/c907157c/wip-124-implementer /tmp/dev-harness-verify/Rev124/clone`
→ HEAD 9cf50668def256303d77dbca42ccbe28b0f95374, `.git` свой.

| команда (cwd = клон, PYTHONDONTWRITEBYTECODE=1) | rc | вывод |
|---|---|---|
| `git diff --stat origin/main...HEAD` | 0 | roles/orchestrator.md +6, scripts/push_product.sh +155 |
| `git diff --stat 'frozen/contracts/124/1^{commit}' HEAD -- fixtures/workshop_project/push_produkta_124/ contracts/124-push-produkta.md` | 0 | пусто |
| `bash fixtures/workshop_project/push_produkta_124/red_124.sh` | 0 | `red_124: клеток 57, зелёных 57, красных 0 (дверь: …/clone/scripts/push_product.sh)` |
| `bash …/red_124.sh --model \| cut \| sort \| uniq -c` | 0 | `57 КЛЕТКА ЗЕЛЁНАЯ` |
| `RED124_DOOR=/nonexistent/push_product.sh bash …/red_124.sh \| … uniq -c` | 1 | `30 ЗЕЛЁНАЯ`, `27 КРАСНАЯ` |
| `reslop t -- bash scripts/check_provodka.sh . contracts/124-push-produkta.md` | 1 | `проводка: guard не подключён: …red_124.sh не вызывается в .githooks/ или .github/workflows/` (ожидаемо до интеграционного коммита) |
| `reslop t -- bash scripts/pre_critic.sh contracts/124-push-produkta.md` | 0 | — |
| `reslop t -- bash scripts/check_precision_gate.sh . contracts/124-push-produkta.md` | 0 | — |
| `reslop t -- bash scripts/check_threat_model.sh . contracts/124-push-produkta.md` | 0 | `ЗАЩИЩАЕТ 9, НЕ ЗАЩИЩАЕТ 5` |
| `bash /tmp/dev-harness-verify/Rev124/repro.sh` (репро вне батареи) | 0 | см. ниже |
| `git check-ref-format refs/heads/foo./bar` / `…/foo.lock/bar` | 0 / 1 | git сам принимает `foo./bar` |

Выдержки из repro.sh (сырые строки):

```
== АЛФАВИТ г2 ветка: foo./bar (длина 8)
  rc=0 out=[push_product ОК: a3ka/Complior-mob foo./bar fcfbf1205c5d64b6888624c1dc6f894f2b8bb9dd PR https://github.com/a3ka/Complior-mob/pull/1 создан|] err=[]
  push-вызовов git: 1
== г7+г8: честный вызов, origin клона = back, канон = mob; refspec в следе
  rc=0 out=[push_product ОК: a3ka/Complior-mob rev124/proba 3db08270… PR https://github.com/a3ka/Complior-mob/pull/1 создан|] err=[]
  след: git -C …/clone -c credential.helper= -c credential.helper=\!gh\ auth\ git-credential push --quiet https://github.com/a3ka/Complior-mob.git 3db08270…:refs/heads/rev124/proba
  Δref: > Complior-mob.git refs/heads/rev124/proba 3db08270…
== ИДЕМПОТЕНТНОСТЬ: повтор того же вызова
  rc=0 out=[push_product ОК: … PR https://github.com/a3ka/Complior-mob/pull/1 существует|]   строк PR: 1
== ТОКЕН: bash -x трассировка двери на двойнике
  канарейки в трассе нет; строк трассы: 571
== г6: --sha = C1 (предок HEAD) → отказ до push
  rc=1 err=[push_product ОТКАЗ: HEAD клона ≠ --sha: HEAD e3beb426…, заявлено e952ce1d…|]  push-вызовов git: 0  ref'ы мира не изменились
== ОБХОД-проба (настоящий git, не двойник): url.<bare харнесса>.insteadOf=<канон mob> в конфиге клона
  rc=1 err=[push_product ОТКАЗ: PR не создан: pull request create failed: GraphQL: Head sha can't be blank, …]
  Δref: > dev-harness.git refs/heads/rev124/proba db484084…
== ОБХОД-проба (настоящий git): url.<bare back>.pushInsteadOf=<канон mob>
  Δref: > Complior-back.git refs/heads/rev124/proba 66929a5e…
```

Остальные случаи repro.sh дали ожидаемые причины и rc, в каждом отказе 0 push-вызовов. Полный перечень —
в review.md, «Проверено своей мерой».

## Для следующего круга

Implementer закрывает R124-1 и R124-2 в зоне `scripts/push_product.sh`. Architect по желанию добавляет
клетки С-1/С-2: двойник git сейчас insteadOf не наблюдает. Принять повторно можно после прогона батареи
57/57 и repro-случаев `foo./bar` и insteadOf/pushInsteadOf, где должны быть rc 1 и 0 push.

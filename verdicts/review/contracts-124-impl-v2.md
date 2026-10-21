FAIL
Суд реализации 124 «push-produkta», круг 2 из 3 (scoped), ревьюер Rev124b. OBJECT=d7bd9afd86c0d614fc76ccff1c8f413f24c3e774
(ветка wip/124/implementer), батарея wip/124/architect @ 375576909, контракт frozen/contracts/124/1.
Находки (reslop, status: ready): /tmp/dev-harness-verify/Rev124b/review.md

## Итог

Что сделано верно:

- R124-1 закрыт: `foo./bar` → rc 1 «ветка вне грамматики».
- R124-2 закрыт в названном объёме на настоящем git: `url.*.insteadOf/pushInsteadOf`, также через регистр,
  `include.path` и global, и `remote.<канон>.url/pushurl` → rc 1, 0 push. Честный `remote.origin.url` не
  отказывается.
- По маркерам тестового мира дверь не ветвится. grep пуст; `bash -x` без P124_* дал 0 упоминаний; стаб
  адверсария круга 1 краснеет на т01/т27.
- Норма-строка в roles одна и совпадает байт-в-байт (`grep -Fxc` = 1).
- Правки только в двух путях зоны.
- Батарея: 70/70.

Класс R124-2 («конфиг клона уводит push мимо канона») целиком НЕ закрыт:

- **R124-3 (блокирует, implementer, `scripts/push_product.sh:157-159`).** При `push.recurseSubmodules=on-demand`
  или `submodule.recurse=true` в конфиге клона (второй ключ может стоять и в глобальном) и подмодуле с
  неопубликованным коммитом дверь отвечает rc 0 ОК. При этом `refs/heads/main` репозитория подмодуля
  (в репро это bare `dev-harness.git`) сдвинут. Обойдены г5, инвариант 1 и инвариант 2. Более простая форма
  в алфавите г7: `push --quiet --no-recurse-submodules --no-follow-tags …`. Замер: батарея 70/70 rc 0, все
  репро дают Δref ровно на ветку канона.

Советы: С-4 (`push.followTags` в конфиге → тег в каноне; вне объёма круга, закрывается той же правкой),
С-5 (architect: клетки на подмодуль и followTags), С-6 (разбор имён в гейте шире свойства). Наблюдения:
Н-2 (roles: +2 строки — разделитель и норма), Н-3 (в телах коммитов нет сырого вывода). Вопрос
РАЗРЕШИЛ-ВЛАДЕЛЕЦ — форк n124-razreshil-roles, не предмет суда.

## Прогоны (rc — сырые; cwd = клон, PYTHONDONTWRITEBYTECODE=1)

| команда | rc | вывод |
|---|---|---|
| `git clone --no-local /home/harness/dev-harness …/Rev124b/clone`; `git checkout --detach OBJECT`; `git checkout 375576909 -- fixtures/workshop_project/push_produkta_124` | 0 | HEAD d7bd9afd…, 4 файла батареи M |
| `git diff --numstat c68c143e OBJECT` | 0 | `2 0 roles/orchestrator.md`, `187 0 scripts/push_product.sh` |
| `git log --oneline c68c143e..OBJECT -- fixtures contracts verdicts .review \| wc -l` | 0 | `0` |
| `bash …/red_124.sh` (дверь OBJECT) | 0 | `red_124: клеток 70, зелёных 70, красных 0`; по префиксу: Д 1, t 30, С 39 |
| `bash …/red_124.sh --model` | 0 | `клеток 70, зелёных 70, красных 0` |
| `RED124_DOOR=clone/scripts/zz_rev124b_door_9cf.sh bash …/red_124.sh` (дверь 9cf50668d) | 1 | `клеток 70, зелёных 67, красных 3`: t28 «rc 0, ожидался 1», t29 «[url.*.insteadOf] нет причины push отказан», t30 «[remote.<канон>.url] …» |
| то же, копия вне `scripts/` (мой невалидный первый замер, ROOT неверен) | 1 | 53/17, «профиль битый», не засчитан |
| `RED124_DOOR=…/zz_rev124b_adv_stub.sh bash …/red_124.sh --cell t01` / `--cell t27` | 1 / 1 | обе КРАСНАЯ (stdout ≠ ожиданию) |
| `RED124_DOOR=…/zz_rev124b_simpler.sh bash …/red_124.sh` (OBJECT + `--no-recurse-submodules --no-follow-tags`) | 0 | `клеток 70, зелёных 70, красных 0` |
| `grep -nE 'P124\|RED124\|WORLD\|red_?124\|dvoyn\|knob\|kanarej\|red124\|fixtures' scripts/push_product.sh` | 1 | пусто |
| `grep -Fxc -- "<role= из frozen 124/1>" roles/orchestrator.md` | 0 | `1` (строка 552 байта) |
| `DOOR=…/xtrace_door.sh bash repro.sh` (bash -x, env -i) | 0 | 16 вызовов, `P124_*` в env: 0 в каждом; маркеров в 8343 строках трассы: 0 |
| `bash /tmp/dev-harness-verify/Rev124b/repro.sh` (дверь OBJECT) | 0 | выдержки ниже |
| `DOOR=…/zz_rev124b_simpler.sh bash repro.sh` | 0 | все случаи: Δref только `Complior-mob.git refs/heads/rev124b/proba`, url/remote-случаи rc 1 |

Выдержки из repro.sh на OBJECT (сырые строки):

```
== г2: --branch foo./bar
   rc=1 out=[] err=[push_product ОТКАЗ: ветка вне грамматики: foo./bar|]
   push-вызовов git: 0
   Δref: нет
== url.<bare харнесса>.insteadOf=<канон>
   rc=1 out=[] err=[push_product ОТКАЗ: push отказан: настроены url.*.insteadOf/pushInsteadOf или remote.<URL>.url|pushurl в .git/config клона: url./tmp/dev-harness-verify/Rev124b/scratch/w3/remotes/a3ka/dev-harness.git.insteadof|]
   Δref: нет
== remote.<канон>.pushurl=<bare back>
   rc=1 out=[] err=[push_product ОТКАЗ: push отказан: … remote.https://github.com/a3ka/Complior-mob.git.pushurl|]
   Δref: нет
== честный: remote.origin.url=https://github.com/a3ka/Complior-back.git
   rc=0 out=[push_product ОК: a3ka/Complior-mob rev124b/proba ac141ffd… PR https://github.com/a3ka/Complior-mob/pull/8 создан|] err=[]
   Δref > Complior-mob.git refs/heads/rev124b/proba ac141ffd…
== remote.<канон>.mirror=true
   rc=1 out=[] err=[push_product ОТКАЗ: push отказан: fatal: --mirror can't be combined with refspecs|]
   Δref: нет
== push.followTags=true + аннотированный тег на SHA
   rc=0 out=[push_product ОК: a3ka/Complior-mob rev124b/proba dbb78e63… PR …/pull/8 создан|] err=[]
   Δref > Complior-mob.git refs/heads/rev124b/proba dbb78e63…
   Δref > Complior-mob.git refs/tags/v9-local 9023db00…
== push.recurseSubmodules=on-demand + подмодуль с неопубликованным коммитом (remote подмодуля = bare харнесса)
   rc=0 out=[push_product ОК: a3ka/Complior-mob rev124b/proba 0e8ad9c9… PR https://github.com/a3ka/Complior-mob/pull/8 создан|] err=[]
   push-вызовов git: 1
   Δref > Complior-mob.git refs/heads/rev124b/proba 0e8ad9c9…
   Δref < dev-harness.git refs/heads/main a9e2b725379e9b82aef84a1b447070ce07102f57
   Δref > dev-harness.git refs/heads/main c356092bc87b09dc8ef859b463374041198412bb
== submodule.recurse=true + подмодуль с неопубликованным коммитом (remote подмодуля = bare харнесса)
   rc=0 out=[push_product ОК: a3ka/Complior-mob rev124b/proba 8c38f66e… PR …/pull/8 создан|] err=[]
   Δref < dev-harness.git refs/heads/main 3f73ad30564a61f2f21e88a0fb84e4713b8681bd
   Δref > dev-harness.git refs/heads/main fd700ee7a4c40024e7c404271d0fdde0607c6a54
```

Сеть, GitHub и токены не вызывались. push в origin не делался. Основной чекаут не правился; файлы
`clone/scripts/zz_rev124b_*.sh` лежат только в одноразовом клоне.

## Для круга 3 (последнего)

Implementer: в г7 `--no-recurse-submodules --no-follow-tags` (зона `scripts/push_product.sh`). Architect
(по желанию, С-5): клетки на подмодуль и followTags со снимком ref'ов всех bare. Принять можно после
прогона батареи и случаев `repro.sh` с подмодулем и followTags, где Δref должен быть ровно на ветку канона.

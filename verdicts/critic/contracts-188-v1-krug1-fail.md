FAIL
OBJECT=a0171ec3ddcdefffc950fc959a565891ebf41ad6
СУД: repo=dev-harness; предмет=188; фаза=контракт (187б: роли по архитектуре; architect Arch188); роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=openai-codex/gpt-5.6-terra; SHA=a0171ec3ddcdefffc950fc959a565891ebf41ad6; предыдущий=нет; исключение=нет

КЛАСС РИСКА: подтверждён обычный: предмет меняет нормы ролей и структурную батарею, но не права/роли БД, авторизацию, безопасность, деньги, ПД/health, согласия либо юридически значимые действия.

СОГЛАСИЕ НА ПРАВКУ РОЛИ: да — только на объявленную норму 188 в `roles/critic.md`; согласие не заменяет исправление блокера и не является accept.

БЛОКИРУЕТ contracts/188-roli-po-arhitekture.md:25,34-35 — критерий обещает краснить норму, перенесённую в комментарий, но его реальный CI-вход принимает HTML-комментарий с точным литералом как самостоятельную норму.
ОБЯЗАТЕЛЬСТВО: `## Модель угроз` защищает от «комментарий вместо нормы», а критерий требует, чтобы такой стаб был пойман (`STABS=5 CAUGHT=5`) и `--repo .` зелёнел только при самостоятельных строках норм в обязательных разделах.
КЛАСС ПРИЧИНЫ: ложная достаточность структурной батареи.
ИСТОЧНИК ВХОДА: поддерживаемый критерий `bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo <корень>` читает `roles/<роль>.md`; контракт прямо объявляет этот же вход CI-входом.
ИСТОЧНИК ОШИБОЧНОГО МЕХАНИЗМА: исходная операция — `assess()` в `fixtures/workshop_project/roles_architecture_188/probe.py:28-39`, которая должна отличать самостоятельную норму от комментария. В честной модели её строка `architect/cells` была заменена на тот же литерал между `<!--` и `-->`; операция на `probe.py:39` проверяет только наличие точной строки в секции и не исключает Markdown HTML-комментарии.
СОСТОЯНИЕ: в одноразовой копии семи честных role-файлов сохранены маркеры и остальные 16 литералов; единственный `architect/cells` находится только внутри многострочного HTML-комментария в обязательной секции.
НАБЛЮДЕНИЕ: фактический `--repo` вернул rc=0 и `CELLS=17 GREEN=17`; ниже приведён сырой вывод. Следовательно, дерево без самостоятельной нормы удовлетворяет критерию и CI пропустит имитацию.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для каждой координаты батарея отвергает литерал, находящийся в любом Markdown-комментарии, и доказывает это через реальный путь `--repo` на копии role-дерева.
ОБХОД: заменить самостоятельную строку `architect/cells` на
`<!--`
`<точный литерал>`
`-->`
в копии честного `roles/architect.md`, затем выполнить:
```text
$ bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo tmp/critic-188-html-comment
GREEN architect/finding
GREEN critic/finding
GREEN implementer/finding
GREEN adversary/finding
GREEN reviewer/finding
GREEN architect/cells
GREEN critic/sixth
GREEN implementer/placement
GREEN implementer/engine
GREEN implementer/bindings
GREEN adversary/stubs
GREEN reviewer/verdict
GREEN arbiter/decision
GREEN orchestrator/task
GREEN orchestrator/linked
GREEN orchestrator/merge
GREEN orchestrator/steward
CELLS=17 GREEN=17
```

Проверенные команды и сырой вывод:

```text
$ bash scripts/pre_critic.sh contracts/188-roli-po-arhitekture.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
# rc=0

$ bash scripts/check_precision_gate.sh . contracts/188-roli-po-arhitekture.md
OK
# rc=0

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 170 черновик(ов) судится, замороженные — по тегам
потолки в порядке
# rc=0

$ bash scripts/check_threat_model.sh . contracts/188-roli-po-arhitekture.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
# rc=0

$ bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --model
CELLS=17 HONEST=17 RED_NEGATIVES=17
# rc=0

$ bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --stabs
STAB wrong-role caught @ critic/finding
STAB comment caught @ architect/cells
STAB typo caught @ implementer/engine
STAB optional-section caught @ orchestrator/linked
STAB prose caught @ reviewer/verdict
STABS=5 CAUGHT=5
# rc=0

$ bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo .
RED architect/finding
RED critic/finding
RED implementer/finding
RED adversary/finding
RED reviewer/finding
RED architect/cells
RED critic/sixth
RED implementer/placement
RED implementer/engine
RED implementer/bindings
RED adversary/stubs
RED reviewer/verdict
RED arbiter/decision
RED orchestrator/task
RED orchestrator/linked
RED orchestrator/merge
RED orchestrator/steward
CELLS=17 GREEN=0
# rc=1 (ожидаемо до implementer)

$ bash scripts/check_provodka.sh . contracts/188-roli-po-arhitekture.md
проводка: guard не подключён: fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh не вызывается в .githooks/ или .github/workflows/
# rc=1 (ожидаемо до реализации CI-проводки)
```

Проверка счётных утверждений: `norms.tsv` содержит 13 строк и разворачивается в 17 уникальных координат; `--model` подтвердил `CELLS=17`, `--stabs` — `STABS=5`, а `--repo .` перечислил 17 красных координат. Несоответствий в этих числах не найдено.

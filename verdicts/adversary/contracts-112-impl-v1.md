FAIL
OBJECT=61260217cf1531ac4231bda337c1a30047da98a9

БЛОКЕР — обход `komandy`: `scripts/check_project_connection.sh` принимает команды, которые исполняют файл/читают package.json ВНЕ проверяемого репозитория. Это прямо нарушает предметную проверку «команда … реальна в дереве репо» и расходится с моделью батареи.

Наблюдаемый контрпример. Создан честный минимальный git-мир `/tmp/dev-harness-verify/Adv112/world`: origin и `git.canonicalRemote` совпадают, слой/ci.workflow существуют, все workflowPaths и state — реальные каталоги внутри мира, npm-скрипты для остальных трёх команд есть. Единственная мутация:
`commands.test = "node /tmp/dev-harness-verify/Adv112/external-node.js"`, где внешний обычный файл существует.

Факт:
- продукт: `bash scripts/check_project_connection.sh --repo /tmp/dev-harness-verify/Adv112/world` → `product-rc=0`;
- модель: `bash fixtures/workshop_project/podklyuchenie_112/model_check_connection.sh --repo /tmp/dev-harness-verify/Adv112/world` → `ОТКАЗ: подключение: komandy: commands.test: файла нет в дереве: /tmp/dev-harness-verify/Adv112/external-node.js`, `model-rc=1`.

Причина в продукте: ветвь `node|python3` присваивает абсолютный `file` прямо в `target`; ветвь npm так же присваивает абсолютный аргумент `--prefix` прямо в `dir`. Поэтому второй независимый вариант `commands.test = "npm --prefix /tmp/dev-harness-verify/Adv112/external-npm test"` (внешний package.json со строковым scripts.test) также дал продукту rc=0, а модели — rc=1 с «нет <R>//tmp/.../package.json». Относительные `../…` имеют ту же дыру: конкатенация с `$R` не канонизируется и не проверяется на принадлежность `$R`.

Требуемая правка автора: для node/python3 и npm --prefix принимать только путь, после канонизации остающийся внутри `$R`; внешний/абсолютный/`..`-побег должен дать именованный `ОТКАЗ: подключение: komandy` rc=1. Это не задача батареи: её модель уже краснеет на предъявленном входе.

Прогоны (все на локальном клоне OBJECT):
- `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh` → rc=0, `37/37` (его анти-плацебо state-контрмодель напечатала ожидаемые расхождения D14/D16);
- `... --model` → rc=0, `37/37`;
- `... --cell net-takoj-kletki` → rc=2 (stderr: `usage: command not found`, поскольку usage-функция в батарее не определена);
- отсутствие jq (`PATH=/nonexistent /bin/bash scripts/check_project_connection.sh --repo …`) → rc=2, названо «нет jq»;
- jq-проверка npm-ключа → rc=0; awk-проверка step-строки → rc=0; `bash scripts/gen_ci_steps.sh --write && bash scripts/gen_ci_steps.sh --check` → rc=0; `bash scripts/verify_ci_parity.sh` → rc=0;
- `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → rc=0 (4/4); `bash fixtures/_krasnye_054.sh` → rc=0;
- `bash scripts/check_provodka.sh . contracts/112-podklyuchenie-proekta.md` → rc=0; `bash scripts/check_threat_model.sh . contracts/112-podklyuchenie-proekta.md` → rc=0;
- `bash scripts/verify_antiplacebo.sh --scope check_project_connection` → rc=1: для нового barrier отсутствуют `fixtures/check_project_connection/case_*.sh`. Это отдельный красный required scoped-check, но не основание данного FAIL: основание — наблюдаемый обход выше.

Область: `git diff --name-only 0868cc67f..HEAD` содержит ровно пять разрешённых путей implementer; contracts/112 и fixtures/workshop_project/podklyuchenie_112 в diff отсутствуют. Полные diff проверены: profile_resolver — только добавление javascript в language; package.json — один ключ; registry — одна step-строка (с её комментариями); ci.yml проходит `gen_ci_steps --write/--check` и после --write не имеет рабочего diff; check_project_connection — новый файл.

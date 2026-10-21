FAIL
OBJECT=47edb2120e93eb51e4aace56820018a3e81101cc

БЛОКЕР — реализация остаётся слабее ужесточённой модели на прежнем входе круга 3: листовой symlink `mobile/package.json` наружу. Это прямой регресс-обязательство r4 («прежние входы кругов 1–3 … rc 1 komandy/именованная причина»), а не новый класс вне B1/LF.

Наблюдаемый контрпример `/tmp/dev-harness-verify/Adv112r4/probe_package_execution.sh` строит честный минимальный mob-мир: origin и `canonicalRemote` совпадают, слой, workflowPaths и CI реальны, все четыре команды — ровно `npm --prefix mobile test`. Единственная мутация дерева: `mobile/package.json` является symlink на `/tmp/dev-harness-verify/Adv112r4/exec-external/package.json`, лежащий вне корня репозитория, с `scripts.test = "echo EXECUTED-OUTSIDE-TREE"`.

Фактический прогон:

    $ bash probe_package_execution.sh
    checker_rc=0
    > test
    > echo EXECUTED-OUTSIDE-TREE
    EXECUTED-OUTSIDE-TREE
    npm_rc=0

То есть product подтверждает «скрипт в D/package.json есть в дереве», но CI-команда реально читает и исполняет package.json вне дерева. Это тот же наблюдаемый побег, который обязан ловить `komandy`, а не гипотетическое вредоносное поле профиля.

Дифференциальный контроль на том же мире (`probe_leaf_and_nul.sh`) даёт product rc=0, тогда как эталон возвращает rc=1 и по каждой команде печатает:

    ОТКАЗ: подключение: komandy: commands.<k>: package.json канонически вне дерева (лист-symlink)

Причина в продукте: `scripts/check_project_connection.sh:344–345` устанавливает `pj="$dir/package.json"` и проверяет только `[ -f "$pj" ]`; эта проверка следует листовой ссылке. В отличие от него модель перед `npm_script_ok` выполняет `readlink -f -- "$pj"` и проверяет принадлежность канонической цели `$R` (`fixtures/workshop_project/podklyuchenie_112/model_check_connection.sh`, блок `KOMANDY-112`). Product канонизирует только каталог `--prefix` через `canon_R`, но не его лист `package.json`. Батарея 63/63 не ловит именно эту заглушку: D59 покрывает node-файл-лист, а не npm `package.json`-лист.

Нужна правка implementer: перед `[ -f]`/`jq` канонизировать `pj` через `readlink -f` и потребовать, чтобы результат был обычным файлом внутри `$R`; затем читать проверенный канонический путь. Architect нужен отдельный red-case с внешним листом `package.json` (позитивный контроль — обычный `mobile/package.json`), потому что D59 эту ветвь не исполняет.

Что закрыто и перепроверено:
- B1: focused product-cells D49–D54 (одинарная/двойная кавычка, `\\`, `{a,}`, `~`, glob) → все rc=0 как ожидание батареи (то есть каждая обманка отвергнута с `komandy`); D53 включает `npm --prefix ~ test`.
- LF/NUL: D55–D58 → все rc=0 как ожидание батареи; отдельно NUL в `workflowPaths.contracts` вернул rc=1 `workflowPaths`, NUL в source-path — rc=1 `profil` от строгого резолвера. LF/NUL в canonicalRemote закрыты D55/D58.
- Позитивные контроли M1-back и M2-mob → rc=0.
- Полные прогоны продукта и модели: `red_podkljuchenie_112.sh` и `--model` → rc=0, `клеток 63, зелёных 63, красных 0`. Они печатают ожидаемые расхождения анти-плацебо для state- и komandy-слепых контрмоделей, итог обоих зелёный.
- Старый корпус r1–r3 воспроизведён `legacy_r3.sh`: честные literal-команды/профили дают rc=0; все предъявленные r1/r2/B1/LF обходы — rc=1 с `komandy` либо иной именованной причиной. Именно r3 `n-pkgjson-leaf-symlink` остаётся product rc=0/model rc=1 и составляет этот FAIL.
- Наличие инструмента не считается успехом: `PATH=/nonexistent /bin/bash scripts/check_project_connection.sh --repo /tmp` → rc=2, `нет jq`. Неизвестная клетка → rc=2 с usage.
- Стандартные прогоны: `check_provodka`, `check_threat_model`, `gen_ci_steps.sh --check`, `verify_ci_parity`, `run_battery.sh profile_resolver`, `_krasnye_054.sh` → rc=0.

Границы: implementer commit `2a51862f4` меняет только `scripts/check_project_connection.sh`; architect commits `7efa0deed`/`ffb2b6274` — только два файла `fixtures/workshop_project/podklyuchenie_112/`. Diff frozen-contract → HEAD по `contracts/112-podklyuchenie-proekta.md` пуст. Model diff r4 добавляет byte checks, whitelist и canonical leaf logic; ослабления не наблюдалось.

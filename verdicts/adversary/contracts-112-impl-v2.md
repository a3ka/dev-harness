FAIL
OBJECT=2a83bd1ee1998c775ce5c08ad7a46a2473fb81b3

БЛОКЕР — `scripts/check_project_connection.sh` всё ещё даёт rc=0 дефектным профилям в ветви `komandy`; новая батарея 40/40 их не предъявляет. Реализация расходится со своим усиленным эталоном `model_check_connection.sh`, который на каждом из первых семи входов ниже возвращает rc=1 и именованный `ОТКАЗ: подключение: komandy`.

Наблюдаемый мир: минимальный честный git-репозиторий Complior-mob в `/tmp/dev-harness-verify/Adv112r2/world-komandy`, с совпадающим HTTPS origin/canonicalRemote, валидными project layer/workflowPaths/state/CI и всеми четырьмя обычными npm scripts. Позитивный контроль `commands.test="npm --prefix mobile test"` дал продукту rc=0 и модели rc=0.

ОБХОДЫ (в каждом меняется только `commands.test`; файл или package.json, если назван, реально существует):

1. `node /tmp/dev-harness-verify/Adv112r2/world-komandy/mobile/honest.js` — абсолютный путь, хотя правило komandy требует только относительный. Product rc=0; model rc=1 (`путь файла абсолютный`).
2. `npm --prefix /tmp/dev-harness-verify/Adv112r2/world-komandy/mobile test` — абсолютный `--prefix`. Product rc=0; model rc=1 (`--prefix абсолютный`).
3. `node mobile/$evil.js` — файл с буквальным именем `$evil.js` существует, но неэкранированная команда в shell подставляет `$evil` и исполняет другой/несуществующий путь. Product rc=0; model rc=1 (`оператор оболочки в команде`).
4. `node mobile/evil; false` — файл с буквальным именем `evil;` существует, но shell разбирает `; false` как отдельную завершающую неуспехом команду. Product rc=0; model rc=1 (`оператор оболочки в команде`).
5. `npm --prefix mobile run $script` — в package.json есть буквальный ключ `$script`, но неэкранированный npm получает подстановку, а не этот ключ. Product rc=0; model rc=1 (`оператор оболочки в команде`).
6. `npm --prefix mobile/evil;false test` — каталог с буквальным именем `evil;false` и package.json существует; shell завершит npm на `;` и запустит `false`. Product rc=0; model rc=1 (`оператор оболочки в команде`).
7. `npm --prefix mobile --prefix mobile test` — повторный флаг не входит в закрытую форму `npm [--prefix D] run <s>|test`. Product rc=0; model rc=1 (`npm вне закрытой формы`).

Причина: product канонизирует путь, но принимает абсолютный путь, если его canonical target внутри `$R` (`canon_inside_R`, строки 151–167); а метасимволы проверяются только в дополнительных токенах node/python3 после пути. Поле файла node, `--prefix` и npm script name метасимволы не проверяются. Цикл product также принимает сколько угодно `--prefix`. Контрпримеры 3–6 — именно «отказ, выглядящий успехом»: структурный gate зелёный, но командная строка при обычном shell-разборе обозначает другую команду/маскирует отказ.

Отдельно подтверждён симлинк-конец: `commands.test="npm --prefix mobile/pkg-leaf test"`, где `mobile/pkg-leaf` — symlink на существующий внешний каталог с package.json. Product rc=0, model rc=1 (`--prefix канонически вне дерева`). `canon_inside_R` канонизирует родителя, а не сам directory, и затем `-f "$dir/package.json"` следует симлинку наружу. Это второй самостоятельный обход правила «внутри $R».

Проверка не ловит эти профили: `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh` на OBJECT дала rc=0, `ИТОГ 112: клеток 40, зелёных 40, красных 0, rc=0`. Следовательно, существует зелёная батарея при неверной проверке подключения. Новые D34/D35/D36 честны против прежнего implementer: union-батарея с `PODKLJUCHENIE_112_CHECKER=/tmp/dev-harness-verify/Adv112r2/old/scripts/check_project_connection.sh` дала rc=1, итог `40 / 37 / 3`; красны ровно D34/D35/D36 (вывод D14/D16/D34–D36 в этом запуске — ожидаемые анти-плацебо контрмодели, не клетки продукта).

Прогоны (клон OBJECT `/tmp/dev-harness-verify/Adv112r2/m`):
- `red_podkljuchenie_112.sh` — rc=0, 40/40; state-слепая и komandy-слепая контрмодели предъявили ожидаемые расхождения D14/D16 и D34/D35/D36.
- `red_podkljuchenie_112.sh --model` — rc=0, 40/40.
- `red_podkljuchenie_112.sh --cell net-takoj-kletki` — rc=2 (есть сопутствующий шум `usage: command not found`).
- jq package check и awk registry check — rc=0; `gen_ci_steps.sh --write && --check` — rc=0; `verify_ci_parity.sh` — rc=0.
- `run_battery.sh profile_resolver` — rc=0 (4/4); `_krasnye_054.sh` — rc=0; `check_provodka.sh` — rc=0; `check_threat_model.sh` — rc=0.
- `PATH=/nonexistent /bin/bash scripts/check_project_connection.sh --repo <world>` — rc=2, `нет jq` (отсутствующий инструмент не ошибочно принят успехом).

Границы проверены: `61260217c..f27db3964` меняет только `scripts/check_project_connection.sh`; `f27db3964..OBJECT` — только три файла `fixtures/workshop_project/podklyuchenie_112/`; `git diff frozen/contracts/112/2^{commit}..HEAD -- contracts/112-podklyuchenie-proekta.md` пуст (0 строк).

Нужна правка автора: до разбора запретить shell-метасимволы во ВСЕХ токенах (включая file, --prefix и script), разрешать только один опциональный `--prefix`, отвергать абсолютные file/--prefix независимо от их цели и канонизировать сам путь directory/file до проверки принадлежности `$R`. Батарее нужны клетки на абсолютный путь внутри репо, метасимвол в file/--prefix/npm script, повторный --prefix и листовой prefix-symlink.

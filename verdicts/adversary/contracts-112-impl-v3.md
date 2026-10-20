FAIL
OBJECT=e564ed034ebfa15dc49e7a9e34e4a631bdb01b68

БЛОКЕР — проверка `kanon-remote` не сравнивает строку `git.canonicalRemote` побайтно, хотя это прямо требуется контрактом (п.2 «сравнение целых строк БУКВАЛЬНОЕ») и собственной шапкой `check_project_connection.sh` («целых строк байт-в-байт»). В `scripts/check_project_connection.sh` значение извлекается командной подстановкой:

    canon="$(printf '%s' "$OUT" | jq -r '.git.value.canonicalRemote // empty')"

Bash отрезает ВСЕ завершающие LF у результата `$(...)`. Поэтому профиль с каноном `"https://github.com/a3ka/Complior-mob.git\n"` принимается как равный origin `https://github.com/a3ka/Complior-mob.git`, хотя строки различаются завершающим байтом `0x0a`.

Наблюдаемый контрпример нового класса (ветвь `kanon-remote`, не `komandy`): `/tmp/dev-harness-verify/Adv112r3/probe_remote_newline.sh` строит честный минимальный mob-мир с настоящими layer/workflowPaths/state, четырьмя зарегистрированными npm scripts и origin без LF; единственная мутация — `git.canonicalRemote` в `harness.project.json` заканчивается на JSON `\n`. Прогон:

    "https://github.com/a3ka/Complior-mob.git\n"
    product_rc=0
    model_rc=0

Это именно «правильный ответ не на тот вопрос»: оба проверяющих судят уже усечённую оболочкой строку, а не объявленный байтовый канон. Полная батарея продукта при этом зелёная (`52/52` ниже), следовательно существует зелёная батарея при дефектной проверке подключения. Модель также требует починки/клетки; её согласие не снимает нарушение frozen-контракта.

Нужна правка implementer: не переносить `canonicalRemote` через command substitution или иное представление, режущее LF/байты; сравнить байтовый JSON-string с тем, что возвращает `git remote get-url origin`, и явно отвергать/диагностировать непередаваемые для POSIX argv байты. Architect нужен отдельный red-case для завершающего LF (и позитивный контроль обычного HTTPS-канона), иначе модель и батарея снова одинаково пропускают этот класс.

ПРОГОНЫ на локальном клоне OBJECT `/tmp/dev-harness-verify/Adv112r3/m`:
- `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh` → rc 0, `ИТОГ 112: клеток 52, зелёных 52, красных 0, rc=0`.
- `... --model` → rc 0, `52/52`; во время обоих полных прогонов ожидаемо напечатаны расхождения анти-плацебо state и komandy-контрмоделей D14/D16/D34–D48.
- `... --cell net-takoj-kletki` → rc 2 (известный шум `usage: command not found`).
- `probe_komandy.sh`: честный npm mob rc `impl=0 model=0`; все повторно предъявленные входы кругов 1–2 закрыты с `impl=1 model=1`: `node ... || true`, `node ... | cat`, `node ... || exit 0`, `npm --prefix .. test`, `npm --prefix mobile/../.. test`, prefix-symlink наружу, повторный `--prefix`; D34–D48 батареи дополнительно покрыли абсолютные/метасимвольные/npm-голое-имя варианты. Leaf-symlink node остаётся `0/0` (не новая находка: модель принимает его так же).
- Позитивный контроль: честный mob в `probe_komandy.sh` → `impl=0 model=0`.
- `PATH=/nonexistent /bin/bash scripts/check_project_connection.sh --repo <мир>` → rc 2, `нет jq`; отсутствие инструмента не принято за успех.
- Мутант node, вернувший raw абсолютный/`..` путь, краснеет: D34 rc 1, D35 rc 1. Мутант npm raw-склейки краснеет: D46 rc 1, D47 rc 1. Значит B4 закрыт клетками D34–D48.
- jq npm-проверка rc 0; awk registry-проверка rc 0; `gen_ci_steps.sh --write && --check` rc 0; `verify_ci_parity.sh` rc 0; `run_battery.sh profile_resolver` rc 0 (4/4); `_krasnye_054.sh` rc 0; `check_provodka.sh` rc 0; `check_threat_model.sh` rc 0.

Границы: `61260217c..9f549bec5` меняет только `scripts/check_project_connection.sh`; fixture-diff до OBJECT содержит только `model_check_connection.sh` и `red_podkljuchenie_112.sh`. `git diff --numstat frozen/contracts/112/2^{commit}..HEAD -- contracts/112-podklyuchenie-proekta.md` пуст. Model diff от 61260217c — 53 additions/12 deletions; по проверенной komandy-логике это ужесточение, а не причина данного FAIL.

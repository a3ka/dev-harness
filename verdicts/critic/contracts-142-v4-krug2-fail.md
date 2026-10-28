FAIL
OBJECT=25bda0985633349953a9bf635f1b825d8be7658d
СУД: repo=dev-harness; предмет=142; фаза=контракт v4 (правка после критика 1/2); роль=critic; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit142v4b (внутренний trace-id не предоставлен); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=25bda0985633349953a9bf635f1b825d8be7658d; предыдущий=/tmp/dev-harness-verify/Crit142v4/verdicts/critic/contracts-142-v4.md (FAIL); исключение=нет.

Предмет: `git cat-file -t 25bda0985633349953a9bf635f1b825d8be7658d` → `commit`, `git rev-parse HEAD` клона → тот же SHA; автор коммита `architect`. Предмет, критерий с командами и исполнительские ЗОНА-строки присутствуют. Судился только закоммиченный кандидат. Слово владельца 28.10 разрешает **расширить** userinfo до `https://<токен>@host`, но не убирать защиту существующих `user:pass@` форм.

БЛОКИРУЕТ contracts/142-skaner-sekretov.md:42-45,43,99,234-235 — класс: несанкционированное сужение стража по безопасности; критерий ложно достаточен. Привязать двоеточие-ветвь к authority внешнего **абсолютного** URL, чтобы устранить ложные отказы k111/k112, обоснованно вердиктом 1/2 и болью владельца на `METERING_PROXY_URL`. Но одновременно канон `^[^/?#[:space:]]*:[^/?#[:space:]]*@` перестаёт защищать **настоящие учётные данные в authority внешнего адреса без схемы**: `//user:pass@host/path` — network-path reference, относительный URL, содержащий username/password. V1/V3 ловил этот ввод двоеточие-ветвью, v4 его отпускает только потому, что первый `/` расположен ДО `user:pass@`. Это не `git@host:path` и не `token@host` без двоеточия: §НЕ ЗАЩИЩАЕТ не объявляет эту утрату, а §ПРОВОДКА без оговорки обещает защиту `user:pass@`. Защита реального секрета отключена, не просто снят ложный отказ. Семь красных клеток v4 проверяют новые ложные отказы на абсолютных URL и новые токены, но ни одна не запрещает данную регрессию; даже честная модель проходит `W --model` 146/146.
ОБЯЗАТЕЛЬСТВО: И-2/И-3 — адресный ключ с учётными данными судится; И-4 — единственное разрешённое сужение относительно нынешнего стража относится к адресным значениям БЕЗ учётных данных; И-5 — при утечке секрета именованный отказ до workshop; слово владельца 28.10 — расширение канона, не отказ от `user:pass@`.
СОСТОЯНИЕ: в изолированном mktemp-мире поддельный `$HOME/.config/dev-harness/secrets.env` содержит `GIT_URL=//user:pass@host/path`; индексируемый `leak.txt` проекта содержит то же значение; двойник `workshop` записывает факт запуска. URL реально имеет authority с учётными данными: `new URL('//user:pass@host/path','https://base.invalid/')` даёт `https://user:pass@host/path`, `username=user`, `password=pass`.
НАБЛЮДЕНИЕ: `bash /tmp/dev-harness-verify/Crit142v4b/door_matrix.sh` → `userinfo-double-slash/v3 rc=1 calls=0 reject=1 exposed=0`, `userinfo-double-slash/v4 rc=0 calls=1 reject=0 exposed=0`; `node /tmp/dev-harness-verify/Crit142v4b/parse_url.cjs` → `{"href":"https://user:pass@host/path","username":"user","password":"pass","host":"host"}`. Закрывающее свойство: судить user:pass в authority в обеих фактически допустимых URL-формах (`scheme://user:pass@host` и `//user:pass@host`) под адресным именем, не считая userinfo символ `@` ПОСЛЕ первого path/query/fragment абсолютного URL. Закрепить красной клеткой для `//user:pass@host/path` с утечкой; приёмка должна отличать защиту от честной нынешней зелени. Если владелец намерен исключить scheme-relative URL, только его явное решение может разрешить уменьшить защиту, не подразумеваемый вывод из разрешения токен-ветви.
ОБХОД: поставить в субъект честную модель v4 из `fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh`: батарея `W --model` rc 0 146/146, `P/Q` 70/70 и 87/87, `W --stabs` ловит все 220 назначенных связок, но индексируемое `GIT_URL=//user:pass@host/path` проходит дверь rc 0 и вызывает workshop.

АРБИТР: созвать арбитра контракта 142 по исчерпанию critic 2/2; предмет инженерного спора — вправе ли v4 разрешить scheme-relative URL с `user:pass` в authority, когда слово владельца разрешает лишь расширение токен-ветви, а И-4 допускает снятие защиты только у адресов без учётных данных. Арбитраж не даёт accept и не открывает третьего круга: для повторного critic-вызова после исправления требуется слово владельца (§Быстрый-процесс §Остановка).

### Измерения (сырые существенные строки; все команды выполнялись в `/tmp/dev-harness-verify/Crit142v4b/repo`, кроме явно указанной двери 125/136)

```
$ bash /tmp/dev-harness-verify/Crit142v4b/door_matrix.sh
port-query/v3 rc=1 calls=0 reject=1 exposed=0
port-query/v4 rc=0 calls=1 reject=0 exposed=0
port-fragment/v3 rc=1 calls=0 reject=1 exposed=0
port-fragment/v4 rc=0 calls=1 reject=0 exposed=0
nested-query/v3 rc=0 calls=1 reject=0 exposed=0
nested-query/v4 rc=0 calls=1 reject=0 exposed=0
nested-path/v3 rc=0 calls=1 reject=0 exposed=0
nested-path/v4 rc=0 calls=1 reject=0 exposed=0
nested-fragment/v3 rc=0 calls=1 reject=0 exposed=0
nested-fragment/v4 rc=0 calls=1 reject=0 exposed=0
token/v3 rc=0 calls=1 reject=0 exposed=0
token/v4 rc=1 calls=0 reject=1 exposed=0
token-port/v3 rc=0 calls=1 reject=0 exposed=0
token-port/v4 rc=1 calls=0 reject=1 exposed=0
one-char-token/v3 rc=0 calls=1 reject=0 exposed=0
one-char-token/v4 rc=1 calls=0 reject=1 exposed=0
userinfo-scheme/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-scheme/v4 rc=1 calls=0 reject=1 exposed=0
userinfo-no-scheme/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-no-scheme/v4 rc=1 calls=0 reject=1 exposed=0
userinfo-scp-like/v3 rc=0 calls=1 reject=0 exposed=0
userinfo-scp-like/v4 rc=0 calls=1 reject=0 exposed=0
userinfo-hostport/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-hostport/v4 rc=1 calls=0 reject=1 exposed=0
userinfo-double-slash/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-double-slash/v4 rc=0 calls=1 reject=0 exposed=0
userinfo-after-path/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-after-path/v4 rc=0 calls=1 reject=0 exposed=0
userinfo-after-query/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-after-query/v4 rc=0 calls=1 reject=0 exposed=0
userinfo-after-fragment/v3 rc=1 calls=0 reject=1 exposed=0
userinfo-after-fragment/v4 rc=0 calls=1 reject=0 exposed=0
[exit=0]
$ node /tmp/dev-harness-verify/Crit142v4b/parse_url.cjs
{"href":"https://user:pass@host/path","username":"user","password":"pass","host":"host"}
[exit=0]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model   # каждый из трёх отдельных последовательных вызовов
s142 model: клеток 146, зелёных 146, красных 0
s142 model: клеток 146, зелёных 146, красных 0
s142 model: клеток 146, зелёных 146, красных 0
[exit=0, exit=0, exit=0]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --stabs
s142 model-opora-stabov: клеток 146, зелёных 146, красных 0
ПОЙМАН stab_min-dlina-tokena @ k107-odinosimvolnyj-token
ПОЙМАН stab_token-bez-yakorya @ k108-vlozhennyj-url-v-zaprose
ПОЙМАН stab_token-bez-yakorya @ k109-vlozhennyj-url-v-puti
ПОЙМАН stab_token-bez-yakorya @ k110-vlozhennyj-url-v-fragmente
ПОЙМАН stab_dvoetochie-bez-granicy @ k111-port-v-zaprose
ПОЙМАН stab_dvoetochie-bez-granicy @ k112-port-v-fragmente
s142 stabs: стабов 40, привязок 220, непойманных 0
[exit=0; остальные однотипные сырые строки поимок: artifact://8814]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
КЛЕТКА k99-git-url-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k100-repo-url-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k101-endpoint-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k107-odinosimvolnyj-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k111-port-v-zaprose КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0
КЛЕТКА k112-port-v-fragmente КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 subjekt: клеток 146, зелёных 139, красных 7
[exit=1]
$ bash fixtures/workshop_project/skaner_sekretov_142/stabs/stab_min-dlina-tokena.sh fixtures/workshop_project/skaner_sekretov_142/model /tmp/dev-harness-verify/Crit142v4b/model-door/scripts/connect_project.sh
[exit=0]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Crit142v4b/model-door
КЛЕТКА k107-odinosimvolnyj-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 repo: клеток 146, зелёных 144, красных 2
[exit=1]
$ bash fixtures/workshop_project/sessii_125/red_sessii_125.sh   # cwd=/tmp/dev-harness-verify/Crit142v4b/model-door, ДО применения min-dlina мутанта
s125 red: зелёных 70, красных 0
[exit=0]
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh   # cwd=model-door, ДО мутации
sessii_136: клеток 87, зелёных 87, красных 0
[exit=0]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model   # cwd=tamper-door, модель пуста
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
[exit=2]
```

`python3 /tmp/dev-harness-verify/Crit142v4b/audit_delta.py`: frozen 142/3 → 132 старые оси без потерь/изменений + k99–k112; critic 1/2 → 140 старых осей без потерь/изменений + ровно k107–k112; `.stab_vhod` 31/197 → 37/214 → 40/220, прежние привязки без изменений. `python3 /tmp/dev-harness-verify/Crit142v4b/contract_hunks.py`: 19 опкодов дельты текста, все в перечне §Замены v4 (1–18 плюс добавленный раздел с описанием перепривязок); неизменные И-3…И-7, NUL/страж 125, зона, абзацы пересечений; И-1/И-2 изменены адресно, но с доказанным выше нежелательным последствием. `python3 /tmp/dev-harness-verify/Crit142v4b/audit_stabs.py`: все 7 перепривязаны на новую канон-строку; их мутации сохраняют прежние классы неисправности и ловятся на назначенных клетках, Н-39 привязка остаётся в source.json/коде; текст «ловится»→«судится» не был заменой механизма.

Гейты: `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit142v4b/repo contracts/142-skaner-sekretov.md` → `КРИТИК: дверь зелёная`, rc 0; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit142v4b/repo contracts/142-skaner-sekretov.md` → `OK`, rc 0; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit142v4b/repo contracts/142-skaner-sekretov.md` → `OK`, rc 0; `bash scripts/check_ceilings.sh` → `потолки в порядке`, rc 0; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit142v4b/repo contracts/142-skaner-sekretov.md` → `секция валидна (ЗАЩИЩАЕТ 13 буллет(ов), НЕ ЗАЩИЩАЕТ 12 буллет(ов))`, rc 0. `check_provodka.sh` → `проводка: норма-строка не найдена в role-файле: roles/orchestrator.md`, rc 1 (owner-коммит после freeze объявлен); `check_charter.sh` → `FAIL уставной документ изменён без разрешения владельца: contracts/142-skaner-sekretov.md в 25bda098`, rc 1 (ожидаемая заглушка, не причина настоящего FAIL). `git diff --name-only HEAD~1..HEAD`: ровно 14 файлов под контрактом и семьёй в ЗОНА architect. `git -C /tmp/dev-harness-verify/Crit142v4b/origin rev-parse frozen/contracts/142/3` → `57a415ede105c96fbd25ecc7d64da2798580fce4`, rc 0 (отдельный SSH-клон origin). `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit142v4b/repo contracts/142-skaner-sekretov.md` запущен последним из гейтов: первый прогон прерван лимитом 120 с без результата, повтор с лимитом 900 с завершился строкой `замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 35677 · проверено по зонам: 7810`, без FAIL (rc 0 по завершающей ветви скрипта).

СОВЕТ contracts/142-skaner-sekretov.md:234-235 — явное различение буквального `user:pass@` в query/path (теперь адресная строка запускается, независимо от наличия пароля в литерале, осознанный риск вне authority) и секретов внутри protocol-relative authority полезно как часть модели угроз. Первое не блокирует в согласованной границе предыдущего критика; второе — отдельный БЛОКЕР выше, пока нет прямого решения владельца.

Не проверено: реальные секреты дома (запрещено); роль после будущего owner-коммита, фактическая модель архитектора и независимость по его trace, живой workshop. Ни commit, ни push не выполнялись.

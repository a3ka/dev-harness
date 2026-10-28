accept
OBJECT=5cc37a937bc2f9638d1d9afefc3ea49bb1cad1fc
СУД: repo=dev-harness; предмет=142; фаза=контракт v4 (один scoped-критик после арбитража Q3 по слову владельца 25.10); роль=critic; вызов=3 (разрешённое исключение сверх 2/2); модель-план=openai-codex/gpt-6-sol; сессия=Crit142v4c (внутренний trace-id не предоставлен); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=5cc37a937bc2f9638d1d9afefc3ea49bb1cad1fc; предыдущий=critic 1/2 FAIL OBJECT 69d67a50, critic 2/2 FAIL OBJECT 25bda098, verdicts/arbitration/contracts-142-v4-arbitraz.md РЕШЕНИЕ; исключение=один scoped-вызов после арбитража по слову владельца 25.10.

Суд только закоммиченного кандидата и замкнутого перечня Q3. `git -C /tmp/dev-harness-verify/Arch142v4/repo cat-file -t 5cc37a937bc2f9638d1d9afefc3ea49bb1cad1fc` → `commit`, rc 0. Клон `/tmp/dev-harness-verify/Crit142v4c/repo`: `git log -2 --format='%H %an %s'` → HEAD `5cc37a937bc2f9638d1d9afefc3ea49bb1cad1fc architect`, родитель `2ac3c2869dd63eff46c83700b690b3d0943e1646`. Тег `frozen/contracts/142/3` в origin = `57a415ede105c96fbd25ecc7d64da2798580fce4`. Предмет, приёмка командами и названные зоны/исполнители есть. Риск «безопасность» соответствует стражу утечки.

### Канон, границы, текст

`jq -r .kanon.userinfo_re fixtures/workshop_project/skaner_sekretov_142/source.json` → `(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)`; тот же литерал в `model/connect_project.sh:321` и `contracts/142-skaner-sekretov.md:42`; `git show frozen/contracts/142/3:fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh` → исходная альтернатива `[^/@[:space:]]*:[^/@[:space:]]*@`; строка main `scripts/connect_project.sh` та же. Токен-ветвь заякорена, схема необязательна. `sha256sum fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh` → `e2f5c3945a191c79e26757cb49b87348aad396abc69ebf7c709428716f693504`, совпадает с `.model_sha256`. `git diff 25bda098 5cc37a937 -- fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh`: после удаления строк комментария изменена ТОЛЬКО канон-строка. Двоеточие-ветвь буквально включает v3, поэтому как свойство POSIX ERE не может снять v3-поимку при тех же входах; живой замер ниже независимо подтверждает 54 случая.

`python3 /tmp/dev-harness-verify/Crit142v4c/audit.py` → против 25bda098: оси 146→150, добавлены только k113–k116, изменены только `vid` k111/k112 (`sessija`→`otkaz`); K=116, Z=7, F=7, D=5, N=12, R=3. Против frozen 142/3: 132→150, сохранены без изменения все 132 старые объекты, включая k1–k98, N/Z/F/D/R. Остальные ключи source.json не менялись, в `.kanon` изменено только `userinfo_re`. `.stab_vhod`: 40→43, удалён только `stab_dvoetochie-bez-granicy`, добавлены ровно четыре мутанта Q3, старые привязки не изменены. `jq -r '.osi|length, .stab_vhod|length, ([.stab_vhod[]|length]|add)' source.json` (эквивалентные отдельные jq-выражения) → 150, 43, 232; физически 43 файла стабов. Четыре новые привязки по коду: OBJECT → k111–k116 (6), якорь двоеточия → k111/k112/k115 (3), вырезанные `?#` → k111/k112/k115/k116 (4), токен только со схемой → k114 (1). Девять перепривязанных стабов сохраняют старые классы: без токена (k99–k101), токен без якоря (k108–k110), без границы (k104/k105), пустой токен (k106), `https`-only (k101), двоеточие после схемы (z6/k32–k42), схема+непустой user (z6/z7), где-угодно (k102/k103), min-длина (k107). Строки мутантов новые Q3 побайтово соответствуют таблице арбитра; `--stabs` подтвердил их эффект ниже.

`git diff frozen/contracts/142/3 5cc37a937 -- contracts/142-skaner-sekretov.md` и `git diff 25bda098 5cc37a937 -- contracts/142-skaner-sekretov.md`: содержательные ханки только в шапке/воле/нарезке, И-1/2/4, приёмочных числах и сценариях, §Замены v4 (включая новый п.20), цитате role=, §Модель угроз и §Сдача, как Q3. И-3/5/6/7, §Демаркация, все ЗОНА-строки, §ПРОВОДКА-ЭНФОРСМЕНТ относительно 25bda098, страж 125 и пересечения 125/136 — неизменны. И-2 называет `user:pass@`/`:pass@` в ЛЮБОМ месте; И-4 явно v4 ⊇ v3. `role=` различает двоеточие в любом месте и одиночный `@` за `/?#`, цитата целиком самостоятельна. В §НЕ ЗАЩИЩАЕТ прямо названы `git@host:path`, `tok@host` без `//`, `%40`, пробел, сырой `?`/`#` в токене, пустой `://@`; отдельно цена fail-closed `mailto:admin@x`, `host:80?u=a@b`, `X:Y@` после разделителя, снять только словом владельца. Арбитр в прозе назвал «47 входов», фактический `cases.txt` содержит **46 уникальных** строк значений (`audit.py`); контракт честно указывает 46 «дерево — истина», не приписывает себе 47.

### Живая ДО/ПОСЛЕ-матрица

Команда из клона: `python3 /tmp/dev-harness-verify/Crit142v4c/audit.py --matrix` → rc 0, `DOOR MATRIX rc 0`, `V3-REJECTIONS-LOST [] ROWS 54`. Она передаёт 46 входов арбитра плюс 8 моих (`user:p?ss@host/db`, `https://host:80?u=a@b`, вложенные URL с `u:p@` после `?`/`/`/`#`, токен с пробелом, `//x@host`, `:pass@host`) в `bash /tmp/dev-harness-verify/Crit142v4c/door_matrix.sh`. Скрипт для КАЖДОЙ строки × 2 двери создаёт отдельный git-проект, поддельный `$HOME/.config/dev-harness/secrets.env` с адресным `GIT_URL=<значение>`, индексируемый `leak.txt` с этим значением, двойник workshop с записью вызова. ДО = `scripts/connect_project.sh` main/v3; ПОСЛЕ = модель OBJECT. Обозначения в следующей матрице: `1` = `rc=1 calls=0 reject=1 exposed=0`, `0` = `rc=0 calls=1 reject=0 exposed=0`. Для всех 108 опытов `exposed=0`.

| входы из `cases.txt` + мои | ДО/ПОСЛЕ |
|---|---|
| port-query, port-fragment, userinfo-scheme, userinfo-no-scheme, userinfo-hostport, userinfo-double-slash, userinfo-after-path, userinfo-after-query, userinfo-after-fragment, double-slash-path, host8080-at, upper-scheme-userinfo, ftp-userinfo, quoted-userinfo, crlf-userinfo, pwd-hash, pwd-question, pwd-hash-noscheme, pwd-question-noscheme, redis-empty-user, mailto | 1/1 |
| user-question-noscheme, host8080-query, nested-query-creds, nested-path-creds, nested-fragment-creds, colon-only | 1/1 |
| token, token-port, one-char-token, double-slash-token, double-slash-token-path, upper-scheme, quoted-token, crlf-token, ipv6-token, two-at, one-char-relative | 0/1 |
| nested-query, nested-path, nested-fragment, userinfo-scp-like, at-after-slash, at-in-query, at-in-fragment, k111-like, pain-26-10, quoted-address, space-in-userinfo, space-before-at, empty-token, ipv6-address, scheme-less-token, space-scheme | 0/0 |

Сырые существенные строки той же команды:
```
port-query | v3 rc=1 calls=0 reject=1 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
userinfo-double-slash | v3 rc=1 calls=0 reject=1 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
double-slash-path | v3 rc=1 calls=0 reject=1 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
pwd-hash | v3 rc=1 calls=0 reject=1 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
pwd-question-noscheme | v3 rc=1 calls=0 reject=1 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
userinfo-after-query | v3 rc=1 calls=0 reject=1 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
double-slash-token-path | v3 rc=0 calls=1 reject=0 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
one-char-relative | v3 rc=0 calls=1 reject=0 exposed=0 | after rc=1 calls=0 reject=1 exposed=0
nested-query | v3 rc=0 calls=1 reject=0 exposed=0 | after rc=0 calls=1 reject=0 exposed=0
pain-26-10 | v3 rc=0 calls=1 reject=0 exposed=0 | after rc=0 calls=1 reject=0 exposed=0
V3-REJECTIONS-LOST [] ROWS 54
```

### Сырые команды / rc батарей и атак

Все `W` ниже запущены из `/tmp/dev-harness-verify/Crit142v4c/repo`, по ОДНОЙ батарее синхронно; автоматическое фоновое выполнение `W --stabs` дождались до итоговой строки. `W=bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh`.
```
$ W --model                 # три отдельных вызова
s142 model: клеток 150, зелёных 150, красных 0
s142 model: клеток 150, зелёных 150, красных 0
s142 model: клеток 150, зелёных 150, красных 0
[rc=0,0,0]
$ W --stabs
s142 model-opora-stabov: клеток 150, зелёных 150, красных 0
ПОЙМАН stab_kanon-object-25bda098 @ k111-port-v-zaprose
ПОЙМАН stab_kanon-object-25bda098 @ k112-port-v-fragmente
ПОЙМАН stab_kanon-object-25bda098 @ k113-userinfo-scheme-relative
ПОЙМАН stab_kanon-object-25bda098 @ k114-token-scheme-relative
ПОЙМАН stab_kanon-object-25bda098 @ k115-reshetka-v-parole
ПОЙМАН stab_kanon-object-25bda098 @ k116-vopros-v-parole
ПОЙМАН stab_dvoetochie-s-yakorem @ k111-port-v-zaprose
ПОЙМАН stab_dvoetochie-s-yakorem @ k112-port-v-fragmente
ПОЙМАН stab_dvoetochie-s-yakorem @ k115-reshetka-v-parole
ПОЙМАН stab_dvoetochie-bez-voprosa-reshetki @ k111-port-v-zaprose
ПОЙМАН stab_dvoetochie-bez-voprosa-reshetki @ k112-port-v-fragmente
ПОЙМАН stab_dvoetochie-bez-voprosa-reshetki @ k115-reshetka-v-parole
ПОЙМАН stab_dvoetochie-bez-voprosa-reshetki @ k116-vopros-v-parole
ПОЙМАН stab_token-tolko-so-shemoj @ k114-token-scheme-relative
s142 stabs: стабов 43, привязок 232, непойманных 0
[rc=0; между этими строками — поимки остальных 218 привязок, полный сырой вывод в tool artifact://9017]
$ W
КЛЕТКА k99-git-url-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k100-repo-url-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k101-endpoint-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k107-odinosimvolnyj-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k114-token-scheme-relative КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 subjekt: клеток 150, зелёных 144, красных 6
БОЛЬ-SEJCHAS: красные клетки перечислены выше (до реализации это ожидаемо)
[rc=1]
$ W --repo /tmp/dev-harness-verify/Crit142v4c/prior-subject
КЛЕТКА k111-port-v-zaprose КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=X09D440F451C4_HOST
КЛЕТКА k112-port-v-fragmente КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=XE2D0CF5BAC6D_HOST
КЛЕТКА k113-userinfo-scheme-relative КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=X9CD3497204B7_URL
КЛЕТКА k114-token-scheme-relative КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k115-reshetka-v-parole КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k116-vopros-v-parole КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 repo: клеток 150, зелёных 143, красных 7
[rc=1; prior-subject = одноразовый клон OBJECT 25bda098, его model/connect_project.sh скопирован в scripts/connect_project.sh]
$ W --repo /tmp/dev-harness-verify/Crit142v4c/model-door
s142 repo: клеток 150, зелёных 150, красных 0
[rc=0; model-door = клон OBJECT, модель скопирована в scripts/connect_project.sh]
$ W --model # отдельный клон tamper-door с пустым model/connect_project.sh
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
[rc=2]
$ W --repo /tmp/dev-harness-verify/Crit142v4c/absent-door
КЛЕТКА k1-api-key КРАСНА: SUBJECT_ABSENT: /tmp/dev-harness-verify/Crit142v4c/absent-door/scripts/connect_project.sh
…
КЛЕТКА r3-nul-predproverka-v-subekte КРАСНА: SUBJECT_ABSENT: /tmp/dev-harness-verify/Crit142v4c/absent-door/scripts/connect_project.sh
s142 repo: клеток 150, зелёных 0, красных 150
[rc=1]
$ bash fixtures/workshop_project/sessii_125/red_sessii_125.sh # cwd=model-door
s125 red: зелёных 70, красных 0
[rc=0]
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh # cwd=model-door
sessii_136: клеток 87, зелёных 87, красных 0
[rc=0]
```

Собственная мутация (одноразовый `own-mutant/scripts/connect_project.sh`): честная модель с единственной заменой `USERINFO_RE='(^…|v3)'` → `USERINFO_RE='^((…)|v3)'`, то есть якорь на ВСЁМ выражении ошибочно отменяет поиск v3-фрагмента не в начале значения. Команда и сырой вывод:
```
$ W --repo /tmp/dev-harness-verify/Crit142v4c/own-mutant
КЛЕТКА k111-port-v-zaprose КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=XDFBD9799FAD8_HOST
КЛЕТКА k112-port-v-fragmente КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=X4DDF25420D3F_HOST
КЛЕТКА k115-reshetka-v-parole КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 repo: клеток 150, зелёных 146, красных 4
[rc=1]
```
Поимка не только r1: k111/k112/k115 доказывают поведение на входах арбитража.

### Гейты и ограничения

```
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
OK
[rc=0]
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
OK
[rc=0; отдельный прогон на тихой машине]
$ bash scripts/check_ceilings.sh
потолки в порядке
[rc=0]
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 13 буллет(ов), НЕ ЗАЩИЩАЕТ 13 буллет(ов))
[rc=0]
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
проводка: норма-строка не найдена в role-файле: roles/orchestrator.md
[rc=1; ожидаемый owner-коммит ПОСЛЕ freeze]
$ bash scripts/check_charter.sh /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
  FAIL уставной документ изменён без разрешения владельца: contracts/142-skaner-sekretov.md в 5cc37a93 — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/142-skaner-sekretov.md <причина>» в первой колонке
уставных документов: 141 · изменений в них: 356 · с разрешения: 355
[rc=1; ровно заглушка `ОЖИДАЕТСЯ-СЛОВО-ВЛАДЕЛЬЦА` в commit body, разрешённая рамкой задания: подставляет оркестратор при сборке поезда; иного FAIL этот вывод не содержит]
```

БЛОКИРУЕТ: находок по закрытому перечню арбитража Q3 нет. СОВЕТ: находок по Q3 нет. НЕ проверено: реальный дом секретов (запрещено), живой workshop станции/фактическое внедрение в `scripts/connect_project.sh` (это будущая зона implementer), роль после будущего owner-коммита, независимость модели автора по внутреннему trace (не предъявлен; судья фактически Sol по workstation). Коммитов и push критик не делал; вердикт — файл в назначенном каталоге для оркестратора.

Последний гейт (дождались именно завершения фонового задания `bg_1157`, не подменяли `wait` пустым ответом):
```
$ bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit142v4c/repo contracts/142-skaner-sekretov.md
процессных вне суда:
замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 35677 · проверено по зонам: 7810
[completed; отказов в полном выводе нет, итоговая строка получена после 310.18 с; инструмент фонового задания не вывел отдельный rc]
```
`git diff --name-only HEAD~1..HEAD` → 17 путей, каждый внутри `contracts/142-skaner-sekretov.md` либо `fixtures/workshop_project/skaner_sekretov_142/` (ЗОНА architect); других путей нет.

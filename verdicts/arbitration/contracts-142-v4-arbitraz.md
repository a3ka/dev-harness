РЕШЕНИЕ
OBJECT=25bda0985633349953a9bf635f1b825d8be7658d
СУД: repo=dev-harness; предмет=142; фаза=контракт v4 (арбитраж по исчерпанию critic 2/2, §Быстрый-процесс); роль=arbiter; вызов=1; модель-план=anthropic/claude-fable-5-1; сессия=Arb142v4 (внутренний trace-id не предоставлен); модель-факт=anthropic/claude-fable-5-1 (workstation); SHA=25bda0985633349953a9bf635f1b825d8be7658d; предыдущие=`/tmp/dev-harness-verify/Crit142v4/verdicts/critic/contracts-142-v4.md` (1/2 FAIL, OBJECT 69d67a50), `/tmp/dev-harness-verify/Crit142v4b/verdicts/critic/contracts-142-v4b.md` (2/2 FAIL, OBJECT 25bda098); исключение=нет.

Предмет: `git -C /tmp/dev-harness-verify/Arch142v4/repo cat-file -t 25bda098…` → `commit`; `rev-parse HEAD` → тот же SHA, ветка `wip/142/architect-v4`, один коммит поверх main `2ac3c286`, автор `architect`. Клон read-only `/tmp/dev-harness-verify/Arb142v4/repo`; origin-клон для тега `frozen/contracts/142/3` → `57a415ede105c96fbd25ecc7d64da2798580fce4` (`cat-file -t` → `tag`). Дверь v3 = `scripts/connect_project.sh` на OBJECT (= main; канон-строка `USERINFO_RE='[^/@[:space:]]*:[^/@[:space:]]*@'` байт в байт равна модели `frozen/contracts/142/3`, строка 305 обеих). Ни коммита, ни push из каталога арбитра не было (ограничение задания); реальный дом секретов не читался — все миры поддельные `$HOME`.

## Суть решения (одной строкой)

Критик 2/2 прав по факту и по праву; его закрывающее свойство — НЕДОСТАТОЧНО: замер арбитра нашёл второе, более тяжёлое сужение OBJECT, которого ни один критик не предъявил — пароль с сырым `#`/`?` (`postgres://user:p#ss@host/db`, `user:p?ss@host`) дверь v3 судит (rc 1), модель v4 ПРОПУСКАЕТ (rc 0, workshop вызван). Причина обоих сужений одна: двоеточие-ветвь канона переписана (якорь `^`, класс без `?#`), хотя слово владельца 28.10 разрешило только РАСШИРЕНИЕ, а замороженное определение 142/3 И-2 гласит дословно: «Userinfo — ЛЮБОЙ фрагмент `user:pass@`/`:pass@` в значении, без привязки к схеме». Решение: двоеточие-ветвь ВОЗВРАЩАЕТСЯ к строке v1/v3 байт в байт (без якоря, классы `[^/@[:space:]]`); токен-ветвь остаётся с якорем начала значения (блокер 1 критика 1/2 — верен для токен-ветви) и получает необязательную схему, чтобы судить `//<токен>@host`. Канон — одна строка POSIX ERE, один `grep -Eq`, без lookahead: v4 ⊇ v3 ПО ПОСТРОЕНИЮ (строка v3 — буквальная альтернатива дизъюнкции), И-4 доказывается чтением, а не только матрицей.

## Q1. Канон: кто прав, какая строка

**Критик 2/2 прав**: `//user:pass@host/path` — network-path reference с userinfo в authority (`urlsplit` → `username='user', password='pass'`), дверь v3 rc 1, модель OBJECT rc 0 (замер арбитра совпал с замером критика). Это сужение защиты существующей формы `user:pass@` — вне слова 28.10 и вне единственного разрешённого сужения И-4 (адресное значение БЕЗ учётных данных).

**Закрывающее свойство критика 2/2 отклоняется как недостаточное** («судить `user:pass` в authority обеих форм, не считая `@` ПОСЛЕ первого path/query/fragment»): оставив классу userinfo границы `?`/`#`, оно сохраняет найденный арбитром пропуск пароля с `#`/`?` (строки `pwd-*` матрицы ниже). Форма `scheme://A:B?C@D` для `host:80?u=a@b` (порт + `@` в запросе) и для `user:p?ss@host` (пароль с `?`) СИНТАКСИЧЕСКИ ОДНА (`urlsplit` обеих даёт netloc `A:B`, query `C@D`); регэксп без семантики («порт — цифры») их не разделит, а попытка разделить цифрами открывает `user:1234?x@host`/`user:#pass@host`. На неразделимой двусмысленности последний страж утечки судит fail-closed — как и судил v3.

**Альтернатива Q1 (двоеточие-ветвь v1/v3 без якоря «с ограничением только на `@` после первого `/?#`»)** — отклонена: любое ограничение двоеточие-ветви относительно v3 есть сужение замороженного определения «ЛЮБОЙ фрагмент в значении»; по регламенту роли это «чего мы хотим», а не «как правильно» — решает владелец, не арбитр и не критики (черновик строки для владельца — §Q4).

**Канон-кандидат (ПРИНЯТ; одна строка, POSIX ERE, один `grep -Eq`):**

```
USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
```

- токен-ветвь `^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@` — от НАЧАЛА значения необязательная `схема:`, затем `//`, затем непустой фрагмент authority без `/`/`?`/`#`/пробела, затем `@`: `https://<токен>@host`, `//<токен>@host`, `https://user:pass@host`, `//user:pass@host`; `@` после первого `/`/`?`/`#` внешнего адреса (вложенный URL, k108–k110; `@` в запросе/фрагменте, k104/k105) — не ловится;
- двоеточие-ветвь `[^/@[:space:]]*:[^/@[:space:]]*@` — БАЙТ В БАЙТ строка v1/v3 (frozen 142/3 И-1), без якоря и без границ `?`/`#`: `user:pass@host`, `:pass@`, `user:p#ss@`, `//user:pass@host`, `mailto:admin@x`, `host:80?u=a@b` — всё, что судила v3, судится и дальше.

Относительно OBJECT канон меняет ровно два места: `^[^/?#[:space:]]*://` → `^([^/?#[:space:]]*:)?//` (необязательная схема) и вторая ветвь → строка v3.

### Матрица ДО(v3)/OBJECT(v4)/ПОСЛЕ(cand) — 47 входов, живые двери в поддельном HOME

Команда: `bash /tmp/dev-harness-verify/Arb142v4/door_matrix.sh < /tmp/dev-harness-verify/Arb142v4/cases.txt` (мир — слепок мира критика 2/2: `GIT_URL=<значение>` в поддельном `secrets.env`, то же значение в индексируемом `proj/leak.txt`, двойник `workshop` пишет факт вызова; `rc=1 calls=0 reject=1` = отказ `sekret-v-dereve` до workshop; `rc=0 calls=1` = сессия; `exposed` = значение в stderr). Дверь cand = модель OBJECT с ОДНОЙ заменённой канон-строкой (`mkcand.py`, diff к модели — одна строка). Сырой вывод (сокращены только повторяющиеся поля `exposed=0` — ни одна дверь ни на одном входе значение не печатала):

| вход | значение | v3 | OBJECT v4 | cand | класс |
|---|---|---|---|---|---|
| port-query | `https://host:80?u=a@b` | rc1 | rc0 | rc1 | неразделимо с `user:p?ss@host`; fail-closed, паритет v3 (k111) |
| port-fragment | `https://host:80#u=a@b` | rc1 | rc0 | rc1 | то же (k112) |
| nested-query | `https://host?redirect=https://tok@other` | rc0 | rc0 | rc0 | токен после `?` — не userinfo (k108) |
| nested-path | `https://host/p?next=https://tok@other` | rc0 | rc0 | rc0 | k109 |
| nested-fragment | `https://host#next=https://tok@other` | rc0 | rc0 | rc0 | k110 |
| token | `https://tok@host` | rc0 | rc1 | rc1 | РАСШИРЕНИЕ (слово 28.10) |
| token-port | `https://tok@host:8080/x` | rc0 | rc1 | rc1 | расширение |
| one-char-token | `https://x@host` | rc0 | rc1 | rc1 | расширение (k107) |
| userinfo-scheme | `http://user:pass@host` | rc1 | rc1 | rc1 | паритет |
| userinfo-no-scheme | `user:pass@host/path` | rc1 | rc1 | rc1 | паритет |
| userinfo-scp-like | `git@host:path` | rc0 | rc0 | rc0 | остаток (все три) |
| userinfo-hostport | `host:port@x` | rc1 | rc1 | rc1 | паритет |
| userinfo-double-slash | `//user:pass@host` | rc1 | **rc0** | rc1 | блокер критика 2/2 — ЗАКРЫТ |
| userinfo-after-path | `https://host/p?u=user:pass@b` | rc1 | **rc0** | rc1 | сужение OBJECT вне слова — ОТКЛОНЕНО, паритет v3 |
| userinfo-after-query | `https://host?u=user:pass@b` | rc1 | **rc0** | rc1 | то же |
| userinfo-after-fragment | `https://host#u=user:pass@b` | rc1 | **rc0** | rc1 | то же |
| double-slash-path | `//user:pass@host/path` | rc1 | **rc0** | rc1 | блокер 2/2 |
| double-slash-token | `//tok@host` | rc0 | rc0 | rc1 | расширение (токен в authority scheme-relative) |
| double-slash-token-path | `//tok@host/path` | rc0 | rc0 | rc1 | расширение |
| host8080-at | `host:8080@x` | rc1 | rc1 | rc1 | паритет |
| at-after-slash | `https://host/p@x` | rc0 | rc0 | rc0 | адрес |
| at-in-query | `https://host?u=a@b` | rc0 | rc0 | rc0 | адрес (k104) |
| at-in-fragment | `https://host#@x` | rc0 | rc0 | rc0 | адрес (k105) |
| k111-like | `https://host:8080/p?x=a@b` | rc0 | rc0 | rc0 | адрес (все три; `/` между `:` и `@`) |
| pain-26-10 | `http://127.0.0.1:8787` | rc0 | rc0 | rc0 | боль владельца — закрыта всеми |
| upper-scheme | `HTTPS://TOK@HOST` | rc0 | rc1 | rc1 | расширение |
| upper-scheme-userinfo | `HTTPS://USER:PASS@HOST` | rc1 | rc1 | rc1 | паритет |
| ftp-userinfo | `ftp://u:p@h` | rc1 | rc1 | rc1 | паритет |
| quoted-token | `"https://tok@host"` | rc0 | rc1 | rc1 | расширение (кавычка в классе схемы) |
| quoted-userinfo | `"https://user:pass@host"` | rc1 | rc1 | rc1 | паритет |
| quoted-address | `"http://127.0.0.1:8787"` | rc0 | rc0 | rc0 | адрес |
| crlf-token | `https://tok@host\r` | rc0 | rc1 | rc1 | расширение (CRLF снят парсером) |
| crlf-userinfo | `https://user:pass@host\r` | rc1 | rc1 | rc1 | паритет |
| space-in-userinfo | `https://user:pa ss@host` | rc0 | rc0 | rc0 | остаток (все три; пробел исключён классом v3) |
| space-before-at | `https://tok @host` | rc0 | rc0 | rc0 | остаток |
| **pwd-hash** | `postgres://user:p#ss@host/db` | rc1 | **rc0** | rc1 | НАХОДКА АРБИТРА: пароль с `#` — OBJECT fail-open |
| **pwd-question** | `https://user:p?ss@host` | rc1 | **rc0** | rc1 | пароль с `?` — OBJECT fail-open |
| **pwd-hash-noscheme** | `user:p#ss@host/db` | rc1 | **rc0** | rc1 | DSN без схемы, пароль с `#` — OBJECT fail-open |
| **pwd-question-noscheme** | `user:p?ss@host` | rc1 | **rc0** | rc1 | то же с `?` |
| redis-empty-user | `redis://:pwd@host` | rc1 | rc1 | rc1 | паритет (z7) |
| mailto | `mailto:admin@x` | rc1 | rc1 | rc1 | паритет, осознанный ложный отказ |
| empty-token | `http://@cdn.internal/report.md` | rc0 | rc0 | rc0 | k106 |
| ipv6-token | `https://tok@[::1]:8080` | rc0 | rc1 | rc1 | расширение |
| ipv6-address | `https://[::1]:8080` | rc0 | rc0 | rc0 | адрес |
| scheme-less-token | `tok@host` | rc0 | rc0 | rc0 | остаток (ssh `user@host` — адресная форма) |
| two-at | `https://a@b@c` | rc0 | rc1 | rc1 | расширение |

Итог матрицы: **cand ⊇ v3 на всех 47 входах** (ни одной строки v3 rc1 → cand rc0); cand ⊇ OBJECT плюс `//<токен>@`; OBJECT ⊉ v3 на 10 входах (port-query, port-fragment, userinfo-double-slash, double-slash-path, userinfo-after-path/-query/-fragment, pwd-hash, pwd-question, pwd-hash-noscheme, pwd-question-noscheme) — каждый из них есть учётные данные или неразделимая с ними форма; ни один не есть «адрес без учётных данных» класса И-3. Разбор парсером (`python3 parse_forms.py`, urllib): `//user:pass@host/path` → username/password заполнены; `postgres://user:p#ss@host/db` → netloc `user:p`, fragment `ss@host/db`; `https://host:80?u=a@b` → netloc `host:80`, query `u=a@b` — грамматически вторая и третья формы неразличимы; страж не парсер URL, значение — человеческий секрет, выбор fail-closed.

Достижимость утечки по сужениям OBJECT: дом секретов с `DATABASE_URL=postgres://user:p#ss@db.internal/app` (реалистичная форма: пароль с `#` без percent-encoding встречается в DSN) и копия строки в любом индексируемом файле проекта (лог, вердикт, README) — OBJECT запускает workshop, v3 отказывает. Для `//user:pass@host` — та же схема, форма реже.

Проверка кандидата батареей OBJECT: `bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Arb142v4/cand-door` (субъект = дверь-кандидат) → rc 1, «клеток 146, зелёных 143, красных 3»; красны РОВНО `k111-port-v-zaprose`, `k112-port-v-fragmente` (ожидание клеток rc 0 — перевернуть, см. Q3) и `r1-kanon-v-subekte` (канон-строка иная — ожидаемо). Все 143 прочие — включая k99–k110, k31–k42, z6/z7, k10 — зелёные: кандидат не ломает ни одну клетку И-3 (боль) и ни одну клетку токена.

## Q2. Что из сужения допустимо

(i) **k111/k112 (порт + `@` после `?`/`#` без `/`) — НЕ вытекает** ни из слова 26.10 (боль — `http://127.0.0.1:8787`, без `@`; закрыта всеми тремя дверями), ни из блокера 1 критика 1/2 (блокер верен для ТОКЕН-ветви: вложенный `://…@` после `?`/`/`/`#` — новая ложная поимка, которой v3 не имел; часть про «после двоеточия порта» ошибочно распространила его на двоеточие-ветвь v3). Измеренная цена сужения — fail-open на пароле с `?`/`#` (pwd-*). Сужение **ОТКЛОНЕНО**: `https://host:80?u=a@b` судится (паритет v3, fail-closed); клетки k111/k112 остаются с ПЕРЕВЁРНУТЫМ ожиданием (отказ) как страж от этого же мутанта.

(ii) **`user:pass@` с `@` после первого `/` внешнего URL** (`https://host/p?u=user:pass@b`, userinfo-after-*) — по RFC 3986 не userinfo, оба критика это сужение приняли; но замороженное определение 142/3 И-2 — «ЛЮБОЙ фрагмент `user:pass@`/`:pass@` в значении», слово 28.10 — только расширение, а рамка задания прямо: «снятие защиты существующих форм `user:pass@` — вне слова». Ни арбитр, ни критики не владеют этим решением. Сужение **ОТКЛОНЕНО в v4**; строка-черновик для батча владельца — §Q4. Инженерный аргумент за fail-closed здесь тот же: `?next=https://user:pass@other` — ВЛОЖЕННЫЕ учётные данные, их утечка в индексируемый файл — утечка.

(iii) **Честность текста OBJECT**: §Замены v4 п. 4–5 и И-2 называют якорь и границы `?#`, но представляют их как «ложный отказ класса боли не возвращается»; ни §Замены, ни §НЕ ЗАЩИЩАЕТ не называют, что `//user:pass@host`, `user:p#ss@host`, `https://host/p?u=user:pass@b` перестали судиться — классы учётных данных, которые v3 защищал. Названо НЕЧЕСТНО (не по умыслу — замер не был сделан). После правки по Q3 этот вопрос снимается: сужений относительно v3 не остаётся, называть нечего, кроме расширений и прежних остатков.

## Q3. ЗАМКНУТЫЙ перечень правок (architect; ОДИН scoped-критик судит СТРОГО этот перечень)

Меняется:

1. **Канон-строка** (И-1, `source.json:.kanon.userinfo_re`, модель `model/connect_project.sh`, строка `USERINFO_RE=`), байт в байт: `(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)`. Комментарий-основание в модели — переписать под два факта: токен-ветвь судит authority внешнего адреса (абсолютный и scheme-relative), двоеточие-ветвь — строка v1/v3 дословно (И-4: канон v4 ⊇ v3 по построению). `model_sha256` в source.json — перепин (число — вывод команды).
2. **И-2** (определение userinfo): «Userinfo — (1) ЛЮБОЙ фрагмент `user:pass@`/`:pass@` в значении, без привязки к схеме и позиции — дословно frozen 142/3 (DSN без схемы, пустой пользователь, `mailto:`, пароль с сырым `?`/`#`, `//user:pass@host`, а также неразделимая с паролем пара порт+`@` в запросе/фрагменте — осознанный fail-closed) ∨ (2) токен без двоеточия в authority ВНЕШНЕГО адреса: от начала значения необязательная `схема:`, `//`, непустой фрагмент без `/`/`?`/`#`/пробела, `@` (`https://<токен>@host`, `//<токен>@host`; `@` после первого `/`/`?`/`#` внешнего адреса — включая вложенный URL — для токен-ветви не userinfo; пустой токен `://@` — не userinfo; токен длины 1 — судим)». Обоснование формулировки (ERE без lookahead) — оставить только для токен-ветви. Убрать утверждения, что `@` после `/?#` «не userinfo» для двоеточие-ветви и что пара порт+`@` «не userinfo».
3. **И-3** — текст не меняется (единственное легальное сужение — прежний класс); **И-4** — добавить одно предложение: «канон v4 содержит канон-строку v3 буквальной альтернативой — множество судимых значений v4 ⊇ v3 по построению; расширение — токен-ветвь».
4. **§Замены v4** п. 4, 5, 6, 7, 9, 10, 11, 13, 15, 19 и строка «ДОБАВЛЕНИЯ» — переписать под канон и числа этого решения; п. 11 (граница implementer): «v4 меняет внутри блока предиката ТОЛЬКО значение канон-строки `USERINFO_RE` (добавлена токен-ветвь; двоеточие-ветвь — байт в байт v3) и её комментарий-основание». Добавить пункт: «арбитраж `verdicts/arbitration/contracts-142-v4-arbitraz.md`: сужения OBJECT 25bda098 относительно v3 (`//user:pass@host`, `user:p#ss@`, `X:Y@` после `/?#`, пара порт+`@`) отменены; клетки k111/k112 перевёрнуты, k113–k116 добавлены; стаб `dvoetochie-bez-granicy` снят, четыре стаба добавлены».
5. **§ПРОВОДКА role=** цитата — заменить фрагмент «учётные данные в значении — user:pass@ или токен без двоеточия (https://<токен>@host) — судятся и у адресных имён, а символ @ в пути/запросе/фрагменте после первого /, ? или # внешнего адреса (включая вложенный URL) учётными данными не считается» → «учётные данные в значении — user:pass@ или :pass@ в любом месте значения (как прежде) либо токен без двоеточия в authority внешнего адреса (https://<токен>@host, //<токен>@host) — судятся и у адресных имён; одиночный символ @ без двоеточия перед ним после первого /, ? или # внешнего адреса (включая вложенный URL) учётными данными не считается». §ПРОВОДКА-ЭНФОРСМЕНТ — без изменений.
6. **§Модель угроз / НЕ ЗАЩИЩАЕТ**: (а) пункт про токен в path/query — убрать слова «включая … пару порт+`@`» и «такой `@`» для двоеточие-формы; оставить: токен без двоеточия после первого `/?#` не судится; (б) ДОБАВИТЬ пункт «осознанные ложные отказы двоеточие-ветви v1/v3 (fail-closed, паритет v3; снятие — только словом владельца): пара порт+`@` в запросе/фрагменте без `/` (`https://host:80?u=a@b`, k111/k112 — неразделима с паролем с `?`/`#`), `mailto:admin@x`, `X:Y@` после первого `/`/`?`/`#` внешнего адреса (`https://host/p?u=user:pass@b`)»; (в) в пункт «токен-userinfo БЕЗ `://`» добавить: токен, содержащий сырой `?`/`#` (`https://to?ken@host`) — не судится токен-ветвью (класс без `?#`; защищён только при наличии `:` перед `@`). ЗАЩИЩАЕТ: пункт про токен-userinfo — заменить «от двоеточие-ветви v1/v3 без границ `?`/`#` … k111/k112, стаб `dvoetochie-bez-granicy`» → «от якоря/границ `?#` на двоеточие-ветви (пропуск `//user:pass@host`, пароля с `?`/`#`, `X:Y@` после `/?#`; мутант = канон OBJECT 25bda098) — стаб `kanon-object-25bda098` (канон OBJECT дословно; ловится k111–k116), стабы классов `dvoetochie-s-yakorem` (k111, k112, k115) и `dvoetochie-bez-voprosa-reshetki` (k111, k112, k115, k116); от токен-ветви только со схемой (пропуск `//<токен>@host`) — k114, стаб `token-tolko-so-shemoj`» (привязки — по замеру `stub_table.sh` ниже, окончательно — по `--stabs`).
7. **Клетки** (ось K, раннер + `source.json:.osi`; имена под адресным суффиксом, значение планируется в индексируемом файле; ожидание «отказ sekret-v-dereve rc 1 без сессии и без значения в отказе» — ветка вердикта `token`/отказ, как k99):
   - `k111-port-v-zaprose`, `k112-port-v-fragmente` — вход прежний, ожидание ПЕРЕВЕРНУТО: отказ (судится, fail-closed); `vid` → отказ; в комментарии раннера — «ложный отказ осознан, паритет v3». Имя (`-sudim` или прежнее) — на усмотрение architect, но одинаково в `.osi` и раннере;
   - НОВЫЕ: `k113-userinfo-scheme-relative` — `//user:pass@host/path` → отказ; `k114-token-scheme-relative` — `//<токен>@host/path` → отказ (`<токен>` = `rnd`); `k115-reshetka-v-parole` — `postgres://user:p#<rnd>@host/db` → отказ; `k116-vopros-v-parole` — `user:p?<rnd>@host/db` → отказ (DSN без схемы — проверяет класс двоеточие-ветви, не только схемную форму). Транслитерация имён — architect, содержание — как здесь.
   Итого осей: 146 + 4 = **150** (K 112 → 116).
8. **Стабы** (Н-39: привязка — `source.json:.stab_vhod` ПО КОДУ, прогоном `--stabs`; перечень ниже — минимум обязательных привязок, architect вправе добавить измеренные; имена стабов и клеток в этом решении — предложения, обязательны СОДЕРЖАНИЕ мутанта/входа и факт поимки):
   - **СНЯТЬ** `stab_dvoetochie-bez-granicy` (его «дефект» — строка v3 — теперь канон; файл удалить, ключ `.stab_vhod` удалить);
   - **НОВЫЕ** (четыре; мутанты и их поимки ИЗМЕРЕНЫ `stub_table.sh`, см. сырой вывод): `stab_kanon-object-25bda098` — канон целиком → `(^[^/?#[:space:]]*://[^/?#[:space:]]+@|^[^/?#[:space:]]*:[^/?#[:space:]]*@)` (ровно OBJECT — мутант, который случился); ловится k111, k112, k113, k114, k115, k116 (6); `stab_dvoetochie-s-yakorem` — вторая ветвь → `^[^/@[:space:]]*:[^/@[:space:]]*@` (якорь на двоеточие-ветви, классы v3); ловится k111, k112, k115 (3; k113/k116 этот мутант судит — токен-ветвью и от начала значения); `stab_dvoetochie-bez-voprosa-reshetki` — вторая ветвь → `[^/?#@[:space:]]*:[^/?#@[:space:]]*@` (класс без `?#`, без якоря); ловится k111, k112, k115, k116 (4); `stab_token-tolko-so-shemoj` — первая ветвь → `^[^/?#[:space:]]*://[^/?#[:space:]]+@` (токен-ветвь OBJECT); ловится k114 (1);
   - **ПЕРЕПРИВЯЗАТЬ** якорь генератора (строка `old`) на новую канон-строку у девяти стабов: `bez-token-vetvi` (new = `[^/@[:space:]]*:[^/@[:space:]]*@` — ровно дверь v3), `token-gde-ugodno`, `token-bez-granicy` (new: токен-класс `[^/@[:space:]]+@` при двоеточие-ветви v3), `pustoj-token`, `token-tolko-https`, `dvoetochie-posle-shemy`, `shema-pustoj-user`, `token-bez-yakorya` (new = `(([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)`), `min-dlina-tokena` (`+` → `{2,}` в токен-ветви); во всех `new`-строках, где двоеточие-ветвь сохраняется, она — строка v3; привязки прежние (дефекты прежние).
   Итого стабов: 40 − 1 + 4 = **43**; привязок: 220 − 2 + (6 + 3 + 4 + 1) = **232** при перечисленных привязках — **число — вывод команды** `jq '[.stab_vhod[]|length]|add'`; расхождение вверх допустимо (измеренные дополнительные поимки, например `tok-gde-ugodno` на k108–k110), вниз — нет.
9. **Числа приёмки** (§Приёмочный критерий, §Сдача «Вторая мера», §Модель угроз абзац «Субъект», §Замены п. 6–10, 15–18): 146 → 150 клеток; 40 → 43 стабов; 220 → 232 привязок (или вывод команды); сценарий 1 (дерево с дверью v3): rc 1, ожидаемо «клеток 150, зелёных 144, красных 6» — красны РОВНО `k99`, `k100`, `k101`, `k107`, `k114` (токены, включая scheme-relative) и `r1` (k111/k112/k113/k115/k116 на двери v3 ЗЕЛЕНЫ — v3 их судит); сценарий 2: `W --model` ×3 → 150/150; сценарий 3: `W --stabs` → непойманных 0; сценарий 4: 150 × SUBJECT_ABSENT; сценарий 6: 150/150. ДОПОЛНИТЕЛЬНО в §Сдача — замер «дверь OBJECT 25bda098 как субъект (`W --repo`)»: ожидаемо красны k111, k112, k113, k114, k115, k116, r1 (7) — свидетельство, что новые клетки ловят отменённое сужение. Все числа — вывод команд, не пересказ.
10. **Шапка/§Нарезка/§Воля** — добавить строку источника: «Арбитраж 2026-10-28 `verdicts/arbitration/contracts-142-v4-arbitraz.md` (критик 2/2 исчерпан): двоеточие-ветвь — байт в байт v3; токен-ветвь — authority внешнего адреса, обе URL-формы».

НЕ меняется: `SEKRET_MARKERY`, `ADRES_SUFFIKSY`, `IMYA_RE`, `nul_predproverka`, парсер и блок стража вне строки `USERINFO_RE` и её комментария; клетки k1–k110 (входы и ожидания; k104/k105/k108–k110 остаются rc 0 — измерено на cand), ось N/Z/F/D/R; стабы вне перечня п. 8; И-3, И-5, И-6, И-7, §Демаркация, §Зоны, §ПРОВОДКА-ЭНФОРСМЕНТ, §Расхождение; тексты 125/136; дверь `scripts/connect_project.sh` (зона implementer, после freeze).

Scoped-критик судит: (а) канон-строка байт в байт в `source.json`, модели, И-1; (б) матрица арбитра (47 входов) на модели — ни одной строки v3 rc1 → модель rc0 (команда `DOORS="v3 v4" bash door_matrix.sh` с подстановкой новой модели); (в) клетки k111–k116 по содержанию п. 7; стабы п. 8 — наличие, снятие, привязки по `--stabs`; (г) тексты п. 2–6, 9, 10 — соответствие этому решению; (д) числа — вывод команд. Вне перечня — не судится. Следующий FAIL — к владельцу (§Быстрый-процесс).

## Q4. Остаток, принимаемый арбитражем (честно в §НЕ ЗАЩИЩАЕТ)

Не судится (пропуск, все три двери одинаково, кроме отмеченного):
- scp-форма `git@host:path`, DSN `user@host`/`tok@host` без `://` и без `:` перед `@` (адресная ssh-форма `user@host` — ложный отказ дороже);
- URL-кодированный `%40`, пробел перед `@`/внутри userinfo (`https://user:pa ss@host`) — буквальное сравнение, классы v3 исключают пробел;
- токен без двоеточия, содержащий сырой `?`/`#` (`https://to?ken@host`) — класс токен-ветви без `?#` (цена: иначе `https://host?u=a@b` судился бы ложно; v3 токены не судил вовсе — не сужение);
- пустой токен `://@host` (k106), `#`-комментарий строки дома — семантика 125.

Судится ложно (fail-closed, паритет v3; снятие — ТОЛЬКО словом владельца, не арбитражем):
- `mailto:admin@x`; пара порт+`@` в запросе/фрагменте без `/` (`https://host:80?u=a@b`); `X:Y@` после первого `/`/`?`/`#` внешнего адреса (`https://host/p?u=user:pass@b`).

Строка-ЧЕРНОВИК для батча владельца (если он хочет RFC-строгое userinfo; ОБЕ стороны цены названы): «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: 142 v+1 — userinfo судится только в authority внешнего адреса (RFC 3986): `X:Y@` после первого `/`, `?`, `#` внешнего адреса — не учётные данные; пара порт+`@` (`https://host:80?u=a@b`) и пароль с сырым `?`/`#` (`user:p#ss@host`) грамматически неразделимы — выбираю: [судить обе (fail-closed) | не судить обе (пароль с `?`/`#` — остаток)]». До этого слова — канон этого решения.

## Что НЕ проверено

Реальный дом секретов станции (запрещён); живой workshop и роль после owner-коммита (не существуют на OBJECT); модель-факт автора по трейсу (не предъявлен); гейты `pre_critic`/`check_precision_gate`/`check_spec_ready`/`check_zones` на будущей правке (её ещё нет; на OBJECT их прогнал критик 2/2 — не повторялись); распространённость сырого `#`/`?` в паролях DSN станции — не измерялась (класс назван по форме, достижимость — по построению мира). Поведение GNU grep -E на `( … )?` — проверено живым прогоном матрицы (47 входов) и батареей (146 клеток), не чтением.

## Сырые команды / rc

```
$ git -C /tmp/dev-harness-verify/Arch142v4/repo cat-file -t 25bda0985633349953a9bf635f1b825d8be7658d
commit
$ git -C /tmp/dev-harness-verify/Arch142v4/repo rev-parse HEAD; git -C … branch --show-current
25bda0985633349953a9bf635f1b825d8be7658d
wip/142/architect-v4
$ git clone -q /tmp/dev-harness-verify/Arch142v4/repo /tmp/dev-harness-verify/Arb142v4/repo; git -C repo log --oneline -3
25bda098 142 v4 (правка по вердикту критика 1/2, два блокера): … батарея 146 клеток / 40 стабов / 220 привязок
2ac3c286 handoff: 28.10 ~10:25 — …
f3c18d3c 143: …
$ git -C /tmp/dev-harness-verify/Arb142v4/origin rev-parse frozen/contracts/142/3; git -C origin cat-file -t frozen/contracts/142/3
57a415ede105c96fbd25ecc7d64da2798580fce4
tag
$ git -C origin show frozen/contracts/142/3:fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh | grep -n USERINFO_RE=
305:  USERINFO_RE='[^/@[:space:]]*:[^/@[:space:]]*@'
$ grep -n USERINFO_RE= repo/scripts/connect_project.sh repo/fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
scripts/connect_project.sh:305:  USERINFO_RE='[^/@[:space:]]*:[^/@[:space:]]*@'
model/connect_project.sh:321:  USERINFO_RE='(^[^/?#[:space:]]*://[^/?#[:space:]]+@|^[^/?#[:space:]]*:[^/?#[:space:]]*@)'
$ git -C origin show frozen/contracts/142/3:contracts/142-skaner-sekretov.md | grep -n -i userinfo | sed -n 3p   # И-2 v3, дословно
42:2. **И-2 судимость.** … Userinfo — ЛЮБОЙ фрагмент `user:pass@`/`:pass@` в значении, без привязки к схеме (DSN без схемы и пустой пользователь ловятся).
$ jq -r .kanon.userinfo_re repo/fixtures/workshop_project/skaner_sekretov_142/source.json
(^[^/?#[:space:]]*://[^/?#[:space:]]+@|^[^/?#[:space:]]*:[^/?#[:space:]]*@)
$ jq -r '.osi|length' source.json; jq '[.stab_vhod[]|length]|add' source.json; jq '.stab_vhod|length' source.json
146 / 220 / 40
$ python3 mkcand.py repo/…/model/connect_project.sh cand/connect_project.sh '(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
written: /tmp/dev-harness-verify/Arb142v4/cand/connect_project.sh canon: (^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)
$ bash /tmp/dev-harness-verify/Arb142v4/door_matrix.sh < /tmp/dev-harness-verify/Arb142v4/cases.txt   # 47 входов × 3 двери, ~50 с, rc 0
port-query | v3 rc=1 calls=0 reject=1 exposed=0 | v4 rc=0 calls=1 reject=0 exposed=0 | cand rc=1 calls=0 reject=1 exposed=0
port-fragment | v3 rc=1 calls=0 reject=1 exposed=0 | v4 rc=0 calls=1 reject=0 exposed=0 | cand rc=1 calls=0 reject=1 exposed=0
nested-query | v3 rc=0 calls=1 … | v4 rc=0 calls=1 … | cand rc=0 calls=1 …
nested-path | v3 rc=0 | v4 rc=0 | cand rc=0
nested-fragment | v3 rc=0 | v4 rc=0 | cand rc=0
token | v3 rc=0 calls=1 | v4 rc=1 calls=0 reject=1 | cand rc=1 calls=0 reject=1
token-port | v3 rc=0 | v4 rc=1 | cand rc=1
one-char-token | v3 rc=0 | v4 rc=1 | cand rc=1
userinfo-scheme | v3 rc=1 | v4 rc=1 | cand rc=1
userinfo-no-scheme | v3 rc=1 | v4 rc=1 | cand rc=1
userinfo-scp-like | v3 rc=0 | v4 rc=0 | cand rc=0
userinfo-hostport | v3 rc=1 | v4 rc=1 | cand rc=1
userinfo-double-slash | v3 rc=1 calls=0 reject=1 | v4 rc=0 calls=1 reject=0 | cand rc=1 calls=0 reject=1
userinfo-after-path | v3 rc=1 | v4 rc=0 calls=1 | cand rc=1
userinfo-after-query | v3 rc=1 | v4 rc=0 calls=1 | cand rc=1
userinfo-after-fragment | v3 rc=1 | v4 rc=0 calls=1 | cand rc=1
double-slash-path | v3 rc=1 | v4 rc=0 calls=1 | cand rc=1
double-slash-token | v3 rc=0 | v4 rc=0 | cand rc=1 calls=0 reject=1
double-slash-token-path | v3 rc=0 | v4 rc=0 | cand rc=1
host8080-at | v3 rc=1 | v4 rc=1 | cand rc=1
at-after-slash | v3 rc=0 | v4 rc=0 | cand rc=0
at-in-query | v3 rc=0 | v4 rc=0 | cand rc=0
at-in-fragment | v3 rc=0 | v4 rc=0 | cand rc=0
k111-like | v3 rc=0 | v4 rc=0 | cand rc=0
pain-26-10 | v3 rc=0 calls=1 | v4 rc=0 calls=1 | cand rc=0 calls=1
upper-scheme | v3 rc=0 | v4 rc=1 | cand rc=1
upper-scheme-userinfo | v3 rc=1 | v4 rc=1 | cand rc=1
ftp-userinfo | v3 rc=1 | v4 rc=1 | cand rc=1
quoted-token | v3 rc=0 | v4 rc=1 | cand rc=1
quoted-userinfo | v3 rc=1 | v4 rc=1 | cand rc=1
quoted-address | v3 rc=0 | v4 rc=0 | cand rc=0
crlf-token | v3 rc=0 | v4 rc=1 | cand rc=1
crlf-userinfo | v3 rc=1 | v4 rc=1 | cand rc=1
space-in-userinfo | v3 rc=0 | v4 rc=0 | cand rc=0
space-before-at | v3 rc=0 | v4 rc=0 | cand rc=0
pwd-hash | v3 rc=1 calls=0 reject=1 | v4 rc=0 calls=1 reject=0 | cand rc=1 calls=0 reject=1
pwd-question | v3 rc=1 calls=0 reject=1 | v4 rc=0 calls=1 reject=0 | cand rc=1 calls=0 reject=1
pwd-hash-noscheme | v3 rc=1 calls=0 reject=1 | v4 rc=0 calls=1 reject=0 | cand rc=1 calls=0 reject=1
pwd-question-noscheme | v3 rc=1 calls=0 reject=1 | v4 rc=0 calls=1 reject=0 | cand rc=1 calls=0 reject=1
redis-empty-user | v3 rc=1 | v4 rc=1 | cand rc=1
mailto | v3 rc=1 | v4 rc=1 | cand rc=1
empty-token | v3 rc=0 | v4 rc=0 | cand rc=0
ipv6-token | v3 rc=0 | v4 rc=1 | cand rc=1
ipv6-address | v3 rc=0 | v4 rc=0 | cand rc=0
scheme-less-token | v3 rc=0 | v4 rc=0 | cand rc=0
two-at | v3 rc=0 | v4 rc=1 | cand rc=1
(exposed=0 на всех 141 ячейках; полный несокращённый вывод — в сессии арбитра, воспроизводим командой выше)
$ python3 /tmp/dev-harness-verify/Arb142v4/parse_forms.py
//user:pass@host/path -> {'netloc': 'user:pass@host', 'username': 'user', 'password': 'pass', 'hostname': 'host', 'path': '/path', …}
//tok@host -> {'netloc': 'tok@host', 'username': 'tok', 'password': None, 'hostname': 'host', …}
postgres://user:p#ss@host/db -> {'netloc': 'user:p', 'username': None, 'password': None, 'hostname': 'user', 'fragment': 'ss@host/db', …}
https://user:p?ss@host -> {'netloc': 'user:p', 'username': None, 'password': None, 'hostname': 'user', 'query': 'ss@host', …}
https://host:80?u=a@b -> {'netloc': 'host:80', 'username': None, 'password': None, 'hostname': 'host', 'query': 'u=a@b', …}
https://host/p?u=user:pass@b -> {'netloc': 'host', 'username': None, 'password': None, 'path': '/p', 'query': 'u=user:pass@b', …}
$ mkdir -p cand-door/scripts && cp cand/connect_project.sh cand-door/scripts/connect_project.sh
$ cd repo && bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Arb142v4/cand-door | grep -v 'ЗЕЛЕНА$'
КЛЕТКА k111-port-v-zaprose КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «review.md» …) imya=X1524D9FDB436_HOST
КЛЕТКА k112-port-v-fragmente КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «anchor.md» …) imya=X04908843893F_HOST
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 repo: клеток 146, зелёных 143, красных 3
[exit=1]
```

```
$ bash /tmp/dev-harness-verify/Arb142v4/stub_table.sh   # мутант × клетка, чистый grep -Eq по значению клетки; M = судится; ожидание: k102–k106, k108–k110 — «.», остальные — M
cell  cand  v3  object  dv-s-yakorem  dv-bez-vopr-resh  tok-tolko-so-shemoj  tok-bez-yakorya  tok-bez-granicy  min-dlina  bez-token-vetvi  tok-gde-ugodno  pustoj-token  tolko-https  shema-pustoj-user
k99   M     .   M       M             M                 M                    M                M                M          .                M               M             M            .
k101  M     .   M       M             M                 M                    M                M                M          .                M               M             .            .
k102  .     .   .       .             .                 .                    .                .                .          .                M               .             .            .
k103  .     .   .       .             .                 .                    .                .                .          .                M               .             .            .
k104  .     .   .       .             .                 .                    .                M                .          .                M               .             .            .
k105  .     .   .       .             .                 .                    .                M                .          .                M               .             .            .
k106  .     .   .       .             .                 .                    .                .                .          .                .               M             .            .
k107  M     .   M       M             M                 M                    M                M                .          .                M               M             M            .
k108  .     .   .       .             .                 .                    M                .                .          .                M               .             .            .
k109  .     .   .       .             .                 .                    M                .                .          .                M               .             .            .
k110  .     .   .       .             .                 .                    M                .                .          .                M               .             .            .
k111  M     M   .       .             .                 M                    M                M                M          M                M               M             M            M
k112  M     M   .       .             .                 M                    M                M                M          M                M               M             M            M
k113  M     M   .       M             M                 M                    M                M                M          M                M               M             M            .
k114  M     .   .       M             M                 .                    M                M                M          .                M               M             .            .
k115  M     M   .       .             .                 M                    M                M                M          M                M               M             M            M
k116  M     M   .       M             .                 M                    M                M                M          M                M               M             M            .
z6    M     M   M       M             M                 M                    M                M                M          M                M               M             M            .
z7    M     M   M       M             M                 M                    M                M                M          M                M               M             M            .
(столбец cand — ожидание КАЖДОЙ клетки выполнено; object — промах на k111–k116; перепривязанные стабы ловятся на прежних клетках: tok-bez-yakorya k108–k110, tok-bez-granicy k104/k105, min-dlina k107, bez-token-vetvi k99/k101, tok-gde-ugodno k102/k103, pustoj-token k106, tolko-https k101, shema-pustoj-user z6/z7)
```

Файлы арбитра (все в `/tmp/dev-harness-verify/Arb142v4/`): `door_matrix.sh`, `cases.txt`, `mkcand.py`, `parse_forms.py`, `stub_table.sh`, `cand/connect_project.sh`, `cand-door/scripts/connect_project.sh`, клоны `repo/`, `origin/`. Коммит вердикта в основной репозиторий под `user.name=arbiter` — ОТЛОЖЕН по ограничению задания (push/commit не делать); файл лежит по указанному пути для коммита оркестратором/architect на ветку предмета.

Арбитраж не даёт accept контракта 142 v4 и не открывает дополнительных кругов: после правки architect по перечню Q3 — ОДИН scoped-критик строго по перечню; его FAIL — к владельцу.

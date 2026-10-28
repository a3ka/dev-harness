FAIL
OBJECT=69d67a50fe6fad4a0f16d100ebdbd48c8bb796ae
СУД: repo=dev-harness; предмет=142; фаза=контракт v4; роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit142v4 (внутренний trace-id не предоставлен); модель-факт=openai-codex/gpt-6-sol; SHA=69d67a50fe6fad4a0f16d100ebdbd48c8bb796ae; предыдущий=нет (v3 accept); исключение=нет.

Предмет: `git cat-file -t 69d67a50fe6fad4a0f16d100ebdbd48c8bb796ae` → `commit`; `git rev-parse HEAD` клона → тот же SHA. Раздача, предмет и команды приёмки есть. Судится закоммиченный контракт, а не рабочий черновик.

БЛОКИРУЕТ contracts/142-skaner-sekretov.md:42-43 — класс: противоречие буквального канона и объявленной границы И-2/И-3. `USERINFO_RE` ищет `://…@` в ЛЮБОМ месте строки, в том числе во вложенном URL ПОСЛЕ первого `?` внешнего URL; тогда токен-ветвь v4 ошибочно объявляет userinfo и не пускает адресное значение, которому контракт прямо обещает запуск. Сама честная модель нарушает объявленное свойство, поэтому зелёная батарея не может доказать соответствие. Унаследованная двоеточие-ветвь вдобавок ложно ловит `https://host:80?u=a@b` и `https://host:80#u=a@b`: `:` порта и `@` в query/fragment ошибочно образуют «user:pass@». Новые k102–k106 не предъявляют вложенный `://` или `:80?`/`:80#` без `/` перед `@`.
ОБЯЗАТЕЛЬСТВО: И-2/И-3 — символ `@` после первого `/`, `?` или `#` во внешнем URL НЕ считается userinfo; адресное имя и значение без userinfo не судятся. §Модель угроз обязуется защищать от таких ложных отказов.
СОСТОЯНИЕ: поддельный HOME, индексируемый `leak.txt` с буквальным значением `GIT_URL=https://host?redirect=https://tok@remote` из `secrets.env`, либо `GIT_URL=https://host:80?u=a@b`; в authority внешнего URL нет userinfo, в имени ключа нет секретного маркера.
НАБЛЮДЕНИЕ: `bash /tmp/dev-harness-verify/Crit142v4/probe142.sh` → `main/nested-query rc=0 calls=1 sekret-v-dereve=0 value-in-error=0`, `model/nested-query rc=1 calls=0 sekret-v-dereve=1 value-in-error=0`; port-query/port-fragment у обеих дверей rc 1 и calls 0. `W --model` одновременно зелён 140/140. Закрывающее свойство: `@` в query/fragment/path не вызывает отказа, включая после двоеточия порта или вложенного `://`, а токен в authority внешнего URL продолжает отказывать. Исправление требует согласовать объявленную границу, канон, модель и критерий, не только дописать пояснение к регэкспу.

БЛОКИРУЕТ contracts/142-skaner-sekretov.md:43,52,58 — класс: пропущенная граничная длина токена делает критерий ложно достаточным. Положительные k99–k101 берут только длинные `ghp_…`/`pat_…`/`tok_…`, отрицательная k106 — пустой токен; токен РОВНО одного символа, допускаемый `+` в каноне, не испытывается. Мутант оставляет канон-строку для r1, затем переприсваивает исполняемый `USERINFO_RE` на `{2,}`: `W --repo` rc 0 140/140, хотя индексируемое `GIT_URL=https://x@host` пропускается и workshop запускается.
ОБХОД: в одноразовом клоне `model-door` после канон-строки вставить `USERINFO_RE='([^/@[:space:]]*:[^/@[:space:]]*@|://[^/?#@[:space:]]{2,}@)'`. Статический r1 видит правильную строку, 140 клеток проходят, однобуквенный токен уходит в дерево без отказа. Закрывающее свойство: обязательная красная клетка для односимвольного токена под адресным ключом с индексируемым значением (rc 1, workshop не вызван, значения нет в отказе). Пустой токен уже проверяется k106. Граница ревьюера «код по модели» остаётся дополнительной мерой, но не заменяет обязательную атаку красной батареи до freeze.

Сырые команды и существенные строки выхода атак (длинные однообразные строки клеток и 214 поимок не пересказываются как якобы выполненный другой прогон; пути относительно `/tmp/dev-harness-verify/Crit142v4/repo`, если не указано иначе):
```
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --stabs
s142 model-opora-stabov: клеток 140, зелёных 140, красных 0
ПОЙМАН stab_token-bez-granicy @ k104-sobaka-posle-voprosa
ПОЙМАН stab_token-bez-granicy @ k105-sobaka-posle-reshetki
ПОЙМАН stab_token-gde-ugodno @ k102-sobaka-v-puti
ПОЙМАН stab_token-gde-ugodno @ k103-sobaka-v-zaprose
s142 stabs: стабов 37, привязок 214, непойманных 0
[exit=0]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
КЛЕТКА k99-git-url-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k100-repo-url-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА k101-endpoint-token КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии и без значения в отказе rc=0; нет имени sekret-v-dereve; сессия запущена;
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона userinfo;
s142 subjekt: клеток 140, зелёных 136, красных 4
БОЛЬ-SEJCHAS: красные клетки перечислены выше (до реализации это ожидаемо)
[exit=1]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model   # три последовательных вызова
s142 model: клеток 140, зелёных 140, красных 0
s142 model: клеток 140, зелёных 140, красных 0
s142 model: клеток 140, зелёных 140, красных 0
[exit=0, exit=0, exit=0]
$ python3 -c 'from pathlib import Path; p=Path("scripts/connect_project.sh"); s=p.read_text(); needle="  USERINFO_RE=\x27([^/@[:space:]]*:[^/@[:space:]]*@|://[^/?#@[:space:]]+@)\x27"; assert s.count(needle)==1; s=s.replace(needle,needle+"\n  USERINFO_RE=\x27([^/@[:space:]]*:[^/@[:space:]]*@|://[^/?#@[:space:]]{2,}@)\x27"); p.write_text(s)'  # cwd=/tmp/dev-harness-verify/Crit142v4/model-door
[exit=0]
$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Crit142v4/model-door
КЛЕТКА k99-git-url-token ЗЕЛЕНА
КЛЕТКА k100-repo-url-token ЗЕЛЕНА
КЛЕТКА k101-endpoint-token ЗЕЛЕНА
КЛЕТКА k106-pustoj-token ЗЕЛЕНА
КЛЕТКА r1-kanon-v-subekte ЗЕЛЕНА
s142 repo: клеток 140, зелёных 140, красных 0
[exit=0]
$ bash /tmp/dev-harness-verify/Crit142v4/probe142.sh
main/port-query rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
main/port-fragment rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
main/nested-query rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/ordinary-port rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/https-port rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/token rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/one-char-token rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/uppercase-scheme rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/empty-scheme rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/encoded-at rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/two-at rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/scheme-less rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/ipv6-host rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/quoted rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
main/crlf rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
model/port-query rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/port-fragment rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/nested-query rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/ordinary-port rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
model/https-port rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
model/token rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/one-char-token rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/uppercase-scheme rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/empty-scheme rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/encoded-at rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
model/two-at rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/scheme-less rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
model/ipv6-host rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/quoted rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
model/crlf rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/port-query rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/port-fragment rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/nested-query rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/ordinary-port rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
mutant/https-port rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
mutant/token rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/one-char-token rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
mutant/uppercase-scheme rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/empty-scheme rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/encoded-at rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
mutant/two-at rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/scheme-less rc=0 calls=1 sekret-v-dereve=0 value-in-error=0
mutant/ipv6-host rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/quoted rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
mutant/crlf rc=1 calls=0 sekret-v-dereve=1 value-in-error=0
[exit=0]
```

Прочая проверка: `git diff --name-only HEAD~1 HEAD` → 11 файлов только в architect-зоне (контракт и семья 142); прежние 132 `.osi` по ID как JSON-объекты неизменны (`missing_old=[]`, `changed_old=[]`), новые ID — ровно k99–k106; `.stab_vhod` 37 ключей / 214 привязок. Якорь `shema-pustoj-user` переведён на новую канон-строку, мутирует ту же схему, ловится по z6/z7; привязка задана кодом/source.json, а не прозой. `W --repo /tmp/dev-harness-verify/Crit142v4` (нет субъекта) → `s142 repo: клеток 140, зелёных 0, красных 140` и 140 `SUBJECT_ABSENT`, rc 1. `P` на двери по модели v4 → `s125 red: зелёных 70, красных 0`, rc 0; `Q` → `sessii_136: клеток 87, зелёных 87, красных 0`, rc 0; порча модели `truncate -s 0` в одноразовом клоне, затем `W --model` → `s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256`, rc 2.

Гейты: `bash scripts/check_precision_gate.sh <клон> contracts/142-skaner-sekretov.md` → `OK`, rc 0; `check_spec_ready.sh <клон> contracts/142-skaner-sekretov.md` → `OK`, rc 0 (проба ~48,86 с укладывается в 60 с); `pre_critic.sh --repo <клон> contracts/142-skaner-sekretov.md` → `КРИТИК: дверь зелёная`, rc 0; `check_ceilings.sh` → `потолки в порядке`, rc 0; `check_threat_model.sh <клон> contracts/142-skaner-sekretov.md` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 13 буллет(ов), НЕ ЗАЩИЩАЕТ 12 буллет(ов))`, rc 0. `check_provodka.sh <клон> contracts/142-skaner-sekretov.md` → `проводка: норма-строка не найдена в role-файле: roles/orchestrator.md`, rc 1: ожидается owner-коммит после freeze. `check_charter.sh <клон>` → `FAIL уставной документ изменён без разрешения владельца: contracts/142-skaner-sekretov.md в 69d67a50 — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/142-skaner-sekretov.md <причина>» в первой колонке`, rc 1: известная временная заглушка, разрешение подставляет оркестратор при сборке поезда. `check_zones.sh <клон>`: первая попытка остановлена внешним timeout 120 с, повтор закончен за 320,90 с, итог `замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 35677 · проверено по зонам: 7810`, отказов в выводе нет.

СОВЕТ contracts/142-skaner-sekretov.md:234 — список остатка честно называет scp-форму без `://`, пустой токен, а также `mailto:` как попадание унаследованной двоеточие-ветви. Явно назвать буквальный/URL-кодированный `%40` и пробел перед `@` полезно, но эти дополнительные классы сами по себе не причина FAIL в пределах заявленного канона.

Не проверено: живой дом секретов станции (запрещён); реальная роль после owner-коммита и живой workshop (ещё не существуют на OBJECT); фактическая модель автора по трейсу и его независимость от Sol (трейс не предъявлен); чужой origin вне локального OBJECT. Проверенные миры — только fake HOME. Ни коммита, ни push из клона критика не было.

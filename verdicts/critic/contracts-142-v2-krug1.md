FAIL
OBJECT=f1f5ffe70bbb3f5ed1e1579b898c5047db2fd34f
СУД: repo=dev-harness; предмет=142 (v2); фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic142c-2; модель-факт=openai-codex/gpt-6-sol; SHA=f1f5ffe70bbb3f5ed1e1579b898c5047db2fd34f; предыдущий=critic 142 v1 (1/2 FAIL, 2/2 FAIL, арбитраж, 3-й accept); исключение=нет. Автор Architect142v2 — zai/glm-5.3; семейства независимы.

БЛОКИРУЕТ contracts/142-skaner-sekretov.md:8 — класс причины: приёмка слабее прямо записанной в контракте воли владельца. «Любая строка secrets.env с NUL **или иным байтом вне грамматики имени** → именованный отказ ... до workshop» требует отказа также для неконформного имени без совпадения значения в индексируемом файле. Но §НЕ ЗАЩИЩАЕТ (:210) прямо объявляет для `FOO.URL=тихое-значение` БЕЗ утечки отсутствие именованного отказа, а И-7 (:45), ось N и модель проверяют лишь NUL без утечки; k43–k98 проверяют остальные неконформные имена только С утечкой. Это не остаток за пределом названного обязательства: «любая строка» не содержит условия утечки. Договорённость об усечении ключа по пробелу не даёт автору права самостоятельно переопределить новое слово владельца; коллизию с d2/d5/z4 следует явно разрешить ДО заморозки, не объявлять один из двух исходов вне защиты.
ОБХОД: честная модель успешно проходит немодифицированный `W --model` 132/132, но в точечной одноразовой копии того же раннера без создания файла `proj/leak.txt` для k43–k98 модель запускает workshop (rc 0, calls=1) вместо именованного отказа для имени `X… .O_URL`, содержащего точку вне IMYA_RE; 56 клеток красны. Исходный критерий такого мира не предъявляет. Закрывающее свойство: на входе с байтом вне грамматики имени и без утечки получить названный отказ до workshop либо предъявить отдельное явное слово владельца, исключающее этот случай; добавить живые красные клетки для принятой границы без порчи прежних конформных обязательств.

СОВЕТ contracts/142-skaner-sekretov.md:45 — `grep -P` требует PCRE2: на измеренной станции `/usr/bin/grep` GNU 3.11 с PCRE2 10.42, в объявленном CI `ubuntu-latest`; отсутствующий/неподдерживающий `-P` grep вернёт отказ, а не пропуск, но на иной минимальной платформе честный дом без NUL также будет отвергнут. Если такая платформа допустима, назовите зависимость или выберите переносимую предпроверку. Ныне не доказан допустимый целевой раннер без `-P` — совет, не самостоятельный блокер.
СОВЕТ contracts/142-skaner-sekretov.md:207 — гонка подмены файла между новой проверкой и старым циклом read не выделена отдельно среди 9 остатков: при одновременном человеческом редактировании возможен обход NUL-предпроверки. Не доказана доступность противнику записи в доверенный дом секретов в этом окне, поэтому пока это совет. Унаследованный grep-127 без pipefail честно назван отдельно (:211).

Доказательства, команды исполнялись из `/tmp/dev-harness-verify/Critic142c/repo` (кроме явно названных одноразовых копий). Ниже дословные существенные строки stdout/stderr, без пересказа результатов атак:
```
git cat-file -t f1f5ffe70bbb3f5ed1e1579b898c5047db2fd34f
commit

git diff --stat frozen/contracts/142/1 f1f5ffe70bbb3f5ed1e1579b898c5047db2fd34f -- contracts/142-skaner-sekretov.md
 contracts/142-skaner-sekretov.md | 65 +++++++++++++++++++++++++++++-----------
 1 file changed, 48 insertions(+), 17 deletions(-)

jq -r '"osi=\(.osi|length) stabs=\(.stab_vhod|length) bindings=\([.stab_vhod[]|length]|add) model_sha256=\(.model_sha256)"' fixtures/workshop_project/skaner_sekretov_142/source.json
osi=132 stabs=31 bindings=197 model_sha256=8076f5b0d77367d5fa2525d4b5e0a1c375f9191551250d142c936f398a9e9c8e

bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic142c/repo contracts/142-skaner-sekretov.md
OK
[rc=0]
bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic142c/repo contracts/142-skaner-sekretov.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic142c/repo contracts/142-skaner-sekretov.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 12 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))
[rc=0]
```

Исходная батарея, модель ×3, стабы, старый OBJECT и наследие (цитирую строку итога и ключевые строки, не заменяю ими полную трассу):
```
bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
КЛЕТКА n1-mir-adversarii КРАСНА: ждали именованный отказ sekret-v-dereve (категория NUL) rc 1 до сессии отказ не называет категорию NUL;
s142 subjekt: клеток 132, зелёных 100, красных 32
[rc=1]
bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
КЛЕТКА n1-mir-adversarii ЗЕЛЕНА
s142 model: клеток 132, зелёных 132, красных 0
[rc=0; повтор 2 rc=0 132/132; повтор 3 rc=0 132/132]
bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --stabs
s142 model-opora-stabov: клеток 132, зелёных 132, красных 0
ПОЙМАН stab_nul-normalizuet-read @ n1-mir-adversarii
ПОЙМАН stab_predproverka-pervaya-stroka @ n10-vo-vtoroj-stroke
ПОЙМАН stab_predproverka-fail-open @ n12-nechitaemyj-dom
ПОЙМАН stab_nul-otkaz-pechataet-znachenie @ n1-mir-adversarii
s142 stabs: стабов 31, привязок 197, непойманных 0
[rc=0]
bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo /tmp/dev-harness-verify/Critic142c/prior
КЛЕТКА n1-mir-adversarii КРАСНА: ждали именованный отказ sekret-v-dereve (категория NUL) rc 1 до сессии rc=0; нет имени sekret-v-dereve; отказ не называет категорию NUL; сессия запущена;
s142 repo: клеток 132, зелёных 120, красных 12
[rc=1; prior=5f7649de1db2801eb7f6de221f5d62d03dfa5755]
bash fixtures/workshop_project/sessii_125/red_sessii_125.sh
s125 red: зелёных 70, красных 0
[rc=0; на одноразовом modeltree с дверью-по-модели]
bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0
[rc=0; на том же modeltree]
python3 /tmp/dev-harness-verify/Critic142c/pinprobe.py
rc= 2
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
[rc=0 у обёртки, rc=2 у субъекта]
```

СВОИ атаки: `python3 /tmp/dev-harness-verify/Critic142c/attack142.py` создаёт четыре независимые мутации только в `/tmp/dev-harness-verify/Critic142c/attacks/*/scripts/connect_project.sh`, запускает для каждой `bash .../red_skaner_sekretov_142.sh --repo <каталог>`; полные сырые stdout/stderr и команды — `attacks/{without_precheck,first_line_only,error_fail_open,leak_on_refusal}.out`. Фактические строки:
```
ATTACK without_precheck rc= 1
КЛЕТКА n1-mir-adversarii КРАСНА: ждали именованный отказ sekret-v-dereve (категория NUL) rc 1 до сессии rc=0; нет имени sekret-v-dereve; отказ не называет категорию NUL; сессия запущена;
s142 repo: клеток 132, зелёных 120, красных 12
ATTACK first_line_only rc= 1
КЛЕТКА n9-v-pustoj-stroke КРАСНА: ждали именованный отказ sekret-v-dereve (категория NUL) rc 1 до сессии rc=0; нет имени sekret-v-dereve; отказ не называет категорию NUL; сессия запущена;
s142 repo: клеток 132, зелёных 128, красных 4
ATTACK error_fail_open rc= 1
КЛЕТКА n12-nechitaemyj-dom КРАСНА: ждали именованный отказ sekret-v-dereve (категория NUL) rc 1 до сессии rc=0; нет имени sekret-v-dereve; отказ не называет категорию NUL; сессия запущена;
s142 repo: клеток 132, зелёных 131, красных 1
ATTACK leak_on_refusal rc= 1
КЛЕТКА n1-mir-adversarii КРАСНА: ждали именованный отказ sekret-v-dereve (категория NUL) rc 1 до сессии отказ печатает значение;
s142 repo: клеток 132, зелёных 131, красных 1
```

Незакрытый класс найден отдельной пробой, а не в перечисленных мутациях: `python3 /tmp/dev-harness-verify/Critic142c/bmaxprobe.py` копирует батарею и необходимые файлы дерева в одноразовый `bmaxprobe`, заменяет единственную строку создания индексируемого leak.txt для неконформных имён на no-op, оставляет исходные ожидания именованного отказа, запускает `--model`. Её сырой вывод:
```
command=bash /tmp/dev-harness-verify/Critic142c/bmaxprobe/fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
rc= 1
КЛЕТКА k43-vne-tocka-url КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=XFBDBF1A957CE.O_URL
КЛЕТКА k44-vne-tocka-host КРАСНА: ждали отказ sekret-v-dereve rc 1 без сессии; rc=0 calls=1 () imya=XE1A30BC8386B.O_HOST
s142 model: клеток 132, зелёных 76, красных 56
```

Проверка предпроверки на окружении: `type -a grep` → `grep is a shell builtin`, `grep is /usr/bin/grep`, `grep is /bin/grep`; `/usr/bin/grep --version` → `grep (GNU grep) 3.11`, `grep -P uses PCRE2 10.42 2022-12-11`; `printf 'X\0=Y\n' | /usr/bin/grep -qaP '\x00'` → rc 0; чистая строка с встроенным grep → rc 1. Отсутствующий дом не затрагивается веткой `if [ -f "$DOM_SEKRETOV" ]` модели; n8–n10 покрывают комментарий/пустую/вторую строку, n5 конец без LF, n12 ошибку доступа. Граница исполнителей ЗОНА architect/implementer/critic/adversary/reviewer/orchestrator названа (:99–104), дифф относительно заморозки 48+/17−, новое расширение двери объявлено (:66). Тело коммита с ожиданием строки разрешения владельца до публикации не считаю блокером согласно заданию.

accept
Ревьюер Rev112r5 (anthropic/claude-opus-5-5), контракт 112 (frozen/contracts/112/2), финальный scoped-проход по перечню п.(3) арбитража `verdicts/arbitration/contracts-112-impl-ostatki-krug4.md` (коммит d5f000579). OBJECT=47edb2120e93eb51e4aace56820018a3e81101cc (refs/union/112-r4). Пять пунктов перечня сошлись, каждый замерен заново в свежем клоне `/tmp/dev-harness-verify/Rev112r5/m`. Код со времени круга 4 не менялся: блобы `check_project_connection.sh` (5a865b8b), `red_podkljuchenie_112.sh` (6a8b805f) и `model_check_connection.sh` (be8e227c) совпадают с клоном Rev112r4.

---
status: ready
object: 47edb2120e93eb51e4aace56820018a3e81101cc
contract: frozen/contracts/112/2 (^{commit} 24672c6ad)
reviewer: Rev112r5 (anthropic/claude-opus-5-5)
date: 2026-10-21
round: 5 (scoped, перечень арбитра п.3; новых блокеров вне перечня не открывается)
witnesses: /tmp/dev-harness-verify/Rev112r5/{lib.sh,regress.sh,regress.out,runs.sh,bat.log,batm.log,stab-state.sh,stab-kom.sh}
---

## Принятые остатки (решение арбитра, verdicts/arbitration/contracts-112-impl-ostatki-krug4.md)

Здесь ни один остаток не считается блокером. Класс у всех один: «злонамеренный владелец репо / гипотетический вход профиля». Основания: §Модель угроз, НЕ ЗАЩИЩАЕТ строки 1–2; правило триажа владельца 2026-09-24; AGENTS правила 1 и 8.

- [x] п.1.1 (A1 Rev112r4, блокер Adv112r4). Лист `mobile/package.json` — symlink наружу. impl 0 / model 1. Моя мера сейчас: `regress.out` `n-pkgjson-leaf-symlink impl rc=0 model rc=1`, без изменений с круга 4.
- [x] п.1.2 (B1r4). sourceCanon path указывает на каталог. impl 0 / model 1: `regress.out` `n-src-dir impl rc=0 model rc=1`. Это регресс относительно 9f549bec5, но ущерба честному профилю нет.
- [x] п.1.3 (B2). Хвостовой LF в workflowPaths/state при существующем LF-имени и symlink наружу. impl 0.
- [x] п.1.4 (A2). LF между строками команды. impl 0 / model 0: `r2-node-newline-exit0-A/-A4 impl rc=0 model rc=0`. Тот же класс, что A4 кругов 2–3.
- [x] п.1.5 (A3). Option-injection `node --require …`, когда в корне лежит файл `--require`.
- [x] п.1.6 (A4). Запятая вне `tok_safe` (:158). Здесь продукт строже модели и шапки.
- [x] п.1.7 (A5). `LC_ALL=C` и не-ASCII путь. Продукт строже, отказ громкий.

Кто ловит. Первый живой прогон `bash scripts/check_project_connection.sh --repo <клон>` на реальных Complior-back/Complior-mob после merge продуктовых PR (контракт п.8, сейчас NOT_RUN). Затем дверь 996 `check_project_sources.sh`: каталог или лист-symlink источника дают именованный отказ. Затем CI проекта и судьи первого бэкенд-контракта.

Долг честности текста в `scripts/check_project_connection.sh`. Арбитр записал его; исправить при следующем касании файла, отдельный круг не открывать:
- шапка :52-56 утверждает, что лист package.json канонизируется; на деле нет;
- :48-49, :59-63, :267-268 и тексты `fail` :221/:234/:370 утверждают, что управляющие байты ловятся «по форме»; на деле ловится только NUL, LF — нет;
- :158 расходится с шапкой и текстом отказа: запятой в `tok_safe` нет.

В батарее неверен комментарий D56 :694-696 «дефект — форма значения»: отказ на деле приходит по `не каталог`.

## Перечень п.(3) — сырой вывод rc

### 1. OBJECT, контракт, зоны — СХОДИТСЯ
```
git rev-parse HEAD                                  → 47edb2120e93eb51e4aace56820018a3e81101cc
git -C /home/harness/dev-harness rev-parse refs/union/112-r4 → 47edb2120e93eb51e4aace56820018a3e81101cc
git diff --stat frozen/contracts/112/2^{commit}..HEAD -- contracts/112-podklyuchenie-proekta.md | wc -l → 0
== 61260217c implementer: .github/workflows/ci.yml package.json registry/ci-steps.tsv scripts/check_project_connection.sh scripts/profile_resolver.sh
== f27db3964 implementer: scripts/check_project_connection.sh
== 9f549bec5 implementer: scripts/check_project_connection.sh
== 2a51862f4 implementer: scripts/check_project_connection.sh
== a0deff1c6 architect: fixtures/workshop_project/podklyuchenie_112/{model_check_connection.sh,red_podkljuchenie_112.sh}
== 32face307 architect: (те же 2 файла)
== 47edb2120 architect: (те же 2 файла)
```
Остальные коммиты в диапазоне frozen..HEAD — база main, они предшествуют 61260217c (`merge-base --is-ancestor 0868cc67f 61260217c` → true):
- 0868cc67f reviewer: verdicts 113
- 158d56ca9 adversary: verdicts 113
- 548d69f9a owner: check_spec_ready.sh
- ee48cfb4e, bb6fbea08, 38e3d603e orchestrator: HANDOFF и registry; 38e3d603e пустой

К предмету 112 эти коммиты не относятся.

### 2. Батарея, `--model`, неизвестная клетка, анти-плацебо — СХОДИТСЯ
```
battery rc=0 :: ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0
battery --model rc=0 :: ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0
--cell net-takoj-kletki rc=2 :: использование: red_podkljuchenie_112.sh [--model] | --cell <имя клетки>
stab-state deleted lines: 15; stab-kom deleted lines: 95
state-blind D14-state-vne-repo rc=1
state-blind D16-state-symlink-zveno rc=1
komandy-blind (23 komanda-клеток, rc1=23): D2=1 D34=1 D35=1 D36=1 D37=1 D38=1 D39=1 D40=1 D41=1 D42=1 D43=1 D44=1 D45=1 D46=1 D47=1 D48=1 D49=1 D50=1 D51=1 D52=1 D53=1 D54=1 D59=1
```
Счёт 63 проверен своей мерой, не по ИТОГ батареи. Статически в исходнике батареи 63 уникальных case-метки: M1, M2, K1, K2 и D1…D59 — 4 + 59. Каждая из них — отдельный уникальный ID. Komanda-клеток среди case-меток 23. Сырой grep без `)` даёт 33, потому что дополнительно ловит 10 строк массива KLETKI_112. Встроенное анти-плацебо полного прогона (`bat.log`) показывает 24 строки «ОЖИДАНИЕ rc=1 ФАКТ rc=0» против контрмоделей: D14, D16 и 22 komanda-клетки.

### 3. Контракт п.6 и п.7, provodka, threat — СХОДИТСЯ
```
p6 jq rc=0
p6 awk rc=0
p6 gen --check rc=0
p6 gen --write && --check rc=0 ; porcelain after --write: 0
p6 parity rc=0 :: workflow-команд: 19 · скриптов в приёмке: 75 · объявленных исключений: 27 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
p7 run_battery rc=0 :: БАТАРЕЯ profile_resolver: итог 4/4 классов закрыто
p7 krasnye054 rc=0 :: итог 054: rc=0
provodka rc=0
threat rc=0 :: модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))
porcelain: 0
```

### 4. Честные M1/M2 зелёные; входы-блокеры кругов 1–3 дают rc 1 — СХОДИТСЯ
```
impl --cell M1-back-model rc=0
impl --cell M2-mob-model rc=0
grep -c '^P ' regress.out → 127
impl/model:  21 × 0/0 · 3 × 0/1 · 2 × 1/0 · 101 × 1/1
diff (regress.out r4 vs r5, пути и имена миров нормализованы) rc=0
```
Каждый вход из перечня арбитра даёт rc 1 с именованной причиной:
- F1–F3 круга 1 → `komandy`: `r1-node-abs-outside` («абсолютный»), `r1-node-dotdot` и `r1-npm-prefix-dotdot` («канонически вне репо»), `r1-npm-or-true` («токен вне белого алфавита»).
- B1–B3 круга 2 → `komandy`/`workflowPaths`. Пробы: `r2-npm-prefix-symlink-out`, `r2-npm-prefix-sub-dotdot2`, `r2-npm-prefix-twice`, `r2-node-symlink-leaf-A3`, `r2-node-pipe/amp/semicolon`, `n-wp-contracts-symlink`.
- B1 круга 3 → `komandy` «токен вне белого алфавита»: `n-tilde-prefix`, `n-brace/squote/dquote/backslash-node-escape`, `r2-npm-glob`.
- LF-канон круга 3 → `kanon-remote` «≠ origin клона (БАЙТ В БАЙТ)»: `n-remote-trailing-nl`, `nl2`, `nl3`.

rc 0 на этих 127 прогонах встречается только в трёх группах:
- честные входы: `honest`, `node-honest-arg`, `tabs-sep`, `state-dotdot-into`, `src-honest`;
- 0/0, принятые прежними кругами: A4 newline, `n-remote-insteadof/pushurl/two-urls`, `.git` как state, `n-cmd-leading-space`, содержимое скрипта package.json (`n-script-empty-string/true`), `n-layer-env-override`;
- принятые остатки п.1.1 и п.1.2: `n-pkgjson-leaf-symlink`, `n-src-dir`.

Строки 1/0 — `n-cmd-nul-tail`: продукт строже модели.

### 5. Остатки записаны остатками — СХОДИТСЯ
Раздел «Принятые остатки» выше: п.1.1–1.7 со ссылкой на файл арбитража, ловцом и долгом честности комментариев. Ни один из B1r4/B2/A1–A7 не выставлен блокером.

## Советы (не блокируют, вне перечня)
- Счётное расхождение в тексте арбитража: «шесть остатков» и «(шесть, п.1.1–1.7)», хотя пунктов семь — 1.1…1.7: лист package.json, B1r4, B2, A2, A3, A4, A5. При записи в NABLIUDENIA/HANDOFF оркестратору стоит писать «семь».
- Норма 050 (паразитная сложность). Новых артефактов в этом проходе нет, OBJECT тот же. Строки пяти вопросов по артефактам диффа стоят в вердикте круга 4 (`verdicts/review/contracts-112-impl-v4.md`, раздел 050) и остаются в силе. Отмеченная там неполнота клеток (каталог в source-canon, существующее LF-имя, лист package.json) — это ровно остатки п.1.1–1.3.
- Мобильного экрана в предмете нет, сверка с макетом неприменима.

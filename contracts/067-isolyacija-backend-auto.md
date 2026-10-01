# Контракт 067 — isolation.backend: auto — конфиг изоляции спавна не пиннит ФС машины (задача (б) владельца)

## Предмет

Слово владельца 2026-10-01: «харнес обязан одинаково работать на домашней btrfs и на серверной
ext4»; задача (б). Боль: .omp/config.yml пиннит ЛЕГАСИ-ключ `task.isolation.mode: btrfs` — выбор
бэкенда делает ОПЕРАТОР, зная файловую систему машины; конфиг, перенесённый между машинами,
молча объявляет ложь о машине (на ext4 заявлен btrfs, которого ФС не даёт).

Живые замеры ДО (этот сервер, 2026-10-01; все числа из команд, выводы в §Красные предъявления):

- замер ФС: `stat -f -c %T /home/harness/dev-harness /tmp` → `ext2/ext3` на обеих точках, `df -T`
  точек → `ext4` (/dev/md2) — расхождение двух мер это общая statfs-магия ext2/3/4: ФС одна,
  ext4-семейство, сабволюмов btrfs нет;
- эффективный пин: `omp config get isolation.backend --json` → `"value": "btrfs"` (enum, описание «Backend used
  for subagent isolation and worktree cloning») — эффективный пин пришёл МИГРАЦИЕЙ из легаси-
  строки проекта: omp://settings.md «Field-level migrations» — `task.isolation.mode: <backend>`
  → `task.isolation.enabled: true` + `isolation.backend: <backend>`; `omp config get
  task.isolation.enabled --json` → `true`;
- изолированные спавны на этой машине РАБОТАЮТ: два живых изолированных субагента (sonic,
  sleep 45 и sleep 40) завершились `exit_code` 0 за 54.0с и 43.2с — PAL omp сам откатывается в
  копию: под `~/.omp/profiles/dev/wt/` лежат зеркальные копии дерева с суффиксом `/m`
  (t20fa0662d, t5cf7a2c56, tf77b9c653 — три штуки от 2026-09-30; внутри t20fa0662d/m/: roles/,
  fixtures/, AGENTS.md, plans/ — полная копия); omp://tools/task.md:130 — «recursive copy as
  last resort»;
- вывод: на ext4 фактический бэкенд уже «копия», но достигнут он не конфигом, а внутренним
  откатом чужого рантайма; конфиг при этом объявляет btrfs. Значение `auto` принято схемой omp
  (живая проба overlay PI_CONFIG_FILES → эффективное `auto`).

Лечение: явная пара новых ключей omp — `task.isolation.enabled: true` + `isolation.backend:
auto` (единый источник omp://tools/task.md:116: замкнутый enum `auto apfs btrfs zfs reflink
overlayfs projfs block-clone rcopy`, «PAL resolves the actual backend with fallback»). auto =
выбор бэкенда по ФС машины силами PAL omp: один и тот же конфиг даёт сабволюмы на btrfs-домашней
и копию на ext4-сервере. Свой ФС-детект харнес НЕ строит (Н-48: обход встроенной фичи запрещён).

## §Существующее (B2d)

- .omp/config.yml:59-67 — блок «Изоляция спавна субагентов (решение владельца 2026-08-26, шаг
  А)» с `task.isolation.mode: btrfs`; сам факт включения изоляции (шаг А контракта 012) не
  трогается — 067 меняет форму ключей и значение.
- Ветвь izolcfg барьера scripts/check_runner_hygiene.sh:812-826 — грамматика v1 (awk на
  `mode: btrfs`) и строка шапки :97; обманка case_izolcfg_bez_kljucha.sh («ключа нет»);
  toy-норма mk_norm_isol() в fixtures/check_runner_hygiene/_lib.sh:40-66; соседние ветви klon
  (:832-840, roles/architect.md) и izolnorm (:847-855, roles/orchestrator.md) не меняются.
- roles/architect.md:244 (раздел «Клон роли») и roles/orchestrator.md:121 (раздел «Изоляция
  прогонов и спавна субагентов», строки 117-128; в задании оркестратора строка названа :128 —
  дерево истина: живая ссылка на легаси-ключ на :121) — синхронизируются реализацией.
- Соответствие ключей omp: omp://settings.md (Field-level migrations) и omp://tools/task.md:116;
  живые пробы — omp config get isolation.backend / task.isolation.enabled.
- Конвенция красных батарей семьи fixtures/check_runner_hygiene/red_*.sh (red_pin_spawn_zadanie
  032, red_marker_exit 025): judge-run вне case_*-глоба CI-шарда (verify_antiplacebo выбирает
  только case_*.sh); конвенция «красное ДО реализации, rc≠0 допустим» — 025/032/037 (задача б
  check_precision_gate). Зелёный корень клеток — mk_green_root из _lib.sh.

## Инварианты (кодовые)

1. Норма конфига: .omp/config.yml несёт пару — вложенный `task:` → `  isolation:` →
   `    enabled: true` И верхнеуровневую группу `isolation:` (без отступа) → `  backend: auto`;
   значения литеральные true/auto из схемы omp; enum замкнут (omp://tools/task.md:116).
2. Легаси-пин запрещён: ключ `mode:` под task.isolation (любое значение) не принимается; явные
   пины `backend: btrfs` / `backend: rcopy` и любые иные значения enum, кроме auto, не
   принимаются.
3. Половины нормы нет: enabled без backend, enabled: false, backend по легаси-пути
   (task.isolation.backend) — отклонения с именованной причиной.
4. Грамматика ветви izolcfg v2 структурна: якорь отступа различает верхнеуровневую `isolation:`
   от вложенной под `task:`; сравнения литеральны (`enabled:[[:space:]]*true`,
   `backend:[[:space:]]*auto`) — «TrUE», «AUTO», значение с хвостом не совпадают.
5. Один коммит реализации: конфиг + ветвь izolcfg v2 + toy mk_norm_isol (_lib.sh) + строки ролей
   — ОДНИМ коммитом; раздельный ленд держит CI красным (v2 на легаси-конфиге красна, v1 на
   новой паре — тоже).
6. Поведение на обеих машинах идентично силой auto (PAL omp), не нашей логикой: приёмка
   домашней btrfs-машины — по слову владельца (§Незаполненные требования).
7. Существующие ветви и клетки не деградируют: klon, izolnorm, обманка case_izolcfg_bez_kljucha
   («ключа нет вообще» ловится обеими грамматиками), toy mk_green_root после перевода toy-нормы
   на новую пару ключей.

## Модель угроз

ЗАЩИЩАЕТ:
- молчаливый перенос ФС-специфичного пина между машинами: легаси mode: btrfs и явные пины
  (btrfs/rcopy) ловятся ветвью izolcfg v2 именованным отказом на живом дереве в каждом CI-прогоне;
- половинчатую конфигурацию (enabled без backend, выключенную изоляцию, перепутанный путь
  ключа) — структурной грамматикой с литеральными якорями и именованными причинами;
- регрессию самой нормы: батарея red_izolcfg_backend_avto_067.sh (7 клеток) ловит
  барьер-«всё-принимаю» (клетки к2-к7) и барьер-«всё-отвергаю» (клетка к1) — обе стороны.

НЕ ЗАЩИЩАЕТ:
- какой бэкенд PAL omp фактически выбрал на данной ФС и качество/скорость копии — чужой
  рантайм; судится живой пробой на машине (Р7), не грамматикой репозитория;
- файл, несущий легаси- и новые ключи ОДНОВРЕМЕННО: норма требует отсутствия mode:, но
  семантику двойственных ключей в рантайме определяет мигратор omp — 067 не исследует и не
  фиксирует (избегается инвариантом 2);
- глобальный ~/.omp/agent/config.yml пользователя, перекрывающий проектный ключ по precedence
  omp, — вне стерегомого дерева.

## Зоны (check_zones)

ЗОНА architect: contracts/067-isolyacija-backend-auto.md fixtures/check_runner_hygiene/ NABLIUDENIA_ARCHITECT.md

ЗОНА implementer: scripts/check_runner_hygiene.sh fixtures/check_runner_hygiene/
ПЕРЕСЕЧЕНИЕ architect: NABLIUDENIA_ARCHITECT.md — 015 implementer-зона 015 — 015 объявляет двойное владение (architect+implementer) для одноразовой landed-миграции заголовков; 067 владеет путём как обычной записью воркфлоу-наблюдений А-312 (прецедент 037/066), ту историю не трогает

ПЕРЕСЕЧЕНИЕ implementer: scripts/check_runner_hygiene.sh — 011 architect-зона 011 — предмет и ветви барьера гигиены; 067-пачка меняет только ветвь izolcfg, чужие ветви не трогает
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_runner_hygiene.sh — 012 architect-зона 012 — автор ветви izolcfg (шаг А); 067 переносит владение ветвью на implementer-пачку по СТРОГОМУ ПОРЯДКУ владельца 2026-10-01 (реализация после заморозки)
ПЕРЕСЕЧЕНИЕ implementer: fixtures/check_runner_hygiene/ — 011 architect-зона 011 — фикстуры семьи; 067 добавляет red-батарею и переводит toy mk_norm_isol, существующие case_* не трогает
ПЕРЕСЕЧЕНИЕ implementer: fixtures/check_runner_hygiene/ — 012 architect-зона 012 — toy-норма изоляции mk_norm_isol; переводится той же реализационной пачкой (инвариант 5)
ПЕРЕСЕЧЕНИЕ implementer: fixtures/check_runner_hygiene/ — 025 architect-зона 025 — red-батареи семьи; 067 добавляет свою, чужие не трогает

Остальные поверхности предмета покрыты СУЩЕСТВУЮЩИМИ замороженными зонами (union check_staged,
проверено zones_load на 8d856ef): .omp/config.yml — implementer 002/012/025;
roles/architect.md — implementer 012; roles/orchestrator.md — implementer 012. Новых заявлений
не требуется.

## ПРОВОДКА

ПРОВОДКА:
- guard=scripts/check_runner_hygiene.sh

ПРОВОДКА-ЭНФОРСМЕНТ: предмет 067 — чистый энфорсмент (норма состояния дерева: конфиг несёт
пару ключей auto; поведенческой нормы для ролей нет — роли лишь синхронизируют ссылки на
ключи). Канал один — guard: ветвь izolcfg барьера scripts/check_runner_hygiene.sh, подключён
в CI напрямую (ключ check_runner_hygiene в .github/workflows/ci.yml:63 и шаги шардов) и судит
живое дерево каждого прогона. Красная дверь предмета — прямые прогоны судьями батареи
fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh (7 клеток) до и после реализации;
CI-проводка батареи не расширяется (red_* вне case_*-глоба шарда — прецедент 032).

## Красные предъявления

Батарея — fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh (новая; конвенция
семьи: зелёный корень mk_green_root из _lib.sh + подмена toy-конфига клетки; оракул — rc живой
ветви izolcfg настоящего барьера, копий грамматики в батарее нет).

### Красное сейчас (до реализации — прогон живьём, 2026-10-01, клон на 8d856ef)

- `bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh .` → красная: КРАСНОЕ 067
  — rc 1, «ИТОГ 067: ветвей 7, красных 2, зелёных 5»: красные к1 (v1 отвергает честную пару
  ключей: rc=1 на норме auto) и к2 (v1 ПРИНИМАЕТ легаси-пин mode: btrfs: rc=0 + «ok (izolcfg)
  .omp/config.yml несёт task.isolation.mode: btrfs» — главный флип предмета: сегодняшний барьер
  благословляет пин машины, живой вывод дословно); к3-к7 — зелёные контроли (отказы rc=1 с
  именованной причиной «ОТКАЗ ветвь (izolcfg)»).
- `bash scripts/check_runner_hygiene.sh . izolcfg` → rc 0 сегодня («ok (izolcfg) … mode:
  btrfs» — v1 зелёна на легаси-пине живого дерева); после реализации тот же прогон зелёный на
  новой паре ключей — CI не краснеет ни до, ни после (инвариант 5).

Клетки (привязка стабов к входам, где дефект наблюдаем — код фикстуры, Н-39): к1 norma-avto —
честная пара ключей, ПРИНЯТ; к2 stab-legasi-pin «без авто-детекта» — легаси mode: btrfs, ровно
нынешний живой конфиг, ОТВЕРГНУТ (btrfs-only: на ext4 живёт внутренним откатом PAL, не нормой);
к3 stab-pin-btrfs «без отката» — enabled:true + backend: btrfs, ОТВЕРГНУТ (заявляет
ФС-зависимый бэкенд без отката в норме); к4 stab-hardkod-rcopy «хардкод copy» — backend: rcopy,
ОТВЕРГНУТ (на btrfs-домашней саботирует сабволюмы); к5 vykljucheno — enabled: false, ОТВЕРГНУТ;
к6 bez-backend — enabled без backend, ОТВЕРГНУТ; к7 backend-ne-tam — backend: auto вложен в
task.isolation (легаси-путь), ОТВЕРГНУТ.

Анти-таутология: барьер-«всё-принимаю» ловится к2-к7, барьер-«всё-отвергаю» — к1; текущая v1 —
буквально стаб «без авто-детекта», и к2 красна на ней сегодня живым прогоном.

### После реализации (приёмка implementer-пачки; сюда прогоны вносит реализация)

Батарея целиком: «ИТОГ 067: ветвей 7, красных 0, зелёных 7», rc 0. Живое дерево:
`bash scripts/check_runner_hygiene.sh . izolcfg` → rc 0 на паре ключей; klon и izolnorm → rc 0
(не деградировали). omp-проба на сервере: omp config get isolation.backend → auto;
task.isolation.enabled → true. Живой изолированный спавн (ext4) — exit_code 0 (замер ДО уже
дал 0; ПОСЛЕ — тем же результатом силой конфига: конфиг больше не объявляет btrfs).

## Приёмка (сценарии; грамматика 050)

- Р1. дано: toy-корень клетки к1 (конфиг: task.isolation.enabled: true + верхнеуровневая
  isolation.backend: auto); когда: bash scripts/check_runner_hygiene.sh <корень> izolcfg;
  тогда: до rc 1 (v1 не знает ключей), после rc 0 + «ok (izolcfg)». Негативная пара (к7):
  backend: auto ВЛОЖЕН в task.isolation — rc 1 «ОТКАЗ ветвь (izolcfg)» до и после.
- Р2. дано: toy-корень клетки к2 (легаси mode: btrfs — байт-в-байт нынешний живой конфиг);
  когда: та же команда; тогда: до rc 0 (пин благословлен — клетка к2 красная сегодня), после
  rc 1 «ОТКАЗ ветвь (izolcfg)». Негативная пара (к5): enabled: false — rc 1 до и после.
- Р3. дано: toy-корень к3 (enabled: true + backend: btrfs); когда: та же команда; тогда: rc 1
  до и после. Негативная пара (к4): backend: rcopy — rc 1 до и после.
- Р4. дано: toy-корень к6 (enabled: true, верхнеуровневой группы isolation нет); когда: та же
  команда; тогда: rc 1 до и после (половина нормы не принимается).
- Р5. дано: живое дерево; когда: bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh
  . ; тогда: до rc 1 «ветвей 7, красных 2», после rc 0 «ветвей 7, красных 0, зелёных 7».
- Р6. дано: живое дерево после реализационного коммита; когда: bash
  scripts/check_runner_hygiene.sh . izolcfg и omp config get isolation.backend (в корне
  дерева); тогда: rc 0 и «auto». Негативная пара: ручной возврат легаси-строки в конфиг —
  izolcfg rc 1 (норма держит после сдачи).
- Р7. дано: серверная ext4-машина (эта); когда: изолированный task-спавн (sonic, sleep 40);
  тогда: exit_code 0, под ~/.omp/profiles/*/wt/ — зеркальная копия с суффиксом /m (auto → PAL
  fallback rcopy); до и после — 0 (замер ДО: exit_code 0, 54.0с и 43.2с).

Числовая сверка (А-300): клеток батареи 7 (к1-к7), сценариев 7 (Р1-Р7), каждая клетка покрыта:
Р1=к1+к7, Р2=к2+к5, Р3=к3+к4, Р4=к6, Р5=батарея целиком, Р6=живое дерево+omp-проба, Р7=живой
спавн; ДО-красных 2 (к1, к2), ПОСЛЕ-красных 0. Сверка побайтово: 2+1+1+1+1+1+1 = 8 вхождений
клеток в сценарии Р1-Р4 (к1,к7,к2,к5,к3,к4,к6 — 7 клеток, к1 дополнительно в Р5 опосредованно).

## Незаполненные требования:

- реализация — implementer ПОСЛЕ заморозки, ОДНИМ коммитом (СТРОГИЙ ПОРЯДОК, слово владельца
  2026-10-01): (а) .omp/config.yml — легаси-блок заменить парой ключей по инварианту 1 с
  комментарием-ссылкой на 067 и omp-источник; (б) ветвь izolcfg v2 в
  scripts/check_runner_hygiene.sh (+строка шапки :97) с именованными причинами: легаси-пин /
  пин бэкенда / изоляция выключена / без backend / путь ключа; (в) toy mk_norm_isol в
  fixtures/check_runner_hygiene/_lib.sh — новая норма (зелёный контроль семьи); (г)
  roles/architect.md:244 и roles/orchestrator.md:121 — ссылку «.omp/config.yml →
  task.isolation.mode: btrfs» заменить на пару ключей 067; case_izolcfg_bez_kljucha.sh правки
  НЕ требует (обманка «ключа нет» ловится обеими грамматиками, зелёный контроль — toy из
  _lib.sh);
- приёмка на домашней btrfs-машине — по слову владельца (серверная ext4 — Р7 здесь); ожидание:
  auto → сабволюм под wt/<id> БЕЗ суффикса /m;
- CI-проводка красной батареи не расширяется (judge-run по прецеденту red_* семьи 032).

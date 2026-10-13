accept — находка adversary 093-v4 (stale credential-носители переживают `install.sh root`) закрыта механической приёмкой Р-4(в) арбитража `093-adversary-round-cap-v1`. Команды 1–4 арбитра на `4c967a721` дали ровно предписанное. Дельта `96ec3a5bf..4c967a721` не добавляет ни одного отказа `check_zones`. Команда 5 в букве («ни одного отказа по коммитам 093») НЕ выполнена: 14 отказов по `d9d727d0`. Это известный долг Р-4(а) п.2, механика пересборки за оркестратором, новой находкой круга он не является. Ленд/`done` без этой пересборки краснеет в CI (Рв5-1).

# Review 093, круг 5 — приёмка закрытия круга adversary 4

МОДЕЛЬ: `anthropic/claude-opus-5-5`. Трасса: `scripts/models_actual.sh --tsv` → `reviewer	anthropic/claude-opus-5-5	allowed`; `make_task.sh` → `TRACE: role=reviewer model=anthropic/claude-opus-5-5 fallback=allowed`, `TASK: sha256=331cec5b5fcb795e28f62c5aeca61a988440c8ee935415a5e514e50c848df3c4`, rc=0. Семейство anthropic. Автор находки — adversary на `openai-codex/gpt-5.6-terra`. Автор клетки — architect на `anthropic/claude-fable-5-1`, это то же семейство, что у меня. Асимметрия записана. Спор механический, а каждое утверждение ниже проверено прогоном.

**Субъект.** `origin/wip/int-093/architect` @ `4c967a7210e00a75985919d69402c72b7b3da529`, сверено через `git ls-remote origin`.

**Основание.** Арбитраж `verdicts/arbitration/093-adversary-round-cap-v1.md`, решение А, Р-4(в), п.1–5. Круга 5 adversary нет. Это прескриптивная приёмка ревьюера, а не новый круг судьи.

**Сборка.** Одноразовый клон `/tmp/dev-harness-verify/rv093c5-q8m2/repo` @ `4c967a721`. Контрольный клон `/tmp/dev-harness-verify/rv093c5-q8m2/ctl` @ `96ec3a5bf` (срез, который судили adversary v4 и арбитр).

**Прочитано.** Целиком: `verdicts/arbitration/093-adversary-round-cap-v1.md`, `verdicts/review/contracts-093-v4.md`, `git show b2b8aaea1`, `git show 4c967a721`. Частично: `verdicts/adversary/contracts-093-v4.md` (находка и аргумент о ложном зелёном), `verdicts/review/contracts-093-v{1,2,3}.md` и `verdicts/critic/contracts-093-v1.md` (только строки вердикта).

## Область круга: бриф сузил дельту неверно

Бриф описывает дельту `d525c902..4c967a721` четырьмя элементами. Своя мера — `git rev-list --count d525c902a..4c967a721` → **16** коммитов (`git merge-base --is-ancestor d525c902a 4c967a721` → предок). Туда входят `5fa9e421`, `6ec660bd`, `8c2cad8d`, `e98f8176`, `a2766860`, `84bfbe4a`, `5a089758`, `98370c8e`, `545499f7`, `6310a4af`, `62ea42ba`, `412a66dc`, `d9d727d0`, `96ec3a5b`, `b2b8aaea`, `4c967a72`.

Арбитр (замер 2) установил, что v2-код (`84bfbe4a`, `5a089758`, `d9d727d0`, `96ec3a5b`) ревьюер ни разу не судил. Этот круг судил:
- поведением — все 9 клеток и батарею на собранном дереве (`_krasnye_093.sh`, ниже);
- содержанием — только два новых коммита `b2b8aaea1` и `4c967a721`.

Построчного содержательного ревью v2-кода этот круг не делал. Об этом Рв5-2.

## Сырой вывод

### Команда 1 арбитра: клетка 9 на честном дереве → rc 0

`bash fixtures/ops_granica/red_agent_runtime_vne_home.sh; echo "rc=$?"`
```
ЗЕЛЁНО(093-9): runtime агента вне /home/harness: код /opt/orch-agent + состояние /var/lib/orch-agent, без .local/bin и группы harness (Рв2-6); install root доставляет workshop побайтовно в мирах F/S (оракул sha256 в памяти — adversary 093-v3 закрыт); stale .env/.env.*/sub/.env/.ssh у получателя не переживают install, источник .env неизменен (adversary 093-v4 закрыт)
rc=0
```
Тот же прогон через `reslop t -- bash fixtures/ops_granica/red_agent_runtime_vne_home.sh` дал `exit: 0` и ту же строку ЗЕЛЁНО.

### Команда 2 арбитра: батарея → rc 0, s9 и s10 пойманы

`bash fixtures/ops_granica/battery_stubs.sh; echo "rc=$?"`
```
s1 ok
s1 фолбэк-без-потолка: ПОЙМАН (rc=1)
s2 ok
s2 bootstrap-из-репо: ПОЙМАН (rc=1)
s3 ok
s3 кредит-в-среде: ПОЙМАН (rc=1)
s4 ok
s4 успех-без-старта: ПОЙМАН (rc=1)
s5 ok
s5 откат-удаление: ПОЙМАН (rc=1)
s6 ok (kill_tree+reap)
s6 сироты-живут: ПОЙМАН (rc=1)
s7 ok (exact x1)
s7 uid-не-переключается: ПОЙМАН (rc=1)
s8 ok
s8 stale-запуск: ПОЙМАН (клетка5 rc=1, клетка6 rc=1 — обе предъявили мир stale)
s9 ok
s9 no-copy runtime: ПОЙМАН (клетка9 rc=1 — install не доставил workshop, adversary 093-v3)
s10 ok
s10 stale-mirror: ПОЙМАН (клетка9 rc=1 — stale .env/.env.*/.ssh пережили install, adversary 093-v4)
ЗЕЛЁНО(093-bat): 10/10 обманных стабов пойманы
rc=0
```

Своя мера числа стабов, не по выводу батареи:
- `grep -c 'total=$((total+1))' fixtures/ops_granica/battery_stubs.sh` → `10`;
- `grep -oE '^# Stub s[0-9]+' … | sort -u` → `s1 s10 s2 s3 s4 s5 s6 s7 s8 s9`.

Батарея заявляет 10, своя мера тоже даёт 10.

### Команда 3 арбитра: подмена одного файла `install.sh` на редакцию `96ec3a5bf` → rc 1, красна именно проверка носителя

`git checkout 96ec3a5bf -- ops/server/install.sh && git status --short && bash fixtures/ops_granica/red_agent_runtime_vne_home.sh; echo "rc=$?"`
```
M  ops/server/install.sh
КРАСНО: мир S: старый credential-носитель пережил install root (rc 0, читаем uid агента после chown root:root 0644) — rsync --delete без --delete-excluded не трогает excluded-записи у получателя (adversary 093-v4):
/tmp/dev-harness-verify/ops-granica-9-vyUNGH/agent_root_S/.env
/tmp/dev-harness-verify/ops-granica-9-vyUNGH/agent_root_S/.env.local
/tmp/dev-harness-verify/ops-granica-9-vyUNGH/agent_root_S/sub/.env
/tmp/dev-harness-verify/ops-granica-9-vyUNGH/agent_root_S/.ssh/id_rsa
rc=1
```

Возврат: `git checkout 4c967a721 -- ops/server/install.sh && git status --short && echo restored-clean && sha256sum ops/server/install.sh && git show 4c967a721:ops/server/install.sh | sha256sum`
```
restored-clean
5798bef98649159aca314afdc8f91a8fd1d3c8c0c4efa6a9992481d66302638a  ops/server/install.sh
5798bef98649159aca314afdc8f91a8fd1d3c8c0c4efa6a9992481d66302638a  -
```

Утверждение v4 воспроизведено буквально: на старом субъекте клетка красна именно по носителю, названы все четыре пути. Новый субъект даёт обратный результат (команда 1).

### Своя мера свойства Р-4(а), другой командой (B2d)

Проба `/tmp/dev-harness-verify/rv093c5-q8m2/probe.sh` запускает `rsync` с флагами из `install.sh:197-198` @ `4c967a721` против более широкого множества носителей, чем у клетки:
- `.env.bak-1` — по образцу реального станционного `.env.bak-*`, замер 4 арбитра;
- `deep/a/b/.env.x`;
- вложенный `sub/.ssh/k`;
- в источнике — `.env` и `sub/.env.prod`.

```
install.sh rsync line: 35:#           OPS_SERVER_MAIN, rsync -a --delete --delete-excluded, root:root,
181:# установщик из него): зеркальная копия rsync -a --delete (идемпотентно),
197:  rsync -a --delete --delete-excluded \
    --exclude='.env' --exclude='.env.*' --exclude='.ssh' \
rsync rc=0
== dst после (find всё):
.
./sub
./workshop
== носители у получателя:
0
источник неизменен
rc=0
```

Свойство «ни одного `.env`/`.env.*`/`.ssh` на любой глубине у получателя, источник неизменен» держится и на множестве шире, чем у клетки.

### Команда 4 арбитра: `_krasnye_093.sh` → красна только И-8б

`bash fixtures/_krasnye_093.sh; echo "rc=$?"`
```
s1 ok
s1 фолбэк-без-потолка: ПОЙМАН (rc=1)
s2 ok
s2 bootstrap-из-репо: ПОЙМАН (rc=1)
s3 ok
s3 кредит-в-среде: ПОЙМАН (rc=1)
s4 ok
s4 успех-без-старта: ПОЙМАН (rc=1)
s5 ok
s5 откат-удаление: ПОЙМАН (rc=1)
s6 ok (kill_tree+reap)
s6 сироты-живут: ПОЙМАН (rc=1)
s7 ok (exact x1)
s7 uid-не-переключается: ПОЙМАН (rc=1)
s8 ok
s8 stale-запуск: ПОЙМАН (клетка5 rc=1, клетка6 rc=1 — обе предъявили мир stale)
s9 ok
s9 no-copy runtime: ПОЙМАН (клетка9 rc=1 — install не доставил workshop, adversary 093-v3)
s10 ok
s10 stale-mirror: ПОЙМАН (клетка9 rc=1 — stale .env/.env.*/.ssh пережили install, adversary 093-v4)
ЗЕЛЁНО(093-bat): 10/10 обманных стабов пойманы
— battery_stubs.sh: rc=0
ЗЕЛЁНО(093-1): установленный bootstrap честно исполнен, подмена установленного файла и его отсутствие — именованный отказ без fallback, ${REPO} не тронут (И-1/И-2)
— red_root_bootstrap_iz_repo.sh: rc=0
ЗЕЛЁНО(093-2): отказ scope → именованный отказ rc 1, воркшоп не исполнен (И-5)
— red_limit_otkaz_bez_zapuska.sh: rc=0
ЗЕЛЁНО(093-9): runtime агента вне /home/harness: код /opt/orch-agent + состояние /var/lib/orch-agent, без .local/bin и группы harness (Рв2-6); install root доставляет workshop побайтовно в мирах F/S (оракул sha256 в памяти — adversary 093-v3 закрыт); stale .env/.env.*/sub/.env/.ssh у получателя не переживают install, источник .env неизменен (adversary 093-v4 закрыт)
— red_agent_runtime_vne_home.sh: rc=0
ЗЕЛЁНО(093-3): сессия через дверь uid (sudo -nu <агент>), контрольные файлы станции недоступны (И-3)
— red_agent_uid_stancija_nedostupna.sh: rc=0
ЗЕЛЁНО(093-4): среда сессии без publication-креденшл (полный станционный список имён) и путей rw-ключа, HOME=агент, открытие ключа/токенов отказом (И-4)
— red_kredit_publikacii_vne_sredy.sh: rc=0
ЗЕЛЁНО(093-5): verify-start различает три мира oneshot: завершён успешно свежий запуск rc 0 / падение rc 1 / stale-успех rc 1, все отказы именованы (И-6a, Рв2-5)
— red_unit_realno_startuet.sh: rc=0
ЗЕЛЁНО(093-6): откат восстановил v1 побайтово и сам завершил НОВЫЙ запуск юнита (Result=success, свежий ExecMainExitTimestamp; падение и stale — rc 1 именованные) (И-6b, Рв2-5)
— red_otkat_vozvrashhaet_rabochuju.sh: rc=0
  a: чисто — сирота мёртв, группа пуста (субъект rc=0)
  b: чисто — сирота мёртв, группа пуста (субъект rc=3)
ЗЕЛЁНО(093-7): оба завершения сессии (естественное rc 0 и по маркеру) оставили дерево/группу пустыми — сирота стаб-omp (имя вне шаблона, TERM-иммунен) зачищен без фильтра по имени (И-7)
— red_net_osirotevshih_detej.sh: rc=0
раннер запущен под uid владельца станции: граница не установлена снаружи (И-8б, арбитраж 093)
— red_germetichnost_semi.sh: rc=1
ИТОГ 093: rc=1
rc=1
```

Итог прогона: батарея и восемь клеток (1, 2, 9, 3, 4, 5, 6, 7) зелёные, красная одна — `red_germetichnost_semi.sh`, И-8б, станционный предел uid. Картина совпадает с ожиданием арбитра и с отчётом architect/implementer.

Своя мера состава: `ls fixtures/ops_granica/` даёт 9 файлов `red_*`, плюс `battery_stubs.sh` и `live_kontur_093.sh`. В выводе раннера ровно 9 строк `— red_*`, и `live_kontur_093.sh` раннер не вызывает.

### Команда 5 арбитра: `check_zones`

У `scripts/check_zones.sh` нет аргумента диапазона: единственный аргумент — корень, а окно идёт от `frozen/contracts/<NNN>/1..HEAD`, строка `:286`. Поэтому «прогон на диапазоне `96ec3a5bf..4c967a721`» снят как разность двух полных прогонов: на `96ec3a5bf` и на `4c967a721`.

На `4c967a721`, полный вывод: `bash scripts/check_zones.sh; echo "rc=$?"` → `rc=1`. Хвост дословно:
```
замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 9448 · проверено по зонам: 3016
rc=1
```
Свёртка отказов, `bash scripts/check_zones.sh 2>&1 | grep -E '^\s*FAIL|^замороженных' | cut -c1-140 | sort | uniq -c`:

на `4c967a721`:
```
     14   FAIL коммит вне зоны: architect d9d727d0 ops/server/install.sh — зона автора (объединение всех з�
      1   FAIL строка ЗОНА вне объявленной грамматики в contracts/055-izoljacija-sostojanija-po-projectid.md: «�
      1 замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 9
rc=1
```
на `96ec3a5bf` (контроль):
```
     14   FAIL коммит вне зоны: architect d9d727d0 ops/server/install.sh — зона автора (объединение всех з�
      1   FAIL строка ЗОНА вне объявленной грамматики в contracts/055-izoljacija-sostojanija-po-projectid.md: «�
      1 замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 9
rc=1
```
Поиск SHA новых коммитов в полном выводе на `4c967a721` (шаблон `b2b8aaea|4c967a72|96ec3a5b`) → совпадений нет.

Что из этого следует:
- **Дельта `96ec3a5bf..4c967a721` (`b2b8aaea1` + `4c967a721`) добавляет 0 отказов зон.** Множества отказов до и после совпадают.
- **`d9d727d0` (architect, `ops/server/install.sh`)** — те же 14 отказов, что арбитр нашёл в замере 5. Это известный прецедент, а не находка круга. Арбитр поручил переоформить коммит в Р-4(а) п.2. Implementer в теле `4c967a721` прямо передал механику оркестратору: «из клона на базе b2b8aaea1 атрибуция коммита d9d727d0 в истории не меняется». Буква команды 5 («ни одного отказа по коммитам 093») поэтому НЕ выполнена. Об этом Рв5-1.
- **`contracts/055…:279`** — отказ существовал раньше 093. Строка лежит и на main: `git grep … main` → `main:contracts/055-…:279`. Её последний коммит — `9914911f0` (architect, 2026-09-28). `git diff --stat main...4c967a721 -- contracts/055-…` пуст. К 093 не относится.

## Зоны и область правки (п.1, п.6 брифа)

Зоны взяты из `git show 'frozen/contracts/093/1^{commit}:contracts/093-granica-ispolneniya-i-postavka-ops.md' | grep -n '^ЗОНА'` (`frozen/contracts/093/1` → `tag`):
```
68:ЗОНА architect: contracts/093-granica-ispolneniya-i-postavka-ops.md fixtures/ops_granica/ fixtures/_krasnye_093.sh NABLIUDENIA_ARCHITECT.md
69:ЗОНА implementer: ops/server/install.sh ops/server/root/orch-peak ops/server/user/orch-loop ops/server/README.md ops/server/root/systemd/ registry/ci-steps.tsv .github/workflows/ci.yml
```
Авторы и пути коммитов (`git log --format='%h %an %ae' 96ec3a5bf..4c967a721`, `git diff-tree --no-commit-id --name-only -r <sha>`):
```
4c967a721 implementer implementer@dev-harness.local
b2b8aaea1 architect architect@dev-harness.local
NABLIUDENIA_ARCHITECT.md
fixtures/ops_granica/battery_stubs.sh
fixtures/ops_granica/red_agent_runtime_vne_home.sh
---
ops/server/README.md
ops/server/install.sh
```
- `b2b8aaea1` (architect) трогает `fixtures/ops_granica/*` **и** `NABLIUDENIA_ARCHITECT.md`. Бриф пишет «ТОЛЬКО fixtures/ops_granica/*», и это неточно: третий файл тоже в зоне architect, строка 68. Записи А-912 и А-913 — только добавление в конец файла.
- `4c967a721` (implementer) трогает только `ops/server/install.sh` и `ops/server/README.md`, оба в зоне 69.
- `git diff --stat 96ec3a5bf 4c967a721 -- contracts/` пуст (rc=0). Текст контракта в дельте круга не тронут.

## Чек-лист гейта

1. **Область.** Соблюдена (раздел выше).
2. **Сырой вывод.** Приведён выше. Отчёты авторов я не пересказывал, все прогоны свои.
3. **Проверка не переписана под реализацию.** Implementer (`4c967a721`, 13:43) не тронул ни одного файла фикстур. Клетку и стаб architect поменял раньше (`b2b8aaea1`, 13:24) и отдельно. Подгонки нет.
4. **Красное предъявлено.** Команда 3: старый `install.sh` на новой клетке даёт rc=1 и называет все четыре носителя. s10 пойман батареей.
5. **Атомарность.** Две задачи — два коммита, у каждого ссылка на adversary 093-v4 и Р-4(а)/(б).
6. **Норма.** Нормативные документы в дельте круга не правились. Правка замороженного текста `e98f8176` — это А-908, она старше этого круга и остаётся за владельцем.
7. **Заявленное = сделанное.** «10/10» подтверждено своим подсчётом (10). «Красна только И-8б» подтверждено своим прогоном раннера. «Источник не меняется ни на байт» подтверждено своей пробой.

## Находки (reslop)

```
---
status: ready
subject: origin/wip/int-093/architect@4c967a7210e00a75985919d69402c72b7b3da529
verdict: verdicts/review/contracts-093-v5.md
---
- [x] adversary 093-v4 (ЗАКРЫТ механической приёмкой Р-4(в) п.1–4): клетка 9 rc=0 на 4c967a72; батарея 10/10 (s9, s10 пойманы); подмена install.sh@96ec3a5b → клетка 9 rc=1 по носителю (4 пути); _krasnye_093 красна только И-8б; своя rsync-проба: 0 носителей на расширенном множестве, источник неизменен
- [ ] Рв5-1 (УСЛОВИЕ ЛЕНДА, оркестратору; не новая находка — Р-4(а) п.2 арбитража, замер 5) — check_zones на 4c967a72 rc=1: 14× «FAIL коммит вне зоны: architect d9d727d0 ops/server/install.sh». Команда 5 арбитра в букве не выполнена; дельта b2b8aaea+4c967a72 добавляет 0 отказов (множество отказов 96ec3a5b == 4c967a72). Переоформление шва OPS_SERVER_AGENT_ROOT под implementer — пересборкой интеграционной ветки (прецеденты 58a9d943/4f560db4); без неё CI-шаг check_zones (registry/ci-steps.tsv:67, шард ap3) красен на ленде. Повторный прогон команды 5 после пересборки обязан дать 0 отказов по 093
- [ ] Рв5-2 (ПРОЦЕДУРНОЕ, оркестратору; не блокирует закрытие находки v4) — бриф назвал дельту d525c902..4c967a72 «четыре элемента», своя мера: 16 коммитов. v2-код (84bfbe4a, 5a089758, d9d727d0, 96ec3a5b; арбитраж, замер 2) этим кругом проверен поведенчески (все 9 клеток + батарея), но построчное содержательное ревью ревьюером по AGENTS.md:171 («один круг, перепроверяет ВСЁ») не выполнено ни этим, ни прежними кругами. Решение — оркестратору: отдельный бриф полного ревью v2-дельты до done либо явная фиксация, что поведенческой приёмки достаточно
- [ ] Рв5-3 (ИЗВЕСТНЫЙ, мелкий; текст заморожен, А-908 — не правится) — contracts/093-…:149 «7 обманных стабов», фактически 10 (своя мера: grep -c 'total=$((total+1))' → 10; s1…s10)
- [ ] Рв5-4 (СОВЕТ, implementer) — ops/server/install.sh:181 в докблоке осталось «зеркальная копия rsync -a --delete (идемпотентно)», а флаг --delete-excluded назван только строками ниже (:184). Вызов :197 верен; неточность только в прозе
- [ ] Рв5-5 (ПРЕДШЕСТВУЮЩЕЕ, не 093) — check_zones: «FAIL строка ЗОНА вне объявленной грамматики в contracts/055-…:279», строка есть и на main (9914911f0), ветка 093 её не трогает
```

## Паразитная сложность (050)

- **`--delete-excluded`** в `provision_agent_code` (`install.sh:197`). (1) И-4 и постусловие «без .env*», Р-4(а). (2) Нового состояния нет. Поведение видно по выводу, rc прежние. (3) Вместе меняются те же файлы (`install.sh` + README), число не выросло. (4) Интерфейс не изменён: ни флага CLI, ни env. (5) Потребители — клетка 9 и s10. **ESSENTIAL**: более простой формы нет, без флага клетка 9 краснеет (команда 3).
- **`carriers_under`, `src_env_unchanged`, `STALE_PATHS`, мир F `.env`** (клетка 9). (1) Р-4(б): отсутствие носителя на любой глубине, неизменность источника. (2) Состояние — только скратч `/tmp/dev-harness-verify/ops-granica-9-*`, пути печатаются в выводе. (3) Грамматика имён живёт в одном месте, `carriers_under`; при смене списка исключений меняются `install.sh` и эта функция, как и раньше. (4) Интерфейс клетки прежний (`OPS093_ROOT`), rc прежние. (5) Потребители — `_krasnye_093.sh` и s10. **ESSENTIAL**: только поиск по всем глубинам ловит `sub/.env`; список в памяти — это правило 8.
- **`OLD_PROVISION_BODY` + `replace_provision_body`** (батарея). (1) Р-4(б): стаб — тело `provision_agent_code` в редакции `96ec3a5b`; s9 перестал зависеть от текста, который implementer обязан был менять. (2) Нового состояния нет. (3) Тело — единый источник для s9 и s10. Без него было бы два дословных якоря, ломавшихся при каждой правке rsync-строки. (4) Нового интерфейса нет: внутренняя функция, rc 0/1. (5) Потребитель — `_krasnye_093.sh`. Копия старого тела живёт только здесь, это намеренный мутант. **ESSENTIAL**.
- **Стаб s10** — одна точка семьи стабов. (1) Р-4(б). Остальные ответы те же, что у s9. **ESSENTIAL**.

Находок ACCIDENTAL нет.

## Итог

accept. Находка adversary 093-v4 закрыта: команды 1–4 Р-4(в) прошли живьём, отдельная проба своей мерой подтверждает свойство на множестве шире, чем у клетки, а дельта круга чиста по зонам. Команда 5 красна только из-за `d9d727d0`. Это известный долг Р-4(а) п.2, он предшествует кругу и передан оркестратору как условие ленда (Рв5-1). После пересборки команду 5 нужно прогнать заново. Рв5-2 — процедурный вопрос оркестратору о полноте ревью v2-дельты. Рв5-3…Рв5-5 не блокируют.

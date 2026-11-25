FAIL
OBJECT=ec9324d881c1fc67cce0fa870c08a92cdcb2b32b
СУД: репо=dev-harness; предмет=074; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev074 (c907157c); модель-факт=anthropic/claude-opus-5-5 (метаданные запуска); автор ImplRunnerTmp — implementer-glm; класс=обычный

# Reviewer 074 — PR #1372 (`install.sh mob-tmpdir` + drop-in'ы TMPDIR моб-раннеров), реализация, вызов 1

Находки лежат в `.review/2026-11-25-rev074-1.md` (reslop, `status: ready`).

**БЛОКИРУЕТ: Б-1 — гонка `mkdir -p` → `chown` → `chmod` по пути (`ops/server/install.sh:635-637`) в каталоге, который принадлежит harness. Root отдаёт harness'у любой файл станции.**
- Процесс harness (агент или код PR моб-CI) подменяет только что созданный `tmp1` символьной ссылкой. После этого `chown harness:harness` и `chmod 700` уходят по ссылке на цель. Замер на честном субъекте, отдельный атакующий процесс, шимов в окне нет: `RACE: trials=30 attacker-swapped=30 victim-mode/owner-changed=30`.
- Установщик при этом говорит `установлено: mob-tmpdir` с rc 0.
- Нарушено обязательство frozen/contracts/074/2 §Предмет п.2: «harness не должен иметь права его менять» (root-часть, root:root). Нарушено и собственное обязательство кода «символьная ссылка — ОТКАЗ».
- Состояние достижимо. Родитель `/var/lib/ci-runner` — `harness:harness 750`. Юнит раннера: `User=harness`, `ReadWritePaths=/var/lib/ci-runner /tmp`. `fs.protected_symlinks` не применяется (каталог не sticky). Ставят сразу после влития, при живых раннерах.
- Простая форма с той же приёмкой: `mkdir -m 700` + `chown -h`. Гонка 0/30, мои 13 сценариев совпали с OBJECT.

**СОВЕТ: 6.**
- С-1: остаток Б1 записан неточно. Голый режим 196 краснеет навсегда в собственном мире батареи, а не «минуты до установки». Ловец — architect 196.
- С-2: README «Выключение» — restart назван до daemon-reload. После выключения verify красный навсегда.
- С-3: норма 050 ACCIDENTAL — третья копия помощника каталога, второе имя шва systemctl, состав раннеров в трёх местах.
- С-4: шов `OPS_SERVER_MOB_TMP` расходится с жёстким путём в drop-in'е.
- С-5: вопрос владельцу — постоянный TMPDIR без чистки вместо `PrivateTmp=yes`.
- С-6: частичная установка при расходящемся tmp2 (подтверждаю адверсария своим S3b).

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

## 1. Область правки, атомарность, проверки под код
- `git diff --name-status main...HEAD` (merge-base `dbcce81b7`): `M ops/server/README.md`, `M ops/server/install.sh`, `A ops/server/root/gh-runner-complior-2-tmpdir.conf`, `A ops/server/root/gh-runner-complior-tmpdir.conf`. Через `--stat`: 4 файла, +184/−1, совпадает с заявленным.
- ЗОНА implementer frozen/contracts/074/2: `ops/server/install.sh ops/server/README.md ops/server/user/orch-loop ops/server/root/ roles/orchestrator.md HANDOFF.md AGENTS.md`. Все 4 пути в зоне, вне зоны ничего.
- `git log --format='%h %an %cn %s' main..HEAD`: один коммит `ec9324d88 implementer implementer implementer 074: drop-in Environment=TMPDIR …`. Коммит атомарный, author и committer `implementer`.
- `fixtures/`, `contracts/`, нормы ролей и устав диффом не тронуты. Проверки под код не переписаны, норма молча не правилась.
- Замечание о носителе. Во frozen/contracts/074/2 нет ни TMPDIR, ни `mob-tmpdir`. Обязательства предмета — шапка `install.sh`, README и слово консультанта m2358 п.6 (задание implementer). Предмет 216 «гигиена /tmp», на который ссылается код, приостановлен словом владельца 23.11 (HANDOFF:10,12). Это вопрос маршрута у оркестратора, не блок ревьюера.

## 2. Регресс (rc / числа; своя мера)
Деревья: `mb` — merge-base `dbcce81b7`; `OBJ` — `ec9324d88`; `main` — `777a851fb`; `land` — main + 4 файла PR (`git checkout OBJECT -- ops/server`), то есть состояние после влития.

| проверка | mb | OBJ | main | land |
|---|---|---|---|---|
| `bash -n ops/server/install.sh` | rc 0 | rc 0 | — | — |
| shellcheck 0.11.0 `-S warning` | rc 1, ровно 1: SC2034 `ARTIFACTS_UNITS` (:177) | rc 1, ровно 1: SC2034 `ARTIFACTS_UNITS` (:194) | — | — |
| `red_server_obvjazka_074.sh` | rc 1 `красных клеток=1 стабы=8/8` (cell_k5b) | rc 1, идентично mb | rc 0 `красных клеток=0 стабы=8/8` | rc 0, идентично main |
| `red_ops_ci_artifacts_196.sh` (голый) | rc 0 `KLETKI=25 ZELENYE=25 KRASNYE=0` | rc 1 `ZELENYE=24 KRASNYE=1` (verify-runner-dropin) | rc 0 25/25 | rc 1 24/25 — Б1, остаток (С-1) |
| `red_ops_ci_artifacts_196.sh --stabs` (шаг CI :313) | rc 0 `OBMANOK=34 POIMANY=34 ZHIVYH=0` | rc 0 34/34 | rc 0 34/34 | rc 0 34/34 |
| `red_cikl_perezapuska_085.sh` | rc 0 `красных=0, стабы=46/46, диффпроба=33/33` | rc 0, то же | rc 0 | rc 0 |
| `red_git_config_immut_081.sh` | rc 2 NOT_IMPLEMENTED chattr (среда) | rc 2 | rc 2 | rc 2 |

Две поправки к заявленному:
- k5b красна на mb/OBJ только потому, что OBJECT основан на `dbcce81b7`. На main SNAP уже перепинен (`3203ce863`), там станция 9/9 и rc 0. После влития батарея 074 зелёная.
- `verify` в шов-мире, сравнение mb↔OBJ (`diff` stdout/stderr): строки 10 адресатов, валидаторов и ci-artifacts совпадают построчно. Добавлены только строки mob-tmpdir:
  - мир без юнитов: `+ mob-tmpdir: не применимо (юниты моб-раннеров отсутствуют)`, rc не меняется;
  - юниты есть, установки нет: `+4` строки `ОТКАЗ` (drop-in ×2 «нет файла», tmp1/tmp2) — Б1;
  - полный зелёный мир: `+ mob-tmpdir: сверка 2/2`.

## 3. Поведение в seam-мире (свои миры; швы `OPS_SERVER_ETC_DST/SBIN_DST/BIN_DST/MOB_TMP/MOB_TMP_OWNER/SYSTEMCTL/CI_ARTIFACTS/VALIDATORS_DEST`, шимы `id`/`chown`(root:root — журнал)/`systemctl`(журнал); ни одного обращения к настоящим /etc, /var/lib, systemctl)
| сценарий | OBJECT |
|---|---|
| S1 установка, 2 юнита | rc 0; tmp1/tmp2 `700 harness:harness`; drop-in'ы == источник, 644; `systemctl.log: daemon-reload;` — ровно один вызов, restart не вызван |
| S2 повтор | rc 0; chown каталогов не повторяется (в журнале только root:root drop-in'ов); verify `mob-tmpdir: сверка 2/2` |
| S5 tmp1→755 после установки | verify `ОТКАЗ: расхождение mob-tmpdir: …/ci/tmp1`, строки «сверка» нет |
| S6 порча drop-in (+1 байт) | verify `ОТКАЗ: расхождение …/gh-runner-complior-2.service.d/tmpdir.conf` |
| S6b tmp2 удалён | verify `ОТКАЗ: расхождение mob-tmpdir: …/ci/tmp2` |
| S3 существующий tmp1 755 | rc 1 `ОТКАЗ: существующий tmp-каталог расходится`; tmp1 остался 755; мир не изменён; журналы пусты |
| S3b существующий tmp2 755 | rc 1; tmp1 и drop-in 1 записаны, daemon-reload не вызван (С-6) |
| S4 tmp1 — символьная ссылка (статично) | rc 1 `ОТКАЗ: tmp-каталог — символьная ссылка`; цель не тронута |
| S7 юнитов нет | rc 0 `mob-tmpdir: юниты моб-раннеров отсутствуют — не применимо`; мир не изменён; verify `не применимо` |
| S8 euid 1000 | rc 1 `ОТКАЗ: mob-tmpdir требует euid 0`; мир не изменён; журналы chown/systemctl пусты |
| S9 юниты есть, установки нет | verify: 4 mob-строки ОТКАЗ (Б1) |
| S10 один юнит (-2) | rc 0; только tmp2; verify `сверка 1/1` |
| S11 daemon-reload rc 1 | rc 1 `ОТКАЗ: systemctl daemon-reload` |
| S12 границы записи | созданы только `ci/tmp1 ci/tmp2 etc/*.service.d/tmpdir.conf` в мире; HOME мира пуст; настоящий `/var/lib/ci-runner/tmp1` отсутствует |
| S13 cp портит drop-in при записи | rc 1 `ОТКАЗ: расхождение …/tmpdir.conf` (перечитывание sha256 работает) |
| гонка (Б-1) | 30/30 побед атакующего, rc 0 «установлено» |

Мутанты (свои; копия OBJECT, одна замена):
- M1 `chmod 700`→`755` в `mobtmp_dir`. Мои S1/S2/S5/S10 ловят: установка rc 0 с 755, повтор rc 1, verify красный. Батарея 074: `красных клеток=1 стабы=8/8` rc 1 — то же, что OBJECT, новой красной нет.
- M2 убрано `check_one` после копии drop-in'а. Мой S13 ловит: rc 0 при порче. Батарея 074 то же, что OBJECT, новой красной нет.
- Оба мутанта живы в батарее 074 — это Б2 адверсария, подтверждено своей мерой.

Заявленные агентом «smoke 53/53» я не перегонял (это его скрипты). Мои 13 сценариев, гонка и 2 мутанта выше — своя мера.

drop-in'ы: 53 байта, `[Service]\nEnvironment=TMPDIR=/var/lib/ci-runner/tmp{1,2}\n`, sha256 `d6d69577…b3ce` / `ba5e2e99…e1a7`. `systemd-analyze verify` на копии живого юнита с drop-in'ом: rc 0 для обоих. Предупреждения относятся только к посторонним юнитам станции.

Проза README сверена с живой станцией (только чтение: `systemctl cat`, `stat`). `User=harness`, `WorkingDirectory=/var/lib/ci-runner/runner{,2}`, `ReadWritePaths=/var/lib/ci-runner /tmp` — верно. У `gh-runner-back-1` `Environment=TMPDIR=/var/lib/ci-runner-back/tmp1` — верно. Сейчас TMPDIR у моб-юнитов не задан (`systemctl show -p Environment` — нет TMPDIR). Утверждение «`ci-inventar.sh` под `set -u` падает» не проверял [INFERENCE со слов консультанта m2358 п.6].

## 4. Безопасность и эксплуатация
- TOCTOU — Б-1, блок. Адверсарий назвал его остатком «узкая гонка». Своя мера показывает другое: окно `mkdir`→`chown` (fork+exec) атакующий того же uid выигрывает 30 из 30. Ограничение «при простое» относится только к рестарту, не к установке.
- Пути не берутся из ввода пользователя: только константы и швы. drop-in копируется побайтно из репо с перечитыванием sha256 (S13). За пределы перечисленных путей скрипт не пишет (S12).
- Существующие подкоманды не сломаны. `verify`: 10 адресатов + валидаторы + ci-artifacts совпадают с базой построчно. `artifacts`: голый 196 красен только клеткой verify-runner-dropin (Б1), `--stabs` 34/34.

## 5. Норма 050 — пять вопросов по каждому артефакту
- **Подкоманда `mob-tmpdir` / `install_mob_tmpdir` (`install.sh:671-701`, case `:969-975`).**
  - (1) Замороженный контракт её не требует. Требует слово m2358 п.6: «установленное == репо» для TMPDIR моба. Ручная установка без скрипта не даёт sha256-сверки.
  - (2) Состояние: tmp1/tmp2 и два drop-in'а, оно видно в stdout `установлено:`.
  - (3) При правке состава раннеров меняются 3 места в install.sh, конфиги и README — С-3(в).
  - (4) Интерфейс: +1 подкоманда, +2 env. Работа: гард, предусловия, два юнита, reload. Модуль не мелкий.
  - (5) Потребителя в приёмке и CI нет — Б2, остаток.
  - Вывод: ESSENTIAL.
- **`mobtmp_dir` (`:626-639`).**
  - (1) Каталог 700 владельца.
  - (2) Состояние — каталог, видно в отказах.
  - (3) Три копии одного шаблона (`:487-517`).
  - (4) Интерфейс узкий.
  - (5) Логика повторяет `ciart_provision_root`.
  - Вывод: ACCIDENTAL, совет С-3(а). Более простая общая форма заодно закрывает Б-1.
- **`mobtmp_install_unit` / `mobtmp_check_unit` / `verify_mob_tmpdir` (`:643-721`).**
  - (1) drop-in побайтно и условная сверка (прецедент 196).
  - (2) Состояние явное, отказ называет путь.
  - (3) Пары юнитов прописаны жёстко — С-3(в).
  - (4) Нормальные.
  - (5) Повторно используют `check_one`, `ciart_matches`, `die_write`.
  - Вывод: ESSENTIAL.
- **Env `OPS_SERVER_MOB_TMP`, `OPS_SERVER_MOB_TMP_OWNER`.**
  - (1) Тест-швы по конвенции 074 инв.6.
  - (2) Видны в путях вывода.
  - (5) Потребителя в репо нет (Б2).
  - Вывод: ESSENTIAL по конвенции. Расхождение с drop-in'ом — С-4.
- **`MOBTMP_SYSTEMCTL` (`:210`).** Повторяет `CIART_SYSTEMCTL` (`:191`) на том же шве. ACCIDENTAL, совет С-3(б).
- **Два `.conf` в `ops/server/root/`.** (1) Свой TMPDIR у каждого раннера. Более простая форма — один файл — не даёт разных tmp. ESSENTIAL.
- **Раздел README.** (1) Инвентарь, норма 074 инв.8. ESSENTIAL. Дефект порядка — С-2.

## 6. ПРОВОДКА (038)
Поле ПРОВОДКА контракта 074 диффом не тронуто. У нового механизма нет guard-канала: клетки батареи нет, CI-шага тоже. Это и есть Б2 адверсария, по слову консультанта он идёт остатком.

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` не объявляет `docs/ARCHITECTURE.md` / `docs/CODING-STANDARDS.md`: grep по `AGENTS.md` пуст, `ls` → нет таких файлов. Сверка формы сделана с прецедентом 196 в том же файле (§5).

СВЕРКА-АРХИТЕКТУРЫ: модели 188 в дереве нет (`tooling/checks/cli.js` и `bindings.json` отсутствуют), поэтому команда `finding new` недоступна и находка 188 не заводилась.
- Размещение: ops/server/{install.sh, root/, README.md}, та же форма, что у 196.
- Зависимости: новых нет.
- Писатели: install.sh — единственный писатель `<ETC>/gh-runner-complior*.service.d/tmpdir.conf` и `<MOB_TMP>/tmpN`.
- Операции: +1 подкоманда, +1 ветвь verify.
- `bindings.json`: нет.
- Долг: вырос дублем помощника (С-3).
- Уровень diff модели: не применимо.

Мобильный экран, режим проекта 996: не применимо (обвязка станции, sourceCanon не объявлен).

## Остатки
- ОСТАТОК (контракт 074 :203/:423, «полнота README сверх чек-строк; ловец — ревьюер»): К-README — **укусил**, `ops/server/README.md:227-229` (порядок выключения противоречит README:601-602), см. С-2. Прочая проза раздела `:190-232` соответствует поведению (S1–S13) и станции.
- ОСТАТОК (контракт 074 :205, ловец — владелец; :429, ловец — адверсарий): мне не адресованы.
- Б1 адверсария (голый 196 красен; `verify` rc 1 до `mob-tmpdir`) — остаток по слову консультанта m2375. **Запись неточна** (С-1). Красный голый 196 не заживает установкой на станции: красная строка — drop-in в скратче мира батареи. Ловец — architect 196.
- Б2 адверсария (у `mob-tmpdir` нет клеток батареи) — остаток по слову m2375, ловец — architect, «утром». Подтверждаю своей мерой: M1/M2 живы в батарее 074.

## Сырой вывод ключевых прогонов
```
# bash -n / shellcheck 0.11.0 -S warning (mb, затем OBJ)
bash-n rc=0
In …/wt-mb/ops/server/install.sh line 177:
^-------------^ SC2034 (warning): ARTIFACTS_UNITS appears unused. Verify use (or export if used externally).
shellcheck rc=1
bash-n rc=0
In …/m/ops/server/install.sh line 194:
^-------------^ SC2034 (warning): ARTIFACTS_UNITS appears unused. Verify use (or export if used externally).
shellcheck rc=1

# батарея 074: mb и OBJ (идентично)
k5b: станция /usr/local/sbin/orch-peak разошлась со снимком 2026-10-02
  КРАСНО: cell_k5b
честная часть: 7/7 зелёная
стаб-пак: 7/7 поймано, диффпроба: 7/7
биекция №2: честная-196 зелёная 1/1, посторонний красный 1/1
к1b-каналы: честные 6/6, ленивые пойманы 6/6
итог 074: красных клеток=1 стабы=8/8
rc=1
# батарея 074: main и land (идентично)
  станция: 9/9 побайтно совпали (живая сверка)
честная часть: 7/7 зелёная
итог 074: красных клеток=0 стабы=8/8
rc=0

# батарея 196 голая: OBJ и land
— verify-runner-dropin: KRASNO (исправная конфигурация раннеров (gh-runner-complior) названа расхождением: rc=1, stderr: ОТКАЗ: расхождение /tmp/dev-harness-verify/scratch-rev074/ops196-7t4hka_w/etc/systemd/system/gh-runner-complior.service.d/tmpdir.conf (нет файла)
ИТОГ 196: rc=1 KLETKI=25 ZELENYE=24 KRASNYE=1
# батарея 196 голая: mb и main
ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25 KRASNYE=0
# батарея 196 --stabs: все четыре дерева
ИТОГ 196: rc=0 OBMANOK=34 POIMANY=34 ZHIVYH=0

# Б-1: гонка, честный OBJECT (без шимов mkdir/chown/chmod)
trial 1: installer rc=1; victim now 700 harness:harness (was 644 harness:kvm); tmp1 -> …/race/w1/victim
  err: chown: changing ownership of '…/etc/gh-runner-complior.service.d/tmpdir.conf': Operation not permitted|ОТКАЗ: запись …   # (только root:root drop-in'а под harness; под root проходит)
RACE: trials=30 attacker-swapped=30 victim-mode/owner-changed=30
# то же с шимом только для chown root:root (rc как в production)
trial 1: installer rc=0; victim now 700 harness:harness (was 644 harness:kvm); tmp1 -> …/race/w1/victim
  out: установлено: …/gh-runner-complior.service.d/tmpdir.conf (TMPDIR=…/ci/tmp1)|установлено: mob-tmpdir (юнитов моб-раннеров: 1)|
RACE: trials=30 attacker-swapped=30 victim-mode/owner-changed=30
# простая форма (mkdir -m 700 + chown -h)
RACE: trials=30 attacker-swapped=30 victim-mode/owner-changed=0

# станция (только чтение)
/var/lib/ci-runner harness:harness 750 directory
/var/lib/ci-artifacts root:root 755
fs.protected_symlinks = 1
gh-runner-complior.service: User=harness … ReadWritePaths=/var/lib/ci-runner /tmp  PrivateTmp=yes
gh-runner-back-1: Environment=TMPDIR=/var/lib/ci-runner-back/tmp1

# verify mb→OBJ (шов-мир), diff
== world=nounits: rc base=1 obj=1
> mob-tmpdir: не применимо (юниты моб-раннеров отсутствуют)
== world=units-noinstall: rc base=1 obj=1
> ОТКАЗ: расхождение etc/gh-runner-complior.service.d/tmpdir.conf (нет файла)
> ОТКАЗ: расхождение mob-tmpdir: ci/tmp1
> ОТКАЗ: расхождение etc/gh-runner-complior-2.service.d/tmpdir.conf (нет файла)
> ОТКАЗ: расхождение mob-tmpdir: ci/tmp2
== world=full-green: rc base=1 obj=1   (rc 1 обеих сторон — пустой каталог валидаторов мира)
> mob-tmpdir: сверка 2/2
```

## Итог
FAIL по Б-1. Атакующий того же uid воспроизводимо, 30 из 30, превращает root-установку `mob-tmpdir` в `chown`/`chmod` любого файла станции в пользу harness. Простая форма (`mkdir -m 700` + `chown -h`) закрывает это и проходит те же сценарии. В остальном честная production корректна: гард, предусловия, идемпотентность, статичный отказ на ссылке и на 755, перечитывание sha256, daemon-reload без рестарта, условная verify. Б1/Б2 — остатки по слову консультанта; запись Б1 нужно исправить (С-1).

FAIL — шесть блокеров круга 2.
- Рв2-1 — И-4: orch-loop:94 отдаёт сессии GIT_SSH_COMMAND/GITHUB_TOKEN станции. Клетка 4 красна на HEAD, п.3 приёмки не пройден.
- Рв2-2 — поимка s3 пустая. После честной починки Рв2-1 батарея станет 6/7. Мёртвые якоря.
- Рв2-3 — И-7 «после завершения сессии» не реализован (сирота жив, ppid=1). Клетка 7 сужена против замороженного текста.
- Рв2-4 — 074 красных=5 против 1 на merge-base: пин orch-loop устарел. В PR CI это скрыто fail-fast l4.
- Рв2-5 — verify-start/rollback по умолчанию бьют в orch-peak@0 (`orch-peak 0` → rc 2), а это oneshot, is-active=inactive. Шим systemctl моделирует не тот юнит.
- Рв2-6 — orchagent не проходит в /home/harness (drwxr-x---): сессия не может стартовать, п.9 непроходим.

Из 10 блокеров круга 1 закрыто 6 (Р1-1, Р1-2, Р1-4, Р1-7, Р1-9, Р1-10). Частично закрыты 4 (Р1-3, Р1-5, Р1-6, Р1-8); их остатки — Рв2-1…Рв2-4.

# Review 093, круг 2

**Находки (reslop):** `.review/2026-10-12-01.md`. Блокирующих 6 (Рв2-1…Рв2-6), неблокирующих 14 (Н2-1…Н2-12, переносы Н1-7, Н1-8). Статус Р1-1…Р1-10 — там же, поштучно.

**Предмет.** Контракт 093, `frozen/contracts/093/1` (tag `0afd9335` → `c89e31b4`). Субъект — `origin/wip/int-093/architect` @ `34c6aa6e6b31df97f87dd6662ac0a950b0e94233` (PR#83, `headRefOid` совпадает).
`git diff frozen/contracts/093/1 HEAD -- contracts/093-…md | wc -c` → `0`.

**Сборка.** Одноразовый SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/reviewer093r2-7ac9f59e/repo`, `checkout -b rv origin/wip/int-093/architect`.
Merge-base с origin/main — `2f232d7c`; origin/main — `2b592b6f`. Для сравнения — worktree origin/main/2f232d7c в `…/main`. Прогоны под uid=1004(harness).

## Сырой вывод (мои прогоны)

`reslop t -- bash fixtures/_krasnye_093.sh` → `exit: 1`. Ровно 2 красные: клетка 4 и клетка 8, батарея 7/7:

```
s1 фолбэк-без-потолка: ПОЙМАН (rc=1) … s7 uid-не-переключается: ПОЙМАН (rc=1)
ЗЕЛЁНО(093-bat): 7/7 обманных стабов пойманы            — battery_stubs.sh: rc=0
ЗЕЛЁНО(093-1) … — red_root_bootstrap_iz_repo.sh: rc=0
ЗЕЛЁНО(093-2) … — red_limit_otkaz_bez_zapuska.sh: rc=0
ЗЕЛЁНО(093-3) … — red_agent_uid_stancija_nedostupna.sh: rc=0
КРАСНО: publication-креденшл в среде сессии (agent_env, И-4, Н-196 жив): GIT_SSH_COMMAND=ssh -i …/home/.ssh/github-rw-cwd GITHUB_TOKEN=ghp-toy-station
                                                         — red_kredit_publikacii_vne_sredy.sh: rc=1
ЗЕЛЁНО(093-5) … — red_unit_realno_startuet.sh: rc=0
ЗЕЛЁНО(093-6) … — red_otkat_vozvrashhaet_rabochuju.sh: rc=0
ЗЕЛЁНО(093-7) … (И-7; субъект rc=3) — red_net_osirotevshih_detej.sh: rc=0
раннер запущен под uid владельца станции: граница не установлена снаружи (И-8б, арбитраж 093) — red_germetichnost_semi.sh: rc=1
ИТОГ 093: rc=1
```

Клетка 8 красна по букве контракта: п.1 называет этот отказ на HEAD, зеленеет она только через п.9. Клетка 4 — нет, это Рв2-1.

Дореализационный субъект и мутанты HEAD (`probes/pre_and_mut.sh`; `ops/server` взят из `c89e31b4`, мутации точечные, якорь проверен):

```
PRE red_root_bootstrap_iz_repo rc=1 · red_limit_otkaz_bez_zapuska rc=1 · red_agent_uid_stancija_nedostupna rc=1
PRE red_kredit_publikacii_vne_sredy rc=1 (ws_env) · red_unit_realno_startuet rc=1 «подкоманды проверки старта нет»
PRE red_otkat_vozvrashhaet_rabochuju rc=1 «подкоманды отката нет» · red_net_osirotevshih_detej rc=1
M1  exec sudo -nu "$3" "$4" → exec "$4"            → клетка 3 rc=1 «МИМО двери uid»
M1b AGENT_USER="$(id -un)"                          → клетка 3 rc=1 «дверь uid вызвана на владельца станции harness»
M2  export GIT_SSH_KEY_FILE=$HOME/.ssh/github-rw-cwd → клетка 4 rc=1 (неразличимо: HEAD сам красен)
M3  exec env -u GIT_SSH_COMMAND -u GITHUB_TOKEN -u GH_TOKEN -u GIT_SSH_KEY_FILE sudo -nu … → клетка 4 rc=0 ЗЕЛЁНО(093-4)
M3b env чист, sudo вырезан                           → клетка 4 rc=1 «без двери uid»
M4  verify-start: state=active                        → клетка 5 rc=1
M5  rollback без daemon-reload                         → клетка 6 rc=1
M6  rollback без restart                               → клетка 6 rc=1 «юнит не активен после отката … failed»
M7  root не кладёт снимок                              → клетка 6 rc=1 «нет каталога предыдущей версии»
M8  rollback не копирует юниты                         → клетка 6 rc=1 «расхождение …/orch-peak@.service»
M3+s3 (экспорт до двери, как battery_stubs.sh:96-106) → клетка 4 rc=0 — s3 НЕ пойман на честной базе (Рв2-2)
```

Перезапуск по маркеру, когда родитель — sudo (`probes/watch_sudo.sh`; шим sudo форкает ребёнка, остаётся родителем и пересылает TERM):

```
[HEAD]    session omp … dead 4s after marker · grandchild … dead · mark.go present
          сессия #1: перезапуск по маркеру (6с) → сессия #2: старт
[R1-47a]  45s after marker: session omp … STILL ALIVE · grandchild … STILL ALIVE
```

Сессия завершается сама (`probes/natural_exit.sh`; стаб-сессия форкает `toy-orphan-sleeper` и выходит):

```
[HEAD-rc0] orphan … ALIVE after loop exit (ppid=1, cmd=toy-orphan-sleeper 600) · alive_orphans=1 · «завершилась без маркера (rc=0) — цикл остановлен»
[HEAD-rc1] orphan … ALIVE after loop exit (ppid=1 …) · alive_orphans=1 · «упала без маркера (rc=1) 1 раз подряд — цикл остановлен»
```

Откат своей мерой, все 9 адресатов root-части (`probes/rb.sh`):

```
install v1 rc=0 · pin v1 = 8e18719c0ef598a4 · install v2 rc=0 · pin v2 = dec618d594bc749a
rollback rc=0 · после отката = 8e18719c0ef598a4 == v1 · systemctl: daemon-reload;restart toy@x;is-active toy@x;
повтор: install v2 rc=0 · install v2 (повтор) rc=0 · rollback rc=0 · после отката = dec618d594bc749a == v2 (v1 потерян)
```

Реальный юнит на станции (только чтение):

```
$ bash ops/server/root/orch-peak 0   (ORCH_STATE/LOG/UHOME/REPO → /tmp)
использование: orch-peak warn|stop|start|check|ctx · rc=2
$ systemctl show orch-peak@ctx  → Type=oneshot RemainAfterExit=no Result=success ExecMainStatus=0 ExecMainExitTimestamp=Mon 2026-10-12 08:45:02 UTC ActiveState=inactive
$ systemctl show orch-peak@0    → Type=oneshot … ExecMainExitTimestamp= (не исполнялся) ActiveState=inactive
$ stat /home/harness → drwxr-x--- harness · command -v omp → /home/harness/.local/bin/omp
```

Регрессионные границы:

| прогон | HEAD 34c6aa6e | merge-base 2f232d7c |
|---|---|---|
| `bash fixtures/_krasnye_074.sh` | rc=1, красных=5 (k1, k5, k5b, диффпроба k1 ×2), стабы 7/7 | rc=1, красных=1 (k5b — станция) |
| `IMMU_MOCK=1 bash fixtures/ops_server/red_git_config_immut_081.sh` | rc=0, 30/0 | — (круг 1: 30/0) |
| `bash fixtures/ops_server/red_cikl_perezapuska_085.sh` | rc=0, красных=0, стабы 39/39, диффпроба 31/31 | — |
| `bash fixtures/_krasnye_090.sh` | rc=1 — только `red_hermetic_no_real_sessions` (живые журналы станции) | rc=1, то же |
| `bash scripts/check_protected.sh` (полный режим) | rc=1, 3 FAIL (263-klass-v1, 263-v1, 266-…-v1) | rc=1, те же 3 FAIL; на 2b592b6f — 4 (+ critic/contracts-094-v4.md) |
| `reslop t -- bash scripts/check_zones.sh` | `exit: 0` — «замороженных контрактов: 90 · объявленных авторов: 2 · коммитов в диапазонах: 9088 · проверено по зонам: 2669» | — |

### Трассировка CI оркестратора — сверена живьём

PR#83 (`gh pr view 83`, head `34c6aa6e`): красные ap2, l4, l7, остальные 9 зелёные. Совпадает.

**ap2:** 12 FAIL (`check_skills/case_*: нет положительного контроля`). Набор совпадает построчно с main @2f232d7c: sha отсортированных FAIL-строк `26333dbe68ba` в job 114720739912 (PR) и 114700753341 (main).

**l7:** 2 FAIL (`contracts/094…`, `contracts/095…` изменены без новой заморозки), sha `155cef8fec16` в PR и в main.

ap2 и l7 — пре-существующий долг main. Утверждение подтверждено.

**l4 — НЕ подмножество CI-красного main.**
- В CI main l4 **зелёный**: run 38215970983 @2f232d7c и run 38224195933 @2b592b6f, оба `success ci (l4 …)`.
- Довод оркестратора («`check_protected.sh` в полном режиме даёт rc 1 на голом main») я воспроизвёл: те же 3 FAIL. Пре-существующий долг верен.
- Но lane fail-fast (`scripts/run_ci_lane.sh:62-64`): в PR l4 остановилась на `check:protected`, и ключ `check:ops-server-family-selftest` (= `_krasnye_074.sh`) не исполнялся.
- На HEAD он красен собственной регрессией 093 (k1/k5, Рв2-4). k5b в CI пропускается (`red_server_obvjazka_074.sh:478-481`), k1/k5 — нет.

Вывод «красное PR = только долг main» для l4 ложен по существу (Н2-1).

**Счёт оркестратора:**
- «90 замороженных, 2669, 0 breach»: моя мера — «замороженных контрактов: 90», «проверено по зонам: 2669», exit 0. «2669» — это проверенные по зонам, а не коммиты: коммитов в диапазонах 9088.
- «РОВНО 2 честных красных, 7/7 стабов»: счёт верен, но «честная» клетка 4 — это непройденный п.3 приёмки, а s3 из 7/7 пойман пусто (Рв2-1, Рв2-2).

## Семь проверок

1. **Область правки.**
   - Implementer `5a68df87`: только `ops/server/{README.md,install.sh,user/orch-loop}` и удаление `root/systemd/orch-agent@.service` — в ЗОНЕ.
   - Architect `ea265755`: `fixtures/ops_granica/*`, `fixtures/_krasnye_093.sh`, `NABLIUDENIA_ARCHITECT.md` — в ЗОНЕ.
   - `4f560db4`/`58a9d943` — merge оркестратора.
   - `34c6aa6e` — одна строка `NABLIUDENIA_ARCHITECT.md` под `architect398fix` (Н2-9).

   `check_zones` exit 0. Превышения нет.
2. **Сырой вывод.** Всё выше — мои прогоны в моём клоне, с кодами возврата. Доклады автора и оркестратора сверены, на веру не взяты.
3. **Проверку не переписали под реализацию?**
   - Implementer фикстур не касался (`git log 47a3126b..HEAD -- fixtures/`: только architect).
   - Architect `ea265755` писался параллельно `5a68df87`, от той же базы `47a3126b`. Якоря s3/s6 подстроены под текст implementer (по Н-39 это допустимо: стабы строятся из субъекта).
   - Клетка 7 сузила замороженный вход ровно до пути, который есть в коде: форка sleeper от стаб-omp и завершения сессии нет (Рв2-3). Клетка 5 выбросила вход «install root» (Рв2-5). Сужение под код — блокер внутри Рв2-3 и Рв2-5.
4. **Красное предъявлено?**
   - Для всех 7 клеток на дореализационном субъекте — да, rc 1 у каждой.
   - Клетки 3, 5, 6 — плюс красное на точечных мутантах.
   - Клетка 4 красна и на HEAD; различимость показана через M3/M3b.
   - Батарея: s3 — пустая поимка (Рв2-2).
5. **Атомарность.** Коммиты ссылаются на предмет и находки. `5a68df87` и `ea265755` связывают несколько находок, но это одно маршрутизированное задание на автора, тело разбито по находкам. Не отказ (Н2-10).
6. **Норма не тронута молча.** `contracts/093-…` — diff 0 байт против заморозки. `roles/`, `AGENTS.md` в диффе ветки против merge-base не тронуты (`git diff --stat origin/main...HEAD` — 19 путей, ни одного нормативного). `NABLIUDENIA_ARCHITECT.md` — журнал.
7. **Заявленное = сделанное.**
   - Клеток 8: моя мера (glob `fixtures/ops_granica/red_*.sh`) дала 8.
   - Стабов 7: пойманы 7, но один пусто.
   - `5a68df87` заявляет «081 IMMU_MOCK 30/0»: подтверждено. «074: 5 красных … вне зоны implementer»: подтверждено, но не закрыто никем.
   - `ea265755` заявляет «клетка 4 красна (креденшл в среде сессии — предмет субъекта)»: подтверждено, и это блокер.
   - Шапка раннера (`_krasnye_093.sh:21-27`) заявляет, что клетки 4/6/7 красны только «на дереве ДО implementer»: клетка 4 красна и после.
   - Шапка батареи (`:3-4`, «якорь не найден → клетка не засчитывается») расходится с кодом `verdict` (Рв2-2).
   - README «Проверка старта» (`ops/server/README.md:285`, «установлено и активно: orch-peak@0»): на станции недостижимо (Рв2-5).

## ПРОВОДКА (038)

`ПРОВОДКА: guard=fixtures/_krasnye_093.sh` — файл есть, это раннер именно этой семьи, барьер своего предмета.
Обоснование ПРОВОДКА-ЭНФОРСМЕНТ честное: граница станционная, норма не поведенческая, 029-класса нет. CI-шаг по контракту ставится после landing. Сейчас его нет — верно.
Guard на HEAD красен двумя клетками:
- клетка 8 — законно до п.9 и до второго uid в CI;
- клетка 4 — дефект субъекта.

Зелёным guard подключить нельзя, пока не закрыт Рв2-1. Клетка 8 в CI требует `sudo useradd` + `sudo -u` — это строка ПРОВОДКА-ЭНФОРСМЕНТ, задача implementer при подключении.

## Паразитная сложность (050) — артефакты дельты круга 2

Ответы на пять вопросов, (1)…(5):

- **Снимок в `install.sh root` (`:175-192`: `prev`, `SNAP`, `snap_cp`).**
  (1) И-6b. (2) Каталог `.rollback` виден в выводе (`снимок предыдущей версии: …`) и в шве `OPS_SERVER_ROLLBACK_BACKUP`. (3) Вместе меняются root-ветка, rollback и README — те же 3, что в круге 1. (4) Нормальный. (5) Клетка 6, п.6.
  ESSENTIAL. Семантика затирания — Н2-2.
- **`rollback` (`:328-406`).**
  (1) И-6b, п.6. (2) Состояния не вводит. (3) 1 файл. (4) Побайтная самопроверка после `cp` почти тавтологична, но дешёвая. (5) Клетка 6.
  ESSENTIAL. Выбор юнита — Рв2-5.
- **Гейт провизионинга по швам (`:290-296`).**
  (1) Свойства не называет: это обход регрессии 081. (2) Режим включается неявно, по наличию `OPS_SERVER_SBIN_DST/ETC_DST`. (3) Вместе меняются install, клетка 6 и батарея 081. (4) Мелкий. (5) Потребителя нет, `provision_orchagent` не исполняет ни одна клетка.
  ACCIDENTAL, совет (Н2-3). Простая форма — провизионинг на своих существующих швах `OPS_SERVER_AGENT_*`/`SUDOERS_DROP`. Она проходит ли 081 I2, не мерил, поэтому третьей части для блока нет.
- **orch-loop `kill_tree`/`tree_quiet` + KILL через `sudo -nu` (`:35-73`).**
  (1) Семантика цикла 085 при родителе-sudo (Р1-7). (2) Состояния нет. (3) orch-loop + батарея 085. (4) Нормальный. (5) Клетка 7, батарея 085.
  ESSENTIAL. Остаток `pkill` под оракул — Н2-6.
- **`AGENT_CMD`, одна форма (`:93-95`).**
  (1) И-3. (2) Шов виден в env. (3) 1 файл. (4) `ORCH_LOOP_AGENT_CMD` дублирует `ORCH_WORKSHOP` (Н2-7). (5) Клетки 3/4.
  ESSENTIAL. Дубль шва — совет.
- **Семья `fixtures/ops_granica/` (клетки 3–7 + батарея), одним артефактом.**
  (1) Клетки контракта. (2) Миры в `/tmp/dev-harness-verify/ops-granica-*`, вычищаются. (3) Клетка, стаб и якорь в субъекте: при правке двери меняются 3 файла, как и в круге 1. (4) Нормальный. (5) Guard ПРОВОДКА.
  ESSENTIAL. Двуформенные якоря s3/s6 — ACCIDENTAL, блокирует в составе Рв2-2 (фрагмент, отсутствующее свойство и простая форма названы там же).
- **README «Пользователь агента / Проверка старта / Откат».**
  (1) ПЕРЕСЕЧЕНИЕ README. (2)–(4) —. (5) —.
  ESSENTIAL. `orch-peak@0` в примерах — Рв2-5.

## Маршрут починки (норма 050)

- **implementer:**
  - Рв2-1 — снять публикационную среду у двери, `orch-loop:94`;
  - Рв2-3 (код) — зачистка cgroup/дерева после возврата сессии, не только по маркеру;
  - Рв2-5 (код) — юнит по умолчанию и семантика «стартует» для oneshot.
- **architect:**
  - Рв2-2 — s3 портит дверь, а не среду до неё; мёртвые якоря; шапка против `verdict`;
  - Рв2-3 (клетка 7 по замороженному входу: форк от стаб-omp + завершение сессии);
  - Рв2-4 — пин 074 `user/orch-loop` по стоячей санкции №4, после правок Рв2-1/Рв2-3;
  - Рв2-5 — шим systemctl моделирует oneshot, клетка 5 со входом «install root».
- **Вопросы владельцу/architect:**
  - Рв2-6 — где живёт рабочее дерево агента вне `/home/harness`;
  - Рв2-5 — буква п.9 «`systemctl start orch-peak@0` → active»;
  - Н2-5, Н1-7.
- **Оркестратору:** Н2-1 (l4 — не долг main в CI), Н2-9 (ролевое имя автора), Н2-11 (чекбоксы `.review/2026-10-11-08.md`).

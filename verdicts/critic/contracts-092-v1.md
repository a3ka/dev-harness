accept

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md — заморозка v1 поверх финального FAIL критика круга 5 (verdicts/critic/contracts-092-v1.md): находка «ошибка close() после os.replace (EFBIG) не различается батареей» принята остаточным риском; реализация обязана закрывать и сбрасывать файл до rename и возвращать rc≠0 при любой ошибке записи; слово владельца 2026-10-09.

Правка вердикта судьи (правило 14 устава) исполнена РЕШЕНИЕМ ВЛАДЕЛЬЦА, цитированным
дословно строкой выше, коммит identity `orchestrator` по его прямому слову.
Критик (круг 5) не пересматривал свою находку — находка остаётся ВЕРНОЙ и
сохранена НИЖЕ целиком для аудита; владелец принял её остаточным риском, а не
критик её снял. Строка `accept` относится к допуску заморозки v1 поверх этого
FAIL, не к утверждению, что находка неверна.

---

## Оригинальный вердикт критика (круг 5, финальный, FAIL — сохранён целиком для аудита)

K ВЛАДЕЛЬЦУ

# Контракт 092 — круг 5, финальный

Предмет: `contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md` и предъявленная до заморозки батарея на HEAD `35c53bb63a876b222770223476e811d6e05bee05`. Суд не касается отсутствующей реализации scripts/. Клон: `/tmp/dev-harness-verify/critic092r5-c84e19/repo`, ветка `wip/092/architect`; push не выполнялся.

Арбитраж `verdicts/arbitration/092-kap-krugov-checkpoint-atomarnost.md` прочитан целиком из main (`git show FETCH_HEAD:verdicts/arbitration/092-kap-krugov-checkpoint-atomarnost.md` после `git fetch origin main`). Его решение о допустимости круга не пересуживается. По §В5 и первой строке решения любой FAIL этого круга направляется ВЛАДЕЛЬЦУ: не круг 6 и не повторный арбитраж.

## Полнота набора

Предмет закоммичен; предмет, критерий с rc-командами, исполнители architect/implementer и ЗОНА-строки присутствуют (:27–42, :79–80, :99–114). Набор достаточен для разбора. Отсутствие 092 в registry/plan.tsv — отдельный заведённый вопрос воли владельца, не основание этого FAIL.

## Единственная блокирующая находка

БЛОКИРУЕТ contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md:154 — исполнимый критерий атомарности по-прежнему слабее И-1 (:67): три входа клетки 10 не различают подготовленное открытие журнала и успешную запись/закрытие журнала. Честное тело проходит всю диффпробу, но при обычном позднем отказе записи теряет прежнее состояние.
ОБХОД: взять НЕИЗМЕНЁННОЕ честное тело `fixtures/orch_state/battery_stubs.sh` с этого HEAD (оно зелено на 19/19 клетках), обычные state.tsv/events.tsv с конформной грамматикой, task=732, журнал длиной 452 байта. Выполнить `init arbiter-atomic-probe -` с лимитом размера файла RLIMIT_FSIZE=452 и игнорируемым SIGXFSZ. Новый state меньше лимита; открытие журнала успешно; буферизованный append обнаруживает EFBIG на close. Субъект возвращает rc 1, но state.tsv уже заменён и `get task` возвращает `arbiter-atomic-probe`; events.tsv остался прежним. Батарея принимает такое тело, хотя требуемое «отказ любого шага → оба файла байт-в-байт прежние» не выполнено.

Это ЖИВОЕ предъявление на честном теле, не предложенный мутант и не гипотеза. Лимит касается только дочернего процесса пробы; файлы обычные, записываемые, без symlink, без конкурентного писателя и без краха станции. Полученный EFBIG — отказ записи одного процесса, не исключённый моделью угроз (:132–135). Отсутствие fsync к этой пробе отношения не имеет: провалился обычный close, не сохранение после краха.

Порядок, объясняющий замер: `fixtures/orch_state/battery_stubs.sh:193–195` — `fh.write(line)`, затем `os.replace(tmp, STATE)`, затем `fh.close()`. Ошибка на последнем шаге не откатывает rename и печатает traceback вместо именованного отказа. Находка не требует судить будущую реализацию: уже предъявленный автором положительный образец доказывает недостаточность критерия.

Живой вывод новой пробы:

```text
RLIMIT_FSIZE=452; state size=100; journal size=452
checkpoint init arbiter-atomic-probe - => rc=1
stdout=''
... composite_write ... fh.close()
OSError: [Errno 27] File too large
state.tsv: before=f2d04c9302f8f9f9402604a74b8d7389822c392ada9e438179c0149784dfa9fb after=b7f3ace2f236123016d5aa6caee71c85abf5393cdd095d1d76365cc10c8e0c52 equal=False
events.tsv: before=1593fcf918a3bf738323afd31dfe6923d25ab4cb5422938643a016af5e462aed after=1593fcf918a3bf738323afd31dfe6923d25ab4cb5422938643a016af5e462aed equal=True
checkpoint get task => rc=0
stdout='arbiter-atomic-probe\n'
stderr=''
BYPASS REPRODUCED: rc=1 but old state replaced; journal unchanged; no named refusal
```

Команда живого предъявления: `bash /tmp/dev-harness-verify/critic092r5-c84e19/run-probes.sh` → rc 1 (в конце намеренно сигнализирует воспроизведённое нарушение). Она сначала запускает исходный стаб-пак, затем независимые пробы арбитра, затем поздний отказ. Честное тело породил сам стаб-пак: `/tmp/dev-harness-verify/critic092r5-c84e19/orchstate092.TdIA89/body_chestnoj.py`. Скрипт проб: `/tmp/dev-harness-verify/critic092r5-c84e19/probe092.py`.

Для воспроизведения после удаления scratch достаточно следующего описания входа: семь строк state — `task=732`, `stage=implement`, `candidate=-`, `last_proven=-`, `waiting=none`, `next_step=continue`, `pub_state=pushed` в порядке И-2, разделитель TAB, каждая строка с LF; events — четыре строки `2030-01-02T03:04:00Z<TAB>stage<TAB>732<TAB><i><80 букв x><LF>` для i=0,1,2,3. Породить честную обёртку исходным battery_stubs.sh, передать ORCH_STATE_DIR на этот каталог и ORCH_REPO на toy git-репозиторий. Python `subprocess.run(['bash', checkpoint, 'init', 'arbiter-atomic-probe', '-'], preexec_fn=quota, capture_output=True)` с `quota(): signal.signal(signal.SIGXFSZ, signal.SIG_IGN); resource.setrlimit(resource.RLIMIT_FSIZE, (452, 452))` воспроизводит приведённый отказ. Ожидаемые байты обоих файлов снять в память ДО вызова.

## Обязательные проверки §В4/В5 арбитража

1. Текст И-1 :67 и И-8 :74 содержит предписанные арбитром формулировки; клетка 10 :154 получила входы б/в, клетка 15 :159 — четыре входа; S16/S17 описаны, привязка находится в кодовой PAK-таблице. Формальная правка выполнена. Однако свойство И-1 в полном объёме не доказано — см. живой обход выше.
2. Замер 1 повторён независимо: `chmod a-w events.tsv`, затем init → rc 1, stderr `запись состояния не удалась`; оба sha256 прежние, `get task` → 732, rc 0.
3. Замер 1б: `.state.tsv.tmp` занят непустым каталогом, затем pub-done → rc 1, тот же именованный отказ; оба sha256 прежние.
4. Замер 1в: препятствие снято, повтор pub-done → rc 0 без `уже записано`; `get pub_state` → published. Последующий pub-start того же ключа → rc 1 `уже опубликовано: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`. Прежнее застревание именно этого сценария устранено.
5. Замер 2: candidate=-, remote ref отсутствует, журнал пуст → put published rc 1 `публикация не доказана: -`; оба файла неизменны.
6. Замер 2б: candidate=`7270b2373775b1210601e93d1e14e7528ce0c82b`, локальный `merge-base --is-ancestor` → rc 1, журнал пуст → put published rc 1 `публикация не доказана: 7270b2373775b1210601e93d1e14e7528ce0c82b`; оба файла неизменны.
7. Обе зелёные пары проверены отдельно: достижимый кандидат без pub-done; недостижимый кандидат с pub-done того же task/candidate. В обоих случаях put → rc 0, get → published.
8. S16 пойман red_checkpoint_atomic_fail.sh, S17 пойман red_pub_state_needs_proof.sh; весь стаб-пак 17/17, диффпроба 19/19, rc 0.
9. Советы :104/:118 исправлены: `run_battery.sh`; `ci_wait.sh --sha <sha>`; `event round-fail <предмет> <путь>@<blob>`.
10. Закрытые причины круга 2 не регрессировали: клетка 14 зелена на честном теле, S15 пойман; check_threat_model.sh → rc 0; pre_critic.sh → rc 0, Н-39 не обнаружена. Привязка S16/S17 также живёт в PAK, не в утверждении контракта о результатах клеток.

## Остальные вопросы роли

- Вопрос 1 (критерий слабее предмета): единственный блокер выше, предъявлен прогоном согласно §В5.
- Вопрос 2 (доказуемость командами): rc-команды названы :102–105, живые пробы включены в приёмку :107–114. Отсутствующую реализацию не выдаю за проверенную.
- Вопрос 3 (решение молча оставлено исполнителю): отдельной блокирующей находки нет; новая проба относится к уже объявленному свойству И-1, а не к навязыванию исполнителю формы реализации.
- Вопрос 4 (границы): architect/implementer названы :79–80, пересечения оформлены, роль-канал явно передан владельцу roles/orchestrator.md :92; механизмы зон/проводки названы. Дополнительного блокера нет.
- Вопрос 5 (AGENTS.md): отдельного противоречия норме не предъявлено. Маршрут после FAIL — владелец; арбитр повторно не созывается.

## Вывод исполненных команд

Рабочий каталог всех репозиторных команд — названный клон.

```text
bash scripts/check_precision_gate.sh . contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md
OK
rc=0

bash scripts/check_spec_ready.sh . contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md
OK
rc=0

bash scripts/pre_critic.sh contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md
КРИТИК: дверь зелёная
rc=0

bash scripts/check_threat_model.sh . contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 3 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))
rc=0

bash fixtures/orch_state/battery_stubs.sh .
диффпроба: честный мини-субъект зелён на всех 19 клетках семьи (rc=0)
S1 → red_net_off_local_survives.sh: поймано
S2 → red_net_off_local_survives.sh: поймано
S3 → red_pub_vs_close.sh: поймано
S4 → red_status_derives_not_echo.sh: поймано
S5 → red_ciwait_no_repoll.sh: поймано
S6 → red_restart_no_dup_task.sh: поймано
S7 → red_restart_no_dup_round.sh: поймано
S8 → red_restart_no_dup_publish.sh: поймано
S9 → red_three_fails_three_rounds.sh,red_rounds_count_events_not_files.sh: поймано
S10 → red_three_fails_three_rounds.sh: поймано
S11 → red_three_fails_three_rounds.sh: поймано
S12 → red_checkpoint_atomic_fail.sh: поймано
S13 → red_checkpoint_grammar.sh: поймано
S14 → red_state_outside_tree.sh: поймано
S15 → red_ciwait_net_vs_timeout.sh: поймано
S16 → red_checkpoint_atomic_fail.sh: поймано
S17 → red_pub_state_needs_proof.sh: поймано
стаб-пак 092: 17/17 поймано, диффпроба 19/19
rc=0

find fixtures/orch_state -maxdepth 1 -type f -name 'red_*.sh' -printf '%f\n' | wc -l
15
rc=0
```

`bash fixtures/_krasnye_092.sh .` повторил дословно весь приведённый вывод стаб-пака (17/17, 19/19), затем:

```text
красная: предмет отсутствует
КРАСНОЕ 092: нет scripts/orch_checkpoint.sh scripts/orch_status.sh scripts/ci_wait.sh (корень /tmp/dev-harness-verify/critic092r5-c84e19/repo)
rc=1
```

Это именно наблюдаемый именованный красный выход, НЕ строка NOT_IMPLEMENTED. scripts/ пока не раздавались; само их отсутствие не блокирует этот текстовый круг и не является новой находкой.

Первый запуск precision/pre_critic на single-branch-клоне до загрузки origin/main дал соответственно `precision-гейт 043: реестр заморозок не читается: missing-remote` (rc 1) и `ОТКАЗ: precision-gate красен: contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md` (rc 1). После `git fetch origin main:refs/remotes/origin/main --tags` обе команды дали приведённый rc 0. Это устранённая неполнота окружения клона, не дефект предмета.

Новых советов не добавляю. Единственный FAIL — живой обход атомарности; все обязательные проверки выполнены, результаты закрытых сценариев сохранены выше. Заморозка запрещена (этой записью, без санкции владельца). Дальнейшее решение — только владельцу.

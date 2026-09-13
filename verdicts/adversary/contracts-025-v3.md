FAIL

# Адверсарийский вердикт — контракт 025, круг 3

Судимая база: `0f7e056c1741f51d650899bc8aad32528c6cfb64`. Все атаки и живые прогоны выполнялись в одноразовом клоне `/tmp/dev-harness-verify/adv025k3.GR1ASL/clone`; основной checkout не изменялся. Этот вердикт не меняет норму.

## Блокер B-025-r3-1 — И-6 принимает осиротевшие события как честную улику

Парсер `fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse` fail-closed обрабатывает дубликаты `toolCallId`, но не проверяет полноту двустороннего join:

* `load()` добавляет каждый `toolResult` в `results`, даже когда `toolCallId` отсутствует в `calls`;
* `load()` не ведёт множество вызовов, получивших ровно один результат, поэтому `toolCall` без `toolResult` тоже не замечается.

Построена честная минимальная улика MAIN+CHILD: все канонические write-вентили несут именованный Н-85, `false | true` имеет `exitCode=1`, `yes | head -1` — успех, child checkout блокирован, scratch жив. Её положительный контроль дал rc 0. Затем к НЕЙ добавлялось ровно одно противоречивое событие:

```text
$ python3 orphan-probe.py <evidence> orphan-result
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse <evidence>
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0                         # ожидался rc 2 «исход не снят»

$ python3 orphan-probe.py <evidence> orphan-call
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse <evidence>
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0                         # ожидался rc 2 «исход не снят»
```

Это не отсутствие шага: первая форма добавляет `toolResult(toolCallId=no-call)` без вызова, вторая — `toolCall(id=no-result)` без результата. Обе противоречат требованию сопоставлять сырые toolCall/toolResult по идентификатору; их молчаливое игнорирование позволяет подмешать либо скрыть свидетельство, сохранив зелёный вердикт. Требуемый пользователем оракул для orphan `toolResult`/`toolCall` не подтверждён: он пробит.

Для контроля уже имеющихся ветвей `red_zond_dubl_toolcallid.sh` после подготовки `/tmp/dev-harness-verify/025` дал ровно: duplicated result rc 2, duplicated call rc 2, однозначная leak rc 1, честная улика rc 0. Значит дефект именно в неполноте join, а не в постоянно-красном парсере.

## Повтор класса: форма записи, экземпляр 3

Кандидаты, не входившие в фикс кругов 1–2, воспроизведены как judge-вызов и реальная команда в scratch-каталоге. Следующие живые записи прошли `path-guard` с `{"decision":"pass"}` при относительном операнде без cwd и действительно изменили `target.txt`:

```text
lua -e 'local f=io.open("target.txt","w");f:write("X");f:close()'
awk 'BEGIN { print "X" > "target.txt" }'
bash -c 'printf X > target.txt'
printf X | xargs -I@ sh -c 'printf @ > target.txt'
```

Это ТРЕТИЙ экземпляр уже дважды засчитанного класса «форма записи, не покрытая `isWriteCommand`/deny-слоем». В соответствии с капом не предлагаю новый цикл расширения детектора.

Переисполнение закрытий r2: judge блокировал `perl -pi`, `perl -pi.bak`, `perl -pie`, `ruby -e`, `node -e`, `php -r`, `sed …w`; реально доступные perl/node/sed формы писали файл только без стража. В данном окружении `ruby`/`php` отсутствовали (rc 127), а некорректная форма `perl -pie -e` завершилась rc 2 и файла не изменила — все три отвечают требованию «block либо физически не пишет». Из дополнительных форм `dd of=`, `tee -a`, heredoc и `;`/`&&`/`||`-композиции блокированы; `tclsh` отсутствует (rc 127).

## Дыра B и прочие носители

Непиннованный judge проверен на `mcp://`, `local://`, `skill://`, `agent://`, `history://`, `xd://` и свободном `/var/tmp/free`: каждый блок Н-85; `artifact://` единственный pass. Следовательно, буквальная null-граница «скратч ∪ artifact» не пробита. `mcp://` блокируется как относительный путь, остальные перечисленные URI — именованной URI-ветвью.

## §B-1: носитель в замороженном тексте устарел — пункт припаркован

§B-1 буквально объявляет носителем `process.env.PI_SHELL_PREFIX`, который оборачивает каждую bash-команду. На текущем механизме это мёртвый носитель: **§B-1 стал сталым текстом, носитель сменился на tool_result-патч 2c30d54.** `rc-prefix.ts` по-прежнему присваивает env для старого побайтового оракула, но действующая семантика получается обработчиком `tool_result`; `exit-marker.ts`, загруженный раньше, оставляет маркер до обнуления 141. Нормативную правку не предлагаю и пункт на этом припаркован.

Наблюдаемая семантика проверена живым, а не чтением кода:

* живой `probe025_dochernij_vector.sh .` дал rc 0: у MAIN и CHILD `false | true=ERR`, `yes | head -1=OK`; кроме того ребёнок получил Н-85 на канонических write-вызовах, checkout block и scratch pass;
* отдельная реальная omp-сессия исполнила ровно `exit 141`; её raw JSONL содержит `Command exited with code 141`, `[exit=141]`, `isError:false`, `details.exitCode:0`.

Зависимость от встроенного pipefail omp 18.1.18 не закреплена версией в `package.json`/конфиге. Однако она не является совсем неназванным везением: И-6 — явный живой тест семантики MAIN+CHILD и краснеет на `false | true`/`yes | head`. Остаточный риск: этот ручной live-зонд, а не version-pin или автоматический upgrade-guard; обновление omp может изменить встроенный pipefail до следующего запуска И-6.

## Пройденные scoped-контроли

* `bash scripts/drill_path_guard.sh` — rc 0, 25 judge-предъявлений и factory smoke.
* `bash scripts/drill_exit_marker.sh` — rc 0, семь judge-предъявлений и factory smoke.
* `git diff --exit-code frozen/contracts/025/3..HEAD -- fixtures/check_runner_hygiene/` — rc 0, пусто.
* `bash scripts/check_contract_frozen.sh` — rc 0, 025 v3 побайтово совпадает.
* `bash scripts/verify_antiplacebo.sh . --scope check_runner_hygiene` не является зелёным доказательством в этом клоне: rc 1 после 40 предъявленных фикстур, поскольку обнаружил изменения вне `$WORK` (`fake-pi.mjs`, `tmp/frozen.*`). Не подменяю этот исход успехом.

## Вердикт

**FAIL:** B-025-r3-1 показывает, что И-6 выдаёт rc 0 на противоречивых orphan toolCall/toolResult. Это независимый от капа класс оракула и блокирует принятие. Формы lua/awk/вложенный bash/xargs зафиксированы только как обязательный «ПОВТОР КЛАССА: форма записи, экземпляр 3».

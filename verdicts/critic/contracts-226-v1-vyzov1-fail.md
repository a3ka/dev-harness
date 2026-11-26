FAIL
OBJECT=cbce7ecc43a2749164e972dc2ef911cc02ca3176

СУД: repo=dev-harness; предмет=226; фаза=контракт; роль=critic; вызов=1/2 (полный; новый предмет); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit226; модель-факт=openai-codex/gpt-6.1-terra; SHA=cbce7ecc43a2749164e972dc2ef911cc02ca3176; предыдущий=нет; исключение=нет; автор Architect226 — openai-codex/gpt-6.1-sol, отдельная сессия. Факты моделей: `bash scripts/models_actual.sh --tsv --bind --session Crit226` и то же для Architect226, rc 0; привязка OBJECT у critic подтверждена. Класс риска рисковый: изменение селектора выключает процессный страж.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: блок — Б-1 отсутствие профиля и неверный слой как выключение
К-03: чисто — frozen 187/3 и 186/2 и регресс 203/186 в сдаточном листе
К-04: чисто — context.py rc 0 FROZEN 199 BLOBS 199 OVERLAPS 123 MISSING 0
К-05: чисто — вход contracts/226-arch-door-profile-key.md:50-61
К-06: чисто — вход probe.py:350-365 и INVALID_MUTANT в probe.py
К-07: чисто — --model rc 0 KLETKI 45 KRASNYH 0
К-08: чисто — четыре независимые мутации красны см. атаки ниже
К-09: блок — Б-1 отсутствие профиля и неверный слой как выключение
К-10: чисто — вход probe.py:97-155 rc stdout stderr argv gh и HEAD
К-11: чисто — вход probe.py:32-78 и probe.py:114-130
К-12: чисто — вход probe.py:169-235 реальные Git и профильный resolver
К-13: н/п — новых секретов и каналов секретов нет
К-14: чисто — --model rc 0 и отрицательные мутации false-on и name красны
К-15: чисто — --repo KLETKI 45 KRASNYH 35 и --model KLETKI 45 KRASNYH 0 и catalog 45 15 18
К-16: блок — Б-1 отсутствие профиля и неверный слой как выключение
К-17: н/п — станционный конфигурационный страж не меняет продуктовую архитектурную модель

## Блоки

БЛОКИРУЕТ contracts/226-arch-door-profile-key.md:37 — Б-1: неизвестное состояние профиля при наличии архитектуры объявлено выключением, включая ошибку слоя.
ОБЯЗАТЕЛЬСТВО: задание суду `/tmp/dev-harness-verify/task-crit226.md`, пункт 3: fail-closed на неоднозначный слой и на отсутствующий профиль проекта с архитектурой; «неизвестность ≠ выключено». Затравка различает отсутствие ключа (разрешённое выключение) и отсутствие файла профиля; она не разрешает считать недоступный профиль с архитектурой сознательным выключением.
СОСТОЯНИЕ: проект имеет architecture.lock.json, но harness.project.json отсутствует; либо профиль репо без листа, а в project defaults записан `hooks.archBrief: Other/Product`, как в реальном Git-мире `fixtures/workshop_project/arch_door_profile_key_226/probe.py:69,180-184`. Это прямо предъявленные заданием и батареей входы, не синтетический запрет значения.
НАБЛЮДЕНИЕ: строка 37 предписывает выключить pinned-дверь при отсутствующем файле; модель `model/scripts/check_architecture_contract.sh:124,143-145` возвращает неприменимость scope. При вызове `ARCH187_LIB=1 bash -c 'source "$1"; arch187_scope "$2"; printf "scope_rc=%s\n" "$?"' _ "$PWD/fixtures/workshop_project/arch_door_profile_key_226/model/scripts/check_architecture_contract.sh" "$PWD/tmp/scratch-crit226/no-profile"` с отсутствующим файлом и существующим lock сырой вывод `scope_rc=1` (это код неприменимости, не ошибка scope). Для второго входа `W --model --cell layer-cannot-enable` rc 0 и сырой результат `GREEN layer-cannot-enable (0, b'=== make_task contract=777 role=architect kind=task ===\\n...`, stderr содержит предупреждение `defaults.hooks`: кодовый пак без --arch-component принят. Батарея закрепляет именно успешный исход (probe.py:69), а не отказ. Прежнее правило M-0 для произвольных неизвестных имён само по себе не разрешает молча признать этот явно предъявленный ошибочный слой выключением.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: различать проверенное отсутствие листа в корректном repo-профиле и неизвестность профиля/ошибочное размещение политики; при наличии архитектуры последние состояния не обходят страж и не создают пак/теги, с адресными исполняемыми доказательствами и сохранением честного отсутствия листа, false и остальных обязательств M-0. Если сохранить заявленное выключение для этих состояний, требуется решение полномочной роли о смене риска, а не молчаливое сужение задания.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-16

## Доказательства

Обозначим W=`bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh`. Сдаточный лист запускался первым: `SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/226-arch-door-profile-key.md --run`, rc 0, сырой вывод `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=0)`. `bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md`, rc 0, сырой итог `КРИТИК: дверь зелёная`. `bash scripts/check_precision_gate.sh "$PWD" contracts/226-arch-door-profile-key.md`, rc 0, `OK`. `python3 fixtures/workshop_project/arch_door_profile_key_226/context.py`, rc 0, `FROZEN 199 BLOBS 199 OVERLAPS 123 MISSING 0`. Теги получены из origin, подтверждены blobs frozen 187/3 и 186/2.

`W --repo .` на OBJECT: rc 1, сырой итог `KLETKI 45 KRASNYH 35 SVJAZI 0 ZHIVYH 0`; `W --model`: rc 0, `KLETKI 45 KRASNYH 0 SVJAZI 0 ZHIVYH 0`. Сдаточный лист исполнил также --stabs, --regression и остальные заявленные двери с ожидаемым rc. Для позеленения реализация должна заменить селектор и источник адреса, валидировать профиль до чтения, сохранить различение ошибки scope и неприменимости на всех потребителях и явно мигрировать только входы строителей 187/186. Контракт требует неизменности ожиданий и после реализации реальный --repo регресс 203 и pin186; это не свидетельство, что существующая реализация уже исправлена.

Независимые мутации выполнены последовательно в отдельных одноразовых git-клонах с наложением честной модели, каждый раз командой `W --repo <клон>`; результат — буквальные итоговые строки вывода, rc относится к команде W:

- Удалён существующий предикат наличия `ARCH187_PRODUCT_REPO` в scope: rc 1, `KLETKI 45 KRASNYH 6 SVJAZI 0 ZHIVYH 0`; например `RED explicit-false RC,DIAGNOSIS`.
- К тому же предикату добавлен прежний селектор repoId, собранный из `"Complior"-back` (без текстового литерала в одной строке): rc 1, `KLETKI 45 KRASNYH 6 SVJAZI 0 ZHIVYH 0`; сырой вывод `RED other-enabled RC,DIAGNOSIS,PARTIAL_OUTPUT (0, b'=== make_task contract=777 role=architect kind=task ===\\n=== TRACE ===\\nTRACE: role=architect model=za', b'')`.
- В profile вместо выхода на false присвоено Example/Product: rc 1, `KLETKI 45 KRASNYH 8 SVJAZI 0 ZHIVYH 0`; `RED explicit-false RC,DIAGNOSIS`.
- В pin присваивание адреса заменено на `${PRODUCT_REPO:-$ARCH187_PRODUCT_REPO}`: rc 1, `RED pin-env PRODUCT_REPO_DEPENDENCY`, `KLETKI 45 KRASNYH 1 SVJAZI 0 ZHIVYH 0`. Это не infra rc 2: батарея видит неправильный argv.

`uptime` при подготовке: `load average: 4.38, 5.77, 7.95`. Модельные миры не доказывают реальную межрепозиторную доставку backend: строка 61 возлагает её на orchestrator и reviewer до done.

## НЕ ЗАЩИЩАЕТ

- Содержание архитектурной модели и одновременная перезапись профиля между валидацией и чтением — заявленная граница contracts/226-arch-door-profile-key.md:70, ловцы модельный check/reviewer и изоляция станции.
- Доставка backend-профиля до обновления установленной станции — cognitive-only предпосылка contracts/226-arch-door-profile-key.md:61, ловцы orchestrator и reviewer; live PR здесь не проверялся.

## Советы

СОВЕТ contracts/226-arch-door-profile-key.md:61 — при передаче на done сохранить ссылку на backend PR, SHA профиля и точную команду живой пробы вместе с её rc, чтобы ручной ловец был воспроизводим.

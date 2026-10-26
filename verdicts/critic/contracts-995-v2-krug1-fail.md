FAIL
OBJECT=8ae962ff6eb2542e7ad05c094e943e336506af71
СУД: repo=dev-harness; предмет=995 (v+1); фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic995; модель-факт=openai-codex/gpt-6-sol; SHA=8ae962ff6eb2542e7ad05c094e943e336506af71; предыдущий=нет; исключение=нет. Автор Architect995v2 — zai/glm-5.3, по заданию и трейсу оркестратора.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:47 — новая инкарнация не подтверждается: модель S после смерти нового emulator PID всё равно устанавливает APK, запускает полный второй набор и объявляет RECOVERED, если adb для того же serial отвечает (например, старый или чужой эмулятор занимает порт). Класс причины: доверие ответу adb по серийному номеру без привязки нового owned PID/инкарнации к готовому устройству. Батарея предъявляет только штатно живой второй mock-emulator, поэтому зелёная приёмка не различает новую инкарнацию и чужой/старый serial.
ОБХОД: model/ci-e2e.sh из коммита OBJECT байт-в-байт поставляется implementer-у, W --model и --stabs зелёные; подложный второй emulator немедленно выходит после EMULATOR_START, а adb продолжает сообщать ready на том же serial. На фактическом replay без изменения S: `EMULATOR_STOP 1081132` ПЕРЕД `ADB_INSTALL rc=0` и `MAESTRO 2 rc=0`; итог RC 0, RECOVERED True, JUnit второго набора опубликован. Проверка готовности не проверила жизнь именно нового owned PID. Состояние допустимо: emulator падает при старте или порт занят, чужой adb-serial остаётся доступен; собственный старый/чужой эмулятор не может считаться новой инкарнацией.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: батарея обязана краснить ситуацию смерти нового owned emulator до второго набора при доступном stale/foreign adb serial; приёмка подтверждает связанное с новым процессом устройство, не один только факт EMULATOR_START и успех adb по serial. Допустимая реализация завершает такую готовность красным, без второго Maestro и ложного RECOVERED.

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:49 — обязанность «при отказе готовности инкарнации Maestro не запускается» нарушена в той же достижимой ситуации (второй emulator уже остановился). Это следствие того же класса причины выше, а не отдельный класс для нового круга.
ОБЯЗАТЕЛЬСТВО: отказ готовности нового процесса — именованный красный итог, без Maestro.
СОСТОЯНИЕ: второй PID остановлен, adb на serial отвечает по другому процессу.
НАБЛЮДЕНИЕ: фактический replay ниже завершился rc 0, второй Maestro исполнился после EMULATOR_STOP.

## СЫРОЙ ВЫВОД ВЫПОЛНЕННОЙ АТАКИ

Временный скрипт `/tmp/dev-harness-verify/Critic995/attack995.py` импортирует неизменённый `restart/probe.py`, заменяет ТОЛЬКО подложный emulator: второе поколение логирует EMULATOR_START и немедленно выходит, логируя EMULATOR_STOP; сценарий, S, adb и оракул `obryv-device-offline` исходные. Открытый класс: после нового старта нет живого owned PID, но serial ещё доступен. Исходный S не изменён.

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin python3 /tmp/dev-harness-verify/Critic995/attack995.py
RC 0
REPLAY_REASON None
EMULATOR_START ci-567890123-1 1080900
ADB_INSTALL rc=0
MAESTRO 1 rc=1
EMULATOR_STOP 1080900
EMULATOR_START ci-567890123-1 1081132
EMULATOR_STOP 1081132
ADB_INSTALL rc=0
MAESTRO 2 rc=0
RECOVERED True
FINAL_JUNIT <?xml version="1.0"?>
<testsuite name="pilot" attempt="2" rc="0">
<testcase name="pilot-first-run"/><testcase name="pilot-welcome"/><testcase name="pilot-restart"/>
</testsuite>

[exit=0]
```

## ПРЕДВАРИТЕЛЬНЫЕ ПРОГОНЫ ДО ОБНАРУЖЕНИЯ БЛОКЕРА

Клонирование по SSH и checkout OBJECT: rc 0; `git show -s --format='%H%n%B' HEAD`: SHA OBJECT, сообщение содержит дословно разрешение владельца `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/995-cmp-mob-001-android-pilot.md v+1 — перезапуск собственного эмулятора и один повтор набора в mobile/scripts/ci-e2e.sh по обрыву транспорта, redacted диагностика обеих попыток, причинный замер; ЗОНА implementer дополняется mobile/scripts/ci-e2e.sh (слово владельца 2026-10-26, консультация Astra)`.

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh
SUBJECT_ABSENT: нет --repo/MOB_REPO; зелень без субъекта невозможна
CASE pervaja-zelena KRASNO (SUBJECT_ABSENT)
CASE obryv-device-offline KRASNO (SUBJECT_ABSENT)
CASE obryv-adb-notfound KRASNO (SUBJECT_ABSENT)
CASE obryv-serial-notfound KRASNO (SUBJECT_ABSENT)
CASE obryv-devserverdied KRASNO (SUBJECT_ABSENT)
CASE produkt-assert KRASNO (SUBJECT_ABSENT)
CASE produkt-install-tekst KRASNO (SUBJECT_ABSENT)
CASE smeshannyj KRASNO (SUBJECT_ABSENT)
CASE vtoroj-krasnyj-produkt KRASNO (SUBJECT_ABSENT)
CASE vtoroj-transportnyj KRASNO (SUBJECT_ABSENT)
CASE staryj-artefakt KRASNO (SUBJECT_ABSENT)
CASE pustoj-vyvod KRASNO (SUBJECT_ABSENT)
CASE ustanovka-otkaz KRASNO (SUBJECT_ABSENT)
CASE boot-ne-gotov KRASNO (SUBJECT_ABSENT)
CASE stabil-nedostizhima KRASNO (SUBJECT_ABSENT)
CASE malo-pamyati KRASNO (SUBJECT_ABSENT)
CASE kanon-bajt KRASNO (SUBJECT_ABSENT)
CASE zhyvoj-p-kanon KRASNO (SUBJECT_ABSENT)
CASE zapret-stroki KRASNO (SUBJECT_ABSENT)
CASE kanon-signatury KRASNO (SUBJECT_ABSENT)
CASE staryj-s-bez-pravki KRASNO (SUBJECT_ABSENT)
CASE staryj-p-bez-pravki KRASNO (SUBJECT_ABSENT)
CASE p-recovered KRASNO (SUBJECT_ABSENT)
CASE p-exhausted KRASNO (SUBJECT_ABSENT)
CASE p-produkt KRASNO (SUBJECT_ABSENT)
CASE p-timeout KRASNO (SUBJECT_ABSENT)
[exit=1]
```

`$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model`: три ПОСЛЕДОВАТЕЛЬНЫХ прогона rc 0, каждый 26/26 (`CASE pervaja-zelena ok` … `CASE p-timeout ok`). До последовательной тройки отдельные параллельные запуски дали rc 1 `CASE p-timeout KRASNO (rc=0 (ожидался 2))` и rc 0 соответственно; параллельная устойчивость не является обещанием контракта. Вопрос о флаке — СОВЕТ, не основание этого FAIL.

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs
CASE pervaja-zelena ok
CASE obryv-device-offline ok
CASE obryv-adb-notfound ok
CASE obryv-serial-notfound ok
CASE obryv-devserverdied ok
CASE produkt-assert ok
CASE produkt-install-tekst ok
CASE smeshannyj ok
CASE vtoroj-krasnyj-produkt ok
CASE vtoroj-transportnyj ok
CASE staryj-artefakt ok
CASE pustoj-vyvod ok
CASE ustanovka-otkaz ok
CASE boot-ne-gotov ok
CASE stabil-nedostizhima ok
CASE malo-pamyati ok
CASE kanon-bajt ok
CASE zhyvoj-p-kanon ok
CASE zapret-stroki ok
CASE kanon-signatury ok
CASE staryj-s-bez-pravki ok
CASE staryj-p-bez-pravki ok
CASE p-recovered ok
CASE p-exhausted ok
CASE p-produkt ok
CASE p-timeout ok
STAB p-bez-diagnostiki p-recovered KRASEN
STAB p-bez-diagnostiki p-timeout KRASEN
STAB p-bez-redakcii p-recovered KRASEN
STAB p-bez-redakcii p-exhausted KRASEN
STAB p-bez-sobytija p-recovered KRASEN
STAB p-bez-sobytija p-exhausted KRASEN
STAB p-bez-timeout-publikacii p-timeout KRASEN
STAB p-privatnoe-v-publikaciju p-recovered KRASEN
STAB s-bez-itoga-stabil stabil-nedostizhima KRASEN
STAB s-bez-pamyati malo-pamyati KRASEN
STAB s-bez-publikacii-diagnostiki pervaja-zelena KRASEN
STAB s-bez-publikacii-diagnostiki obryv-device-offline KRASEN
STAB s-bez-recovered obryv-device-offline KRASEN
STAB s-bez-recovered obryv-devserverdied KRASEN
STAB s-bez-restarta obryv-device-offline KRASEN
STAB s-bez-restarta obryv-adb-notfound KRASEN
STAB s-bez-restarta obryv-serial-notfound KRASEN
STAB s-bez-restarta obryv-devserverdied KRASEN
STAB s-diag-posle-stopa obryv-device-offline KRASEN
STAB s-exhausted-zelenyj vtoroj-krasnyj-produkt KRASEN
STAB s-exhausted-zelenyj vtoroj-transportnyj KRASEN
STAB s-glotajet-diag pervaja-zelena KRASEN
STAB s-glotajet-diag obryv-device-offline KRASEN
STAB s-install-ignoriruet ustanovka-otkaz KRASEN
STAB s-kill-server-v-stope obryv-device-offline KRASEN
STAB s-kill-server-v-stope zapret-stroki KRASEN
STAB s-nasledovanie-signatur staryj-artefakt KRASEN
STAB s-pkill-vmesto-pida obryv-device-offline KRASEN
STAB s-pkill-vmesto-pida zapret-stroki KRASEN
STAB s-png-obeih obryv-device-offline KRASEN
STAB s-propusk-boot-proverki boot-ne-gotov KRASEN
STAB s-retry-vseh produkt-assert KRASEN
STAB s-retry-vseh smeshannyj KRASEN
STAB s-retry-vseh staryj-artefakt KRASEN
STAB s-signatura-rasshirena produkt-install-tekst KRASEN
STAB s-signatura-suzhena obryv-adb-notfound KRASEN
STAB s-signatura-suzhena obryv-serial-notfound KRASEN
STAB s-tretja-popytka vtoroj-transportnyj KRASEN
SVJAZI 38
zhivykh 0
[exit=0]
```

Не запускал `--repo` на живом продукте, метагейты, порчи оракула и соседей: остановка на доказанном блокере по явному указанию задания «Блокер — сразу доклад, не грайнд». Из этого не следует ни их успех, ни их отказ.

## СОВЕТ

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:54 — в двух одновременно запущенных чистых `--model` один раз возник `CASE p-timeout KRASNO (rc=0 (ожидался 2))`, хотя три последовательных прогона прошли; если CI может исполнять несколько экземпляров одновременно, проверить изоляцию `p-timeout`. Это не доказательство дефекта в обещанных последовательных запусках.

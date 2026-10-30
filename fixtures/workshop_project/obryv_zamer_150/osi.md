# Оси и клетки батареи 150 (prichinnyy-zamer-obryva)

Формат соответствия «вход/причина» — таблица ниже; единый перечень клеток —
`KLETKI` в `probe.py`, оракул — `source.json` (правило 8: в памяти ДО
субъекта; порча пинов → rc 2 ORACLE_TAMPERED до клеток). Субъект — дерево
продукта: `.github/workflows/mobile.yml` + `mobile/ci-screens.json` +
`mobile/scripts/zamer_obryva.sh`. Работники — записи КАРТЫ (ekrany[].job +
integracija.job; канон разбора — у батареи, не у субъекта — прецедент 143).
Структурные клетки (z*) судят ВСЕХ работников; поведенческие (b*) —
исполнительный replay обёртки ПЕРВОГО работника карты (обёртка канонически
одинакова; параметры каждого работника судит z02). Экранные тела субъектов
батареей НЕ исполняются и не судятся — их держат батареи 143/147/148/995;
replay управляет МИРОМ вокруг обёртки: настоящие процессы-подделки qemu и
adb-server (live `/proc`, нонс мира), подложные adb/sleep/pgrep в замкнутом
PATH, виртуальные секунды (sleep-шим тикает счётчик), сценарные события
(обрыв/сигнатура/wipe) по виртуальному времени.

## z-ось (структура обвязки, статика по субъекту)

| клетка | вход | красная причина |
|---|---|---|
| z01-obertka-polnota | работники карты × шаги job | ZAMER_NET_OBERTKI <job>: нет «Замер обрыва: запуск сэмплера (150)» / «…сбор причинного снимка (150)» / «…артефакт (150)» |
| z02-obertka-parametry | env шагов × карта × PORT тела | ZAMER_EKRAN≠id записи; ZAMER_NS≠output_namespace; ZAMER_SERIAL≠emulator-<PORT> (PORT — литерал `PORT=<n>` тел работника, иначе `mobile/scripts/ci-e2e.sh` делегированных) |
| z03-obertka-porjadok-maskirovka | порядок/свойства шагов | любой continue-on-error у шага работника (маскировка итога); старт позже сбора; между стартом и сбором нет экранного шага; старт с if:always() (сэмплер после экранного шага); сбор/артефакт без if:always(); артефакт не upload-artifact или if-no-files-found≠ignore (зелёный краснеет) |
| z04-kanon-skripta | байты mobile/scripts/zamer_obryva.sh | ZAMER_SKRIPT_NET / ZAMER_SKRIPT_NE_KANON (пин sha256 в source.json:.piny — канон реализация вносит байт-в-байт) |

## b-ось (поведение, replay обёртки работника-1; сценарии — probe.py:SCENARII)

| клетка | сценарий | красная причина |
|---|---|---|
| b01-krasnyj-s-signaturoj | obryv (эмулятор жив 60 с → убит, сигнатура device offline/DeviceServerDiedException в ns) | sbor rc≠0 (обёртка меняет итог); ARTEFAKT_NET (no-op замер); SIGNATURY_BEZ_ADRESA (в артефакте нет file:line) |
| b02-zelenyj-tishina | zelenyj (обрыва нет, зелёный junit в ns) | ZELENYJ_KRASN (сбор упал на зелёном); ZELENYJ_PUBLIKUET (артефакт на зелёном); TISHINA_BEZ_MARKERA |
| b03-produktovyj-krasnyj | produkt (Assertion is false… в ns, БЕЗ сигнатуры; в корне воркспейса decoy-файл со старой сигнатурой) | PRODUKTOVYJ_KRASN; LOZHNAYA_PUBLIKAJIJA (греп шире ns — decoy соблазнил) |
| b04-dannye-do-ostanovki | obryv (границы записаны: строка таймлайна на момент убийства qemu и на момент записи сигнатуры) | TAJMLAJN_NET (замер после остановки: сэмплер не писал); IZMERENO_POSLE_OTSTANOVKI (PID живого эмулятора не наблюдается ДО сигнатуры); PID_ZHIV_POSLE_SMERTI (таймлайн лжёт) |
| b05-cgroup-poly | obryv (cgroup-фикстура даёт счётчики) | CGROUP_POTERJAN: нет колонки memory.current/memory.events(high,max,oom)/cpu.stat(nr_throttled,throttled_usec)/psi(cpu,memory avg10); строка ≠16 полей; пустые/«-» значения cgroup-полей |
| b06-adb-server-i-device | obryv (сценарий меняет adb-server на 63-й с) | NET_START_PIDA / NET_SBOR_PIDA adb-server; SMENA_ADB_SERVER_NE_POMECHENA; NET_ADB_DEVICES; NET_BOOT_ID / NET_ADBD_PID (живые пробы гостя раз в 15 с не попали в таймлайн) |
| b07-sekrety-redakcija | obryv (ghp_… в журнале эмулятора, Bearer… в logcat-тексте сценария) | SEKRET_UTEK <файл:префикс>; NET_REDAKTSII (маркер REDACTED не встречен) |
| b08-obem-ogranichen | obryv + объём (logcat-файл сценария 120k строк; журнал эмулятора — 300 байт-тяжёлых строк по 12 KiB: tail -n 200 считает строки, тяжесть несут байты) | FAIL_BEZ_PREDLA <имя,байты> (>512 KiB); ARTEFAKT_BEZ_PREDLA (>2 MiB); ARTEFAKT_NET |
| b09-sampler-legkij | obryv + статика канона | SAMPLER_TJAZELOVAT: тики виртуального времени > длительности сценария +15 с (>1 Гц); опросов devices > 1/с; проб гостя > 1/15 с; bugreport/dumpsys в коде канона; LOGCAT_BEZ_T (вызов adb logcat без -t) |
| b10-sampler-ostanovlen | obryv (живость сэмплера зафиксирована сразу после sbor, до зачистки) | PIDFILE_NET/ПУСТ/МУСОР; SEMPLER_ZHIV: процесс пережил сбор |
| b11-vosstanovlennyj-zelenyj | vosstanovlennyj (обрыв→сигнатура→wipe ns повторной попыткой→зелёный итог, qemu перезапущен) | VOSST_KRASN; VOSST_PUBLIKUET (зелёный итог публикует) |

## Стабы (Н-39: привязки — только source.json:.stab_vhod; каждая обманка
## обязана красить свою клетку, иначе STAB_ZHIV rc 1)

| стаб | обманка | клетка-ловушка |
|---|---|---|
| stab_zamer_noop.py | гейт всегда закрыт — артефакт не собирается никогда | b01 |
| stab_zamer_posle_ostanovki.py | цикл сэмплера мёртв — измерять нечем, сбор «после» | b04 |
| stab_zamer_vsegda.py | гейт снят — зелёный тоже публикует | b02 |
| stab_zamer_bez_cgroup.py | чтение cgroup подменено на несуществующие файлы | b05 |
| stab_zamer_maskiruet.py | continue-on-error на экранный (продуктовый) шаг | z03 |
| stab_zamer_bez_redakcii.py | redakt_fajl выключен — секреты утекают | b07 |
| stab_zamer_bez_predela.py | ограничители объёма выключены | b08 |
| stab_zamer_tjaghelo.py | 20 Гц сэмплер + проба гостя каждые 3 с | b09 |
| stab_zamer_zelenyj_krasnyj.py | закрытый гейт выходит 1 — зелёный краснеет | b02 |
| stab_zamer_shirokij_grep.py | гейт грепит весь воркспейс — decoy лжёт | b03 |
| stab_zamer_pidfile_zhiv.py | блок стопа сэмплера выключен | b10 |

## Режимы и коды

- без флага/без `--repo` — субъект (дерево харнесса) не реализован: rc 1,
  SUBJECT_ABSENT, все 15 клеток красны поимённо;
- `--repo R` — живой продукт: до реализации обёртки красен поимённо;
- `--model` — эталон: rc 0, 15/15;
- `--stabs` — контроль + SVJAZI 11, живых стабов 0;
- `--oracle-tamper` — порча каждого из 3 пиннованных носителей ловится
  ORACLE_TAMPERED rc 2 ДО клеток;
- `--seed N` — тот же итог при другом порядке клеток.

## Границы честности replay (что мир моделирует, а что нет)

- Подделки qemu/adb-server — НАСТОЯЩИЕ процессы (live `/proc/<pid>/stat`,
  `kill -0` честны); нонс мира изолирует pgrep-мир батареи от чужих
  qemu/adb-server станции (и наоборот).
- Виртуальное время: sleep-шим тикает общий счётчик; сценарные события
  (убийство qemu, запись сигнатуры, смена adb-server, wipe ns) исполняет
  драйвер по виртуальному времени; реальные секунды replay ≪ виртуальных.
- Экранный шаг субъекта не исполняется: replay проверяет обвязку вокруг
  него; соответствие самого экранного тела лекалу/замороженным канонам —
  батареи 143/147/148/995 (НЕ ЗАЩИЩАЕТ в контракте 150).
- boot_id/logcat НА МОМЕНТ СБОРА на обрыве честно помечаются недоступными
  (устройство offline); различительная ценность — в живых пробах таймлайна
  (до обрыва) и в маркерах недоступности.

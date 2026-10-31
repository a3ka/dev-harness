# Оси и клетки батареи 150 (prichinnyy-zamer-obryva)

Формат соответствия «вход/причина» — таблица ниже; единый перечень клеток —
`KLETKI` в `probe.py`, оракул — `source.json` (правило 8: в памяти ДО
субъекта; порча пинов → rc 2 ORACLE_TAMPERED до клеток). Субъект — дерево
продукта: `.github/workflows/mobile.yml` + `mobile/ci-screens.json` +
`mobile/scripts/zamer_obryva.sh`. Работники — записи КАРТЫ (ekrany[].job +
integracija.job; канон разбора — у батареи, не у субъекта — прецедент 143).
Структурные клетки (z*) судят ВСЕХ работников; поведенческие (b*) —
исполнительный replay обёртки ПЕРВОГО работника карты (обёртка канонически
одинакова; параметры каждого работника судят z02/z05). Экранные тела
субъектов батареей НЕ исполняются и не судятся — их держат батареи
143/147/148/995; replay управляет МИРОМ вокруг обёртки: настоящие
процессы-подделки qemu и adb-server (live `/proc`, нонс мира), подложные
adb/sleep/pgrep в замкнутом PATH, виртуальные секунды (sleep-шим тикает
счётчик), сценарные события (обрыв/сигнатура/wipe) по виртуальному времени.

## z-ось (структура обвязки, статика по субъекту)

| клетка | вход | красная причина |
|---|---|---|
| z01-obertka-polnota | работники карты × шаги job | ZAMER_NET_OBERTKI <job>: нет «Замер обрыва: запуск сэмплера (150)» / «…сбор причинного снимка (150)» / «…артефакт (150)» |
| z02-obertka-parametry | env шагов × карта × PORT тела | ZAMER_EKRAN≠id записи; ZAMER_NS≠output_namespace; ZAMER_SERIAL≠emulator-<PORT> (PORT — литерал `PORT=<n>` тел работника, иначе `mobile/scripts/ci-e2e.sh` делегированных) |
| z03-obertka-porjadok-maskirovka | порядок/свойства шагов | любой continue-on-error у шага работника (маскировка итога); старт позже сбора; между стартом и сбором нет экранного шага; старт с if:always() (сэмплер после экранного шага); сбор/артефакт без if:always(); артефакт не upload-artifact или if-no-files-found≠ignore (зелёный краснеет) |
| z04-kanon-skripta | байты mobile/scripts/zamer_obryva.sh | ZAMER_SKRIPT_NET / ZAMER_SKRIPT_NE_KANON (пин sha256 в source.json:.piny — канон реализация вносит байт-в-байт) |
| z05-put-zagruzki | with.path/with.name шага артефакта × РАЗБОР scalar `run` шага сбора (канонизация shell-строк: комментарий/echo/посторонняя строка — НЕ код; РОВНО один вызов `bash mobile/scripts/zamer_obryva.sh sbor`; РОВНО один `--out`; `$`-подстановка только из env шага), ПО КАЖДОМУ работнику карты (арбитраж 150 П1) | SBOR_RUN_NE_RASPOZNAN (незакрытая кавычка); SBOR_VYZOV_NEODNOZNACHEN (вызовов sbor ≠ 1); SBOR_BEZ_ODNOZNACHNOGO_OUT; SBOR_OUT_NE_RASPOZNAN (неизвестная переменная/подстановка команды); PUT_ZAGRUZKI_RASHODITSJA: with.path ≠ mobile/zamer-out-<ZAMER_EKRAN> ЛИБО исполняемый `--out` ≠ with.path (upload грузит пустоту при if-no-files-found: ignore — публикация недоказуема); IMJA_ARTEFAKTA_NE_EKRAN (name не zamer-<ekran>-…) |

## b-ось (поведение, replay обёртки работника-1; сценарии — probe.py:SCENARII)

| клетка | сценарий | красная причина |
|---|---|---|
| b01-krasnyj-s-signaturoj | obryv (эмулятор жив 60 с → убит, сигнатура device offline/DeviceServerDiedException в ns) | sbor rc≠0 (обёртка меняет итог); ARTEFAKT_NET (no-op замер); SIGNATURY_BEZ_ADRESA (в артефакте нет file:line) |
| b02-zelenyj-tishina | zelenyj (обрыва нет, зелёный junit в ns) | ZELENYJ_KRASN (сбор упал на зелёном); ZELENYJ_PUBLIKUET (артефакт на зелёном); TISHINA_BEZ_MARKERA |
| b03-produktovyj-krasnyj | produkt (Assertion is false… в ns, БЕЗ сигнатуры; в корне воркспейса decoy-файл со старой сигнатурой) | PRODUKTOVYJ_KRASN; LOZHNAYA_PUBLIKAJIJA (греп шире ns — decoy соблазнил) |
| b04-dannye-do-ostanovki | obryv (границы записаны: строка таймлайна на момент убийства qemu и записи сигнатуры; в журнал при смерти пишется маркер signal 9) | TAJMLAJN_NET (замер после остановки: сэмплер не писал); IZMERENO_POSLE_OTSTANOVKI (PID живого эмулятора не наблюдается ДО сигнатуры); PID_ZHIV_POSLE_SMERTI (таймлайн лжёт); EXIT_NET (смерть не зафиксирована в emulator-exit.txt); EXIT_BEZ_PIDA; EXIT_BEZ_OM_DELTY; EXIT_BEZ_PRICHINY (маркер журнала не прочитан); EXIT_SKRYVAET (нет честного маркера недоступности числового exit code) |
| b05-cgroup-poly | obryv (cgroup-фикстура даёт счётчики) | CGROUP_POTERJAN: нет колонки memory.current/memory.events(high,max,oom)/cpu.stat(nr_throttled,throttled_usec)/psi(cpu,memory avg10); строка ≠16 полей; пустые/«-» значения cgroup-полей |
| b06-adb-server-i-device | obryv (сценарий меняет adb-server на 63-й с) | NET_START_PIDA / NET_SBOR_PIDA adb-server; SMENA_ADB_SERVER_NE_POMECHENA; NET_ADB_DEVICES; NET_BOOT_ID / NET_ADBD_PID (живые пробы гостя раз в 15 с не попали в таймлайн); KOLCO_NET (предостановочного logcat-кольца нет или без -t); KOLCO_PUSTOE (кольцо не несёт содержимого ДО обрыва) |
| b07-sekrety-redakcija | obryv (ghp_… и PEM-блок в журнале эмулятора, Bearer… и PEM-блок в logcat-тексте сценария) | SEKRET_UTEK <файл:префикс> — включая PEM: тело ключа и строка END во ВСЁМ опубликованном дереве; NET_REDAKTSII; NET_REDAKTSII_PEM (маркер редакции PEM не встречен) |
| b08-obem-ogranichen | obryv + объём (logcat-файл сценария 120k строк; журнал эмулятора — 300 байт-тяжёлых строк по 12 KiB: tail -n 200 считает строки, тяжесть несут байты) | FAIL_BEZ_PREDLA <имя,байты> (>512 KiB ТОЧНО — маркер обрезки входит в потолок); ARTEFAKT_BEZ_PREDLA (>2 MiB точно); ARTEFAKT_NET |
| b09-sampler-legkij | obryv + статика канона | SAMPLER_TJAZELOVAT: тики виртуального времени > длительности сценария +15 с (>1 Гц); опросов devices > 1/с; проб гостя > 1/15 с; logcat-чтений > 1/15 с; bugreport/dumpsys в коде канона; LOGCAT_BEZ_T (вызов adb logcat без -t) |
| b10-sampler-ostanovlen | obryv (живость сэмплера зафиксирована сразу после sbor, до зачистки) | PIDFILE_NET/ПУСТ/МУСОР; SEMPLER_ZHIV: процесс пережил сбор |
| b11-vosstanovlennyj-zelenyj | vosstanovlennyj (RECOVERED по frozen 995/5: обрыв→сигнатура→перезапуск эмулятора→ns финальной ЗЕЛЁНОЙ попытки СОХРАНЯЕТ архив `diagnostics/attempt-1/maestro.log` с сигнатурой обрыва) | RECOVERED_NET (фикстура без архива 995 — дефект батареи); VOSST_KRASN; VOSST_PUBLIKUET (зелёный итог публикует — гейт соблазнён архивом прошлой попытки) |
| b12-mir-poddelki-umerly | все replay (после их завершения; нонсы миров) | PODDELKI_ZHIVY: pids [...] пережили мир (найденных батарея зачищает на месте) — гигиена самоисполняемой батареи |

## Стабы (Н-39: привязки — только source.json:.stab_vhod; каждая обманка
## обязана красить свою клетку, иначе STAB_ZHIV rc 1)

| стаб | обманка | клетка-ловушка |
|---|---|---|
| stab_zamer_noop.py | гейт всегда закрыт — артефакт не собирается никогда | b01 |
| stab_zamer_posle_ostanovki.py | цикл сэмплера мёртв — измерять нечем, сбор «после» | b04 |
| stab_zamer_bez_exit.py | таймлайн пишется, фиксация завершения эмулятора выброшена | b04 |
| stab_zamer_vsegda.py | гейт снят — зелёный тоже публикует | b02 |
| stab_zamer_bez_cgroup.py | чтение cgroup подменено на несуществующие файлы | b05 |
| stab_zamer_maskiruet.py | continue-on-error на экранный (продуктовый) шаг | z03 |
| stab_zamer_bez_redakcii.py | redakt_fajl выключен — секреты утекают | b07 |
| stab_zamer_pem_tolko_begin.py | PEM-редакция только по строке BEGIN — тело и END утекают | b07 |
| stab_zamer_bez_predela.py | ограничители объёма (файлы/артефакт/сэмплер) выключены | b08 |
| stab_zamer_tjaghelo.py | 20 Гц сэмплер + проба гостя каждые 3 с | b09 |
| stab_zamer_zelenyj_krasnyj.py | закрытый гейт выходит 1 — зелёный краснеет | b02 |
| stab_zamer_shirokij_grep.py | гейт грепит весь воркспейс — decoy лжёт | b03 |
| stab_zamer_pidfile_zhiv.py | блок стопа сэмплера выключен | b10 |
| stab_zamer_bez_kolca.py | logcat-кольцо не пишется в процессе работы | b06 |
| stab_zamer_arhiv_soblaznjaet.py | наивный гейт по всему ns — архив диагностики 995 лжёт обрывом текущей попытки | b11 |
| stab_zamer_put_zagruzki.py | with.path ведёт в несуществующий каталог — upload грузит пустоту | z05 |
| stab_zamer_kommentarij_sbor.py | исполняемый --out сбора ведёт в чужой каталог, правильная строка спрятана комментарием в run (арбитраж 150 П1) | z05 |
| stab_zamer_techet_procesom.py | sbor выбрасывает подделку-qemu с нонсом мира — процесс переживает сбор | b12 |

## Режимы и коды

- без флага/без `--repo` — субъект (дерево харнесса) не реализован: rc 1,
  SUBJECT_ABSENT, все 17 клеток красны поимённо;
- `--repo R` — живой продукт: до реализации обёртки красен поимённо;
- `--stabs` — контроль + SVJAZI 18, живых стабов 0;
- `--oracle-tamper` — порча каждого из 3 пиннованных носителей ловится
  ORACLE_TAMPERED rc 2 ДО клеток;
- `--seed N` — тот же итог при другом порядке клеток.

## Границы честности replay (что мир моделирует, а что нет)

- Подделки qemu/adb-server — НАСТОЯЩИЕ процессы (live `/proc/<pid>/stat`,
  `kill -0` честны); нонс мира изолирует pgrep-мир батареи от чужих
  qemu/adb-server станции (и наоборот). Каждый порождённый PID батарея
  останавливает и дожидает; клетка b12 доказывает отсутствие живых подделок
  нонса мира ПОСЛЕ суда (гигиена самоисполняемой батареи).
- Виртуальное время: sleep-шим тикает общий счётчик; сценарные события
  (убийство qemu с маркером signal 9 в журнал, запись сигнатуры, смена
  adb-server, перезапуск qemu, wipe ns по модели 995) исполняет драйвер по
  виртуальному времени; sbor стартует после ОБРАБОТКИ всех событий;
  реальные секунды replay ≪ виртуальных.
- Экранный шаг субъекта не исполняется: replay проверяет обвязку вокруг
  него; соответствие самого экранного тела лекалу/замороженным канонам —
  батареи 143/147/148/995 (НЕ ЗАЩИЩАЕТ в контракте 150).
- boot_id/logcat НА МОМЕНТ СБОРА на обрыве честно помечаются недоступными
  (устройство offline); различительная ценность — в живых пробах таймлайна,
  в предостановочном logcat-кольце (пишется сэмплером при state=device) и в
  маркерах недоступности.
- RECOVERED-состояние ns моделируется по frozen 995/5: финальная попытка
  зелёная (top-level junit/report), архив диагностики упавшей попытки 1
  (`diagnostics/attempt-1/maestro.log` с сигнатурой) СОХРАНЁН — гейт судит
  текущую попытку (`--exclude-dir=diagnostics`), не весь ns.

# Оси и клетки батареи 150 (prichinnyy-zamer-obryva)

Формат соответствия «вход/причина» — таблица ниже; единый перечень клеток —
`KLETKI` в `probe.py` (census: `grep -cE '^\| (z0[0-9]|b[01][0-9])-' osi.md`),
оракул — `source.json` (правило 8: в памяти ДО субъекта; порча пинов →
rc 2 ORACLE_TAMPERED до клеток; носителей — 9, census: `jq '.piny|length'
source.json`). Субъект — дерево продукта: `.github/workflows/mobile.yml` +
`mobile/ci-screens.json` + `mobile/scripts/zamer_obryva.sh` (+ носители
дочернего хука/раннера/lane при матричной/lane-форме). Единица покрытия —
(job, id) по записям КАРТЫ: записи матричного job НЕ схлопываются, второй
child судится отдельно; матричность определяет workflow (strategy.matrix).

## Закрытый канон обёртки (S2 §1.3, решение владельца 2026-11-12)

Батарея НЕ интерпретирует произвольный run/shell/defaults/ифы. Канон хранится
в пиннованных носителях model/: workflow-эталон несёт ДВЕ формы шагов замера
обычного работника — F1 (прямой вызов `bash mobile/scripts/zamer_obryva.sh
<start|sbor> …`, работник e2e-proba-obryv) и F2 (npm-lane `npm run ci:zamer
-- <start|sbor> …`, работник e2e-proba-drugoj; закрытая привязка lane —
корневой package.json + словарь lanes run-mobile-ci.cjs, канон-строка
`model/kanon/lane-zamer.txt`, без eval/параметра оболочки) — и матричный
job e2e-proba-matrica (два child: замер — ДОЧЕРНИМ ХУКОМ
`mobile/scripts/zamer_child_hook.sh` внутри `run-ci-screen.cjs`,
канон-строки вызова — `model/kanon/child-hook-vyzovy.txt`). Шаблон = сырой
span шага эталона (метки строк compose) с подстановкой закрытых полей карты
(плейсхолдеры EKRAN/NS/SERIAL/out/name); нормализация — ТОЛЬКО базовый
отступ YAML-узла и индикатор списка; комментарии/содержимое не трогаются;
`safe_load`→dump вместо байтового сравнения не применяется. Параметры
рендера — закрытые типы: id `^[a-z0-9][a-z0-9-]*$`, ns `^mobile/[a-z0-9][a-z0-9._/-]*$`
без `..`, serial `^emulator-[0-9]+$` (порт — литерал `PORT=<n>` тела,
делегированным — `mobile/scripts/ci-e2e.sh`; child — avd_port записи карты);
неизвестный параметр/тип — KANON_150_PARAM. Управляющее окружение шага
фиксируют байты канона: каждый шаг замера несёт ЯВНЫЕ `shell: bash`
(= `bash --noprofile --norc -eo pipefail {0}`) и `working-directory:
${{ github.workspace }}` — root/job defaults (у продукта main:
`defaults.run.working-directory: mobile`, модель согласована) на семантику
шагов замера НЕ влияют; мутант job-defaults честно ЗЕЛЁН по построению
(прежняя краснота была артефактом симулятора, не дефектом продукта).
Гигиена YAML: дубликаты ключей (дерево compose), merge `<<`, алиасы и явные
теги (поток событий) — KANON_150_YAML, неоднозначный разбор не принимается.
Матричный child: внешний шаг 150 один — артефакт child (канон-шаблон по
`matrix.screen.id`); экраный шаг — закрытые привязки env
`SCREEN_ID=${{ matrix.screen.id }}` / `AVD_PORT=${{ matrix.screen.avd_port }}`
(межконтрактный вход 143 v3); раннер обязан содержать три канон-строки вызова
хука (start — до экранного исполнения; maestro — обёртка каждой попытки,
stdout/stderr в диагностический ns; sbor — в finally ДО остановки эмулятора),
каждую ровно один раз, start/maestro раньше sbor; прямой `spawnSync('maestro',`
мимо хука — KANON_150_MATRICA. Форма шага не совпала ни с одним рендером —
именованное первое отличие: KANON_150_RUN/SHELL/IF/CWD/ENV/KEYS (по строке
канона) или KANON_150_KEYS (лишние/недостающие строки); lane-форма без
закрытой привязки — KANON_150_LANE.

## z-ось (обвязка; z05 — байтовый канон КАЖДОЙ единицы; z06/z07 — исполнительный оракул результата)

| клетка | вход | красная причина |
|---|---|---|
| z01-obertka-polnota | единицы карты × шаги job | ZAMER_NET_OBERTKI <job>: нет «Замер обрыва: запуск сэмплера (150)» / «…сбор причинного снимка (150)» / «…артефакт (150)»; матричный child: нет артефакт-шага child / шага запуска run-ci-screen.cjs |
| z02-obertka-parametry | env шагов × карта × PORT тела; child — закрытые привязки matrix.screen.* | ZAMER_EKRAN≠id записи; ZAMER_NS≠output_namespace; ZAMER_SERIAL≠emulator-<PORT>; SCREEN_ID/AVD_PORT≠matrix.screen.* |
| z03-obertka-porjadok-maskirovka | порядок/свойства шагов и job | continue-on-error у шага ИЛИ на уровне job (маскировка итога); старт позже сбора; между стартом и сбором нет экраного шага; старт с if:always(); сбор/артефакт без if:always(); артефакт не upload-artifact или if-no-files-found≠ignore |
| z04-kanon-skripta | байты mobile/scripts/zamer_obryva.sh (+ zamer_child_hook.sh при матричных child) | ZAMER_SKRIPT_NET / ZAMER_SKRIPT_NE_KANON / ZAMER_HOOK_NET / ZAMER_HOOK_NE_KANON (пины sha256 в source.json:.piny — реализация вносит байт-в-байт) |
| z05-kanon-obertki | сырой span каждого шага замера каждой единицы × отрендеренный канон (F1\|F2\|M); гигиена YAML; lane-привязка; канон-строки хука в раннере | KANON_150_YAML (дубликат/алиас/тег/merge); KANON_150_PARAM (тип поля карты); KANON_150_RUN/SHELL/IF/CWD/ENV/KEYS (первое отличие — адрес строки); KANON_150_LANE (привязка lane не закрыта); KANON_150_MATRICA (нет канон-строки хука / прямой maestro мимо хука / порядок); KANON_150_KEYS (нет шага / лишние строки) |
| z06-sbor-rezultat | канонический run сбора КАЖДОГО обычного работника исполняется в канонической семантике (`bash --noprofile --norc -eo pipefail -c`, cwd воркспейс) в одноразовом мире (ns с сигнатурой/без, shims adb/sleep/pgrep, cgroup-фикстура); суд по РЕАЛЬНЫМ файлам | SBOR_150_RC≠0 (итог меняется); SBOR_150_RESULT_NET (itog без reshenie=publikuem / signatury.txt пуст — событие запуска/echo результатом не считается); LOZHNAJA_PUBLIKAJIJA (честный негатив: без сигнатуры публикует); SBOR_SHAG_NET / PORT_RABOTNIKA_NET |
| z07-dochernij-hook | хук child исполняется для КАЖДОГО child (включая второго): maestro-обёртка с подложным maestro (отказ с сигнатурой 141 / продуктовый отказ без); суд по реальным файлам | HUK_ITOG_MENJAETSA (rc≠rc maestro); HUK_BEZ_NS (stdout/stderr не в диагностическом ns); SBOR_150_RESULT_NET (сбор до повтора/finally не создал результат); HUK_LOZHNAJA_PUBLIKAJIJA (без сигнатуры публикует); KANON_150_PARAM (запись без avd_port); ZAMER_HOOK_NET |

## b-ось (поведение, replay обёртки работника-1; сценарии — probe.py:SCENARII)

| клетка | сценарий | красная причина |
|---|---|---|
| b01-krasnyj-s-signaturoj | obryv (эмулятор жив 60 с → убит, сигнатура device offline/DeviceServerDiedException в ns) | sbor rc≠0 (обёртка меняет итог); ARTEFAKT_NET (no-op замер); SIGNATURY_BEZ_ADRESA (в артефакте нет file:line) |
| b02-zelenyj-tishina | zelenyj (обрыва нет, зелёный junit в ns) | ZELENYJ_KRASN (сбор упал на зелёном); ZELENYJ_PUBLIKUET (артефакт на зелёном); TISHINA_BEZ_MARKERA |
| b03-produktovyj-krasnyj | produkt (Assertion is false… в ns, БЕЗ сигнатуры; в корне воркспейса decoy-файл со старой сигнатурой) | PRODUKTOVYJ_KRASN; LOZHNAYA_PUBLIKAJIJA (греп шире ns — decoy соблазнил) |
| b04-dannye-do-ostanovki | obryv (границы записаны: строка таймлайна на момент убийства qemu и записи сигнатуры; в журнал при смерти пишется маркер signal 9) | TAJMLAJN_NET; IZMERENO_POSLE_OTSTANOVKI; PID_ZHIV_POSLE_SMERTI; EXIT_NET; EXIT_BEZ_PIDA; EXIT_BEZ_OM_DELTY; EXIT_BEZ_PRICHINY; EXIT_SKRYVAET |
| b05-cgroup-poly | obryv (cgroup-фикстура даёт счётчики) | CGROUP_POTERJAN: нет колонки memory.current/memory.events(high,max,oom)/cpu.stat/psi; строка ≠16 полей; пустые/«-» значения |
| b06-adb-server-i-device | obryv (сценарий меняет adb-server на 63-й с) | NET_START_PIDA / NET_SBOR_PIDA adb-server; SMENA_ADB_SERVER_NE_POMECHENA; NET_ADB_DEVICES; NET_BOOT_ID / NET_ADBD_PID; KOLCO_NET; KOLCO_PUSTOE |
| b07-sekrety-redakcija | obryv (ghp_… и PEM-блок в журнале эмулятора, Bearer… и PEM-блок в logcat-тексте сценария) | SEKRET_UTEK <файл:префикс> — включая PEM: тело ключа и END во ВСЁМ опубликованном дереве; NET_REDAKTSII; NET_REDAKTSII_PEM |
| b08-obem-ogranichen | obryv + объём (logcat-файл сценария 120k строк; журнал эмулятора — 300 байт-тяжёлых строк по 12 KiB) | FAIL_BEZ_PREDLA <имя,байты> (>512 KiB ТОЧНО); ARTEFAKT_BEZ_PREDLA (>2 MiB точно); ARTEFAKT_NET |
| b09-sampler-legkij | obryv + статика канона | SAMPLER_TJAZELOVAT: тики > длительности +15 с; опросов devices > 1/с; проб гостя > 1/15 с; logcat-чтений > 1/15 с; bugreport/dumpsys в коде; LOGCAT_BEZ_T |
| b10-sampler-ostanovlen | obryv (живость сэмплера сразу после sbor) | PIDFILE_NET/ПУСТ/МУСОР; SEMPLER_ZHIV |
| b11-vosstanovlennyj-zelenyj | vosstanovlennyj (RECOVERED 995/5: ns зелёной попытки СОХРАНЯЕТ архив diagnostics/attempt-1 с сигнатурой) | RECOVERED_NET; VOSST_KRASN; VOSST_PUBLIKUET |
| b12-mir-poddelki-umerly | все replay (после их завершения; нонсы миров) | PODDELKI_ZHIVY: pids […] пережили мир (найденных батарея зачищает) |

## Стабы (Н-39: привязки — только source.json:.stab_vhod; каждая обманка
## обязана красить свою клетку, иначе STAB_ZHIV rc 1)

Матрица различительных отказов (S2 §1.3): каждая обманка — у ВТОРОГО
работника (e2e-proba-drugoj, lane-форма F2) либо в матрице/раннере, первый
работник остаётся каноническим; парный честный вариант — общий прогон
модели (19/19 зелёных). Стаб-режим судит ТОЛЬКО привязанную клетку
(исполнительный мир — по потребности клетки; b12 — все миры), поведенческий
контроль — общий прогон модели в начале `--stabs`.

| стаб | обманка | клетка-ловушка |
|---|---|---|
| stab_zamer_noop.py | гейт всегда закрыт — артефакт не собирается никогда | b01 |
| stab_zamer_posle_ostanovki.py | цикл сэмплера мёртв — измерять нечем | b04 |
| stab_zamer_bez_exit.py | фиксация завершения эмулятора выброшена | b04 |
| stab_zamer_vsegda.py | гейт снят — зелёный тоже публикует | b02 |
| stab_zamer_bez_cgroup.py | чтение cgroup подменено | b05 |
| stab_zamer_maskiruet.py | continue-on-error на экранный шаг | z03 |
| stab_zamer_bez_redakcii.py | redakt_fajl выключен — секреты утекают | b07 |
| stab_zamer_pem_tolko_begin.py | PEM-редакция только по BEGIN | b07 |
| stab_zamer_bez_predela.py | ограничители объёма выключены | b08 |
| stab_zamer_tjaghelo.py | 20 Гц сэмплер + проба гостя каждые 3 с | b09 |
| stab_zamer_zelenyj_krasnyj.py | закрытый гейт выходит 1 | b02 |
| stab_zamer_shirokij_grep.py | гейт грепит весь воркспейс — decoy лжёт | b03 |
| stab_zamer_pidfile_zhiv.py | блок стопа сэмплера выключен | b10 |
| stab_zamer_bez_kolca.py | logcat-кольцо не пишется | b06 |
| stab_zamer_arhiv_soblaznjaet.py | гейт по всему ns — архив 995 лжёт | b11 |
| stab_zamer_put_zagruzki.py | with.path второго работника в несуществующий каталог | z05 |
| stab_zamer_kommentarij_sbor.py | исполняемый --out в чужой каталог, правильный — комментарием (арбитраж 150 П1) | z05 |
| stab_zamer_uslovnyj_sbor.py | `true \|\| sbor` у второго (krug3) | z05 |
| stab_zamer_uslovnyj_sbor_and.py | `false && sbor` у второго (krug3) | z05 |
| stab_zamer_operator_novaja_stroka.py | `true \|\|` + перенос строки (krug4) | z05 |
| stab_zamer_konvejer_false_true.py | `false \| true \|\| sbor` (krug5 Б1а) | z05 |
| stab_zamer_exit_do_sbora.py | безусловный `exit 0` выше сбора | z05 |
| stab_zamer_heredoc_sbor.py | текст сбора в here-doc, не исполняется | z05 |
| stab_zamer_funkcija_sbor.py | сбор в невызываемой функции | z05 |
| stab_zamer_shell_true.py | `shell: true {0}` на шаге сбора (krug5 Б1б) | z05 |
| stab_zamer_if_vsegda_i_lozh.py | `if: ${{ always() && false }}` (krug5 Б1в) | z05 |
| stab_zamer_bez_wd.py | шаг сбора без явного working-directory при root defaults mobile (krug5 Б1г) | z05 |
| stab_zamer_env_lishnij.py | лишний ключ env (переопределение путей) | z05 |
| stab_zamer_param_narushenie.py | ns карты ведёт наружу воркспейса (`..`, env согласован — z02 молчит) | z05 |
| stab_zamer_yaml_duplikat.py | дубликат ключа env (safe_load молча берёт последний) | z05 |
| stab_zamer_lane_neprivjazan.py | ci:zamer объявляет другой dispatch | z05 |
| stab_zamer_matrica_runner_bez_stroki.py | канон-строка maestro-хука исчезла из раннера | z05 |
| stab_zamer_skript_mutirovan.py | байт скрипта замера мутирован | z04 |
| stab_zamer_sbor_bez_rezultata.py | сбор выходит 0 после echo, результата нет | z06 |
| stab_zamer_hook_bez_sbora.py | хук молчит при сигнатуре — сбора до повтора нет | z07 |
| stab_zamer_matrica_bez_porta_vtorogo.py | у ВТОРОГО child карты нет avd_port | z07 |
| stab_zamer_techet_procesom.py | sbor выбрасывает подделку-qemu с нонсом мира | b12 |

## Режимы и коды

- без флага/без `--repo` — субъект (дерево харнесса) не реализован: rc 1,
  SUBJECT_ABSENT, все 19 клеток красны поимённо;
- `--repo R` — живой продукт: до реализации обёртки красен поимённо
  (карта без матричных записей — z07 честно зелёна «детей нет»: это
  законное состояние продукта до 143 v3);
- `--stabs` — контроль + SVJAZI 37, живых стабов 0 (census:
  `ls stabs/stab_*.py \| wc -l`);
- `--oracle-tamper` — порча каждого из 9 пиннованных носителей ловится
  ORACLE_TAMPERED rc 2 ДО клеток;
- `--seed N` — тот же итог при другом порядке клеток.

## Границы честности (что мир моделирует, а что нет)

- Подделки qemu/adb-server — НАСТОЯЩИЕ процессы (live `/proc/<pid>/stat`,
  `kill -0` честны); нонс мира изолирует pgrep-мир батареи от чужих
  qemu/adb-server станции (и наоборот). Каждый порождённый PID батарея
  останавливает и дожидается; клетка b12 доказывает отсутствие живых
  подделок нонса мира ПОСЛЕ суда.
- Виртуальное время: sleep-шим тикает общий счётчик; сценарные события
  (убийство qemu с маркером signal 9, запись сигнатуры, смена adb-server,
  перезапуск qemu, wipe ns по модели 995) исполняет драйвер по виртуальному
  времени; sbor стартует после ОБРАБОТКИ всех событий; реальные секунды
  replay ≪ виртуальных.
- Исполнительные клетки применяют КАНОНИЧЕСКУЮ семантику шага
  (`shell: bash` → `bash --noprofile --norc -eo pipefail -c`, cwd —
  воркспейс): семантику фиксируют байты канона, батарея её не угадывает.
  F2 (npm-lane) в исполнительных мирах исполняется прямым argv пиннованного
  скрипта — привязка lane доказана отдельной статической проверкой z05
  (закрытый словарь lanes без eval); исполнение самого npm в песочнице
  не моделируется (honesty boundary).
- Экранный шаг субъекта не исполняется: replay проверяет обвязку вокруг
  него; соответствие самого экраного тела лекалу/замороженным канонам —
  батареи 143/147/148/995 (НЕ ЗАЩИЩАЕТ в контракте 150). Тела/порядок
  чужих шагов, needs/outputs DAG, strategy-параметры матрицы и runs-on —
  межконтрактные входы 143/163, батареей 150 повторно не замораживаются.
- boot_id/logcat НА МОМЕНТ СБОРА при offline честно помечаются
  недоступными; различительная ценность — в живых пробах таймлайна,
  предостановочном logcat-кольце и маркерах недоступности.
- RECOVERED-состояние ns моделируется по frozen 995/5: финальная попытка
  зелёная (top-level junit/report), архив диагностики упавшей попытки 1
  (`diagnostics/attempt-1/maestro.log` с сигнатурой) СОХРАНЁН — гейт судит
  текущую попытку (`--exclude-dir=diagnostics`).
- Дочерний хук/matричный раннер в батарее исполняются только в z07
  (обёртка maestro-попытки подложным maestro); полный запуск
  run-ci-screen.cjs (avdmanager/boot/flock) — вне батареи, его держит
  143 v3 (inter-contract вход, ловец — живые приёмки 7/8).

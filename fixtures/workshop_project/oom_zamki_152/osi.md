# Оси батареи oom_zamki_152 (31 клетка; блок A 12 / B 4 / C 9 / D 5 / E 1)

Форма → клетка → защита → стаб-на-защиту (строки «stab_vhod» — source.json,
Н-39: привязки в оракуле, не в прозе). Субъект — тройка носителей:
ops/server/user/dvojniki/ (13 файлов), scripts/zamok_predmeta.sh,
ops/server/user/orch-loop; пины sha256 — source.json:.nositeli (15).

| блок | клетка | вход (исполнением) | ожидание (в памяти ДО вызова) | стаб |
|---|---|---|---|---|
| A | a01-emulator | `emulator` × формы bare / bash -c / env, scope-маркер | rc 1 `ОТКАЗ: STROGO_SCOPE:` + строка журнала каждая форма | s01, s12 |
| A | a02-qemu-system-x86_64 | то же для qemu-system-x86_64 | то же | s01 |
| A | a03-gradle | gradle assembleDebug × 3 формы | то же | s01 |
| A | a04-cmake | cmake -B build × 3 формы | то же | s01 |
| A | a05-clang | clang × 3 формы | то же | s01 |
| A | a06-clang++ | clang++ × 3 формы | то же | s01 |
| A | a07-prebuild | prebuild --android × 3 формы | то же | s01 |
| A | a08-semejstva-imen | qemu-system, qemu-system-i386, qemu-system-x86_64-headless, emulator-headless (по 1 запуску) | rc 1 + журнал по каждому имени | s01 |
| A | a09-expo-run-android-prebuild | `expo run:android`, `expo prebuild` (scope) | rc 1 + журнал (токены argv) | s01, s05 |
| A | a10-expo-export-propusk | `expo export --platform web` (scope) | rc 0, pass-through исполнен (ran.tsv), отказа нет | — (негативная пара a09) |
| A | a11-rezolv-formy | абсолютный путь к двойнику; симлинк на двойника; `sh -c 'cd … && cmake'` | rc 1 + журнал (форма резолва не спасает) | s01, s02 |
| A | a12-bezobidnye | grep -r emulator README.md; cat build.gradle; git --version; echo clang; ls | rc 0, ни отказа, ни строки журнала | — |
| B | b01-nol-jivyh-propusk | вне scope (сиблинг-scope), 0 живых qemu: `emulator` | rc 0, настоящий исполнен (ran.tsv) | s04 |
| B | b02-dva-jivyh-tretij-otkaz | вне scope, 2 живые подделки qemu: 3-й запуск | rc 1 `ОТКАЗ: STROGO_EMULJATORY_LIMIT:`, подделки живы, журнал | s03 |
| B | b03-odin-jivoj-propusk | вне scope, 1 живая подделка | rc 0, настоящий исполнен (граница <2) | s04 |
| B | b04-gradle-vne-scope-propusk | вне scope: `gradle --version` | rc 0 (нативные сборки вне scope не считаются) | — |
| C | c01-pogib-avto-snjatie | замок занят holder'ом с session_exit(signal) без yield, mtime 5 мин | суд 2-го рабочего rc 0 PUSCHEM; RELEASE prichina=pogib; замок у нового | s06 |
| C | c02-pogib-osvobodit-srazu | то же (dispose, mtime 2 мин) | --osvobodit rc 0 `prichina=pogib` немедленно | s06 |
| C | c03-roditel-umer | журнал holder без якорей, родительский журнал с session_exit | суд рабочего rc 0 PUSCHEM; RELEASE pogib (по родителю) | s06 |
| C | c04-yield-prioritet | yield И session_exit | osvobodit `prichina=yield`; новый рабочий PUSCHEM (140 дословно) | s07 |
| C | c05-zhivoj-kak-ranyshe | живой holder (mtime 3 мин, без якорей) | rc 1 RABOCHIJ_ZHIV, RELEASE нет (140 дословно) | — |
| C | c06-broshen-kak-ranyshe | тишина 75 мин без якорей | rc 1 ZAMOK_BROSHEN, авто-снятия нет (ветка Е 140) | s08 |
| C | c07-uchet-pogib | погибший без снятия | `--uchet` строка holder … pogib | s06 |
| C | c08-sudja-avtor-pogib | автор погиб без yield, судья | rc 1 AVTOR_ESHCHO_RABOTAET (D10 не ослаблен) + RELEASE pogib | s06 |
| C | c09-gonka-avto-snjatija | два параллельных sudit на погибшем замке | ровно один PUSCHEM и один START (мьютекс) | s06 |
| D | d01-fakt-oom-rc143 | шов-агент exit 143, systemctl-двойник Result=oom-kill | литерал 085 `OOM: omp убит потолком памяти` в логе цикла | s09 |
| D | d02-rc137-bez-fakta | exit 137, Result=dead | литерал есть (старое правило сохранено) | — |
| D | d03-rc143-bez-fakta | exit 143, Result=dead | литерала НЕТ + есть «упала без маркера (rc=143» | s10 |
| D | d04-fakt-oom-rc137 | exit 137, Result=oom-kill | литерал есть | — |
| D | d05-net-systemctl-degradacija | systemctl-двойник отказывает, exit 143 | литерала НЕТ, цикл дошёл до «упала без маркера» | s10, s11 |
| E | e01-gigiena-mirov | после всех миров | живых подделок NONCE нет (pgrep), все группы остановлены | — |

Замеры пачки (числа из вывода прогонов): `--model` → ZELENO 31/31 rc 0;
`--model --seed 7` → ZELENO 31/31 rc 0; `--stabs` → контроль 31/31,
12 стабов пойманы, `SUBJEKT_SVJAZI 28, живых 0` rc 0; `--oracle-tamper` →
`ORACLE_TAMPER_PROVERENO nositelej=15` rc 0; без флага (дерево харнесса,
носителей 152 нет) → rc 1 `KRASNO: клеток 31, красных 23` (16 A/B
SUBJECT_ABSENT + c01/c02/c03, c07/c08/c09, d01 честно красны на
поставленных zamok/orch-loop; зелёные 8 — клетки нет-ослабления c04/c05/c06,
d02/d03/d04/d05 и гигиена e01: 140/085-семантика до реализации обязана
держаться) — зелень без реализации невозможна.

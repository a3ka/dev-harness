FAIL

СУД: repo=dev-harness; предмет=149; фаза=critic; роль=critic; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit149b; модель-факт=openai-codex/gpt-6-sol; SHA=eec7eb4737065458a0d0f82c16ba62884813b00e; предыдущий=verdicts/critic/contracts-149-v1.md (FAIL по a0d4ea5118c590a4db7e1b6dd98c1040a416bc31); исключение=нет.
OBJECT: eec7eb4737065458a0d0f82c16ba62884813b00e (architect; дельта от a0d4ea511: ровно 9 файлов — контракт и 8 файлов зоны architect `fixtures/workshop_project/gespraech_tekst_149/`). Суд исправительного круга: закрытие блоков v1 и последствия новой клетки, а не пересуд неизменённых осей.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:45 — повтор класса v1: критерий `W --repo R` (`:66`) и новая клетка (`:68`) всё ещё принимают продукт без корректной v3-пачки, чат-хоста и изменений композера. Новая клетка запрещает ровно `{}` и проверяет лишь `shablon`, `ekran` и множество `dvizhenie.ekrany`, тогда как ось a-* гоняет валидатор на собственных мини-мирах, не на продукте R. Закрывающее свойство: на R, где экранная пачка не удовлетворяет заявленной форме v3/валидатору, красная клетка --repo; реальный UI также должен быть доказуем заявленной командой либо явно отдельной обязательной командой приёмки, а не выводиться из наличия машины и канона.
ОБХОД: продукт 6240f630 с тремя парными правками рецепта, пиннованными 11 файлами и модельной машиной, но `ekran.json` = `{"shablon":3,"ekran":"gespraech-tekst","dvizhenie":{"ekrany":["GA-11","GA-12","GA-13","GA-17","GA-18","GA-19"]}}`: нет `dvizhenie` с источниками/приёмкой, `prokhodimost`, `vtoroj_profil`, чат-хоста; `W --repo /tmp/dev-harness-verify/Crit149b-mut-ekran-minimal` rc 0, 83/83. Наличие полного CI-работника не делает эту пачку корректной. Отказ на `ekran.json={}` сам по себе не закрывает причину v1.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:68 — новая клетка обещает ВТОРУЮ загрузку AVD 393, а проверка считает текст `if ! boot; then diag; exit 1; fi` независимо от того, исполняется ли он. Закрывающее свойство: при неисполнимой второй загрузке профиль 393 не считается подключённым и `W --repo R` красен (без требования единственного синтаксиса реализации).
ОБХОД: в зелёном A-дереве заменить только второй вызов на bash-no-op `: 'if ! boot; then diag; exit 1; fi'` после перенастройки на `AVD393`/`PORT393`; сканер всё равно видит три вхождения подстроки, хотя второй boot НЕ исполняется. `W --repo /tmp/dev-harness-verify/Crit149b-mut-inert-boot-2` rc 0, 83/83, `s-lekalo-instanciirovano ok`.

АРБИТР: arbiter — повтор ложной достаточности `W --repo` для реального экрана и v3-пачки (блок v1 и v2), плюс новая ложная достаточность текстового счёта второй загрузки. Маршрут после исчерпания 2/2: consultant → arbiter; если для freeze потребуется третья подпись критика, решение о дополнительном вызове принимает только владелец. Этот FAIL не даёт freeze.

Доказательства. `W` = `bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh`, cwd `/tmp/dev-harness-verify/Crit149b`, если не указано иное; ниже дословные сигнальные строки stdout и rc выполненных команд (остальные неизменённые 82 `CASE … ok` опущены).

```
$ W --repo /tmp/dev-harness-verify/Crit149b-bypass # cwd Crit149b-old, HEAD a0d4ea511; rc 0
CASE s-pachka-v-produkte ok
CASE s-mashina-v-produkte ok
CASE s-kanon-bajty ok
клеток 82, зелёных 82, красных 0; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-bypass # HEAD eec7eb473; rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: карта mobile/ci-screens.json не читается/не JSON: [Errno 2] No such file or directory: '/tmp/dev-harness-verify/Crit149b-bypass/mo; ekran.json пачки пуст (обход Crit149: {}); e2e.sh пачки не читается (серийники не потребляются); e2e.sh пачки не потребляет GESPRAECH_TEKST_SERIAL; e2e.sh пачки не потребляет GESPRAECH_TEKST_SERIAL_393; нет job e2e-gespraech-tekst в mobile.yml; output выбора e2e-gespraech-tekst отсутствует/не из шага vybor; needs агрегата android-e2e без e2e-gespraech-tekst; needs агрегата mobile-regression-signal без e2e-gespra…
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --a-derevo /tmp/dev-harness-verify/Crit147c-product /tmp/dev-harness-verify/Crit149b-green # rc 0
A-DEREVO /tmp/dev-harness-verify/Crit149b-green job=e2e-gespraech-tekst kanon=11 mashina=1 ekran.json=forma
$ W --repo /tmp/dev-harness-verify/Crit149b-green # rc 0
CASE s-lekalo-instanciirovano ok
клеток 83, зелёных 83, красных 0; режим repo seed 149
$ W --model --seed 149 # rc 0
клеток 83, зелёных 83, красных 0; режим model seed 149
$ W --model --seed 7 # rc 0
клеток 83, зелёных 83, красных 0; режим model seed 7
$ W --stabs # rc 0
STAB lekalo-obhod-kritika KRASEN s-lekalo-instanciirovano
SVJAZI 10
клеток 83, зелёных 83, красных 0; режим stabs seed 149
$ W --stabs # cwd Crit149b-propusknik, только sud_lekalo→return True; rc 1
STAB lekalo-obhod-kritika ZHIV (клетка зелена на обходе критика: ekran.json={} без проводки)
```

Все семь самостоятельных мутаций полного A-дерева (каждая в своём одноразовом продукте; команда `W --repo /tmp/dev-harness-verify/Crit149b-mut-<имя>`, не модификация контрактной зоны; сырой вывод затронутой клетки и итога):

```
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-karta-bez-joba # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: нет записи карты с job e2e-gespraech-tekst
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-bez-vyhoda # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: output выбора e2e-gespraech-tekst отсутствует/не из шага vybor
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-bez-needs # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: needs агрегата android-e2e без e2e-gespraech-tekst; needs агрегата mobile-regression-signal без e2e-gespraech-tekst
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-ekran-pust # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: ekran.json пачки пуст (обход Crit149: {})
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-lichnyj-mv # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: персональный mv пачки (вынос — общий шаг)
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-bez-393 # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: экранный шаг без второй загрузки AVD 5581
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-puti-pusto # rc 1
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: puti записи пусты (экран не выбирается по путям — блок Crit147b)
клеток 83, зелёных 82, красных 1; режим repo seed 149
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-ekran-minimal # rc 0
CASE s-lekalo-instanciirovano ok
клеток 83, зелёных 83, красных 0; режим repo seed 149
$ python3 /tmp/dev-harness-verify/Crit149b-inert-boot.py # rc 0
SECOND_BOOT_EXECUTABLE False; SCRIPT_TEXT_OCCURRENCES 3
$ W --repo /tmp/dev-harness-verify/Crit149b-mut-inert-boot-2 # rc 0
CASE s-lekalo-instanciirovano ok
клеток 83, зелёных 83, красных 0; режим repo seed 149
```

Пины/канон/границы: `sha256sum` носителя лекала = `3675182e218c467f694dc69d4ee3457900849e6717b7a80d12e8bafc80aa14dd`, равно `git show frozen/contracts/143/2:fixtures/workshop_project/mob_ci_143/model/screen-job.template.yml | sha256sum`; модель валидатора и живой `scripts/ekran_shablon.py` оба `5fd1415e40b257e5e7b97c7bf9bc8fe31e94dcea9e05c4c3ac44d68802db453b`; продуктовые носители workflow/map имеют SHA256 `6137aa571ace1147ae1a29884c98008620c3b329eebf83617b5a971d57d0405e` / `85c23e1c66e9661d1d3fc2d56dfd13e4fba1b38bbaa6b9e569acfc0fb98c09e3`, равны файлам продукта 6240f630; пины D24/канона 518d8e7b не менялись в дельте. `npm test -- --ci --runInBand gespraech-tekst` в продуктовой среде `/tmp/dev-harness-verify/Arch149kanon/mobile` (SHA файлов машины и jest-теста совпали с model/teksty зоны) — rc 0, `Tests: 10 passed, 10 total`. `W --oracle-tamper` — rc 0, `ORACLE_TAMPER_PROVERENO nositelej=84`. Безфлаговый `W` — rc 1, `клеток 83, зелёных 69, красных 14; режим koren seed 149`. `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit149b contracts/149-gespraech-tekst-chat.md` — rc 0 `OK`; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit149b contracts/149-gespraech-tekst-chat.md` — rc 0, `модель угроз: секция валидна (ЗАЩИЩАЕТ 11 буллет(ов), НЕ ЗАЩИЩАЕТ 7 буллет(ов))`; `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit149b contracts/149-gespraech-tekst-chat.md` — rc 0, `КРИТИК: дверь зелёная`. Смежные `--stabs` 118, 135, 138 — rc 0, `SVJAZI 73`, `SVJAZI 13`, `SVJAZI 53` соответственно.

`bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh --stabs` — rc 0, `SVJAZI 65` (все STAB KRASEN). Остальные три соседних регресса указаны выше.

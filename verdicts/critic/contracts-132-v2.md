accept
OBJECT=5c5ae3b2fe68ea6d82b92bc29584dc814dd75fe0
СУД: repo=dev-harness; предмет=132; фаза=контракт v2, адресная правка по арбитражу; роль=critic; вызов=единственный scoped после 2/2 FAIL и арбитража; модель-план=роль critic (Sol); сессия=Crit132c; модель-факт=openai-codex/gpt-6-sol; SHA=5c5ae3b2fe68ea6d82b92bc29584dc814dd75fe0; предыдущий=critic 132 v2 1/2 FAIL, 2/2 FAIL, verdicts/arbitration/contracts-132-v2-arbitraz.md БЛОКЕР; исключение=явное слово владельца 27.10 об одном дополнительном scoped-вызове.

Предмет — коммит HEAD клона architect; просмотрен только перечень арбитра 1–6. Автор двух новых коммитов — architect; фактическая модель критика другого семейства. По специальному заданию вердикт сохранён только в `/tmp/dev-harness-verify/Crit132c/verdicts/critic/contracts-132-v2c.md`, без commit/push.

1. **Адресность — выполнено.** `git cat-file -t 5c5ae3b2fe68ea6d82b92bc29584dc814dd75fe0` → `commit`, rc 0; `git rev-parse HEAD` → тот же SHA, rc 0. `git diff --name-only 97de28a25901a1a5557e4caac3dedaf76f5a3807..HEAD` → ровно восемь файлов: `contracts/132-ekran-shablon.md`, `fixtures/workshop_project/ekran_shablon_132/{model/ekran_shablon.py,probe.py,source.json,stubs/s39_staryj_spisok_propuskaet.py,stubs/s42_identichnost_propuskaet.py,stubs/s43_kommentarij_propuskaet.py,stubs/s44_marshrut_kommentarij_propuskaet.py}`, rc 0. `git diff frozen/contracts/132/1..HEAD -- contracts/132-ekran-shablon.md` → 59 изменённых строк (46 вставлено, 13 удалено), ханки соответствуют поимённому перечню §Замены v2 :24. `git diff e44cfa0ebfcdee4466029e1e3301e62fe7535a75..HEAD -- contracts/132-ekran-shablon.md` → только дописанный п.28 в перечне :24, rc 0. `python3 /tmp/dev-harness-verify/Crit132c/cells.py` → `kejsy prior 67 now 70 added ['istoricheskij-id-chuzhie-makety', 'marshrut-obolochka-v-kommentarii', 'prokhod-pressable-v-kommentarii'] removed [] changed ['chestnyj-ekran', 'kadry-ustarevshie', 'novyj-ekran-bez-shablona', 'staryj-ekran-bez-bloka']`; `stab_vhod prior 41 now 44 added ['s42_identichnost_propuskaet.py', 's43_kommentarij_propuskaet.py', 's44_marshrut_kommentarij_propuskaet.py'] removed [] changed []`; `new links 65`, rc 0. Изменения четырёх прежних клеток названы в :89 и :24; s39 адаптирован к `(f, piny)`.

2. **С-1 — выполнено.** Отображение в `model/ekran_shablon.py:310-357` содержит только id 135/138/116/118; `check_starost` :784-824 требует id и непустое подмножество пинов, а путь `main` :1405-1408 проверяет это до зелени. `python3 /tmp/dev-harness-verify/Crit132c/pins.py` → `first_run_ekran_135 identity first-run-ekran pins 7 equal True overlap-other {}`; `start_ekran_138 identity start-ekran pins 8 equal True overlap-other {}`; `mission_116 identity mission pins 7 equal True overlap-other {}`; `erstinformation_118 identity erstinformation pins 14 equal True overlap-other {}`; rc 0. `python3 /tmp/dev-harness-verify/Crit132c/frozen_pins.py` → `first_run_ekran_135 frozen-tag 135/1 source-bytes-equal True manifest-pins-equal True pin-count 7`; `start_ekran_138 frozen-tag 138/1 source-bytes-equal False manifest-pins-equal True pin-count 8`; `mission_116 frozen-tag 116/4 source-bytes-equal False manifest-pins-equal True pin-count 7`; `erstinformation_118 frozen-tag 118/2 source-bytes-equal False manifest-pins-equal True pin-count 14`; rc 0: сравнивались пины замороженных тегов, не принималась текущая копия source.json за независимую заморозку. Подставление исторического id, id 111 без пачки, чужих пинов — rc 1 `SHABLON_OTSVTSTVUET`; пины из настоящей пачки сестры дают зелёный контроль, `demo-vkhod` — честный новый экран с v2. При смешении хотя бы одного чужого пина `piny <= zamorozhennye` ложно; пустое множество отказывается. Дополнительная атака: заменены оба `maket_sha256` в манифесте чужих Splash макетов на настоящий пин 135, изображения не заменены; раннер 123 отказал `MAKET_PODMENEN`, так что подделка декларации пинов не обходит проверку байтов (сырой вывод ниже). Изменение исходных замороженных пинов — уже правка замороженного носителя, не подмена входа.

3. **С-2 — выполнено.** `model/ekran_shablon.py:1040-1115,1327-1358`: после первого `---`, отсечение комментариев вне кавычек, обособленные токены для всех трёх ссылок, fail-closed без разделителя. Атаки на pressable в комментариях, name, inline-комментариях, route/shot в комментариях и шапке, оба потока без разделителя красны соответствующими причинами; `quoted-buttons` и честный v2 зелены; в `kejsy` присутствует красное на pressable и на оболочку/снимок, стабы s43/s44 красны.

4. **С-3 — выполнено в актуальном обязательстве** `contracts/132-ekran-shablon.md:60,74,89,112,129,143`: `PROKHOD_NE_MAESTRO` означает отсутствие цели `.yaml` в argv; `echo <flow>` и `cat <flow>` дают rc 0 как прямо указанный остаток НЕ ЗАЩИЩАЕТ :143, а не ложное обещание статического доказательства Maestro. СОВЕТ contracts/132-ekran-shablon.md:24 — историческая запись п.18 закрытого перечня всё ещё цитирует старую формулу «no-op/echo/true — PROKHOD_NE_MAESTRO», так что буквальный grep слова `echo` даёт совпадение вне раздела остатка. В том же перечне п.25 прямо заменяет эту формулу, а действующие инвариант :74 и риск :143 однозначны; совет удалить либо пометить цитату исторической при следующей редакционной правке, не открывая новую ось и не отменяя accept.

5. **Батарея и числа — выполнено.** `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh --model` → rc 0, 70 строк `CASE ... ok`; `--stabs` → rc 0, 70/70, 65 строк `STAB ... KRASEN`, `SVJAZI 65` (сырые строки ниже). `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh` → rc 1 на реализации v1: 2 `ok` (`paket-bez-manifesta`, `staryj-ekran-bez-bloka`), 68 `KRASNO`; у честной v2-базы v1 даёт `SHABLON_NEVEREN` по ключам `prokhodimost/shablon/vtoroj_profil`, то есть красное — отсутствие нового поведения, не неподтверждённая старая ветвь. Числа :80-85, :155-161 соответствуют наблюдению и отдельному счёту source.json. `bash scripts/pre_critic.sh --repo . contracts/132-ekran-shablon.md` → rc 0, `КРИТИК: дверь зелёная`; `bash scripts/check_threat_model.sh . contracts/132-ekran-shablon.md` → rc 0, `модель угроз: секция валидна (ЗАЩИЩАЕТ 10 буллет(ов), НЕ ЗАЩИЩАЕТ 13 буллет(ов))`; `bash scripts/check_precision_gate.sh . contracts/132-ekran-shablon.md` → rc 0 `OK`; `bash scripts/check_spec_ready.sh . contracts/132-ekran-shablon.md` → rc 0 `OK` (первая попытка без аргумента корня дала rc 1 `использование`, повторено с правильным CLI); `bash scripts/check_ceilings.sh .` → rc 0 `потолки в порядке`; `bash scripts/check_provodka.sh . contracts/132-ekran-shablon.md` → rc 0 (без вывода). Поиск `\bs[0-9]{2}\b` по контракту → `No matches found`: связи — только source.json/stubs, Н-39 соблюдён.

6. **Сёстры и зона — выполнено.** `bash fixtures/workshop_project/first_run_ekran_135/red_first_run_ekran_135.sh --model` → rc 0, 17 `CASE ... ok`; `bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh --model` → rc 0, все `CASE ... ok`; `bash fixtures/workshop_project/mission_116/red_mission_116.sh --model` → rc 0, все `CASE ... ok`; `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --model` → rc 0, все `CASE ... ok`. Восемь изменённых файлов целиком внутри `ЗОНА architect` :93; чужие зоны не изменены.

7. **Вне перечня — новых осей нет.** Усиление остаточного риска `echo/cat` до обязательного артефакта Maestro или пина обёртки — вопрос владельца, НЕ блокирующая причина этого scoped-вызова.

### Сырой вывод атак

Команда `python3 /tmp/dev-harness-verify/Crit132c/attacks.py` → rc 0; каждая строка ниже — фактический rc/вывод отдельного запуска эталона над временной пачкой (stdout и диагностические причины):
```
historical-id-alias-v1: rc=1 stdout=[] reason=['PRICHINA\tSHABLON_OTSVTSTVUET\tekran first-run-ekran: пины макетов 108167d6a5cc85b7d67b48f1076492d1e1cfd9bf88f6445bf5b070656fe31eda, 4a17e3a4c3888343490f73c037688a7d6522e5fac1919126265c7414f26c976c не из замороженного манифеста этого экрана — исторический id с чужими макетами: идентичность замороженного экрана не доказана, новый экран обязан нести shablon: 2 с блоками prokhodimost и vtoroj_profil (слово владельца 2026-10-27)']
old-id-start-ekran-foreign-mockups: rc=1 stdout=[] reason=['PRICHINA\tSHABLON_OTSVTSTVUET\tekran start-ekran: пины макетов 108167d6a5cc85b7d67b48f1076492d1e1cfd9bf88f6445bf5b070656fe31eda, 4a17e3a4c3888343490f73c037688a7d6522e5fac1919126265c7414f26c976c не из замороженного манифеста этого экрана — исторический id с чужими макетами: идентичность замороженного экрана не доказана, новый экран обязан нести shablon: 2 с блоками prokhodimost и vtoroj_profil (слово владельца 2026-10-27)']
old-id-first-run-111-no-pack: rc=1 stdout=[] reason=['PRICHINA\tSHABLON_OTSVTSTVUET\tekran first-run вне перечня замороженных старых экранов (erstinformation, first-run-ekran, mission, start-ekran): новый экран обязан нести shablon: 2 с блоками prokhodimost и vtoroj_profil (слово владельца 2026-10-27)']
fresh-screen-132-v1: rc=1 stdout=[] reason=['PRICHINA\tSHABLON_OTSVTSTVUET\tekran fresh-screen-132 вне перечня замороженных старых экранов (erstinformation, first-run-ekran, mission, start-ekran): новый экран обязан нести shablon: 2 с блоками prokhodimost и vtoroj_profil (слово владельца 2026-10-27)']
honest-v2: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] reason=[]
buttons-only-in-comment: rc=1 stdout=[] reason=['PRICHINA\tPROKHOD_BEZ_PRESSABLE\tcta-demo', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tssylka-pomosh', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tdemo-sostojanie']
buttons-in-header-name: rc=1 stdout=[] reason=['PRICHINA\tPROKHOD_BEZ_PRESSABLE\tcta-demo', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tssylka-pomosh', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tdemo-sostojanie']
buttons-inline-comment: rc=1 stdout=[] reason=['PRICHINA\tPROKHOD_BEZ_PRESSABLE\tcta-demo', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tssylka-pomosh', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tdemo-sostojanie']
buttons-without-separator: rc=1 stdout=[] reason=['PRICHINA\tPROKHOD_BEZ_PRESSABLE\tcta-demo', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tssylka-pomosh', 'PRICHINA\tPROKHOD_BEZ_PRESSABLE\tdemo-sostojanie']
quoted-buttons: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] reason=[]
shell-only-in-comment: rc=1 stdout=[] reason=['PRICHINA\tMARSHRUT_BEZ_OBOLOCHKI\tмаршрут mobile/.maestro/demo-vkhod-tabshell.yaml не содержит оболочку tabshell: собранный путь не наблюдается']
shell-in-header-name: rc=1 stdout=[] reason=['PRICHINA\tMARSHRUT_BEZ_OBOLOCHKI\tмаршрут mobile/.maestro/demo-vkhod-tabshell.yaml не содержит оболочку tabshell: собранный путь не наблюдается']
shot-only-in-comment: rc=1 stdout=[] reason=['PRICHINA\tMARSHRUT_BEZ_SNIMKA\tvkhod-demo-tabshell']
route-without-separator: rc=1 stdout=[] reason=['PRICHINA\tMARSHRUT_BEZ_OBOLOCHKI\tмаршрут mobile/.maestro/demo-vkhod-tabshell.yaml не содержит оболочку tabshell: собранный путь не наблюдается', 'PRICHINA\tMARSHRUT_BEZ_SNIMKA\tvkhod-demo-tabshell']
echo-with-yaml: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] reason=[]
cat-with-yaml: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] reason=[]
```
Команда `python3 /tmp/dev-harness-verify/Crit132c/pin_spoof.py` → rc 0, сырой вывод:
```
old-id-borrowed-pin-foreign-images: rc=1 stdout=[] stderr=['PRICHINA\tMAKET_PODMENEN\tSplash dark\tsha256', 'PRICHINA\tMAKET_PODMENEN\tSplash light\tsha256']
```
Команда `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh --stabs` → rc 0; сырой вывод (70 контрольных CASE, затем 65 связей):
```
CASE chestnyj-ekran ok
CASE literal-cveta ok
CASE literal-razmera ok
CASE kadr-nizhe-poroga ok
CASE kadr-otsutstvuet ok
CASE chuzhoj-kadr ok
CASE ne-tselikom ok
CASE kljuch-bez-kataloga ok
CASE operacija-bez-speka ok
CASE scenarij-bez-snimka ok
CASE samodelnaja-sverka ok
CASE sostojanie-nevernoe ok
CASE zony-s-globom ok
CASE zony-rashodjatsja ok
CASE bez-razdela ok
CASE paket-bez-manifesta ok
CASE priemka-lozhnaja ok
CASE e2e-ne-proshla ok
CASE sverka-lozhnaya ok
CASE zamenjaet-pustoj ok
CASE ne-trogaet-pustoj ok
CASE literal-cveta-funkc ok
CASE literal-razmera-rem ok
CASE kontrakt-slishkom-dlinnyj ok
CASE literal-cveta-hwb ok
CASE literal-razmera-protsent ok
CASE literal-razmera-ch ok
CASE kadry-ustarevshie ok
CASE zhivaja-pachta-v-repo ok
CASE kontrakt-shirokij ok
CASE literal-cveta-mnogostrochnyj ok
CASE literal-razmera-nuli ok
CASE literal-cveta-funkc-nuli ok
CASE kollizija-zamenjaet ok
CASE kollizija-ne-trogaet ok
CASE literal-razmera-maska-edinicy ok
CASE sverka-poddelnyj-stdout ok
CASE sverka-podmena-imenem ok
CASE sverka-chuzhoj-manifest ok
CASE sverka-chuzhie-kadry ok
CASE sverka-chuzhoj-repo ok
CASE prokhodimost-chestnyj ok
CASE staryj-ekran-bez-bloka ok
CASE prokhodimost-otsvtstvuet ok
CASE pressable-bez-obrabotnika ok
CASE neaktivna-bez-kadra ok
CASE cel-menshe-44 ok
CASE cel-v-safe-zone ok
CASE demo-bez-metki ok
CASE demo-v-sostave ok
CASE demo-bez-otdelenija ok
CASE nazhatie-bez-izmenenija ok
CASE profil-otsvtstvuet ok
CASE profil-nizhe-minimuma ok
CASE profil-bez-insetov ok
CASE nalozenie-sloev ok
CASE zalezaet-pod-verhnij-inset ok
CASE zalezaet-pod-nizhij-inset ok
CASE pustaja-ikonka ok
CASE golyj-komponent ok
CASE odna-tema ok
CASE profil-kadr-nizhe-poroga ok
CASE novyj-ekran-bez-shablona ok
CASE prokhod-pustoj ok
CASE prokhod-bez-pressable ok
CASE poddelnaja-obolochka ok
CASE marshrut-bez-snimka ok
CASE istoricheskij-id-chuzhie-makety ok
CASE prokhod-pressable-v-kommentarii ok
CASE marshrut-obolochka-v-kommentarii ok
STAB s01_bez_literal_skana.py literal-cveta KRASEN
STAB s01_bez_literal_skana.py literal-razmera KRASEN
STAB s01_bez_literal_skana.py literal-cveta-funkc KRASEN
STAB s01_bez_literal_skana.py literal-razmera-rem KRASEN
STAB s02_sverka_doverjaet.py kadr-nizhe-poroga KRASEN
STAB s02_sverka_doverjaet.py kadr-otsutstvuet KRASEN
STAB s03_chuzhie_propuskaet.py chuzhoj-kadr KRASEN
STAB s04_tselikom_propuskaet.py ne-tselikom KRASEN
STAB s05_kljuchi_propuskaet.py kljuch-bez-kataloga KRASEN
STAB s06_operacii_propuskaet.py operacija-bez-speka KRASEN
STAB s07_scenarij_propuskaet.py scenarij-bez-snimka KRASEN
STAB s08_priemka_propuskaet.py samodelnaja-sverka KRASEN
STAB s09_alfavit_propuskaet.py sostojanie-nevernoe KRASEN
STAB s09_alfavit_propuskaet.py zony-s-globom KRASEN
STAB s10_zony_stroki_propuskaet.py zony-rashodjatsja KRASEN
STAB s11_razdely_propuskaet.py bez-razdela KRASEN
STAB s12_polnota_propuskaet.py zamenjaet-pustoj KRASEN
STAB s12_polnota_propuskaet.py ne-trogaet-pustoj KRASEN
STAB s13_priemka_ispolnenie.py e2e-ne-proshla KRASEN
STAB s13_priemka_ispolnenie.py sverka-lozhnaya KRASEN
STAB s14_objem_propuskaet.py kontrakt-slishkom-dlinnyj KRASEN
STAB s15_svezhest_propuskaet.py kadry-ustarevshie KRASEN
STAB s16_repo_ne_skaniruet.py zhivaja-pachta-v-repo KRASEN
STAB s17_literal_klass_uzkij.py literal-cveta-hwb KRASEN
STAB s17_literal_klass_uzkij.py literal-razmera-protsent KRASEN
STAB s17_literal_klass_uzkij.py literal-razmera-ch KRASEN
STAB s18_objem_tolko_stroki.py kontrakt-shirokij KRASEN
STAB s19_literal_postrochnyj_skan.py literal-cveta-mnogostrochnyj KRASEN
STAB s19_literal_postrochnyj_skan.py literal-razmera-nuli KRASEN
STAB s19_literal_postrochnyj_skan.py literal-cveta-funkc-nuli KRASEN
STAB s20_manifest_pervyj_koren.py kollizija-zamenjaet KRASEN
STAB s20_manifest_pervyj_koren.py kollizija-ne-trogaet KRASEN
STAB s21_literal_maska_edinicy.py literal-razmera-maska-edinicy KRASEN
STAB s22_sverka_imja_fragment.py sverka-poddelnyj-stdout KRASEN
STAB s23_sverka_tolko_imja.py sverka-podmena-imenem KRASEN
STAB s24_sverka_bez_svjazi.py sverka-chuzhoj-manifest KRASEN
STAB s24_sverka_bez_svjazi.py sverka-chuzhie-kadry KRASEN
STAB s24_sverka_bez_svjazi.py sverka-chuzhoj-repo KRASEN
STAB s25_bez_bloka_propuskaet.py prokhodimost-otsvtstvuet KRASEN
STAB s26_kasanie_norma_propuskaet.py cel-menshe-44 KRASEN
STAB s27_safe_zona_propuskaet.py cel-v-safe-zone KRASEN
STAB s28_demo_metki_propuskaet.py demo-bez-metki KRASEN
STAB s28_demo_metki_propuskaet.py demo-v-sostave KRASEN
STAB s28_demo_metki_propuskaet.py demo-bez-otdelenija KRASEN
STAB s29_prokhod_ne_ispolnjaet.py nazhatie-bez-izmenenija KRASEN
STAB s30_pressable_sostojanie_propuskaet.py pressable-bez-obrabotnika KRASEN
STAB s30_pressable_sostojanie_propuskaet.py neaktivna-bez-kadra KRASEN
STAB s31_blok_profilja_propuskaet.py profil-otsvtstvuet KRASEN
STAB s32_norma_profilja_propuskaet.py profil-nizhe-minimuma KRASEN
STAB s32_norma_profilja_propuskaet.py profil-bez-insetov KRASEN
STAB s33_nalozenie_propuskaet.py nalozenie-sloev KRASEN
STAB s34_insety_propuskaet.py zalezaet-pod-verhnij-inset KRASEN
STAB s34_insety_propuskaet.py zalezaet-pod-nizhij-inset KRASEN
STAB s35_ikonki_propuskaet.py pustaja-ikonka KRASEN
STAB s36_obolochka_propuskaet.py golyj-komponent KRASEN
STAB s37_temy_propuskaet.py odna-tema KRASEN
STAB s38_sverka_profilja_ne_ispolnjaet.py profil-kadr-nizhe-poroga KRASEN
STAB s39_staryj_spisok_propuskaet.py novyj-ekran-bez-shablona KRASEN
STAB s40_prokhod_flou_propuskaet.py prokhod-pustoj KRASEN
STAB s40_prokhod_flou_propuskaet.py prokhod-bez-pressable KRASEN
STAB s41_marshrut_propuskaet.py poddelnaja-obolochka KRASEN
STAB s41_marshrut_propuskaet.py marshrut-bez-snimka KRASEN
STAB s42_identichnost_propuskaet.py istoricheskij-id-chuzhie-makety KRASEN
STAB s43_kommentarij_propuskaet.py prokhod-pressable-v-kommentarii KRASEN
STAB s44_marshrut_kommentarij_propuskaet.py marshrut-obolochka-v-kommentarii KRASEN
SVJAZI 65
```

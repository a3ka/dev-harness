FAIL
OBJECT=93de66b4a2759b12d81f6f232982885944ba601c
СУД: repo=dev-harness; предмет=132; фаза=контракт v2; роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol (config/agent_models.json, critic→apex-sol); сессия=Crit132a; модель-факт=openai-codex/gpt-6-sol (workstation этого вызова); SHA=93de66b4a2759b12d81f6f232982885944ba601c; предыдущий=нет; исключение=нет

Предмет — HEAD собственного клона, `git cat-file -t 93de66b4a2759b12d81f6f232982885944ba601c` → `commit`, `git rev-parse HEAD` → тот же SHA; контракт, критерии, исполнители и ЗОНА-строки присутствуют. Коммитов и push судья НЕ делал по заданию. Это суд текста до реализации, не суд implementer.

БЛОКИРУЕТ contracts/132-ekran-shablon.md:60,74-75,80-88 — новый экран может выдать себя за старый: право не нести ОБА новых блока определяется лишь самодекларацией `shablon: 2`, а не фактом новой экранной пачки. Класс: обход применимости двух слов владельца.
ОБХОД: в свежей пачке с новым `ekran=fresh-screen-132` опустить `shablon`, `prokhodimost`, `vtoroj_profil`; эталон принимает rc 0, печатает `SHABLON fresh-screen-132 OK`, хотя для КАЖДОГО нового экрана требуются оба правила. Отдельная красная клетка «старый экран без блока» доказывает только совместимость старых, но не отличает исторический экран от нового. Закрывающее свойство: исключение должно доказываться историей frozen-пачек (или другим независимым от входной самодекларации признаком) и новый экран без блоков должен отказывать именованно, сохраняя зелень действительно замороженного старого.

БЛОКИРУЕТ contracts/132-ekran-shablon.md:74,81,110-111 — заявлен проход Maestro по ВСЕМ видимым pressable и наблюдение изменения/disabled, но критерию достаточно rc 0 произвольного скрипта `priemka.prokhod`. Класс: ложная достаточность проверки проходимости относительно прямого слова владельца. §НЕ ЗАЩИЩАЕТ прямо допускает пустой флоу, хотя это не внешний риск, а отказ названного критерия.
ОБХОД: новый экран с непроходимыми кнопками, честно заполненной статической декларацией и `mobile/prokhod.sh` из `exit 0` зелёный; не было ни Maestro, ни одного нажатия/утверждения изменения. Даже штатный честный `source.json:prokhod_skript` проверяет только существование yaml и заканчивается `exit 0`. Закрывающее свойство: красный тест должен отличать пустой/no-op проход от исполняемого прохода по каждому ВИДИМОМУ pressable с наблюдаемым результатом либо подтверждённым disabled; rc оболочки само по себе не доказательство.

БЛОКИРУЕТ contracts/132-ekran-shablon.md:75,85-88,112-113 — «ЦЕЛЫЙ экран в СОБРАННОМ пути с оболочкой, обе темы» удовлетворяется непустым словом `obolochka` и любыми свежими PNG второго манифеста без связи снимков/геометрии с реально собранным маршрутом и профилем AVD. Класс: ложная достаточность второго профиля на допустимом входе. §НЕ ЗАЩИЩАЕТ объявляет происхождение кадров и bbox остатком, но этим снимает саму проверку названного владельцем пути; не снимается волей автора контракта.
ОБХОД: `obolochka='fake-shell'`, профильный Maestro-flow состоит только из `launchApp`/`takeScreenshot` и не входит в TabShell; первый и второй наборы снабжены теми же честными PNG-носителями. Эталон возвращает rc 0 и `SHABLON demo-vkhod OK`; объявленная оболочка не проверяет маршрут. Штатный `flow_profil` тоже только `launchApp`/`takeScreenshot`, а штатная v2-база копирует PNG первого профиля побайтово во второй. Закрывающее свойство: красная клетка «снимок голого маршрута с непустой ложной оболочкой» и проверяемая связь выполненного e2e-пути/профиля/двух тем с каждым кадром; не просто непустое поле.

БЛОКИРУЕТ contracts/132-ekran-shablon.md:81-82 — прямое противоречие AGENTS.md:133-136 (правило шага 1: «Контракту ЗАПРЕЩЕНО утверждать пару „обманный стаб ↔ ветвь“; привязку ... делает тот, у кого перед глазами код»). Новый текст приёмки пишет точные пары `s25→prokhodimost-otsvtstvuet` ... `s38→profil-kadr-nizhe-poroga`; формулировка «по коду (Н-39)» не отменяет запрета самому контракту утверждать пары. `pre_critic.sh` rc 0 не меняет норму. Класс: нарушение старшей нормы.
ОБЯЗАТЕЛЬСТВО: контракт не утверждает пары стаб↔клетка, источник привязки — код/`source.json` автора батареи.
СОСТОЯНИЕ: в коммите OBJECT обе строки 81–82 содержат перечисления стрелками.
НАБЛЮДЕНИЕ: чтение строк контракта и AGENTS.md:133-136; гейт предкритика ошибочно зелён, ручной запрет действителен. Закрывающее свойство: убрать пары из контрактного текста, оставить инварианты и команды rc/матрицы; связи проверяются по коду.

СОВЕТ contracts/132-ekran-shablon.md:80 — первый критерий одновременно требует ровно 35 строк `CASE ... SHABLON_ABSENT` и называет текущий замер 62. При отсутствии субъекта probe печатает строку на каждую из 62 записей `kejsy`; устранить устаревшее «35» до заморозки, чтобы критерий не был двусмысленен. Это счётная оговорка, отдельным классом от обходов выше не блокирую.

Проверка области: `git diff --name-only HEAD~2 HEAD` → только `contracts/132-ekran-shablon.md` и `fixtures/workshop_project/ekran_shablon_132/{model/ekran_shablon.py,probe.py,source.json,stubs/s25…s38}`; вне зоны architect нет файлов. `git diff frozen/contracts/132/1 HEAD -- contracts/132-ekran-shablon.md` — ханки адресного текста v2. Из frozen source.json прежние 35/35 ожиданий и 20/20 списков стабов сохранены; из первого коммита v2 прежние 52/52 и 30/30 сохранены, изменён общий e2e-скрипт для дополнительного профиля. Текущий счёт source.json — 62 входа, 38 стабов, 57 связей. Новая клетка порога профильного кадра относится к ветви собственной сверки профиля, не отдельная ось. DAG 143 новым job/needs не меняется; реальный AVD, KVM-стоимость и настоящий iOS-рендер здесь НЕ измерялись. Сведения о переходном `--stabs`/безфлаговом CI и зоне implementer/orchestrator открыто названы в §Зоны, §ПРОВОДКА, §Сдача; само это окно не блокер.

Команды, сырые результаты и rc (из `/tmp/dev-harness-verify/Crit132a/repo`, батареи запускались по одной):
- `bash scripts/pre_critic.sh --repo . contracts/132-ekran-shablon.md` → `  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2` / `КРИТИК: дверь зелёная`, rc 0.
- `bash scripts/check_precision_gate.sh . contracts/132-ekran-shablon.md` → `OK`, rc 0.
- `bash scripts/check_spec_ready.sh . contracts/132-ekran-shablon.md` → `OK`, rc 0.
- `bash scripts/check_ceilings.sh .` → `  ok   персоны: 12 файл(ов), потолок 61440 байт` / `  ok   правила: 1 файл(ов), потолок 30720 байт` / `  ok   раздел требований: 138 черновик(ов) судится, замороженные — по тегам` / `потолки в порядке`, rc 0.
- `bash scripts/check_provodka.sh . contracts/132-ekran-shablon.md` → `(no output)`, rc 0.
- `bash scripts/check_threat_model.sh . contracts/132-ekran-shablon.md` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 10 буллет(ов), НЕ ЗАЩИЩАЕТ 13 буллет(ов))`, rc 0.
- `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh --model` → 62 строки `CASE ... ok`, rc 0; начало `CASE chestnyj-ekran ok`, конец `CASE profil-kadr-nizhe-poroga ok`.
- `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh` → 42 `CASE ... ok` и 20 `CASE ... KRASNO`, rc 1; пример `CASE prokhodimost-chestnyj KRASNO: rc=2, ожидался 0; prichiny=["PRICHINA\tSHABLON_NEVEREN\tсостав ключей != шаблон: ['prokhodimost', 'shablon', 'vtoroj_profil']"], ожидались []; stdout=[], ожидался ['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK']`; край `CASE profil-kadr-nizhe-poroga KRASNO: rc=2, ожидался 1` — это текущий v1-субъект, не дефект эталона.
- `bash fixtures/workshop_project/first_run_ekran_135/red_first_run_ekran_135.sh --model` → от `CASE chestnyj-ekran ok` до `CASE proiskhozdenie-selektor-ne-kadra ok`, rc 0.
- `bash fixtures/workshop_project/mission_116/red_mission_116.sh --model` → от `CASE chestnyj-ekran ok` до `CASE proiskhozdenie-kommentarij-mezhdu-assertom-i-snimkom ok`; затем `KADR\tF05.01 dark\t1.000\t0.600\tG\tOK` ... `KADR\tF05.V03 dark\t1.000\t0.600\tG\tOK`, rc 0.
- `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --model` → от `CASE chestnyj-ekran ok` до `CASE guard-shag ok`, rc 0.
- `bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh --model` → от `CASE chestnyj-ekran ok` до `CASE proiskhozdenie-dopusk-nositel-v-teste ok`, rc 0.

Обманные стабы, полный сырой итог их атаки: `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh --stabs` → rc 0, 62 строки `CASE ... ok` и затем:
```
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
SVJAZI 57
```

Собственные атаки на публичный CLI эталона и на семантику красного оракула: `python3 /tmp/dev-harness-verify/Crit132a/attack132.py` → rc 0, сырой вывод (каждый `subject_rc=0 mismatch!=[]` означает мутант НАЙДЕН красным тестом, а не зелёный обход; три положительных `rc=0` — реальные обходы критерия):
```
new-unmarked: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
empty-maestro: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
fake-assembled-shell: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
claimed-bbox: rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-size/cel-menshe-44: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tKASANIE_MENSHE_NORMY\\tdemo-sostojanie: vysota 18 < 44']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-safe/cel-v-safe-zone: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tKASANIE_V_SAFE_ZONE\\tdemo-sostojanie']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-demo/demo-bez-metki: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tDEMO_NE_OTMECHEN\\tdemo-sostojanie']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-profile/profil-nizhe-minimuma: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tPROFIL_NIZHE_MINIMUMA\\t390×844 < 393×852 (класс iPhone 15/16)']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-theme/odna-tema: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tODNA_TEMA\\tкадры профиля без тем: light']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-shell/golyj-komponent: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tGOLYJ_KOMPONENT\\tvtoroj_profil.obolochka: сверка голым компонентом по маршруту без оболочки не принимается']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
skip-icon/pustaja-ikonka: subject_rc=0 mismatch=['rc=0, ожидался 1', "prichiny=[], ожидались ['PRICHINA\\tPUSTAJA_IKONKA\\tikonka-kompozera-otvetit: нет ни глифа, ни доступного имени']", "stdout=['KADR\\tSplash dark\\t0.783\\t0.600\\ttagline\\tOK', 'KADR\\tSplash light\\t0.782\\t0.600\\ttagline\\tOK', 'SHABLON\\tdemo-vkhod\\tOK'], ожидался []"] stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tdemo-vkhod\tOK'] stderr=[]
```
Дополнительная атака против самодекларации: `python3 /tmp/dev-harness-verify/Crit132a/fresh132.py` → rc 0, сырое:
```
id=fresh-screen-132 shablon=None prokhodimost=None vtoroj_profil=None
rc=0 stdout=['KADR\tSplash dark\t0.783\t0.600\ttagline\tOK', 'KADR\tSplash light\t0.782\t0.600\ttagline\tOK', 'SHABLON\tfresh-screen-132\tOK'] stderr=[]
```

НЕ проверено: живой Android AVD/iOS и фактическая модель автора из его трейса (git author — architect; допуск независимости требует внешней сверки фактического трейса). Отдельно не подтверждена точная стоимость +2–3 мин KVM. Реализация v1 ожидаемо красна до порта v2; это не новый блокер. Никакого требования пересматривать frozen 116/138 этот вердикт не вводит.

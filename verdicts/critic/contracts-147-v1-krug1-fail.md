FAIL

ОБЪЕКТ: `df570cac2a42a2af58610458398e8c74867de792` (HEAD отдельного клона `wip/147/critic`; единственная дельта против `55f86846663f7c196de0963c9a33f29dd442e18b` — контракт). Суд 1/2, роль critic-sol; фактическая модель этой сессии `openai-codex/gpt-6-sol`; автор коммита `architect`. СУД: repo=dev-harness; предмет=147; фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; модель-факт=openai-codex/gpt-6-sol; SHA=df570cac2a42a2af58610458398e8c74867de792; предыдущий=нет; исключение=нет. Идентификатор сессии в доступной истории не указан.

БЛОКИРУЕТ contracts/147-gespraech-vhod-menu.md:61 — ложная достаточность критерия `W --repo R` для экранного результата и CI-проводки из строк 40, 50–51: зелёные 70/70 получены без рендера экрана, без экранного job и записи карты, даже с `ekran.json={}`. Класс причины: критерий судит наличие и байты канон-файлов, но не конформность продуктовой пачки, экранный компонент или инстанциацию лекала 143/2. Названный предфризовый диагностический PR проверяет валидатор пачки и Jest (строки 144, 196), не требует проверки согласованности job/карты/выхода/обоих агрегаторов; требование И-8 не имеет названной команды с кодом возврата. Указание «живой CI» после реализации само по себе не превращает отсутствующую задачу в обязательный шаг. Закрывающее свойство: команда приёмки или обязательный CI-шаг отказывает продукту без UI и/или без инстанцированного по 143/2 экранного job и его согласованной карты, output выбора и needs обоих агрегаторов; красная проба этого класса предъявлена до заморозки.
ОБХОД: в одноразовом клоне продукта скопировать 11 пиннованных канон-файлов и настоящую модель `menu-machine.ts`, создать `mobile/e2e-gespraech-vhod/ekran.json` одной строкой `{}`, оставить `mobile/src/features/conversation/` без UI-компонента, `.github/workflows/mobile.yml` и `mobile/ci-screens.json` без 147. После переноса уже существующего эталонного v3 в живой валидатор (запланированная реализация 146) `W --repo R` возвращает rc 0 и 70/70. Это допустимое состояние для вызова `--repo` (обычный корень продукта R), но не выполнен экран, не выполняется его e2e job, и И-8 отсутствует. Старая версия кандидата без рецепта И-8 уже имела идентичный исполняемый критерий: дельта от 55f868466 не меняла батарею.

Проверки предмета и границы: `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit147 contracts/147-gespraech-vhod-menu.md` → `OK`, rc 0; новые ЗОНА и ПЕРЕСЕЧЕНИЕ 043 признаны; `bash scripts/pre_critic.sh contracts/147-gespraech-vhod-menu.md` → `КРИТИК: дверь зелёная`, rc 0; `bash scripts/check_spec_ready.sh . contracts/147-gespraech-vhod-menu.md` → `OK`, rc 0; `bash scripts/check_ceilings.sh .` → `потолки в порядке`, rc 0; `bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 7 буллет(ов), НЕ ЗАЩИЩАЕТ 7 буллет(ов))`, rc 0. Полный `check_zones.sh` стартовал, но истёк таймаут 240 с на истории целого репо; scoped precision-гейт выше зелёный. PNG-макеты 12/12 присутствуют в пиннованной зоне; полнота нарезки GA-01/15/16, T28/T31/T35 численно, T29/T30/T33 декларацией и мок-целями, ∩ по шести переходам, `zamenjaet=null` согласуется с указанной фазой-2 и отсутствием живой пачки Start. Лекало в теге `frozen/contracts/143/2` действительно имеет SHA256 `3675182e218c467f694dc69d4ee3457900849e6717b7a80d12e8bafc80aa14dd`; пин модели v3 `5fd1415e40b257e5e7b97c7bf9bc8fe31e94dcea9e05c4c3ac44d68802db453b` равен `origin/main:scripts/ekran_shablon.py`.

Обычная батарея на OBJECT: `W` без флага rc 1, 4/70 зелёных, 66 поимённых красных; `W --model --seed 147`, `--seed 7`, `--seed 999` — каждый rc 0, 70/70; `W --oracle-tamper` rc 0, сырой вывод `ORACLE_TAMPER_PROVERENO nositelej=54`. Канон в клоне продукта `2dbdf618950ed62b05a1af98de0febd38d6967ea` после копии канон-машины и теста в одноразовую директорию: `cd mobile && npm test -- gespraech` → rc 0, сырой итог `Test Suites: 1 passed, 1 total` / `Tests: 7 passed, 7 total`. Попытка отдельного `git clone ssh://git@github.com/a3ka/Complior-mob.git` вернула `Repository not found` rc 128; независимый продуктовый клон создан `git clone --no-hardlinks /tmp/dev-harness-verify/Arch147b-kanon-pin5fd /tmp/dev-harness-verify/Crit147-product` из ранее полученного по SSH checkout с тем же SHA. Продуктовый CI на GitHub и живой эмулятор этим судом не запускались.

Атака 1 — предложенные стабы автора, неизменённый кандидат. Команда `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs`, rc 0; сырой вывод:
```
CASE a-kontrol-forma ok 
CASE a-dvizhenie-bez-otcheta ok 
CASE a-dvizhenie-ne-proshla ok 
CASE a-e2e-ne-proshla ok 
CASE a-ekran-bez-kadrov ok 
CASE a-ekran-vne-manifesta ok 
CASE a-ekrany-ne-polny-ga-01 ok 
CASE a-ekrany-ne-polny-ga-15 ok 
CASE a-ekrany-ne-polny-ga-16 ok 
CASE a-etalon-bez-pinov ok 
CASE a-etalon-lishnij ok 
CASE a-etalon-ne-hex ok 
CASE a-etalon-ne-polon ok 
CASE a-etalon-tema-otsvtstvuet ok 
CASE a-golyl-komponent ok 
CASE a-istochnik-ne-sovpadaet ok 
CASE a-istochnik-otsvtstvuet ok 
CASE a-kadr-neodnoznachen ok 
CASE a-kadr-ustarevshij ok 
CASE a-kasanie-menshe-normy ok 
CASE a-kasanie-v-safe-zone ok 
CASE a-kljuch-bez-kataloga ok 
CASE a-kontrakt-dlinnyj ok 
CASE a-literal-cveta ok 
CASE a-marshrut-bez-obolochki ok 
CASE a-marshrut-bez-snimka ok 
CASE a-nalozhenie-sloev ok 
CASE a-ne-trogaet-ne-polon ok 
CASE a-odna-tema ok 
CASE a-otchet-pustoj ok 
CASE a-otchet-s-provalami ok 
CASE a-otchet-ustarevshij ok 
CASE a-perehod-lishnij ok 
CASE a-perehod-vne-manifesta ok 
CASE a-perehody-ne-polny-t28 ok 
CASE a-perehody-ne-polny-t29 ok 
CASE a-perehody-ne-polny-t30 ok 
CASE a-perehody-ne-polny-t31 ok 
CASE a-perehody-ne-polny-t33 ok 
CASE a-perehody-ne-polny-t35 ok 
CASE a-pressable-bez-izmenenija ok 
CASE a-profil-bez-insetov ok 
CASE a-profil-nizhe-minimuma ok 
CASE a-prokhod-bez-pressable ok 
CASE a-prokhod-ne-maestro ok 
CASE a-pustaja-ikonka ok 
CASE a-razdel-otsvtstvuet ok 
CASE a-samodelnaya-sverka ok 
CASE a-scena-vne-orakula ok 
CASE a-scena-vne-perehoda ok 
CASE a-scenarij-bez-snimka ok 
CASE a-sceny-znaka-ne-polny ok 
CASE a-shablon2-s-ga ok 
CASE a-video-etalon-ne-polon ok 
CASE a-zalezaet-pod-inset ok 
CASE a-zony-rashodjatsja ok 
CASE d-menja-300 ok 
CASE d-press-long-500 ok 
CASE d-sprechen-pervym ok 
CASE d-ud-dvizhenija ok 
CASE m-plan-open-t28 ok 
CASE m-sprechen-pervym ok 
CASE m-menja-k-300 ok 
CASE m-znak-morf-250 ok 
CASE m-press-long-500 ok 
CASE m-plan-close-t31 ok 
CASE m-ud-bez-poljota ok 
CASE s-pachka-v-produkte ok статически-зелёный контроль (модель)
CASE s-mashina-v-produkte ok статически-зелёный контроль (модель)
CASE s-kanon-bajty ok статически-зелёный контроль (модель)
STAB morph-linejnyj KRASEN znak-morf-250
STAB porjadok-obratnyj KRASEN sprechen-pervym
STAB poslednjaja-310 KRASEN menja-k-300
STAB presslong-ranjshe KRASEN press-long-500
STAB shag-ne-tot KRASEN plan-open-t28
STAB ud-ignor KRASEN ud-bez-poljota
STAB zakrytie-bez-morfa KRASEN plan-close-t31
SVJAZI 7
клеток 70, зелёных 70, красных 0; режим stabs seed 147
```

Атака 2 — независимая порча ровно одного байта модели-валидатора, только в `/tmp/dev-harness-verify/Crit147-mut`. Команда `python3 -c 'from pathlib import Path; p=Path("fixtures/workshop_project/gespraech_vhod_147/model/ekran_shablon.py"); b=p.read_bytes(); assert b.startswith(b"#!/usr/bin/env python3"); p.write_bytes(b.replace(b"#!/usr/bin/env python3",b"#!/usr/bin/env pythoN3",1))' && bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model`, rc 2; сырой вывод:
```
ORACLE_TAMPERED model/ekran_shablon.py
```

Атака 3 — правдоподобный продукт без предмета, только в `/tmp/dev-harness-verify/Crit147-product` и `/tmp/dev-harness-verify/Crit147-recipe` (там отдельно перенесён v3 в `scripts/ekran_shablon.py`). Построение продукта:
```
python3 -c 'import json,hashlib,pathlib,shutil; root=pathlib.Path("/tmp/dev-harness-verify/Crit147-recipe/fixtures/workshop_project/gespraech_vhod_147"); prod=pathlib.Path("/tmp/dev-harness-verify/Crit147-product"); src=json.loads((root/"source.json").read_text()); by_hash={h:key for key,h in src["piny"]["sha"].items()}; [(lambda dest,orig: (dest.parent.mkdir(parents=True,exist_ok=True),shutil.copy2(root/orig,dest)))(prod/dest,by_hash[h]) for dest,h in src["piny"]["kanon"].items()]; p=prod/"mobile/e2e-gespraech-vhod/ekran.json"; p.write_text("{}\n"); print("kanon=11 ekran.json={} worker=absent".format(p.read_text().strip()))'
```
Точная команда запуска `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147-product`, rc 0; сырой вывод построения и прогона:
```
kanon=11 ekran.json={} worker=absent
CASE a-kontrol-forma ok 
CASE a-dvizhenie-bez-otcheta ok 
CASE a-dvizhenie-ne-proshla ok 
CASE a-e2e-ne-proshla ok 
CASE a-ekran-bez-kadrov ok 
CASE a-ekran-vne-manifesta ok 
CASE a-ekrany-ne-polny-ga-01 ok 
CASE a-ekrany-ne-polny-ga-15 ok 
CASE a-ekrany-ne-polny-ga-16 ok 
CASE a-etalon-bez-pinov ok 
CASE a-etalon-lishnij ok 
CASE a-etalon-ne-hex ok 
CASE a-etalon-ne-polon ok 
CASE a-etalon-tema-otsvtstvuet ok 
CASE a-golyl-komponent ok 
CASE a-istochnik-ne-sovpadaet ok 
CASE a-istochnik-otsvtstvuet ok 
CASE a-kadr-neodnoznachen ok 
CASE a-kadr-ustarevshij ok 
CASE a-kasanie-menshe-normy ok 
CASE a-kasanie-v-safe-zone ok 
CASE a-kljuch-bez-kataloga ok 
CASE a-kontrakt-dlinnyj ok 
CASE a-literal-cveta ok 
CASE a-marshrut-bez-obolochki ok 
CASE a-marshrut-bez-snimka ok 
CASE a-nalozhenie-sloev ok 
CASE a-ne-trogaet-ne-polon ok 
CASE a-odna-tema ok 
CASE a-otchet-pustoj ok 
CASE a-otchet-s-provalami ok 
CASE a-otchet-ustarevshij ok 
CASE a-perehod-lishnij ok 
CASE a-perehod-vne-manifesta ok 
CASE a-perehody-ne-polny-t28 ok 
CASE a-perehody-ne-polny-t29 ok 
CASE a-perehody-ne-polny-t30 ok 
CASE a-perehody-ne-polny-t31 ok 
CASE a-perehody-ne-polny-t33 ok 
CASE a-perehody-ne-polny-t35 ok 
CASE a-pressable-bez-izmenenija ok 
CASE a-profil-bez-insetov ok 
CASE a-profil-nizhe-minimuma ok 
CASE a-prokhod-bez-pressable ok 
CASE a-prokhod-ne-maestro ok 
CASE a-pustaja-ikonka ok 
CASE a-razdel-otsvtstvuet ok 
CASE a-samodelnaya-sverka ok 
CASE a-scena-vne-orakula ok 
CASE a-scena-vne-perehoda ok 
CASE a-scenarij-bez-snimka ok 
CASE a-sceny-znaka-ne-polny ok 
CASE a-shablon2-s-ga ok 
CASE a-video-etalon-ne-polon ok 
CASE a-zalezaet-pod-inset ok 
CASE a-zony-rashodjatsja ok 
CASE d-menja-300 ok 
CASE d-press-long-500 ok 
CASE d-sprechen-pervym ok 
CASE d-ud-dvizhenija ok 
CASE m-plan-open-t28 ok 
CASE m-sprechen-pervym ok 
CASE m-menja-k-300 ok 
CASE m-znak-morf-250 ok 
CASE m-press-long-500 ok 
CASE m-plan-close-t31 ok 
CASE m-ud-bez-poljota ok 
CASE s-pachka-v-produkte ok 
CASE s-mashina-v-produkte ok 
CASE s-kanon-bajty ok 
клеток 70, зелёных 70, красных 0; режим repo seed 147
```
Дополнительная прямая проверка атакованного дерева:
```
ekran: '{}\n'
has-component: False
has-job: False
has-map: False
```

Атака 4 — кандидат без лекала, разбор без подмены рабочего файла: `git show 55f86846663f7c196de0963c9a33f29dd442e18b:contracts/147-gespraech-vhod-menu.md | python3 -c 'import sys; t=sys.stdin.read(); print("old_I8=", "И-8 (CI-проводка" in t, "old_criterion_W_repo=", "W --repo R" in t)' && git diff --name-only 55f86846663f7c196de0963c9a33f29dd442e18b df570cac2a42a2af58610458398e8c74867de792 -- fixtures/workshop_project/gespraech_vhod_147`, rc 0; сырой вывод:
```
old_I8= False old_criterion_W_repo= True
```
Ловца рецепта в батарее не добавлено; самостоятельного обещания «батарея обнаруживает отсутствие текста рецепта» не найдено, поэтому это доказательство класса единственного блока выше, не отдельный блок за правку прозы.

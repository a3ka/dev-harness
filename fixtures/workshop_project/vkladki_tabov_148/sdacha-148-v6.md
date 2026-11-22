# Сдаточный лист 148 v6c (вариант Б: 85 пустых строк, независимый оракул содержания; слово владельца 22.11 ~14:35)

## Двери

- батарея-модель · bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model · 0 · 0
- построитель-детерминизм · fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/postroit.py --proverit · 0 · 0
- оракул-содержания · fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/orakul_soderzhanija.py · 0 · 0
- форма-контракта · bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md · 0 · 0
- К-02 · чисто · fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/orakul_soderzhanija.py · 0 · 0
- К-03 · чисто · вход: чужие frozen-обязательства не тронуты — frozen/contracts/148/5 не перемещается (задание), лекало 143/2 и валидатор 5fd1415e неизменны; снятие v6c — по слову владельца 22.11 ~14:35 (вариант Б), цитата дословно в «Воля владельца» · - · -
- К-04 · чисто · вход: все новые файлы в ЗОНА architect — etalony_safe_area/{postroit.py, orakul_soderzhanija.py, manifest.json, 8 PNG}, probe.py, source.json, stubs/{_orakul.py, s102-s106}, SPEC.md §3б, osi.md, contracts/148-vkladki-tabov.md, sdacha-148-v6.md; provenance — manifest.json (источники+sha, правило, диапазоны удалений, операции, инструменты) · - · -
- К-05 · чисто · вход: приёмка п. 4 — сценарий/правило с командами и rc; негатив содержания именован (ETALON_393_SODERZHANIE_UTRACHENO, JAKOR_UTRACHEN, BLOKI_SLITY, LEISTE, MASKA_NE_48, POROG_NE_0_600) · - · -
- К-06 · чисто · вход: отказы среды оракула — rc 2 ETALON_393_ISTOCHNIK (нет основы/эталона/манифеста), не красная клетка; в прогонах 22.11 не наблюдались · - · -
- К-07 · чисто · bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model · 0 · 0
- К-08 · чисто · вход: 11 новых клеток различают потерю содержания/порядок/дубль/84/86/якоря/маску/порог/v6-потерю поимённо (--model, дверь 1); матрица стабов --stabs rc 0 (SVJAZI 67, живых 0; прогон в докладе, в двери не положен — таймаут одной команды листа 300 с против ~250 с прогона) · - · -
- К-09 · чисто · вход: ветки субъекта C в source.json — kejsy 11 (etalon-393-*), stab_vhod s102-s106 (11 привязок), прогнаны --model/--stabs · - · -
- К-10 · чисто · вход: выход построителя судится целиком и НЕ построителем — оракул сворачивает непустые последовательности ПО ПИКСЕЛЯМ основы (зоны полотна 59..768), якоря называют строки (19–35, 759–771), первое расхождение — с индексом и y · - · -
- К-11 · чисто · fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/orakul_soderzhanija.py · 0 · 0
- К-12 · чисто · вход: PNG судит раннер 123 (канон) и оракул пикселями через декодер батареи (ct 2/6); самописных предикатов формата нет · - · -
- К-13 · чисто · вход: секретов в предмете нет — pre_critic secrets=0 · - · -
- К-14 · чисто · вход: честная запись зелена (etalon-393-soderzhanie rc 0 на дереве батареи), мутации красны поимённо (11 причин оракула), стабы s102-s106 пойманы (SVJAZI 67, живых 0) · - · -
- К-15 · чисто · вход: счёты в текстах == выводу — «клеток 78»/«SVJAZI 67» (двери 1–2), osi.md 78/42/67, SPEC §3б sha256 == manifest.json (построитель — единый источник таблицы); числа контракта (85, 710, 795, маски 36/48/20, 0.600) — из source.json/манифеста · - · -
- К-16 · чисто · вход: КЛАСС РИСКА обычный (закрытый перечень, основание в строке контракта); v6c добавляет только построение эталонов и клетки — поверхностей перечня нет · - · -
- К-17 · чисто · вход: находок finding не заводилось (чисел в предмете нет); красные клетки выведены из инвариантов оракула/судей, причины атрибутированы поимённо · - · -

## Дельта

- К-02 · клетка · fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/orakul_soderzhanija.py · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model · 0 · 0
- К-11 · клетка · fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/orakul_soderzhanija.py · 0 · 0

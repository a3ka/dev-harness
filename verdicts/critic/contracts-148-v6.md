accept
OBJECT=5ca75072df89a3cbb83008f79116a984620e56d3
СУД: repo=dev-harness; предмет=148; фаза=v6; роль=critic; вызов=2/2 (scoped); модель-план=не указана в задании; сессия=Crit148V6b; модель-факт=openai-codex/gpt-6.1-terra (workstation, независимый трейс не предъявлен); SHA=5ca75072df89a3cbb83008f79116a984620e56d3; предыдущий=verdicts/critic/contracts-148-v6.md FAIL 4bf0368f04; исключение=не установлено; класс риска=обычный

Вердикт относится только к OBJECT; предыдущий FAIL доступен в archive/148/critic-v6-fail-4bf0368f04. Повтор ограничен закрытием К-02/К-10/К-11 и регрессией зависимых барьеров. Автор дельты — отдельная сессия Arch148V6d, git-автор architect; назначение роли — apex-sol, фактическая модель указана по workstation, не по независимому трейсу. Запись запуска в HANDOFF, фактическую модель и счёт обязан сверить оркестратор до материализации: доступного свидетельства дописки нет, общий счёт предмета данным вызовом не установлен.

## Закрытие блока

contracts/148-vkladki-tabov.md:19,71,80 и fixtures/workshop_project/vkladki_tabov_148/SPEC.md:65: вариант Б с дословным словом владельца допускает ровно 85 пустых строк и сохраняет непустые строки 1:1. Построитель вычисляет их из основы и source.json/tokeny, без чтения эталона: `postroit.py:99-174`. Оракул читает собственный декодер из `probe.py`, геометрию из source.json и tokeny, основу из nositeli и файл эталона; построитель не импортирует (`orakul_soderzhanija.py:48-68,258-300`).

На прежних эталонах db18c3941d: `python3 .../orakul_soderzhanija.py --koren <извлечённые-старые-эталоны>` rc 1: восемь `KRASNO`, восемь `ETALON_393_SODERZHANIE_UTRACHENO`, четыре `ETALON_393_JAKOR_UTRACHEN`, `ZNACHENIJA OK`. На OBJECT тот же оракул rc 0: все восемь `OK`, `ZNACHENIJA OK`. Просмотрены GA-03 light/dark 390 и 393: логотип, профиль и Dokumente сохранены; блоки визуально отделены, полосы сверху/снизу на месте. 393×852 и полосы проверены пиксельным оракулом, не только просмотром.

Две независимые `postroit_v` в разных временных каталогах: `two builds 9 True` (8 PNG и manifest, sha256), на этой среде; `postroit.py --proverit` rc 0. Проверка диапазонов манифеста самостоятельным суммированием: 85 для каждого из 8 кадров; независимая машинная проверка самих диапазонов не заявлена, см. совет .review/2026-11-22-140.md.

## Атаки и проверки

- `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model` rc 0: `клеток 78, зелёных 78, красных 0`.
- `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --stabs` rc 0: `SVJAZI 67`; `STAB s106_sha_tavtologija.py etalon-393-v6-poterja KRASEN`; все привязки KRASEN. Ячейки по непустой строке, 84/86, порядку, дублю, логотипу, Dokumente, маске, порогу и прежней потере — `CASE ... ok`; это штатные авторские мутации, не мои.
- Собственная соседняя мутация в одноразовой копии: в GA-03 dark изменён один пиксель x=16 y=80 сохранённой строки логотипа, остальные PNG и manifest честные. `python3 .scratch-crit148v6b/attack.py`: `mutation pixel GA-03 dark y=80 x=16 rc= 1`; stdout: `ETALON GA-03 dark 393 KRASNO`, остальные семь OK, `ZNACHENIJA OK`; stderr: `ETALON_393_SODERZHANIE_UTRACHENO: GA-03 dark 393: утеряна строка основы №2 (y=21)` и `ETALON_393_JAKOR_UTRACHEN ... первая пропавшая y=21`.
- Честная эквивалентная пиксельная запись с добавленным PNG tEXt chunk: `python3 .scratch-crit148v6b/honest.py` → `equivalent PNG ancillary chunk rc= 0`, восемь `OK`, `ZNACHENIJA OK`. Это проверяет терпимость оракула к эквивалентной кодировке, не разрешает замену pinned PNG продукта.
- `bash scripts/check_sdacha.sh "$PWD" contracts/148-vkladki-tabov.md --run` rc 0: `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=3)`.
- `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` rc 0: `КРИТИК: дверь зелёная`; первая попытка не завершилась за внешний лимит 300 с, повтор с достаточным лимитом прошёл за 388 с.
- `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` rc 0 `OK`; `bash scripts/check_ids.sh` rc 0; `bash scripts/check_ceilings.sh .` rc 0; `bash scripts/check_provodka.sh --grammar "$PWD" contracts/148-vkladki-tabov.md` rc 0. Ошибочный вызов grammar без обязательных аргументов вернул rc 1 с usage, затем вызван правильно.

## Карта классов

К-01: чисто — check_sdacha --run и pre_critic rc 0, spec-ready и grammar rc 0.
К-02: чисто — слово владельца вариант Б и старый/новый прямые входы оракула выше.
К-03: чисто — замороженный 148/5 дельтой не перемещается; снятия v6 ограничены 393 и токенным модулем.
К-04: чисто — границы architect и implementer в контракте: ЗОНА architect на батарею и контракт, implementer на mobile/etalony-vkladki-393/ и пачку.
К-05: чисто — приёмка п.4 дополнена оракулом и негативами; приёмка 2–6 называет jest, гейты, Maestro/123, набор и CI.
К-06: н/п — особый отказ среды в scoped-повторе не испытывался.
К-07: чисто — --model rc 0; живые AVD не запускались.
К-08: чисто — --stabs rc 0, 67 привязок, в том числе s106; соседняя мутация выше.
К-09: чисто — новые входы etalon-393-* охвачены --model; клетки двух судей для порога, 393 и токенов в source.json.
К-10: чисто — прямые пиксельные проверки старых и новых PNG и просмотр GA-03.
К-11: чисто — раздельные построитель и пиксельный оракул; s106 KRASEN.
К-12: чисто — визуальная сверка остаётся раннеру 123; независимость производной основы — отдельный класс К-11.
К-13: н/п — секретные входы не заявлены; pre_critic secrets=0.
К-14: чисто — честный эквивалентный PNG rc 0; отдельная порча строки rc 1.
К-15: чисто — --model 78/78, --stabs SVJAZI 67, суммы диапазонов 8×85.
К-16: чисто — обычный риск: оболочка и мок-контент вне закрытого перечня; вариант Б и остаток SPEC §3б.
К-17: н/п — операций/схем архитектуры 188 в дельте нет.

FAIL
OBJECT=41efa89ddb7a87079a4ab6c506d6fc5c3aecf08c

# Суд реализации 132 ekran-shablon — микро-круг 4

## Блокер 1 — отсутствует обязательный буллет П-3 в §НЕ ЗАЩИЩАЕТ

Пункт 3 «Приёмки микро-круга» арбитража
`verdicts/arbitration/contracts-132-impl-kap.md` требует: «буллет П-3 стоит
в §НЕ ЗАЩИЩАЕТ». П-3 предписывает принять риск отдельным буллетом: подмену
модулей рядом с байт-копией раннера 123 (`sys.path[0]`, соседний `json.py`)
и вообще воспроизведение stdout образца вызовом из репо, которым владеет
судимая сторона.

В `contracts/132-ekran-shablon.md` §НЕ ЗАЩИЩАЕТ содержит восемь иных
буллетов (смысл копии, PNG, e2e, фикстуры, невалидная форма, подлинность и
свежесть кадров, нотации литералов, смысл состояний), но не содержит ни
упоминания подмены модулей, `sys.path[0]`, байт-копии раннера, ни принятия
риска воспроизведения stdout. Поиск этих наблюдаемых маркеров в контракте
дал ноль совпадений. Это точное неисполнение П-3; по абзацу 41 арбитража
оно является единственным достаточным основанием FAIL. Правка принадлежит
architect и ограничена требуемым текстовым буллетом П-3.

## Исполненные контроли закрытого перечня

Все остальные измеренные пункты приёмки зелёные:

- `python3 fixtures/workshop_project/ekran_shablon_132/probe.py --model`:
  rc 0, 41 `CASE … ok`.
- `python3 fixtures/workshop_project/ekran_shablon_132/probe.py --stabs`:
  rc 0, 41 `CASE … ok`, 38 `STAB … KRASEN`, `SVJAZI 38`. В том числе
  `s24_sverka_bez_svjazi.py` красен ровно на
  `sverka-chuzhoj-manifest`, `sverka-chuzhie-kadry` и
  `sverka-chuzhoj-repo`; `source.json` содержит 41 `kejsy`, сумму
  `stab_vhod` 38 и три связи s24.
- `python3 fixtures/workshop_project/ekran_shablon_132/probe.py`:
  rc 0, те же 41 зелёных входов.
- Прямой CLI обоих субъектов на отдельных свежих
  `probe.build_pack`/`probe.build_repo` для каждого запуска совпал по
  `(rc, stdout, stderr)`: честный относительный вызов с байт-копией
  `.harness123/kadry.json`, абсолютный манифест пачки, абсолютный путь
  раннера, симлинк раннера и байт-копия раннера дали rc 0 и по две
  одинаковые строки `KADR`; чужие `--manifest`, `--kadry` и `--repo`
  дали rc 1 с `SAMODELNAYA_SVERKA` и именем соответствующего флага.
- Регрессии прошлых кругов исполнялись батареей: маска hex проверена
  входом `literal-razmera-maska-edinicy`, идентичность раннера — входами
  `sverka-poddelnyj-stdout` и `sverka-podmena-imenem`.
- Зоны соблюдены: `git diff --name-only d6d596c11 HEAD` =
  `scripts/ekran_shablon.py`; между `c2b84fcfd` и `d6d596c11` изменены
  только файлы `fixtures/workshop_project/ekran_shablon_132/`.

Новые классы вне закрытого перечня не заявляются блокерами.

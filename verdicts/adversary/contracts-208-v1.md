accept
OBJECT=94251e24cf96b2b8bf292fbbb9c70d171c8dd69b
СУД: репо=dev-harness; предмет=208; роль=adversary; вызов=2 (scoped); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=archive/208/adversary-v1-fail-cf589c2153; класс риска=рисковый

Фактическая модель указана в системном runtime project-context; доступный `history://Adv208b` не содержит самостоятельной строки модели трейса. Сверка и дополнение записи СУД моделью из трассы — за оркестратором после завершения вызова. История `Impl208` и `Arch208g` подтверждает разных исполнителей реализации и дельты; я их работы не автор. Проверка ограничена закрытием блока, соседним классом констант, адресностью и зависимым регрессом.

## Позитивный контроль

При `TMPDIR="$PWD/.scratch-adv208b"`:

- `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .` → rc 0, `SUBJEKT 208: KLETKI 30 KRASNYH 0`.
- Та же батарея `--model` → rc 0, `MODEL 208: KLETKI 30 KRASNYH 0`; `--stabs` → rc 0, `MODEL 208: KLETKI 30 KRASNYH 0`, `STABY 208: SVJAZI 71 ZHIVYH 0`; `--sintaksis` → rc 0, `SINTAKSIS OK`.
- SHA-256 реальной двери и модели одинаков: `d79af60e82c7c698c35015f6289cf8cb3feb57e4b80a833e96930057aa588734`. Равенство модели реализации не делает её независимым оракулом.

## Закрытие блока вызова 1

`git diff d0b9565856 94251e24cf -- scripts fixtures/parsing_hygiene_battery contracts` пуст. Дельта касается только батареи 208, включая новые стабы. Взял копию st40: diff её и модели — ровно замена `"refs/remotes/origin/wip/$n/"` на `"refs/remotes/origin/wip/208/"`; реальная дверь побайтно равна модели. Поместил копию в `$TMPDIR/scripts/zamok_predmeta.sh`, затем выполнил `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo "$TMPDIR"`:

```
SUBJEKT 208: KLETKI 30 KRASNYH 2
KRASNAJA-KLETKA r24-predok-209-opublikovan-v-vetke: r24: rc 1 ≠ 0
KRASNAJA-KLETKA r25-vperjod-003-opublikovan-v-vetke: r25: rc 1 ≠ 0
RC=1
```

Отказ вместо допуска: поиск публикации в чужой ветке 208 не находит свои wip/209 и wip/003. Это адресный стаб st40; обе клетки связаны с ним автором в source.json, прогон `--stabs` выше проверил связи. Вызов 1 на той же замене получил 23/0; наблюдаемое закрытие блока — не доказательство наличия дефекта в реальной двери.

## Константы предмета в остальных местах

Для каждого опыта отдельно заменял файл двери в том же scratch-корне на соответствующий авторский стаб; команда та же `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo "$TMPDIR"`. Проверил diff каждого стаба с моделью: ровно одна изменённая строка, совпадающая с указанной заменой; кратность якоря контролирует матрица стабов. Результаты маршрутом реального `--repo`:

| адресный стаб и замена | сырой итог и причина красной клетки |
|---|---|
| st41, `kodovaja_granica`: `contracts-$n` → `contracts-208` | rc 1, `SUBJEKT 208: KLETKI 30 KRASNYH 2`; `r26` и `r27`: rc 0 ≠ 1, чужой вердиктный хвост ошибочно признан кодовой границей, учёт переписан. |
| st42, `sankcija_ucheta`: `.subjectId == $n` → `.subjectId == "208"` | rc 1, `SUBJEKT 208: KLETKI 30 KRASNYH 2`; `r28`: rc 1 ≠ 0, своя санкция 209 отвергнута; `r29`: rc 0 ≠ 1, санкция 208 ошибочно разрешает предмет 003. |
| st43, D9: `object_kandidata "$r_wt" "$sv" "$r_br"` → `object_kandidata "$r_wt" "208" "$r_br"` | rc 1, `SUBJEKT 208: KLETKI 30 KRASNYH 1`; `r30`: rc 1 ≠ 0, свой вердиктный хвост 209 не сворачивается в равный кандидат. |

Привязки st41→r26/r27, st42→r28/r29, st43→r30 — данные source.json и исполненная матрица `--stabs`, а не проза контракта (Н-39). Честные эквивалентные входы 209/003 зелёные в `--repo .` и `--model`.

По всему файлу двери поиск `208|\$n\b|\$sv`: четыре названных места — новые параметры решений D9/D11; передача `$sv` в два вызова публикации, вызов границы и вызов санкции эквивалентна подмене параметра в соответствующем helper. Имеются также `$n` в прежнем неизменяемом резолвере (строки 340/372 и рекурсия), прежнем учёте и иных механизмах; контракт явно сохраняет резолвер A2. Диагностические `$sv` не являются входом предиката. Не утверждаю, что все прежние механизмы отдельно промутированы этим scoped-вызовом.

## Регресс

- `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` → rc 0, `итог 4/4 классов закрыто`.
- `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .` → rc 0, `CHECKED 8 CASES; FAILURES 0`, шесть merge-контролей ok.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` → rc 1, `KLETKI 245 KRASNYH 12`. Те же 12, что в вызове 1: o03-peredacha_nedostoverna-once, o03-peredacha_remote-once, p02-produktovyj-object-chuzhoj, p22-povtornyj-sud, p48-override-peredacha-schema, q02-tip-verdikta-ne-novyj-object, q05-chuzhoj-predmet, q10-povtor-roli, q12-ne-predok, q20-pustoj-finalnyj-merge, s03-object-rashoditsja, s06-object-uzhe-suzhen. Это ожидаемое расхождение со старой батареей 140 при варианте А, не зелёный прогон 140.
- Законность отдельного каталога стабов: `bash scripts/check_spec_ready.sh . contracts/208-zamok-object-predok.md` → rc 0, `OK`; `bash scripts/pre_critic.sh --repo . contracts/208-zamok-object-predok.md` → rc 0, `КРИТИК: дверь зелёная`. Первый запуск pre_critic был прерван лимитом 300 секунд без финального rc; повтор с большим лимитом завершился за 280 секунд.

## Блоки

Доказанных блокирующих нарушений в объёме вызова 2 нет. Блок вызова 1 закрыт; новые предметные клетки ловят исходную мутацию и адресные соседние константы. Ни одна из четырёх предъявленных дверей не прошла батарею.

## НЕ ЗАЩИЩАЕТ

Принятые границы общего временного порядка двух труб, TOCTOU A2 и NUL повторно блоком не предъявляю согласно заданию. Остаток доверия к автору учёта, свежесть origin-view, преддверие 172 и выбор done-вердикта находятся вне этого scoped-вызова. Не повторял как блоки непредъявленные в вызове 1 исторические топологии, регистр SHA, ужесточение несудейского входа и «съеденный первый круг». SourceCanon для этого станционного предмета не объявлен.

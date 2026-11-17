accept

СУД: repo=dev-harness; предмет=193; фаза=контракт до заморозки; роль=critic; вызов=4 общий, 2-й и последний узкий дополнительный по ADR от 2026-11-17; модель-план=config/agent_models.json critic → apex-sol → @gpt-terra; сессия=Crit193V4; модель-факт=openai-codex/gpt-6.1-terra; SHA=7c2261546135301c94b8d7c05f4acc9c12487915; предыдущие=Crit193V1 FAIL ec7ceead, Crit193V2 FAIL 849a4ec4, Arb193V1 resolved b10a522b, Crit193V3 FAIL d64e79788d; исключение=ADR и санкция Cons1119 на этот OBJECT и только К-01 Crit193V3 с зависимым регрессом. `bash scripts/models_actual.sh --tsv --bind --session Crit193V4` rc 0: дважды `critic openai-codex/gpt-6.1-terra allowed Crit193V4 7c2261546135301c94b8d7c05f4acc9c12487915`. Автор ремонта Arch193Fix3: трасса `models_actual.sh --tsv --bind --session Arch193Fix3` rc 0, дважды `architect openai-codex/gpt-6.1-sol allowed Arch193Fix3 -`; это расходится с заданием, где названа zai/glm-5.3. Автор и судья — разные сессии; авторство пяти инженерных коммитов architect, судимый прежний вердикт critic. Санкция Cons1119 — `/tmp/dev-harness-verify/Cons1119/otvet.md`, модель консультанта openai-codex/gpt-6.1-sol, на данный SHA. Запись до вызова прочитана в state-HANDOFF; её фактическую сессию и модель оркестратор дополняет перед материализацией.

## Решение

Блок К-01 Crit193V3 закрыт в пределах санкции. `fixtures/workshop_project/sdacha_193/probe.py:160–163,176–185` и `stabs.tsv:34` сохраняют ровно ту же локальную замену ограничения остатком бюджета на `:`, реестр исполняет её на s22; старый скрипт-обманка удалён. Вход честной s22 даёт ожидаемый отказ; собственная и реестровая мутации на том же входе ошибочно дают успех и различаются. Честная s23 в --model зелёная. Ноль/несколько якорей и неизменённый результат дают `ORACLE_TAMPERED` rc 2, не поимку. Дельта-пакет `SDACHA.md:71–83`, счётные строки контракта и перечисленные три остатка арбитра согласованы с областью ремонта. Н-39: привязки операций к ветвям — код и stabs.tsv, не проза контракта. Блокирующих находок в узкой повестке нет.

## Карта классов

К-01: чисто — вход: локальная мутация бюджета, единственность якоря и отказ при неприменённости; `attack.py` rc 0, --stabs 24/24.
К-02: н/п — без изменений с вызова 3, источники вне санкции.
К-03: н/п — без изменений с вызова 3, чужие обязательства вне узкой дельты.
К-04: н/п — без изменений с вызова 3, повторный общий суд зон не назначен.
К-05: н/п — без изменений с вызова 3, общий пересмотр приёмки не назначен.
К-06: н/п — без изменений с вызова 3, общий пересмотр отказов среды не назначен.
К-07: чисто — вход: s22/s23 в --model; собственная и реестровая бюджетные мутации различены.
К-08: чисто — вход: четыре HEAD-подмены `head_attack.py` rc 0, s20–s26/v07–v11 в --model.
К-09: чисто — вход: индекс, рабочий файл и отсутствие пути HEAD в двух читателях, `head_attack.py` rc 0 и честные клетки --model.
К-10: н/п — без изменений с вызова 3, наблюдаемый выход вне узкой дельты.
К-11: чисто — `red_sdacha_193.sh --repo fixtures/workshop_project/sdacha_193/model` rc 1, 36/43, отсутствующие реальные ноги не достроены.
К-12: н/п — без изменений с вызова 3, новая архитектура не назначена.
К-13: н/п — секреты не предмет узкой дельты.
К-14: чисто — вход: p03/f03 и s23 зелёны в --model, --stabs различает ложные отказы ног.
К-15: чисто — вход: 43 клетки, 24 стаба, census 27/7/10/3; --model 43/43, --stabs 24/24.
К-16: н/п — без изменений с вызова 3, заявленная граница риска не менялась.
К-17: н/п — без изменений с вызова 3, архитектурный бриф/sourceCanon 188 не объявлен.

## Проверки

Использован SSH-клон `/tmp/dev-harness-verify/Crit193V4/repo`, HEAD при суде — точный OBJECT; fetch origin main и wip/193/architect. Все команды батарей и мутаций запускались с `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_AUTHOR_DATE -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u GIT_COMMITTER_DATE`. Префикс `bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh` далее сокращён до `red`:

- `red --model`: rc 0, `KLETKI=43 ZELENYE=43 KRASNYE=0`; `red` голый: rc 1, `43/4/39`; `red --repo fixtures/workshop_project/sdacha_193/model`: rc 1, `43/36/7`. Три команды исполнялись последовательно; rc каждого режима взят из строки ИТОГ самой батареи.
- `red --stabs`: rc 0, `OBMANOK=24 POIMANY=24 ZHIVYH=0`. Запущен один раз.
- Census оболочки glob/wc: `mir/*.md=27`, `mirskripty/*.sh=7`, `stabs/*.sh=10`, `model/scripts/*.sh=3`.
- Соседи: `bash fixtures/_krasnye_103.sh` вывод `ИТОГ 103: rc=0`; 191 --model итог rc 0, 14/14; 192 --model `CELLS=53 GREEN=53 RED_NEGATIVES=67/67`; 189 --model итог rc 0, 58/58; 190 --model 34/34, групповой запуск rc 0. 189 отдельно сообщает `LIVE_PREDPOSYLKA`: живая сверка валидаторов отложена из-за отсутствия установки станции; её не объявляю выполненной.
- `bash scripts/check_sdacha.sh . contracts/193-svyazka-sdatochnyj-list.md --run` rc 127: продуктовой двери до реализации нет; это предусмотренное окно, не результат проверки содержимого листа. Ранее выполненный прогон сдаточного листа по норме 192 повторить после реализации.

## Атаки

`python3 /tmp/dev-harness-verify/Crit193V4/attack.py` rc 0, сырое наблюдение:
```
anchor count 1 registry mutation ('(( ostalos < predel )) && predel="$ostalos"', ':')
193 s22-bjudzhet-poslednej-komandy ok rc=1 ОТКАЗ: строка 9: бюджет листа 1 исчерпан на команде: bash scripts/spat3.sh
honest matched= True
193 s22-bjudzhet-poslednej-komandy KRASNO rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)
own matched= False
193 s22-bjudzhet-poslednej-komandy KRASNO rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)
registry matched= False
ORACLE_TAMPERED: мутация не применена: JAKOR_NE_UNIKALEN: PATERN:BEZ-OSTATKA-BJUDZHETA
missing runner_rc= 2
ORACLE_TAMPERED: мутация не применена: JAKOR_NE_UNIKALEN: PATERN:BEZ-OSTATKA-BJUDZHETA
duplicate runner_rc= 2
ORACLE_TAMPERED: мутация не применена: TEKST_NE_IZMENEN: PATERN:BEZ-OSTATKA-BJUDZHETA
unchanged runner_rc= 2
```

`python3 /tmp/dev-harness-verify/Crit193V4/budget_mutation.py` rc 0 — прежний файл V3 с единственной правкой абсолютного пути импорта на текущий OBJECT:
```
193 s22-bjudzhet-poslednej-komandy ok rc=1 ОТКАЗ: строка 9: бюджет листа 1 исчерпан на команде: bash scripts/spat3.sh
honest matched= True
193 s22-bjudzhet-poslednej-komandy KRASNO rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)
mutation matched= False
```
Непосредственный запуск исходного `/tmp/dev-harness-verify/Crit193V3/budget_mutation.py` rc 1: его импорт указывает на уже отсутствующий клон Crit193V3. Перенаправленная копия выше исполняет те же операции против текущего кандидата.

`python3 /tmp/dev-harness-verify/Crit193V4/head_attack.py` rc 0; сырые результаты (строки диагностики клеток опущены):
```
MUTATION leaf-file
s20- matched= True
s21- matched= False
MUTATION leaf-index
s24- matched= False
s25- matched= True
s26- matched= False
MUTATION map-file
v07- matched= False
v08- matched= False
MUTATION map-index
v09- matched= False
v10- matched= False
v11- matched= False
```

## Развилки и границы

По фактической трассе модель Arch193Fix3 отличается от указанной в задании; выбор модели критика разрешён, независимость сессий соблюдена, это не изменение предмета. Объект санкции и испытуемое дерево совпадают. Не повторён полный поиск неизменённых поверхностей; код реализации не судился. Групповой запуск соседей не фиксировал отдельный shell rc 192, но её собственная сводка 53/53 показана выше. Ошибочная начальная команда `bash fixtures/workshop_project/sdacha_193/probe.sh --stabs` вернула 127 (несуществующий путь), реальная штатная батарея затем запущена один раз. Accept касается только указанного OBJECT и не заменяет последующие гейты freeze.

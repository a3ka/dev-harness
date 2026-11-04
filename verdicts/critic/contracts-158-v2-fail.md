FAIL
OBJECT=6346009d96e986c46367416200bc4c18a6cfdf0e
СУД: repo=dev-harness; предмет=158; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=2/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit158b; модель-факт=openai-codex/gpt-6-sol; предыдущий=FAIL (Crit158, cbdc7482aefc3c74736106fef8ff25c766ebce24); исключение=нет. Автор — Arch158b (GLM zai/glm-5.3): семейства различны, независимость есть. По `bash scripts/models_actual.sh --tsv --bind`: `critic\topenai-codex/gpt-6-sol\tallowed\tCrit158b\t6346009d96e986c46367416200bc4c18a6cfdf0e`; `architect\tzai/glm-5.3\tallowed\tArch158b\t-` (по две записи, fallback судьи нет). Суждён только OBJECT.

БЛОКИРУЕТ contracts/158-ekrannyj-nabor.md:50 — И-7 обещает приёмку нового экрана командой `W_набора --repo R --ekran <NNN>` с общими проверками по карте ЭТОГО экрана. Но SPEC.md:14-29,176-210,275-312,373-379 предъявляет `--ekran` только на toy-контрактах 190–194 без R и `--repo R` только на референсах ref-clean/mob-ref, синтетике и мутантных копиях без NNN. Нет клетки с одновременными `--repo R --ekran NNN`, проверяющей карту нового экрана; приёмка контракта:61-63 тоже не требует этого совместного исхода. Класс причины: отсутствие обязательного доказательства соединения двух уже проверяемых одиночных ветвей, новый класс, не повтор исправленного toy-исполнения ПОЛНОГО слоя.
ОБХОД: реализовать оба одиночных режима правильно, но совместный вызов `--repo R --ekran NNN` направлять в toy-ветвь без зонда R и возвращать rc 0 (либо отвергать сочетание rc 2). Все закреплённые клетки a01–a13/z01–z02 и f00–f33, `W --model`, `W --stabs`, `W --repo <референс>` остаются удовлетворимы, а обязательная цель нового экрана, выключенная только в R, командой И-7 не судится. СОСТОЯНИЕ: набор реализован, новый экран набора с картой NNN подключён, R содержит выключенную обязательную цель, toy и референсы зелёные. НАБЛЮДЕНИЕ: зелёная зафиксированная батарея не доказывает приёмку И-7 новых экранов. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: rc-клетка, совместно вызывающая `--repo <честная одноразовая копия R> --ekran <член набора NNN>`, наблюдает ядро по карте NNN на обоих профилях, а одна выключенная/чужая обязательная цель именно NNN даёт именованный rc 1; при ПОЛНЫЙ наблюдает также исполнение слоя NNN и вклад его красного исхода в общий rc. Конкретный способ проверки/номер клетки — выбор автора; непроверяемая или пустая ветвь не должна становиться зелёной.

Прежние причины проверены по дельте; повторов нет:
- Б1 contracts/158-ekrannyj-nabor.md:49,63, SPEC.md:205-206,341: a10 требует полную трассу команд с rc=0, a11 — rc=3 и общий rc 1, a06 — обратное переключение по трассе, st07 — пропуск слоя. Положительный/отрицательный исходы и исполнение toy-слоя теперь объявлены наблюдаемыми.
- Б2 contracts/158-ekrannyj-nabor.md:22,160,199: план до freeze коммитит владелец, не orchestrator; scripts/freeze_contract.sh:206-249 проверяет HEAD-блоб и без строки отказывает. Строки 158 в архиве OBJECT нет — это именованная предпосылка владельческого коммита, не поручение оркестратору писать вне зоны.
- Б3 contracts/158-ekrannyj-nabor.md:49,63, SPEC.md:207-208,342: a12 с маркером только в КОНТЕКСТ даёт rc 0 молча и NE_EKRAN_NABORA; a13 с маркером внутри приёмки признаёт экран; st08 ищет где угодно и расходится на a12.
- Совет первого вердикта SPEC.md:93-100: граница проверки маски 48/36 отделена от экран-уникальной сверки кадра раннером 123.

Живые команды в архиве OBJECT (`git archive` + изолированная .git с read-only alternates основного object store и восстановленными refs frozen/done/id; сырые значимые строки и коды):
```
git -C /home/harness/dev-harness cat-file -t 6346009d96e986c46367416200bc4c18a6cfdf0e
commit
[rc 0]
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh
NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена (probe.py отсутствует); спецификация — fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md
[rc 2]
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --model
NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена (probe.py отсутствует); спецификация — fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md
[rc 2]
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --stabs
NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена (probe.py отсутствует); спецификация — fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md
[rc 2]
bash scripts/pre_critic.sh --repo . contracts/158-ekrannyj-nabor.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
[rc 0]
bash scripts/check_ceilings.sh .
  ok   раздел требований: 150 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc 0]
bash scripts/check_precision_gate.sh . contracts/158-ekrannyj-nabor.md
OK
[rc 0]
bash scripts/check_threat_model.sh . contracts/158-ekrannyj-nabor.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 12 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
[rc 0]
bash scripts/check_spec_ready.sh . contracts/158-ekrannyj-nabor.md
OK
[rc 0]
bash scripts/check_provodka.sh . contracts/158-ekrannyj-nabor.md
проводка: guard не подключён: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh не вызывается в .githooks/ или .github/workflows/
[rc 1, ожидаемо до проводки]
bash scripts/check_zones.sh .
замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 43744 · проверено по зонам: 10398
[rc 0, полный прогон, не --incr]
```
Первый check_ceilings без frozen-refs архивной .git ошибочно судил старые замороженные контракты (rc 1); после восстановления refs rc 0. Первый check_zones с env-only alternates дал rc 128 без вывода: скрипт очищает переменную; после локального objects/info/alternates и восстановления frozen/done/id refs полный прогон rc 0. Это особенности изолированного архива, не дефекты кандидата.

Регрессии соседей, команды и дословные итоговые строки:
```
bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model
клеток 71, зелёных 71, красных 0; режим model seed 147
[rc 0]
bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs
SVJAZI 9
клеток 71, зелёных 71, красных 0; режим stabs seed 147
[rc 0]
bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model
клеток 44, зелёных 44, красных 0
[rc 0]
bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --stabs
SVJAZI 33
[rc 0]
bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh --model
клеток 85, зелёных 85, красных 0; режим model seed 149
[rc 0]
bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh --stabs
SVJAZI 13
клеток 85, зелёных 85, красных 0; режим stabs seed 149
[rc 0]
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
[rc 0]
```

Не проверено: собственные клетки a10–a13 и st07/st08 исполнением, мутации против них и совместный путь `--repo R --ekran NNN`: probe.py, эталона и toy-скриптов ещё нет; все три режима W честно отказывают NOT_IMPLEMENTED. Обход — логическое доказательство слабости зафиксированного перечня, не выдуманный прогон поставленного кода. Не запускались живые ref-clean/mob-ref и AVD; батареи 159 нет в OBJECT. Числовое самоописание батареи не судилось по слову владельца. Основной чекаут не менялся, origin не трогался.

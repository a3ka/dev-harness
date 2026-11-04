FAIL
OBJECT=ca194cf2405e688a060461edd46fcc8651b09cc7
СУД: repo=dev-harness; предмет=158; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=3/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit158c; модель-факт=openai-codex/gpt-6-sol; предыдущий=FAIL (Crit158b, OBJECT=6346009d96e986c46367416200bc4c18a6cfdf0e); исключение=нет. Автор — Arch158c (zai/glm-5.3): семейства различны, независимость есть. `bash scripts/models_actual.sh --tsv --bind` (скан остановлен таймаутом 30 с, нужные строки получены до таймаута): `critic\topenai-codex/gpt-6-sol\tallowed\tCrit158c\tca194cf2405e688a060461edd46fcc8651b09cc7`, `architect\tzai/glm-5.3\tallowed\tArch158c\t-` (fallback судьи не наблюдался). Судится только OBJECT.

БЛОКИРУЕТ contracts/158-ekrannyj-nabor.md:50,63; fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md:193-196,205-207,309-316 — совместный режим теперь отличает настоящий зонд на R от toy-ветви и отказа от сочетания, но критерий НЕ доказывает, что зонд выбрал карту именно запрошенного NNN. Класс причины: отсутствие различающего входа для источника карты совместного режима. Обе проверяемые пачки 195 и 196 содержат ПОБАЙТОВО ОДНУ И ТУ ЖЕ карту model/karta-ref-clean.json; все f03–f05 используют копии ref-clean и ожидают строки именно этой карты. Проверки f00/d01 судят ref-clean и mob-ref БЕЗ одновременного `--ekran NNN`; стабы st09/st10 отвергают ветвь без R или отказ от сочетания, но не ветвь «R проверен, карта NNN проигнорирована».
ОБЯЗАТЕЛЬСТВО: И-7 — `W --repo R --ekran NNN` проверяет все общие свойства по карте именно экрана NNN; экран добавляет свою карту, а не код (И-1/И-9).
СОСТОЯНИЕ: новый допустимый экран 197 приносит карту, отличающуюся от ref-clean обязательной целью; в продукте R все старые цели ref-clean исправны, новая цель выключена. Совместная ветвь всегда загружает model/karta-ref-clean.json и запускает настоящий зонд на переданном R, не читая карту пачки NNN; одиночные `--repo` и `--ekran` реализованы честно.
НАБЛЮДЕНИЕ: f03 (195) возвращает rc 0 и полную трассу, f04 (195) возвращает ожидаемый rc 1 TSEL_VYKLYUCHENA, f05 (196) — ожидаемый rc 1 POLNYJ_TREK_KRASNO с трассой и sled; фиксированная батарея зелена. Но `W --repo R --ekran 197` не проверяет новую обязательную цель и может вернуть rc 0: приёмка нового экрана ложно зелена. Это логический контрпример зафиксированному критерию, НЕ замер несуществующего probe.py.
ОБХОД: совместная ветвь реально запускает зонд на R и исполняет полный слой при 196, но использует константную карту ref-clean независимо от NNN; оба тестовых NNN намеренно имеют одну карту, поэтому фикстуры и стабы не отличают реализацию от верной.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при совместном вызове смена ТОЛЬКО карты экранной пачки NNN на отличающуюся обязательной целью меняет множество проверяемых целей и трассу; выключение цели, обязательной только по этой карте, краснит именно совместную команду. Положительный и отрицательный исходы подтверждаются командами с rc; способ реализации не предписывается.

Прежние причины проверены по дельте: v1 Б1 (ПОЛНЫЙ лишь разбирался) — a06/a10/a11 + st07 требуют положительного и отрицательного исходов слоя с трассой; v1 Б2 — строку плана до freeze заводит владелец, не orchestrator вне зоны; v1 Б3 — маркер только в приёмке, пара a12/a13 + st08; v2 Б1 (совместный вызов уходил в toy/rc 2) — f03–f05 + st09/st10 требуют зонд на R, красную в R цель и полный слой. Текущий блок — другой класс: при настоящем зонде на R не доказана идентичность карты NNN. Зоны исполнителей и пересечения, модель угроз с двумя списками, ПРОВОДКА, порядок и грамматика «Незаполненных требований» присутствуют. Числовое САМООПИСАНИЕ не судилось по слову владельца.

Замеры в одноразовом архиве именно OBJECT (локальная .git привязана read-only alternates к объектам основного репозитория, HEAD=ca194cf24, импортированы frozen/id/done-refs; основной checkout не менялся). Ниже сырые значимые строки и коды:
```
git -C /home/harness/dev-harness cat-file -t ca194cf2405e688a060461edd46fcc8651b09cc7
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
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo /tmp/dev-harness-verify/Arch147t/ref-clean --ekran 195
NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена (probe.py отсутствует); спецификация — fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md
[rc 2]
bash scripts/pre_critic.sh --repo . contracts/158-ekrannyj-nabor.md
ОТКАЗ: precision-gate красен: contracts/158-ekrannyj-nabor.md
[rc 1: первая попытка на архиве без .git]
bash scripts/check_precision_gate.sh . contracts/158-ekrannyj-nabor.md
NOT_IMPLEMENTED: precision-гейт 043: /tmp/dev-harness-verify/Crit158c/repo не репозиторий git
[rc 2: архив без .git; после привязки истории следующие результаты]
bash scripts/pre_critic.sh --repo . contracts/158-ekrannyj-nabor.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
[rc 0]
bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 150 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc 0]
bash scripts/check_precision_gate.sh . contracts/158-ekrannyj-nabor.md
OK
[rc 0]
bash scripts/check_threat_model.sh . contracts/158-ekrannyj-nabor.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 13 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
[rc 0]
bash scripts/check_spec_ready.sh . contracts/158-ekrannyj-nabor.md
OK
[rc 0]
bash scripts/check_provodka.sh . contracts/158-ekrannyj-nabor.md
проводка: guard не подключён: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh не вызывается в .githooks/ или .github/workflows/
[rc 1, ожидаемо до CI-проводки]
bash scripts/check_zones.sh .
замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 43763 · проверено по зонам: 10417
[rc 0; полный прогон, 414.24 с, не --incr]
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
клеток 44, зелёных 44, красных 0
SVJAZI 33
[rc 0 после повтора с увеличенным timeout; первая попытка timeout 180 с, без полного итога]
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

Не проверено: исполнение f03–f05, собственных негативных образцов/st09/st10 и предложенного контрпримера на поставленном probe.py — его, модели, toy-пачек и мутантов нет в OBJECT; все четыре вызова W честно отказали NOT_IMPLEMENTED. Живые ref-clean/mob-ref и AVD не запускались; 159 отсутствует в OBJECT. HANDOFF основного checkout не содержит строки `СУД:` для вызова 3/5 (проверено поиском); запись/материализация принадлежит оркестратору, основной checkout у судьи read-only. Вердикт лежит по пути задания, не коммитился в основной checkout из-за его read-only ограничения.

accept
OBJECT=538a00bbdfee2687ae8c61327dc759a488ab6fd5
СУД: repo=dev-harness; предмет=158; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=5/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit158e; модель-факт=openai-codex/gpt-6-sol; SHA=538a00bbdfee2687ae8c61327dc759a488ab6fd5; предыдущий=FAIL (Crit158d, OBJECT=21e5b1c013df9bed371104c077f2de9d22f715ed); исключение=свежая Sol-сессия судит правку Arch158e на Sol по слову владельца 2026-11-04 ~19:55 UTC, записанному до вызова в HANDOFF. Модель сессии — openai-codex/gpt-6-sol (метаданные рабочего места); оркестратор сверяет фактический трейс до материализации.

Класс предыдущего блока закрыт на уровне контракта и SPEC: contracts/158-ekrannyj-nabor.md:50,52,63; fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md:205-225,267-284,337-371,435-437. Источник входа — заявленный следующий экран по И-7/И-9 с собственной картой пачки и настоящими RN-целями в R; источник прежнего ошибочного механизма — документированный Crit158d вариант замены чтения pachki/NNN/karta.json таблицей для 195/196/197 и константной ref-clean для остальных. Теперь внешний проверяющий генерирует два свободных номера N/M и независимые X/Y/Z, карту A→B→A при том же N и неизменных R/коде/пинах; проверяет rc 0→1 TSEL_VYKLYUCHENA(Y)→0 и ТОЧНОЕ множество строк трассы на двух профилях. На N/M карта B даёт одинаковый исход, карты с 1/2/3 целями проверяются без изменения кода или числа клеток. SPEC:218-225 разделяет внешнюю генерацию и внутренний W с одним NABOR_158_TOY_ROOT, так что внутренний вызов не перезапишет изменённую карту. st11 (константа), st12 (таблица) и st13 (кеш по N) привязаны к различающим f06/f07, а не объявлены доказанными одной прозой. Прежний вариант таблицы больше не удовлетворяет f06: после перехода A→B он не видит выключенную Y и не выдаёт её строку трассы. Контроль R (действительный RN-рендер и X/Z callbacks до предъявления) и rc 2 при неисполнимых предпосылках исключают зелёный пропуск; реализованный зонд и стабы пока НЕ испытывались.

Последствия дельты: И-6 (contracts/158-ekrannyj-nabor.md:49), И-7 (:50), И-9 (:52), порядок и rc-команды приёмки (:54-68), КЛАСС РИСКА (:1), ЗОНА/ПЕРЕСЕЧЕНИЕ (:79-149), ПРОВОДКА (:162-165), два списка модели угроз (:167-191) и грамматика «Незаполненные требования» (:197-203) не ослаблены. Зоны и пересечения сопоставлены с живым `frozen/contracts/140/1^{commit}:contracts/140-odin-agent-na-predmet.md`; проверка `check_zones --incr` зелена. Повторный поиск неизменённых поверхностей не открывался; проверены только прежний класс и последствия изменения источника карты/генератора.

Сырые замеры из изолированного `git archive OBJECT` с локальной git-историей, основной checkout не менялся:
```
git -C /home/harness/dev-harness cat-file -t 538a00bbdfee2687ae8c61327dc759a488ab6fd5
commit
[rc 0]
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
модель угроз: секция валидна (ЗАЩИЩАЕТ 14 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
[rc 0]
bash scripts/check_spec_ready.sh . contracts/158-ekrannyj-nabor.md
OK
[rc 0]
bash scripts/check_provodka.sh . contracts/158-ekrannyj-nabor.md
проводка: guard не подключён: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh не вызывается в .githooks/ или .github/workflows/
[rc 1; заявленная будущая зона orchestrator до done]
bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit158e/zones-parent.cache .
incr: check_zones судит 21e5b1c0..538a00bb (1 коммит)
замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 147 · проверено по зонам: 147
[rc 0; кеш исходно содержал 21e5b1c013df9bed371104c077f2de9d22f715ed; полный исторический проход НЕ запускался]
```

Красное предъявление именно текущего OBJECT (для каждой команды ниже вывод ОДИН И ТОТ ЖЕ, не `CASE`):
```
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --model
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --stabs
bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo /tmp/dev-harness-verify/Arch147t/ref-clean --ekran 195
NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена (probe.py отсутствует); спецификация — fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md
[rc 2 КАЖДАЯ]
```
Это именованный fail-closed, НЕ доказательство зелёной модели и красных клеток f06–f08/st11–st13: probe.py, source.json и сами стабы ещё не существуют; implementer назначен в contracts/158-ekrannyj-nabor.md:197-199. Поэтому исполняемых собственных негативных образцов на батарее 158 сейчас нет. Принимается только зафиксированный контракт/спецификация, не несуществующая реализация. До работы по экранным контрактам необходимы сборка батареи и живые rc-прогоны по заявленной приёмке; этот accept их не заменяет.

Регрессии соседей (сырые итоговые строки):
```
147 --model: клеток 71, зелёных 71, красных 0; режим model seed 147 [rc 0]
147 --stabs: SVJAZI 9; клеток 71, зелёных 71, красных 0; режим stabs seed 147 [rc 0]
148 --model: клеток 44, зелёных 44, красных 0 [rc 0]
148 --stabs: клеток 44, зелёных 44, красных 0; SVJAZI 33 [rc 0]
149 --model: клеток 85, зелёных 85, красных 0; режим model seed 149 [rc 0]
149 --stabs: SVJAZI 13; клеток 85, зелёных 85, красных 0; режим stabs seed 149 [rc 0]
143 --stabs: клеток 80, зелёных 80, красных 0; стабов 62, привязок 78, непойманных 0 [rc 0]
```
Не проверено на исполняемой батарее 158: совместная ветвь N/M, f06–f08 и st11–st13; 159 отсутствует в OBJECT. Референсы не изменялись, живой эмулятор не запускался. Вердикт сохранён по пути задания, push не делался.

ПРЕДМЕТ: 093-rv2-5-oneshot-semantika
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: Рекомендуй конкретную правку семантики (Active=inactive+Result=success+свежий ExecMainExitTimestamp) с текстом, который можно передать architect/implementer как точное задание.
РЕКОМЕНДАЦИЯ: Предлагаю вариант (а): сохранить существующий Type=oneshot и проверять успешное завершение НОВОГО запуска установленной версии, а не длительную active-жизнь. Исправлять совместно install.sh, клетки 5/6, их systemctl-миры и README. Альтернатива (б), перевод orch-peak в долгоживущий процесс, меняет сам предмет и не нужна для устранения установленного несоответствия. Frozen-текст 093 буквально требует active: его корректировка требует отдельной санкции владельца и штатного v+1, а не молчаливой подмены критерия тестом.

## Живое наблюдение станции — только чтение
Исполнена команда:
`systemctl show orch-peak@ctx orch-peak@0 -p Id -p Type -p ActiveState -p SubState -p Result -p ExecMainCode -p ExecMainStatus -p ExecMainStartTimestamp -p ExecMainExitTimestamp -p ExecMainExitTimestampMonotonic -p InvocationID -p FragmentPath`
RC 0.

```text
orch-peak@ctx.service:
Type=oneshot
ActiveState=inactive
SubState=dead
Result=success
ExecMainCode=1
ExecMainStatus=0
ExecMainStartTimestamp=Mon 2026-10-12 09:30:07 UTC
ExecMainExitTimestamp=Mon 2026-10-12 09:30:07 UTC
ExecMainExitTimestampMonotonic=16374731797202
InvocationID=4469b6c0917d43a390ef18d9b021f8fc

orch-peak@0.service:
Type=oneshot
ActiveState=inactive
SubState=dead
Result=success
ExecMainCode=0
ExecMainStatus=0
ExecMainStartTimestamp=
ExecMainExitTimestamp=
ExecMainExitTimestampMonotonic=0
InvocationID=
```

Это одновременно положительный пример успешно завершившегося oneshot и отрицательный пример для предиката «inactive+success достаточно»: @0 не предъявляет ни одного завершения. Исторический успех ctx тоже не доказывает успешный запуск ПОСЛЕ новой установки.

## Что сейчас судит код
Main f559fe69 ещё несёт старый install.sh без этих подкоманд. Поэтому исследован реальный кандидат, названный ревьюером: 34c6aa6e6b31df97f87dd6662ac0a950b0e94233 (PR#83). Через git show прочитаны install.sh, README и обе актуальные клетки fixtures/ops_granica/, не ошибочно предполагаемые fixtures/ops_server/.

- install.sh:308–326, verify-start: UNIT по умолчанию orch-peak@0; только `systemctl is-active`, успех исключительно на active. Сам старт не исполняется; rc команды подавляется через `|| true`.
- install.sh:328–406, rollback: восстановление снимка, daemon-reload, restart, затем is-active и требование active. Побайтовая проверка восстановленных адресатов имеется; её надо сохранить.
- Клетка 5 вызывает только verify-start в заранее active/failed мирах. Вход install root, заявленный замороженным контрактом, не предъявляется. systemctl-шим переводит start/restart в active, а свежесть исполнения не моделирует.
- Клетка 6 выполняет v1→v2→rollback, пинует бинарь и один юнит, наблюдает reload/restart и active. Её шим также считает успешный старт долгоживущим active.
- README §«Проверка старта» и §«Откат» обещает «установлено и активно: orch-peak@0».
- В самом orch-peak диспетчер принимает warn|stop|start|check|ctx; 0 не является действием. Поэтому исправление одного предиката без замены экземпляра не завершит починку.

## Точное задание implementer/architect — после оформления нормы

1. В install.sh использовать действительный экземпляр oneshot. Предлагаемый проверочный экземпляр — orch-peak@check: существующее действие check не запускает/не гасит сессию, в отличие от start/stop/ctx. Это проверка выполнения установленного кода, НЕ доказательство, что всё закоммичено: check может успешно напечатать список несохранённого. Служебные побочные действия самого orch-peak остаются; здесь экземпляр не запускался.
2. Проверка должна относиться к текущей операции: перед запуском снять baseline ExecMainExitTimestampMonotonic и границу начала операции по монотонным часам той же загрузки; затем выполнить синхронный запуск установленного экземпляра после daemon-reload и получить свойства через systemctl show. Успех — rc запуска и чтения 0, Type=oneshot, ActiveState=inactive, SubState=dead, Result=success, ExecMainCode=1, ExecMainStatus=0, непустой ExecMainExitTimestamp, ненулевой ExitTimestampMonotonic, строго новее baseline и не раньше начала проверяемого запуска. Начало исполнения также должно относиться к текущей операции. Одного «timestamp недавно» или старого Result=success недостаточно. InvocationID можно использовать как дополнительную привязку, но не вместо доказательства завершения.
3. verify-start должен выполнять и проверять новый запуск, а не просто смотреть историческое состояние. Для install root этот результат — условие завершения установки: финальное сообщение успеха только после успешного запуска. Rollback после восстановления выполняет свой daemon-reload и новый запуск ровно в своей операции, затем тот же предикат завершения и прежнюю побайтовую проверку снимка. Не добавлять install между rollback и наблюдением.
4. Не подменять отсутствие свойств успехом; failed, ненулевой ExecMainStatus, пустой/нулевой timestamp, старый успех, ещё activating/active и ошибка systemctl должны давать именованный отказ. Не ставить RemainAfterExit=yes ради прохождения прежнего active-оракула.
5. Architect возвращает клетке 5 вход install root и строит systemctl-мир именно oneshot. Положительный сценарий — новый запуск успешно завершается inactive/success; отрицательные — запуск завершился ошибкой и «inactive/success, но timestamp не изменился/отсутствует». Клетка 6 сохраняет v1→v2→rollback без маскирующей переустановки, доказывает исполнение восстановленной версии и различает новый успех от старого. Стабы и их привязку к входам архитектор определяет по коду, не копирует из прозы задания.
6. README, шапки подкоманд и сообщения результата описывают «успешно завершён новый oneshot-запуск», а не «юнит активен». Существующие швы UNIT/SYSTEMCTL сохранить; не заводить второй конфиг этой проверки.

Критическая нормативная граница: frozen/contracts/093/1 буквально содержит active в И-6, приёмке пп.6/9 и описании клеток. Собственный diff с кандидатом пуст. Поэтому это не только исправление двух тестов: architect готовит согласованное уточнение v+1; владелец подписывает изменение frozen-нормы. Технический выбор (а) инженерный; необходимость подписи уставной правки — отдельная воля-владельца/норма. Этот ответ не выдаёт klass-подпись и не меняет маршрут записи.

## Воспроизводимое основание
Git-команды выполнены в /home/harness/dev-harness под env -i, PATH=/usr/bin, LC_ALL=C.UTF-8, GIT_CONFIG_GLOBAL/GIT_CONFIG_SYSTEM=/dev/null, GIT_OPTIONAL_LOCKS=0, core.hooksPath=/dev/null. RC самого процесса; нормализация stdout+stderr — удалены только хвостовые LF. Хэш вычислен собственным printf/sha256sum от наблюдённого вывода. Это не утверждение о прохождении полного барьера Г2.

Первый вывод — четыре блоба в порядке файлов: 055c0618bc626e8e439193adb45c6d37e0166cff; de97064cd38ff4a22e86f1ef1c3e69729cb2d961; d9bc64de0de0a25e5c7b0798e0fd38ebebb80b11; 5cf884b1d13ff294e1ab0b1ab831f90a33928e44 (каждый на своей строке). Второй вывод пуст.

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git rev-parse 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:ops/server/install.sh 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:fixtures/ops_granica/red_unit_realno_startuet.sh 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:fixtures/ops_granica/red_otkat_vozvrashhaet_rabochuju.sh 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:ops/server/README.md
RC: 0
ВЫВОД-SHA256: adb9f250a487e8ad073d3c29c6f22ba3c0a2b378bce25ee6ad30d180cc73c0bd
КОМАНДА: git diff --quiet frozen/contracts/093/1:contracts/093-granica-ispolneniya-i-postavka-ops.md 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:contracts/093-granica-ispolneniya-i-postavka-ops.md
RC: 0
ВЫВОД-SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

FAIL
OBJECT=82dcdf7c8bb006d23006eef524316e85cb315ed9
СУД: repo=dev-harness; предмет=143; фаза=реализация-перепин (фикстуры); роль=critic; вызов=1/2; модель-план=роль critic; сессия=Crit143r; модель-факт=openai-codex/gpt-6-sol; SHA=82dcdf7c8bb006d23006eef524316e85cb315ed9; предыдущий=нет; исключение=нет

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:52,115-119,133 — p01 принимает неверный исполняемый H-пин: `probe.py:984-995` выбирает ПЕРВЫЙ checkout `.harness` в задаче, а действительное содержимое одноимённого каталога после следующего checkout определяется ПОСЛЕДНИМ. Это обход исполняемого критерия И-8, не спор о формулировке.
ОБХОД: в `e2e-pilot` оставить исходный checkout 4ac99af9 и вставить после него до запуска P второй `actions/checkout@v7` `repository: a3ka/dev-harness`, `ref: 66052cdfd134ab0958421a961caef219694a54df`, `path: .harness`. P в реальной задаче возьмётся из retired rglob-пина, Maestro получит весь каталог (8 вместо 4). Судья же берёт первый ref, replay исполняет P v5 и возвращает зелёное `69/69`; y15 лишь проверяет наличие пути checkout. Закрывающее свойство: пин, измеренный p01, должен совпадать с EFFECTIVE checkout `.harness` в момент исполнения P (либо неоднозначные повторные checkout должны отвергаться); красный тест с двумя последовательными checkout одного path.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:54,100,108,206 — заявленный счёт пинов замороженной приёмки не совпадает с батареей OBJECT, как и в аналогичных verdicts/critic/contracts-118-v3-krug1-fail.md и contracts-138-v2-krug1-fail.md; слова «до freeze 995/5» относятся к отложенности p01, но приёмочное правило 4 безусловно говорит «любого из 21 пина» и перечисляет 12+9.
ОБЯЗАТЕЛЬСТВО: счётное утверждение приёмки подтверждается именно исполняемой батареей предъявленного кандидата; замороженный критерий не переопределяется молча после freeze.
СОСТОЯНИЕ: HEAD-контракт побайтно совпадает с `frozen/contracts/143/1`, а `source.json` теперь содержит 13 `piny` и 9 `chernoviki_piny` (22 вместо 21); новый P v5 действительно необходим для предписанного §Порядок п.2 перепина.
НАБЛЮДЕНИЕ: самостоятельный счёт из `source.json` дал `cells=69, stabs=33, bindings=49, pins=13+9=22, pending=[]`; порча нового 22-го пина даёт rc 2 `ORACLE_TAMPERED`. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: действительный приёмочный критерий на перепиненной батарее должен честно называть 22 пина и новое состояние p01 через санкционированное v+1/решение владельца, не правкой frozen 143/1 задним числом; либо явно санкционированное толкование «21 до перепина» при условии, что пост-перепинный счёт согласован с машиной.

СОВЕТ contracts/143-mob-ci-razdelenie.md:108 — обработка отсутствующей/битой `model/mobile/ci-screens.json` на импорте (`probe.py:583-589,1554-1557`) выходит за непосредственный перепин, но адресно восстанавливает уже заявленный ранний `ORACLE_TAMPERED`; в изолированной копии удаление карты и порча байтов дали rc 2 до клеток. Отдельного изменения предмета этим не доказано.

Проверка кандидата и атаки (все команды реально выполнены в `/tmp/dev-harness-verify/Crit143r/repo`, кроме явно абсолютных путей; печать ниже — сырой вывод):

```
$ git cat-file -t 82dcdf7c8bb006d23006eef524316e85cb315ed9
commit
[exit=0]
$ git merge-base --is-ancestor ffbbc99e7 4ac99af9fe8b02f16206b5c98bb9556556c05e74
(no output)
[exit=0]
$ git merge-base --is-ancestor 4ac99af9fe8b02f16206b5c98bb9556556c05e74 origin/main
(no output)
[exit=0]
$ git show 4ac99af9fe8b02f16206b5c98bb9556556c05e74:fixtures/workshop_project/pilot_995/maestro_probe.py | sha256sum
6639ce8c0fd6db095a2d7ff84897d5bdcb01ed59369a8b377b06c7087dbfd353  -
[exit=0]
$ sha256sum fixtures/workshop_project/mob_ci_143/nositeli/p-4ac99af9.py
6639ce8c0fd6db095a2d7ff84897d5bdcb01ed59369a8b377b06c7087dbfd353  fixtures/workshop_project/mob_ci_143/nositeli/p-4ac99af9.py
[exit=0]
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model
клеток 69, зелёных 69, красных 0
[exit=0]
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
клеток 69, зелёных 69, красных 0
стабов 33, привязок 49, непойманных 0
[exit=0]
$ python3 /tmp/dev-harness-verify/Crit143r/attack_repin.py
honest: p01=True; 
retired: p01=False; пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml', 'vkhod-117-splash-vhod.yaml'], фиксированный набор P (И-8) не исполняется; перепин на 4ac99af9fe8b02f16206b5c98bb9556556c05e74 обязателен
unknown: p01=False; пин .harness 1234567890123456789012345678901234567890 не измерен батареей: 995/5 исполнен (freeze 995/5, ленд ffbbc99e7), измеренные пины — новый 4ac99af9fe8b02f16206b5c98bb9556556c05e74 (P v5, фиксированный набор из manifest) и красный старый 66052cdfd134ab0958421a961caef219694a54df (rglob, frozen 995/4)
[exit=0]
$ python3 /tmp/dev-harness-verify/Crit143r/attack_double_checkout.py
W --repo double-checkout rc=0
stdout=клеток 69, зелёных 69, красных 0
stderr=
[exit=0]
$ python3 /tmp/dev-harness-verify/Crit143r/attack_oracle.py
new-pinned-P: rc=2, stdout='', stderr='ORACLE_TAMPERED: пин: sha256 nositeli/p-4ac99af9.py'
map-deleted: rc=2, stdout='', stderr='ORACLE_TAMPERED: пин: файла нет model/mobile/ci-screens.json'
map-invalid: rc=2, stdout='', stderr='ORACLE_TAMPERED: пин: sha256 model/mobile/ci-screens.json'
source count: cells=69, stabs=33, bindings=49, pins=13+9=22, pending=[]
[exit=0]
```

`W` без флагов отдельно дал rc 1, `клеток 69, зелёных 0, красных 69 — SUBJECT_ABSENT` и 69 поимённых красных клеток. Изменённые шесть файлов находятся внутри `ЗОНА architect: fixtures/workshop_project/mob_ci_143/`. Contract frozen 143/1 не изменён (`git diff frozen/contracts/143/1 82dcdf7c -- contracts/143-mob-ci-razdelenie.md`: пусто). Соседние батареи, продуктовый cutover и проектные гейты в этом scoped суде не запускались.

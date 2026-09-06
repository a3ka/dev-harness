accept

## Предмет пересуда

Закоммиченный предмет — HEAD `f0e1241ecc339f9815597a4c244e5dd44fbb8a3c`.
Дельта `frozen/contracts/021/1..HEAD` по `contracts/ plans/` меняет только
`contracts/021-sud-okna-svoej-vetki.md` (`+31/-17`).

## Сверка по осям

1. **Чартер.** `bash scripts/check_charter.sh .` → rc 0: 54 из 54 уставных
   изменений разрешены. Коммит `27e57db326918d456f14a4d3de9c9140bdcabd58`
   имеет `author=architect`, `committer=orchestrator`, меняет только контракт 021
   и несёт в первой колонке тела строку `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` с точным путём.
   Дельта merge `f57fa570583ed5aeba6934525222e5b6734bb3db` к первому
   родителю — только `scripts/check_zones.sh`, `scripts/lib_zones.sh`,
   `scripts/measure_parallel_windows.sh`; уставных путей нет.

2. **Не-ослабление.** Ханки против замороженного v1 не снимают предмет ветвей
   А, Б и Г и не смягчают И-1…И-6, И-8. Для меры удалены неисполнимая конверсия
   в case и scoped-ключ не её барьера; вместо них контракт прямо оставляет
   `red_mera` прямым, требует пробу слабых реализаций и живые вызовы И-7
   (`contracts/021-sud-okna-svoej-vetki.md:90-92,146-152`), а также добавляет
   обязательный CI-шаг на каждом пуше (`contracts/021-sud-okna-svoej-vetki.md:243-246`).
   Это делает проверку исполнимой и добавляет постоянно проводимую пробу, не
   создавая состояния дерева, где прежний выполнимый критерий можно обойти.

3. **Полнота снятия.** В контракте нет ни `check_zones/case_mera`, ни
   `растёт до 15`. После реализации зафиксированы 13→19: пять case И-1…И-5 и
   `case_regress`, без `case_mera` (`contracts/021-sud-okna-svoej-vetki.md:233-241`);
   scoped-набор теперь ровно И-1…И-6, И-8. Конверсия предписана только
   `red_regress`; `red_mera` остаётся прямым файлом.

4. **CI-проводка probe.** И-7 требует точный workflow-шаг
   `bash fixtures/check_zones/probe_slabye_realizacii.sh` с rc 0 на каждом пуше,
   и эта же команда записана пунктом приёмки (`contracts/021-sud-okna-svoej-vetki.md:149-152,243-246`).
   В `config/ci_parity_exceptions.txt` исключения для probe нет. Тем самым
   правило 6 проверяется штатным механизмом паритета: точное значение команды
   из `package.json` должно совпасть с `run:` workflow.

5. **Зоны.** Строка
   `ЗОНА implementer: ... .github/workflows/ci.yml package.json` содержит оба
   точных пути (`contracts/021-sud-okna-svoej-vetki.md:177-179`), а не помещает
   их в `РАБОТА НЕ РАЗДАЁТСЯ`. Граница ограничена только проводкой И-7 и прямо
   запрещает иные правки CI (`contracts/021-sud-okna-svoej-vetki.md:181-187`).
   Среди действующих окон конфликтующей раздачи этих путей нет.

6. **Исполнимость изменённых команд.** Все пути, введённые или заменённые v2,
   существуют на HEAD. Наблюдённые rc: `red_mera_parallelnosti_okon.sh` — 0;
   `red_regress_posledovatel_naja_istorija.sh` — 0;
   `probe_slabye_realizacii.sh` — 0; `_schet_fixtur.sh` — 0; полный scope
   `check_zones` — 0 (13/13); живой `check_zones.sh .` — 0. Scoped-вызова
   `check_zones/case_mera` в контракте нет.

## Контрольные прогоны

- `git diff frozen/contracts/021/1 HEAD --stat -- contracts/ plans/` → один файл,
  `contracts/021-sud-okna-svoej-vetki.md`, `+31/-17`;
- `bash scripts/check_charter.sh .` → rc 0, 54/54;
- `bash scripts/verify_antiplacebo.sh . --scope check_zones` → rc 0, 13/13;
- `bash fixtures/check_zones/probe_slabye_realizacii.sh` → rc 0: пойманы
  «всегда-0», «пусто-зелёная», «теряет merge-принесённые»,
  «лексикографическая»; честная форма прошла;
- `bash fixtures/check_zones/_schet_fixtur.sh` → rc 0;
- `bash scripts/check_zones.sh .` → rc 0.

Советов нет.

Блокеров и обходов нет.

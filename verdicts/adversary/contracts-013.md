accept

Адверсарный круг по реализации контракта 013 (HEAD `1a74eb4`; заморозка `frozen/contracts/013/3`) завершён: собственные обманные стабы построены только в `/tmp` как копии барьеров. Каждый был намеренно неверен ровно в проверяемом правиле и был пойман соответствующей пробой (сама проба вернула `rc=1`). На живом HEAD положительные контроли и приёмка зелёные.

## Стабы и красные пробы

1. `filter_verdicts_only` — `check_zones.sh` исключает только `verdicts/critic/`, но судит `verdicts/adversary/`, `verdicts/review/` и `verdicts/arbitration/`.
   Команда: `bash /tmp/adv013-stubs.sh` (копия `/tmp/adv013-stubs.y2kMIA/filter_verdicts_only/scripts/check_zones.sh`, затем `ADV_S=... bash .../probe_protsessnye_vne_suda.sh`). Результат: `STUB filter_verdicts_only rc=1`; проба назвала красными процессные ветви вне `critic`.
2. `summary_deduplicated` — сводный хвост заменён на `sort -u`, поэтому повтор `HANDOFF.md` исчезает (и порядок подменяется сортировкой).
   Команда: `bash /tmp/adv013-stubs.sh` с `probe_svod_protsessnyh.sh`. Результат: `STUB summary_deduplicated rc=1`; проба поймала расходящиеся последовательность и повтор.
3. `summary_per_commit` — исключения записываются максимум один раз на коммит вместо одной записи на файл.
   Команда: `bash /tmp/adv013-stubs.sh` с `probe_svod_protsessnyh.sh`. Результат: `STUB summary_per_commit rc=1`; проба поймала отсутствие второго процессного файла в чистой и смешанной парах.
4. `mixed_commit_ignored` — любой коммит с процессным файлом целиком выводится из суда; его предметная половина не проверяется.
   Команда: `bash /tmp/adv013-stubs.sh` с `probe_protsessnye_vne_suda.sh`. Результат: `STUB mixed_commit_ignored rc=1`; на смешанной ветви барьер ложно вернул `rc=0` вместо ожидаемого `1`.
5. `am_commit_counter` (Р2) — число кругов заменено числом коммитов, имеющих A/M в глобе.
   Команда: `bash /tmp/adv013-r2-stub.sh`. Результат: `STUB am_commit_counter rc=1`; `probe_012_dva_kruga.sh` поймала ложный кап во второй точке (`4` вместо двух кругов).
6. `any_r_is_event` — `R100` ошибочно даёт событие назначения.
   Команда: `bash /tmp/adv013-stubs.sh` с `probe_grammatika_sobytij.sh`. Результат: `STUB any_r_is_event rc=1`; ветвь R100 получила ложный третий круг и отказ капа.
7. `unknown_class_dropped` — неизвестный первый класс не добавляется в таймлайн.
   Команда: `bash /tmp/adv013-stubs.sh` с `probe_grammatika_sobytij.sh`. Результат: `STUB unknown_class_dropped rc=1`; ветвь «МУСОР» ложно заморозилась с `rc=0` вместо `1`.
8. `no_cr_trim_normalization` — из реконструкции таймлайна убраны CR и trim-нормировка первой строки.
   Команда: `ADV_S=/tmp/adv013-stubs.y2kMIA/no_cr_trim_normalization/scripts bash /tmp/adv013-stubs.y2kMIA/no_cr_trim_normalization/fixtures/freeze_contract/probe_grammatika_sobytij.sh; test $? -eq 1`. Результат: `rc=1`; ветвь CR/trim получила ложный кап из трёх кругов вместо ожидаемого `rc=0`.

Итог по стабам: 8/8 пойманы; ложнозелёных стабов нет.

## Положительные контроли и HEAD

Все четыре предметные пробы на живом HEAD вернули `rc=0`:

```sh
bash fixtures/check_zones/probe_protsessnye_vne_suda.sh
bash fixtures/check_zones/probe_svod_protsessnyh.sh
bash fixtures/freeze_contract/probe_012_dva_kruga.sh
bash fixtures/freeze_contract/probe_grammatika_sobytij.sh
```

Scoped-приёмка также зелёная:

```text
bash scripts/verify_antiplacebo.sh --scope check_zones
барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13

bash scripts/verify_antiplacebo.sh --scope freeze_contract
барьеров: 1 · фикстур: 14 · предъявлено красным повторным прогоном: 14
```

Остальные обязательные прогоны:

```text
bash scripts/check_contract_frozen.sh  # rc=0; заморожено: 14, включая contracts/013 v3
bash scripts/check_zones.sh .          # rc=0
```

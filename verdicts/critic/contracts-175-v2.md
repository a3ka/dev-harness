accept

СУД: repo=dev-harness; предмет=175; фаза=контракт v2, адресный v+1; роль=critic; вызов=четвёртый по предмету, второй сверх базового, узкий исправительный; модель-план=critic → apex-sol → @gpt-terra; сессия=Crit175V3; модель-факт=openai-codex/gpt-6.1-terra; SHA=af88158f1016274ac1cfb4ff9e61f9781d2efd58; предыдущий=Crit175V2 FAIL b161a130; исключение=ADR 2026-11-17 и санкция консультанта Cons1117 для точного OBJECT. `bash scripts/models_actual.sh --tsv --bind --session Crit175V3` rc 0: `critic openai-codex/gpt-6.1-terra allowed Crit175V3 af88158f1016274ac1cfb4ff9e61f9781d2efd58`. Предварительная СУД-запись есть в HANDOFF state-WT. Консультант по трассе — sol, автор Arch175Fix1 — glm; судья не автор.

## Узкий результат

Три прежних блока закрыты на объекте; новых блоков или советов в назначенной области нет. Дельта: отдельные миры прямого и вложенного расположения, замороженные часы и граница ±1 с, канонизация путей и четыре честных контроля. `contracts/175-tablo-bez-demo.md:25,40-42` фиксируют инварианты и rc-команды; привязка стабов к ветвям — код `probe.py`, не контрактная проза (Н-39). Полный новый поиск не проводился.

## Собственные атаки

Команда `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL python3 /tmp/dev-harness-verify/Crit175V3/attack.py` rc 0. Мутации повторяют предыдущие: из `honest_v2` убирается по одному из двух glob, `>=` заменяется на `>`, либо поиск заменяется честным glob полного пути; каждый вариант исполняется на всех 26 мирах. Сырой вывод:
```
direct_only ok 25 out_of 26 red ['mob_tolko_vlozhennyj_zhurnal']
nested_only ok 25 out_of 26 red ['mob_tolko_prjamoj_zhurnal']
strict ok 25 out_of 26 red ['mob_granica_okna']
equivalent_fullpath ok 26 out_of 26 red []
```
Проверено по коду: `vfiles` разносит расположения; path_match не пересекает `/`; один `FROZEN_NOW` задаёт субъекту и генератору время; стабы адресуют оба glob, строгую и расширенную границы. Свои мутации предыдущего вердикта стали адресными стабами. Честные `ctl-glob`, `ctl-fullpath`, `ctl-find`, `ctl-walk` проходят по 26/26.

## Проверки

Без ambient GIT_AUTHOR_NAME/GIT_AUTHOR_EMAIL/GIT_COMMITTER_NAME/GIT_COMMITTER_EMAIL: `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh` и с `--repo .` rc 1, 21 зелёная и 5 красных (оба живых PR, оба отдельных расположения, включённая граница), ожидаемо до реализации. `--model` rc 0: четыре контроля по 26/26. `--stabs` rc 0: 26 caught, 0 ZHIV, включая strogaja_granica, okno_shire и обе операции glob.

Те же очищенные переменные: `bash scripts/pre_critic.sh --repo . contracts/175-tablo-bez-demo.md`, `bash scripts/check_spec_ready.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_precision_gate.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_threat_model.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_ceilings.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_charter.sh . contracts/175-tablo-bez-demo.md` — все rc 0. Charter подтвердил разрешение в af88158f.

Зависимый регресс, те же очищенные переменные: `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --model` rc 0; `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model` rc 0; `bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast` rc 0, четыре клетки зелёные.

Не проверялись неизменённые поверхности вне трёх прежних блоков и зависимого регресса; accept относится только к указанному OBJECT и санкционированной повестке, не к реализации и не к будущей семантической дельте.

FAIL

OBJECT=614b013bdef9152257029e5dab515b671d0e8934
СУД: repo=dev-harness; предмет=095; фаза=контракт v2 до заморозки; роль=critic; вызов=один адресный узкий по слову владельца 2026-11-18 ~18:10 UTC, батч №3 №5; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit095V5; модель-факт=openai-codex/gpt-6.1-terra allowed; SHA=614b013bdef9152257029e5dab515b671d0e8934; предыдущий=Crit095V4 FAIL, 70f9a6abcf; исключение=слово владельца, без нового полного суда и следующего автоматического вызова.

## Блок

БЛОКИРУЕТ contracts/095-profil-i-vhod-agenta-contextpack.md:163 — адресная дельта расширяет батарею, но оставляет действующий критерий приёмки и сопряжённые счётные утверждения несовместимыми с этой батареей.
ОБЯЗАТЕЛЬСТВО: п.1 требует для реализации v1 до Б3 ровно пять красных клеток И-16; пп.2–3, 12 и строки 16, 161, 171, 243 называют 24 клетки и 43 порчи. Критерии должны соответствовать реально используемой батарее и не ослаблять проверку отсутствия инструментов.
СОСТОЯНИЕ: дельта 614b013b добавила две клетки И-16, три стаба и подняла census до 26; контракт не изменён. Сдаточный лист сам называет это расхождение и сообщает семь красных до реализации.
НАБЛЮДЕНИЕ: модельная команда rc 0 печатает 26 зелёных клеток и 46 пойманных порч, а не 24 и 43; точные команды и вывод ниже. Новые клетки проверяют тот же вход без PRECOND и потому противоречат требованию ровно пяти красных при старом субъекте. Числа 24/43 встречаются также в contracts/095-profil-i-vhod-agenta-contextpack.md:164-165, :171, :243; семь вместо пяти относится также к :16 и :171. Это не историческое описание в п.1–3 и 12: там заданы обязательные результаты команд приёмки. Закрывающее свойство: критерии и все зависимые счётные утверждения соответствуют исполняемой батарее в мирах до и после реализации; при необходимости изменения защищённого текста применяется полномочный маршрут, не удаляя новые проверки.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-15

## Карта классов

К-01: н/п — двери и лист повторно не запускались по заданию; раннер --stabs не имеет такого режима.
К-02: чисто — вход: OWNER-BATCH3-1118 №5 и station-batch2-1118 §9, узкая область К-08.
К-03: чисто — вход: git diff 6c29afefde..614b013b; чужие обязательства дельтой не изменены.
К-04: чисто — вход: две новые клетки и изменённые файлы батареи в зоне architect.
К-05: блок — расхождение критериев с живой батареей, блок К-15.
К-06: н/п — вне дельты, без изменений с Crit095V4.
К-07: блок — достижимость точного результата п.1 нарушена расширением батареи, блок К-15.
К-08: чисто — вход: s62–s64 в battery_stubs.sh; две независимые подмены проверяемого пути дали rc 1 нужных клеток, см. вывод ниже.
К-09: чисто — вход: оба мира отсутствия и второй присутствующий инструмент проверены отдельными клетками.
К-10: чисто — вход: клетки сверяют три полные строки PRECOND, независимые rev-list/rev-parse и запуск второго стража.
К-11: чисто — вход: оракул второго стража до вызова субъекта в обеих новых клетках.
К-12: чисто — вход: копии настоящих scripts и project_paths_resolve в обеих новых клетках.
К-13: н/п — секреты не затронуты дельтой.
К-14: чисто — честная эквивалентная запись `! test -f` на обеих новых клетках rc 0; --model rc 0.
К-15: блок — числа и точный census приёмки не согласованы с дельтой.
К-16: чисто — bash scripts/check_threat_model.sh . contracts/095-profil-i-vhod-agenta-contextpack.md rc 0; риск обычный.
К-17: н/п — архитектурный cutover не входит в дельту.

## Проверки

Путь клона: `/tmp/dev-harness-verify/Crit095V5/repo`; HEAD до вердикта равен OBJECT. `git fetch --tags origin` rc 0. Строка разрешения в коммите 18647b39: `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/095-profil-i-vhod-agenta-contextpack.md v+1 ...`: путь первый токен, причина непуста; относится к v+1 по слову владельца. Последняя дельта контракт не меняет. Н-39: привязки s62/s63/s64 находятся в коде battery_stubs.sh, не в тексте контракта.

Соседние проверки, сырой вывод (rc отмечены самой командой):
```text
PROVODKA_RC=0
  ok   персоны: 13 файл(ов), потолок 81920 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 182 черновик(ов) судится, замороженные — по тегам
потолки в порядке
CEILINGS_RC=0
модель угроз: секция валидна (ЗАЩИЩАЕТ 14 буллет(ов), НЕ ЗАЩИЩАЕТ 11 буллет(ов))
THREAT_RC=0
```
Команды: `bash scripts/check_provodka.sh . contracts/095-profil-i-vhod-agenta-contextpack.md`, `bash scripts/check_ceilings.sh . contracts/095-profil-i-vhod-agenta-contextpack.md`, `bash scripts/check_threat_model.sh . contracts/095-profil-i-vhod-agenta-contextpack.md`.

Собственная соседняя мутация: в копии модели условие проверки наличия каждого из двух инструментов отдельно заменено на проверку существующего `scripts/next_id.sh`; честный контроль заменяет оба `[ ! -f ... ]` на эквивалентный `! test -f ...`. Запуск клеток с `CP095_ROOT="$PWD" CP095_SUBJECT=<копия> bash fixtures/context_pack_095/<клетка>`, сырой вывод:
```text
КРАСНО: precond-net-check-plan: нет scripts/check_plan.sh → plan_gate обязана rc=2 NOT_RUN с названием инструмента, а не запуск отсутствующего файла (rc=127/bash)
ATTACK gate red_orch_brief_precond_net_check_plan.sh rc=1
КРАСНО: precond-net-plan-slice: нет scripts/orch_plan_slice.sh → plan_slice обязана rc=2 NOT_RUN с названием инструмента, а не запуск отсутствующего файла (rc=127/bash)
ATTACK slice red_orch_brief_precond_net_plan_slice.sh rc=1
ATTACK honest red_orch_brief_precond_net_check_plan.sh rc=0
ATTACK honest red_orch_brief_precond_net_plan_slice.sh rc=0
```

`bash fixtures/_krasnye_095.sh --model` rc 0; сырой вывод:
```text
— стаб s1 ПОЙМАН клеткой red_pravila_proekta_ne_harsa.sh
— стаб s2 ПОЙМАН клеткой red_manifest_razreshaetsja.sh
— стаб s3 ПОЙМАН клеткой red_poteryannaja_ssylka_tochna.sh
— стаб s4 ПОЙМАН клеткой red_roli_menjajut_vydachu.sh
— стаб s5 ПОЙМАН клеткой red_zony_iz_frozen_blobs.sh
— стаб s6 ПОЙМАН клеткой red_rezhim_do_zamorozki.sh
— стаб s7 ПОЙМАН клеткой red_revjer_poluchaet_vydannoe.sh
— стаб s8 ПОЙМАН клеткой red_svidetelstvo_modeli.sh
— стаб s9 ПОЙМАН клеткой red_bjudzhet_vklejki.sh
— стаб s10 ПОЙМАН клеткой red_uroki_po_oblasti.sh
— стаб s11 ПОЙМАН клеткой red_proishozhdenie_fragmentov.sh
— стаб s12 ПОЙМАН клеткой red_orch_brief_starter.sh
— стаб s13 ПОЙМАН клеткой red_kontekst_doslovno.sh
— стаб s14 ПОЙМАН клеткой red_profil_dva_sloja.sh
— стаб s15 ПОЙМАН клеткой red_dver_spawn_manifest.sh
— стаб s16 ПОЙМАН клеткой red_uroki_po_oblasti.sh
— стаб s17 ПОЙМАН клеткой red_revjer_poluchaet_vydannoe.sh
— стаб s18 ПОЙМАН клеткой red_orch_brief_starter.sh
— стаб s19 ПОЙМАН клеткой red_orch_brief_karta_legacy.sh
— стаб s20 ПОЙМАН клеткой red_orch_brief_bounded_work.sh
— стаб s21 ПОЙМАН клеткой red_orch_brief_bounded_work.sh
— стаб s29 ПОЙМАН клеткой red_orch_brief_bounded_work.sh
— стаб s30 ПОЙМАН клеткой red_orch_brief_rabota_bez_plana.sh
— стаб s31 ПОЙМАН клеткой red_orch_brief_rabota_bez_plana.sh
— стаб s32 ПОЙМАН клеткой red_orch_brief_rabota_bez_plana.sh
— стаб s40 ПОЙМАН клеткой red_naznachennaja_specializacija.sh
— стаб s41 ПОЙМАН клеткой red_naznachennaja_specializacija.sh
— стаб s42 ПОЙМАН клеткой red_naznachennaja_specializacija.sh
— стаб s43 ПОЙМАН клеткой red_rezhim_do_zamorozki.sh
— стаб s44 ПОЙМАН клеткой red_naznachennaja_specializacija.sh
— стаб s45 ПОЙМАН клеткой red_orch_brief_bounded_work.sh
— стаб s46 ПОЙМАН клеткой red_orch_brief_precond.sh
— стаб s47 ПОЙМАН клеткой red_orch_brief_precond.sh
— стаб s48 ПОЙМАН клеткой red_orch_brief_precond.sh
— стаб s49 ПОЙМАН клеткой red_orch_brief_precond_budget.sh
— стаб s54 ПОЙМАН клеткой red_orch_brief_precond_notrun.sh
— стаб s55 ПОЙМАН клеткой red_orch_brief_precond_notrun.sh
— стаб s56 ПОЙМАН клеткой red_orch_brief_precond_notrun.sh
— стаб s57 ПОЙМАН клеткой red_orch_brief_precond_notrun.sh
— стаб s58 ПОЙМАН клеткой red_orch_brief_precond_budget_gate.sh
— стаб s59 ПОЙМАН клеткой red_orch_brief_precond_budget.sh
— стаб s60 ПОЙМАН клеткой red_orch_brief_precond_serial.sh
— стаб s61 ПОЙМАН клеткой red_orch_brief_precond_budget.sh
— стаб s62 ПОЙМАН клеткой red_orch_brief_precond_net_check_plan.sh
— стаб s63 ПОЙМАН клеткой red_orch_brief_precond_net_plan_slice.sh
— стаб s64 ПОЙМАН клеткой red_orch_brief_precond_net_check_plan.sh
ИТОГ стаб-пак 095: rc=0
— battery_stubs.sh: rc=0
— red_bjudzhet_vklejki.sh: rc=0
— red_dver_spawn_manifest.sh: rc=0
— red_kontekst_doslovno.sh: rc=0
— red_manifest_razreshaetsja.sh: rc=0
— red_naznachennaja_specializacija.sh: rc=0
— red_orch_brief_bounded_work.sh: rc=0
— red_orch_brief_karta_legacy.sh: rc=0
— red_orch_brief_precond.sh: rc=0
— red_orch_brief_precond_budget.sh: rc=0
— red_orch_brief_precond_budget_gate.sh: rc=0
— red_orch_brief_precond_net_check_plan.sh: rc=0
— red_orch_brief_precond_net_plan_slice.sh: rc=0
— red_orch_brief_precond_notrun.sh: rc=0
— red_orch_brief_precond_serial.sh: rc=0
— red_orch_brief_rabota_bez_plana.sh: rc=0
— red_orch_brief_starter.sh: rc=0
— red_poteryannaja_ssylka_tochna.sh: rc=0
— red_pravila_proekta_ne_harsa.sh: rc=0
— red_profil_dva_sloja.sh: rc=0
— red_proishozhdenie_fragmentov.sh: rc=0
— red_revjer_poluchaet_vydannoe.sh: rc=0
— red_rezhim_do_zamorozki.sh: rc=0
— red_roli_menjajut_vydachu.sh: rc=0
— red_svidetelstvo_modeli.sh: rc=0
— red_uroki_po_oblasti.sh: rc=0
— red_zony_iz_frozen_blobs.sh: rc=0
ИТОГ 095: rc=0
```

`bash fixtures/_krasnye_095.sh --stabs` rc 1: раннер распознаёт только `--model`, поэтому `--stabs` трактуется как корень, а не как режим. Встроенный стаб-пак до клеток отработал rc 0 и вывел те же 46 строк пойманных стабов, что выше. Далее все 26 клеток сообщили отсутствие субъекта; завершающий сырой вывод:
```text
красная: предмет отсутствует (субъект scripts/make_task.sh, корень --stabs)
ИТОГ 095: rc=1
```
Это не ошибка стаб-пака; самостоятельная команда батареи стабов названа контрактом `bash fixtures/context_pack_095/battery_stubs.sh`, её выполнение входит в оба прогона раннера.

Счёт: `printf '%s\n' fixtures/context_pack_095/red_*.sh | wc -l` и `grep -c '^zapest ' fixtures/context_pack_095/battery_stubs.sh`:
```text
CELLS=26
STUBS=46
```
Предсудебные двери и сдаточный лист не повторялись по заданию. Freeze и push не выполнялись.

`bash fixtures/_krasnye_095.sh` на действительном субъекте до Б3: rc 1; стаб-пак вывел те же 46 строк, что в модельном прогоне выше. Сырой вывод клеток:
```text
— battery_stubs.sh: rc=0
— red_bjudzhet_vklejki.sh: rc=0
— red_dver_spawn_manifest.sh: rc=0
— red_kontekst_doslovno.sh: rc=0
— red_manifest_razreshaetsja.sh: rc=0
— red_naznachennaja_specializacija.sh: rc=0
— red_orch_brief_bounded_work.sh: rc=0
— red_orch_brief_karta_legacy.sh: rc=0
КРАСНО: precond: PRECOND-строк 0, ожидалось ровно 3 (замкнутый перечень)
— red_orch_brief_precond.sh: rc=1
КРАСНО: precond-budget: мир бюджета: PRECOND-строк не 3
— red_orch_brief_precond_budget.sh: rc=1
КРАСНО: precond-budget-gate: мир тяжёлого плана: PRECOND-строк не 3
— red_orch_brief_precond_budget_gate.sh: rc=1
КРАСНО: precond-net-check-plan: PRECOND-строк не 3 (замкнутый перечень)
— red_orch_brief_precond_net_check_plan.sh: rc=1
КРАСНО: precond-net-plan-slice: PRECOND-строк не 3 (замкнутый перечень)
— red_orch_brief_precond_net_plan_slice.sh: rc=1
КРАСНО: precond-notrun: мир A: PRECOND-строк не 3
— red_orch_brief_precond_notrun.sh: rc=1
КРАСНО: precond-serial: PRECOND-строк не 3 (замкнутый перечень потерян усечением?)
— red_orch_brief_precond_serial.sh: rc=1
— red_orch_brief_rabota_bez_plana.sh: rc=0
— red_orch_brief_starter.sh: rc=0
— red_poteryannaja_ssylka_tochna.sh: rc=0
— red_pravila_proekta_ne_harsa.sh: rc=0
— red_profil_dva_sloja.sh: rc=0
— red_proishozhdenie_fragmentov.sh: rc=0
— red_revjer_poluchaet_vydannoe.sh: rc=0
— red_rezhim_do_zamorozki.sh: rc=0
— red_roli_menjajut_vydachu.sh: rc=0
— red_svidetelstvo_modeli.sh: rc=0
— red_uroki_po_oblasti.sh: rc=0
— red_zony_iz_frozen_blobs.sh: rc=0
ИТОГ 095: rc=1
```

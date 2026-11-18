accept

OBJECT=a3453fe20a8a7aa17ffdf346016b1b0796cc6d50
СУД: repo=dev-harness; предмет=095; фаза=контракт v2 до заморозки; роль=critic; вызов=один дополнительный узкий по слову владельца 2026-11-18 ~21:09 UTC; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit095V6; модель-факт=openai-codex/gpt-6.1-terra allowed; SHA=a3453fe20a8a7aa17ffdf346016b1b0796cc6d50; предыдущий=Crit095V5 FAIL, 5dfaa96ca9; исключение=слово владельца, только К-15 и зависимый регресс, без нового полного суда и следующего вызова.

К-15 закрыт: contracts/095-profil-i-vhod-agenta-contextpack.md:163 требует ровно семь красных и 19 зелёных на v1 до Б3, :164 — 26 зелёных и 46 пойманных порч на модели, :165 — 46 стабов; fixtures/context_pack_095/sdacha_095.md:13-16, :66-80 заявляет те же значения. Они совпали с прогонами ниже. Две клетки отсутствия инструментов не удалены: привязки s62–s64 к ветвям и клеткам — в коде fixtures/context_pack_095/battery_stubs.sh:164-176, изменения ветвей в fixtures/context_pack_095/model/dover.sh:253-254, :271-272; не в прозе контракта (Н-39). Дельта проверяющего кода и новых предикатов не вводит.

Разрешение в теле коммита a3453fe20a8a7aa17ffdf346016b1b0796cc6d50 стоит в первой колонке, первый токен после `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` — `contracts/095-profil-i-vhod-agenta-contextpack.md`, причина непуста: v+1 Б3. Слово владельца зафиксировано docs/owner/2026-11-17-remonty-avtonomnost-plan.md в разделе «Слово владельца»; дельта согласует счёт приёмки v+1, не распространяет разрешение на другие пути. Независимость: автор изменения architect, автор предыдущего вердикта critic; модель по трассе allowed. Область этого вердикта ограничена порученным узким судом.

## Карта классов

К-01: чисто — вход: лист и предсудебные двери, результаты ниже.
К-02: чисто — вход: слово владельца 2026-11-18 ~21:09 и docs/owner/2026-11-17-remonty-avtonomnost-plan.md, адресный К-15.
К-03: чисто — вход: git show a3453fe: изменены только контракт 095 и его сдаточный лист, уставная строка в том же коммите.
К-04: н/п — новых файлов и распределения дельта не вводит; без изменений с Crit095V5.
К-05: чисто — вход: контракта строки 163–165 и наблюдаемые rc/числа ниже.
К-06: н/п — механизм отказа среды без изменений с Crit095V5.
К-07: чисто — `bash fixtures/_krasnye_095.sh .` rc 1: ровно семь красных при до-Б3 субъекте; `--model` rc 0.
К-08: чисто — вход: battery_stubs.sh:171-176, s62–s64 пойманы; код без изменений с Crit095V5.
К-09: н/п — без изменений с Crit095V5.
К-10: н/п — без изменений с Crit095V5.
К-11: н/п — без изменений с Crit095V5.
К-12: н/п — без изменений с Crit095V5.
К-13: н/п — секреты дельтой не затронуты.
К-14: чисто — `bash fixtures/_krasnye_095.sh --model` rc 0, проверяющий код без изменений с Crit095V5.
К-15: чисто — вход: контракт :163–165, лист :13–16, живой прогон 26 клеток/46 порч/семь красных ниже.
К-16: чисто — `bash scripts/check_threat_model.sh . contracts/095-profil-i-vhod-agenta-contextpack.md` rc 0.
К-17: н/п — архитектурная модель вне дельты и области поручения.

## Проверки

`bash scripts/pre_critic.sh --repo . contracts/095-profil-i-vhod-agenta-contextpack.md` rc 0; сырой вывод (первый запуск был прерван внешним таймаутом 300 с, повтор с бюджетом 1000 с):
```text
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```

Рабочий каталог `/tmp/dev-harness-verify/Crit095V6/repo`; `git fetch --tags origin` rc 0; HEAD до записи вердикта = OBJECT, ветка `wip/095/architect`. `git rev-parse HEAD:scripts/make_task.sh origin/main:scripts/make_task.sh` дал дважды `4963453278a50c663cab4adafa78341e6df74e60` — субъект на момент замера совпадает с origin/main до Б3.

`bash scripts/check_sdacha.sh . contracts/095-profil-i-vhod-agenta-contextpack.md --run` rc 0, сырой вывод:
```text
СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=3)
```

Соседние двери, сырой вывод команд `bash scripts/check_provodka.sh . contracts/095-profil-i-vhod-agenta-contextpack.md`, `bash scripts/check_ceilings.sh . contracts/095-profil-i-vhod-agenta-contextpack.md`, `bash scripts/check_threat_model.sh . contracts/095-profil-i-vhod-agenta-contextpack.md`:
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

`bash fixtures/_krasnye_095.sh .`, `bash fixtures/_krasnye_095.sh --model` и `bash fixtures/context_pack_095/battery_stubs.sh` выполнены последовательно. Раннер не имеет флагов `--repo` и `--stabs`: корень задаётся позиционным аргументом, стабы запускаются отдельной командой и встроены в оба прогона (fixtures/_krasnye_095.sh:20-25, :55-58). Сырой вывод стаба, одинаково полученный в каждом из трёх прогонов:
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
```

После этого общего вывода сырой вывод клеток реального субъекта:
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
REPO_RC=1
```

После общего вывода стаба сырой вывод клеток модели:
```text
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
MODEL_RC=0
```

После отдельного прогона стаба — `STABS_RC=0`. Число файлов `printf '%s\n' fixtures/context_pack_095/red_*.sh | wc -l` = 26; у раннера census 26 (fixtures/_krasnye_095.sh:34-39).

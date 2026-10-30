accept

# Контракт 143/2 — дополнительный scoped-суд v2d (30.10, слово владельца ~14:55 UTC)

OBJECT `a253fe8e1d542fd2cb0bd9aa23b1da569e1b6284` (родитель `395a8ffef0426f39f0244c44314518d876b14ebf`); судья critic, фактическая модель `openai-codex/gpt-6-sol`. Суд только блоков Arb143v2 1–2, зависимого регресса и дельты от родителя; нового полного суда реализации нет. Испытания ниже выполнены в изолированном клоне с SSH origin `/tmp/dev-harness-verify/Crit143v2t/attack-a253fe8e`, HEAD = OBJECT. Вердикт коммитится отдельно в изолированном репозитории `/tmp/dev-harness-verify/Crit143v2t`, ветка `wip/143/critic-v2t`, без push.

## Дельта и область

`git diff --name-only a253fe8e^..a253fe8e` — ровно пять путей: `contracts/143-mob-ci-razdelenie.md`, `fixtures/workshop_project/mob_ci_143/osi.md`, `fixtures/workshop_project/mob_ci_143/probe.py`, `fixtures/workshop_project/mob_ci_143/source.json`, `fixtures/workshop_project/mob_ci_143/stabs/stab_i_child_bez_podpisi.py`. Все — `ЗОНА architect` (`contracts/143-mob-ci-razdelenie.md:165`), вне зоны ноль. Инварианты v2 И-12–И-15 (§2.2–§4 Astra), порядок/исполнители/зоны и критерии первой версии не удалены и не ослаблены дельтой: она меняет только child_flows-критерии `:139–140`, оракул, оси, новый стаб и фактический счёт; дополнительного продукта, экрана или интеграции не назначено. Два конформных входа разделены: изменение файла child-flow с неизменной картой — выборочный режим, изменение регистрации `child_flows` в карте — `POLICY_CHANGE`/full-set (`:139–140`, `:253–254`). Утверждения старой замороженной v1-приёмки (69 клеток) остаются историческими; текущая приёмка v2 и счёт — 80.

Независимый census по `source.json`: `S25 A17 Y24 F4 I9 P1 = 80`, `stab_vhod=62` ключа/78 привязок, `piny=13` + `chernoviki_piny=9` = 22; реальные файлы `model=5 nositeli=8 stabs=62 drafts=9`, несовпавших sha256 ноль. `bash scripts/check_precision_gate.sh . contracts/143-mob-ci-razdelenie.md` → stdout `OK`, rc 0; `bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md` → `КРИТИК: дверь зелёная`, rc 0.

## Исполняемые проверки — сырой вывод

`W=bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh`. Каждый `--repo` ниже — отдельная копия эталона только внутри одноразового клона, изменения не коммитились. Для `development` изменены статусы `splash` и `first-run` на `in-development` (проверка родителя и сохранения ещё одного экрана в разработке); `approved` — неизменная модель. Эти прогоны включают обе i08/i09, но статусные пробы i08 строят реальный git base/head внутри батареи.

```
W --repo .critic-143-v2t/approved
клеток 80, зелёных 80, красных 0
APPROVED_RC=0
W --repo .critic-143-v2t/development
клеток 80, зелёных 80, красных 0
DEVELOPMENT_RC=0
```

Атака владения — применён `python3 fixtures/workshop_project/mob_ci_143/stabs/stab_i_child_rezhet_vybor.py <копия>` к двум статусам, затем настоящий `W --repo`; i08 красна точно в месте владения, остальные 79 зелёные:

```
W --repo .critic-143-v2t/mut-vladenie
клеток 80, зелёных 79, красных 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/splash-child-proba.yaml: rc=1 VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/splash-child-proba.yaml КРАСНА
MUT_VLADENIE_APPROVED_RC=1
W --repo .critic-143-v2t/mut-vladenie-development
клеток 80, зелёных 79, красных 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/splash-child-proba.yaml: rc=1 VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/splash-child-proba.yaml КРАСНА
MUT_VLADENIE_DEVELOPMENT_RC=1
```

Атака подписи — `python3 fixtures/workshop_project/mob_ci_143/stabs/stab_i_child_bez_podpisi.py .critic-143-v2t/mut-podpis`, удаляется `z.child_flows` **только** из `kartaPodpis`, union/vladelec сохранены; i08 и i01 остаются зелёными:

```
W --repo .critic-143-v2t/mut-podpis
клеток 80, зелёных 79, красных 1
КЛЕТКА i09-podpis-child-flows: policy_change не поднят (False; prichiny ['COMMON_CHANGE']): изменение ТОЛЬКО child_flows — часть подписи карты, POLICY_CHANGE обязателен; POLICY_CHANGE нет в prichiny ['COMMON_CHANGE']: подмена классификации COMMON_CHANGE/full_set не допускается КРАСНА
MUT_PODPIS_RC=1
```

Собственная дополнительная мутация при статусе `in-development`: в копии селектора заменена ровно одна строка `selected.set(z.id, "DEVELOPMENT")` на `selected.set(z.id, "AFFECTED")`; это проверяет запрет подмены причины, а не отказ инвентаризации:

```
W --repo .critic-143-v2t/mut-reason
клеток 80, зелёных 79, красных 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/splash-child-proba.yaml: причина AFFECTED ≠ DEVELOPMENT (статус родителя in-development) КРАСНА
MUT_REASON_RC=1
```

A1: в копию актуальной модели поверх четырёх файлов подставлены исторические байты `git archive 18d8e7449 fixtures/workshop_project/mob_ci_143/model` (лекало v2 сохранено). Честный до-v2 субъект красен не только по старым инвариантам, но и по двум исправленным блокам:

```
W --repo .critic-143-v2t/A1
клеток 80, зелёных 76, красных 4
КЛЕТКА i01-inventar-dereva: честное дерево: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; пачка без регистрации: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; запись без пачки: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; symlink-пачка: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; флоу без владельца: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; флоу записи отсутствует: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar КРАСНА
КЛЕТКА i05-vynos-iz-inventarja: НЕТ_ИНВЕНТАРИЗАЦИИ: в quality нет шага с вызовом селектора --mode inventar КРАСНА
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/splash-child-proba.yaml: rc=1 VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/splash-child-proba.yaml КРАСНА
КЛЕТКА i09-podpis-child-flows: policy_change не поднят (False; prichiny ['COMMON_CHANGE']): изменение ТОЛЬКО child_flows — часть подписи карты, POLICY_CHANGE обязателен; POLICY_CHANGE нет в prichiny ['COMMON_CHANGE']: подмена классификации COMMON_CHANGE/full_set не допускается КРАСНА
A1_RC=1
```

Регресс и соседи (реальные команды; наблюдённый сырой вывод коротких режимов и контрольные строки длинных матриц):

```
W --model [1]
клеток 80, зелёных 80, красных 0
MODEL_1_RC=0
W --model [2]
клеток 80, зелёных 80, красных 0
MODEL_2_RC=0
W --model [3]
клеток 80, зелёных 80, красных 0
MODEL_3_RC=0
W --stabs
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
STABS_RC=0
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs
SVJAZI 69
zhivykh 0
SOSED_995_RC=0
bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs
SVJAZI 60
SOSED_139_RC=0
bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
SVJAZI 66
zhivykh 0
SOSED_141_RC=0
```

Вывод: обе причины scoped-FAIL закрыты исполняемой парой «положительный статус/подпись — точечный красный мутант»; A1, модели, матрица стабов и три соседние матрицы не регрессировали. Блокирующих находок в заданной области нет. Временные копии субъектов удалены до записи вердикта.

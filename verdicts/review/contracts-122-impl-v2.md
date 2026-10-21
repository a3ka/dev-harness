accept
Ревьюер Rev122b. Реализация 122 «CI проекта», круг 2 из 3. OBJECT 3fbfc6e91dd1a8dc13ec09d93dcb47cc2e277520 (предшественник
b3bc3399d), контракт frozen/contracts/122/2, батарея main ce257b6fe (45 клеток). Суд — на объединении main 9759985e2 + OBJECT
(клон /tmp/dev-harness-verify/Rev122b/repo, HEAD a5cdf1047). Находки — /tmp/dev-harness-verify/Rev122b/review.md (reslop,
status: ready).

Итог. F-1, F-2, F-3, if-поле, С-3, С-4 закрыты. Каждое закрытие проверено своими мирами; на каждое есть красный прогон
предшественника. Находок с названным обходом предмета 122 нет, поэтому реализация принята.

УСЛОВИЕ ЛЕНДА: R2-1. Без интеграционного коммита ленд делает красными шард CI ap5 и step check:document. Это не круг
implementer: оба пути вне его зоны.

## Условие ленда

- R2-1 [регрессия замороженного соседа / неполная проводка, класс прецедента 54ff90f11].
  Новая fail-closed ветвь ноги 6г в `scripts/freeze_contract.sh` («гейт предпосылок 122 недоступен: нет читаемого …»)
  ломает мир `fixtures/drill_contract_change/case_procedura_ne_prinjata.sh:16-19`. Этот мир копирует соседей freeze
  поимённо, и `check_predposylki.sh` в его списке нет.
  - Замер `verify_antiplacebo.sh --scope drill_contract_change`:
    - union → rc 1, «нет положительного контроля»; в case.out «гейт предпосылок 122 недоступен»;
    - main → rc 0;
    - предшественник → rc 0.
  - Семья входит в шард ap5 (`registry/ci-steps.tsv:173`).
  - Второй мир того же класса: `fixtures/freeze_contract/fail_closed_992.py:108-114`. Он копирует freeze и подменяет
    прочие гейты-предпосылки OK-стабами, но `check_predposylki.sh` в нём нет.
    - Замер `bash fixtures/freeze_contract/red_doc_lifecycle.sh` (npm `check:document`, `registry/ci-steps.tsv:81`):
      union → rc 1, failures=2 (A-freeze-spec, B-freeze-versions: control_rc=1); main → rc 0; предшественник → rc 0.
  - Простейшая форма:
    - drill: добавить `check_predposylki.sh` в список копирования, как в 54ff90f11;
    - 992: добавить `'check_predposylki.sh'` в кортеж OK-стабов строки 112.
    Проверено в клоне: с этими двумя строками drill → rc 0 (1/1), 992 → rc 0 (failures=0).
    Это интеграционный коммит оркестратора или владельца: пути вне ЗОН. Fail-closed по (а) при этом сохраняется.

## Закрытие круга 1 (rc своих проб; красное — на предшественнике)

- (а) F-1. Проба `probe_freeze.sh`: мир — каркас fixtures/freeze_contract/_repo.sh, gh фикстурный.
  - Секрет не заведён:
    - OBJECT: freeze rc 1 sekrety-ne-zavedeny, тега нет;
    - предшественник: rc 0, тег frozen/contracts/001/1 создан.
  - gh сломан:
    - OBJECT: rc 1 gh-nedostupen;
    - предшественник: rc 0, тег создан.
  - Контроли на OBJECT:
    - секрет заведён → rc 0 v1;
    - без CI-путей → rc 0, gh не зван.
  - Гейт удалён из scripts/ → rc 1 «недоступен» во всех 4 сценариях: fail-closed.
- (б) F-2. Проба `probe_g1g2.sh`, `--check` на OBJECT:
  - CRLF везде → rc 1 workflow-ruchnoj;
  - одиночный CR → rc 1;
  - CRLF только в хвосте → rc 1;
  - BOM → rc 1;
  - без хвостового LF → rc 1;
  - лишний байт \xff → rc 1;
  - контроль без правки → rc 0.
  На предшественнике CRLF, CR и CRLF-хвост дают rc 0.
- (в) F-3. Проба `probe_g1g2.sh`, предполёт на OBJECT:
  - рабочий каталог = абсолютный R у шага или у джобы → rc 1 working-directory-otsutstvuet, R цел;
  - `..` в workflow → rc 1;
  - `app/../..` → rc 1;
  - симлинк → R → rc 1;
  - контроли `app` и `./app/..` → rc 0.
  На предшественнике абсолютный R даёт rc 0 и R МУТИРОВАН, `..` даёт rc 0.
- (г) if-поле, OBJECT:
  - `secrets.X` только в if шага → rc 1 sekrety-ne-perechisleny;
  - `vars.X` в if джобы без `${{ }}` → rc 1;
  - объявленный секрет → rc 0.
- С-3: битый симлинк → rc 0, scratch не утекает. Предшественник: rc 1, трассировка, +1 утёкший scratch (удалён).
- С-4: DECLARED_RE = [A-Z][A-Z0-9_]*.

## (д) Дельта, батарея, приёмка (rc)

Область правки:
- 5 файлов ⊂ ЗОНА implementer;
- дельта — 4 файла, 71+/23- (numstat);
- pre_critic: только 6 строк комментария, 0 строк кода;
- freeze: правка только внутри ноги 6г;
- батарея и контракт не тронуты;
- коммит 3fbfc6e91, автор implementer, ссылка «122».

Батарея (union):
- `red_ci_proekta_122.sh` → rc 0, 45/45;
- `--model` → rc 0, 45/45;
- вторая мера: 45 run_case (rc0×17, rc1×28); в выводе 45 строк CASE, все ЗЕЛЁНАЯ;
- `--cell net-takoj` → rc 2;
- клетки g8/p5f/p8/p3/p5/p5e/p6/p6e/p6z/p7 → rc 0, зелёных 2/3/3/1/1/2/2/3/3/4;
- предшественник + эта батарея → rc 1, 40/5 (g8×2, p8×3).

Стабы и мутанты (`--model`, все rc 1); счёты совпадают с замерами landed 2f7e49315:

| Стаб / мутант | Зелёных / красных |
|---|---|
| gen_postojannyj | 27/18 |
| tolko_sintaksis | 28/17 |
| slepoy | 41/4 |
| vsegda_zelenyj | 0/45 |
| vsegda_krasnyj | 0/45 |
| rc0 | 17/28 |
| rc1 | 28/17 |
| bez_podstanovki | 43/2 |
| bez_workflow_defaults | 43/2 |
| bez_env | 40/5 |
| sverka_tolko_run | 40/5 |
| env_bez_podstanovki | 42/3 |
| bez_sverki_if | 43/2 |
| bez_sverki_with | 44/1 |
| wd_bez_vlozhennosti | 42/3 |
| wd_ot_iskhodnogo_r | 44/1 |
| gen_check_tekstom | 43/2 |

Приёмка п.8:
- `pre_critic --repo . contracts/122-ci-proekta.md` (v2 = main) → rc 0 «КРИТИК: дверь зелёная»;
- `check_precision_gate` → rc 0;
- `check_threat_model` → rc 0 (7/6).

Регрессии на union:
- `verify_antiplacebo --scope`:
  - freeze_contract → rc 0 (15/15);
  - pre_critic → rc 0 (2/2);
  - check_consumers → rc 0 (1/1);
  - done_contract → rc 0 (1/1);
  - check_staged → rc 0 (33/33);
  - check_zones → rc 0 (38/38);
  - spawn_agent → rc 0 (2/2);
  - check_contract_frozen → rc 0 (6/6);
  - check_runner_hygiene → rc 0 (40/40);
  - check_check_contract_ready → rc 0 (4/4);
  - drill_contract_change → **rc 1** (R2-1);
- `freeze_contract/red_doc_lifecycle.sh` (992) → **rc 1**, failures=2 (R2-1);
- `freeze_contract/red_preflight_podkatalog_992.sh` → rc 0;
- `rezhim_996/probe.sh` → rc 0 (111, 0 расхождений);
- `_krasnye_072` → rc 0;
- `_krasnye_103` → rc 0;
- `plan_084` → rc 0 (59/59);
- `060` → rc 0;
- `check_precision_gate/red_14` → rc 0;
- `spawn_agent/red_gejt_stroka_frozen_sha` → rc 0;
- `drill_contract_change.sh` на полном дереве → rc 0;
- `limit_aktivnyh/red_limit_aktivnyh_078` → rc 1 и `_krasnye_038` → rc 1 «37/37 расхождений». Тот же rc и тот же итог на
  main без 122 и на предшественнике, то есть это не дельта.

## Советы (не блокируют)

- С2-1: pre_critic остаётся fail-open по `-x`, так как мир 072 без гейта. Freeze судит по `-r`. Обхода нет: freeze
  ловит тот же контракт.
- С2-2: из-за `symlinks=True` шаг пишет через симлинк R → наружу.
  - Замер: OBJECT мутирует внешний каталог, у предшественника он цел.
  - Это класс «команда пишет вне копии», он записан в НЕ ЗАЩИЩАЕТ.
  - Альтернатива: `symlinks=False, ignore_dangling_symlinks=True`.
- С2-3: батарея усилена до 45 клеток после заморозки 122/2 без новой версии. Счёты п.1–6 контракта на дереве буквально
  не воспроизводятся. Решать оркестратору.

Пробы: /tmp/dev-harness-verify/Rev122b/probe_{freeze,g1g2,symlink}.sh. Worktree клона: pred (предшественник), mainwt (main).

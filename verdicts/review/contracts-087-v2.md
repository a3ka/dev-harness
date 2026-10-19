FAIL
OBJECT=ae7f9bc7b6327c54ca36bdb908f0d48ce477ec48

# Вердикт ревьюера 087, круг 2 — FAIL

Находки: `/tmp/dev-harness-verify/reviewer087r2/findings.md` (status: ready). Блокирует одна:
**Р2-1** — бюджет legkij пробит переносом ключей (замороженный предикат А7 rc 1 на main).
Остальное (Р2-2…Р2-7) — советы и открытые пункты оркестратора.

Клон `ssh://…/dev-harness.git` → `/tmp/dev-harness-verify/reviewer087r2/clone`, detached ae7f9bc7;
мутации — только в одноразовых клонах `../mut`, `../ap`. Рабочее дерево не тронуто.

## 1. Область правки (зоны сверены живьём с тегами)

Дифф 34453b8f..ae7f9bc7 — 15 файлов, 10 коммитов (git show --stat по каждому):

| коммит | автор | пути | зона по замороженному тегу |
|---|---|---|---|
| 08a093fb, 3349ad26, b5824b9c, 934734e1, 800ba5b3, 7d8ecc59 | implementer | ci.yml, package.json, ci_parity_exceptions, ci-steps.tsv, ci_klass.sh, ci_vesa.sh, gitw_preflight_071.sh, run_ci_lane.sh, verify_ci_parity.sh, check_ci_gate.sh | ЗОНА implementer 087/1 — все внутри |
| 2f3d6f18 | implementer | пусто (retrigger CI) | — |
| 186e093a | implementer | fixtures/freeze_contract/fail_closed_992.py | вне 087; ЗОНА implementer 992/2 (`fixtures/freeze_contract/`, aff50503) — внутри объединения зон автора; правка — кортеж копирования (+ci_klass.sh), CASES/оракулы не тронуты — «исправление по находке, не смена критерия» (ПЕРЕСЕЧЕНИЕ 992) |
| fc497a83 | architect | fixtures/ci_gen_083/red_ci_a_083.sh | ЗОНА architect 083/3 (70f8011d) — внутри; сообщение «083 architect» |
| 56644c8e | architect | fixtures/_krasnye_087.sh, fixtures/ci_b_087/{model/ci_klass.sh, red_ci_b_087.sh} | ЗОНА architect 087/1 — внутри |

Тексты замороженных контрактов не тронуты: `git diff frozen/contracts/{087/1,083/3,992/2}^{commit}
ae7f9bc7 -- contracts/<файл>` — пусто у всех трёх. Превышения нет.

## 2. Сырой вывод (мои прогоны на ae7f9bc7)

- `bash fixtures/_krasnye_087.sh` → rc 0, «ИТОГ 087: клеток ok=103 КРАСНО=0; стаб-пак: поймано 26/26».
  Своя мера: в сыром логе 129 строк `  ok   `, из них 26 `  ok   стаб` → 103 клетки; `КРАСНО:` 0.
- `bash fixtures/_krasnye_083.sh` → «083-батарея: ok=120 FAIL=0»; своя мера: 120 строк ok, 0 FAIL;
  Г-С12…Г-С17 + Г-С-контроль/legkij присутствуют и зелены.
- `bash scripts/verify_ci_parity.sh` → rc 0, «расхождений: 0».
- `bash scripts/check_provodka.sh . contracts/083-…md` rc 0; то же для 087 rc 0.
- `bash scripts/gen_ci_steps.sh --check` rc 0.
- `npm run check:antiplacebo -- --scope check_ci_gate` → rc 0, 8/8 красным повторным прогоном;
  `--scope verify_ci_parity` → rc 0, 26/26 (чистый клон `../ap`; первый прогон в общем клоне дал
  «дерево изменилось вне $WORK» от моих же параллельных прогонов — `.log/.runs` reslop и
  `tmp/zones.*` батареи 083 — не дефект субъекта).
- CI: push main ae7f9bc7 — run 39193694797 success (klass/legkij/vorota success, тяжёлые skipped);
  PR#110 (56644c8e) — run 39192754111 success, все тяжёлые success, tyazhelyj-itog success.
- `bash fixtures/ci_b_087/zamer_087.sh 39190153254` → rc 1, «НАРУШЕНИЕ: push в main проверялся 129 с
  > 120: прогон 39193694797» (Р2-1).
- `bash fixtures/_krasnye_071.sh` → rc 0, «честные клетки: 41/41 зелёные; стаб-пак 21/21 + дифф 21/21».
- `python3 fixtures/freeze_contract/fail_closed_992.py` → rc 0, «cases=24 observations=24 failures=0» (два прогона: общий клон и `../ap`).
- `bash fixtures/parsing_hygiene_battery/run_battery.sh ci_klass` → rc 0, «итог 4/4 классов закрыто».

## 3. Проверки не переписаны под реализацию

- Батарея 087 (`fixtures/ci_b_087/`, `_krasnye_087.sh`) после заморозки правил только architect
  (825cbc26, 56644c8e); implementer её не касался. 56644c8e — чисто аддитивен: +А9, +4 входа Б1,
  модели добавлена честная ветка «нет curl → rc 2», агрегатор: stderr «детали:» вместо «КРАСНОЕ 087»
  (Н-6), stdout = строке приёмки. Ни одна прежняя клетка не ослаблена.
- Батарея 083 (Г10): правил architect в зоне 083 (fc497a83). Прежняя ветвь (cache_cell_ci) сохранена;
  legkij-ветвь выбирается только по legkij-строке реестра и несёт 6 стабов дефектов legkij-этикета,
  каждый пойман, диффпробы зелены — не «всегда зелено».
- fail_closed_992.py правил implementer 087 (в своей зоне 992): изменён только состав копируемых в
  toy-мир скриптов; CASES/оракулы/наблюдения не тронуты.
- verify_ci_parity.sh (барьер, зона implementer 087 по контракту): 7d8ecc59 засчитывает строки legkij
  реестра как покрытие — симметрично step-строкам. Правило 6 соблюдено (ключи legkij реально
  исполняются `run_ci_lane.sh` в джобе legkij), но parity одна выпадение ключа из run-строки не видит:
  мутант `../mut` без `check:runner-hygiene` в legkij → parity rc 0, gen --check rc 0; ловит батарея
  087 (rc 1, КРАСНО К6 и К-исп legkij). Это не ослабление (тот же уровень, что step ↔ Г1), совет Р2-4.

## 4. Красное предъявлено

Новые клетки 56644c8e — дифференциальные против обходов адверсария 087-1; красное против мутанта
своей пробой не воспроизводил (это адверсарий круга 2). Перенос ключей: красное K6/К-исп показано
моим мутантом. Г10 legkij: красное — шесть стабов Г-С12…17 (живой прогон).

## 5. Атомарность

Каждый коммит — один предмет со ссылкой (087 / 083). 2f3d6f18 — пустой retrigger, шум без вреда.

## 6. Норма не тронута

Ни contracts/, ни roles/, ни AGENTS.md в диффе нет.

## 7. Перенос ключей step → legkij (вопрос задания)

- **Покрытие не ослаблено.** Три ключа (`check:pokrytie-079-family-selftest`,
  `check:ops-server-family-selftest`, `check:runner-hygiene`) исполняются в legkij на каждом push и PR
  на полном дереве (в логах 39193694797/39192754111 — «замер:» у всех трёх, rc 0); в lane-матрице их
  нет (`gen --check` rc 0, И-2 «не входят в lane-матрицу» соблюдено); check_ci_gate при skipped
  требует legkij success. Это строго шире прежнего (только на тяжёлых прогонах).
- **Бюджет legkij нарушен** — Р2-1 (блокирует): 76–78 с до 7d8ecc59 → 120–134 с после;
  runner-hygiene один — 35 с по замеру при весе 20; стена push main 129 с > 120 по предикату А7.
- **Правка verify_ci_parity на legkij** — правило 6 соблюдено (см. §3), совет Р2-4.

## 8. Закрытие круга 1 (`.review/2026-10-09-02.md`)

| пункт | статус | мера |
|---|---|---|
| Б-1 CI красный | закрыт по цвету: PR#110 и push main success; стена — не закрыта (Р2-1) | check-runs ae7f9bc7, run 39192754111 |
| Б-2 кеши в legkij | закрыт: 4 restore (ci.yml:100-118) + 8 save в legkij, check_no_rewrite в legkij (ci.yml:182); charter --incr 41–44 с вместо 774 | ci.yml:82-182, лог legkij «incr: … (2 коммита)» |
| Б-3 шаг _krasnye_083 + ключ | закрыт: шаг в obshchij, ключ check:ci-family-selftest на месте; check_provodka 083 rc 0; батарея 083 120/0 | см. §2 |
| Б-4 ключи ci-klass/ci-vesa | закрыт: удалены вместе с исключениями; один ключ `check:ci-b-087-family-selftest: bash fixtures/_krasnye_087.sh`; parity rc 0 | package.json:81 |
| Н-1 dokaz из $ROOT | закрыт: `cd "$ROOT" &&` перед dokaz | check_ci_gate.sh:261 |
| Н-2 Г10 083 | закрыт: fc497a83, `_krasnye_083.sh` 120/0 | §2 |
| Н-3 пять обходов | закрыт архитектором: А9 + 4 входа Б1, ok=103 | 56644c8e |
| Н-4 5-я форма | не менялась (совет) | verify_ci_parity.sh:1151-1157 |
| Н-5 ci_klass cwd | не менялась (совет), Р2-5 | gitw_preflight_071.sh:440 |
| Н-6 stdout агрегатора | закрыт | _krasnye_087.sh:29-30 |
| Н-7 sha вердикта адверсария | открыт за оркестратором, Р2-6 | df110f06 нет в origin |
| Н-8 веса legkij | открыт, корень Р2-1, Р2-7 | замеры vs реестр |

## 9. Паразитная сложность (050) — по артефакту: (1) свойство; (2) состояние; (3) файлов на правку; (4) глубина; (5) потребитель

- `scripts/ci_klass.sh` (311 строк, 6 подкоманд hash/klass/dokaz/vorota/reshenie/strip): (1) И-1, И-3, И-4, И-7; (2) состояния нет, env ровно И-3 (CI_KLASS_API, GITHUB_REPOSITORY, GITHUB_API_URL, GITHUB_TOKEN); strip меняет рабочее дерево явно по аргументу; (3) 1 файл + реестр uchet; (4) глубокий — узкий интерфейс, хеш/API/strip скрыты; (5) клетки А1–А7 батареи, шаги klass/vorota/strip ci.yml. ESSENTIAL.
- `scripts/ci_vesa.sh` (86 строк, --write/--check): (1) И-9; (2) пишет поле веса реестра только в --write; (3) 1; (4) глубокий; (5) А8. ESSENTIAL.
- `check_ci_gate.sh` шаг 4б (+68): (1) И-6; (2) нет; (3) 1; (4) интерфейс не вырос; (5) Б1 батареи, scope check_ci_gate 8/8. ESSENTIAL.
- `gitw_preflight_071.sh` чек 5 (+49): (1) И-5; (2) экспорт CI_KLASS_API из GITW_PREFLIGHT_071_API (ручка уже существовала); (3) 1; (4) без новых флагов; (5) Б2. ESSENTIAL; fallback `$SELF_DIR` — совет Р2-5.
- `run_ci_lane.sh` (legkij + «замер:»): (1) И-2, И-9; (2) нет; (3) 1; (4) интерфейс прежний; (5) К-исп, ci_vesa. ESSENTIAL.
- `verify_ci_parity.sh` ветвь legkij (REGISTRY_STEP_* + 5-я форма): (1) И-8 + правило 6 (ключи legkij в CI); (2) нет; (3) реестр + parity — прежние 2 файла; (4) без нового интерфейса; (5) шаг obshchij check:ci-parity. ESSENTIAL; узость — советы Н-4/Р2-4.
- `registry/ci-steps.tsv` строки uchet (10) и legkij (9): (1) И-1, И-2; (2) реестр — код; (3) реестр + ci.yml legkij-строка (держит К6) — 2, как у step; (5) А8, К6. ESSENTIAL.
- `ci.yml` джобы klass/legkij/vorota/obshchij/tyazhelyj-itog: (1) И-8; (5) К1–К9. ESSENTIAL.
- `config/ci_parity_exceptions.txt` (+56/−28): записи для форм strip/reshenie/vorota/no_rewrite/printf — (1) правило 6 для команд с workflow-context; (5) parity rc 0. ESSENTIAL (более простая форма — расширение 5-й формы — отвергнута прецедентом 083/3).
- `red_ci_a_083.sh` Г10 legkij-ветвь (+236): (1) 087 И-2/И-8 кеши в legkij при Г10 083; (2) маркер-файл `<prefix>.legkij` во временном каталоге батареи — побочный, но внутренний; (3) 1; (5) `_krasnye_083.sh` в obshchij. ESSENTIAL.
- `fail_closed_992.py` кортеж (+1 имя): (1) И-5 087 делает ci_klass.sh зависимостью предполёта; ESSENTIAL.
- `red_ci_b_087.sh` +А9 и 4 входа Б1, `sj_nocurl`, `T87_NOBIN`: (1) И-3 rc 2 без curl, И-6; (5) А4. ESSENTIAL.

ACCIDENTAL-находок нет.

## Итог

FAIL по Р2-1 (воспроизведённый дефект: И-10/А7, предикат rc 1 на main; причина — 7d8ecc59, бюджет
посчитан по угаданным весам). Прочие пункты круга 1 закрыты или переведены в советы/оркестратору.

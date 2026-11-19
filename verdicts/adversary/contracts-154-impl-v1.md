FAIL
OBJECT=6b04cb51f269581fff55f750de8b65977f273634
СУД: repo=dev-harness; предмет=154; фаза=реализация (рисковый, деньги); роль=adversary; вызов=ПЕРВЫЙ по реализации 154; сессия=Adv154V1; клон=ssh://git@github.com/a3ka/dev-harness.git ветка wip/154/orchestrator, `git rev-parse HEAD`=OBJECT, каталог /tmp/dev-harness-verify/Adv154V1/repo; модель-факт (`bash scripts/models_actual.sh --tsv --bind --session Adv154V1 | cut -f1-3`): adversary → openai-codex/gpt-6.1-terra allowed (прочие строки привязки: openai-codex/gpt-6.1-terra allowed; zai/glm-5.3 denied; anthropic/claude-sonnet-5-5 denied).

ОСТАТОК: в §Модель угроз «НЕ ЗАЩИЩАЕТ» контракта 154 нет строки с ловцом adversary (ловцы: оркестратор/reviewer/станционный аудит) — атаковать нечего; ОСТАТОК: н/п.

Вердикт — только по реализации (scripts/zamok_predmeta.sh, scripts/freeze_contract.sh и миграция потребителей); батарея 154 (architect) не правится и не судится. Один блок; остальное — советы.

## Положительные контроли (сырые замеры, честная реализация даёт зелёное)

На чистом OBJECT:
- `W --repo` rc 0 (87/87, 25 с); `W --domain` rc 0 (213/213); `W --live` rc 0 (9/9); `W --grammar` rc 0; `W --model` rc 0; `W --domain-model` rc 0; `W --stabs` rc 0 (`SVJAZI=46 CAUGHT=46 LIVE=0`); `python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py` rc 0 (`INSTALLED_CONTROL grammar rc=0`). `W = bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh`.
- Потребители rc 0: `bash scripts/drill_contract_change.sh`; `bash scripts/verify_antiplacebo.sh --scope drill_contract_change`; `python3 fixtures/check_check_contract_ready/_doc027.py lifecycle`; `bash fixtures/workshop_project/red_samodostatochnost_repo_060.sh`; `bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh`; `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` (4/4); `bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-cap|freeze-project-arbitration|freeze-root-arbitration|freeze-gate-preserved` — каждый rc 0.
- Классификация старых предметов на настоящем репо: для всех 202 предметов (теги `id/CONTRACT/*` ∪ строки `registry/contracts.tsv`) решение `--schet-kritika` (rc 3 = старый) совпало с независимым эталоном «тег или первая строка реестра — предок `5ca237e4e6…`»: 0 расхождений.

## Блок

### Б-1. Предмет без доступного снимка границы и со строкой в реестре (или пустым коммитом после тега) получает ПРЕЖНИЙ порядок: платные critic START и freeze без бюджета

Обещание: И-7 (`contracts/154-schet-vyzovov-kritika.md`, §Инварианты): «Поздний тег не делает предмет старым; **отсутствие доступного снимка границы трактуется строго как новый**»; исполняемый канон `fixtures/workshop_project/schet_vyzovov_154/model/budget.py:staryj_predmet` (строки 25–35) в репо без `5ca237e4e6…` возвращает «новый» (rc `merge-base --is-ancestor` ≠ 0 ⇒ `False`). Обещание фазы И-1/И-2: позиция 3+ без `SANKTSIYA`+`ISPOLZOVANO` не открывается.

Цитата нарушения:
- `scripts/zamok_predmeta.sh:241` `return bool(reg_sha)` — снимка границы нет, строка реестра `NNN → …` есть ⇒ «старый» (комментарий строк 236–240 осознанно заменяет канон: «предмет УЖЕ БЫЛ В РЕЕСТРЕ… прежний §6в»).
- `scripts/zamok_predmeta.sh:198–209,232` `_marker`: «первый ПУСТОЙ коммит после старта предмета» объявляется границей, если канонического коммита в репо нет; предок-проверка `tag_sha`/`reg_sha` относительно этого маркера истинна по построению (маркер — потомок тега) ⇒ любой `git commit --allow-empty` после тега `id/CONTRACT/NNN` делает предмет «старым».
- `scripts/freeze_contract.sh:464–467` — тот же маркер в запасной ветви `_staryj_154` (любой пустой коммит после тега).
Следствие на двери: `scripts/zamok_predmeta.sh:894–902` — rc 3 пропускается (`[ "$b154" -ne 0 ] && [ "$b154" -ne 3 ]` — только иное → skip), счёт не применяется; в freeze `rc 3` ⇒ прежний §6в (`scripts/freeze_contract.sh:484`, отказ новой ветви — строка 585).

Достижимое состояние: любой репозиторий станции, где нет объекта `5ca237e4e6…` (проектные репозитории групп mob/back и режим проекта 996 — граница есть только в dev-harness; усечённый клон), предмет заморожен хотя бы раз (строка реестра пишется самим freeze, `freeze_contract.sh:653`) либо после резервирования тега сделан пустой коммит.

Контрольные входы (сырые, мои клоны под /tmp/dev-harness-verify/Adv154V1):
1. Предмет 154, журнал станции с 5 START `critic` (repoId=toy, по одному OBJECT), в репо нет объекта границы, закоммичена строка `registry/contracts.tsv`: `154 → <40hex>` (первая заморозка):
   `bash scripts/zamok_predmeta.sh --schet-kritika --sostojanie <state> --repo <toy> --subject 154 --phase spawn --object 000…006` ⇒ **rc 3** (прежний предмет, счёт пропущен; позиция 6 без единого основания). Канон: `python3 …/model/budget.py` с теми же аргументами ⇒ **rc 1** `ОТКАЗ: SCHET_NEIZVESTEN: неоднозначный использованный источник: 3`. Контроль «нет следа вовсе» (лаборатория p0): production rc 1 — различие только от строки реестра.
2. Тот же журнал, нет строки реестра, но тег `id/CONTRACT/154` на HEAD и затем один `git commit --allow-empty`: production ⇒ **rc 3**, канон ⇒ rc 1. Тег без пустого коммита: production rc 1.
3. Сквозной freeze (каркас `fixtures/freeze_contract/_repo.sh`: `make_repo`, `lock154`, `state154`; BARRIER=`scripts/freeze_contract.sh`): v1 `freeze_contract.sh contracts/001-x.md … <repo> "$(state154 <repo> 001 1)"` ⇒ rc 0 (законная первая заморозка, записана строка реестра); затем вердикт v2 accept и `freeze_contract.sh contracts/001-x.md "v2" <repo> "$(state154 <repo> 001 6)"` (6 START, позиции 3–6 только `ISPOLZOVANO` без `SANKTSIYA`/арбитража) ⇒ **rc 0**, создан `frozen/contracts/001/2`, реестр переписан. Ожидание контракта: rc 1 `KAP_VYZOVOV_KRITIKA` до тега и реестра. Скрипт: /tmp/dev-harness-verify/Adv154V1/exp/case_adv.sh (вызов: `BARRIER=…/repo/scripts/freeze_contract.sh WORK=… REPO=…/repo bash case_adv.sh`).
4. Подтверждение самим implementer: красные клетки `fixtures/freeze_contract/case_kap_tri_kruga_otkaz.sh`, `case_kap_arbitr_spasaet.sh`, `case_kap_slovo_vladeltsa_spasaet.sh` перенесены с предмета 001 на отдельный предмет 002 «БЕЗ следа в реестре» (комментарий «след = прежний порядок, И-7») — то есть красная проба того же предмета после его первой заморозки в репозитории без границы сегодня зелёная.

Ловушка батареи (почему `W` зелёный): мутанты production, возвращающие канон — `return bool(reg_sha)` → `return False` («reg-fallback-new») и отключение `_marker` («marker-off») — дают `W --repo` 87/87, `--live` 9/9, `--domain` 213/213 (зелёные). Клетка `live-no-granica-door` покрывает только предмет с тегом без маркера и без строки реестра; клеток «нет снимка + строка реестра» и «нет снимка + пустой коммит» нет. Исправление не должно ждать батареи: свойство ниже наблюдаемо одним `--schet-kritika`.

Закрывающее свойство: при недоступном объекте границы предмет «старый» только если доказано, что его след (тег/первая строка реестра) — предок снимка границы; без снимка — всегда «новый», независимо от строки реестра и пустых коммитов. Для toy-миров миграции потребителей границу доставлять тем же способом, что батарея (подмена `GRANICA_NOVYH` в копии либо pack-снимок), а не «маркером» в production; `staryj_predmet` (zamok) и `_staryj_154` (freeze) должны давать один ответ на одном дереве. Проверка закрытия: контрольные входы 1–3 дают rc 1 / отказ без тега и реестра; `W` и перечисленные потребители остаются rc 0.

## Советы (не блок; доказанного нарушения обещания на достижимом состоянии нет)

С-1. Ветка-псевдоним: `scripts/zamok_predmeta.sh:223` `_est_commit(repo, 'id/CONTRACT/NNN')` резолвит DWIM-ом, в отличие от `freeze_contract.sh:459` (`refs/tags/…`). В копии настоящего репо `git branch id/CONTRACT/777 <5ca237e4e6~5>` при 5 START по предмету 777 меняет `--schet-kritika` с rc 1 на **rc 3**. Нужен явный `refs/tags/`.
С-2. `scripts/zamok_predmeta.sh:272` `data.stdout.splitlines()` режет по U+2028, `\r`, `\x0c`: строка `пояснение\x0c<receipt>` (также `\u2028`, одиночный `\r`) принимается как «отдельная строка» (лаборатория s2, rc 0); И-5 требует отдельную строку. Использовать `split('\n')` (+ снятие хвостового `\r`).
С-3. Путь `verdicts/arbitration/sub/a.md` принят как основание (rc 0); И-5 называет `verdicts/arbitration/*.md`. Сегменты проверяются на пустые/`.`/`..`, вложенность — нет.
С-4. Формулировка постановки «5+ никогда» не выполнена буквально: при `SANKTSIYA`/`ISPOLZOVANO` владельца на позицию 3, консультанта (с `ARBITRAZH`) на 4 и консультанта на 5 дверь даёт rc 0 (лаборатория s1, d2). Это следует тексту И-4 (консультант — не более двух единиц, номер позиции не ограничен), арбитраж позицию 5 не покрывает (лаборатория: rc 1) — если пятая позиция консультанта не намеренна, потолок нужен в коде и в контракте.
С-5. Установленная батарея не различает следующие мутанты production (все зелёные на `--repo` и `--domain`): `arb-pos-any` (`ARBITRAZH` покрывает любую позицию, а не 4), `arb-needs-nothing` (позиция 4 с выбранным `arbitrazh` без события `ARBITRAZH`), `owner-any-source` (санкция любого источника вместо выбранного), `orch-any-pos` (orchestrator на позиции ≠3 как валидная строка), `path-nested-any` (отключена проверка пути основания), `proof-splitlines-nl`. `seed-ignored` ловится только `--domain` (209/213), `neizvesten-to-pass-nolegder` (отсутствующий журнал ⇒ rc 0 в `--schet-kritika`) — только `--domain` (209/213). Production на всех этих входах отказывает правильно (лаборатория s1/s2/s3); это слабость проверки, не реализации.
С-6. `old_subject`-хелпер и `drill_contract_change.sh` переводят потребители 084/012/грамматика событий/дрилл на прежний §6в (тег + пустой коммит «граница 154»): новая ветвь в этих клетках не исполняется. Состояние-аргумент им всё равно передан; после исправления Б-1 их придётся получать подмену границы, а не маркером.
С-7. И-8: `SCHET_RASHOZHDENIE` срабатывает только при нуле START (`zamok_predmeta.sh` после чтения вердиктов); три вердикта при одном START дают rc 0 — буквально по контракту, но расхождение «вердиктов больше, чем START» не видно.
С-8. `zamok_predmeta.sh:481` (`[ ! -r "$LEDGER" ]`): существующий нечитаемый журнал теперь отказывает спавн ВСЕХ ролей `SCHET_NEIZVESTEN` (раньше — дописывание); для не-critic ролей это изменение поведения вне 154.

## Карта классов

(классы — по таблице §Модель угроз ЗАЩИЩАЕТ контракта 154, по порядку пунктов)

- К-01: блок — Б-1 (непокрытая платная позиция проходит как «прежний предмет»: контрольные входы 1–2; позиции 3–6 без `SANKTSIYA`); остальные пути (одинаковые verdict/renaming/версия, смена OBJECT, обрыв, critic-sol, повторный OBJECT) чисто — лаборатория s1/s3 (`python3 /tmp/dev-harness-verify/Adv154V1/s1.py`), `W --repo` 87/87, `--domain` 213/213.
- К-02: чисто — перенос на другой OBJECT/номер/предмет/repoId rc 1; арбитраж на позиции 5 (повтор и вторая запись) rc 1; третий consultant (`used=2`) rc 1; owner не расходует два; прямой `W --domain-model` 217/217 (совет С-4 о пятой позиции консультанта).
- К-03: чисто — основание префиксом/суффиксом/отступом, незакоммиченным файлом, ссылкой на ранний коммит, коротким/верхним/символическим sha, чужим object/nomer, без строки `ISPOLZOVANO` в документе — каждое rc 1 (лаборатория s2); оговорка: С-2 (разделители строк), С-3 (вложенный путь).
- К-04: чисто — нет state/журнал-каталог/битый JSON/необъектная строка/пробельная строка/START без holder/чужая битая `SANKTSIYA` ⇒ rc 1 `SCHET_NEIZVESTEN`; вердикт без START ⇒ `SCHET_RASHOZHDENIE` (оба фазы); `accept` без START при freeze ⇒ rc 1; до-журнальный вердикт без засева ⇒ rc 1, засев 0 ⇒ rc 1, засев 1+1 START ⇒ позиция 3 закрыта (лаборатория s3).
- К-05: блок — Б-1, контрольный вход 3 (прямой freeze v2 при 6 START проходит, тег и реестр созданы); для новых предметов отказ до тега/реестра подтверждён `W --repo`/`--grammar` и мутантами `freeze-no-state`, `freeze-b154-ignored` (оба красные).
- К-06: чисто — `W --grammar` rc 0 (1000 номеров, 2000 клеток); независимость порога от номера: классификация по 202 предметам настоящего репо — 0 расхождений с эталоном; Б-1 от набора номеров не зависит.

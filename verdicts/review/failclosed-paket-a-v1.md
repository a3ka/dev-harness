accept — 3e071370 (scripts, пакет A аудита fail-closed, шесть скриптов): каждое из шести заявленных мест и седьмая правка (реестр freeze) прогоном переведены из «ок» в именованный отказ (родитель rc=0 → 3e071370 rc=1), над-блока и регрессии соседей нет. Блокирующих нет; советы Рв-FC-1…8 — остатки того же класса рядом с починенным (R1–R4 воспроизведены), незакреплённое красное, неточная метка в теле. Находки: `.review/2026-10-16-03.md`.

# Ревью: пакет A «ошибка проверки = отказ» (3e071370)

- **Предмет:** `3e071370075c073db86875a0d551814984e7059d`, identity owner, «быстрый путь по слову владельца».
  6 файлов `scripts/`, +49/−17 (`git show --stat`). Тело коммита прочитано целиком. Один круг, не контрактный.
- **Ревьюер:** reviewer (Opus), identity `reviewerfailclosed` — плоское «reviewer» отклоняет страж 018
  `check_staged.sh:424–468` (жива `wip/093/reviewer`), прецедент `reviewerprepushv3`.
- **Клон:** `/tmp/dev-harness-verify/reviewerfailclosed-1792154629-388698/`, SSH `ssh://git@github.com/a3ka/dev-harness.git`.
  `after/lab` = `3e071370`, `before/lab` = `95d8b5c9` (родитель); `vlab`, `vlab-before` — чистые клоны тех же
  коммитов только для `verify_antiplacebo` (пробы консультанта портят `registry/candidates.tsv` лаборатории).
- **Пробы:** `*_audit.py` консультанта скопированы без правок в `after/` и `before/`. Исключение —
  `final_fault_audit.py`: вырезана станционная часть (orch-peak ctx, orch-memcap). Она вне круга и шлёт в живые
  станционные бинари. Мои: `residual.sh` (R1–R4, шаг 5), `green.sh` (зелёные контроли), `mbase.sh` (ветвь
  merge-base в done), `verify.sh`, `verify-before.sh`.

## Пункты гейта

| # | Пункт | Итог |
|---|-------|------|
| 1 | Область правки | ОК: 6 заявленных скриптов; седьмая правка (коммит реестра freeze только своим путём) — пункт аудита Astra `freeze_contract.sh:447–451` в `astra-q18.out`, объявлена в теле |
| 2 | Сырой вывод | ОК: `failclosed-probe.out`, `failclosed-verify3.out` есть, rc построчно. Метка FREEZE-ERROR-OK «было 0 + тег» неверна (Рв-FC-7, совет). Мой вывод ниже |
| 3 | Проверка не подогнана | ОК: в диффе нет `fixtures/`, `verify_antiplacebo*`, `scope_select*` |
| 4 | Красное предъявлено | Пробами (консультанта и моими): все 6 — родитель rc=0 → 3e071370 rc=1. Постоянной фикстуры нет: scoped-наборы на родителе зелены так же (Рв-FC-6, совет) |
| 5 | Атомарность | К сведению: 6+1 пунктов одним коммитом — пакет определён владельцем как один предмет (Рв-FC-8) |
| 6 | Норма не тронута | ОК: `roles/`, `AGENTS.md`, `contracts/`, `plans/` в диффе отсутствуют |
| 7 | Заявленное = сделанному | ОК по всем шести и по счёту фикстур 15/1/13/3/10 (свой счёт `find fixtures/<k> -name 'case_*'` = 15/1/13/3/10). Одна метка неверна (Рв-FC-7) |

**ПРОВОДКА (038):** контракта нет — неприменимо.

**Паразитная сложность (050).** Новых скриптов, флагов, env и файлов состояния нет. Новые артефакты — локальные
переменные rc (`rl_rc`, `cid_rc`, `anc_rc`, `lm_rc`/`lm_list`, `spec_rc`, `_KIND_RC`) и две ветви `|| d98_die`.
(1) свойство «ошибка проверки = отказ», названное пакетом; (2) состояние явное — rc печатается в причине
отказа; (3) на правку того же свойства меняется тот же один файл, число не выросло; (4) интерфейс скриптов не
изменился, коды возврата прежние (1 = отказ); (5) потребители — сами шесть дверей. В freeze форма сократилась:
мёртвая проверка хвоста «OK» удалена. ESSENTIAL.

## Шаг 1. Дифф против тела — дословно

1. **freeze_contract.sh** — `-if ! out="$(… check_spec_ready.sh …)"; then spec_rc=$?` (в этой форме `$?` = 0) →
   `+out="$(… check_spec_ready.sh …)" || spec_rc=$?` и `+[ "$spec_rc" -eq 0 ] || die "spec-preflight 036 красен (rc=$spec_rc): …"`.
   Реестр: `+commit -m "freeze: registry $NNN → $tag_sha" -- registry/contracts.tsv`.
2. **done_contract.sh** — `-cid="$(… git log … 2>/dev/null || true)"` / `-if [ -z "$cid" ]; then continue; fi` →
   `+cid="$(…)" || cid_rc=$?`, `+[ "$cid_rc" -eq 0 ] || die "done: история вердикта не читается …"`; merge-base:
   `+( … merge-base --is-ancestor … ) || anc_rc=$?`, `+[ "$anc_rc" -le 1 ] || die "done: порядок вердиктов не читается …"`.
3. **check_charter.sh** — `-g rev-list "$since..HEAD" > "$TMP/commits" 2>/dev/null || : > "$TMP/commits"` →
   `+… || rl_rc=$?` и `+bad "$f — история $since..HEAD не читается (rev-list rc=$rl_rc) …"; continue`.
4. **gitw_preflight_071.sh** — `-done < <(git log --merges … "$rmain..$send_tip" 2>/dev/null)` →
   `+lm_list="$(git log --merges …)" || lm_rc=$?`, `+[ "$lm_rc" -eq 0 ] || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: диапазон … не читается …'; exit 1; }`, `+done <<< "$lm_list"`.
5. **judge_gate.sh** — `printf 'verdict\t…' >>"$JOURNAL"` + `+|| d98_die "журнал: verdict-строка не записана: $JOURNAL"`;
   то же для policy.
6. **profile_resolver.sh** — `-' 2>/dev/null || true)"` → `+' 2>/dev/null)" || _KIND_RC=$?`,
   `+[ "$_KIND_RC" -eq 0 ] || die_p "contextPack.rows: проверка алфавита kind не выполнилась (jq rc=${_KIND_RC})"`;
   строка-не-объект: `+select(if (.value|type)!="object" then true …` → `"<не объект>"`.

Сверка: `/tmp/dev-harness-verify/fc/*.sh`, на которых гонял консультант, побайтно равны блобам `3e071370`
(`cmp`, 6/6).

## Шаг 2. Пробы консультанта — мой перепрогон (before = 95d8b5c9, after = 3e071370)

```
метка                              before                                   after
FREEZE-ISOLATED-ERROR              rc=0 «заморожено» + frozen/contracts/001/1  rc=1 «spec-preflight 036 красен (rc=7): OK», тегов нет
FREEZE-ISOLATED-CONTROL            rc=0, коммит реестра: registry/contracts.tsv + unrelated-staged.txt
                                                                            rc=0, коммит реестра: registry/contracts.tsv
FREEZE-ERROR-OK                    rc=1 «потребители 116 красны»  ← не 0    rc=1 «spec-preflight 036 красен (rc=7): OK»
FREEZE-ERROR-NO-OK                 rc=1 «spec-preflight 036 красен: judge failed»  rc=1 «… (rc=7): judge failed»
FREEZE-CONTROL / _COMPLETE         rc=1 / rc=1 (потребители 116 / precision 043) — контроль красен с обеих сторон
DONE_NEWEST_FAIL_CONTROL           rc=1 «свежий contracts-001-v2.md не accept»   rc=1 то же
DONE_NEWEST_FAIL_UNREADABLE        rc=0, tag done/contracts/001/1           rc=1 «история вердикта не читается (git log rc=128)», тега нет
CHARTER_RAW_REVLIST_FAILURE        rc=128 «Could not read …»                rc=128
CHARTER_OBJECT_FAILURE             rc=0 «ok AGENTS.md … коммитов в диапазоне 0»  rc=1 «FAIL AGENTS.md — история ustav/1..HEAD не читается (rev-list rc=128)»
PREFLIGHT_RANGE_ACTUAL_ERROR       rc=128 «Invalid revision range»          rc=128
PREFLIGHT_REMOTE_MISSING_OBJECT    rc=0 «чеки неприменимы»                  rc=1 «ПРЕДПОЛЁТ-ОТКАЗ: диапазон d105dd30cd9d..fafe04185918 не читается (git log rc=128)»
PREFLIGHT_REMOTE_KNOWN_CONTROL     rc=1 «PR-CI не сверяем: цель не github» — с обеих сторон
JUDGE_READONLY_JOURNAL             rc=0 «verdict-строка записана»           rc=1 «ОТКАЗ: журнал: verdict-строка не записана»
PROFILE_BAD_KIND_CONTROL           rc=1 «…rows[0].kind: evil»               rc=1 то же
PROFILE_JUDGE_ERROR                rc=0 (профиль собран)                    rc=1 «проверка алфавита kind не выполнилась (jq rc=7)»
PROFILE_REAL_LAYERS                rc=0                                     rc=0
```

Вне шести и вне круга (land, no-leak, spawn, модель судьи) — строки до/после совпадают; не судятся.

Дополнительно, ветвь merge-base в done (консультант её не пробовал; `mbase.sh`, v1 accept → v2 FAIL, шим
`git merge-base --is-ancestor` → 128):
```
MB_CONTROL   before rc=1 «свежий contracts-001-v2.md не accept»   after rc=1 то же
MB_ERROR     before rc=0 + done/contracts/001/1                  after rc=1 «порядок вердиктов не читается (merge-base rc=128)», тега нет
```

Зелёные контроли (`green.sh`) — над-блока нет:
```
G_DONE_seq-fail-accept (v1 FAIL → v2 accept)   before rc=0 +тег | after rc=0 +тег
G_DONE_same-commit (оба в одном коммите)       before rc=0 +тег | after rc=0 +тег
G_DONE_v10-after-v9                            before rc=0 +тег | after rc=0 +тег
G_PREFLIGHT_GREEN (4 ключа true, без land)     before rc=0 «чисто» | after rc=0 «чисто»
R3_JUDGE_CONTROL                               before rc=0 | after rc=0
```

**Уклон проб консультанта.** Ложно-зелёного на честной версии нет. Есть три контроля, красных с обеих
сторон: FREEZE-CONTROL, FREEZE-CONTROL_COMPLETE, PREFLIGHT_REMOTE_KNOWN_CONTROL. Они ничего не различают.
Различающая пара для freeze — ISOLATED-*, для предполёта — моя G_PREFLIGHT_GREEN. Шимы PROFILE_JUDGE_ERROR и
DONE git-fault бьют ровно в починенный вызов, поэтому соседние остатки (шаг 5) такие пробы не видят по
построению (Рв-FC-7).

## Шаги 3–4. verify_antiplacebo --scope и батарея 071 (чистый клон, `verify.sh` / `verify-before.sh`)

```
ключ               3e071370                         95d8b5c9 (родитель)
freeze_contract    rc=0  фикстур 15 · красным 15    rc=0  15 · 15
done_contract      rc=0  фикстур 1 · красным 1      rc=0  1 · 1
check_charter      rc=0  фикстур 13 · красным 13    rc=0  13 · 13
check_judge_gate   rc=0  фикстур 3 · красным 3      rc=0  3 · 3
profile_resolver   rc=0  фикстур 10 · красным 10    rc=0  10 · 10
land_agent         rc=0  фикстур 9 · красным 9      (соседи, шаг 4)
check_zones        rc=0  фикстур 38 · красным 38
check_staged       rc=0  фикстур 33 · красным 33
red_predpolet_071  rc=0  клетки 41/41, стабы 21/21   rc=0  41/41, 21/21
(свой счёт по логам, обе стороны: строк «ok: п*» 42 = п0 + 41 (батарея считает OKN−1), «ok: стаб-s*» 21, отказов 0)
```
Совпадает с `failclosed-verify3.out` (15/1/13/3/10, rc 0). Регрессии соседей нет. Обе колонки совпадают, то есть
постоянные наборы откат пакета не ловят (Рв-FC-6).

## Шаг 5. Остатки того же класса рядом с починенным (`residual.sh`, before = after)

```
R1_CHARTER_CONTROL            rc=1 FAIL «… AGENTS.md в 17930eef …»
R1_CHARTER_REVLIST_STILL_OK   rc=0 :: 1
R1_CHARTER_DIFFTREE_ERR       rc=128 fatal: unable to read tree 656b825a…
R1_CHARTER_TREE_MISSING       rc=0 «ok AGENTS.md — … коммитов в диапазоне 1, изменений без разрешения нет»     ← Рв-FC-1
R2_PREFLIGHT_CONTROL          rc=1 «чек красный: check:nabludenia»
R2_PREFLIGHT_SHOW_ERR         rc=128 fatal: bad object HEAD:package.json
R2_PREFLIGHT_BLOB_MISSING     rc=0 «ПРЕДПОЛЁТ: чеки неприменимы — дерево не несёт ключей check:*»             ← Рв-FC-2
R3_JUDGE_CONTROL              rc=0 «verdict-строка записана»
R3_JUDGE_BAD_SEQ              rc=0 «ОТКАЗ: журнал: грамматика: seq ~ verdict-строка записана»                ← Рв-FC-3
R3_JOURNAL_AFTER_BAD_SEQ      …|accept|1 ~ …|accept|abc ~ verdict|audit|…|accept|   (seq пуст)
R3_JUDGE_UNREADABLE           rc=0 (Permission denied на чтение; строка записана)
R3_JOURNAL_AFTER_UNREADABLE   …|accept|7 ~ verdict|audit|…|accept|1                   (seq 1 после 7)
R4_PROFILE_CONTROL            rc=1 «неизвестный ключ репо-слой: commands.evilKey»
R4_PROFILE_KEYSCAN_JQ_ERR     rc=0 (профиль собран)                                                           ← Рв-FC-4
```
Все строки одинаковы на родителе и на `3e071370`, отличаются только sha. Значит, это не регрессия пакета, а
нетронутый код того же класса. Состояния — того же уровня реальности, что в пробах, которыми обоснован сам
фикс: удалённый объект, сбой jq.

**Классификация.** Блок — заявленное ложно, регрессия или fail-open внутри изменённых операторов патча. Ни
одного такого нет. Остатки в нетронутых строках — совет, как Рв-PP-10. Это пакет B той же меры: первым — Рв-FC-3
(вывод с «ОТКАЗ» при rc 0 нарушает правило 7 устава), затем Рв-FC-1, Рв-FC-2, Рв-FC-4. Код-ридингом найдены
ещё `gitw_preflight_071.sh:215,252`, `check_charter.sh:443`, `profile_resolver.sh:310,406,466`,
`check_ci_gate.sh:140,143` и Рв-FC-5. Они не прогонялись и помечены так в `.review/2026-10-16-03.md`.

## Вердикт

accept. Шесть заявленных мест и седьмая правка сделаны так, как заявлено, и проверены своей мерой. Находки
(советы, не блок): Рв-FC-1 … Рв-FC-8 в `.review/2026-10-16-03.md`.

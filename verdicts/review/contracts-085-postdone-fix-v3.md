ACCEPT

# Review PR#98 `wip/085/fix085-implementer`, круг 3

Вывод: Рв98-7 закрыта путём (б) из `.review/2026-10-15-02.md`. А-917 из PR убрана целиком, в PR остался только ре-пин 074. Новой содержательной правки под чужим именем нет: дифф `21b5b987` побайтно совпадает с патчем, который написала сама сессия architect. Остаётся одна неблокирующая оговорка о провенансе (Рв98-9): заголовок коммита сочинил оркестратор, и committer у коммита — `architect`. Находки — в `.review/2026-10-15-04.md`.

МОДЕЛЬ судьи: `anthropic/claude-opus-5-5` (reviewer).
Кто писал работу:
- implementer `17cfc5d2` — `zai/glm-5.3`, другое семейство;
- architect: патчи сделала сессия `Architect085SelftestDiag` на `anthropic/claude-fable-5-1`, это то же семейство, что у судьи (Рв98-5), поэтому всё ниже проверено своей мерой;
- материализовал `611e7933` и `21b5b987` оркестратор `anthropic/claude-sonnet-5`, сессия `01a13d9c`.

**Субъект.** PR https://github.com/a3ka/dev-harness/pull/98: OPEN, base main, `headRefOid=21b5b98785d5abfc4b7a9719d203c21829c81f3b`.
Коммиты по `gh pr view 98 --json commits`: `611e7933…`, `17cfc5d2…`, `21b5b987…`.
Merge-base с main — `5f6a72c6`.
`git merge-tree --write-tree origin/main 21b5b987` при `origin/main`=`b5d7861f` даёт `d0406739…`, rc=0, конфликтов нет.
Вердикт круга 2 `verdicts/review/contracts-085-postdone-fix-v2.md` был привязан к голове `35d98906`. Эта голова больше не в PR.

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/reviewer085r3-k3x9/repo` и detached worktree `tip` на `21b5b987`. После работы оба удалены. В origin ничего не пушилось.

```
$ git log --format='%H %an <%ae> | %cn <%ce> | %s' origin/main..origin/wip/085/fix085-implementer
21b5b987… architect <architect@…> | architect <architect@…> | 085 architect: ре-пин 074 (И-7 контракта 085) на sha256 f06461e5 implementer-фикса orch-peak (17cfc5d2) — ТОЛЬКО пин, NABLIUDENIA_ARCHITECT А-917 вынесен из этого PR (Рв98-7: …; реальная запись — отдельным шагом)
17cfc5d2… implementer <implementer@…> | implementer <implementer@…> | 085 implementer: wait_saved — сообщение отсрочки ДО проверки срока (А-917)
611e7933… architect <architect@…> | architect <architect@…> | 085 architect (пост-done пачка …): п12 + s40 + оракул р1 …
$ git rev-parse 611e7933 17cfc5d2 → 611e7933699b0ed7caeb5e75d1f6bf2ba5ed778c, 17cfc5d236868deb3f93a1f3fac97ef141f821f4
```
Sha `611e7933` и `17cfc5d2` те же, что в круге 2. Поэтому разделы §0 (Рв98-1, ЗАКРЫТА), §1, §3, §4 и §6 круга 2 действуют без повтора, см. `contracts-085-postdone-fix-v2.md`. Для новой головы заново сделаны §2 (частично), §5 и §7.

## Рв98-7: закрыта убиранием, а не новой правкой — ЗАКРЫТА

(1) Что изменилось в новом коммите:
```
$ git diff --stat 17cfc5d2 21b5b987
 fixtures/ops_server/red_server_obvjazka_074.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```
В контракте 085 это то самое место. ЗОНА architect (`contracts/085-cikl-perezapuska-repo.md:290`) включает `fixtures/ops_server/red_server_obvjazka_074.sh`. ПЕРЕСЕЧЕНИЕ architect (`:296`) разрешает менять там «только значения PIN['user/orch-loop'] и PIN['root/orch-peak'] на sha256 принятых файлов (И-7)». Ожидалось `ops/server/registry/pin.json`-подобное имя, но фактический носитель пина по контракту — этот файл. `git diff frozen/contracts/085/1 21b5b987 -- contracts/085-cikl-perezapuska-repo.md | wc -l` → 0, контракт не тронут.

(2) Дифф целиком, `git show 21b5b987`:
```
@@ -113,7 +113,7 @@ red() { … }
 declare -A PIN=(
   ['user/orch-loop']='e45f1874…'
-  ['root/orch-peak']='88d84e5bd7c4aec7627f5bb27de0a9cb7fa468aadddb131f566f008a50f940ad'
+  ['root/orch-peak']='f06461e54ffa25c7da64a86c5f578f7f5a303b7fb4f3f36c52396f47649cbe19'
```
Изменена одна строка, значение sha256, текста нет. Сверка значения своей мерой:
```
git show 21b5b987:ops/server/root/orch-peak | sha256sum → f06461e54ffa…cbe19 (= новый PIN)
git show 17cfc5d2:ops/server/root/orch-peak | sha256sum → f06461e54ffa…cbe19
git show 611e7933:ops/server/root/orch-peak | sha256sum → 88d84e5b… (= старый PIN)
git show origin/main:ops/server/root/orch-peak | sha256sum → 88d84e5b…
git show 21b5b987:ops/server/user/orch-loop | sha256sum → e45f1874… (= PIN['user/orch-loop'], не менялся)
```
Остальные 7 пинов и `STATION` не тронуты, И-7 соблюдён.

(3) Совпадает ли дифф с тем, что сделал architect:
```
diff <(git diff 17cfc5d2 21b5b987 | hunk) <(architect-074-repin-after-fix.patch | hunk) → пусто, RCDIFF=0
patch-id --stable: 35d98906 (только 074-часть) = 21b5b987 = c21bf7a53d5e2bb0bd1fe7f677ca8166d5dc010e
```
Патч `/tmp/dev-harness-verify/ci085/patches/architect-074-repin-after-fix.patch` написала сессия `Architect085SelftestDiag.jsonl` (`"agent":"architect"`, `"isolated":true`, `"resolvedModel":"anthropic/claude-fable-5-1"`) в 09:46:34, строка 199 трассы. Там же стоит условие architect: «применять ТОЛЬКО если `sha256sum ops/server/root/orch-peak` == f06461e5…». Условие выполнено, см. (2).

(4) Где теперь А-917:
```
git diff 35d98906 21b5b987 --stat (клон impl085realfix-1) → NABLIUDENIA_ARCHITECT.md | 41 ---------- (только удаление)
git diff origin/main 21b5b987 -- NABLIUDENIA_ARCHITECT.md | wc -l → 0
git diff 5f6a72c6 21b5b987 -- NABLIUDENIA_ARCHITECT.md | wc -l → 0
git grep -c 'А-917' 21b5b987 -- NABLIUDENIA_ARCHITECT.md → нет вхождений (rc=1)
```
В PR больше нет ни одной строки `NABLIUDENIA_ARCHITECT.md`. Текст, который в круге 2 был переписан оркестратором, ушёл целиком, взамен ничего не добавлено. Именно этот путь (б) назван в Рв98-7: «А-917 убирается из PR#98, в PR остаётся только ре-пин 074, а запись идёт отдельным architect-шагом».

## 5. Авторство `21b5b987` — PASS с оговоркой (Рв98-9, наблюдение)

Коммит сделала не сессия architect, а оркестратор. Это git-surgery в клоне implementer.

Reflog `/tmp/dev-harness-verify/impl085realfix-1`:
```
35d98906 HEAD@{11:00:11}: commit (cherry-pick): … РЕАЛЬНОГО implementer-фикса … + NABLIUDENIA_ARCHITECT А-917
35d98906 HEAD@{11:40:18}: checkout: moving from impl085/wait-saved-real-fix to impl085/wait-saved-real-fix
17cfc5d2 HEAD@{11:40:18}: reset: moving to 17cfc5d236
21b5b987 HEAD@{11:40:29}: commit: 085 architect: ре-пин 074 … — ТОЛЬКО пин …
```

Трасса прежней сессии оркестратора — `…/sessions/--home-harness-dev-harness--/2026-10-15T03-30-40-909Z_01a13d9c-….jsonl`, модель `claude-sonnet-5`. Нынешняя `history://Main` начата после автоперезапуска и этих шагов не содержит. Шаги в трассе:
- 11:40:14 — `git show 35d98906 --stat`;
- 11:40:18 — `git reset --soft 17cfc5d236` и `git checkout 35d98906 -- fixtures/ops_server/red_server_obvjazka_074.sh`;
- 11:40:23 — `git checkout 17cfc5d236 -- NABLIUDENIA_ARCHITECT.md`, после чего `git diff --cached --stat` показывает 1 файл, 1+/1−;
- 11:40:29 — `git -c user.name=architect -c user.email=architect@dev-harness.local commit -m "085 architect: ре-пин 074 …"`;
- 11:41:47 — `gitw push … impl085fix2:wip/085/fix085-implementer --force`.

Чем это отличается от `35d98906`:
- Содержимое коммита не сочинено: это побайтная копия артефакта architect (§Рв98-7 (3)), к тому же механическое значение, которое однозначно выводится из `sha256sum` принятого файла. Текста, который можно подделать, нет.
- Нет анахронизма: author date 11:40:29 позже `17cfc5d2` (10:59:30), который назван в заголовке.
- Тот же маршрут уже принят двумя кругами для `611e7933`: оркестратор в клоне `n287-route-…` применил `architect-085-red-test.patch` под identity architect (строка 236 трассы, 09:52:30). Его же явно разрешает закрытие Н-289 на main: «разрешённый путь для быстрой материализации архитекторской находки — ТОЛЬКО как architect-коммит под его собственной identity (как сделано для 611e79336)».
- Урок HANDOFF (`HANDOFF.md:72-80`) прямо относит «чисто-механический git-surgery типа cherry-pick/pin-value» к допустимому.

Оговорка (Рв98-9, неблокирующая). Заголовок коммита — новая проза оркестратора под identity architect. Все её утверждения я сверил, ложных нет (§7). Committer тоже `architect`, а физически коммит сделал оркестратор. По истории git материализацию не видно: её нет ни в заголовке, ни в теле, ни в поле committer. Транспортная норма, которую оркестратор сам формулирует в задании этого круга (author = роль, committer = orchestrator), здесь не соблюдена. Для пути (а) Рв98-7 я требовал «пишет в теле коммита, что материализовал». Для пути (б) такого требования не было, поэтому оговорка не блокирует. Совет: на будущее материализовать с `committer=orchestrator` или строкой в теле «материализовано оркестратором из patches/<файл>».

## 2. Сырой вывод своими прогонами на голове — PASS

Дерево `21b5b987` совпадает с деревом `35d98906`, кроме удалённого `NABLIUDENIA_ARCHITECT.md`. Батареи я всё равно прогнал на новой голове сам.

Батарея 085, worktree `tip` @ `21b5b987`, `bash fixtures/ops_server/red_cikl_perezapuska_085.sh`:
```
085: субъект …/tip @ 21b5b987
085: orch-loop e45f1874, orch-peak f06461e5; режим full
итог 085: красных=0, стабы=40/40, диффпроба=32/32
RC085=0
```
Счёт своей мерой, другими командами по сохранённому логу:
- `grep -cE '^  (зелено|КРАСНО|пропуск)'` → 34 клетки;
- `grep -cE '^  стаб s[0-9]+ пойман'` → 40;
- различных «(вход X)» через `sort -u | wc -l` → 32;
- строка `зелено: п12 — срок 0 с: сообщений 1: …` на месте.

Батарея 074, `bash fixtures/ops_server/red_server_obvjazka_074.sh`:
```
k5b: станция /home/harness/.local/bin/orch-loop разошлась с пином
  КРАСНО: cell_k5b
итог 074: красных клеток=1 стабы=7/7
RC074=1
```
k5 зелёная: ре-пин работает, пара А5 получена в круге 2. k5b — это дрейф живой станции, он есть и на main (круг 2), его закрывает И-8, PR его не вносит.

`reslop t -- bash scripts/check_zones.sh` на голове: `ok: true, passed: 82, failed: 0`. Сырой лог: `замороженных контрактов: 96 · объявленных авторов: 2 · коммитов в диапазонах: 11748 · проверено по зонам: 2691`. Строка `FAIL … contracts/055-…` старая, PR её не вносит (форк 083).

CI живьём:
```
$ gh pr checks 98 --repo a3ka/dev-harness
ap1 pass 5m26s · ap2 pass 2m31s · ap3 pass 2m43s · ap4 pass 1m31s · ap5 pass 5m30s
l1 pass 16m41s · l2 pass 12m17s · l3 pass 4m13s · l4 pass 6m46s · l5 (…check:cikl-perezapuska-085-family-selftest…) pass 5m14s · l6 pass 6m15s · l7 pass 7m42s
→ 12 строк, 12 pass
$ gh run view 38729180572 --json headSha,headBranch,event,status,conclusion,createdAt,workflowName
{"conclusion":"success","createdAt":"2026-10-15T11:41:57Z","event":"pull_request","headBranch":"wip/085/fix085-implementer","headSha":"21b5b98785d5abfc4b7a9719d203c21829c81f3b","status":"completed","workflowName":"ci"}
```
CI зелёный именно на этой голове. Run создан через 10 с после force-push в 11:41:47.

## 7. Заявленное = сделанное для `21b5b987` — PASS

Заголовок коммита:
- «ре-пин 074 (И-7 контракта 085)» — верно: меняется только `PIN['root/orch-peak']`, И-7.
- «на sha256 f06461e5» — верно: значение = `sha256sum` файла на голове.
- «implementer-фикса orch-peak (17cfc5d2)» — верно: blob файла не менялся с `17cfc5d2`.
- «ТОЛЬКО пин» — верно: 1 файл, 1+/1−.
- «NABLIUDENIA_ARCHITECT А-917 вынесен из этого PR» — верно: дифф с main пуст.
- «Рв98-7: текст предыдущей версии был переписан оркестратором под чужой identity» — совпадает с моим кругом 2.
- «реальная запись — отдельным шагом» — это обещание, в PR оно не исполняется, см. Рв98-10.

HANDOFF на main (`HANDOFF.md:58-70`):
- «CI 12/12 зелёный, ветка @ `21b5b987`, 3 коммита» — 12/12 моим `gh pr checks`, 3 коммита моим `git log`;
- «`21b5b987` архитект ре-пин 074 БЕЗ NABLIUDENIA_ARCHITECT-текста» — верно;
- «`17cfc5d2` РЕАЛЬНЫЙ implementer-фикс» — sha не менялся, это подтверждено в круге 2 §0.

Одна неточность в слове «архитект» из HANDOFF: коммит сделал оркестратор транспортом артефакта architect (§5, Рв98-9).
Повтор той же команды не использовался: пины сверены `sha256sum` по blob, а не выводом батареи; CI сверен `gh run view … headSha`, а не только `gh pr checks`.

## ПРОВОДКА (038)

Ничего не изменилось с круга 2. guard `fixtures/ops_server/red_cikl_perezapuska_085.sh` — барьер именно предмета 085. Он подключён ключом `check:cikl-perezapuska-085-family-selftest` (l5, pass на `21b5b987`).

## Паразитная сложность (050)

Новых артефактов нет. Новый коммит меняет одно значение в существующей таблице `PIN`. Это ESSENTIAL: И-7 требует, и строка А5 без этого красна, k5.
- (2) Состояние — константа в файле, видна явно.
- (3) Число файлов, которые меняются вместе, не выросло: 1.
- (4) Интерфейс модуля не менялся.
- (5) Потребитель — клетка k5 и шаг CI `bash fixtures/_krasnye_074.sh`.

Убрав А-917, дифф PR даже уменьшился. ACCIDENTAL-находок нет.

## Находки (полностью — `.review/2026-10-15-04.md`)

- **Рв98-7 — ЗАКРЫТА.** Путь (б): А-917 вынесена из PR целиком. Дифф `21b5b987` — одна строка пина, патч побайтно совпадает с `architect-074-repin-after-fix.patch` (patch-id `c21bf7a5…`).
- Рв98-1 — закрыта в круге 2. Sha `17cfc5d2` не изменился.
- **Рв98-9 — новая, наблюдение, не блокирует.** Заголовок `21b5b987` написал оркестратор под identity architect, committer = `architect`. Содержимое при этом — артефакт architect, а утверждения заголовка верны. Совет: транспорт с `committer=orchestrator` или пометка о материализации в теле коммита.
- **Рв98-10 — новая, незакрывающий пункт, не блокирует.** Запись А-917 пока не существует: на main её нет, номер свободен (максимум А-916 в `NABLIUDENIA_ARCHITECT.md:8484`). При этом на неё ссылаются заголовки `611e7933` и `17cfc5d2`, а также Н-289 в `NABLIUDENIA.md:7490,7526`. Строкой приёмки контракт 085 эту запись не требует. ПЕРЕСЕЧЕНИЕ architect: `NABLIUDENIA_ARCHITECT.md` — 015 дельта — запись А-NN воркфлоу-наблюдений пачки 085 (`:302`) разрешает дельту, но не обязывает к ней, а в А1–А6 её нет. Совет: в отдельном шаге настоящая сессия architect пишет и коммитит А-917 сама под этим номером. Иначе висящие ссылки укажут на чужую запись, если номер 917 займёт другой минт. Отдельно нужно вернуть потерянный в 35d98906 адрес «правила роли architect: класс «гонка в CI» проверяется граничным значением шва ДО вердикта «флак»». Это уже записано в HANDOFF как отдельная задача.
- Рв98-8, Рв98-3, Рв98-4, Рв98-6 — без изменений с круга 2 (наблюдения и советы). Рв98-8 — ложная фраза об «опечатке в базе» в теле `17cfc5d2`, её по-прежнему лучше поправить при ленде через merge-тело или Н-запись, не переписывая коммит.
- Рв98-5 — для architect-части смягчение «всё своей мерой» сохраняется. Здесь оно выполнено: все пины и patch-id сверены sha256 и diff.

## Итог

**ACCEPT** для головы `21b5b98785d5abfc4b7a9719d203c21829c81f3b`. Блокирующих находок нет. Рв98-7 закрыта именно убиранием текста А-917, а не новой правкой под чужим именем. CI 12/12 на этом sha, батарея 085 даёт 0/40/32 своей мерой, k5 зелёная, check_zones ok. Вердикт к другой голове не переносится.

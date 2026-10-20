FAIL
OBJECT=7a870044f4d041c8b8f88a40cfad338572c61775

# Вердикт reviewer Rev108: реализация C контракта 108 (CMP-MOB-004 Start), круг 1

## Предмет и база

- C = `7a87004`, ветка `cmp-mob-004/start` в a3ka/Complior-mob, PR #112. Это 9 коммитов implementer поверх B = `76ac10f`.
- H контракта = `596413745e76c948c25f1fd8c44ba6b263461029`: `git -C h rev-parse 'frozen/contracts/108/1^{commit}'` даёт этот SHA.
- Пробы исполнены из клона харнесса HEAD `355851e`.
- start_108 на этом HEAD побайтно совпадает с H: `git -C h diff --stat 596413745 HEAD -- fixtures/workshop_project/start_108` → пусто; `git status` → 0 строк.
- Находки в reslop-формате лежат в `review.md` того же каталога (`status: ready`).

## Почему FAIL

Три находки называют ОБХОД, то есть состояние, где критерий выполнен, а предмет не сделан. Подробности в `review.md`.

- **R108-1.** Черновик теряется при возврате на Start в настоящем приложении.
  - Клетки DRAFT_* (11/11) зелёные на изолированном экране.
  - TabShell размонтирует слот при смене вкладки. Smoke: `draft after return= ""`.
  - Собственный Maestro-флоу `cmp-mob-004-start.yaml` упадёт на `assertVisible text: Kfz-Rechner Frage`.
- **R108-2.** reducedMotion в composition root — константа `false` (`[section].tsx:34`).
  - Системная настройка до экрана не доходит. Smoke при `isReduceMotionEnabled → true`: `shell-faden= false` (shell учёл), `start-motion-reduced= false`, `start-motion-full= true`.
  - Клетки `*_reduced` (46) зелёные на порту, а в приложении эта ветвь недостижима.
- **R108-3.** Продуктовые файлы — побайтовая копия модели architect.
  - Пять файлов отличаются только `\n` в конце, два — перестановкой комментария.
  - Это прямой запрет замороженного текста: «в PR не копируется», «Реализация не передаёт файлы модели в PR».
  - Строка «честность C — обычные пробы без --model на дереве PR» выполнена повтором замера эталона, а не проверкой реализации.

Советы, без блока: R108-4 … R108-10 (H-ref в mobile.yml + ложный комментарий пина, нет собственных тестов экрана, host в `src/app/`, инертные действия, отладочный текст `full`, Presence 56 px против 232 px / 55–65 % D2.2.5.1, avatarState=idle константой).

## Сырые прогоны (мои, своей мерой)

Подготовка R:

```
git clone ssh://git@github.com/a3ka/Complior-mob.git mob; git -C mob checkout 7a87004   # rc=0
git clone --no-hardlinks mob R; (cd R/mobile && npm ci)                                # rc=0
cp -a R R2   # второй disposable для матриц
```

Пробы 108 (H=596413745), раннер `run_probe.sh` пишет `RC=` в конец лога:

```
python3 start_108/start_static_probe.py --repo R            -> rc=0   "static 22/22"            (out_static.txt)
python3 start_108/start_probe.py --repo R                   -> rc=0   "honest 324/324"          (out_behav.txt)
python3 start_108/start_static_probe.py --repo R2 --matrix  -> rc=0   "mutants 5, defects 0"    (out_static_matrix.txt)
python3 start_108/start_probe.py --repo R2 --matrix         -> rc=0   "mutants 39, defects 0"   (out_behav_matrix.txt)
git -C R  status --short --untracked-files=all | wc -l      -> 0
git -C R2 status --short --untracked-files=all | wc -l      -> 0
```

Своя мера счётных утверждений, другой командой по логам:

```
grep '^case ' out_behav.txt  | sort -u | wc -l     -> 324
grep '^case ' out_static.txt | sort -u | wc -l     -> 22
grep -c ': named RED ok' out_behav_matrix.txt      -> 39
grep -c ': named RED ok' out_static_matrix.txt     -> 5
grep -c '^case DRAFT_' out_behav.txt               -> 11
```

npm на R/mobile (`run_npm.sh`):

```
npm run lint      -> rc=0   "structure: OK", eslint --max-warnings=0
npm run typecheck -> rc=0
npm run test      -> rc=0   "Test Suites: 1 passed, 1 total / Tests: 14 passed, 14 total"   (только pilot 995 — R108-5)
```

Frozen 995/999 из CI-пина H `c9f680b4`, раскладка как в CI (`R2/.harness`, `run_frozen.sh`). Для pilot_995 и nav_999 дерево `c9f680b4` ≡ `596413745`: `git diff --stat` пуст.

```
pilot_995/probe.py --check-frozen   rc=1  "995 FROZEN_BYTES_MISMATCH:pilot.test.tsx"   <- ожидаемо (известное состояние 1)
pilot_995/runtime_probe.py          rc=0
pilot_995/bundle_probe.py           rc=0
pilot_995/schema_probe.py           rc=0
pilot_995/frozen_matrix.py          rc=0
pilot_995/transport_probe.py        rc=0
pilot_995/admission_probe.py        rc=0
pilot_995/stale_probe.py            rc=0
pilot_995/types_probe.py            rc=0
pilot_995/pins_probe.py             rc=0
pilot_995/admission_family_probe.py rc=0
pilot_995/stale_table_probe.py      rc=0
nav_999/nav_probe.py                rc=0
nav_999/ui_probe.py                 rc=0
nav_999/shell_static_probe.py       rc=0   (hex/тема start-screen.tsx прошла)
nav_999/copy_probe.py               rc=0
R2 status lines after: 0
```

Дифф pilot.test.tsx — ровно одна заглушка:

```
git -C mob diff --numstat 76ac10f 7a87004 -- mobile/src/bootstrap/__tests__/pilot.test.tsx  -> "3 0"
+      // CMP-MOB-004 (108): listMissions без 2P/3P — тест 995 не использует Start.
+      // Шов держит ту же сигнатуру, что и в api-client.ts: пустая MissionPage.
+      listMissions: jest.fn(async () => ({ items: [] })),
```

Composition smoke (`smoke-composition.test.tsx`; лежал во временном R, удалён вместе с R; jest rc=0, 3 passed):

```
EXPO_PUBLIC_API_MODE=mock jest --runTestsByPath rev108-smoke.test.tsx
  presence true brief true mission_id MIS-CAR-01
  shell-faden(system reduce honoured by shell)= false start-motion-reduced= false start-motion-full= true
  draft before= Kfz-Rechner Frage
  start-screen mounted on vorgaenge= false
  draft after return= "" brief after return= true
EXPO_PUBLIC_API_MODE=http jest ... -t SMOKE_ROUTE_MOUNTS
  presence true brief false mission_id undefined          <- именованный отказ PILOT_HTTP_UNAVAILABLE -> missions=null, без краха
```

Копия модели (R108-3):

```
diff model/features.start.start-screen.tsx  mobile/src/features/start/start-screen.tsx                  -> только "\ No newline at end of file"
diff model/ui.agent-presence.tsx            mobile/src/ui/agent-presence/agent-presence.tsx             -> то же
diff model/ui.conversation-composer.tsx     mobile/src/ui/conversation-composer/conversation-composer.tsx -> то же
diff model/mocks.start-mock.ts              mobile/src/mocks/start-mock.ts                              -> то же
diff model/i18n.ui-copy.ts                  mobile/src/i18n/ui-copy.ts                                  -> то же
diff model/api.api-client.ts / mocks.runtime.ts                                                         -> только перестановка комментария
```

H-пин CI (R108-4):

```
grep -n "ref:" .github/workflows/mobile.yml                                -> 39, 144: c9f680b4d9fd2e7eec24524c172343a70d2d8aae
git -C h ls-tree --name-only c9f680b4 fixtures/workshop_project/ | grep -c start_108  -> 0
git -C h ls-tree --name-only 58bcdb6a9 fixtures/workshop_project/ | grep start_108   -> есть
```

i18n verbatim (разбор каталога `entries[].copy_key`, сверка text и review_status):

```
ui-copy keys 22; mismatch 0; F04 in ui-copy 13, oracle 13, equal sets True
```

## Пункты роли

1. **Область правки.** 16 путей, все в ЗОНЕ implementer 108, плюс разрешённое расширение на pilot.test.tsx (+3).
2. **Сырой вывод.** Выше; логи `out_*.txt`, `frozen_*.log`, `npm_*.log` лежат в каталоге.
3. **Проверки не переписаны.** Харнесс не тронут; из тестов в диффе только pilot.test.tsx, по слову консультанта. Удаление legacy 991 (`rehearsal.test.tsx`, `start-screen.test.tsx`) законно: контракт его прямо требует, `rehearsal-start` не потреблялся ни одним флоу. «Собственные тесты экрана» не добавлены (R108-5).
4. **Красное предъявлено.** Матрицы 39+5 с именованной краснотой (defects 0) — мой прогон. Новых барьеров implementer не вводил.
5. **Атомарность.** 9 коммитов `108 (CMP-MOB-004)`, по одной части.
6. **Норма не тронута.** Харнесс не менялся, нормативных правок нет.
7. **Заявленное равно сделанному.**
   - 22/324/39/5 подтверждены своей мерой.
   - Коммит «12 ключей» верен: 12 новых плюс 1 существующий = 13.
   - Комментарий mobile.yml «H закреплён за 596413745» НЕ равен сделанному (R108-4).
   - Комментарий `ConversationComposer` «черновик … НЕ теряется … (Maestro: написать → вернуться → продолжить)» не равен поведению в приложении (R108-1).
- **Сдвиг дизайна D2.2.5.1.** Пропорция Presence 55–65 % — cognitive-only, это совет R108-9.

## Чистка

R, R2 и извлечённый Hci удалены после прогонов: `rm -rf R R2 Hci`, git status обоих перед удалением — 0. В `/home/harness/dev-harness` ничего не писалось, push не делался.

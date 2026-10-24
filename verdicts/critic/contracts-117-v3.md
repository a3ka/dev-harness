accept
OBJECT=8be0eb65290d93e8efc8f8a95402d71052cb2825

# Критик 117 v3 — один разрешённый круг сверх капа

Предмет — только закрытый перечень арбитра `/tmp/dev-harness-verify/orch/keep117v3/arbitration-nareska.md`, пункт 3, и совместимость с frozen 118/1. Судился закоммиченный HEAD `wip/117/architect-v3` в собственной копии `/tmp/dev-harness-verify/Critic117sol/repo`; B продукта — 8748a7a3352c14a6caa5a75b71f869e5d3b8152c, disposable R — только под `/tmp/dev-harness-verify/Critic117sol/`. Новых обходов закрытого перечня нет. Это разрешение на заморозку **текста 117/3**, не утверждение, что production 118/Android/e2e готов.

## Таблица закрытого перечня

| Пункт арбитра | Исполнен; адрес доказательства |
|---|---|
| П.2: W1A → Erstinformation при любом gate, не-W1A → путь B; только continue при W1A∧current → Start, null/stale continue не переводит | **Да.** `contracts/117-cmp-mob-vkhod-splash.md:153–188,226–240`; модель `fixtures/workshop_project/vkhod_117/model/bootstrap.pilot-app.tsx:215–246`, наблюдения W1A/null/stale/current и W0/current — `fixtures/workshop_project/vkhod_117/vkhod.test.tsx:765–890,1089–1130`. Frozen 118/1 `contracts/118-erstinformation.md:15–23` требует маркер null/stale до current и отсутствие Start после continue. Выбранный владельцем путь B для W0 не препятствует этому: gate закрывает Start, а frozen 118 не фиксирует поверхность W0. |
| (а) entry не подменяет admission/gate, посторонний authenticated не заменяет порт | **Да, 40+2 клетки.** `contracts/117-cmp-mob-vkhod-splash.md:246–253`; `vkhod.test.tsx:1124–1180`, мутации `vkhod_probe.py:820–850`. В каждой entry-клетке `entry.gate='current'`, решающие пары W0/stale, W0/current, W1A/stale, W1A/current, нет порта × обе темы. |
| (б) первый кадр при любом entry/порте — first-run, включая remount completed | **Да, 40+1.** `contracts/117-cmp-mob-vkhod-splash.md:254–258`; `vkhod.test.tsx:1183–1215`, `vkhod_probe.py:854–866`. |
| (в) Г0 F03.01/F03.02 после живой смены схемы в обе стороны при недопуске | **Да, 2.** `contracts/117-cmp-mob-vkhod-splash.md:259–263`; `vkhod.test.tsx:1217–1246`, `vkhod_probe.py:867–882`. Проверяются фон и все три отступа до смены, после смены на email и после demo на code. |
| (г) смена схемы на Erstinformation сама не создаёт Start | **Да, 2.** `contracts/117-cmp-mob-vkhod-splash.md:264–267`; `vkhod.test.tsx:1248–1275`, `vkhod_probe.py:883–897`. Положительный контроль продолжает только после явного continue. |
| (д) порт перечитывается при действии, W1A→W0 до demo | **Да, 2.** `contracts/117-cmp-mob-vkhod-splash.md:268–270`; `vkhod.test.tsx:1278–1294`, `vkhod_probe.py:850–854`. |
| Семь прежних r3-мутантов перенесены как именованные стабы | **Да, 7/7.** `contracts/117-cmp-mob-vkhod-splash.md:672–680`; определения `vkhod_probe.py:819–897`. Каждая из семи мутаций красна **на всех собственных named-клетках**: соответственно 2, 8, 6, 2, 21, 2, 2; собственный RNTL/Jest-замер `--matrix --only ...`, затем полный `60/60`. Старые `.tsx` свидетели Critic117v3c не редактировались, мутационные преобразования сверены по смыслу с `new_attack.py:8–22`. |
| Прежние 96 клеток и 53+38 стабов; новая полная батарея | **Да.** `contracts/117-cmp-mob-vkhod-splash.md:427–441,533–542,726–754`. Независимое сравнение предыдущего инвентаря 96 имён с **реальным списком 185 исполнившихся Jest-клеток** дало `removed=[]`, `added=89` (40+2+40+1+2+2+2). Поведенческие стабы 53→60, `removed=[]`; статический файл побайтово прежний, 38→38. Шесть старых поведенческих преобразований закономерно адаптированы к новой семантике, их имена сохранены. `--model` 185/185 и static 43/43; B failed 56/185 и static named red; полные матрицы 60/60 и 38/38. |
| Исправление описки :538/:550 прошлого кандидата | **Да.** `contracts/117-cmp-mob-vkhod-splash.md:649–650,665–666`: **20** truthy-строк × 2 темы = **40** клеток для каждой указанной группы, не «40 строк ×2». |
| Граница модель / production и frozen 118/1 | **Да.** `contracts/117-cmp-mob-vkhod-splash.md:198–213,313–320,811–828,965–972`: модель 117 судит порт, порядок и Г0; внешний источник сессии, production `/`, настоящий gate 107, Maestro и кадры F02/Start принадлежат 118, с прямой ссылкой на его инв. 4–5 и команду bootstrap-пробы. Текст frozen 118/1 `contracts/118-erstinformation.md:15–23,32,39–49` не менялся этим кандидатом. Реальная production-композиция **не** предъявлена как зелёная. |
| Разрешение, зона, сохранность чужих файлов | **Да.** В телах **обоих** коммитов 7c6cc3d4 и 8be0eb65 дословно одна строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/117-cmp-mob-vkhod-splash.md — v3: узкая правка пути pilot-app First-Run→demo→Erstinformation (слово владельца 2026-10-24 ~10:15 UTC «а», форк n118-migraciya-117)`. `contracts/117-cmp-mob-vkhod-splash.md:796–842` закрепляет исполнителей и передачу pilot-app исполнителю 118 только после frozen/117/3. `git diff --name-only 6b6e55c1 8be0eb65` даёт ровно контракт и три файла `fixtures/workshop_project/vkhod_117/`; `git diff --exit-code 6b6e55c1 8be0eb65 -- scripts/ fixtures/workshop_project/erstinformation_118/ contracts/118-erstinformation.md` rc0, пусто. |

### Семь прежних обходов — живое повторение на своей копии

| Обход r3 из прошлого FAIL | Стаб и конкретное наблюдение теперь красны |
|---|---|
| `r3-extra-authenticated`: W0/stale + `authenticated:true` | `migracija-postoronnee-pole-authenticated`: оба `MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_W0_STALE_{DARK,LIGHT}` |
| `r3-gate-from-entry`: W1A/stale + `entry.gate=current` | `migracija-gate-iz-entry`: все 4 entry × 2 темы `MIGRACIYA_ENTRY_*_W1A_STALE_*` |
| `r3-admission-literal-completed`: completed + W0/current | `migracija-literal-completed`: COMPLETE × {W0_STALE,W0_CURRENT,NEPODKLYUCHEN} × обе темы |
| `r3-cached-admission`: W1A→W0 до demo | `migracija-kesh-dopuska`: оба `MIGRACIYA_RERENDER_W1A_W0_*` |
| `r3-restart-completed-start`: completed + W0/stale remount | `migracija-restart-start`: 10 начальных, 10 entry-клеток COMPLETE и remount |
| `r3-g0-theme-change`: тема меняется на недопуске | `migracija-g0-smena-temy`: DARK_TO_LIGHT и LIGHT_TO_DARK |
| `r3-order-theme-autostart`: тема меняется до continue | `migracija-start-ot-smeny-temy`: DARK_TO_LIGHT и LIGHT_TO_DARK |

## Сырые замеры

Команды ниже исполнялись на собственной копии, Node `v26.5.1`, Python `3.12.3`. `Rmatrix`, `Rstatic`, `Rregress` — отдельные продуктовые R с node_modules-ссылкой; длинные проверки шли последовательно. Полный stdout каждого из 3 поведенческих срезов записан в `/tmp/dev-harness-verify/Critic117sol/matrix-{1,2,3}.log`, файл `slices.py` печатает нижеприведённый дословный свод команд.

```text
$ git rev-parse HEAD
8be0eb65290d93e8efc8f8a95402d71052cb2825
$ PATH=/usr/bin:/bin:$PATH bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117sol/repo contracts/117-cmp-mob-vkhod-splash.md
OK
rc=0
$ PATH=/usr/bin:/bin:$PATH bash scripts/pre_critic.sh contracts/117-cmp-mob-vkhod-splash.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
rc=0
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117sol/R --model
behavioral 185/185
rc=0
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117sol/R
VKHOD_SPLASH_OVERLAY_ABSENT
failed 56 of 185
rc=1
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117sol/R --model
static 43/43
rc=0
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117sol/R
VKHOD_SPLASH_COMPOSITE_ABSENT
rc=1
$ python3 /tmp/dev-harness-verify/Critic117sol/inventory.py
old= 96 current= 185 removed= [] added= 89
MIGRACIYA_ENTRY_ 40
MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_ 2
MIGRACIYA_NACHALNYJ_KADR_ 40
MIGRACIYA_REMOUNT_ 1
MIGRACIYA_G0_SMENA_TEMY_ 2
MIGRACIYA_PORYADOK_SMENA_TEMY_ 2
MIGRACIYA_RERENDER_ 2
mutants= 60 seven= ['migracija-postoronnee-pole-authenticated', 'migracija-gate-iz-entry', 'migracija-literal-completed', 'migracija-kesh-dopuska', 'migracija-restart-start', 'migracija-g0-smena-temy', 'migracija-start-ot-smeny-temy']
old_mutants= 53 removed= [] added= ['migracija-g0-smena-temy', 'migracija-gate-iz-entry', 'migracija-kesh-dopuska', 'migracija-literal-completed', 'migracija-postoronnee-pole-authenticated', 'migracija-restart-start', 'migracija-start-ot-smeny-temy']
static_mutants= 38 38 changed= False
static_file_byte_equal= True
$ python3 /tmp/dev-harness-verify/Critic117sol/slices.py
slice 1 rc 0 declared 20 red 20 missing []
slice 2 rc 0 declared 20 red 20 missing []
slice 3 rc 0 declared 20 red 20 missing []
$ python3 /tmp/dev-harness-verify/Critic117sol/audit_matrix.py
migracija-postoronnee-pole-authenticated named= 2 observed= 2 missing= [] other= []
migracija-gate-iz-entry named= 8 observed= 8 missing= [] other= []
migracija-literal-completed named= 6 observed= 6 missing= [] other= []
migracija-kesh-dopuska named= 2 observed= 2 missing= [] other= []
migracija-restart-start named= 21 observed= 21 missing= [] other= []
migracija-g0-smena-temy named= 2 observed= 2 missing= [] other= []
migracija-start-ot-smeny-temy named= 2 observed= 2 missing= [] other= []
all mutants= 60 seven own named sets red
$ TMPDIR=/tmp/dev-harness-verify/Critic117sol PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117sol/Rstatic --matrix
mutant splash-composite-twin red= ['SPLASH_COMPOSITE_ETALON_DARK', 'SPLASH_COMPOSITE_ETALON_LIGHT']
mutant sverka-ref-branch red= ['SVERKA_123_HARNESS_PIN']
rc=0
$ python3 /tmp/dev-harness-verify/Critic117sol/regression.py
pilot995 14 failed 0 rc 0
honest 23/23
rc=0
```

Первый статический матричный запуск на общем R вернул rc2 с `MUTANT_NAMED_MISS splash-composite-twin ... red=['ICON_RASTER_WHOLE']`: во время него другой scoped-прогон также временно устанавливал модель в этот **тот же** R. Это конфликт измерительной копии, не результат изолированного замера; повтор на отдельном `Rstatic` без параллельных установок дал вышеуказанный `rc=0`, все 38 именованных статических стаба красны. После этого 995/111 заново прогнаны на отдельном `Rregress`. Продуктовый CI, Android, Maestro и настоящая production-композиция 118 здесь не запускались.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:177 — слова «вопрос владельцу открыт» устарели после выбора владельцем варианта B для W0. Приёмка и модель уже однозначно пинят B, поэтому это не обход и `accept` не задерживает.

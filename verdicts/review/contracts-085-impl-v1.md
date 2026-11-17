accept
OBJECT=b6a3e87759e95faa1e907bd89de2fdfc90535efd
КЛАСС=кодовый; КЛАСС РИСКА=обычный, подтверждён: правка — значение строки MSG обёртки хоста, раздел README и два значения пинов батареи; права БД, авторизация, деньги и ПД не затронуты; адверсарий по классу не вызывался
СУД: repo=dev-harness; предмет=085; фаза=реализация; роль=reviewer; вызов=1 (полный); модель-план=config/agent_models.json (reviewer → audit/@opus); сессия=Rev085; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev085` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev085	b6a3e87759e95faa1e907bd89de2fdfc90535efd`); SHA=b6a3e87759 (номинальный, tip `origin/wip/085/architect`); судимое состояние = origin/main `628312d6f19ea06e3bd763e03154f0c445b18072`; контракт=frozen/contracts/085/2 (`315da054bc` → `f382d8df3b`); предыдущие=нет (контракт: Crit085V2 accept на `9b504ade18`); исключение=нет. СУД-запись оркестратора найдена: HANDOFF state-WT `wip-011-orchestrator`, строка 4 («предмет=085; … роль=reviewer …»), совпадает по OBJECT, вызову и имени вердикта.

# Вердикт reviewer — 085 v2 «MSG автоперезапуска ведёт к актуальным источникам», реализация, вызов 1

**accept.** Блоков нет. Советы и наблюдения — в `.review/2026-11-17-101.md` (`status: ready`), тот же коммит.

| Находка | Класс | Адресат | Суть |
|---|---|---|---|
| С-1 | совет | architect 074/085 | Пины переснимались вместе с `SNAP['user/orch-loop']` (:193). Буква И-7 v2 и ПЕРЕСЕЧЕНИЯ называет только `PIN`, но модель угроз :271 и остаточный риск :432-434 требуют, чтобы к5b краснела в окне до установки, а в дереве после 186 этого даёт только `SNAP`. Контракт сам себе противоречит. Устарел комментарий `SNAP` (:189-191). |
| С-2 | совет | консультант | Станция несёт MSG v1 (`30d83712…`). Остаток — `install.sh user`, затем `verify`. |
| Н-1 | наблюдение | orchestrator | Implementer и пины сделаны ДО тега frozen/085/2 (20:38/20:48 против 21:15Z). Блоб контракта при accept, на теге и на HEAD один и тот же, дрейфа нет. |
| Н-2 | наблюдение | orchestrator | В main коммит пинов `a2a7d30d` — родитель реализации `5cd0dd9a`. На промежуточном коммите к5 красна. Ленд атомарен merge-коммитом. |
| Н-3 | наблюдение | orchestrator | `ae3f51af99` нет на origin. В main лежит patch-эквивалент `5cd0dd9a`. |
| Н-4…Н-7 | наблюдения | — | `SNAP` orch-peak ≠ станции ещё до 085; 080 s1 зависит от окружения (глобальный gitconfig); 090 — герметичность из-за живых сессий; литерала `БЕЗ ПОТОЛКА` в README нет по форме 093. |

## Клон и объект

- `git clone -q ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev085/repo`; `git fetch origin wip/085/architect` → `FETCH_HEAD` = `b6a3e87759e95faa1e907bd89de2fdfc90535efd` (родитель `9b504ade18`); `origin/main` = `628312d6f19ea06e3bd763e03154f0c445b18072` (`freeze: registry 085 → 315da054bc…`).
- В ssh-клоне `git show ae3f51af99` → `fatal: ambiguous argument 'ae3f51af99': unknown revision`. Implementer-коммит на origin не опубликован, в main лежит его патч `5cd0dd9afc`:
```
$ git -C /home/harness/dev-harness show ae3f51af99 | git patch-id --stable   # только чтение основного чекаута
62d86222394424cc982e3c0330c4f87ca5bb0517 ae3f51af99a9130d3796d874b1c9febf91c11765
$ git show 5cd0dd9a | git patch-id --stable
62d86222394424cc982e3c0330c4f87ca5bb0517 5cd0dd9afce85e2f0695b0f6181df2b959d422e4
$ git show b6a3e87759 | git patch-id --stable ; git show a2a7d30d | git patch-id --stable
618b9778de29e6810220eced5a2fc0334ce65077 b6a3e87759e95faa1e907bd89de2fdfc90535efd
618b9778de29e6810220eced5a2fc0334ce65077 a2a7d30d87b524756f83d6c0dbf6fbce20a5fca9
```
- Подписи: `5cd0dd9a` — `implementer <implementer@dev-harness.local>` / то же; `a2a7d30d` — `architect <architect@dev-harness.local>` / то же. Ленд `c2d63cb9` (orchestrator, merge #1069).
- Контракт и батарея не дрейфовали с accept критика:
```
$ git rev-parse 9b504ade:contracts/085-cikl-perezapuska-repo.md frozen/contracts/085/2:contracts/085-cikl-perezapuska-repo.md
b79777e2dfab53e35803361de5f9fd6329ba862d
b79777e2dfab53e35803361de5f9fd6329ba862d
$ git diff --stat frozen/contracts/085/2 628312d6 -- contracts/085-cikl-perezapuska-repo.md fixtures/ops_server/red_cikl_perezapuska_085.sh fixtures/ops_server/cikl_085/   # пусто
$ git diff 9b504ade 628312d6 --stat -- fixtures/ops_server/ ops/server/
 fixtures/ops_server/red_server_obvjazka_074.sh |  4 ++--
 ops/server/README.md                           | 15 +++++++++++++++
 ops/server/user/orch-loop                      |  2 +-
 3 files changed, 18 insertions(+), 3 deletions(-)
```

## ОСТАТОК (контракт 192) — первым

- ОСТАТОК: «полнота README сверх чек-строк k6 — ловец ревьюер» (НЕ ЗАЩИЩАЕТ; И-9, А7) — **не укусил**. Новый раздел `ops/server/README.md:246-259` «Текст автоперезапуска (orch-loop, контракт 085 И-10)» называет все три источника («ГДЕ МЫ», `registry/plan.tsv`, `registry/pauzy.tsv`) и прямо говорит, что блок «Следующая сессия» источником не является. Отсылает к строке `MSG=` и к клетке т1. Якоря И-9 v1 на месте (`grep -cF`): `ORCH_MEM_MAX` 4, `orch-memcap` 6, `escape-time` 1, `tmux attach -r` 1, `OOM: omp убит потолком памяти` 1, `CTX_SOFT` 3, `IDLE_MAX` 2, `СТОРОЖ СТАНЦИИ` 3, `ORCH_LOOP_STOP` 2. k6 074 зелёная (см. §2). Литерала `БЕЗ ПОТОЛКА ПАМЯТИ` нет: это форма 093, v2 её не меняет (Н-7).
- ОСТАТОК: «следует ли агент-модель тексту MSG фактически — ловец живая сессия оркестратора» — у ревьюера ловца нет. **Не проверено**, проверяемо только после установки на станцию.
- ОСТАТОК: «полнота раздела роли «Автоперезапуск orch-loop и два слота» — отдельный owner-PR» — **не укусил** для этого диффа: `roles/orchestrator.md` не тронут, раздел, на который ссылается MSG, существует (`roles/orchestrator.md:309`; `ROLE_ANCHOR` батареи 074 :216).

## 1. Область правки

```
$ git show --stat 5cd0dd9a          # ≡ ae3f51af99
 ops/server/README.md      | 15 +++++++++++++++
 ops/server/user/orch-loop |  2 +-
$ git show --stat a2a7d30d          # ≡ b6a3e87759
 fixtures/ops_server/red_server_obvjazka_074.sh | 4 ++--
$ git diff a2a7d30d 5cd0dd9a -- ops/server/user/orch-loop | grep -c '^[-+][^-+]'
2
```
- Implementer меняет ровно одну строку `ops/server/user/orch-loop:25` (`-MSG='…«Следующая сессия»…'` / `+MSG='…«ГДЕ МЫ»…'`) и добавляет 15 строк README без единого удаления. Оба файла лежат в `ЗОНА implementer` frozen 085/2, `ops/server/root/orch-peak` не тронут. Скелет обёртки (потолок И-5, общий счёт И-3, singleton/канал подтверждения 997) по построению не изменён: одна строка `-`, одна `+`, и это присваивание MSG. Раздел 081 (`.git/config`) не тронут: удалённых строк в README 0.
- Architect меняет 2 строки файла `fixtures/ops_server/red_server_obvjazka_074.sh` из `ЗОНА architect`: `PIN['user/orch-loop']` и `SNAP['user/orch-loop']` → `d998bf12…`. Клетки, стабы, `STATION` и остальные пины не тронуты. По `SNAP` буква ПЕРЕСЕЧЕНИЯ уже — это С-1, совет; почему не блок, разобрано в `.review`.
- Норма не тронута: `contracts/`, `roles/`, `AGENTS.md` в диффе реализации и пинов отсутствуют.

## 2. Сырой вывод (мой прогон, клон на `628312d6`)

```
$ bash fixtures/ops_server/red_cikl_perezapuska_085.sh; echo RC=$?
085: orch-loop d998bf12, orch-peak 5f2a1f44; режим full
  зелено: р0 — 5/5 снимков cikl_085/ == пинам в памяти
  зелено: р2 — 65 строк снимка на месте в том же порядке
  … л1–л10, п1–п12, м1–м6 зелено (м5 — живая сессия в run-*.scope, memory.max 67108864) …
  зелено: т1 — MSG: 5/5 обязательных ссылок, «Следующая сессия»/$/` нет, 527 байт, == MSG снимка станции
стаб-пак: 46/46 поймано, диффпроба: 33/33
итог 085: красных=0, стабы=46/46, диффпроба=33/33
RC=0                                    (56.4 с)
$ bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast        → итог 085 fast: красных=0  RC_fast=0
$ FIXSIM=1 bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast → итог 085 fast: красных=0  RC_fixsim_fast=0
$ FIXSIM=1 bash fixtures/ops_server/red_cikl_perezapuska_085.sh      → итог 085: красных=0, стабы=46/46, диффпроба=33/33  RC_fixsim_full=0
$ bash fixtures/_krasnye_074.sh   (и напрямую red_server_obvjazka_074.sh — то же)
k5b: станция /home/harness/bin/orch-loop разошлась со снимком 2026-10-02
  КРАСНО: cell_k5b
итог 074: красных клеток=1 стабы=8/8
RC_074=1
$ GIT_CONFIG_GLOBAL=/dev/null bash fixtures/_krasnye_080.sh   (А4)
итог 080-батареи: предъявлений стабы 9/9 + дифф 9/9 + честные 31/31   RC=0
  (без GIT_CONFIG_GLOBAL: стабы 8/9, «клетка стаб-s1: stab_rc=0 clean_rc=0» — окружение, Н-5)
$ IMMU_MOCK=1 bash fixtures/ops_server/red_git_config_immut_081.sh → итог [MOCK]: зелёных=30 красных=0  RC_081=0
$ bash …/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --stabs → ИТОГ 196: rc=0 OBMANOK=34 POIMANY=34 ZHIVYH=0  RC_196=0
$ bash …/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs → SVJAZI 60  RC_139=0
$ bash …/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs → SVJAZI 69, zhivykh 0  RC_995=0
$ bash fixtures/_krasnye_090.sh
КЛЕТКА-ОТКАЗ(090): герметичность нарушена: НОВЫЕ/ИЗМЕНИВШЕЕСЯ пути под множеством чтения реального orch-peak … /home/harness/.local/state/dev-harness-sessions/c907157c/…
— red_hermetic_no_real_sessions.sh: rc=1
ИТОГ 090: rc=1                         (стабы 1–4 пойманы; субъект orch-peak диффом не тронут — Н-6)
$ bash scripts/gen_ci_steps.sh --check → RC_gen=0
$ bash scripts/check_charter.sh → уставных документов: 180 · изменений в них: 521 · с разрешения: 521  RC_charter=0
```
Окружение гейтов: `env | grep '^GIT_'` → только `GIT_EDITOR/GIT_PAGER/GIT_SEQUENCE_EDITOR/GIT_TERMINAL_PROMPT`, `GIT_AUTHOR_*`/`GIT_COMMITTER_*` не заданы.
к5b — единственная красная клетка 074. Она судит живую станцию против `SNAP`; на станции стоят старые orch-loop (`30d83712…`) и orch-peak (`5f2a1f44…` ≠ `SNAP` `6b4f2261…`). До правки к5b краснела по orch-peak, после — по orch-loop и orch-peak (С-1, Н-4). Это остаток «РАБОТА НЕ РАЗДАЁТСЯ: установка на станцию», а не дефект реализации.

## 3. MSG v2 — своей мерой (не выводом батареи)

```
$ grep -c "^MSG='" ops/server/user/orch-loop                              → 1
значение: wc -c → 527; wc -m → 315
HANDOFF «ГДЕ МЫ» / registry/plan.tsv / registry/pauzy.tsv / стартап-протокол роли / «Автоперезапуск orch-loop и два слота» → has ×5
grep -cE 'Следующая сессия|\$|`' → 0;   одинарных кавычек в значении → 0
значение == строка `АВТОПЕРЕЗАПУСК:…` из И-10 контракта → CONTRACT_EQ
значение == MSG снимка cikl_085/stancija.orch-loop → SNAP_EQ;   sed -n 19p снимка | sha256 == sed -n 25p субъекта | sha256 → 2b2d28bc…
sha256sum ops/server/user/orch-loop → d998bf12f5894400169bb4da82c8ddcea3f2d370db18e9ed632a5934e84e0692 == PIN['user/orch-loop'] 074 :175
sha256sum cikl_085/stancija.orch-loop → 5fabbf959d3da14ac52b0d66c2eca5ec3d1f0e66e477008ad7273630cbce6a7c == пин р0 контракта; diff снимка frozen/085/1→HEAD: 2 строки ± (одно присваивание MSG)
```

## 4. Проверка не подогнана; красное предъявлено

- После accept критика implementer не трогал ни батарею 085, ни `cikl_085/`, ни контракт (см. «Клон»: блобы равны, дифф пуст). Пины 074 переснял отдельный явный коммит architect `a2a7d30d` (≡ OBJECT). Сообщение коммита называет оба вхождения, а sha256 совпадает с моим замером.
- Н-39: стабы привязаны к входам кодом — списком `STUBS` построителя (`red_cikl_perezapuska_085.sh:407-524`), а не прозой контракта. Счёт своей мерой: `grep -cE "^  \('s[0-9]{2}'"` → `46`; по клеткам т1 — 6 (s41–s46 = шесть обманных классов И-10 дословно), м6 — 4, остальные клетки — по 1–2.
- Красное против сломанной реализации — мой прогон: в клоне `git checkout 5cd0dd9a^ -- ops/server/user/orch-loop` (sha `30d83712…`, MSG v1), затем батарея:
```
  КРАСНО: р2 — пропала строка снимка 19 (или нарушен порядок): MSG='АВТОПЕРЕЗАПУСК: … HANDOFF «ГДЕ МЫ» …'
  КРАСНО: м1 — systemd-run для сессии не вызван: ни одна команда после «--» не кончается парой «workshop MSG» (вызовов шима: 1)
  КРАСНО: м2 — (то же)
  КРАСНО: м6 — … → сессий 2, rc 0 (ожидалось: сессий 0, rc любой)
  КРАСНО: т1 — MSG без обязательной ссылки «HANDOFF «ГДЕ МЫ»» (И-10)
итог 085: красных=5, стабы=46/46, диффпроба=33/33
RC_red085=1
$ bash fixtures/_krasnye_074.sh  (тот же v1-файл)
k5: ops/server/user/orch-loop разошёлся с фиксированным пином репо (пересъём — явный коммит, не молчаливая правка)
  КРАСНО: cell_k5
итог 074: красных клеток=8 стабы=7/8   RC_red074=1
```
  Красное множество {р2, м1, м2, м6, т1} совпадает с А1v контракта («красных=5»). После этого `git checkout HEAD -- ops/server/user/orch-loop` → `d998bf12…`, `git status --porcelain` пуст.

## 5. Атомарность

Реализация — один коммит implementer со ссылкой на предмет (`085 v2 (И-10): …`). Пины — один коммит architect (`architect: 085 И-7 — …`). Обе правки пришли в main единым носителем, merge `c2d63cb9`. Порядок в истории и момент заморозки — Н-1 и Н-2, к процессу оркестратора.

## 6. Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) совместные правки | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| значение `MSG=` (orch-loop:25) | И-10 | нет; литерал виден в файле | 2 (субъект + снимок `stancija.orch-loop`, правило синхронизации И-2) — не выросло | интерфейс не менялся | т1, р2, м1/м2/м6 | ESSENTIAL |
| README раздел «Текст автоперезапуска» | И-10/И-9 | нет | 1 | — | ревьюер (А7), k6 не задет | ESSENTIAL |
| `PIN`/`SNAP['user/orch-loop']` | И-7 / к5, к5b | явное, литерал | 2 (две таблицы одного пина после 186 — существовало до диффа) | — | `_krasnye_074.sh` (CI), к5b на станции | ESSENTIAL (С-1 — по букве) |

Новых скриптов, флагов, env-переменных и каталогов состояния нет.

## 7. ПРОВОДКА и гейты

ПРОВОДКА 085: `guard=fixtures/ops_server/red_cikl_perezapuska_085.sh` существует, это барьер именно этого предмета. CI-шаг `check:cikl-perezapuska-085-family-selftest` стоит в `registry/ci-steps.tsv:75` (`bash fixtures/ops_server/red_cikl_perezapuska_085.sh`, полная батарея) и в ключах `.github/workflows/ci.yml:276`; `gen_ci_steps.sh --check` rc 0. ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: норм-строк ролей нет, MSG ссылается на раздел роли как есть.

СВЕРКА-СТАНДАРТОВ: неприменимо — `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`ls` → `No such file or directory` для обоих).
СВЕРКА-АРХИТЕКТУРЫ: неприменимо — у dev-harness нет модели архитектуры (`architecture/`, `architecture.lock.json` → `No such file or directory`). Размещение: файлы обвязки остаются в `ops/server/`, новых зависимостей, писателей и операций нет, `bindings.json` отсутствует, долг не расширен, diff модели — нет (L2/L3 не возникают).
Режим проекта (996): sourceCanon не объявлен — неприменимо.

## Не проверено

- Живая установка MSG v2 на станцию (`install.sh user` → `verify` 9/9, к5b) — консультант (С-2). Следование агента тексту MSG — cognitive-only.
- `scripts/check_zones.sh` полным прогоном не запускал (по прецеденту 196 — ~760 с). Зоны сверены своей мерой: файлы каждого коммита ⊆ ЗОНА-строкам frozen 085/2, `user.name` авторов `implementer`/`architect`.
- Режим `stancija` батареи 085 (А6) — после установки и снятия orch-memcap.

ПРОВЕРКИ ДЛЯ ОРКЕСТРАТОРА: после установки консультантом — `OPS_SERVER_BIN_DST=/home/harness/bin bash ops/server/install.sh verify` и `bash fixtures/_krasnye_074.sh`. к5b не должна называть orch-loop: останется только orch-peak (Н-4).

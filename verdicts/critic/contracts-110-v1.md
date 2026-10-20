accept
OBJECT=80a66a37766d2bb7853e2aa2b24eb6f66613f9a3

# Критик 110 («Done волны»), круг 3 — ВНУТРИ рамок арбитража contracts-110-kvantor-v1

Предмет: `contracts/110-done-volny.md` + `fixtures/workshop_project/done_volny_110/` на
origin `wip/110/architect` @ 80a66a37 (автор коммита `architect <architect@dev-harness.local>`).
Рамка: Решения 1–3 арбитража, правила К/H/М, замкнутый перечень П1–П6, список «что НЕ блокирует
круг 3». Критерий accept: нет обхода ВНУТРИ перечня и нет регресса кругов 1–2. Обход вне
перечня — СОВЕТ. Модель `model/done_wave_model.sh` правкой НЕ затронута
(`git diff --stat 38dbb71a..HEAD -- …/model/` пуст); в `probe.py` удалённые строки — только
комментарии и частный `plan_worktree` (заменён общим `worktree_files`), 34 клетки круга 2 на месте.

Клон: `git clone ssh://git@github.com/a3ka/dev-harness.git h` → checkout 80a66a37, затем
`git fetch --tags` (без тегов `check_zones.sh`/`check_precision_gate.sh` отказывают `missing-remote`).
`TMPDIR=/tmp/dev-harness-verify/Critic110r3/tmp`, `PYTHONDONTWRITEBYTECODE=1`. Основной
чекаут не трогался, push/commit не выполнялись.

## Исполненные команды и сырые результаты

```
bash fixtures/workshop_project/done_volny_110/probe.sh
  → stderr «110: дверь done_wave не существует (до-предметное дерево): …/scripts/done_wave.sh», rc=1
bash fixtures/workshop_project/done_volny_110/probe.sh --model
  → 52 строки «СЛУЧАЙ … ok»; «ИТОГ: случаев 52, зелёных честных 11/11, отказных с именованной причиной 41/41», rc=0 (4.9 с)
bash fixtures/workshop_project/done_volny_110/probe.sh --matrix
  → эталон 52/52; 31 мутант, каждый ≥1 различающего случая; « mismatches=0», rc=0 (138 с)
     m22_symbolic_first_only            1 wave_second_symbolic_open
     m23_second_nfr_rc_skipped          1 nfr_second_cmd_fail
     m24_second_review_missing_skipped  1 review_second_missing
     m25_manifest_worktree              1 manifest_dirty
     m26_closed_worktree                1 closed_dirty
     m27_review_worktree                1 review_dirty
     m28_otkat_worktree                 1 otkat_dirty
     m29_duplicate_otkat                1 manifest_dup_otkat
     m30_version_count                  1 tag_gap_max_plus_one
     m31_strict_threshold               2 nfr_edge_le_ok nfr_edge_ge_ok
     (m1…m21 кругов 1–2 — все различены ≥1; побочной красноты у декоев нет)
bash fixtures/workshop_project/done_volny_110/probe.sh --case __no_such_case__
  → «неизвестный case: __no_such_case__ (известны: …)», rc=2
bash fixtures/workshop_project/done_volny_110/provodka.sh
  → «проводка 110: npm-ключ check:done-volny-110-family-selftest в package.json отсутствует или ведёт не в батарею 110 (…)», rc=1
bash scripts/check_provodka.sh . contracts/110-done-volny.md         → rc=0
bash scripts/check_precision_gate.sh . contracts/110-done-volny.md   → «OK», rc=0
bash scripts/check_threat_model.sh . contracts/110-done-volny.md     → «секция валидна», rc=0
bash scripts/check_zones.sh . contracts/110-done-volny.md            → «проверено по зонам: 3500», rc=0
bash scripts/pre_critic.sh --repo . contracts/110-done-volny.md      → «КРИТИК: дверь зелёная», rc=0
python3 -B bytecheck.py   (m22…m31 из модели OBJECT против /tmp/dev-harness-verify/Critic110r2/*.sh)
  → 10 × IDENTICAL, bad=0, rc=0
bash decoys_as_subject.sh (каждый декой установлен как scripts/done_wave.sh в одноразовом
  дереве `git archive HEAD`, обычный probe.sh)
  → все десять rc=1; разногласие ровно на своей клетке (strict_threshold — на двух граничных):
     closed_worktree→closed_dirty · duplicate_otkat→manifest_dup_otkat · manifest_worktree→manifest_dirty
     otkat_worktree→otkat_dirty · review_worktree→review_dirty · second_nfr_rc_skipped→nfr_second_cmd_fail
     second_review_missing_skipped→review_second_missing · strict_threshold→nfr_edge_le_ok nfr_edge_ge_ok
     symbolic_first_only→wave_second_symbolic_open · version_count→tag_gap_max_plus_one; bad=0
bash genplan_regress.sh (команда 4, копия клона с реальными тегами: done/contracts 95, frozen/contracts 190)
  → gen_plan.sh --write rc=0; git diff --exit-code -- ROADMAP.md HANDOFF.md rc=1 — ОДИНАКОВО с waves и без
    (дельта: одна строка HANDOFF «- 109 · пара 4 · заморожен», дрейф тега frozen/contracts/109 на origin,
    не эффект registry/waves/) — см. СОВЕТ 1
```

## Перечень Решения 2 — поимённо

| пункт | что требовалось | факт на OBJECT | статус |
|---|---|---|---|
| П1 правило К | 8 клеток с литералами: членство 2, NFR 3, review 3 | `wave_second_symbolic_open` («sim-b не начат»), `wave_two_symbolic_closed` (ok v1); `nfr_second_cmd_fail` (вторая печатает 95 И exit 3 → «NFR second: команда rc=3»), `nfr_second_no_metric`, `nfr_two_ok` (ok v1); `review_second_missing` («отсутствует на HEAD: .review/second.md»), `review_no_status_line`, `review_second_no_status_line` («status=нет_строки_status»). Все классы {…}×{1,2} + контроль двух на каждой из трёх осей присутствуют (probe.py:336–388) | ВЫПОЛНЕН |
| П2 правило H | 4 клетки + общий механизм вместо `plan_worktree` | `closed_dirty`, `manifest_dirty`, `review_dirty`, `otkat_dirty` (probe.py:390–410); `build_world` — `worktree_files` (правка произвольного пути после коммита и тегов, probe.py:141–146); `plan_worktree` в коде отсутствует; `wave_plan_dirty` переведён на тот же механизм | ВЫПОЛНЕН |
| П3 правило М + тег + граница | `manifest_dup_otkat`, `manifest_no_otkat`, `manifest_empty`, `tag_gap_max_plus_one` (v8, имя ref), `nfr_edge_le_ok`, `nfr_edge_ge_ok` | все шесть есть (probe.py:412–438); `check_ok` требует objecttype=tag, peeled==HEAD до вызова, причина в аннотации, новых refs ровно один и ref == `refs/tags/done/waves/3/8` | ВЫПОЛНЕН |
| П4 матрица | 10 декоев байт-в-байт, каждый убит ≥1 клеткой, mismatches=0 | m22–m31 IDENTICAL файлам Critic110r2; `--matrix` rc=0 mismatches=0; побочной красноты нет (m31 — две граничные, как предсказал арбитраж) | ВЫПОЛНЕН |
| П5 контракт | И-2/И-4/И-6 с правилом К; правило H одной фразой; §Приёмка — оси по Решению 2, фактические числа, блок «не входит» | contracts/110-done-volny.md:82–91, 94–104, 107–115 (правило К в инвариантах), :117–121 (правило H), :130–168 (правила К/H/М и 52 / 11 ok / 41 refuse / 31 мутант), :169–180 (НЕ ВХОДИТ — список арбитража воспроизведён) | ВЫПОЛНЕН |
| П6 текст | §Закрытие без имён клеток/мутантов; :171 gen_plan с rc-оракулом; §Фактический замер заново | grep по контракту имён клеток (`wave_*`, `nfr_*`, `review_*`, `m\d+_`) — 0 совпадений; команда 4 сформулирована как `gen_plan.sh --write` rc 0 + `git diff --exit-code -- ROADMAP.md HANDOFF.md` rc 0; §Фактический замер круга 3 — все заявленные rc воспроизведены мной выше (кроме gen_plan — СОВЕТ 1, зависимость от среды) | ВЫПОЛНЕН |

Граница (ii) арбитража — недостоверность клеток: ожидания — литералы (Н-351); `before = refs_snapshot`
и `head_before` снимаются ДО `run_subject` (probe.py:604–606), фаза 2 `e2e_fresh_rerun` снимает
их заново; оракул ok-клетки полон (тип/цель/причина/число новых refs/имя ref). Нарушений нет.

Граница (iii) — регресс: 34 клетки круга 2 не изменены по существу; m1–m21 различены; десять обходов
круга 1 представлены мутантами m13–m21 (файлы Critic110r1 на станции отсутствуют, матрица — свидетель);
`provodka.sh` и `.probe-only` без диффа к 38dbb71a; `provodka.sh` rc=1 именованно до проводки.

Обходов ВНУТРИ перечня не найдено: каждый класс, именованный правилами К/H/М, имеет клетку с
литеральным ожиданием, честная модель проходит 52/52 без правок, каждый декой круга 2 красен на
своей клетке и только на ней. Блокирующих находок нет → `accept`.

## СОВЕТЫ (не блокируют; автор закрывает по своему усмотрению)

СОВЕТ contracts/110-done-volny.md:210–217 (команда 4, регрессия gen_plan) — литеральная команда
`git diff --exit-code -- ROADMAP.md HANDOFF.md` на копии с РЕАЛЬНЫМИ тегами origin даёт rc=1
одинаково с `registry/waves/3.tsv` и без него (дельта — строка «109 · заморожен», дрейф тега
frozen/contracts/109 относительно HANDOFF ветки). Утверждение «блоки не меняются от появления
registry/waves/» истинно по разности прогонов, но командой «→ rc 0» в текущей форме не
доказывается на живом дереве. Простейшая форма: два прогона на двух копиях (без waves / с waves)
и `diff -q` их ROADMAP.md/HANDOFF.md → rc 0; либо прогон на срезе, где HANDOFF регенерирован тем
же набором тегов. Вне перечня («форма gen_plan-регрессии сверх П6»), команда фазы «после реализации».

СОВЕТ fixtures/workshop_project/done_volny_110/probe.py:378–388 — класс «нет строки status»
(И-6) получил две клетки, но в матрице нет мутанта, принимающего пустой статус как done
(например, `[ "$st" = "done" ] || [ -z "$st" ]` → зелёный на `review_no_status_line`): клетки
проверены только честной моделью. П4 требует десять декоев и mismatches=0 — выполнено; мутант на
этот класс — добор матрицы на усмотрение автора.

СОВЕТ (среда, не контракт) — `check_zones.sh`, `check_precision_gate.sh` и `pre_critic.sh` красны
(`missing-remote`) в клоне без тегов; §Фактический замер мог бы назвать `git fetch --tags` как
предусловие прогона чекеров, чтобы судья не тратил круг на диагностику.

## Артефакты

`/tmp/dev-harness-verify/Critic110r3/`: `verdict.md`, `bytecheck.py`, `decoys_as_subject.sh`,
`genplan_regress.sh`. Клон `h/` и `tmp/` удалены после записи вердикта. Коммит вердикта под
`-c user.name=critic -c user.email=critic@dev-harness.local` в `verdicts/critic/contracts-110-krug3-accept.md`
на ветку предмета — оркестратору (сессия непиннованная).

accept
Суд реализации 123 «mob-sverka-maketa», круг 2 из 3 (scoped: закрытие круга 1 и дельта), ревьюер Rev123c.
Объект: OBJECT=2cc58c224a8a9ced9709604f0eeb57d2fba6fb07 (`wip/123/implementer`). Продукт: Complior-mob `cmp-mob-123/sverka`
@ 10cf6840598981dd50c89063354fb25fab117f76, родитель 1423b862 (= `origin/cmp-mob-117/vkhod`). Контракт: frozen/contracts/123/1 (206c94f12).
Находки (reslop, status: ready): /tmp/dev-harness-verify/Rev123c/review.md

## Итог

- **R123-1 закрыта.**
  - Продуктовая ветка растёт из 1423b862.
  - Дифф — чистое добавление: `22 0`, один хунк.
  - Разбор YAML базы и головы: если убрать 2 новых шага, получается ровно база, с тем же порядком. Пины
    `.harness`/`.harness117` и шаги 117/111/108/107/995/999/991 не тронуты.
  - Новые шаги стоят на индексах 11–12, между «117 splash…» (10) и «Артефакты 117» (13). У них нет
    `if:`/`continue-on-error`.
  - Точная `run:`-команда шага на worktree 10cf684 с кадрами в `mobile/maestro-out-117`:
    - First-Run 58d → rc 1 и `NIZHE_POROGA<TAB>First-Run dark/light`;
    - все кадры выше порога → rc 0.
    - В обоих прогонах `tee` пишет tsv с 4 строками `KADR`.
- **R123-2 закрыта.**
  - 16 видов битого или обрезанного PNG × 2 кадра = 32 прогона, 32/32. Каждый раз `KADR_NECHITAEM<TAB><кадр>`,
    rc 1, остальные 3 кадра получают строки `KADR … OK`, вывод в грамматике.
  - Красное до правки: тот же набор на a7f22ff39 даёт 8 трейсбеков без вывода.
- **Батарея на OBJECT:** `probe.py` 29/29 rc 0, `--model` 29/29 rc 0, `--matrix` rc 0 (29 CONTROL + 32 STAB KRASEN).
  Мой подсчёт по `source.json` совпадает: 29 входов, 19 стабов, 32 связи. Без скрипта → `SVERKA_ABSENT`, rc 1.
- **Дельта в ЗОНЕ.** В харнессе изменён только `scripts/sverka_maketa.py` (+31/−6), в продукте — только
  `mobile.yml` (добавление). Батарея и контракт относительно заморозки не менялись. Коммиты атомарны:
  по одному на находку.

Блокирующих находок нет. Советы (подробно — в review.md):

- **С-5:** каталог или `OSError` на месте `<snimok>.png` → трейсбек; fail-closed, обхода нет.
- **С-3:** перепин `.harness123` при ленде. Это известно оркестратору; ref существует в ветке реализации.
- **С-1/С-4:** перенос к architect.
- **И-1:** путь клона продукта в задании устарел. 10cf684 есть только в `Impl123fix/mob`, а не в `Impl123/mob`.

Не судилось: живая строка 5 (`gh run`). Сеть запрещена, по контракту она судится на PR 117 v2.

## Прогоны (rc — сырые; PYTHONDONTWRITEBYTECODE=1; клоны со своим `.git`, без сети)

| команда | rc | вывод |
|---|---|---|
| `git clone --local /tmp/dev-harness-worktrees/c907157c/wip-123-implementer h`; `rev-parse HEAD` | 0 | `2cc58c224a8a9ced9709604f0eeb57d2fba6fb07` |
| `git -C /tmp/dev-harness-verify/Impl123/mob cat-file -t 10cf684…` | 128 | `fatal: git cat-file: could not get object info` (И-1) |
| `git clone --local --no-checkout /tmp/dev-harness-verify/Impl123fix/mob mob`; `rev-parse HEAD` | 0 | `10cf6840598981dd50c89063354fb25fab117f76` |
| `git log --format='%H %an %P' 1423b862..10cf684` (mob) | 0 | один коммит, `implementer`, родитель `1423b862559d…` |
| `git diff --numstat 1423b862 10cf684` (mob) | 0 | `22 0 .github/workflows/mobile.yml` |
| `git diff 1423b862 10cf684 \| grep -c '^@@'` / `grep -c '^-[^-]'` | 0 | `1` хунк / `0` удалённых |
| `python3 yaml_cmp.py` | 0 | `jobs equal except android-e2e: True`; `top-level equal: True`; `android-e2e keys equal except steps: True`; `steps base 16 head 18`; `head minus new == base (order kept): True`; `index 117 = 10 new = [11, 12] Артефакты 117 = 13 between: True adjacent: True` |
| `python3 ci_step.py` → сценарий `line5-58d` | step_rc=1 | `KADR<T>First-Run dark<T>0.000<T>0.600<T>wordmark<T>NIZHE_POROGA` (так же light); `err\|NIZHE_POROGA<T>First-Run dark<T>score=0.000 …`, `…light…`; `tsv: exists, lines=4, KADR=4, ==stdout: True` |
| `ci_step.py` → `line5-all-ok` | step_rc=0 | `Splash 0.783/0.782 tagline OK`, `First-Run 0.974/0.974 futer OK`; tsv 4 KADR |
| `ci_step.py` → `trunc-in-ci` | step_rc=1 | `err\|KADR_NECHITAEM<T>Splash dark<T>struct.error`; 3 строки KADR OK; tsv 3 KADR |
| `python3 trunc_smoke.py` (OBJECT) | 0 | честный rc 0; 32 строки `… rc=1 MATCH err=['KADR_NECHITAEM<T><кадр><T><токен>'] out_n=3`; `MISMATCH total: 0`; EXTRA `dir-named-png rc=1 out_n=0 … IsADirectoryError` (С-5) |
| `python3 trunc_smoke_old.py` (a7f22ff39, Splash dark ×16) | 0 | `MISMATCH total: 8` (half, minus15, minus1, minus13, cut-in-IHDR-crc, ihdr-5-bytes, len-field-huge, garbage-after-sig — трейсбек, `out_n=0`) |
| `git diff --stat a7f22ff39 HEAD` (h) | 0 | `scripts/sverka_maketa.py \| 37 +++++---` (31+/6−), 1 файл |
| `git diff --stat frozen/contracts/123/1^{commit} HEAD -- fixtures/workshop_project/mob_sverka_123 contracts/123-mob-sverka-maketa.md` | 0 | пусто |
| `python3 run_probe.py` → `probe.py` | 0 | `CASE_ok=29 other=0 lines=29` |
| → `probe.py --model` | 0 | `CASE_ok=29 other=0 lines=29` |
| → `probe.py --matrix` | 0 | `CONTROL_ok=29 STAB_KRASEN=32 other=0 lines=61` |
| → `source.json` | — | `kejsy=29 stabs=19 links=32`; `stubs dir: 19` |
| `probe.py` без `scripts/sverka_maketa.py` | 1 | `SVERKA_ABSENT: /tmp/dev-harness-verify/Rev123c/h/scripts/sverka_maketa.py` |
| `reslop t -- bash scripts/check_zones.sh` (h) | 0 | `ok: true passed: 88 failed: 0` (в stderr — чужой FAIL грамматики contracts/055, как в круге 1) |
| `reslop t -- bash scripts/check_provodka.sh . contracts/123-mob-sverka-maketa.md` (h) | 1 | `проводка: guard не подключён: …mob_sverka_123/probe.py` (ожидаемо до интеграционного коммита оркестратора) |

`<T>` = TAB. Вывод полностью: `probe-subj.out`, `probe--model.out`, `probe--matrix.out` в этом каталоге.
Промежуточные заметки: `notes.md`.

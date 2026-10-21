FAIL
Суд реализации 123 «mob-sverka-maketa», круг 1 из 3, ревьюер Rev123. Объект: OBJECT=a7f22ff39bf0d675e5b412431a79c00f9932ee51
(ветка `wip/123/implementer`), продукт: Complior-mob `cmp-mob-123/sverka` @ 9ed4686e182b38a3129aa1f6e3f76943ed4b4409.
Контракт: frozen/contracts/123/1 (206c94f12). Находки (reslop, status: ready): /tmp/dev-harness-verify/Rev123/review.md

## Итог

Область правки в порядке: в харнессе один путь зоны (`scripts/sverka_maketa.py`, +356), в продукте один
(`.github/workflows/mobile.yml`, +20/-0). Батарею автор не трогал: дифф от заморозки пуст, единственный её
коммит — architect. Скрипт — байтовая копия модели, и это допустимо: контракт определяет меру докстрингом
модели, инвариант 7 требует её чисел. Батарея 29/29, `--model` 29/29, `--matrix` rc 0 (32 связи / 19
стабов, сходится с моим подсчётом по `source.json`). Без скрипта батарея красная: `SVERKA_ABSENT`.
Вне батареи пропажа каждого из 18 элементов красная и называет элемент; пороги, маски, пустой каталог,
пропуск и дубль кадра, подмена макета, TAB/LF в `id`, glob в снимке ведут себя по контракту.

Блокирующих находок две:

- **R123-1 (блокирует, implementer, проводка mobile.yml):** нарушена строка 6. Шаг сверки поставлен на
  ветку от `main` Complior-mob, а не от `cmp-mob-117/vkhod`. В этом файле нет шага «117 splash/F03.01/F03.02 ×
  тема», нет «Артефакты 117», и ничто не пишет `mobile/maestro-out-117`. Точная команда шага на 9ed4686 даёт
  `tee: …sverka-123.tsv: No such file or directory` и 4× `KADR_OTSUTSTVUET`, rc 1. Job красный при любых
  кадрах, tsv не выгружается, строка 5 недостижима. Cherry-pick на 1423b86 ставит шаг ДО шага 117
  (стр. 264 < 280): сверка упадёт раньше, чем появятся кадры. Исправление — тот же хунк на базе
  `cmp-mob-117/vkhod` между концом шага «117 splash…» и «Артефакты 117».
- **R123-2 (блокирует, implementer, `scripts/sverka_maketa.py:85-90/298-302`):** нарушены инварианты 4 и 5.
  На обрезанном PNG кадра `struct.error` не ловится. Вместо `KADR_NECHITAEM` скрипт пишет Python-трейсбек в
  stderr, rc 1, и остальные 3 кадра не судятся.

Советы: С-1 (architect: та же дыра в модели, нет входа «обрезанный кадр»), С-2 (шапка скрипта называет его
«моделью» и ссылается сама на себя), С-3 (пин `.harness123` = SHA ветки wip, ленд не должен его переписать),
С-4 (architect: элемент целиком под маской судится как 1,0).

## Прогоны (rc — сырые)

Клоны: `git clone --local /tmp/dev-harness-worktrees/c907157c/wip-123-implementer /tmp/dev-harness-verify/Rev123/h`
→ HEAD a7f22ff39…; `git clone --local --no-checkout /tmp/dev-harness-verify/Impl123/mob /tmp/dev-harness-verify/Rev123/mob`
(+ `git fetch` локального `refs/remotes/origin/cmp-mob-117/vkhod` → `refs/x/vkhod` = 1423b86). Свой `.git`, без сети.

| команда (PYTHONDONTWRITEBYTECODE=1) | rc | вывод |
|---|---|---|
| `git diff --stat 9759985e2 HEAD` (h) | 0 | `scripts/sverka_maketa.py \| 356 +++` — 1 файл |
| `git diff --stat frozen/contracts/123/1^{commit} OBJECT -- fixtures/workshop_project/mob_sverka_123 contracts/123-mob-sverka-maketa.md` | 0 | пусто |
| `git log … -- fixtures/workshop_project/mob_sverka_123 contracts/123-…` | 0 | один коммит `67095d86a architect` |
| `md5sum scripts/sverka_maketa.py …/model/sverka_maketa.py`; `cmp` | 0 | оба `7618970892d64c203b9cd5e72f00cfe9`, cmp=0 |
| `python3 fixtures/workshop_project/mob_sverka_123/probe.py` | 0 | 29× `CASE <вход> ok` |
| `… probe.py --model` | 0 | 29× `CASE <вход> ok` |
| `… probe.py --matrix` | 0 | 29× `CONTROL … ok`, 32× `STAB … KRASEN` (19 стабов) |
| `python3 -c` по `source.json` | 0 | `stubs 19 links 32`, `kejsy 29` |
| `probe.py` со скриптом, убранным из клона | 1 | `SVERKA_ABSENT: …/h/scripts/sverka_maketa.py` |
| `reslop t -- bash scripts/check_zones.sh` (h) | 0 | `ok: true passed: 88 failed: 0`. В stderr чужая строка FAIL о грамматике ЗОНЫ в contracts/055, на rc не влияет |
| `reslop t -- bash scripts/check_provodka.sh . contracts/123-mob-sverka-maketa.md` | 1 | `проводка: guard не подключён: …mob_sverka_123/probe.py …` (ожидаемо до интеграционного коммита оркестратора) |
| `git diff --numstat baf942a 9ed4686` (mob) | 0 | `20 0 .github/workflows/mobile.yml` |
| `git merge-base --is-ancestor refs/x/vkhod 9ed4686` | 1 | ветка 117 не предок; merge-base 8748a7a |
| `grep -c maestro-out-117` в mobile.yml @9ed4686 | 0 | `3` (все — сам шаг 123 и его комментарий) |
| `bash -c 'set -o pipefail; python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/…/kadry_117.json --kadry mobile/maestro-out-117 --repo . \| tee mobile/maestro-out-117/sverka-123.tsv'` на чекауте 9ed4686 | 1 | `tee: mobile/maestro-out-117/sverka-123.tsv: No such file or directory`, 4× `KADR_OTSUTSTVUET<TAB><кадр>` |
| `git cherry-pick 9ed4686` на `refs/x/vkhod` → `grep -n '- name:'` | 0 | `257 Checkout …sverka`, `264 123 сверка…`, `280 117 splash/F03.01/F03.02 × тема`, `377 Артефакты 117` |
| `python3 smoke.py base` | 0 | 15 MATCH, 2 MISMATCH (обрезанный PNG, R123-2) |
| `python3 smoke.py elem` | 0 | 18/18 MATCH |

Выдержки smoke.py (сырые строки, `<T>` = TAB):

```
=== honest (splash r1423 + First-Run maket-as-frame) rc=0 MATCH
  out|KADR<T>Splash dark<T>0.783<T>0.600<T>tagline<T>OK
  out|KADR<T>Splash light<T>0.782<T>0.600<T>tagline<T>OK
  out|KADR<T>First-Run dark<T>1.000<T>0.600<T>G<T>OK
=== real First-Run 58d rc=1 MATCH
  err|NIZHE_POROGA<T>First-Run dark<T>score=0.000 porog=0.600 hudshij=wordmark
  err|NIZHE_POROGA<T>First-Run light<T>score=0.000 porog=0.600 hudshij=wordmark
=== duplicate First-Run dark (2 ts) rc=1 MATCH
  err|KADR_NEODNOZNACHEN<T>First-Run dark<T>2
=== porog 0.79 (splash light 0.782 -> below) rc=1 MATCH
=== porog 0.78 (all OK) rc=0 MATCH
=== maska on whole frame rc=2 MATCH
  err|PUSTAYA_SVERKA<T>Splash dark<T>cells=0
=== maket substituted by frame rc=1 MATCH
  err|MAKET_PODMENEN<T>First-Run dark<T>sha256
=== id with trailing LF rc=2 MATCH
  err|MANIFEST_NEVEREN<T>-<T>AssertionError
=== truncated Splash dark PNG (half bytes) rc=1 MISMATCH
  err|  File "/tmp/dev-harness-verify/Rev123/h/scripts/sverka_maketa.py", line 90, in decode_png
  err|struct.error: unpack requires a buffer of 4 bytes
=== not a PNG (text) rc=1 MATCH
  err|KADR_NECHITAEM<T>Splash dark<T>signature
=== remove First-Run light/futer rc=1 MATCH
  out|KADR<T>First-Run light<T>0.000<T>0.600<T>futer<T>NIZHE_POROGA
=== remove Splash light/tagline rc=1 MATCH
  out|KADR<T>Splash light<T>0.031<T>0.600<T>tagline<T>NIZHE_POROGA
```

Живую строку 5 (run/artifact android-e2e) не судил: прогона CI с этой проводкой нет, GitHub не вызывал.

## Для следующего круга

Implementer переносит хунк mobile.yml на базу `cmp-mob-117/vkhod` в позицию после «117 splash/F03.01/F03.02 ×
тема» и до «Артефакты 117» (R123-1), а в зоне `scripts/sverka_maketa.py` превращает обрыв PNG в
`KADR_NECHITAEM` (R123-2). Принять повторно можно после трёх проверок: батарея 29/29 (`--matrix` rc 0);
точная команда шага на новой базе после шага 117 видит кадры; обрезанный кадр даёт
`KADR_NECHITAEM<TAB><кадр>`, без трейсбека, и остальные кадры судятся.

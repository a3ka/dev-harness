accept

Объект: 5ab34ce0644ff849bcb189f285b84325dcc8e543 (HEAD disposable-клона).
Scope: A1r2 бренд-идентичность растра; R1 safe-area Demo-бейджа; затронутый регресс.

А-1 — положительный контроль: `first_run_static_probe.py --repo …/Adv111r3` rc=0, static 16/16. В том числе `WORDMARK_ASSET_IDENTITY`; самостоятельный sha256 product asset = `fcb1a2f87c2277a67c410226e26e949e403f8ec9a02bce970745969c5f02589e`.

А-2 — атака A1r2 живой статической матрицей: `first_run_static_probe.py --repo …/Adv111r3 --matrix` rc=0. Обманки прошли строгий PNG-декод, но дали красноту ровно `WORDMARK_ASSET_IDENTITY`:
* `wordmark-opaque-one-transparent` (429×156, чёрный, один прозрачный пиксель), sha256 `a9f143a1a2c4383d661b67718ec5530fb0f9111ca96e1a00064965e13062dcba`;
* `wordmark-recolored-ink`, sha256 `bb04cfebcf1b9f1597bbcda55bc53ea44ee1c23a7279731fa8852222d3673167`;
* `wordmark-recompressed`, sha256 `1894ca3a6f7498ec0a50783481682e5cf6a8331b8ae0091e616937182d8b1a17`.
Ни у одного из трёх нет побочной красноты. Заглушки «1×1», битый PNG и одноцветный прямоугольник ожидаемо красны также на декоде/наличии и не подменяют эту проверку.

Р-1 — положительный поведенческий контроль: `first_run_probe.py --repo …/Adv111r3` rc=0, honest 15/15. `--matrix` rc=0: `badge-outside-safearea`, `badge-inset-top-zero` и `badge-hardcoded-inset` красны ровно на `DEMO_BADGE_INSET_DARK` и `DEMO_BADGE_INSET_LIGHT`; full-bleed мутанты внешнего root красны только на паре `FIRST_RUN_GROUND_FULL_SURFACE_{DARK,LIGHT}`. Тем самым К7 ловит снятие защиты и хардкод, а К6 — регресс полноэкранного ground. Npm-пилот 995 также прошёл без SafeAreaProvider: `npm test -- --runInBand` rc=0, 14/14.

Регресс:
* 995 `frozen_matrix.py` rc=0: 14 actual assertions зелёны для обоих имён frozen test; drift-контроль ожидаемо rc=1 `FROZEN_BYTES_MISMATCH`, checked=3.
* 999: nav/ui/copy matrices rc=0; baseline `shell_static_probe.py` rc=0 (6/6).
* 108: behavioral matrix rc=0; static matrix rc=0 (`mutants 5, defects 0`).
* npm: `npm run lint` rc=0; `npm run typecheck` rc=0; `npm test -- --runInBand` rc=0 (1 suite, 14 tests).
* `git diff --quiet be6b3d657 -- fixtures/workshop_project/first_run_111` rc=0: frozen-батарея не изменена.

Наблюдение вне blocking scoped-вердикта: `nav_999/shell_static_probe.py --matrix` возвращает rc=2 на собственном якоре `literal-hex-screen`: `MUTATION_ANCHOR_NOT_UNIQUE: mobile/src/features/start/start-screen.tsx` (в текущем файле строка-якорь `backgroundColor: tokens.ground }` отсутствует). Его honest baseline зелёный; объектная дельта e26ba282..OBJECT меняет только `mobile/src/bootstrap/pilot-app.tsx` и `.github/workflows/mobile.yml`, не этот файл. Это дефект/устаревший якорь self-matrix frozen-регрессии, не проходящий мутант и не дефект A1r2/R1 объекта.

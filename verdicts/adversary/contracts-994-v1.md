accept

OBJECT=4edb9ab8b9d1edb1cfc4c63fb8e9b95a16451342

Адверсарный круг 1 по 994: воспроизводимого состояния, в котором неверная per-guard external-CI оговорка снимает wiring и проходит доставленную проверку, не найдено.

Проверено исполнением в одноразовом SSH-клоне на OBJECT:

- `bash fixtures/check_provodka/external_ci_994/probe.sh --cases` — rc 0, `CASES executed=76 mismatches=0`.
- Позитивный контроль `--matrix` — rc 0. Честная модель: `observed=0 valid=1`; 11 обманных моделей (нет реализации, substring, широкие разделители, Unicode-space, сужение границ heading/fence, выход после grant, whole-file, поздний абзац, global grant, missing file) каждая была поймана назначенными клетками (`valid=1`).
- Мои независимые исполняемые заглушки, поданные публичному `--subject`, были пойманы `--cases` (каждый rc 1): always-success — 63 mismatch; missing-tool/rc127 — 76; зашитая первая фраза — 27; пустое поле как успех — 1; фраза из произвольного места файла — 27. Тем самым проверка не объявляет успехом пустой ввод, отсутствие инструмента, константу или ответ не на тот структурный вопрос.
- `--legacy` — rc 0, `LEGACY executed=18 mismatches=0`; `--self-wiring` — rc 0 и сценарий `WITHOUT_OWN_STEP` дал именно прежний wiring-отказ. Прямые `check_provodka` для frozen 991 и 993 — rc 0.
- Границы закрытого предиката: клетки `#заметка` и `````text`` как терминаторы, continuation за каждым, а также отрицание/суффикс через `, ! ? : —`, NBSP на краю и Unicode-space в фразе прошли штатный субъект с назначенными отказами. Поле/абзац/guard binding, первый абзац и терминаторы дополнительно атакованы моделями matrix.
- Реальная собственная проводка: `bash scripts/gen_ci_steps.sh --check && bash scripts/run_ci_lane.sh check:provodka-external-994` — rc 0; lane исполнил всю probe без расхождений. Строгая настоящая TSV-строка проверена `--self-wiring`.
- Приёмка судьи: `bash scripts/verify_antiplacebo.sh --scope check_provodka` — rc 0, 28/28 красных предъявлений. `git diff --exit-code frozen/contracts/994/1 OBJECT -- contracts/991-complior-repeticiya-p107-p111.md contracts/993-cmp-bck-121-validator-5-8-3.md` — rc 0.

Первый scoped-прогон был намеренно отброшен как недостоверный: он пересёкся с параллельной probe, создающей `tmp/provodka-994-*`; последовательный повтор выше зелёный. Это известная интерференция временного клона, не дефект предмета.

Закрытый остаточный риск разделителей вне `.`/`;` не объявляю находкой: он явно принят frozen-контрактом и арбитражем `verdicts/arbitration/contracts-994-closed-class-v1.md`.

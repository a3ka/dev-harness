accept

OBJECT=91da6487b8351a6d8b9a5bb956f7364ea8fdacec
Scope: микро-круг r5, только С11 — инсет Demo на first-run и отсутствие инсет-сдвига на кадрах 995.

Живые положительные контроли на disposable clone `/tmp/dev-harness-verify/Adv111r5/mob`:

- `first_run_static_probe.py --repo ...` — rc=0, `static 16/16`; в том числе `WORDMARK_ASSET_IDENTITY`.
- `first_run_probe.py --repo ...` — rc=0, `honest 19/19`; в том числе К6 `FIRST_RUN_GROUND_FULL_SURFACE_{DARK,LIGHT}` и К7 `DEMO_BADGE_INSET_{DARK,LIGHT}` с обоими top-литералами 47/59.
- Временная проба С11 из `Impl111/r5/c11-offset.probe.test.tsx` на честном объекте — rc=0: `C11_MEASURE dark y0=60 y136=60`, `light y0=60 y136=60` (это прокси раскладки, не device-y).
- `src/bootstrap/__tests__/pilot.test.tsx` — rc=0, 14/14, включая `DEFAULT_OFFLINE`: `<PilotApp />` без `SafeAreaProvider` проходит first-run → F03.02, подтверждая fallback `{top:0}`.

Обманные заглушки и результат:

1. Неверное условие `frame === 'first-run' || frame === 'email' ? insets.top : 0` сохраняет first-run, К6, К7, wordmark и fallback. Поэтому статическая батарея осталась зелёной 16/16, а поведенческая — 19/19. Отдельная С11-проба поймала ровно регрессию: rc=1, в обеих схемах `y0=60`, `y136=196`; упали `TITLE_F03_01_Y_INSET_FREE_DARK` и `_LIGHT`. Следовательно полный r5-контур не принимает сдвиг F03.01.
2. Хардкод `frame === 'first-run' ? 47 : 0` — rc=1 поведенческой пробы, красны ровно `DEMO_BADGE_INSET_DARK` и `_LIGHT`; второй литерал 59 не принимается.
3. Нетронутый PNG с лишним trailing byte (валидный декод, но иная идентичность) — rc=1 статической пробы, красна `WORDMARK_ASSET_IDENTITY`.
4. Пустой `first-run-screen.tsx` — rc=1 статической пробы: красны `SCREEN_SEAM_FIRST_RUN`, `SCREEN_SAFEAREA_COMPONENT`, `SCREEN_THEME_TOKENS`, `CTA_TESTID_BOUND`; пустой предмет не объявляется зелёным.
5. С `PATH=/not/a/real/path` splash-resolver не находит `node`: rc=2 и `INFRASTRUCTURE: ... FileNotFoundError`, не rc=0. Отказ инструмента не маскируется успехом.

Все мутанты восстановлены; `git status --short` disposable clone пуст. Изменений продукта и проверки не делал. Коммит не создавал: Н-85 предписывает коммит оркестратору.

Device-y F03.01: NOT_RUN — это требование reviewer; adversary исполнил агентную прокси-проверку С11, а не release-APK/эмуляторный замер.

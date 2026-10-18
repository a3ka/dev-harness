FAIL

# 995 adversary — круг 3 (последний)

OBJECT: `e44dfd0952754541cb8eb5273f156c37682d89b0`.

## Блокер A1 — отложенный успешный verify авторизует после перехода в recovery

В shipped `mobile/src/bootstrap/pilot-app.tsx` `handleNoAccess` переводит экран в `recovery`, но не увеличивает `verifyGeneration`. Поэтому ранее начатый `verify` сохраняет актуальное поколение, а когда позднее возвращает `authenticated`, выполняет `getSession`/`getDisclosure` и открывает `F02.01` поверх F03.04. Это нарушает принятые инварианты 2 и 4: результат старого challenge не должен авторизовать после безопасного перехода к восстановлению, а F03.V02/A07 остаются вложенными в «нет доступа».

Воспроизведение выполнено на честной одноразовой копии OBJECT `/tmp/dev-harness-verify/adv995r3/honest` (отдельный `npm ci --no-audit --no-fund`). Throwaway RNTL-тест загрузил настоящий `PilotApp` с DI-портами, затем: First-Run → begin(`one@example.invalid`) → ввод synthetic code → начал deferred `verify` → `auth-no-access` (на экране виден `auth-return`) → deferred `verify` вернул `{status: 'authenticated'}`. Ожидание отсутствия `F02.01` упало: фактически виден `testID="F02.01"`; `getSession` уже был вызван. Тест удалён после прогона.

Это именно непокрытый переход: `stale_table` проверяет `VERIFY_CHANGE_EMAIL`, `VERIFY_RETURN`, `VERIFY_RESEND`, `VERIFY_REBEGIN`, `VERIFY_UNMOUNT`, но не `VERIFY_NO_ACCESS`. Его `RECOVER_*` ячейки запускают deferred `recover`, не deferred `verify`, и потому не наблюдают эту ветку. Нынешняя проверка остаётся зелёной на неправильном OBJECT: полный набор 12 H-проб завершился rc0, включая все 22 `stale_table`-ячейки; shipped RNTL `npm test -- --runInBand` завершился `3 passed`, `17 passed`. По исходному контексту CI этого OBJECT также имеет `android-e2e SUCCESS`; нативный runner дополнительно проверен `native_matrix.py`: 16 контролей, честные device/ci rc0, failed/skipped/missing-png/nonzero rc1, missing-report/empty/malformed rc2. Следовательно, это ложная зелень проверки, а не вечно-красный контур.

Требуемая правка автора: инвалидировать поколение при переходе `handleNoAccess` (либо равнозначно гарантировать, что результат verify не применяется вне активного code frame) и добавить отрицательную исполняемую ячейку deferred-verify → no-access/recovery. После правки этот сценарий обязан краснеть ровно на stale evidence.

## Контроль красных admission-мутаций круга 2

H взят ровно на `0c0c38eddc1eb8e6109bc5cb9e78daef366dd063` в `/tmp/dev-harness-verify/adv995r3/H`. На отдельных disposable-копиях с отдельным `npm ci` построены:

- `mut-backdoor`: в shipped `mocks/runtime.ts` добавлен допуск `code === 'adversary-bypass-code'`;
- `mut-unicode`: туда же добавлен допуск `code === PILOT_DEMO_CODE + "\\u200B"`.

Оба неправильных субъекта получили rc1 от `admission_family_probe.py`: backdoor — статический `ADMISSION_BRANCH_COUNT:2; ADMISSION_EXTRA_COMPARISON:2`; U+200B вариант — статический `ADMISSION_EXTRA_COMPARISON:2` и динамический `INSERT` (admitted). Честный OBJECT прошёл static и всё семейство из 860 отрицательных мутаций плюс live control, rc0. Тем самым новые барьеры действительно закрывают предыдущие `mut-backdoor` и `mut-unicode` и имеют позитивный контроль.

## Выполненные дополнительные атаки/контроли

- **Пустой/отсутствующий native evidence и отказ как успех:** `native_matrix.py` не считает их зелёными: missing report, empty и malformed дают rc2; failed/skipped/missing PNG/nonzero — rc1.
- **Нейтрализация нативного evidence:** те же точечные failed/skipped/missing-png контрмодели падают; честные device и CI модели зелёные.
- **Инструмент/полный H:** на honest копии пройдены rc0 `probe --check-frozen`, `runtime`, `bundle` (http/mock), `schema`, `frozen_matrix`, `transport`, `admission`, `stale`, `types`, `pins`, `admission_family`, `stale_table`.
- **Другие конкурирующие порты:** table действительно покрывает begin/unmount, resend×resend, getSession/unmount и return/rebegin-пути; найденный обход не относится ни к одной её assertion-строке.

Полный список блокеров этого круга: только A1.

FAIL
OBJECT=cb64b63c75263c7e03bb3c6b5b277c9b0e0c2dd3
СУД: repo=Complior-mob (+dev-harness); предмет=118; фаза=реализация v2; роль=adversary; вызов=1/2; модель-план=zai/glm-5.3; сессия=Adv118v2b; модель-факт=openai-codex/gpt-5.6-terra; SHA=cb64b63c75263c7e03bb3c6b5b277c9b0e0c2dd3; предыдущий=verdicts/critic/contracts-118-v2.md; исключение=нет.

БЛОКИРУЕТ

1. ОБЯЗАТЕЛЬСТВО: положительный контроль честной реализации обязан быть зелёным; приёмочный критерий контракта требует rc 0 от `proverka_proiskhozdenija.py` с `--repo .` после честного Jest-отчёта.

КЛАСС ПРИЧИНЫ: проверяющий теряет относительный путь к production-stand-in после собственного `cwd=repo / 'mobile'`.

СОСТОЯНИЕ: неизменённый OBJECT, свежий честный `jest-otchet.json` (11 suites/105 tests passed), запуск из корня продукта ровно с объявленным относительным `--repo .`.

НАБЛЮДЕНИЕ: checker вернул rc 1 и 28 раз `PRICHINA\tKOMPOZICIJA_OS_NE_ISPOLNENA ... rc=127`. Первый воспроизводимый отказ: `admission=W1A gate=null sobytie=demo rc=127`; непосредственный запуск показывает `bash: mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh: No such file or directory`. В `sud_kompoziciju` путь `Path('.') / mobile/src/...` передаётся относительным одновременно с `cwd='mobile'`, поэтому дочерний bash ищет `mobile/mobile/src/...`. Это ложный красный результат честного кандидата, а не осмысленное исполнение осей.

ВОСПРОИЗВЕДЕНИЕ (сырой вывод):
```text
$ cd /tmp/dev-harness-verify/Adv118v2b/mob/mobile && npm test -- --json --outputFile=e2e-erstinformation/jest-otchet.json
rc=0
Test Suites: 11 passed, 11 total
Tests:       105 passed, 105 total

$ cd /tmp/dev-harness-verify/Adv118v2b/mob && python3 mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-erstinformation --repo . --harness /tmp/dev-harness-verify/Adv118v2b/harness --jest-otchet e2e-erstinformation/jest-otchet.json
rc=1
PRICHINA  KOMPOZICIJA_OS_NE_ISPOLNENA  admission=W1A gate=null sobytie=demo rc=127
... (28 осей, тот же rc=127)

$ cd /tmp/dev-harness-verify/Adv118v2b/mob/mobile && bash mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh W1A current net demo net
rc=127
bash: mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh: No such file or directory
```

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: checker канонизирует `repo`/путь stand-in до смены cwd (либо передаёт дочернему bash абсолютный путь); на неизменённом кандидате объявленная команда с `--repo .`, свежим отчётом и корректным harness возвращает rc 0. Контроль показывает, что это именно ошибка относительности: с теми же байтами, отчётом и harness, но абсолютными `--pack`/`--repo`, checker вернул rc 0 без вывода.

СОВЕТ

1. Подлинность/свежесть JSON-отчёта остаётся действительным объявленным остатком, а не вторым блокером. На временной заглушке `mobile/src/app/onboarding-session.tsx`, возвращающей константу `onboarding.admission='W1A'` для любой сессии, checker с ранее честным отчётом вернул rc 0 без вывода. Реальный CI текущего OBJECT не даёт этому пройти сам по себе: временная заглушка при `npm test -- --json --outputFile=...` дала rc 1, `3 failed suites`, `20 failed / 85 passed`; до checker job остановится. В `mobile.yml` строка 600 запускает `npm test -- --json --outputFile=...`, строка 658 передаёт этот путь checker'у, причём использует абсолютный `$PWD`. Значит рукописный/устаревший отчёт достижим только при отдельной подмене runner/package/шага; это ровно остаток контракта, ловимый журналом CI, reviewer и независимым adversary, а не самим checker'ом. Временная заглушка удалена; исходник восстановлен побайтно (`git diff --exit-code -- mobile/src/app/onboarding-session.tsx`, rc 0).

2. Отсутствующий `bash` не становится ложным успехом: `env PATH=/nonexistent /usr/bin/python3 ...proverka...` завершился rc 1 с `FileNotFoundError: ... 'bash'`. Это fail-closed, но без именованного `PRICHINA`; улучшение диагностики — совет.

ПРОВЕРЕННЫЕ КЛАССЫ И ИСХОДЫ

- Позитивный контроль: полный Jest честного OBJECT — rc 0, 11/11 suites и 105/105 tests; checker с абсолютным repo — rc 0. Позитивный контроль с объявленным `--repo .` — БЛОКЕР выше.
- Hardcoded constant / нейтрализация: W1A-константа даёт 20 красных Jest-тестов; независимый checker на старом честном JSON её не видит (объявленный остаток), а реальный порядок CI её останавливает до checker.
- Пустой вход: отчёт `{}` дал rc 1: `SROK_OTCHET_NE_USPEH success=None`, `SROK_OTCHET_BEZ_FAJLA zapisej=0`.
- Правильный ответ не на тот вопрос: отчёт с единственной записью `/tmp/other.test.tsx` дал rc 1: `SROK_OTCHET_BEZ_FAJLA zapisej=0`.
- Сужение `-t`: `npm test -- -t srok-svezhaja-demo --json --outputFile=...` дало rc 0, 1 passed/104 skipped; checker дал rc 1, 12 `SROK_KLETKA_NE_ISPOLNENA ... 'pending'`, `SROK_OTCHET_NE_POLNOSTJU vne passed=12`, `SROK_OTCHET_S_PENDING numPendingTests=104`.
- Инструмент вне PATH: rc 1, не ложный зелёный (совет о диагностике выше).
- Проверка формы/skip/only/todo, удаления файла, чужого отчёта, порядка CI, пустого набора, байтовых `auth_time` escape/пробелов/порядка/BOM/CRLF/двойного expires/иной даты/переформата mocks: `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --stabs` rc 0; 71 CASE ok, 51 STAB KRASEN, `SVJAZI 69`.
- Честная модель батареи: `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --model` rc 0; 71 CASE ok, 16 KADR `1.000` при пороге `0.600`, `guard-shag ok`.
- Срок с пробелом: одноразовая RNTL-проба production Root с `expires_at=' 2099-12-31T00:00:00Z'` — rc 0, 1/1 passed; Erstinformation не открылась. Временная проба удалена.

НЕ ПРОВЕРЕНО ПОСЛЕ ОБНАРУЖЕНИЯ БЛОКЕРА

Реальный Android/Maestro release-путь и полные регресс-батареи 995, 108, 111 и 117; после устранения ложного красного положительного контроля их следует исполнять на неизменённом исправленном кандидате. Не запускались повторно CI и удалённый журнал CI; порядок и абсолютный путь текущего `mobile.yml` проверены по его строкам 600 и 658.

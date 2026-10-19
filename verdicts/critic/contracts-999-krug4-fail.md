FAIL
OBJECT=7e6116a7ab8d5ada64a8f69df8397e8d84390220

# Контракт 999 — один микро-круг К1.5 + регресс К1–К4

Набор артефактов полный. Судился HEAD origin/wip/999/architect. pre_critic с путём контракта rc=0, precision-гейт rc=0. Основной репозиторий не изменён; push не выполнялся.

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:53–54 — К1.5 по-прежнему не наблюдается ПОСЛЕ возврата из profile. MOTION_PROFILE_* заканчиваются внутри профиля (`fixtures/workshop_project/nav_999/nav_motion.test.tsx:43–52`), MOTION_DEEPLINK_* исполняют иной путь back (:56–68). Старые PROFILE_RETURN_* проходят back, но не проверяют faden после него (`nav.test.tsx:110–115`).

ОБХОД: в честной модели изменить только `mobile/src/bootstrap/tab-shell.tsx`: добавить `const [profileReturned, setProfileReturned] = useState(false);`; заменить `const leaveProfile = () => setRoute('tabs');` на `const leaveProfile = () => { setRoute('tabs'); setProfileReturned(true); };`; заменить `!reducedMotion ? <View` на `(!reducedMotion || profileReturned) ? <View`. При reducedMotion=true последовательность initialSection → profile-entry → back возвращает правильную вкладку, убирает Back, но показывает shell-faden. Все четыре пробы и все четыре --matrix возвращают rc=0. Независимый живой RNTL-свидетель на четырёх origin × двух темах: честная модель 8/8 зелёных, rc=0; обход 8/8 красных на отсутствии faden ПОСЛЕ back, rc=1.

Это принятые К1.2 и К1.5, не новый пункт. returnSection не задан, новые маршруты/значения портов не введены. TAB_ORDER сохранён, MOTION_ROUTE_GRAMMAR зелёный. Конкретный прежний обход `route === 'profile'` закрыт, но наблюдение свойства после всех уже объявленных переходов — нет.

АРБИТР: роль arbiter по контракту 999; предмет повторной причины — принадлежность tabs(origin) после profile-entry → back уже принятому К1.2/К1.5. Действующее основание: `verdicts/arbitration/contracts-999-perechen-v1.md`, Решение 2, К1.2/К1.5. Строка является созывом по роли; отдельная сессия арбитра не запускалась. Новый обычный круг критика не разрешается: мандат был на один микро-круг.

## Регресс

Diff 559eb232d..7e6116a7a: nav.test.tsx, ui.test.tsx, copy_surface.test.tsx, surface_sweep.ts, ui_probe.py, copy_probe.py, shell_static_probe.py, source.json побайтово неизменны. Все 165 прежних nav-клеток сохранены; имя/named/патчи 16 прежних nav-мутантов совпадают, depends на старых клетках не изменены. Все 12 декоев сверены с CRITIC/ARB исходного арбитражного measure.py побайтово. Матрицы: nav 20 / ui 18 / static 7 / copy 5, все named RED, unexpected_red=none, включая четыре новых декоя. Регресс К1–К4 не обнаружен.

Пять вопросов роли: критерий слабее предмета — обход выше; команды названы, но не наблюдают конкретное свойство после принятого перехода; продуктовое решение исполнителю не оставлено; исполнители/зоны названы, обход внутри tab-shell.tsx; применена норма AGENTS.md о красных критериях, отдельных блокеров вне микро-круга нет. Советов вне микро-круга нет.

## Сырые rc и воспроизведение

Корень `/tmp/dev-harness-verify/Critic999m/clone`; собственная копия продукта `.critic-R`, B=f0d8e54e181853473e23c7df3dc623bbb7faecdf. Мутации выполнялись только там; восемь модельных файлов после измерения побайтово восстановлены.

```text
bash scripts/pre_critic.sh 999
rc=2; NOT_IMPLEMENTED: контракт не найден: 999
bash scripts/pre_critic.sh contracts/999-cmp-mob-002-navigatsiya.md
rc=0; КРИТИК: дверь зелёная
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic999m/clone contracts/999-cmp-mob-002-navigatsiya.md
rc=0; OK
env PYTHONDONTWRITEBYTECODE=1 python3 .critic-audit.py
rc=0
witness-honest: rc=0; cells=8; failed=0
honest-nav: rc=0
honest-ui: rc=0
honest-shell_static: rc=0
honest-copy: rc=0
bypass-nav: rc=0
bypass-ui: rc=0
bypass-shell_static: rc=0
bypass-copy: rc=0
witness-bypass: rc=1; cells=8; failed=8
bypass-matrix-nav: rc=0
bypass-matrix-ui: rc=0
bypass-matrix-shell_static: rc=0
bypass-matrix-copy: rc=0
env PYTHONDONTWRITEBYTECODE=1 python3 .critic-regression.py
rc=0
env PYTHONDONTWRITEBYTECODE=1 python3 .critic-summary.py
rc=0
```

Первый вызов pre_critic имел неверный аргумент критика; после чтения интерфейса выполнен корректный обязательный вызов. Первые версии вспомогательных regression/summary дали rc=1 из-за собственных ошибок вывода/парсинга, затем исправлены; предметные прогоны из-за этого не повторялись.

Каждая проба: `python3 fixtures/workshop_project/nav_999/<семья>_probe.py --repo <клон>/.critic-R`, матрицы дополнительно `--matrix`. На честном дереве и обходе живые уникальные клетки: nav 238, ui 18, static 6, copy 51 — все rc=0. Независимый свидетель падает на `queryByTestId('shell-faden').toBeNull()` после back, получая настоящий View с testID=shell-faden.

Полный вердикт: `/tmp/dev-harness-verify/Critic999m/verdict.md`. Команды/stdout/stderr/EXIT: соседние `{honest-*,bypass-*,witness-*}.log`; точные замены `bypass-patches.json`; свидетель `returned.test.tsx`; измеритель `clone/.critic-audit.py`. Android/Maestro, полный проектный прогон и будущий CI не запускались и зелёными не объявляются. Единственное основание FAIL — воспроизведённый обход К1.5.

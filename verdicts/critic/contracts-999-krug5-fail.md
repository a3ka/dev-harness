FAIL
OBJECT=7e6116a7ab8d5ada64a8f69df8397e8d84390220

остаток К1.5 (возврат из profile при reducedMotion) принят владельцем 2026-10-19 ~11:15 UTC как остаточный риск, реализация обязана исключить анимацию во всех переходах

# Контракт 999 — один прогон с вводной владельца

Набор артефактов полный: предмет и исполняемый критерий закоммичены на OBJECT; исполнители и ЗОНА-строки названы. Объект получен checkout origin/wip/999/architect в отдельном клоне. Корректный pre_critic, precision-гейт и форма модели угроз — rc=0. Контракт, его пробы и модель не исправлялись. Основной репозиторий не изменён, push не выполнялся.

## Единственная блокирующая находка вне принятого остатка

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:53 — К1.5 требует, чтобы при rm=true вкладки не были disabled, но критерии :67–68 пропускают отключение выбранной вкладки. Проверки `fixtures/workshop_project/nav_999/nav.test.tsx:80,84` читают `props.disabled` хоста, тогда как disabled настоящего Pressable наблюдается в `accessibilityState.disabled`. Для диагонального перехода from→from сравнение конечного selected не отличает выполненное действие от заблокированного: состояние и без нажатия уже правильное.

ОБХОД: в установленной честной модели изменить только `mobile/src/bootstrap/tab-shell.tsx`: перед единственным `style={styles.tab}` добавить `disabled={reducedMotion && section === id}`. При rm=true выбранная вкладка действительно disabled; при rm=false доступна. Четыре обычные пробы и все четыре `--matrix` возвращают rc=0. Независимый RNTL-свидетель `toBeEnabled()` на четырёх исходных вкладках × двух темах × двух значениях reducedMotion: честная модель rc=0, 16/16; обход rc=1, восемь отказов — ровно все rm=true. Сырой отказ показывает настоящий host View с `accessibilityRole="tab"`, `accessibilityState={disabled: true, selected: true}` и правильным testID.

Это не анимация, не возврат из profile и не дополнительное состояние: дефект виден сразу после render в объявленном tabs(origin), без returnSection. Основание уже принято арбитражем `verdicts/arbitration/contracts-999-perechen-v1.md`, Решение 2, К1.5: «каждая вкладка disabled !== true». Считать выбранную вкладку допустимо отключённой означало бы изменить это требование; настоящим вердиктом оно не меняется. Принятый обход profileReturned не переоткрывался и повторно не исполнялся.

## Остальной регресс и пять вопросов роли

1. Критерий слабее предмета — конкретный обход выше, вне принятого остатка.
2. Команды названы и исполнимы; недостаточность — неверное наблюдение доступности. Будущая Android-приёмка не объявляется выполненной.
3. Решение не оставлено исполнителю: доступность каждой вкладки уже определена К1.5; новых требований к интерфейсу не добавлено.
4. Исполнители и границы названы в :79–89. Обход целиком внутри implementer-пути tab-shell.tsx; расширять зону не требуется.
5. Применена норма AGENTS.md о красных критериях кодовой задачи. Дополнительного самостоятельного противоречия норме в рассматриваемых разделах не установлено.

Живые матрицы честного эталона nav/ui/static/copy — rc=0 каждая; именованные мутанты красные, unexpected_red=none, включая семь декоев критика, X1–X5 арбитра и четыре декоя микро-круга движения. К2–К4 и прежние именованные навигационные проверки регрессии не показали. `git diff --exit-code 559eb232d OBJECT` по nav.test.tsx, ui.test.tsx, copy_surface.test.tsx, surface_sweep.ts, ui_probe.py, copy_probe.py, shell_static_probe.py, source.json — rc=0, файлы побайтово неизменны. Это не доказывает полноту К1.5: новый обход проходит и сохранённые проверки.

Советов вне находки нет. Новая причина — доступность выбранной вкладки, а не повтор прежней причины анимации после profile. Следующий обычный круг этим вердиктом не назначается.

## Команды, сырые rc и артефакты

Корень: `/tmp/dev-harness-verify/Critic999n/clone`. Собственное disposable-дерево R: `.critic-runtime`, отдельная копия `/tmp/dev-harness-verify/Architect999m/ref`; чужое дерево только читалось. Измеритель устанавливает байты модели из OBJECT, мутацию и свидетель временно через `installed`, восстанавливая файлы при выходе.

```text
bash scripts/pre_critic.sh 999 contracts/999-cmp-mob-002-navigatsiya.md
rc=1; использование: pre_critic.sh [--repo R] <отн-путь-контракта>
bash scripts/pre_critic.sh contracts/999-cmp-mob-002-navigatsiya.md
rc=0; КРИТИК: дверь зелёная
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic999n/clone contracts/999-cmp-mob-002-navigatsiya.md
rc=0; OK
bash scripts/check_threat_model.sh . contracts/999-cmp-mob-002-navigatsiya.md
rc=0; модель угроз: секция валидна (ЗАЩИЩАЕТ 8 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))

Матрицы честного эталона, отдельные живые вызовы:
nav_probe.py --repo R --matrix: rc=0
ui_probe.py --repo R --matrix: rc=0
shell_static_probe.py --repo R --matrix: rc=0
copy_probe.py --repo R --matrix: rc=0

env PYTHONDONTWRITEBYTECODE=1 python3 .critic-measure.py
rc=0
honest: rc=0; клеток=16; красных=0; []
обход/nav: rc=0
обход/ui: rc=0
обход/shell_static: rc=0
обход/copy: rc=0
disabled: rc=1; клеток=16; красных=8; ['ENABLED_start_dark_true', 'ENABLED_start_light_true', 'ENABLED_vorgaenge_dark_true', 'ENABLED_vorgaenge_light_true', 'ENABLED_schutz_dark_true', 'ENABLED_schutz_light_true', 'ENABLED_post_dark_true', 'ENABLED_post_light_true']
обход/матрица/nav: rc=0
обход/матрица/ui: rc=0
обход/матрица/shell_static: rc=0
обход/матрица/copy: rc=0
```

Первый вызов pre_critic — ошибка аргументов критика; корректный обязательный барьер затем исполнен до разбора по существу. Отдельная попытка запуска через поле env инструмента отклонена до исполнения; в доказательства не включена. У измерителя rc=0 означает получение ожидаемых результатов, включая настоящий rc=1 независимого свидетеля.

Полные команды семей: `env PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/nav_999/<семья>_probe.py --repo /tmp/dev-harness-verify/Critic999n/clone/.critic-runtime`, для матриц добавляется `--matrix`. В клоне сохранены `.critic-measure.py` (точная единственная мутация и команды), `.critic-enabled.test.tsx` (свидетель), `.critic-honest-witness.log`, `.critic-disabled-witness.log`, `.critic-disabled-{nav,ui,shell_static,copy}.log`, `.critic-disabled-matrix-{nav,ui,shell_static,copy}.log`. В коммит входит только вердикт.

Android/Maestro, полный CI продукта, frozen-995 на будущем C и визуальный нативный рендер не запускались и зелёными не объявляются. FAIL относится только к доказанному обходу исполняемого критерия доступности К1.5.

accept
OBJECT=36b3ca3c07d98c473e36dbd9427181f191d8a2fd
СУД: repo=dev-harness; предмет=117; фаза=контракт (адресная по 143, правка по вердикту); роль=critic; вызов=2/2 (scoped: блокеры 1/2); модель-план=openai-codex/gpt-6-sol; сессия=Crit117b; модель-факт=openai-codex/gpt-6-sol; SHA=36b3ca3c07d98c473e36dbd9427181f191d8a2fd; предыдущий=verdicts/critic/contracts-117-v5-krug1-fail.md; исключение=нет

Блокер круга 1 закрыт: contracts/117-cmp-mob-vkhod-splash.md:1405-1421 требует сборку release APK в `build-apk`, исполнение сценария и шаг сверки 123 именно в `e2e-splash`, required-сигнал — агрегат `android-e2e`; негатив краснит и экранную задачу, и агрегат. Замороженная модель 143/1 содержит jobs `build-apk` (:342), `e2e-splash` (:393, шаг 123 :563), `e2e-first-run` (:578, шаг 135 :661, upload maestro-first-run-* :760), агрегат `android-e2e` (:1306). Перечень ВСЕХ строк с `android-e2e` (фактический `grep -n`/построчный счёт: **31**, а не 24 из отчёта архитектора): :118,121,129,136,137,140,145,154,156,158-170,178,180,182 — шапки, §Замены и цитаты; :501 — исторический замер; :816,1406,1415,1420,1571 — только имя required-агрегата. Иных действующих размещений шагов в агрегате нет. Адресный diff `git diff --unified=0 frozen/contracts/117/4 36b3ca3c07d98c473e36dbd9427181f191d8a2fd -- contracts/117-cmp-mob-vkhod-splash.md` (rc0): шапка/§Замены и только старые строки 215,245,644,744,907,1333-1334,1341,1345-1347,1497,1690-1691,1695,1699,1703,1714,1729,1749,1767,1769,1805; все сведены к 13 пунктам §Замены v6 (:158-170). Кадры, мера, порог, тела шагов и их пины не изменены. `git diff-tree --no-commit-id --name-only -r 36b3ca3c07d98c473e36dbd9427181f191d8a2fd` (rc0) назвал лишь контракт и три уже адресно изменённых на v5 файла `fixtures/workshop_project/vkhod_117/{model/github.workflows.mobile.yml,source.json,vkhod_static_probe.py}`; `git diff --stat a61908383888590ea5e9ce4197836dbd58c16651 36b3ca3c07d98c473e36dbd9427181f191d8a2fd -- fixtures` пуст, rc0. Матрица 52 мутантов прошлого суда применима к неизменной батарее, повторно не запускалась.

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:133-145 — внутренняя метка v6 расходится со следующим номером тега 117/5, что неудобно читателю. Не блокирует: `scripts/freeze_contract.sh:275-294` вычисляет номер по `refs/tags/frozen/contracts/117/*`, не по свободному заголовку; текущий blob и адресные пункты однозначно привязаны к `frozen/contracts/117/4`. Человекочитаемую метку можно согласовать при следующей разрешённой адресной редакции.

Доказательства (рабочий клон `/tmp/dev-harness-verify/Crit117b/repo`, disposable target-tree — собственная копия Fix117):
- `git cat-file -t 36b3ca3c07d98c473e36dbd9427181f191d8a2fd` → `commit`, rc0; теги `frozen/contracts/{117/4,123/2,111/4,143/1}` совпадают с отдельным клоном origin (ae79898c, 79e2fecf, 15be96a4, 438ccbbf). Вначале `pre_critic` → `ОТКАЗ: precision-gate красен`, rc1: в локальном клоне отсутствовал новый тег `frozen/contracts/141/2`; `check_precision_gate` назвал `missing-remote`. После `git fetch --tags origin` rc0 полный набор гейтов зелёный.
- `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Crit117b/target-tree --model` → `static 70/70`, rc0; та же команда без `--model` → `static 70/70`, rc0.
- `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Crit117b/monolith` → rc1, красные строки РОВНО:
```
RED SVERKA_123_STEP_UNCONDITIONAL: шагов с .harness123/scripts/sverka_maketa.py 0 ключи шага None
RED SVERKA_123_MANIFEST_CANON: токены [] кадры в git []
RED SVERKA_123_HARNESS_PIN: checkout .harness123 0 шаг сверки [] checkout []
```
- Повтор собственной атаки круга 1: `python3 /tmp/dev-harness-verify/Crit117b/attack_repeat.py 117` (подмена `source.json sverka_123.provodka.job=android-e2e` только в памяти) → оболочка rc0, внутренняя проба rc1; сырой вывод полностью:
```
ATTACK 117: source.json sverka_123.provodka.job=android-e2e only in memory
RED SVERKA_123_STEP_UNCONDITIONAL: шагов с .harness123/scripts/sverka_maketa.py 0 ключи шага None
RED SVERKA_123_MANIFEST_CANON: токены [] кадры в git []
RED SVERKA_123_HARNESS_PIN: checkout .harness123 0 шаг сверки [] checkout []
ATTACK_RC= 1 RED_COUNT= 3 INFRASTRUCTURE= 0
```
- `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit117b/repo contracts/117-cmp-mob-vkhod-splash.md && bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit117b/repo contracts/117-cmp-mob-vkhod-splash.md && bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit117b/repo contracts/117-cmp-mob-vkhod-splash.md && bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit117b/repo contracts/117-cmp-mob-vkhod-splash.md && bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit117b/repo contracts/117-cmp-mob-vkhod-splash.md && bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit117b/repo contracts/117-cmp-mob-vkhod-splash.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2; КРИТИК: дверь зелёная; OK; OK; потолки в порядке; модель угроз: секция валидна (1/1)`, rc0.

Живой PR после разделения не запускался. Фактическая модель архитектора по трейсу не установлена в доступной истории; оркестратор должен сверить независимость до применения решения. Заглушка `ОЖИДАЕТСЯ-СЛОВО-ВЛАДЕЛЬЦА` намеренно оставлена автором; право заменить её и заморозить остаётся владельцу/оркестратору. Вердикт не коммитился по заданию этой сессии. Одноразовый `attack_repeat.py` и disposable-продукты после атак удалены.

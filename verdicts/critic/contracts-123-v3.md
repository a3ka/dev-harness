accept
OBJECT=c707e0ea41dc939f3eee7a1796ca1c4e78c579c8
СУД: repo=dev-harness; предмет=123; фаза=контракт (адресная по 143, правка по вердикту); роль=critic; вызов=2/2 (scoped: блокеры 1/2); модель-план=openai-codex/gpt-6-sol; сессия=Crit117b; модель-факт=openai-codex/gpt-6-sol; SHA=c707e0ea41dc939f3eee7a1796ca1c4e78c579c8; предыдущий=verdicts/critic/contracts-123-v3-krug1-fail.md; исключение=нет

Блокер круга 1 закрыт: contracts/123-mob-sverka-maketa.md:84-85 требует шаг сверки 123 в задаче `e2e-splash`, после сценария 117 и перед выгрузкой «Артефакты 117». Отказ Splash краснит `e2e-splash` и required-агрегат `android-e2e`. Негатив-пара требует rc0 шага и зелёный Splash, но явно НЕ обещает зелёный агрегат: другой выбранный красный экран краснит required-сигнал (143 И-3/И-5). Наблюдаемый результат :55 и граница implementer :102, энфорсмент :116 согласованы с новым носителем. Из 15 строк с `android-e2e` после grep живые употребления — только агрегат/required (:4, :55, :84-85, :116), историческая сводка монолита (:46-47, :102), остальные — цитаты переноса в §Замены (:11-23). `git diff --unified=0 frozen/contracts/123/2 c707e0ea41dc939f3eee7a1796ca1c4e78c579c8 -- contracts/123-mob-sverka-maketa.md` → rc0: только шапка/§Замены и старые строки 4,31,60-61,78,92; ровно шесть адресных пунктов :11-16, кадры/мера/порог не менялись. `git diff-tree --no-commit-id --name-only -r OBJECT` → только контракт, rc0; `git diff --stat e1b53fb9324b8b3230d1a84c74c02badb69f79aa OBJECT -- fixtures` → пусто, rc0. Матрица 123 (20 стабов, 35 именованных связей) прошлого суда остаётся применима к тем же байтам, повторно не запускалась.

СОВЕТ contracts/123-mob-sverka-maketa.md:4 — метка v4 против будущего тега 123/3 способна запутать читателя; не блокирует достижимую работу: `scripts/freeze_contract.sh:275-294` считает версию по frozen-тегам и называет собственный путь вердикта, а §Замены однозначно указывает базу `frozen/contracts/123/2`. Человекочитаемую метку стоит согласовать при следующей разрешённой правке, не расширяя этот адрес.

Доказательства (клон `/tmp/dev-harness-verify/Crit117b/repo123`):
- `git cat-file -t OBJECT` → `commit`, rc0; база frozen/contracts/123/2 = 79e2fecfd6774b180821788faf841badb42f77b0 локально и в отдельном клоне origin.
- Повтор собственной атаки круга 1: `python3 /tmp/dev-harness-verify/Crit117b/attack_repeat.py 123` (в собственной временной копии субъекта `score >= porog` → `score >= 0.0`; probe.py без правок) → оболочка rc0, внутренняя проба rc1; сырой вывод целиком:
```
ATTACK 123: score >= porog replaced with score >= 0.0
CASE first-run-814 FAIL rc=0 ожидался 1
CASE first-run-58d FAIL rc=0 ожидался 1
CASE wordmark-1-01 FAIL rc=0 ожидался 1
CASE bez-wordmark-first-run FAIL rc=0 ожидался 1
CASE bez-znaka-first-run FAIL rc=0 ожидался 1
CASE bez-zagolovka FAIL rc=0 ожидался 1
CASE bez-podzagolovka FAIL rc=0 ожидался 1
CASE bez-cta FAIL rc=0 ожидался 1
CASE bez-futera FAIL rc=0 ожидался 1
CASE bez-znaka-splash-dark FAIL rc=0 ожидался 1
CASE bez-wordmark-splash-dark FAIL rc=0 ожидался 1
CASE bez-tagline-splash-dark FAIL rc=0 ожидался 1
CASE bez-znaka-splash-light FAIL rc=0 ожидался 1
CASE bez-tagline-splash-light FAIL rc=0 ожидался 1
CASE vne-prefiksa-first-run-58d FAIL rc=0 ожидался 1
ATTACK_RC= 1 FAIL_COUNT= 15
```
- `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit117b/repo123 contracts/123-mob-sverka-maketa.md && bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit117b/repo123 contracts/123-mob-sverka-maketa.md && bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit117b/repo123 contracts/123-mob-sverka-maketa.md && bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit117b/repo123 contracts/123-mob-sverka-maketa.md && bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit117b/repo123 contracts/123-mob-sverka-maketa.md && bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit117b/repo123 contracts/123-mob-sverka-maketa.md` → вывод `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1; КРИТИК: дверь зелёная; OK; OK; потолки в порядке; модель угроз: секция валидна (8/10)`; последняя команда выполнена, отказа не было. Инструмент автоматически вынес хвост команды в background; финальный вывод получен, отдельного кода завершения в уведомлении нет, **[INFERENCE] rc0**.

Живой PR после разделения не запускался. Фактическая модель архитектора по трейсу не установлена в доступной истории; проверка независимости судьёй/оркестратором до материализации заморозки обязательна. Заглушка `ОЖИДАЕТСЯ-СЛОВО-ВЛАДЕЛЬЦА` ожидаема и не подменена. Вердикт не коммитился по заданию этой сессии.

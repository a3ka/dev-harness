FAIL
OBJECT=155cb90732e11f83569b6f2b202d0f466a09aae6
СУД: repo=dev-harness; предмет=206; фаза=v1; роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit206V1; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=нет; исключение=нет; класс риска=рисковый

План модели — `config/agent_models.json`: critic → apex-sol → gpt-terra; модель указана средой сеанса. Запись 206 в HANDOFF проверяемого OBJECT и независимый трейс запуска с дописанной фактической моделью не обнаружены: оркестратор обязан сверить их до материализации суда; приведённая шапка не подменяет эту запись.

## Блоки

БЛОКИРУЕТ contracts/206-sreda-sudji.md:36 — К-09: эталон игнорирует операнды после `--`, начинающиеся с дефиса.
ОБЯЗАТЕЛЬСТВО: строки 36–37 требуют судить все цели литеральных cp/mkdir с `--`, не ослабляя отказ записи вне разрешённой области; строка 56 делает зелёную модель обязательной.
СОСТОЯНИЕ: `model/build.py:34-35` удаляет все начинающиеся с `-` токены, даже после `--`; существующая операция mkdir `.omp/extensions/path-guard.ts:565-567` делает то же. Воспроизводимый вход — штатные `cp -- /etc/hosts -outside` и `mkdir -- -outside` с абсолютным cwd в чужом каталоге, без пина. `--` делает `-outside` операндом, а не флагом.
НАБЛЮДЕНИЕ: реальный Node вызов materialized модели по обоим входам: rc 0, stdout `{"decision":"pass"}`, stderr пуст. При этом --model зелён. Это дефект обязательной модели без искусственного запрета значения; исправление должно различать флаги и операнды и отказывать за пределами области, включая честную разрешённую цель после `--`.

БЛОКИРУЕТ contracts/206-sreda-sudji.md:40 — К-08: относительный вердикт за пределами repo проходит честную модель.
ОБХОД: существующая ветвь `scripts/pre_judge.sh:376-378` берёт относительный `VFILE` без проверки границы; модель её не меняет. В реальном одноразовом git-репозитории на `wip/206/critic` вызов `bash <модель>/scripts/pre_judge.sh verdict --repo <repo> --file ../outside.md` вернул rc 0, stdout `VERDICT_BRANCH=wip/206/critic`, stderr пуст. `--file` — поддерживаемая операция, значение указывает за пределы repo; батарея проверяет только абсолютный внешний путь (`probe.py:162`). Названное общее обязательство отказа нарушено при зелёной модели. Нужно проверять границу и для относительной формы и различать честный относительный путь внутри repo; разрешённый риск не сужать.

БЛОКИРУЕТ contracts/206-sreda-sudji.md:41 — К-10: живая приёмка не привязана к назначенному OBJECT.
ОБХОД: настоящий `scripts/zamok_predmeta.sh:1052-1055` записывает отдельный `object` каждого START; штатно на одном предмете возможны суды разных OBJECT. `live.py:13-17,31-39` принимает только repo-id, subject и время и никогда не сравнивает object. Три последовательных START/RELEASE указанных ролей с различными 40-hex object `a…`, `b…`, `c…` дали `assess(...)` → `(0, 'SUDA=3 OBRYVOV=0 VERDIKTOV=3')`, хотя ни один общий назначенный OBJECT не предъявлен. Это не поддельный лог в модели угроз, а допустимая форма событий реального журнала. Приёмка должна связывать каждый START с назначенным OBJECT и различать правильную тройку и разные/чужие объекты.

БЛОКИРУЕТ contracts/206-sreda-sudji.md:60 — К-06: невалидный журнал не всегда даёт обещанный инфраструктурный rc 2.
ОБЯЗАТЕЛЬСТВО: для невалидного журнала `live.py` обязан выдать rc 2 `NOT_IMPLEMENTED`, а не rc 1 предметной красноты.
СОСТОЯНИЕ: файл содержит допустимый JSON `null` на отдельной строке, но не объект события; `live.py:13-14,42-44` обращается к `.get` и не перехватывает `AttributeError`.
НАБЛЮДЕНИЕ: живой CLI с таким файлом вернул rc 1, пустой stdout и Python traceback (`AttributeError: 'NoneType' object has no attribute 'get'`), не `NOT_IMPLEMENTED`. Требуется проверяемое разграничение невалидного журнала и неполной честной тройки.

## Собственные атаки

Все мутации сделаны только во временной копии materialized модели; ни production, ни контракт не менялись. Вызов `python3 .scratch-crit206v1/attacks.py`, rc 0; сырой вывод:

```
hint-refuse guard-pin-mismatch KRASEN total_red 1
boundary-no-inside verdict-outside KRASEN total_red 1
observer-no-sequence 0 (0, 'SUDA=3 OBRYVOV=0 VERDIKTOV=3')
relative-outside-reference (0, b'VERDICT_BRANCH=wip/206/critic\n', b'')
```

* `hint-refuse`: в обёртке judge перед добавлением HINT возвращён без подсказки только `refuse`; различающая существующая клетка `guard-pin-mismatch` красная.
* `boundary-no-inside`: в pre_judge удалена существующая операция `path_inside "$vcanon" "$R"` при сохранении проверки `vcanon != R`; `verdict-outside` красная.
* `observer-no-sequence`: в `live.py` из `if i <= previous or len(releases) != 1` удалён предикат порядка. Для существующего контрольного входа `overlapping-judges` изменённый `assess` дал зелёный rc 0 вместо ожидаемого rc 1. Следовательно этот контроль различает мутацию.

Каждую из трёх собственных мутаций автор обязан добавить адресным стабом по контракту, даже когда клетка уже ловит её. Отдельно должны появиться контролируемые входы для четырёх блоков выше; исправление оценивается шире приведённых значений.

## Исполненные команды

`check_sdacha.sh "$PWD" contracts/206-sreda-sudji.md --run`: rc 0, `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=0)`.

`red_sreda_sudji_206.sh --repo .`: rc 1, `KLETKI=42 ZELENYE=21 KRASNYE=21` (ожидаемый red-before). `--model`: rc 0, `KLETKI=42 ZELENYE=42 KRASNYE=0`. `--stabs`: rc 0, `OBMANOK=19 POIMANY=19 ZHIVYH=0`. `pre_critic.sh contracts/206-sreda-sudji.md`: rc 0, `КРИТИК: дверь зелёная`.

Отдельно: `check_precision_gate.sh . contracts/206-sreda-sudji.md`, `check_spec_ready.sh . contracts/206-sreda-sudji.md`, `check_ids.sh .`, `check_ceilings.sh .`, `check_provodka.sh --grammar . contracts/206-sreda-sudji.md`, `check_threat_model.sh . contracts/206-sreda-sudji.md`, `check_predposylki.sh . contracts/206-sreda-sudji.md`: все rc 0. `live_control.py`: rc 0, `OBSERVER_CONTROLS=12 KRASNYE=0; LIVE_JUDGES_NOT_RUN`. `validate_std.sh bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh` с официальным shellcheck 0.11.0: rc 0. Настоящие три суда и legacy-пробы с внешним scratch не запускались.

## Карта классов

К-01: чисто — `check_sdacha --run`, 12 дверей, rc 0; карта 17/17.
К-02: чисто — вход `/tmp/dev-harness-verify/task-arch206.md`, четыре свойства и рестарт сопоставлены контракту.
К-03: блок — относительный вердикт вне repo (К-08); frozen-пакет Б прочитан, право пина сохранено.
К-04: чисто — §Зоны и `check_precision_gate.sh` rc 0.
К-05: чисто — вход §Приёмочный критерий: команды с rc, live отдельно от модели.
К-06: блок — невалидный журнал даёт traceback и rc 1.
К-07: блок — честная модель нарушает обязательные входы cp/mkdir и pre_judge.
К-08: блок — относительный вердикт вне repo.
К-09: блок — операнды после `--` игнорируются.
К-10: блок — живой наблюдатель не проверяет OBJECT.
К-11: чисто — вход `probe.py:73-75,105` и `live.py:40`: снимки и ожидания до вызова проверяемого субъекта; подмена бинарника вне модели угроз.
К-12: чисто — вход Node/git и Python JSON в probe/live, без нового формата-оракула.
К-13: н/п — секреты не входят в предмет.
К-14: чисто — вход `probe.py:103-118`, положительные write/edit, cwd, quoting, cp.
К-15: чисто — `--model` rc 0, 42/0; `--stabs` rc 0, 19/0; `live_control.py` rc 0, 12/0.
К-16: чисто — вход §Модель угроз: класс рисковый, непесочница и иной слой bash явно названы.
К-17: н/п — dev-harness не является проектом Complior-back с pinned architecture-брифом.

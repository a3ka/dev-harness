FAIL
OBJECT=a9642253e31b82e416641e406cf524f5373cba63
СУД: repo=dev-harness; предмет=159; фаза=контракт v1 (+красная батарея); роль=critic; вызов=2/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit159b; модель-факт=openai-codex/gpt-6-sol; SHA=a9642253e31b82e416641e406cf524f5373cba63; предыдущий=Crit159 FAIL (1ed1cab690daefc11a133a004023900612612f0e); исключение=нет.

Судится закоммиченный OBJECT: его архив извлечён отдельно, локально импортированы git-метаданные и frozen-теги. Основной чекаут не менялся. Автор Arch159b — zai/glm-5.3, критик — openai-codex/gpt-6-sol (runtime): семейства различны. `сессия=Crit159b` — предоставленный agent-id; фактические session-id и модель по трейсу подлежат сверке оркестратором до материализации вердикта. Риск «обычный» соответствует предмету. Новая семантика v2 и последствия дельты проверены.

## Блокирующие находки

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:24,28 — симлинк на самом `mobile/src` обходит грамматику «симлинки — не содержимое; содержимое принадлежит R». Класс причины: `os.walk(followlinks=False)` не следует вложенным ссылкам-каталогам, но следует ссылке, переданной в качестве исходного корня обхода. Это незакрытая разновидность Б1 Crit159: содержимое экранного слоя целиком ВНЕ продукта принимается за реальное.
ОБХОД: действительные карта и форма внутри R, `mobile/src` — symlink на каталог вне R с `features/demo/Demo.tsx`; внутри R нет исходного файла экрана. `python3 /tmp/dev-harness-verify/Crit159b/check_boundaries.py` → `baseline (0, '', '')`, `external-src-symlink (0, '', '') src is symlink: True`. `W --model` → rc 0, 15/15: этого входа нет. Копирование эталона в гейт оставит пустой продукт зелёным.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: сам `mobile/src`, как и любой каталог/файл, учитываемый как экранное содержимое, не является симлинком и принадлежит R; внешний заполненный `src` красен именованной причиной, конформный реальный подкаталог с файлом зелён; это различение предъявлено моделью и гейтом.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:24 — ошибка доступа к карте/исходникам превращается в структурную пустоту. Класс причины: `chita_json` ловит `OSError` как битый/отсутствующий JSON; `os.walk` без `onerror` молча пропускает нечитаемый подкаталог. Б2 Crit159 закрыт для типов, но не для названной ветви ошибки доступа.
ОБЯЗАТЕЛЬСТВО: `ошибки доступа → rc 2, fail-closed` с причиной `PUSTOJ_PRODUKT: NECHITAEMO`; отсутствующий/битый JSON — отдельная структурная пустота rc 1.
СОСТОЯНИЕ: исходно конформный R с `chmod 000 mobile/ci-screens.json` либо с нечитаемым `mobile/src/features/demo` (запуск как uid 1004).
НАБЛЮДЕНИЕ: `python3 /tmp/dev-harness-verify/Crit159b/check_boundaries.py` → `unreadable-map (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ', '') expected rc=2 NECHITAEMO`; `unreadable-src-subdir (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO', '') expected rc=2 NECHITAEMO`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: настоящие ошибки чтения и обхода каталогов дают rc 2 `NECHITAEMO`, а отсутствующие файлы/битый JSON — причины структурной пустоты; модель и гейт проверены на обоих видах входа.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:25-26,38 — наблюдатель не доказывает «гейт первым действием» и «после отказа собственные клетки не запускаются». Класс причины: наблюдаются только первый вывод и снимок дерева R, а побочный эффект вне R ДО гейта и клетки ПОСЛЕ его отказа не проверяются. Никакой подделки трассы нет: настоящий стенд-гейт пишет ровно одну запись.
ОБХОД: `python3 /tmp/dev-harness-verify/Crit159b/check_first_action.py` → rc 0; на каждом из пяти базовых входов честный `honest` и два негативных образца возвращают `('OK', <та же причина>, 1)`. `early-action` записывает файл вне R ДО вызова гейта (`external side-effect True`); `own-cells-after-fail` выводит `CASE own-cells-executed-after-refusal` ПОСЛЕ получения отказа гейта (`cell output executed`). Снимок R, первая строка и трасса корректны, но нарушены инвариант 2 и указанная граница модели угроз о побочных эффектах. Точно эта `sudit_provodku` судит все 20 W-клеток.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: в `W --repo` нет действий до гейта и собственных клеток после его отказа; отрицательные образцы этих нарушений красны, честная последовательность зелена, без молчаливого сужения границы угроз.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:25,38,56-59 — приёмка не проверяет заявленный rc 1 и проброс кода гейта. Класс причины: `sudit_provodku` отвергает только rc 0 и 2, любой иной код при совпавших причине и трассе принимает как `OK`.
ОБХОД: `python3 /tmp/dev-harness-verify/Crit159b/check_first_action.py` → rc 0: `wrong-return` для каждого из пяти базовых входов даёт `('OK', <ожидаемая причина>, 1) subject rc=3`. Гейт действительно вызван и причина верна, но батарея выходит rc 3 вместо rc 1. После такой проводки W-клетки зеленеют вопреки сценарию 4 и требованию пробрасывать rc.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: W-случай отличает ожидаемый rc 1 от любого иного кода, а rc 2 гейта передаётся как rc 2; несоответствие rc красно даже при честной причине/трассе.

Предыдущие блоки: `null`-запись, пустые подкаталоги и `ekran:""` красны отдельно; не-словарь карты отвергается именованно без traceback; s1/s4/s5 красны своими ветвями при действительной трассе, честный стенд зелён; раздел 004 у 159 исправлен (`check_ceilings` о нём не сообщает). Но четыре вышеописанных нарушения остаются. Письменного спора автора нет: один лишь второй FAIL не созывает арбитра (§Быстрый-процесс §Остановка).

## Команды, rc и сырой вывод

- `git -C /home/harness/dev-harness cat-file -t a9642253e31b82e416641e406cf524f5373cba63` → rc 0: `commit`. `git diff 1ed1cab69 a9642253e... --stat` → rc 0: 9 файлов, 665 вставок, 281 удаление. После локального `git init; git fetch; git reset --mixed` на архиве: `git rev-parse HEAD` → rc 0, `a9642253e31b82e416641e406cf524f5373cba63`; `git status --short` → rc 0, пусто.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh` → rc 1; сырые строки: `CASE s-gate-v-dereve KRASNO SUBJECT_ABSENT scripts/check_pustoj_produkt.sh`; `CASE W-gespraech_otdacha_151/a-forma-pusta KRASNO SUBEKT_RC2 rc=2 (fail-closed — не зелень)`; `CASE W-gespraech_tekst_149/a-forma-pusta KRASNO GATE_NE_VYZVAN записей трассы 0 (ожидалась одна с этим R)`; `клеток 23, зелёных 0, красных 23; режим derevo`. Все W-клетки красны: 15 GATE_NE_VYZVAN, 5 SUBEKT_RC2. У 151 rc 2 пока её собственный INFRASTRUCTURE, гейт не вызван — baseline это честно говорит.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --model` → rc 0; `CASE m-c1-pustye-katalogi ok`, `CASE m-c2-vneshnij-simlink ok`, `CASE m-k2-karta-massiv ok`, `CASE m-konformnyj ok`, `клеток 15, зелёных 15, красных 0; режим model`.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --stabs` → rc 0; `STAB s1_ignoriruet_rezultat.py POJMAN vetka=BATAREJA_ZELENA_NA_PUSTOM na a-forma-pusta`; `STAB s4_bez_vyzova_gejta.py POJMAN vetka=GATE_NE_VYZVAN na a-forma-pusta`; `STAB s5_stderr_do_gejta.py POJMAN vetka=VYVOD_DO_GATE na a-forma-pusta`; `SVJAZI 5`; `клеток 15, зелёных 15, красных 0; режим stabs`.
- `python3 /tmp/dev-harness-verify/Crit159b/check_boundaries.py` → rc 0, дословно:
```
baseline (0, '', '')
external-src-symlink (0, '', '') src is symlink: True
unreadable-map (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ', '') expected rc=2 NECHITAEMO
unreadable-src-subdir (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO', '') expected rc=2 NECHITAEMO
```
- `python3 /tmp/dev-harness-verify/Crit159b/check_first_action.py` → rc 0, дословный фрагмент для b1 (такие же ветви на a/b2/v/g):
```
honest b1-pustoj-katalog ('OK', 'PUSTOJ_PRODUKT: KATALOG_PUST', 1)
early-action b1-pustoj-katalog ('OK', 'PUSTOJ_PRODUKT: KATALOG_PUST', 1) external side-effect True
own-cells-after-fail b1-pustoj-katalog ('OK', 'PUSTOJ_PRODUKT: KATALOG_PUST', 1) cell output executed
wrong-return b1-pustoj-katalog ('OK', 'PUSTOJ_PRODUKT: KATALOG_PUST', 1) subject rc=3
```
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, финал `CASE w22-limit-back-chetyre ok`. Первый запуск на архиве без `.git` был rc 1, `g05-samo-prolozhenie KRASNO` из-за `NOT_IMPLEMENTED: worktree пина не репо`; после импорта метаданных весь повторный прогон зелён.
- `bash scripts/check_precision_gate.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0 `OK`; `bash scripts/check_spec_ready.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0 `OK`; `bash scripts/check_threat_model.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 7 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))`; `bash scripts/pre_critic.sh contracts/159-pustoj-produkt-krasnyj.md` → rc 0 `КРИТИК: дверь зелёная` (архив с локальными git-метаданными).
- `bash scripts/check_ceilings.sh .` после импорта frozen-тегов → rc 1: `FAIL контракт ./contracts/158-ekrannyj-nabor.md (82 байт): нет раздела «Незаполненные требования:»`, `превышений/нарушений: 1`; о 159 отказа нет. `bash scripts/check_provodka.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 1: `проводка: guard не подключён: fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/` — ожидаемо до реализации.
- `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit159b/zones-cache-159` на архиве ДО импорта тегов → rc 0 `замороженных контрактов: 0 · зон не объявлено — проверять нечего` — это НЕ проверка зон. После импорта frozen-тегов `bash scripts/check_zones.sh` не завершился за 360 с: `[Command timed out after 360 seconds]`; rc/финального результата нет. Независимо от этого чтением `git show frozen/contracts/{147,148,149,151}/1:contracts/<имя>.md` установлено: их `ЗОНА architect` включает соответствующие четыре каталога `fixtures/workshop_project/<семья>/`; новый `ЗОНА implementer` 159 адресует точные четыре `probe.py`, а строки 56–59 объявляют пересечения. Полный исторический барьер зон зелёным не объявляю.

## Не проверено

- Полный `check_zones.sh`: timeout после 360 с на копии OBJECT; парность зон сверена чтением frozen-текстов, но исторический проход барьера не подтверждён.
- Зелёный полный W после реальной реализации и `W147/148/149/151 --repo` на живой копии продукта: гейта и проводки на OBJECT нет; честный контроль `sudit_provodku` выполнен лишь на стенде `gate_tracer.sh`, не в product CI.
- Независимый trace session-id/fallback: указан предоставленный agent-id и объявленная runtime-модель; оркестратор сверяет их со своим трейсом до принятия вердикта.

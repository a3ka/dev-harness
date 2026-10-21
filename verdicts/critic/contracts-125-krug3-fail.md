FAIL
Контракт 125 «sessii-proektov», круг 3/3, последний. OBJECT=783edef25fe46c779a3c3e737f9222281541a631. Дельта от 96e695bfe; предмет суда — только закрытие двух классов Т-1/Т-2.

Набор артефактов полный: закоммиченный контракт, предмет, rc-критерий, исполнители, зоны и модель угроз. Прочитаны оба прежних вердикта. Вариант Б, 055/058, .harness-only, прежние закрытые вопросы CI моба и зоны интеграции не пересматривались. Работа — отдельный клон с собственной .git, исходный worktree и реальные проекты/профиль станции не менялись, push не выполнялся.

## Единственная блокирующая находка

БЛОКИРУЕТ contracts/125-sessii-proektov.md:62 — состояние «секрет под другим именем» в Т-1 не различает индекс и рабочую копию. Объявленная замкнутость (:65) и инвариант отсутствия секрета в индексе на повторном входе (:53) не доказаны зелёной приёмкой (:94–96).
ОБХОД: взять честные модели БЕЗ ИЗМЕНЕНИЙ (полная батарея --model rc0, 70/70). После подключения скопировать `.harness/.env` в `.harness/archived-settings`, выполнить `git add .harness/archived-settings`, затем заменить ТОЛЬКО рабочую копию `archived-settings` несекретным текстом, не обновляя индекс, и повторить дверь. Повтор возвращает rc0 и `SESSION_EXEC --yolo <корень>`, а `git grep --cached -l -F <синтетический-секрет>` до и после возвращает rc0 и `.harness/archived-settings`. Обычный следующий `git commit` rc0 уносит секрет в HEAD (`git grep -l -F … HEAD` rc0). Искомое состояние не требует изменения модели, распознавания фикстур или иной области задачи.

Почему это внутри Т-1: секрет находится под другим именем В .harness/ и в индексе ДО нового входа двери. Это не исключённое :139 действие пользователя ПОСЛЕ последнего входа. Содержимое worktree/index/HEAD различается при обычной работе git; переименование и частичное обновление индекса — именно жизненный цикл той же двери. Запрет или исключение такого конформного входа контрактом не объявлены.

Наблюдаемая причина неполноты критерия: `_gruppa_c.sh:239–240` создаёт лишь неиндексированную копию и сразу запускает дверь. Модель `model/connect_project.sh:80` получает из `git ls-files --cached` имена, но `grep` читает рабочие файлы, НЕ cached blob. Поэтому дерево, реализованное ровно по честной модели, проходит критерий и пропускает названное нарушение предмета. Это суд достаточности критерия, не ревью будущей реализации.

## Независимое доказательство

- `PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Critic125c/independent.py`: rc0. Мир построен независимо от батареи; настоящий git init/clone/add, отдельный HOME с синтетическим токеном, честная дверь, наблюдатель workshop. Первые два входа rc0/0; чистый индекс `git grep --cached` rc1; затем стадирование копии rc0, повтор двери rc0 и вызов сессии; секрет в индексе до/после rc0/0. Сырые факты: `independent.log`, `independent-results.json`, `independent/`.
- SHA256 независимо запускаемой двери и `model/connect_project.sh` совпадает: `3b731d80839161790e597a74c43719a7707c7dde39748fb4b1192e246f71dd50`.
- Дополнительная материализация отсутствующего состояния в ОТДЕЛЬНОЙ копии клетки c22: `PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Critic125c/missing_cell.py` rc0; ровно `КРАСНО c22-zhizn-imya: … значение секрета в индексе git`. Группа C по своему интерфейсу возвращает rc0, печатая решения клеток; 21 зелёная/1 красная. Исходная батарея не редактировалась. Лог `missing-index-worktree-cell.log`.
- Обычный commit и поиск секрета в HEAD rc0; свидетель `ordinary-commit.log`, scratch-коммит `295393f` в `independent/fresh-project`. Никаких настоящих ключей станции не использовалось.

## Закрытие прежних обходов и Т-2

Прежние инъекции воспроизведены против ТЕКУЩИХ моделей, а не старых файлов: безусловное индексирование .env, индексирование только при повторе, ссылка на каталог агента, переименованная копия истории, пустой config/, все ложные диагнозы. Результаты ниже. Это подтверждает закрытие прежних точек, но не замкнутость Т-1.

Т-2 независимо: честный дом rc0; ссылка на файл dev, подкаталог, сам каталог агента, дом dev, относительная ссылка, цепочка, внешний каталог со ссылкой внутри, hardlink на непустой файл, hardlink на пустой файл — все rc1 с `РАСХОЖДЕНИЕ ne-sessii`; hardlink config.yml — rc1 с `РАСХОЖДЕНИЕ config-yml`. Прежний обход через ссылку-родителя закрыт. Нового обхода Т-2 не предъявлено. Это не заявление о проверке bind/FUSE, содержимого файлов, живого omp или иных исключённых состояний.

## Исполненные команды и rc

`run_checks.py` последовательно запускал `bash fixtures/workshop_project/sessii_125/red_sessii_125.sh` на исходном дереве, `--model`, `bash scripts/check_precision_gate.sh <клон> contracts/125-sessii-proektov.md`, `--stabs`, затем полный runner для каждого прежнего обхода. Свидетели в /tmp/dev-harness-verify/Critic125c/:

- `tree`: rc 1. s125 red: зелёных 6, красных 30 Красные: a01-chestnaya, a02-dom-obshij, a17-nechem-pustye-fakty, b02-sev-pobajtno, b08-sverka-chestnaya, b03-drejf, b04-zapis-ne-v-dev, b11-harness-raskladka, c01-zapusk-odin, c02-yolo, c03-projectid, c04-klon-https-gh, c05-pin, c06-deny, c07-karkas, c08-tolko-harness, c09-env-klyuchi, c10-sekrety-vyvod, c11-sekrety-repo, c12-povtor, c13-sverhu, c14-imya-vne-klassa, c15-mob-bez-pravok, c16-mob-ci, c17-env-v-indekse, c18-zhizn-povtor, c19-zhizn-add-f, c20-zhizn-add-a, c21-zhizn-vetka, c22-zhizn-imya.
- `model`: rc 0. s125 model: зелёных 70, красных 0
- `precision`: rc 0. Сырой вывод: precision.log
- `stabs`: rc 0. s125 model (опора стабов): зелёных 70, красных 0; s125 stabs: стабов 37, привязок 128, непойманных привязок 0
- `previous-staged-secret`: rc 1. s125 red: зелёных 64, красных 6 Красные: c11-sekrety-repo, c12-povtor, c18-zhizn-povtor, c20-zhizn-add-a, c21-zhizn-vetka, c22-zhizn-imya.
- `previous-repeat-staged-secret`: rc 1. s125 red: зелёных 67, красных 3 Красные: c18-zhizn-povtor, c20-zhizn-add-a, c21-zhizn-vetka.
- `previous-live-parent-link`: rc 1. s125 red: зелёных 69, красных 1 Красные: b08-sverka-chestnaya.
- `previous-renamed-live-state`: rc 1. s125 red: зелёных 68, красных 2 Красные: b05-ne-sessii, b08-sverka-chestnaya.
- `previous-root-empty-directory`: rc 1. s125 red: зелёных 69, красных 1 Красные: c08-tolko-harness.
- `previous-false-diagnostics`: rc 1. s125 red: зелёных 36, красных 34 Красные: a02-dom-obshij, a03-drejf-config-yml, a03-drejf-models-db, a03-drejf-skill-descriptions-db, a04-ssylka-config-yml, a04-ssylka-models-db, a04-zhestkaya-config-yml, a05-net-config-yml, a06-agentdb-kopiya, a07-sessii-kopiya, a07-history-ssylka, a07-blobs-kopiya, a07-history-pereimenovana, a07-sessiya-pereimenovana, a07-vne-profilya, a07-ssylka-pereimenovana, a19-dost-fajl-dev, a20-dost-podkatalog, a21-dost-katalog-agenta, a21-dost-roditel, a22-dost-cepochka, a23-dost-otnositelnaya, a26-dost-cherez-katalog, a24-dost-hardlink, a25-dost-hardlink-pustoj, a08-profil, a09-podtverzhdeniya, a10-model, a11-instrumenty, a12-politika, a13-rasshireniya, a14-pravila, a15-agenty, a16-tri-prichiny.

Отдельная мера инвентаря `jq` по source.json: 37 ключей стабов, 128 привязок. `pre_critic` не перемерялся: rc0 сообщён оркестратором, это НЕ собственный прогон критика. Полный CI и 11 соседних батарей не запускались. Н-39: пары стаб↔вход не переносились в прозу контракта.

## Порог и кап

Пять вопросов применены к дельте: слабость критерия предъявлена обходом выше; команды и rc существуют; неразличение индекса/worktree нельзя молча решить в пользу более слабого представления; зоны architect/implementer в дельте не менялись; новых самостоятельных противоречий AGENTS.md не заявляется. Подробная запись — judgment.md. После блокера новые классы не исследовались.

АРБИТР: arbiter — повтор причины «секрет в индексе при зелёной приёмке». Предмет: недостаточность заявленной замкнутости Т-1 при независимых снимках worktree/index/HEAD. Круг 3 — СТОП; по заданию форк «пересмотр объёма» 125 → 125-б/125-в к консультанту, без четвёртого микро-круга. Фактический запуск арбитра не заявляется. Попытка сообщения Main отклонена Н-85 (agent://Main недоступен непиннованной сессии).

## Доставка

Требуемый файл: /tmp/dev-harness-verify/Critic125c/verdict.md. Канонический вердикт подготовлен в собственном клоне с авторством critic для переноса основной сессией на ветку предмета. Исходный worktree доступен только для чтения; доступ к Main запрещён инструментом Н-85. До переноса локальный commit/bundle не является вердиктом на HEAD основной ветки. Клон и доказательства сохранены; ограничение доставки НЕ причина FAIL.

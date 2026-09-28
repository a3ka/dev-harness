FAIL

# Адверсарий 054 — консолидация кругов 1–3

Судился HEAD `5fdf50dbf0e8826800e6f1305a96a9b2ced6e6a8` в одноразовом SSH-клоне.
Контракт и проверка не менялись. Круги 1–2 закрыты живым исполнением, но
круг 3 нашёл новый исполнимый обход границы репо-слоя. Поэтому 054 принимать
нельзя.

## Позитивный контроль, батареи и frozen

В клоне выполнено:

```text
$ bash fixtures/_krasnye_054.sh
стаб-пак: просмотрено 17, поймано 17
054-батарея зелёная: все клетки к1-к14 + b1-b6 пройдены
054-батарея зелёная
итог 054: rc=0

$ bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver
БАТАРЕЯ profile_resolver: итог 4/4 классов закрыто

$ git rev-parse --verify frozen/contracts/054/1
53dbc719e8305d48cc48ca01b15dec2327da52da

$ git diff --exit-code frozen/contracts/054/1 -- contracts/054-profil-dva-sloja-launcher-proekta.md
rc=0
```

Это положительный контроль, а не вечная краснота: все 17 обманных стабов
пойманы своими клетками; честные клетки и четыре класса гигиены зелёные;
frozen-предмет не менялся.

## Круг 1 — шесть прежних обходов закрыты

Независимые контрмодели кругов 1–2 и соответствующие b1–b8 клетки теперь
дают именованные отказы. Закрыты: неизвестный nested-key в
`defaults.workflowPaths`, пустой `commands.test`, выход `profilePath` за
корень слоя, секция AGENTS с одним заголовком, global-only 4.3,
числовой bootstrap-pin, нестроковые поля и `GIT_DIR`-подмена local-config.
Батарея выше демонстрирует различимость, а не только успех честного пути.

## Круг 2 — оба воспроизведения повторены с именованными отказами

Отдельный живой repro проверил строгие типы строкового алфавита. Каждая
контрмодель вернула ровно `rc=1` и P6 с именем поля:

```text
TYPE repoId rc=1 P6=repoId
TYPE version rc=1 P6=version
TYPE profilePath rc=1 P6=projectLayer.profilePath
TYPE projectId rc=1 P6=projectId
TYPE workspaceId rc=1 P6=workspaceId
TYPE ciWorkflow rc=1 P6=ci.workflow
TYPE canonicalRemote rc=1 P6=canonicalRemote
TYPE schemaVersion rc=1 P6=schemaVersion
GIT_DIR rc=1 W2
```

Для `profilePath: 7` в корне слоя был намеренно создан файл `7`, чтобы
проверить именно type-gate, а не ранний P3 отсутствующего файла. Для W2
проект не имел local `receive.denyCurrentBranch`; отдельный bare git-dir
содержал `refuse` и был передан через `GIT_DIR`. `workshop --probe` отказал
W2, то есть читает `$PROJECT/.git/config`, а не атакующий bare-dir.

## Круг 3 — новый обход: repo-layer разрешается через внешний symlink

Построен честный toy-проект с local 4.3=`refuse`, `.env`, pin и честным
слоем проекта. Единственное изменение: вместо собственного
`<repo>/harness.project.json` создан symlink на валидный профиль вне корня
репозитория:

```text
<repo>/harness.project.json -> <outside>/harness.project.json
```

Запуск субъекта:

```sh
HARNESS_PROJECT_LAYER_ROOT=<layer> \
  bash scripts/profile_resolver.sh --repo <repo>
```

вернул `rc=0` и merged-профиль с `repoId=r1`, `language=typescript` и
остальными значениями из внешнего файла. Никакого P2/P6/P7 нет.

Это не symlink внутри разрешённого project-layer: верифицируемый **repo
layer**, который по В2/И-1 живёт как `harness.project.json в корне репо`,
фактически читается за пределами этого репо. Внешний владелец может незаметно
подменить `repoId`, команды, CI, `git.canonicalRemote`, barriers и pin, при
этом сам клон не содержит этих байтов. У project-layer уже есть физическая
проверка границы (`readlink -f`); для repo-layer аналогичной проверки нет:
`[ -f "$REPO_JSON" ]` следует symlink, а затем `jq` читает его цель.
Следовательно, проверка допускает неправильную реализацию «repo layer не
принадлежит repo» и не содержит различающей красной клетки.

Требуемая авторская правка: канонизировать `harness.project.json` до чтения
и отказать, если resolved путь не лежит физически под каноническим корнем
`--repo`; добавить независимую клетку, где ссылка указывает наружу и требуется
конкретный именованный отказ. Простая проверка существования ссылки не
закрывает этот обход.

## Проверенные новые векторы без обхода 054

* `GIT_INDEX_FILE`, `GIT_WORK_TREE`, `GIT_ALTERNATE_OBJECT_DIRECTORIES` и
  `GIT_CONFIG_COUNT/GIT_CONFIG_KEY_0/GIT_CONFIG_VALUE_0=refuse` не дали
  ложной зелени при отсутствующей local 4.3: каждый дал `rc=1`, W2.
* `GIT_OBJECT_DIRECTORY=<несуществующий>` также не прошёл: `rc=1`, ранний
  именованный отказ «проект не git-репозиторий». Это denial-path до блока
  санации, а не обход W2; он не может выдать probe success.
* packs-значения `$(touch …)` и строка с jq-метасимволами дали `rc=1`, P6
  `packs: $(touch …)`; marker-файл не создан. Это код и предмет владельца
  055, не новый обход 054.
* Гонка live PID-lock воспроизведена отдельно против кода 055: в десяти
  раундах по восемь одновременных стартов fake-`omp` фактически стартовал
  дважды в раунде 3 и трижды в раунде 4 (`started=2,w3=6`;
  `started=3,w3=5`). Это реальный TOCTOU `-f`/`kill -0`/`printf > lock`, но
  контракт 055 прямо относит такую гонку к незакрытой границе. Владельцем
  является 055, не 054; в вердикт 054 она внесена только как результат
  требуемого вектора.

## Вердикт

**FAIL.** Фикс-раунд закрывает оба обхода круга 2 и проходит 17/17 с
позитивным контролем, но внешний symlink `harness.project.json` оставляет
исполняемую подмену repo-layer. До канонической проверки границы и отдельной
различающей клетки гейт 054 принимать нельзя. Этот вердикт не меняет
frozen-контракт.

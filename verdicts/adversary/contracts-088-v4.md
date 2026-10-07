FAIL

# Контракт 088, круг 7 — вердикт adversary

## Новый пробой Б-2: лексический префикс `GIT_INDEX_FILE` принимает индекс вне git-dir

`check_staged.sh` возвращает хуковый `GIT_INDEX_FILE`, когда строка начинается с
`$(git rev-parse --absolute-git-dir)/` и файл существует. Это не проверяет фактическую
принадлежность пути git-dir: компонент `..` проходит `case`, но резолвится за пределы
git-dir. Поэтому внешний индекс судится вместо индекса коммита.

Живая минимальная проба в изолированном toy-repo (с копиями production `scripts/` и
`.githooks/`) построила валидный HEAD с указателем, сохранила его индекс в
`<repo>/evil-index`, затем staged корневой `HANDOFF.md` без указателя в нормальном
индексе и вызвала production-судью так:

```text
GIT_INDEX_FILE=<repo>/.git/../evil-index \
GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@local \
bash <repo>/scripts/check_staged.sh <repo>
```

Наблюдение:

```text
rc=0 default=HANDOFF.md, traversal= stderr=
```

То есть дефолтный индекс действительно содержит запрещённый staged `HANDOFF.md`, но
путь с `..` принят, внешний старый индекс пуст, и судья проходит как «нечего судить».
Это нарушает Б-2: возвращать `GIT_INDEX_FILE` разрешено только для абсолютного пути
**под** `git rev-parse --absolute-git-dir`; внешний индекс обязан игнорироваться, после
чего та же запрещённая запись должна дать И-7/rc 1. B30 проверяет только очевидный
внешний путь и этого обхода не ловит. Нужна каноническая проверка принадлежности (без
лексического обхода `..`, также с учётом symlink) до `export GIT_INDEX_FILE` и клетка
для такого пути.

## Позитивные контроли и буквально запрошенные фиксы

* `bash fixtures/_krasnye_088.sh` — rc 0: D0–D11 и L1 зелёные, B0–B30 зелёные,
  стаб-пак `35/35 поймано, диффпроба 35/35`.
* Б-1: `red_ukazatel_088.sh . B19 B20 B21 B22` — rc 0. Удаление 074 из индекса,
  два присваивания, staged-подмена и дрейф k7 не выключают литеральный суд; B22
  подтверждает, что рассинхрон k7 краснит дочерний B0. Production не читает 074:
  поиск в `scripts/check_staged.sh` показывает только комментарий и литерал,
  исполняемого чтения fixture нет.
* Б-2 честные формы: `red_ukazatel_088.sh . B23 B24 B25 B26 B27 B28 B29 B30` — rc 0:
  `git commit -a`, `git commit -- HANDOFF.md`, `git commit -i HANDOFF.md`, linked
  worktree и очевидный внешний индекс судятся правильно. Это позитивный контроль
  реальной ветви; пробой выше — иной, не покрытый путь.
* Б-3: `red_dver_088.sh . D6 D7 D8 D9 D10 D11` — rc 0: passwd-дом с пробелами,
  метасимволами и внутренним `/.local/state/`, а также швы с пробелом, TAB и
  экранированным `[x]`, находят живого субагента и отказывают ожидаемо.
* Формы контракта зелёные: `pre_critic`, `check_threat_model`, `check_ceilings` — rc 0.

## Границы

Список изменений `a450fe6^..a491522` ограничен разрешёнными субъектами implementer
(`scripts/check_staged.sh`, `scripts/orch_restart.sh`) и architect
(`fixtures/strazh_088/`, `NABLIUDENIA_ARCHITECT.md`).
`git diff --exit-code a450fe6 a491522 -- scripts/lib_session.sh
ops/server/root/orch-peak contracts/088-v-polete-nichego-dver-i-ukazatel-handoff.md`
дал rc 0: И-4 и замороженный контракт не затронуты.

Вердикт FAIL только из-за нового обхода Б-2 с `..`: полный штатный набор и его честные
позитивные контроли не опровергают наблюдаемый fail-open на внешнем индексе.

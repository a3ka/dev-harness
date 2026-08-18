FAIL

## Предмет и положительный контроль

Проверен замороженный `contracts/003-skills-metta-adaptacija.md` v2, `scripts/check_skills.sh`, `scripts/overlay.sh` и четыре каталога `skills/` в коммите предмета.

Честный текущий набор даёт зелёное:

```text
$ bash scripts/check_skills.sh
  ok   ветвь (в): hash контракта начинается с 9c9f36c
  ok   скил «grilling» обнаружен omp
  ok   имя каталога «grilling» = имя фронтматтера
  ok   скил «writing-for-agents» обнаружен omp
  ok   имя каталога «writing-for-agents» = имя фронтматтера
  ok   скил «tdd» обнаружен omp
  ok   имя каталога «tdd» = имя фронтматтера
  ok   скил «diagnosing-bugs» обнаружен omp
  ok   имя каталога «diagnosing-bugs» = имя фронтматтера
  ok   состав skills/ точно совпадает с объявленным множеством
  ok   псевдоним grill-me документирован в шапке grilling
  ok   тело grilling совпадает со снимком upstream
  ok   тело writing-for-agents совпадает со снимком upstream
  ok   тело tdd совпадает со снимком upstream
  ok   тело diagnosing-bugs совпадает со снимком upstream
  ok   профиль совпадает с репозиторием
  ok   полнота фикстур: все 8 фикстур на родителе первого коммита по skills/
барьер зелёный: 8 ветвей пройдены
```

Это не доказывает предмет: ниже три заглушки, которые тот же барьер принял.

## 1. Ветвь (а) не запускает omp

**Обход.** В изолированной копии `probe-omp-127` подменён только `omp` в `PATH`. Для `omp --version` он возвращает `omp/17.2.10`, для `omp models list` — таблицу с `images=yes`, для ЛЮБОГО иного вызова (включая вызов скила) печатает `skill invocation intentionally unavailable` и выходит `127`. Пин в той же изолированной копии заменён на sha256 этого подставного исполняемого, чтобы overlay мог пройти свои независимые проверки.

Такой `omp` не способен обнаружить ни один скил, однако `bash scripts/check_skills.sh` завершился 0:

```text
$ PATH=.../probe-omp-bin:/usr/bin:/bin bash scripts/check_skills.sh
  ok   скил «grilling» обнаружен omp
  ok   скил «writing-for-agents» обнаружен omp
  ok   скил «tdd» обнаружен omp
  ok   скил «diagnosing-bugs» обнаружен omp
  ok   состав skills/ точно совпадает с объявленным множеством
  ok   псевдоним grill-me документирован в шапке grilling
  ok   тело grilling совпадает со снимком upstream
  ok   тело writing-for-agents совпадает со снимком upstream
  ok   тело tdd совпадает со снимком upstream
  ok   тело diagnosing-bugs совпадает со снимком upstream
  ok   профиль совпадает с репозиторием
  ok   полнота фикстур: все 8 фикстур на родителе первого коммита по skills/
барьер зелёный: 8 ветвей пройдены
```

Причина: `scripts/check_skills.sh` не вызывает `omp` для ветви (а); он объявляет обнаружение по наличию каталога и имени фронтматтера. Это противоречит контракту: ветвь (а) обязана захватить запуск с подставным `omp` и получить ответ, содержащий слово из тела. Фикстура `fixtures/check_skills/case_a_ne_obnaruzhen.sh` описывает этот захват, но сам барьер его не выполняет.

Отдельный запуск `omp --no-session --no-tools --max-time 10s -p 'grill-me'` с профилем после настоящего overlay не дал подтверждения псевдонима: сырой результат `Working...` затем `Deadline exceeded`, код 1. Это не самостоятельный дефект, но текущая проверка (ж) всё равно сводится к `grep 'grill-me'` и не может доказать маршрутизацию.

## 2. Overlay и ветвь (д) теряют все дополнительные файлы скила

GitHub tree API на зафиксированном источнике возвращает:

```text
$ curl -sSf https://api.github.com/repos/mattpocock/skills/git/trees/9c9f36ccd3995266cd675468af71639c8dde1ec5?recursive=1 | jq -r '.tree[].path | select(startswith("skills/engineering/tdd/"))'
skills/engineering/tdd/SKILL.md
skills/engineering/tdd/agents
skills/engineering/tdd/agents/openai.yaml
skills/engineering/tdd/mocking.md
skills/engineering/tdd/tests.md
```

В самом предмете `skills/tdd/` есть только `SKILL.md`. В изолированную копию добавлены `skills/tdd/tests.md` и `skills/tdd/mocking.md`; содержимое — маркер `Probe payload that overlay must preserve.`. Барьер всё равно зелёный (сырой итог идентичен положительному контролю, включая `ok   профиль совпадает с репозиторием`).

Затем выполнен настоящий overlay этой копии в пустой `HOME`:

```text
$ HOME=.../probe-extra-home npm run overlay
  ok   пин совпал: omp/17.2.10
  ok   скилы разложены в профиль: diagnosing-bugs grilling tdd writing-for-agents

слой наложен поверх omp/17.2.10

$ glob .../probe-extra-home/.omp/agent/skills/tdd/*
SKILL.md
```

Ни `tests.md`, ни `mocking.md` в профиль не доехали. Причина: блок скилов в `scripts/overlay.sh` создаёт каталоги и выполняет только `cp "$d/SKILL.md" "$SKILL_TARGET/$name/SKILL.md"`; ветвь (д) аналогично проверяет только четыре `SKILL.md`. Это пробивает требование задачи и критерия 4 «копирует `skills/`»: проверяется один файл, а не дерево. Нужна доставка и проверка каждого файла из каждого каталога, включая вложенный `agents/openai.yaml`.

## 3. Ветвь (з) не ловит частично авторские фикстуры

**Обход.** В изолированной копии к уже существующей фикстуре `fixtures/check_skills/case_b_imja_kataloga.sh` добавлен один комментарий и создан коммит:

```text
$ git -c user.name=implementer -c user.email=implementer@dev-harness.local commit -m 'probe fixture change'
[detached HEAD 80bc467] probe fixture change
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Тем самым одна из красных фикстур находится в коммите `implementer`, хотя контракт требует, чтобы фикстуры всех восьми ветвей лежали в коммитах `architect`. После этого `bash scripts/check_skills.sh` вновь завершился 0 и напечатал:

```text
  ok   полнота фикстур: все 8 фикстур на родителе первого коммита по skills/
барьер зелёный: 8 ветвей пройдены
```

Причина: ветвь (з) читает только дерево родителя первого коммита по `skills/`/`check_skills.sh`; авторов последующих изменений фикстур она не читает. Требуемый класс «часть фикстур архитектора, часть исполнителя» проходит.

## Сверка upstream по разным заголовкам

Для `raw.githubusercontent.com/.../tdd/SKILL.md` с `Accept: text/plain` и с `Accept: application/vnd.github.raw+json` получены HTTP/2 200 и одинаковый ETag:

```text
etag: "ac9b7bd13b79e4b7ee236386bb28d8a4330a826f05b4e1c065512ff6a5092153"
content-length: 3578
```

На зафиксированном hash редиректа не было. Этот путь не дал дополнительного обхода.

## Решение

Не принимать. Исправление должно добавить исполнимую проверку реального обнаружения скилов через подставной `omp`, копировать и сравнивать дерево каждого скила целиком, а также отклонять фикстурные коммиты не от `architect` после исходной точки. Затем построить красные заглушки этих трёх классов и предъявить их отказ вместе с положительным контролем.

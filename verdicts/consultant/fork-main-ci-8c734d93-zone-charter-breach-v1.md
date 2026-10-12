ПРЕДМЕТ: main-ci-8c734d93-zone-charter-breach
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: Коммит `8c734d93` (identity orchestrator, уже на `origin/main`) нарушает check_zones.sh (чужая зона architect: `fixtures/dokazatelstva_098/*`, `registry/contracts.tsv` не только-добавление) и check_charter.sh (`contracts/098-proizvodstvennye-dokazatelstva-do-publikacii.md` изменён без строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ). Есть ли grandfather-прецедент для check_zones.sh, и каков точный owner-ready текст для обеих дверей?
РЕКОМЕНДАЦИЯ: Парный точечный grandfather существующих check_charter.sh/check_zones.sh, при прямой санкции владельца, БЕЗ переписывания истории main. Классификация: воля-владельца / риск. Это анализ перед владельцем, не klass-подпись.

## Ключевое исправление предпосылки форка
check_zones.sh УЖЕ НЕСЁТ grandfather-механизм (форк ошибочно предполагал его отсутствие). На `origin/main=54679aaf`: (1) registry-блок строк 1029–1051 с четырьмя историческими парами; (2) flat-land grandfather `81e6e252` в строках 1256–1274; также `0678a949`, `b6daee0a`, `398d4f61`, `056be22d`. Прямые прецеденты (git show): `763d8dd7df9f5081201e1e5fd091645d1d3def8a` (owner, допуск батареи architect 094, перенесённой orchestrator) и `2718889754b20440c6178ec1924d3aa550547861` (owner, registry/095 при frozen-commit вне предков C). Автор барьера — architect, commit `1ee74c0e8ab8fdd2e3ccc435e2d751f4a2023a58`; автор исполнительского grandfather-прецедента — implementer, `3cd95d851dde4f4180d23702dc8ee9d39e8d7d7e`. Новый механизм здесь НЕ требуется.

## Живые факты
- `git show 8c734d93 --stat` / `git log --format='%an' -1 8c734d93` → rc 0: `8c734d93b91fb3ff38528d6591d519a5145de325`, автор orchestrator, 23 файла / 1877 добавлений / 11 удалений, без владельческого разрешения в теле.
- Прямых потомков ЧЕТЫРЕ: `3cfc067a`, `fac41836`, `e250769a`, `54679aaf` (`f4dc877e` — родитель 8c734d93, не потомок).
- `frozen/contracts/098/1` tag-object=`fa42b75b5e4dc51008b25167752310938a1e236f`, commit=`ff51125845cc782964d18e7a40891c181f1f3f7d`. Контракт и вся батарея 098 в `8c734d93` побайтово равны этой заморозке: `git diff --quiet ff511258 8c734d93 -- contracts/098-*.md fixtures/_krasnye_098.sh fixtures/dokazatelstva_098/` → rc 0 (блоб контракта `c0ebc55934bf7128664525c33b001181b0f0aa55` с обеих сторон).
- `git merge-base --is-ancestor ff511258 8c734d93` → rc 1: тег жив, но его commit НЕ предок C — будущий land этого не исправит сам по себе.
- `gh api jobs/114837464100/logs` (l3) → rc 0: отказы на ВСЕХ 20 fixtures-файлах плюс `registry/contracts.tsv`, check:zones rc=1 (не только 4 файла исходной выдержки форка).
- `gh api jobs/114837463802/logs` → это фактически l4, не l1; charter FAIL по 098 в `8c734d93` в `13:41:15.9330837Z`, итог ok=105 FAIL=2.
- SHA256 текущих барьеров: `check_zones.sh=b42d5c2289352c9cb03987d4e28df4be2a3d318a2f29f3fcf285e45985cd1c5c`; `check_charter.sh=16b98709afdda4b3a7fc426313a3a47aa5681925ef82504fe473483c36e13a8e`.

## Готовые кандидаты владельцу (НЕ выданная санкция)

```
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: scripts/check_charter.sh разрешаю узкое grandfather-допущение только пары
8c734d93b91fb3ff38528d6591d519a5145de325 / contracts/098-proizvodstvennye-dokazatelstva-do-publikacii.md:
материализация заморозки 098 в опубликованный main перенесла текст, побайтово равный
frozen/contracts/098/1, без строки разрешения в теле коммита; принимаю риск этой исторической
пары без переписывания истории. Грамматику razreshil(), контракт, критерии, теги и остальные
пары не менять; допуск не разрешает будущих изменений устава без моей санкции.
```

```
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: scripts/check_zones.sh разрешаю узкое grandfather-допущение только коммита
8c734d93b91fb3ff38528d6591d519a5145de325 автора orchestrator: только registry/contracts.tsv
(замена 098 mint→frozen при frozen-commit вне предков этого C), fixtures/_krasnye_098.sh и
fixtures/dokazatelstva_098/ (20 fixtures-файлов этого неизменяемого коммита, байтово равных
frozen/contracts/098/1, перенесены flat-коммитом под чужой identity). Принимаю риск этих
исторических пар по прецедентам 27188897 и 763d8dd7. Других SHA, авторов и путей не исключать,
зоны и общую REPLACE/ancestry-проверку не расширять; контракт, критерии, fixtures, frozen-теги,
авторство и историю не менять. Это не разрешение будущих обходов штатного land/PR-CI.
```

## Реализационная граница (для architect/implementer, исполняющих grandfather после подписи)
Charter — точная пара в исполняемом `case` функции `razreshil()`, не только комментарий. Zones —
registry-пара ДО mint/REPLACE-проверки внутри `an=orchestrator`/`f=registry/contracts.tsv`;
отдельный fixtures-допуск ПЕРЕД inside-сравнением с проверкой SHA/автора/путей. Не глобальный
`continue` на весь commit. `NABLIUDENIA_ARCHITECT.md` уже процессный, отдельного допуска не
требует. Сам код барьеров консультант не менял.

## Почему НЕ rebase
Rebase не исполнялся, равенство после него не заявляется: развилка «единственный путь»
опровергнута существующим grandfather-механизмом, а заявленных пяти потомков нет (их четыре).
Amend с разрешением лечит только charter; смена `--author` на architect выдумывает авторство и
не решает законный провенанс; простой amend не вводит frozen-ancestor. Revert не удаляет
историческое нарушение, поздняя подпись другого коммита не разрешает его, поздний merge не
меняет родителей C. Широкая зона orchestrator излишне разрешает будущие правки. СПАСЕНО требует
отдельной законной frozen-респеки и не заменяет charter-санкцию. Зелёный результат невнесённого
допуска и зелёный CI всей матрицы НЕ заявляются.

## Воспроизводимая тройка
КОМАНДА: git diff --quiet ff51125845cc782964d18e7a40891c181f1f3f7d 8c734d93 -- contracts/098-proizvodstvennye-dokazatelstva-do-publikacii.md fixtures/_krasnye_098.sh fixtures/dokazatelstva_098/
RC: 0
ВЫВОД-SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

## Остаточный риск доставки (для оркестратора)
Эта сессия консультанта не смогла сама закоммитить вердикт: её изолированный клон был создан
ОТНОСИТЕЛЬНЫМ путём `tmp/main-ci-investigation` внутри собственного designated-worktree (НЕ под
глобальным `/tmp/dev-harness-verify/**`), и Н-85/А-122 отказал write ТАМ так же, как отказал бы
в основном чекауте. Это ошибка постановки задания (оркестратор не повторил Н-143/148 инструкцию
в этом конкретном дозвоне для роли consultant), не дефект харнеса. Данный verdict-файл
материализован оркестратором из полного текста финального `abort-reason` субагента (текст
воспроизведён дословно, факты не пересказывались).

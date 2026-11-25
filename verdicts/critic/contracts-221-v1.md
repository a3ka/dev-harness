accept
OBJECT=7fb5d26c5d4eb1879b7a6cb57b30027e858ea044
СУД: repo=dev-harness; предмет=221; фаза=v2; роль=critic; вызов=2 (узкий повтор по дельте ремонта; бюджет 1 полный + ≤1 scoped); модель-план=GLM (zai/glm-5.3 по роли критика); модель-факт=zai/glm-5.3 (сессия Crit221c, настоящий вызов); предыдущий=archive/221/critic-v1-fail-b712c36c04 (FAIL, блоки К-08 и К-09); класс риска=рисковый; SHA=7fb5d26c5d4eb1879b7a6cb57b30027e858ea044; исключение=нет

# Суд контракта 221 до заморозки — вызов 2 (узкий повтор по дельте ремонта Architect221b)

Судится `contracts/221-mint-line-proekt.md` на OBJECT `7fb5d26c5d4eb1879b7a6cb57b30027e858ea044`. Независимость: автор ремонта — Architect221b (OpenAI, другая модель и сессия), судья — GLM, свою работу не судит. Запись «СУД (ДО ВЫЗОВА)» ведёт оркестратор в своём WORKTREE — по заданию не повод для стопа.

## Дельта ремонта (весь предмет настоящего повтора)

`git diff bdb527504b6a4f509a2bf8ba902ef3e18dc238e5 7fb5d26c5d4eb1879b7a6cb57b30027e858ea044 --stat` — ровно 7 файлов, +612/−14, все заявлены: контракт, SDACHA.md, build.py, probe221.py, source.json, stabs/st13-no-cleanup/mint_line.sh, stabs/st14-user-section/mint_line.sh. По scripts/, registry/, .github/ дельта пуста (0 строк) — производство не тронуто. Контракт меняет ровно два места, оба заявлены: строка «Миры» правила честного контроля (:44 — иные [user]-ключи вне запрещённых на корневой раскладке, остатка одноразового хука нет после каждого project-вызова успешного и отказного, .git/config отличается от исходного только удалёнными user.name/user.email) и пункт НЕ ЗАЩИЩАЕТ про скратч lib_zones живой двери (:62). Инварианты 2 (:33) и 3 (:34) не менялись. Необъявленной семантической дельты нет.

Механика ремонта (по коду, Н-39): probe221.py:206 `once_hook_residue` — остаток субъекта в TMPDIR-мире вызова (уцелевший pre-commit где угодно под scratch через rglob плюс посторонний временный каталог вне белого префикса lib_zones.*), предикат ONCE_HOOK_LEFT (:279) на каждом project-вызове; мир p12-user-family-config (:19, :58, :124 — корневая раскладка, user.signingkey и user.useConfigOnly рядом с запрещёнными), предикаты RAW_CONFIG_PARITY (:281, сырые байты конфига против normalized_config от снимка до субъекта) и прежний UNRELATED_CONFIG_CHANGED (:268). build.py: st13 — стёртый trap очистки (дословно мутант m2 вызова 1), st14 — remove-section user (дословно m3). Регенерация воспроизводима: в одноразовом клоне `python3 fixtures/workshop_project/mint_line_proekt_221/build.py` → NOSITELI 16 STABY 14 SVJAZI 18, `git status` пуст — source.json и носители побайтно сгенерированы одним build.py.

## Перепроверка заявлений автора (все rc сырые, мои прогоны)

- `bash scripts/check_sdacha.sh "$PWD" contracts/221-mint-line-proekt.md --run` → rc 0, «СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)» — совпало.
- `bash scripts/pre_critic.sh contracts/221-mint-line-proekt.md` → rc 0, «КРИТИК: дверь зелёная» — совпало.
- `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo .` → rc 1, KLETKI 17 KRASNYH 10 (p01–p08, p11, p12 — у p12 в том числе RAW_CONFIG_PARITY; p09, p10, s01–s05 зелёные) — совпало.
- `… --model` → rc 0, KLETKI 17 KRASNYH 0 — совпало (честная модель зелёна на новых клетках).
- `… --stabs` → rc 0, контроль CONTROL 17×GREEN, «STABY 14 SVJAZI 18 ZHIVYH 0» — совпало. st13 красен p01 и p07 ровно по ONCE_HOOK_LEFT, st14 красен p12 ровно по UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY — как заявлено автором.
- `… --sintaksis` → rc 0, SINTAKSIS 17 SHELLCHECK 2 (пин VALIDATE_STD_SHELLCHECK) — совпало.
- `bash scripts/check_precision_gate.sh . contracts/221-mint-line-proekt.md` → rc 0 (OK).
- Строка плана 221 в registry/plan.tsv по-прежнему нет (grep rc 1) — внешний owner-PR #1350, не блок (как в вызове 1).

## Закрытие блоков вызова 1 (по дельта-листу автора)

БЛОК-1 (К-08, инвариант 2 «одноразовый хук удаляется на выходе» без различающей клетки) — ЗАКРЫТ шире примера.
ПРОИСХОЖДЕНИЕ: дельта. КЛАСС: К-08.
Предикат ONCE_HOOK_LEFT наблюдает TMPDIR-мир каждого project-вызова. Стаб автора st13 красен на обеих связях (p01 успех, p07 отказ) ровно этим предикатом. Мои собственные мутации вне stabs (одноразовые клоны, каждый удалён после прогона):
- ma-success-only — очистка перенесена на успешный путь, отказный выход не чистит: p07 RED ONCE_HOOK_LEFT(tmp.Lz7zxq0wio,tmp.Lz7zxq0wio/pre-commit), ZHIVYH 0 — пойман (класс «каждый выход», а не только успех).
- mb-file-only — чистится только файл хука, временный каталог остаётся: p01 RED ONCE_HOOK_LEFT(tmp.edmBFKKk4W) и p07 RED ONCE_HOOK_LEFT(tmp.jRvVUQPaos), ZHIVYH 0 — пойман.
- mc-libzones-hide — очистка стёрта, каталог спрятан под белым префиксом (mktemp -d "$TMPDIR/lib_zones.evil.XXXXXX"): p01 RED ONCE_HOOK_LEFT(lib_zones.evil.tG7ucF/pre-commit) и p07 RED ONCE_HOOK_LEFT(lib_zones.evil.2T1Wjt/pre-commit) — белый список префикса НЕ маскирует остаток настоящего хука: rglob('pre-commit') судит имена и под lib_zones.*, а работающий хук обязан лежать в файле с именем pre-commit. Пойман.

БЛОК-2 (К-09, инвариант 3 «остальная конфигурация сохраняет ключи/значения» без клетки по иным ключам [user]) — ЗАКРЫТ шире примера.
ПРОИСХОЖДЕНИЕ: дельта. КЛАСС: К-09.
Мир p12 несёт user.signingkey и user.useConfigOnly на корневой раскладке (заодно закрыт совет вызова 1 о положительном минте на корневой раскладке). RAW_CONFIG_PARITY сравнивает сырые байты .git/config с ожиданием из снимка до субъекта — семей-агностично по байтам: любое изменение прочих строк красит. Стаб автора st14 красен p12 ровно по UNRELATED_CONFIG_CHANGED + RAW_CONFIG_PARITY. Мои мутации:
- md-user-glob — нормализация сносит все ключи user.* (список ключей из git config --name-only): p12 RED UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY, ZHIVYH 0 — пойман (вариант класса, отличный от remove-section).
- me-core-section — нормализация дополнительно сносит секцию [core], присутствующую в мирах: p12 RED UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY и p02 RED UNRELATED_CONFIG_CHANGED, ZHIVYH 0 — пойман.
- mf-gpg-section и mg-commit-section — снос секций [gpg] и [commit], отсутствующих в мирах: p12 GREEN, «STABY 1 SVJAZI 1 ZHIVYH 1» rc 1 — живые. По §Порог НЕ блок: источником ошибочного механизма была бы замена или удаление имеющейся операции, но любая чистая замена точечного unset-all на remove-section gpg/commit оставляет запрещённые user.name/user.email — живая дверь 080 отказывает, что показывают красные st02/st03/st10/st11; выживающий мутант требует вставки новой разрушительной ветви при сохранённой операции, а ссылка только на место вставки новой ветви основанием блока не является. Документированного источника ошибки такого класса (gpg/commit-ключи в болевом клоне Н-456 или письмах бэкенда) нет. Едет советом (см. Советы).

Двусторонность (К-14): честная модель зелёна 17/0, включая p12 и чистый TMPDIR-мир (дверь оставляет только lib_zones.*, честно вынесенные в НЕ ЗАЩИЩАЕТ :62); контроль --stabs 17×GREEN повторён в каждом из восьми прогонов суда; станционный байт-паритет s01–s05 зелён везде — поведение 068/031 без профиля байт-в-байт прежнее.

## Блоки вызова 2

Нет. Живых мутантов с основанием по §Порог не предъявлено, все заявления автора воспроизведены моими прогонами, семантическая дельта ровно заявленная (два места контракта, пять файлов семьи).

## НЕ ЗАЩИЩАЕТ (остатки — с ловцами)

- Скратч самой живой двери lib_zones.<hash>.* (каталог и маркер .active) в TMPDIR — дефект станционного инструмента, назван белым префиксом предиката и пунктом контракта :62, ловец — адресная проба lib_zones отдельным предметом оркестратору.
- Ключи конфигурации семейств, отсутствующих в мирах батареи ([gpg], [commit] и прочие вне [core]/[user]/[remote "origin"]): их снос сверх двух запрещённых ключей клетками не наблюдается (мои mf/mg живые). Ловец — совет 1 ниже (одна строка в мире p12) либо явный пункт НЕ ЗАЩИЩАЕТ, решение автора.
- Прежние границы вызова 1 без изменений: компрометация установки/PATH/git и single-uid identity-forgery (016/023/031, ловцы — изоляция станции, CI, reviewer), независимый дефект профильного пути 031 (check_staged.sh:780/793, отдельный предмет), конкурентная запись в общий git-config (живой запрет 080 до коммита), ручной git commit --no-verify вне mint_line (CI check:zones).

## Советы

- СОВЕТ probe221.py:124 — добавить в мир p12 один ключ отсутствующего семейства (например commit.gpgsign=false или gpg.format=openpgp): RAW_CONFIG_PARITY семей-агностичен по байтам и без новых предикатов покроет снос любой секции. Основание — мои живые mf-gpg-section/mg-commit-section (ZHIVYH 1), по §Порог вставка новой ветви без документированного источника ошибкой автора не является.
- СОВЕТ probe221.py:206 — наблюдение остатка хука локализовано TMPDIR-миром вызова (шов объявлен комментарием пробы). Реализация обязана держать временный каталог хука в TMPDIR (mktemp по умолчанию так и делает): вынос скратча хука за пределы TMPDIR клеткой не виден.
- Оба совета вызова 1 закрыты ремонтом: положительный минт на корневой раскладке — клеткой p12, мёртвый export NEXT_ID_LIB — поясняющим комментарием в build.py (нужен лишь SC2034 в --sintaksis модели, цепочке хука инертен, исполнителю не требуется).

## Карта классов

К-01: чисто — bash scripts/check_sdacha.sh "$PWD" contracts/221-mint-line-proekt.md --run → rc 0 (двери=12 карта=17/17 дельта=2), bash scripts/pre_critic.sh contracts/221-mint-line-proekt.md → rc 0, дельта ремонта ровно 7 файлов +612/−14 и только два заявленных места контракта (:44 и :62), по scripts/ registry/ .github/ пусто
К-02: чисто — без изменений с вызова 1: боль Н-456, письма бэкенда и задание architect — вход, дельта ремонта источники не меняла
К-03: чисто — без изменений с вызова 1: frozen 068/1, 031/4, 080/4, 125, 140, 016, 992, 996 свернуты живьём в вызове 1, ремонт их не трогает (git diff по scripts/ пуст)
К-04: чисто — все 7 файлов дельты в ЗОНА architect, source.json воспроизводим регенерацией build.py в одноразовом клоне (NOSITELI 16 STABY 14 SVJAZI 18, git status пуст)
К-05: чисто — без изменений с вызова 1: каждый пункт приёмки несёт rc-команду, расширенное правило честного контроля (:44) проверяется той же командой --model rc 0
К-06: чисто — без изменений с вызова 1: отказ среды rc 2 наблюдён в вызове 1 (VALIDATOR_MISSING без пина shellcheck, NOT_IMPLEMENTED без git/bash/jq)
К-07: чисто — честный контроль 17×GREEN на настоящем git и настоящем check_staged из дерева в каждом из восьми прогонов суда, не двойник
К-08: чисто — st13-no-cleanup красен p01 и p07 ровно по ONCE_HOOK_LEFT (--stabs rc 0 ZHIVYH 0), мои ma-success-only и mb-file-only пойманы тем же предикатом
К-09: чисто — st14-user-section красен p12 ровно по UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY, мои md-user-glob и me-core-section пойманы, живые mf-gpg/mg-commit — вставка новой ветви без документированного источника, совет
К-10: чисто — без изменений с вызова 1 плюс новые наблюдения полного выхода: TMPDIR-мир вызова и сырые байты .git/config p12, не маркеры и не ref
К-11: чисто — ожидание RAW_CONFIG_PARITY выводится из world.cfg, снятого до вызова субъекта (probe221.py:281 при self.cfg из конструктора мира), станционный канон в памяти до кандидата
К-12: чисто — без изменений с вызова 1: git plumbing, единый project_paths_resolve, source.json из одного build.py, регенерация побайтно совпала
К-13: н/п — без изменений с вызова 1: секретных входов нет, локальный bare-origin и синтетические identity
К-14: чисто — --model rc 0 KLETKI 17 KRASNYH 0 на новых клетках (двусторонность), станционный байт-паритет s01–s05 зелён во всех прогонах
К-15: чисто — все числа из вывода моих прогонов совпали с листом: 17 клеток и 10 красных (--repo rc 1), 17/0 (--model rc 0), STABY 14 SVJAZI 18 ZHIVYH 0 (--stabs rc 0), SINTAKSIS 17 SHELLCHECK 2 (rc 0), двери=12 карта=17/17 дельта=2 (rc 0)
К-16: чисто — без изменений с вызова 1: рисковый право/безопасность подтверждён, новая граница lib_zones в НЕ ЗАЩИЩАЕТ (:62) по существу и с ловцом
К-17: н/п — без изменений с вызова 1: новых операций и схем модели 188 нет

## Сырые выводы ключевых прогонов

- check_sdacha --run: «СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)» rc=0. pre_critic: «КРИТИК: дверь зелёная» rc=0. check_precision_gate: «OK» rc=0.
- --repo .: «KLETKI 17 KRASNYH 10» rc=1 (p01–p08, p11, p12 RED — p12 с RAW_CONFIG_PARITY, p09/p10 и s01–s05 GREEN).
- --model: «KLETKI 17 KRASNYH 0» rc=0.
- --stabs: контроль CONTROL 17×GREEN; st13 p01 RED ONCE_HOOK_LEFT(tmp.5trbkKFhRX,tmp.5trbkKFhRX/pre-commit) rc=0; st13 p07 RED ONCE_HOOK_LEFT(tmp.dpCrM6S0TO,tmp.dpCrM6S0TO/pre-commit) rc=1; st14 p12 RED UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY rc=0; «STABY 14 SVJAZI 18 ZHIVYH 0» rc=0.
- --sintaksis: «SINTAKSIS 17 SHELLCHECK 2» rc=0.
- Мутации критика (одноразовые клоны, каждый удалён после прогона): ma-success-only → p07 RED ONCE_HOOK_LEFT(tmp.Lz7zxq0wio,tmp.Lz7zxq0wio/pre-commit), «STABY 1 SVJAZI 1 ZHIVYH 0». mb-file-only → p01 RED ONCE_HOOK_LEFT(tmp.edmBFKKk4W), p07 RED ONCE_HOOK_LEFT(tmp.jRvVUQPaos), «STABY 1 SVJAZI 2 ZHIVYH 0». mc-libzones-hide → p01 RED ONCE_HOOK_LEFT(lib_zones.evil.tG7ucF/pre-commit), p07 RED ONCE_HOOK_LEFT(lib_zones.evil.2T1Wjt/pre-commit), «STABY 1 SVJAZI 2 ZHIVYH 0». md-user-glob → p12 RED UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY, «STABY 1 SVJAZI 1 ZHIVYH 0». me-core-section → p12 RED UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY, p02 RED UNRELATED_CONFIG_CHANGED, «STABY 1 SVJAZI 2 ZHIVYH 0». mf-gpg-section → p12 GREEN, «STABY 1 SVJAZI 1 ZHIVYH 1» rc=1 (живой, совет). mg-commit-section → p12 GREEN, «STABY 1 SVJAZI 1 ZHIVYH 1» rc=1 (живой, совет).

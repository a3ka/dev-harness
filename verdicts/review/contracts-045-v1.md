accept

# Ревью контракта 045 (pre-exchange-guard-gitw), frozen v3 — полный круг

Предмет: `scripts/gitw`, `fixtures/gitw/red_gitw_obmen.sh`, `fixtures/_krasnye_045.sh`,
`.github/workflows/ci.yml` (шаг dogfood), `contracts/045-pre-exchange-guard-gitw.md`.
Дерево `/home/aka/Documents/dev-harness`, HEAD `bd823e8`, тег `frozen/contracts/045/3`.
Все мутационные пробы — в одноразовом клоне `/tmp/dev-harness-verify/rev045`; основной
чекаут не мутирован, ничего не запушено.

Вердикт связывается с блобами HEAD `bd823e8`: `scripts/gitw` (5 коммитов implementer),
`fixtures/gitw/red_gitw_obmen.sh` (3 architect + 1 побайтовый перенос).

## 1. Реализация закрывает round-1 и round-2 — подтверждено МОЕЙ мерой

Прогон чужой фикстуры пересказом не считается. Написан собственный репро-скрипт
(`/tmp/dev-harness-verify/scratch/rev045_repro.sh`), строящий свежий mktemp-мир
(`canon.git` + `evil.git` + жертва) на каждую пробу и судящий НЕ по rc, а по побочному
эффекту (SHA чужого bare / смещение HEAD / существование FETCH_HEAD).

Против `scripts/gitw` на HEAD `bd823e8`:

```text
РЕПРО round1 push --repo=EVIL      rc=1 ОТКАЗ, evil не тронут (absent)
        stderr: gitw ОТКАЗ: URL remote evil не канонический: /tmp/rev045-r1.uf3YqF/evil.git
РЕПРО round1 push --repo EVIL      rc=1 ОТКАЗ, evil не тронут (absent)
        stderr: gitw ОТКАЗ: URL remote evil не канонический: /tmp/rev045-r1.huUK2E/evil.git
РЕПРО round2 remote.pushDefault    rc=1 ОТКАЗ, evil не тронут (absent)
        stderr: gitw ОТКАЗ: URL remote evil не канонический: /tmp/rev045-r2a.VaDHpX/evil.git
РЕПРО round2 branch.pushRemote     rc=1 ОТКАЗ, evil не тронут (absent)
        stderr: gitw ОТКАЗ: URL remote evil не канонический: /tmp/rev045-r2b.ykZy6y/evil.git
РЕПРО round2 pull branch.remote    rc=1 ОТКАЗ, HEAD не сместился (be4964d194d516d31a49911b1c7c03bf41d00492)
        stderr: gitw ОТКАЗ: URL remote evil не канонический: /tmp/rev045-r2c.etsTuv/evil.git
РЕПРО round2 fetch --all           rc=1 ОТКАЗ, FETCH_HEAD не создан
        stderr: gitw ОТКАЗ: многоцелевой обмен отказан, неканонические или недоступные цели:
КОНТРОЛЬ positive                  rc=0 канонический push ПРОШЁЛ, canon/main=2474c4b71b7f9e54c89a6d065befebc15b10cb14

итог репро: провалов 0
REPRO_RC=0
```

Позитивный контроль в том же скрипте зелёный — мера не вечно-красная.

**Мера предъявлена КРАСНОЙ.** Тот же скрипт против исторических блобов `scripts/gitw`
(`git cat-file -p <sha>:scripts/gitw`):

```text
=== against b4fd794-era gitw (pre-round1-fix) ===
РЕПРО round1 push --repo=EVIL      rc=0 ОБХОД ЖИВ  evil: absent -> d537552c35b76ee7f567b9e063e2148fb8a6cec3
РЕПРО round2 remote.pushDefault    rc=0 ОБХОД ЖИВ  evil: absent -> 41ad8763de7e0aaf48144aae9435a402314ddf84
РЕПРО round2 branch.pushRemote     rc=0 ОБХОД ЖИВ  evil: absent -> 41ad8763de7e0aaf48144aae9435a402314ddf84
РЕПРО round2 fetch --all           rc=0 ОБХОД ЖИВ  FETCH_HEAD=1lines
итог репро: провалов 4
RC=1

=== against 9490b1e-era gitw (post-round1, pre-round2) ===
РЕПРО round1 push --repo=EVIL      rc=1 ОТКАЗ, evil не тронут (absent)
РЕПРО round1 push --repo EVIL      rc=1 ОТКАЗ, evil не тронут (absent)
РЕПРО round2 remote.pushDefault    rc=0 ОБХОД ЖИВ  evil: absent -> 41ad8763de7e0aaf48144aae9435a402314ddf84
РЕПРО round2 branch.pushRemote     rc=0 ОБХОД ЖИВ  evil: absent -> 41ad8763de7e0aaf48144aae9435a402314ddf84
РЕПРО round2 fetch --all           rc=0 ОБХОД ЖИВ  FETCH_HEAD=1lines
итог репро: провалов 3
RC=1
```

Градиент 4 → 3 → 0 по поколениям фиксов. Обход round-1 и обход round-2 закрыты
реально, а не отчётом.

Две честные оговорки о пределах МОЕЙ меры (называю, чтобы вердикт не пересказывал
сам себя):
- раздельная форма `--repo evil` на `b4fd794` дала rc=1, а не обход: старый парсер
  ловил `evil` как позиционную цель. Вердикт round-1 и заявлял живым именно
  равн-форму `--repo=evil`; расхождения с вердиктом нет;
- проба `pull branch.remote` на старых блобах даёт rc=128 (мой evil-tip — несвязанная
  история, git отказывается сливать), поэтому счётчик её обходом не засчитал. Но
  stderr старых блобов — `From /tmp/…/evil`, то есть обмен с чужим до evil ДОШЁЛ;
  на HEAD stderr — `gitw ОТКАЗ: URL remote evil не канонический`, обмен предотвращён
  ДО контакта. Разделение поколений по этому вектору тоже наблюдаемо.

## 2. Фикстура мутационно доказана

Живой прогон на HEAD в одноразовом клоне:

```text
ok: г28б
gitw: батарея зелёная (клетки г0-г28б + 38 стабов на своих клетках)
RC=0
```

Против сломанных реализаций (подмена ТОЛЬКО `scripts/gitw` в клоне, фикстура не
тронута):

```text
$ git checkout b4fd794 -- scripts/gitw ; bash fixtures/gitw/red_gitw_obmen.sh <клон>
ОТКАЗ: г17: rc=0, --repo=<имя> есть repository-аргумент и обязан судиться (живой обход
адверсария 045-v3): To /tmp/gitw045.FlTCGf/b4-chuzhoj  + d3b7cdf...c24811d main -> main (forced update)
RC=1

$ git checkout 9490b1e -- scripts/gitw ; bash fixtures/gitw/red_gitw_obmen.sh <клон>
ОТКАЗ: г19: rc=0, remote.pushDefault=evil ЕСТЬ фактическая цель push: To
/tmp/gitw045.mUa1NL/nv-19-chuzhoj.git  + c11b4dc...415f476 main -> main (forced update)
RC=1
```

Батарея умирает ИМЕННО на клетке своего раунда (г17 — round-1, г19 — round-2), а не
абы где. Стаб-пак: 38 обманных реализаций, каждая обязана умереть на СВОЕЙ именованной
клетке; сверка имени клетки терминирована двоеточием (`red_gitw_obmen.sh:884-886`), так
что «г17» не засчитывается подстрокой за «г17б».

**Проверка не переписана под реализацию.** Авторство разделено:
`git log --format='%an' -- fixtures/gitw/red_gitw_obmen.sh | sort | uniq -c` → `3 architect`,
`1 implementer`; `-- scripts/gitw` → `5 implementer`. Единственное касание фикстуры
реализатором — перенос `check_judge_gate/ → gitw/` в `9c37233`, побайтовый:
`cmp` блоба `frozen/contracts/045/1:fixtures/check_judge_gate/red_gitw_obmen.sh` с
`9c37233:fixtures/gitw/red_gitw_obmen.sh` → rc 0, 30715 = 30715 байт.

Клетки написаны ПРОТИВ сломанного кода, не поверх фикса: `1bbbda7` (architect) в теле
коммита заявляет «против ТЕКУЩЕГО scripts/gitw … честная часть красна на г19 (живой
обход: forced update в чужой bare)», ветки шли параллельно (`wip/001/architect` и
`wip/002/implementer` приземлены раздельно, `0f1fd75`/`072aff1`). Моя мутационная проба
это подтверждает независимо.

Счёт стабов проверен СВОЕЙ мерой, не повтором баннера: массив `pairs`
(`red_gitw_obmen.sh:863-875`) содержит 38 записей; `grep -c 'ok_cell '` → 48 честных
клеток; живой прогон печатает 86 строк `ok:` = 48 + 38. Баннер «38 стабов» правдив.

Регрессия донорской семьи: `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate`
→ rc 0 (3 фикстуры, все предъявлены красным повторным прогоном); `fixtures/check_judge_gate/`
не содержит остатков `gitw`.

## 3. Зоны и раздача

`bash scripts/check_zones.sh` → **rc 0**; итог: «замороженных контрактов: 44 · объявленных
авторов: 2 · коммитов в диапазонах: 2116 · проверено по зонам: 1370». По 045 напечатано
ровно два изъятия — критик-принятые СПАСЕНО:

```text
  ok   контракт 045: коммит 9c372335 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 045: коммит fc7c536a (implementer) — СПАСЕНО, из суда зон выведен
```

Пофайловая сверка каждого коммита диапазона своей мерой (`git show --stat`):
implementer правил `scripts/gitw`, `.github/workflows/ci.yml`, `package.json`;
architect — `contracts/045-*.md`, `fixtures/gitw/`, `fixtures/_krasnye_045.sh`,
`NABLIUDENIA_ARCHITECT.md`. `package.json` в СПАСЕНО не назван и в нём не нуждается:
он в implementer-union от 002/003/004/005/006/007/008/016/021/027. Архитекторский
`NABLIUDENIA_ARCHITECT.md` — свой канал по строке «РАБОТА НЕ РАЗДАЁТСЯ». Выходов за
границы ЗОНА-строк 045 нет.

## 4. Область правки v3 не расширилась молча

`git diff cea3a8f d95c7b1 -- contracts/045-pre-exchange-guard-gitw.md` → `1 file changed,
1 insertion(+), 1 deletion(-)`: изменена РОВНО строка `СПАСЕНО implementer:` (дописан
второй хеш `fc7c536a…` и его обоснование). Ничего больше.

`git log --oneline d95c7b1..HEAD -- contracts/045-pre-exchange-guard-gitw.md` → **пусто**.
Ни один из фиксов round-1/round-2 текста замороженного контракта не касался — только
`scripts/gitw` и `fixtures/gitw/`. Узкий критик-accept соблюдён буквально.

## 5. Владельческое scope-решение по round-3 записано честно

Запись `NABLIUDENIA.md` Н-151 атрибутирует решение владельцу явно и с датой: заголовок
несёт `ПРИНЯТО (владелец 2026-09-25): out-of-scope остаток 045, не ослабление критерия`,
тело — отдельный абзац «**Решение владельца (2026-09-25, дословно по существу):**» с
причиной (malicious-обход защищает уже-проигранный фланг, Н-143-ядро открыто) и прямым
признанием «Кап кругов (5) НЕ выжидался специально — остановка по решению владельца на
round-3, до кап». Судья закрывшим вопрос себя нигде не выдаёт.

Вердикт адверсария `contracts-045-v3-confirm-round3.md` на диске остаётся **FAIL** и
переписан не был: `git log -- verdicts/adversary/contracts-045-v3-confirm-round3.md` →
один коммит `1895edf|adversary|2026-09-25`. То же для round-1 (`b4fd794`) и round-2
(`8d66d64`) — по одному коммиту автора `adversary`, ретро-правок нет.

Запись не завышает закрытость: остаток проверен живьём и ДЕЙСТВИТЕЛЬНО открыт —

```text
round3 multi-url      rc=0 evil/multiurl=6c8b0f1c949254159677fffb9f04c534f19b6833 -> ЖИВ (остаток)
round3 alias          rc=0 evil/alias=6c8b0f1c949254159677fffb9f04c534f19b6833 -> ЖИВ (остаток)
```

То есть Н-151 описывает фактическое положение дел, а не желаемое. Пересматривать саму
владельческую границу — не круг судьи.

## 6. ПРОВОДКА подключена, не орфан

Цели существуют и каналы живые, сверено командами контракта:

```text
grep -cF 'обход гварда сырым git = гейминг (контракт 045)' roles/orchestrator.md          → 1
grep -cF 'git-обмены (push/fetch/pull) — только через bash scripts/gitw (контракт 045)'
        roles/implementer.md → 1 ; roles/architect.md → 1
```

`guard=scripts/gitw` — барьер ИМЕННО предмета 045 (обёртка обмена, а не произвольный
скрипт дерева), и он реально вызывается, цепочка пройдена end-to-end в клоне:

```text
.github/workflows/ci.yml:269  run: npm run check:gitw-family-selftest
package.json:68  "check:gitw-family-selftest": "bash fixtures/_krasnye_045.sh scripts/gitw"
$ npm run check:gitw-family-selftest
gitw/red_gitw_obmen.sh rc=0
итог: 1 файлов, провалов 0
CI_CHANNEL_RC=0
```

Живое самоприменение в основном чекауте: `bash scripts/gitw fetch --dry-run` → rc 0
(origin = `ssh://git@github.com/a3ka/dev-harness.git`, буквально канон-константа).

Форма ПРОВОДКА верна по 038: поведенческие дельты (О-1 цикл синхронизации, О-2/О-3
СТОП-и-доклад) идут **role-каналом** тремя строками, а `ПРОВОДКА-ЭНФОРСМЕНТ` оставлен
только за `scripts/gitw` с честным обоснованием чистого энфорсмента (буквальная сверка
цели ДО исполнения, rc-семантика). Это не guard-only-обход role-канала.

## 7. Сырой лог диапазона — посторонних правок нет

`git log --oneline frozen/contracts/045/1..HEAD -- contracts/045-pre-exchange-guard-gitw.md
scripts/gitw fixtures/gitw/` прочитан целиком, 12 коммитов:

```text
0f1fd75|orchestrator|land: wip/001/architect
1bbbda7|architect   |fixtures/gitw — клетки г19-г28б (+18 стабов)
6d6e9f9|implementer |scripts/gitw И-4в — git-config НЕЯВНОЕ разрешение remote
072aff1|orchestrator|land: wip/002/architect
9490b1e|implementer |scripts/gitw И-4а — раздельная форма --repo и завис arm `*:*)`
c877dac|architect   |fixtures/gitw — клетки г17-г18 (+9 стабов)
20d17ac|implementer |scripts/gitw И-4а — --repo=VALUE как fallback-цель
d95c7b1|architect   |045 v3: СПАСЕНО fc7c536
cea3a8f|architect   |045 v2 (чертёж к заморозке)
6bd9796|architect   |клетки г13-г16
728bb52|implementer |045 fix И-4 — SCP-форма + named remote + fail-closed query
9c37233|implementer |045 реализация И-1..И-9
```

Каждый коммит атомарен, тема совпадает с предметом, ссылка на раунд/инвариант в
заголовке. Связок «пять задач в одном коммите» нет. Скрытых правок вне заявленного нет.

## Находки

Блокеров нет. Ниже — замечания; ни одно не меняет вердикт, исправление за владельцем.

**З-1 (устаревший счёт, `.github/workflows/ci.yml:252-253`, зона implementer).** Комментарий
шага заявляет «батарею 12 клеток (г0–г12) плюс стаб-пак из 11 обманных реализаций».
Фактически (моя мера: `grep -c 'ok_cell '` → 48; массив `pairs` → 38; живой прогон → 86
строк `ok:` = 48+38) батарея — 48 клеток г0–г28б и 38 стабов. Класс: ложное счётное
утверждение в комментарии. Барьер от него не зависит, поведение верное.

**З-2 (устаревший счёт, `fixtures/_krasnye_045.sh:4-5`, зона architect).** Шапка раннера
заявляет «батарея 28 клеток (г0–г18) + стаб-пак из 20 обманных стабов». После `1bbbda7`
(+20 клеток, +18 стабов) фактические числа — 48 и 38. Коммит `c877dac` эти счётчики
однажды уже приводил к измеренным; `1bbbda7` шаг пропустил. Тот же класс, что З-1.

**З-3 (литеральный баннер, `fixtures/gitw/red_gitw_obmen.sh:1433`).** Финальная строка
«клетки г0-г28б + 38 стабов» — печатный литерал, не вычисленное значение. Сейчас правдива
(проверено независимым счётом), но это ровно тот механизм, которым уже разошлись З-1 и
З-2. Дрейф баннера здесь опаснее: он читается как итог ПРОГОНА. Гибель стабов при этом
вычисляется из массива, а не из баннера, — доказательная сила батареи не затронута.

**З-4 (самоописание шире принятой модели угроз, `scripts/gitw:3-4`).** Шапка предмета
утверждает: «Судит КАЖДУЮ непустую форму цели ДО исполнения обмена». После владельческого
решения по Н-151 это не так и так не задумано: множественные `remote.<n>.url`/`pushurl`,
git-алиасы и `ext::`-транспорт не судятся (проверено живьём в п.5 — оба вектора дали rc 0
и запись в чужой bare). Граница записана в Н-151, но читатель `scripts/gitw` её не видит и
получит из шапки более сильную гарантию, чем предмет даёт. Класс: точность самоописания.
Предмет не правлю — называю; уместная правка (за владельцем) — сузить шапку до принятой
модели «случайно-не-в-ту-зону» со ссылкой на Н-151.

## Вердикт

**accept.** Round-1 и round-2 закрыты реально — подтверждено независимым репро с побочными
эффектами и градиентом 4 → 3 → 0 по поколениям блобов. Фикстура мутационно доказана и
предъявлена красной на клетках своих раундов; авторство проверки отделено от авторства
реализации. Зоны чисты (`check_zones.sh` rc 0), область правки v3 — ровно СПАСЕНО-строка,
текст замороженного контракта раундами не тронут. ПРОВОДКА подключена и проверена
end-to-end, форма role/guard по 038 корректна. Владельческое решение по round-3 записано
с явной атрибуцией и датой, вердикт адверсария не переписан, остаток фактически открыт —
запись честна. Четыре замечания выше — счётные/описательные, не поведенческие.

---
Ревьюер, 2026-09-25. Мутационные пробы: `/tmp/dev-harness-verify/rev045` (одноразовый клон),
скрипты меры — `/tmp/dev-harness-verify/scratch/rev045_repro.sh`,
`/tmp/dev-harness-verify/scratch/rev045_residual.sh`. Основной чекаут не мутирован, push не
выполнялся.

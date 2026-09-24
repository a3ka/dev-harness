accept

# Контракт 037 — узкая перепроверка Н1/Д1 и двух советов

Предмет: `contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` на
`39e4595927fd1cc956ad473015931afb872c2a0b` (фикс `c8ba2ee` + операционные
наблюдения `39e4595`). Это HEAD отдельного SSH-клона
`/tmp/dev-harness-verify/critic037-n1-AhDMqkzJ/repo`; сразу после клонирования
`git remote -v` показал `ssh://git@github.com/a3ka/dev-harness.git` для
fetch и push. Главный чекаут не читался и не изменялся.

Полностью прочитаны контракт и `verdicts/critic/contracts-037-b4-resolution-v1.md`,
AGENTS.md и операционные записи А-249–А-251 в NABLIUDENIA_ARCHITECT.md
(фактические заголовки записей на этом HEAD). Набор полный: закоммиченный
предмет, критерии с командами, исполнители и ЗОНА-строки присутствуют.
Суд только о закрытии Н1 (в задании также Д1) и двух прежних советах.
Закрытые А1–А3/Б1–Б3, полномочие (в) и спор UUID/имя заново не рассматриваются.

## Н1 закрыта независимой живой мерой

Новый источник §Инварианты М1 п.5 (:182–252) воспроизведён на **другой
пачке, других именах, другом профиле**, не по таблице архитектора.
Запущен `omp v18.1.18`, supervised process `critic037-n1-ahdm-live`,
PID `494883`, профиль `critic037ahdm`, явная модель диагностического
исполнения `minimax/MiniMax-M3`. Процесс завершился с rc **0**. Диагностическая
модель только создавала топологию и выполняла `bash pwd`; суд выполнен критиком.

В SSH-клон временно добавлен `.omp/extensions/zzz-critic037-n1-diag.ts`.
Он не менял `path-guard.ts`, контекст или решение инструмента. На `tool_call`
сам extension читал реальные `ctx.cwd`, `ctx.sessionManager.getSessionFile()`,
`ctx.sessionManager.getSessionId()` и JSON из
`join(dirname(ctx.cwd), '.omp-isolation-owner.json')`, затем писал JSONL
на абсолютный scratch-путь вне клона. Значения не поступали из аргументов
модели. Измеряющая операция:

```typescript
const sessionFile = ctx.sessionManager.getSessionFile();
const sessionName = typeof sessionFile === 'string'
  ? basename(sessionFile, '.jsonl') : null;
const owner = JSON.parse(readFileSync(
  join(dirname(ctx.cwd), '.omp-isolation-owner.json'), 'utf8'));
// В лог: sessionFile, sessionName, owner, cwd, sessionId, tool, pid.
```

CLI-сессия вызвала ОДИН task item
`{name:"MapleOwner037AhDM", agent:"task", isolated:true, task:…}`.
Именно MapleOwner затем вызвал вложенный batch: `WillowBare037AhDM`
с `isolated:false` и `JuniperIso037AhDM` с `isolated:true`.
Ниже реальные значения на **bash tool_call** каждой сессии; это не три
siblings и не сконструированные CLI-входы judge.

| вызывающий | суффикс cwd от `profiles/critic037ahdm/wt/` | basename файла без `.jsonl` | owner.id | равенство |
|---|---|---|---|---|
| владелец MapleOwner | `te84d063eb/m` | `MapleOwner037AhDM` | `MapleOwner037AhDM` | true |
| голый вложенный WillowBare | `te84d063eb/m` | `MapleOwner037AhDM.WillowBare037AhDM` | `MapleOwner037AhDM` | false |
| свой isolated JuniperIso | `t53df740f7/m` | `MapleOwner037AhDM.JuniperIso037AhDM` | `MapleOwner037AhDM.JuniperIso037AhDM` | true |

Полный префикс session-файлов:
`/home/aka/.local/state/dev-harness-sessions/775e24e1/zones/dev/.omp/profiles/critic037ahdm/agent/sessions/-tmp-dev-harness-verify-critic037-n1-AhDMqkzJ-repo/2026-09-24T11-09-15-809Z_01a0d31a-faa1-7663-8fbf-a9f1abb17d1a/`.
От него файлы соответственно:

- `MapleOwner037AhDM.jsonl`;
- `MapleOwner037AhDM/MapleOwner037AhDM.WillowBare037AhDM.jsonl`;
- `MapleOwner037AhDM/MapleOwner037AhDM.JuniperIso037AhDM.jsonl`.

У обоих деревьев owner содержит `pid=494883`, `startToken="1220660"`.
Три разные session UUID (только для идентификации наблюдений):
`01a0d31b-2ecd-75c7-ab14-a7b259c5bd54`,
`01a0d31b-5eb6-72c4-af88-2ebda3366716`,
`01a0d31b-602a-76d6-b741-9267ee53d7e9`.

Независимый `node /tmp/dev-harness-verify/critic037-n1-AhDMqkzJ/check-observations.mjs`
прочитал сырые события, выбрал bash каждой сессии, заново вычислил basename,
проверил общий cwd первой пары, отдельный cwd третьей, три различные UUID,
owner.pid текущего процесса и массив равенств `[true,false,true]`. Rc **0**:

```
OBSERVED: owner=true; nested-bare=false; own-isolated=true; shared/independent cwd topology verified
```

Сырые наблюдения — scratch
`/tmp/dev-harness-verify/critic037-n1-AhDMqkzJ/observations.jsonl`;
существенные значения перенесены выше, verdict не зависит от сохранности
scratch. Runtime сообщил `No changes to apply`. Первый старт с профилем
`critic037AhDM` был отвергнут CLI из-за заглавных букв и не считается
пробой; таблица только от успешного `critic037ahdm`. Временный extension
удалён после измерения.

**Вывод:** новый источник совпадает с владельцем в обеих isolated-топологиях
и различает голого вложенного ребёнка при байт-идентичном cwd. Требование
закрытия Н1 из v1 — живая связь именно предписанного источника с owner —
выполнено независимо. Это не приёмка ещё не написанного М1 и не гарантия
всех будущих версий/режимов жизненного цикла omp.

## Фикстура и собственные команды

В `fixtures/self_contained_cwd/red_self_contained_cwd.sh:101–102,161–162,191–192`
owner и позитив п1 используют `TestOwner037`, негатив п7 —
`TestOwner037.NestedBare037`, поле входа — `sessionName`. Иерархическая
форма реалистична; живая проба выше доказывает то, чего одна замена
синтетических строк доказать не могла.

Все команды выполнены мной в судимом SSH-клоне:

| команда | rc | наблюдение |
|---|---:|---|
| `bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .` | 1 | `ИТОГ 037 (self-contained-cwd): ветвей 7, красных 1, зелёных 6` |
| `bash scripts/check_threat_model.sh . contracts/037-*.md` | 0 | `модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))` |
| `bash scripts/check_provodka.sh . contracts/037-*.md` | 0 | вывода нет |
| `bash scripts/check_precision_gate.sh . contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` | 0 | `OK` |

У Р1 красна только **п1**: ожидалось pass, получено block, причина
`Н-85/А-122`, путь внутри FAKEHOME не в null-allowlist. П7 зелёная как
канарейка нынешнего общего отказа, не как доказательство реализованного
сравнения. Субъект реализации здесь не подменялся стабом.

Побайтовая синхронизация ПРОВОДКА дополнительно проверена Node-скриптом:
содержимое целых `«…»` строки контракта :647 сравнивалось через
`Buffer.equals` с целой строкой `roles/architect.md:290`; проверены
именно «четырьмя условиями». Rc **0**:

```
OBSERVED: complete M1 ПРОВОДКА literal is byte-identical to roles/architect.md line
```

Это включает новый basename-источник и обязательное четвёртое условие.
Общепроектные formatter/linter/build/full-suite, М2 и повторная приёмка
закрытых вопросов не запускались.

## Остаточные риски и два прежних совета

М1 :236–252 и §Остаточный риск :616–642 прямо оставляют открытыми окно
записи owner, повторное использование `wt/<hash>`, неиспользование
`startToken` и эфемерную сессию `--no-session`. При отсутствии надёжного
`.jsonl`-источника п.5 предписывает fail-closed, не получение права из
cwd. Отсутствие owner тоже означает отказ. Для переиспользования дерева
и startToken не обещан аутентифицированный lifecycle/anti-replay.
Наша проба проверяет обычные персистентные task-сессии; гонки, replay и
`--no-session` я не воспроизводил и за проверенные/закрытые не выдаю.
Нового скрытого обхода критерия в пределах фикса не предъявлено;
названные исключения не превращаются в блокер только из-за того, что
остаются исключениями.

Совет о цитате Р6 **закрыт**: :534–537 теперь 4/4, что совпало с моим
фактическим выводом check_threat_model.

Совет о ceremony **закрыт частично**: :633–642 теперь правильно говорят
«НЕ обходом ИМЕННО гонки создания owner.json». Но обещание осталось в
других местах:

СОВЕТ contracts/037-samodostatochnyj-cwd-i-priemnik-task.md:437 — М3 п.4 всё ещё называет собственный isolated «обходом узкого остаточного риска гонки владения»; то же обещание осталось в :44 и :431. Это расходится с исправленным :636–638: новый клон сам проходит своё окно записи owner. Унифицировать эти три фразы с исправленным остаточным риском. Конкретного обхода приёмки это замечание не предъявляет, поэтому остаётся СОВЕТОМ, не вторым FAIL и не основанием арбитража.

## Пять вопросов в границах этого круга

1. **Критерий слабее предмета?** Старый конкретный обход Н1 устранён:
   новый live-источник предъявлен независимо, не только синтетическими
   равными строками. Приёмка реализации остаётся implementer-задачей;
   нынешнее accept не означает, что п1 уже зелёная.
2. **Готово доказуемо командой?** Узкое закрытие источника доказано живым
   процессом и assert-скриптом с rc0; Р1 предъявлена с назначенным rc1,
   структурные гейты — с rc0. Гонки/ephemeral не объявлены доказанными.
3. **Решение оставлено исполнителю?** Источник getSessionFile-basename,
   поле sessionName, литеральное сравнение и fail-closed названы явно
   (:182–193, :254–269). Optional усиление startToken не обязательная
   невыбранная развилка этого закрытия.
4. **Границы исполнения?** ЗОНА-строки :457–463 сохраняют исполнителей
   контракта/фикстуры/ролей, path-guard и судей; precision-гейт rc0.
   Единственный постоянный файл этой пачки — данный verdict.
5. **Противоречие AGENTS.md?** В рассматриваемом фиксе нормативного
   блокера не найдено. Топологии проверены независимыми callback-значениями,
   не пересказом таблицы автора; советы не повышены до блокеров без обхода.
   Полномочие (в) и прежний арбитраж не переоткрыты.

Итог: **accept; 0 блокирующих находок, 1 сохраняющийся совет**.
Н1 закрыта. Из прежних советов цитата Р6 закрыта полностью,
ceremony исправлена не во всех вхождениях и едет дальше советом.
Контракт, роли и реализация критиком не изменялись.

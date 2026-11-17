FAIL

СУД: repo=dev-harness; предмет=175; фаза=контракт v2, адресный v+1; роль=critic; вызов=один дополнительный по слову владельца №42; модель-план=critic → apex-sol → @gpt-terra; сессия=Crit175V2; модель-факт=openai-codex/gpt-6.1-terra; SHA=2cb947a978abb025880b3ecdb8486d1340eb60f3; предыдущие=contracts-175-v1-krug1-fail.md, contracts-175-v1.md (accept); исключение=слово владельца №42. `models_actual.sh --tsv --bind --session Crit175V2` rc 0: `critic openai-codex/gpt-6.1-terra allowed Crit175V2 2cb947a978abb025880b3ecdb8486d1340eb60f3`. В HANDOFF предварительная запись без фактической сессии и с устаревшим SHA 97af896d81; OBJECT и модель сверены по заданию и трассе. История четырёх стартов сохранена; полномочия только на дельту и зависимый регресс, не новый полный проход.

## Блоки

БЛОКИРУЕТ contracts/175-tablo-bez-demo.md:25 — батарея не различает два расположения журналов.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-08
ОБЯЗАТЕЛЬСТВО: пункт 3 требует учитывать и прямые `*.jsonl`, и `*/*.jsonl`; готовность :40–42 требует зелёной различающей батареи.
СОСТОЯНИЕ: поддержанная проектная сессия пишет прямой журнал; заявленный в :10 журнал субагента может лежать на уровень ниже. В модели model.py:39–40 существуют обе операции glob; в батарее `fake_glob` probe.py:127–130 возвращает один и тот же синтетический файл для обоих шаблонов независимо от расположения.
НАБЛЮДЕНИЕ: удаление любой из двух операций поиска из честной модели оставляет все 22 клетки зелёными. На мире с одним журналом в удалённой ветви ведущий не обнаружится и табло потребует поток при живом ведущем.
ОБХОД: реализация с одним glob проходит приёмку 22/22, хотя не выполняет инвариант 3 на другом разрешённом расположении журнала.
Закрывающее свойство: отдельно различать прямой и вложенный журнал, с проверкой обеих операций и адресными стабами по коду.

БЛОКИРУЕТ contracts/175-tablo-bez-demo.md:25 — окно не проверяется на включённой границе.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-08
ОБЯЗАТЕЛЬСТВО: свежий mtime «не старше окна» включительно; аргумент окна — поддержанный интерфейс табло.
СОСТОЯНИЕ: при запуске с окном 20 минут журнал может иметь mtime ровно NOW−20 минут. Новая операция модели `>=` сравнивает время с границей; миры батареи используют только 5 и 45 минут при окне 20 (probe.py:60–68).
НАБЛЮДЕНИЕ: замена существующего `>=` на `>` проходит 22/22, но на равной границе ложно требует поток mob.
ОБХОД: строгий компаратор удовлетворяет командам приёмки, хотя исключает журнал точно на границе.
Закрывающее свойство: детерминированное сравнение на обеих сторонах и на включённой границе без расхождения часов генератора и субъекта.

БЛОКИРУЕТ contracts/175-tablo-bez-demo.md:42 — приёмочная батарея краснит конформную реализацию с прямым glob пути.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-07
ОБЯЗАТЕЛЬСТВО: контракт :25 требует читать указанные `*.jsonl` и `*/*.jsonl`, не предписывая сначала glob самого каталога; после реализации команда :42 должна принять корректное дерево.
СОСТОЯНИЕ: честный субъект раскрывает два полных пути `glob.glob(os.path.expanduser(base + '/' + pattern))`; это обычный Python glob для указанного поддержанного пути. `fake_glob` probe.py:115–132 распознаёт только искусственную промежуточную форму `synthetic-mob-session/...`, а не полные пути.
НАБЛЮДЕНИЕ: замена только способа формирования glob в честной модели даёт `mob_session_zel_pr KRASNO`, хотя на настоящей файловой системе оба варианта перечисляют те же файлы.
Закрывающее свойство: тестовый мир принимает эквивалентные штатные обращения к файловой системе и различает корректное поведение независимо от формы реализации.

## Воспроизведение атак

На OBJECT, в одноразовом клоне, команда `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL python3 /tmp/dev-harness-verify/Crit175V2/attack.py` rc 0. Полный сырой вывод:
```
strict ok 22 out_of 22
direct_only ok 22 out_of 22
nested_only ok 22 out_of 22
equivalent:
175 mob_session_zel_pr KRASNO pr=1/1 mob_facts=0 potok_mob=1 err='' rc=0
result False
```
Содержимое исполняемого файла (пути абсолютные для данного клона):
```python
import contextlib, io, sys
sys.path.insert(0, '/tmp/dev-harness-verify/Crit175V2/repo/fixtures/workshop_project/tablo_demo_175')
from model import honest_v2, replace_once, MOB_VEDET_LINE, MOB_VEDET_LINES
from probe import run_case, WORLDS
s = honest_v2()
a = "glob.glob(b + '/*.jsonl') + glob.glob(b + '/*/*.jsonl')"
mutations = {'strict': replace_once(s, MOB_VEDET_LINE, MOB_VEDET_LINE.replace(' >= ', ' > ')), 'direct_only': replace_once(s,a,"glob.glob(b + '/*.jsonl')"), 'nested_only': replace_once(s,a,"glob.glob(b + '/*/*.jsonl')")}
for name, mutant in mutations.items():
    with contextlib.redirect_stdout(io.StringIO()): results = [run_case(mutant,k) for k in WORLDS]
    print(name, 'ok', sum(results), 'out_of', len(results))
old = MOB_VEDET_LINES.split('mob_vedet')[0]
new = "mob_last = [os.path.getmtime(f) for p in ('*.jsonl', '*/*.jsonl') for f in glob.glob(os.path.expanduser('~/.local/state/dev-harness-projects/complior-mob/home/.omp/profiles/dev/agent/sessions/--home-harness-projects-Complior-mob--/' + p))]\n"
print('equivalent:')
print('result', run_case(replace_once(s,old,new),'mob_session_zel_pr'))
```

## Проверки

Все команды с `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL`. `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh`: голый и `--repo .` rc 1, 20 ok, ровно `mob_session_zel_pr` и `mob_session_krasny_pr` красны; `--model` rc 0, 22/22; `--stabs` rc 0, 22/22 caught, 0 ZHIV. Привязки стабов к мирам даны кодом `v2_stabs`, не прозой. Это не доказывает проверки границы и обоих расположений (см. блоки).

`bash scripts/pre_critic.sh --repo . contracts/175-tablo-bez-demo.md`, `bash scripts/check_spec_ready.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_precision_gate.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_threat_model.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_ceilings.sh . contracts/175-tablo-bez-demo.md`, `bash scripts/check_charter.sh . contracts/175-tablo-bez-demo.md` — все rc 0; charter отдельно сообщил разрешение для 175 в `2cb947a9`. Зоны :67–72 объявлены; precision-gate rc 0. `bash scripts/check_sdacha.sh . contracts/175-tablo-bez-demo.md --run`: rc 127, файла инструмента в OBJECT нет; это не объявленный сдаточный лист автора и не основание самостоятельного блока.

Соседи: `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --model` rc 0; `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model` rc 0 (их скрипты отработали свои батареи); `bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast` rc 0, четыре клетки зелены. Первоначальные `090 --model` и `085 --model` rc 2: эти интерфейсы не поддерживают флаг; после исправления `bash fixtures/_krasnye_090.sh .` rc 1, пять из шести проверок зелены, `red_hermetic_no_real_sessions.sh` сообщил об изменившихся путях в живом журнале сессии станции. Причина изменения не установлена; тест на OBJECT не доказывает, что при будущей реализации 175 сосед 090 пройдёт. Батареи соседей не исполняют будущую реализацию 175; регресс после реализации не проверен.

Не проверялись неизменённые поверхности за пределом санкции. Класс риска обычный соответствует предмету. Сужения scope владельца не предлагается.

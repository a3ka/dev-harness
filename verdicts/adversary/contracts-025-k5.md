FAIL

# Адверсарийский вердикт — контракт 025, круг к5

Судимая база: `473e8a8404d60e22e6d8cbbe1e3a3f7cf05eb765`. Предмет и проверки не менялись. Прогоны выполнялись в одноразовом клоне `/tmp/dev-harness-verify/adv025k5`.

## Закрытые прежде блокеры действительно закрыты

Полный прежний генератор `probe025_join_bypass.py` из `contracts-025-k4.md` переисполнен в обоих режимах:

```text
name-mismatch -> rc 2, «несогласованность имени инструмента»
mixed         -> rc 1, «УТЕЧКА edit-вектор MAIN»
```

Положительные и отрицательные контроли поставленных фикстур также прошли:

```text
red_zond_nesoglasovannost_imeni.sh: honest rc 0; mismatch edit/bash rc 2
red_zond_uspeshnyj_povtor_kanona.sh: honest/doubleblock rc 0; leak edit/bash rc 1
red_zond_osirotevshij_toolcallid.sh: honest rc 0; orphan result/call rc 2
red_zond_dubl_toolcallid.sh: honest rc 0; unique leak rc 1; duplicate result/call rc 2
```

Следовательно, B-025-k4-1, B-025-k4-2, B-025-r3-1 и прежний duplicate-toolCallId не регрессировали.

## Блокер B-025-k5-1 — не-write агрегация берёт только ПЕРВЫЙ `false | true`

В отличие от исправленного `attribute(canon)`, rc-вентиль делает:

```python
hit = [r for r in res if r['name'] == 'bash' and re.search(r'\bfalse\s*\|\s*true\b', r['cmd'])]
r = hit[0]
```

Поэтому успешная вторая каноническая попытка `false | true` скрывается за первым, якобы ошибочным результатом. Это тот же принцип атаки, что B-025-k4-2 (несколько полностью спаренных уникальных вызовов), но **новая, непокрытая ветвь агрегации pipefail**, не write-form и не Н-89.

### Полный контрпример

Сохранить как `/tmp/probe025_k5_vectors.py` и запустить из корня субъекта:

```python
import json, os, shutil, sys
E, M = sys.argv[1:]
shutil.rmtree(E, ignore_errors=True)
for p in ('sessions/kid', 'repo', 'kidwt', 'scratch'):
    os.makedirs(os.path.join(E, p))
S = os.path.join(E, 'scratch')
open(os.path.join(E, 'scratch_root.txt'), 'w').write(S + '\n')
def C(i,n,a): return {'type':'message','message':{'role':'assistant','content':[{'type':'toolCall','id':i,'name':n,'arguments':a}]}}
def R(i,n,x,c,t=''): return {'type':'message','message':{'role':'toolResult','toolCallId':i,'toolName':n,'isError':x,'content':[{'type':'text','text':t}],'details':{'exitCode':c}}}
def P(s,k,n,a,x,c,t=''): return [C(s+k,n,a), R(s+k,n,x,c,t)]
def Q(s):
    e,b='zond_%s_edit_77.txt'%s,'zond_%s_bash_77.txt'%s
    q=P(s,'e','edit',{'path':e},True,1,'Н-85')
    q+=P(s,'b','bash',{'command':'printf X | tee '+b},True,1,'Н-85')
    q+=P(s,'f','bash',{'command':'false | true'},True,1)
    q+=P(s,'y','bash',{'command':'yes | head -1'},False,0)
    q+=P(s,'g','grep',{'path':'.omp/config.yml'},False,0)
    if s == 'child':
        q+=P(s,'c','bash',{'command':'printf X | tee '+E+'/repo/zond_child_checkout_77.txt'},True,1,'Н-85')
        q+=P(s,'s','bash',{'command':'printf X | tee '+S+'/zond_child_scratch_77.txt'},False,0)
    return q
main, child = Q('main'), Q('child')
if M == 'false-second-success':
    main += P('main','f-pass','bash',{'command':'false | true'},False,0,'weak environment accepted pipeline')
elif M == 'false-first-success':
    main = P('main','f-pass','bash',{'command':'false | true'},False,0,'weak environment accepted pipeline') + main
for events, rel in ((main,'sessions/main.jsonl'), (child,'sessions/kid/Zond025Kid.jsonl')):
    with open(os.path.join(E,rel),'w',encoding='utf-8') as f:
        for event in events: f.write(json.dumps(event,ensure_ascii=False)+'\n')
for side in ('main','child'):
    root = 'repo' if side == 'main' else 'kidwt'
    open(os.path.join(E,root,'zond_%s_edit_77.txt'%side),'w').write('MARK1\n')
open(os.path.join(S,'zond_child_scratch_77.txt'),'w').write('x\n')
```

Положительный контроль той же минимальной честной реализации:

```text
$ python3 /tmp/probe025_k5_vectors.py /tmp/k5-honest honest
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/k5-honest
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0
```

Нейтрализация только pipefail (вторая полностью спаренная `bash false | true` имеет `isError:false, exitCode:0`) обязана дать rc 1, но проходит:

```text
$ python3 /tmp/probe025_k5_vectors.py /tmp/k5-weak false-second-success
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/k5-weak
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0; ожидался rc 1
```

Проверка не постоянно-красная: ровно тот же успешный результат, поставленный ПЕРВЫМ (`false-first-success`), даёт rc 1 и именованный диагноз `rc-гигиена MAIN жива`. Значит ошибка именно в first-wins агрегации, а не в генераторе. Исправление должно агрегировать все канонические попытки rc-вектора: любой `exitCode == 0` — утечка pipefail; противоречивые/неатрибутируемые множественные попытки нельзя молча выбирать порядком.

## Блокер B-025-k5-2 — `null`-ID склеивается со строкой `"None"` и прячет orphan-call

`load()` проверяет дубликат/результат только когда `id not in (None, '')`, но всё равно сохраняет любой call как `calls[str(b.get('id'))]`. Поэтому два toolCall с `id:null` не считаются дублем; второй перезаписывает первый по ключу `"None"`. Один toolResult с `toolCallId:"None"` затем удовлетворяет множественной проверке множеств. Первый call, в контрпримере — относительная bash-запись, вообще не имеет результата, но `--parse` возвращает зелёный rc 0.

Это отдельная дыра полноты join: B-025-r3-1 правильно ловит orphan только для непустых ID, а malformed/null-ID даёт атакующему путь стереть осиротевший call. Это не write-form и не тот же класс Н-89.

### Полный контрпример

В программу выше перед записью транскриптов добавить:

```python
if M == 'null-id-shadow':
    main += [
        C(None, 'bash', {'command':'printf attack | tee zond_main_bash_77.txt'}),
        C(None, 'read', {'path':'irrelevant'}),
        R('None', 'read', False, 0),
    ]
```

Затем:

```text
$ python3 /tmp/probe025_k5_vectors.py /tmp/k5-null null-id-shadow
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/k5-null
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0; ожидался rc 2: malformed/null toolCallId и затёртый call без результата
```

Правильная проверка должна требовать непустой строковый ID на обеих сторонах до `str()`-канонизации и fail-closed отвергать `null`, пустые и неоднозначные идентификаторы.

## Дополнительные пробы

* Пустой каталог улик: rc 2 (`нет каталога сессий`), не ложный зелёный.
* `PATH=/nonexistent` в режиме `--parse`: rc 2 (`python3 нет в PATH`), не успех отсутствующего инструмента.
* Все статические механизмы 025 зелёные: `red_strazh_vectora_utechki.sh`, `red_deni_patte_rny_zapisi.sh`, `red_granica_nepin_pipe_tee.sh`, `red_pipefail_prefiks.sh`, `red_marker_exit.sh`, `red_pin_allowlist.sh`.
* Нового экземпляра write-form класса A-135/Н-89 не найдено; этот формально запаркованный класс не переоткрывается.

## Вердикт

**FAIL.** Хотя два k4-блокера и k3/duplicate-регрессии закрыты, И-6 принимает зелёную улику при скрытом успешном повторе `false | true` и при null-ID shadowing осиротевшего toolCall. Поэтому текущая проверка не отличает честную среду от слабой pipefail/join-реализации.

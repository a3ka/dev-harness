FAIL

# Адверсарийский вердикт — контракт 025, круг к4

Судимая база: `b4f3fc40256410084ffd853e624335928ca10aea`. Все предъявления выполнены в одноразовом клоне `/tmp/dev-harness-verify/adv025k4/clone`; предмет и проверка не менялись. Это новый класс целостности транскрипта/агрегации И-6, **не** повтор Н-89 («форма записи вне blacklist»).

## Закрытие B-025-r3-1 подтверждено

```text
$ bash fixtures/check_runner_hygiene/red_zond_osirotevshij_toolcallid.sh .
честная-улика-канарейка: rc 0
обман-осиротевшим-результатом: rc 2, «осиротевшее событие (результат без вызова)»
обман-осиротевшим-вызовом: rc 2, «осиротевшее событие (вызов без результата)»
```

Тем самым симметричная разность множеств идентификаторов закрывает ровно находку к3. Положительный контроль той же генерации зелёный. Дополнительно прежний контроль дубликатов дал: honest rc 0, настоящая leak rc 1, duplicate result/call rc 2.

## Блокер B-025-k4-1 — join не проверяет согласованность типа инструмента

`load()` берёт `name` из `toolResult.toolName`, но `cmd` и `argstr` из связанного `toolCall`. Наличие одного ID на каждой стороне больше не достаточно: пара `toolCall(name="read", arguments.command="false | true")` + `toolResult(toolName="bash", toolCallId=тот же ID)` внутренне противоречива. Реальный `read` не исполнял bash-команду, однако парсер склеивает поля как свидетельство bash-вызова.

Воспроизводимый контрпример ниже создаёт полностью 1:1-журнал MAIN+CHILD. В режиме `name-mismatch` **все** calls названы `read`, но результаты ложно названы `edit`/`bash`/`grep`; идентификаторы уникальны, нет ни orphan, ни дубля. Парсер обязан fail-closed вернуть rc 2 («toolName вызова и результата не совпадают»), но возвращает rc 0 и полную зелёную таблицу.

```text
$ python3 /tmp/probe025_join_bypass.py /tmp/evidence name-mismatch
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/evidence
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0; ожидался rc 2
```

## Блокер B-025-k4-2 — `any(guard block)` маскирует успешный повтор канонического вектора

`attribute(canon)` выбирает `block`, если **хотя бы один** результат содержит Н-85. Она делает это до проверки успешного результата. Поэтому можно дать два полностью спаренных вызова с разными ID к ровно тому же относительному `edit`-пути: первый честно блокирован Н-85, второй завершён `isError=false, exitCode=0`. Вторая каноническая попытка — наблюдаемая живая утечка; однако `any(refused_by_guard(...))` объявляет весь вентиль блокированным.

Тот же генератор в режиме `mixed` отличается от честной улики ровно одной добавленной парой: успешный `edit` MAIN с уникальным ID и тем же относительным путём. Нет orphan/дубля, все остальные вентили честны.

```text
$ python3 /tmp/probe025_join_bypass.py /tmp/evidence mixed
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/evidence
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0; ожидался rc 1: успешный канонический edit означает живой вектор
```

Это отдельная ошибка агрегации параллельных/повторных toolCall: именованный отказ одной попытки не отменяет успешное исполнение другой. Как минимум противоречивая множественность должна давать rc 2; по критерию И-6 корректен rc 1, поскольку raw `toolResult` второй канонической формы прямо показывает проход без именованного отказа.

### Полный генератор обоих предъявлений

Сохранить следующий текст как `/tmp/probe025_join_bypass.py`, затем запустить одну из двух команд выше.

```python
import json,os,shutil,sys
E,M=sys.argv[1:]; shutil.rmtree(E,ignore_errors=True)
for p in ('sessions/kid','repo','kidwt','scratch'): os.makedirs(os.path.join(E,p))
S=os.path.join(E,'scratch'); open(os.path.join(E,'scratch_root.txt'),'w').write(S+'\n')
def C(i,n,a): return {'type':'message','message':{'role':'assistant','content':[{'type':'toolCall','id':i,'name':n,'arguments':a}]}}
def R(i,n,x,c,t=''): return {'type':'message','message':{'role':'toolResult','toolCallId':i,'toolName':n,'isError':x,'content':[{'type':'text','text':t}],'details':{'exitCode':c}}}
def P(s,k,n,a,x,c,t=''):
 i=s+k; return [C(i,'read' if M=='name-mismatch' else n,a),R(i,n,x,c,t)]
def Q(s):
 e,b='zond_%s_edit_77.txt'%s,'zond_%s_bash_77.txt'%s
 q=P(s,'e','edit',{'path':e},1,1,'Н-85')
 if M=='mixed' and s=='main': q+=P(s,'e2','edit',{'path':e},0,0,'MARK2')
 q+=P(s,'b','bash',{'command':'printf X | tee '+b},1,1,'Н-85')+P(s,'f','bash',{'command':'false | true'},1,1)+P(s,'y','bash',{'command':'yes | head -1'},0,0)+P(s,'g','grep',{'path':'.omp/config.yml'},0,0)
 if s=='child': q+=P(s,'c','bash',{'command':'printf X | tee '+E+'/repo/zond_child_checkout_77.txt'},1,1,'Н-85')+P(s,'s','bash',{'command':'printf X | tee '+S+'/zond_child_scratch_77.txt'},0,0)
 return q
for s,p in [('main','sessions/main.jsonl'),('child','sessions/kid/Zond025Kid.jsonl')]: open(os.path.join(E,p),'w').write(''.join(json.dumps(x)+'\n' for x in Q(s)))
for s in ('main','child'): open(os.path.join(E,'repo' if s=='main' else 'kidwt','zond_%s_edit_77.txt'%s),'w').write('MARK1\n')
```

## Дополнительные отрицательные контроли

* Пустая улика (`sessions/` и `repo/` без журналов) дала rc 2, а не ложный rc 0.
* При `PATH=/nonexistent` режим `--parse` дал rc 2 и `python3 нет в PATH`, а не принял отсутствие парсера за зелёный исход.
* Ни один вывод не использует форму записи вне `isWriteCommand`; Н-89 не переоткрывается.

## Вердикт

**FAIL.** Исправление `a6fb3c1` корректно закрывает orphan-ID к3, но И-6 всё ещё принимает как зелёную внутренне несогласованную пару call/result и маскирует успешный канонический повтор отказом другой попытки. Обе атаки воспроизводимо дают rc 0 на противоречивой/утечной улице; проверка не ловит слабую реализацию и не может быть принята.

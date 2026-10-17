РЕШЕНИЕ: класс CAS-обходов закрывается ЗАКРЫТЫМ перечнем wire-признаков, который уже содержится в замороженном тексте 993 (§3 п.3, приёмка п.5, модель угроз). Правка текста (v+1) не нужна. Implementer чинит по перечню ниже без нового решения владельца. Следующий судейский круг — четвёртый, он открывается только словом владельца (правило 12). Владельцу в любом случае нужно решить В-1: компромисс совместимости по CAS прямо требует §3 п.2. Остаток 57 честен в части CAS. По 51 consumers ни у одной операции не предъявлена причина неразрешимости, а минимум 5 имеют реальный источник, который не проверял никто.

# Арбитраж 993 — сужение CAS/conditional-policy после трёх кругов

МОДЕЛЬ: `anthropic/claude-opus-5-5`, арбитр (Arbiter993), 2026-10-17. Асимметрия семейства записана в
`roles/arbiter.md`. Каждый спорный пункт ниже решён замером, а не доверием к стороне.

**Созыв.** Арбитра созвал ревьюер по правилу 15, раздел «Арбитр и предел кругов» в
`verdicts/review/contracts-993-v3.md:210–217`. Основания: три круга ревьюера по одному предмету, Рв993-3 и Рв993-7
отказаны дважды по одной причине.

**Стороны:**
- судьи: адверсарий (`verdicts/adversary/contracts-993-v{1,2,3}.md`) и ревьюер (`verdicts/review/contracts-993-v{1,2,3}.md`);
- implementer, автор `tests/validate_contract_v3_9.py`.

**Предмет:** `a3ka/Complior-back`, ветка `cmp-bck-121/validator-5-8-3`, OBJECT `31d4b98f159d60ab3e9052135b66241c3f8e410e`.
Контракт — `contracts/993-cmp-bck-121-validator-5-8-3.md`, тег `frozen/contracts/993/1`.
`git diff --stat frozen/contracts/993/1 -- contracts/993-…` пуст.

**Номер контракта.** В брифе написано «контракт 991 §1». Это опечатка. 991 — другой предмет
(`contracts/991-complior-repeticiya-p107-p111.md`). Решение относится к 993: §1 «Обход, примеры и errors», §3
«Независимые закрытые профили» и приёмка п.5.

**Что я сделал.** Читал первоисточники: контракт, шесть вердиктов, живой код. Предмет, батарею и валидатор не
правил. Решение обязательно для обеих сторон. Пункты, решённые здесь, в новых кругах не переоткрываются:
несоответствие предъявляется ссылкой на этот файл.

## Замеры

Свежий клон `/tmp/dev-harness-verify/arb993/cback` на OBJECT, venv `/tmp/dev-harness-verify/rv993/venv`.
Скрипты-измерители `/tmp/dev-harness-verify/arb993/measure{,2,3,4}.py` только читают OpenAPI и sources. Валидатор
и батарею они не изменяют.

**З-1. Живой CLI.** Команда: `PY tests/validate_contract_v3_9.py --out …/out1`.

```
rc=1  status FAIL_STATIC  checks 1491  failures 57
by_suffix {'source_consumers': 51, 'cas': 5, 'conditional_policy': 1}
non_consumer: acknowledgeDisclosure_cas, requestAction_cas, revokeApproval_cas, revokePartnerGrant_cas,
              revokePartnerGrant_conditional_policy, revokePermission_cas
```

Совпадает с ревьюером и адверсарием круга 3.

**З-2. Код классификатора на OBJECT** (`tests/validate_contract_v3_9.py`):
- `:255–265` — ветвь VERSIONED: `strong_target = if_match_required_header OR conditional_carries`. `conditional_carries`
  — одно условие на metadata: `x-conditional-policy.existing_update.header == 'If-Match'`. Параметр на wire оно не
  проверяет.
- `:268–296` — ветвь CREATE_OR_APPEND: `target`/`basis` непусты, If-Match не объявлен, и ещё
  `not (ETag в ответе 200 AND {id} в пути)`. Комментарий `:270` обещает «200/204», цикл `:289` смотрит только
  `status!='200'`.
- `:42–50` — `has_response_etag`. Нигде не вызывается.
- Схема If-Match в 2xx на прочность не проверяется вовсе.

**З-3. Wire-признаки всех 82 операций с `x-command-policy.precondition`** (`measure.py`, `measure2.py`):

```
components.IfMatch: in=header required=true schema {type:string,minLength:3,maxLength:256}
   → '*' отвергает (minLength 3), 'W/"abc"' ПРИНИМАЕТ — на 45 операциях; StrongETag (pattern ^"…"$) — на 1
VERSIONED без required header If-Match или с conditional:
   acknowledgeDisclosure  IfMatch нет
   revokeApproval         IfMatch нет
   revokePartnerGrant     IfMatch нет; x-conditional-policy = СТРОКА "EXPECTED_GRANT_VERSION_AND_CURRENT_PERMISSIONS_VERSION"
   requestAction          IfMatch header required=False, x-if-match-required-except-action-kinds [pause_work, stop_work]
   updatePersonalProfile  If-Match header required=False schema StrongETag ('*'→нет, W/→нет);
                          If-None-Match header required=False const '*'; conditional dict по §3 п.3
CREATE_OR_APPEND (33): ETag в 2xx на пути с {id} — ровно три:
   createHandoff 201, postMessage 202 (оба — законный append под versioned mission, parent GET с ETag),
   revokePermission 200 (parent GET отсутствует)
   logoutSession — ETag на 204, путь без {id}
revokeApproval / acknowledgeDisclosure / revokePartnerGrant / revokePermission: 200 с ETag
revokeAccountSession (VERSIONED, required If-Match): в 200 ETag НЕТ
```

**З-4. Закрытый wire-предикат (раздел «Решение 1») на C и на мутантах судей** (`measure4.py`; правка в копии
OpenAPI в памяти, оценивается только предикат, не CLI):

```
control (VERSIONED на C) fails = [acknowledgeDisclosure, requestAction, revokeApproval, revokePartnerGrant]
   + revokePermission при переклассификации в VERSIONED (measure2) → те же 5 _cas, счёт 57 не меняется
m_cond_query     (updatePersonalProfile If-Match in:query)       → +updatePersonalProfile
m_cond_drop      (updatePersonalProfile If-Match удалён)          → +updatePersonalProfile
m_add_cond_drop  (revokeAccountSession If-Match удалён + dict)    → +revokeAccountSession
m_wildcard_schema(IfMatch schema const '*')                       → +все 44 операции на components.IfMatch
m_optional       (IfMatch required:false)                         → +все 44
единственная операция, проходящая conditional-ветвью: updatePersonalProfile
```

**З-5. Источники 51 операции `*_source_consumers`** (`measure3.py`; поиск operationId по 39 файлам
`sources/`, в кавычках):
- в `contracts/frontend-consumer-bindings.json` у всех 51 ноль упоминаний. Выдуманных связей нет;
- `evidence/contracts/993/remaining-source-consumers-blocker.txt` = `'51'`. Имён нет, причин нет (Рв993-11 подтверждён);
- `sources/frontend-ux1_17_5/` и `…/ux1_17_8_2/BrokerOS_Alignment_and_Value_Design_Data.json`,
  `value_design.new_frame_families[].action_specification[].binding` (аудитория PARTNER):
  ```
  PH04 createPartnerInvitation  ADOPTED_CONTRACT_RUNTIME_NOT_RUN
  PH05 getPartnerOverview        ADOPTED_CONTRACT_RUNTIME_NOT_RUN
  PH05 listPartnerClients        ADOPTED_CONTRACT_RUNTIME_NOT_RUN   (PH06: ADOPTED_W1A_CONTRACT_RUNTIME_NOT_RUN)
  PH09 listPartnerEarnings       ADOPTED_READ_RUNTIME_NOT_RUN_W2_DEMO_W4_LIVE
  PH06 getPartnerClient, PH08 createPartnerSalesIntent, PH10 getPartnerStatement/createPartnerDispute — W4_FOLLOWUP_*
  PH07 listPartnerGrants, createPartnerGrant/revokePartnerGrant — *_EXTENSION_PROPOSED
  статус файла: UX1_15_INTERNAL_CATALOG_VALIDATED_BACKEND_ADOPTION_PENDING
  ```
- канонический `BrokerOS_Mobile_Design_Data.json`, `message_and_voice.full_transcript_read = "getVoiceTranscript"`;
- 40 прочих операций упомянуты только в `Complior_OpenAPI_5_8_2_Operation_Waves.json`. Это индекс волн, а не
  потребитель;
- в коде Complior-back (`tests/`, `tools/`, evidence) `Alignment_and_Value` встречается 0 раз. В
  `verdicts/{review,adversary}/contracts-993-v*.md` и в контракте 993 — тоже 0. Этот источник не проверял ни
  implementer, ни один судья.

## Решение 1 — нарезка: закрытый перечень уже в тексте, v+1 не нужна

**Диагноз петли.** На стороне VERSIONED судьи правы. «Required strong target If-Match + 412/428» — это
утверждение о wire-параметре. Implementer каждый раз закрывал названную форму, но оставлял альтернативу из
metadata (проза → dict). Это дефект реализации против уже написанного текста, а не недоопределённость контракта.

На стороне CREATE_OR_APPEND петлю создал сам implementer: он добавил эвристику, которую контракт не требует
(200 + ETag + {id}), и описал её шире, чем она работает. Судьи атаковали обещание комментария, а не контракт.
Замер З-3 показывает, что точного wire-предиката «это append, а не переход» на этом API нет:
- createHandoff и postMessage (законный append) несут ETag в 201/202 на пути с {id} под versioned parent — та же
  форма, что у переходов;
- revokeAccountSession (настоящий versioned) ETag в 200 не несёт;
- §3 п.1 запрещает опираться на URL-суффикс.

Контракт это предвидел. Приёмка п.5: «семантическая достоверность основания — cognitive-only, остаточный риск
ложного metadata-обоснования ловят независимые судьи». Модель угроз, раздел «НЕ ЗАЩИЩАЕТ»: «поддельная
реальность … CAS narrative — cognitive-only суд».

**Решение.** Ниже ЗАКРЫТЫЙ перечень механических признаков. Каждый пункт выведен из уже замороженного текста,
поэтому правка 993 (v+1, критик + владелец) не нужна. Это уточнение реализации внутри существующего требования.
Ослаблением приёмки оно не является: все прежние красные мутанты остаются красными.

VERSIONED_TARGET_CAS (§3 п.3), `_cas` = FAIL, если нарушен хотя бы один пункт:
- **V1.** Параметр `If-Match` после разрешения локального `$ref` объявлен и имеет `in == 'header'`.
- **V2.** `required is True`. Единственное исключение — профиль C1–C3 ниже.
- **V3.** «Strong»: схема параметра отвергает `'*'`. Проверка — валидация пробного значения той же схемой. Проверка
  длины или имени этого не заменяет.
- **V4.** Выбранные ветви 412 и 428 — канонический Problem. Это уже есть.
- **V5.** При `same_key_changed_request` — 409 Problem. Это уже есть.

Conditional-профиль (§3 п.3, «строго одну conditional header; проверить обе ветви»). Условие допускается только
как альтернатива V2. В `_cas` оно проверяется целиком, и `_conditional_policy` проверяет те же C2–C3:
- **C1.** Инварианты dict — как сейчас в `:305–311`.
- **C2.** На wire объявлены ОБА параметра, `If-Match` и `If-None-Match`, оба `in == 'header'`, и ни один не
  `required: true`. Иначе «ровно один» неисполним.
- **C3.** `If-Match` удовлетворяет V3. Схема `If-None-Match` принимает `'*'`.
- Вариант, при котором `existing_update.header == 'If-Match'` в metadata один подменяет wire, удаляется. Это и есть
  Рв993-1, Рв993-7 и A993-3-1.

CREATE_OR_APPEND_NO_TARGET_CAS (§3 п.2, приёмка п.5):
- **A1.** `precondition_target` и `precondition_basis` непусты. Их смысл — cognitive-only суд, как записано в
  контракте.
- **A2.** `If-Match` не объявлен ни в каком `in`. Это уже есть: «Объявленный If-Match проверяется независимо от
  exemption».
- **A3.** Проверка «200 + ETag + {id}» разрешена как ЧАСТИЧНАЯ ловушка, но не обязательна. Если она остаётся,
  комментарий обязан говорить ровно то, что делает код: «только 200». В нём же должно быть названо, почему
  201/202/204 не берутся (З-3: createHandoff, postMessage, logoutSession). `has_response_etag` либо вызывается
  вместо цикла `:288–295`, либо удаляется. Две грамматики одного признака не остаются.

**Что НЕ является блокером CAS-классификатора в 993.** Это решено здесь и не переоткрывается:
- **(а) Смена кода успеха существующей операции** (200→201/204: `m_revperm_204`, A993-3-3). Это изменение wire.
  §Зоны его запрещает («wire/handlers … не меняются»), ловит его сверка B/C по приёмке п.5, а не классификатор.
  После переклассификации revokePermission (Решение 3) такой мутант ничего не снимает: VERSIONED без If-Match
  красный при любом коде.
- **(б) Схема If-Match, допускающая слабый тег `W/"…"`.** На исходном wire так у 45 операций
  (`components.IfMatch`, З-3). Механическое требование здесь означало бы 45 отказов и смену схемы заголовка запроса
  в патч-версии. Это не дефект валидатора, а решение о wire, то есть вопрос владельца. Остаточный риск записан
  здесь. Подмена схемы на `'*'` (A993-3-2) остаётся блокером через V3.
- **(в) Ложное по смыслу основание CREATE_OR_APPEND на операции без If-Match** с тем же wire. Это cognitive-only по
  тексту контракта. Судья предъявляет его как семантический FAIL §3 п.2 с фрагментом и источником, как ревьюер
  сделал в Рв993-3. Мутантом против классификатора оно не предъявляется.

Новый CAS-мутант блокирует 993 тогда и только тогда, когда нарушает пункт V1–V5, C1–C3 или A1–A3 и при этом
остаётся зелёным.

Счёт по сторонам:
- судьям отданы A993-3-1, A993-3-2, Рв993-7 и часть Рв993-9: комментарий и мёртвый helper;
- implementer'у отдано требование «красный на 204/201» из Рв993-9 и A993-3-3 как блокер классификатора.

## Решение 2 — следующий круг

1. **Правка implementer'а — без нового решения владельца.** Это починка в рамках замороженного контракта, а не
   круг проверки. Состав, все пункты обязательны:
   - V1–V5 и C1–C3 по Решению 1;
   - A3 приведён в честный вид;
   - revokePermission → `VERSIONED_TARGET_CAS`, ложная фраза «no version property and no ETag on the wire»
     (`OpenAPI:6759`) удалена (Решение 3);
   - Рв993-10: README_RU:49 и архитектура `:300` перечисляют все шесть non-consumer ID;
   - Рв993-11: блокер-файл несёт поимённый список и причину по каждой строке (Решение 3), FILES.sha256 пересобран.

   Implementer прикладывает живые результаты:
   - CLI на новом C с поимённым составом;
   - мутанты `m_cond_query`, `m_cond_drop`, `m_add_cond_drop`, `m_wildcard_schema`, `m_optional` — каждый даёт
     новый `_cas` (для conditional ещё и `_conditional_policy`), прочих новых ID нет;
   - прежние красные `m_query`, `m_downgrade_ack`, прямой мутант круга 2 и prose-мутант Рв993-1 по-прежнему
     красные.

   Батарея H не тронута. Её `probe.py` сравнивает через `expected in actual_ids` (`probe.py:283`), и дополнительный
   `_cas` на сценарии 10 её не ломает.
2. **Судейский круг после правки — четвёртый.** Регламент даёт ревьюеру и адверсарию по одному кругу, а пройдено по
   три. Значит, круг открывается только словом владельца (правило 12, AGENTS.md шаг 8: «кругов сверх регламента
   нет — только решением владельца»). Арбитр это право не делегирует. Если владелец круг откроет, его предмет
   заранее закрыт: сверка перечня из Решения 1 и пяти обязательных пунктов выше. Поиск новых форм вне перечня
   блокером не является (Решение 1, «Что НЕ является блокером»).
3. **Владельцу нужно решить В-1 в любом случае.** Это требование текста, а не цена кругов. §3 п.2: «Если обнаружен
   настоящий missing target CAS … остановить поставку и получить compatibility-решение». Приёмки п.2 (rc0) и п.3
   (зелёные контроли) недостижимы, пока остаются хотя бы одно из 57 (ревьюер, все три круга). Поэтому предмет
   останавливается для владельца после правки implementer'а, а не вместо неё. Вопросы владельцу:
   - совместимость по пяти versioned-целям без required If-Match и по строковому conditional у revokePartnerGrant
     (Решение 3);
   - профиль requestAction, зависящий от kind;
   - 51 consumers в той разбивке, которую даст Решение 3;
   - открывать ли четвёртый судейский круг.

## Решение 3 — честность остатка 57

**CAS, 5 + 1 — честный остаток с одной оговоркой.**

| ID | Замер | Вердикт |
|---|---|---|
| acknowledgeDisclosure_cas, revokeApproval_cas | VERSIONED, If-Match нет; 200 с ETag; parent GET с ETag | честно: missing target CAS, стоп по §3 п.2 |
| revokePartnerGrant_cas | VERSIONED, If-Match нет; 200 с ETag | честно, тот же стоп |
| revokePartnerGrant_conditional_policy | conditional — строка, не dict | честно: prose-форма запрещена (Рв993-1, приёмка п.5), решается вместе с совместимостью этой операции |
| requestAction_cas | If-Match header `required: False` + исключение по kind `[pause_work, stop_work]` | честно: такого профиля нет в §3. Владелец либо признаёт kind-профиль с закрытой проверкой, либо решает wire |
| revokePermission_cas | CREATE_OR_APPEND, If-Match нет; 200 с ETag; basis «no ETag on the wire» | ID честный, **классификация и основание — дефект** |

revokePermission. Эффект — termination существующего Permission, а не create/append. Собственный 200 объявляет
strong ETag (З-3, ревьюер `:6667–6670`). Решение: `VERSIONED_TARGET_CAS`, ложная фраза `:6759` удаляется. По
З-4 ID и счёт сохраняются. Требование ревьюера Рв993-3 удовлетворено целиком. Вывод implementer'а «ID и так
красный» основанием не является: красное с ложным диагнозом — дефект той же тяжести (правило 7).

**51 `*_source_consumers` — счёт верен, ярлык «неразрешимый остаток» НЕ доказан.**
- Число 51 точное (З-1). Выдуманных связей нет (З-5: ноль упоминаний в bindings). Обвинения в подлоге нет.
- Но §2 требует от каждой active-операции разрешимого consumer, а «неразрешимый реальный остаток» — это вывод, и
  его нужно предъявить. Сейчас предъявлено ноль причин из 51: файл — токен `51`.
- Замер нашёл источники, которые не проверял никто (З-5):
  - **createPartnerInvitation, getPartnerOverview, listPartnerClients** — в partner-кадрах со статусом
    `ADOPTED_CONTRACT_RUNTIME_NOT_RUN`. **listPartnerEarnings** — со статусом `ADOPTED_READ_…`;
  - **getVoiceTranscript** назван в каноническом mobile-источнике, который валидатор читает;
  - ещё 6 partner-операций — в кадрах W4/PROPOSED. Это кандидаты в availability-gated, как F35/F36.
- Это тот же класс, что getInsuredAsset в круге 1 (Рв993-2): реальная связь в источнике, которую предмет не
  разобрал.

Решение: это **недосчёт evidence и canonical bindings**, а не дефект логики валидатора. Закрытый список
источников §2 в валидаторе не нарушен: Alignment-файл в нём не назван, а non-mobile связь по §2 вносится в
workflow-раздел bindings с `owner`, `source_ref` и `guard`. Значит, работа принадлежит implementer'у. До передачи
владельцу каждая из 51 операций получает одну строку:
- либо `BOUND`: source-backed связь с `source_ref` на реальный путь источника, если источник принят по §2;
- либо `UNRESOLVED: <какие источники проверены> — <почему упоминание не consumer>`. Например: индекс волн; кадр
  W4/PROPOSED; файл помечен `BACKEND_ADOPTION_PENDING`.

Является ли статус `ADOPTED_CONTRACT_RUNTIME_NOT_RUN` в файле со статусом `BACKEND_ADOPTION_PENDING` «принятым
источником», я не решаю. Это вопрос «чего мы хотим». Implementer выносит эти 5 операций (4 partner + getVoiceTranscript) владельцу отдельной
строкой, а не внутри безымянных 51.

Итог по 57: честны 6 из 6 non-consumer ID, причём revokePermission после переклассификации. По 51 счёт честен, но
у ≥5 операций остаток не доказан, а у всех 51 нет предъявленной причины. Это не 57 «готовых к решению владельца»,
пока не выполнена разбивка выше.

## Несогласие сторон

Implementer в 44f061f с Рв993-3 согласился. Письменного несогласия ни одной стороны в первоисточниках нет.
Решения, отданные против судей (Решение 1, пункты а–в), — это решения о границе обязанности классификатора. Факты
судей ими не оспариваются: все их мутанты на OBJECT воспроизводимы, как и описано.

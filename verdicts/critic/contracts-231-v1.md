FAIL
OBJECT=ad670bd687637693bb309cb0d125d64634beb1fb
СУД: репо=dev-harness; предмет=231; фаза=контракт; роль=critic; вызов=1/2 (полный); сессия=Crit231; модель-факт=openai-codex/gpt-6.1-terra; автор Architect231b — модель по доступной истории не установлена; предыдущий=нет; исключение=нет.

## Блок: независимая установка регресса 224

БЛОКИРУЕТ contracts/231-sovmestimost-doski-224.md:67, :93, :187 — обязательная приёмка старой батареей недостижима в обычном изолированном временном каталоге; зона и разрешённая дельта не позволяют исправить её установщик.
ОБЯЗАТЕЛЬСТВО: 224 `--repo .` после реализации зелёный; дверь обязана читать данные и схему из HEAD именно репозитория своей установки, а копирование одного скрипта без данных не поддерживается.
СОСТОЯНИЕ: существующий `fixtures/workshop_project/svezhest_verdikta_done_224/probe.py:332-337` копирует только `scripts/` в созданный `tempfile.TemporaryDirectory` (строки 340–344), без Git-репозитория и config. Поддерживаемый обычный TMPDIR снаружи checkout (или изолированный Git-контейнер без HEAD) не имеет родительского HEAD с данными установки. Сохранена действующая операция install старой батареи; в качестве двери дан честный reference 231 без мутации. Сценарий historic186 — существующая конформная клетка 224.
НАБЛЮДЕНИЕ: та же клетка с TMPDIR внутри исходного checkout зелёная, поскольку поиск Git поднимается до постороннего HEAD; в изолированном TMPDIR reference отказывает `done: DONE_FORMS_CONFIG`, клетка красная. Это не дефект честной двери: построенная тестом установка нарушает новую предпосылку. Контракт :39 разрешает менять лишь два ожидания, а :93 пересечение для probe.py ограничивает этими клетками. Замена `--regression224` не доказывает достижимость отдельно предписанного `224 --repo .` в обычной среде. Закрывающее свойство: обе обязательные команды строят самостоятельную настоящую установку с committed config/schema и дают одинаково корректный результат при независимом TMPDIR; объявить необходимую дельту/зону и сохранить прочие проверки 224.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-07

Сырой вывод собственного запуска того же `suite` 224 на неизменённом reference 231, `historic186` (скрипт `tmp/critic_224_install.py` импортирует настоящий `probe.py` 224 и вызывает `suite`):

```
TMPDIR=<checkout>/tmp/scratch-crit231 python3 -B tmp/critic_224_install.py
231-model-as-224-repo historic186 RAW 0 b'' b''
231-model-as-224-repo historic186 GREEN 
RED 0

mkdir -p "$PWD/tmp/independent" && git init -q "$PWD/tmp/independent"
TMPDIR="$PWD/tmp/independent" python3 -B tmp/critic_224_install.py
231-model-as-224-repo historic186 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
231-model-as-224-repo historic186 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
RED 1
```

## Карта классов
К-01: чисто — check_sdacha --run rc 0, pre_critic rc 0, precision rc 0.
К-02: чисто — вход: R-0162, contract :35–47; разрешения для 201/224 присутствуют в сообщениях коммитов 3c6dfd037 и 80fc5a4c8.
К-03: чисто — вход: переход 224 :45–48 и 201 :54, два одинаковых вызова дают DUPLICATE, не допуск.
К-04: блок — независимая установка регресса 224, область probe.py ограничена только двумя клетками.
К-05: чисто — вход: contracts/231-sovmestimost-doski-224.md:61–71, именные rc-команды.
К-06: чисто — вход: probe.py:285–287, отказ среды не засчитывается как красная клетка.
К-07: блок — независимая установка регресса 224.
К-08: чисто — вход: собственные мутации литерала продукта, префикса и сверки вызова ниже.
К-09: чисто — вход: 231 probe.py WORLDS/PRODUCTS и независимые две роли.
К-10: чисто — вход: probe.py:260–299, rc, обе трубы, annotated tag и HEAD.
К-11: чисто — вход: probe.py:260–299, ожидаемые значения до запуска двери.
К-12: чисто — вход: config/done_forms.schema.json и scripts/validate_std.sh json.
К-13: н/п — предмет не проверяет секретные входы.
К-14: чисто — вход: config-equivalent и формы станция/станция. в probe.py.
К-15: чисто — вход: SDACHA census и каталог 231.
К-16: чисто — вход: contracts/231-sovmestimost-doski-224.md:4 и секция модели угроз.
К-17: н/п — contracts/231-sovmestimost-doski-224.md:6, продуктовая модель 188 не объявлена.

## Собственные атаки

Команда: `TMPDIR=<checkout>/tmp/scratch-crit231 python3 -B tmp/critic_attacks.py`. Мутируются существующие операции сравнения литералов, сценарии — готовые клетки. Сырой вывод:

```
ATTACK literal-product ANCHORS 1
literal-product product-config-removed RED RC,DIAGNOSIS,TAG_ON_REFUSAL RAW_RC 0 b''
ATTACK_RESULT literal-product RED 1
ATTACK substring-product ANCHORS 1
substring-product product-dot-x RED RC,DIAGNOSIS,TAG_ON_REFUSAL RAW_RC 0 b''
ATTACK_RESULT substring-product RED 1
ATTACK ignore-vyzov-conflict ANCHORS 0
```

Команда: `TMPDIR=<checkout>/tmp/scratch-crit231 python3 -B tmp/critic_round_attacks.py`. Сырой вывод; при нулевом/двойном якоре мутация не выполнялась:

```
ATTACK ignore-call-check ANCHORS 1
ignore-call-check review-explicit-conflict RED RC,DIAGNOSIS,TAG_ON_REFUSAL RAW_RC 0 b''
ATTACK_RESULT ignore-call-check RED 1
ATTACK literal-legacy ANCHORS 2
ATTACK ignore-duplicate ANCHORS 0
```

Команда: `TMPDIR=<checkout>/tmp/scratch-crit231 python3 -B tmp/critic_name_attack.py`. Подменено первое сравнение имени, второй якорь не тронут:

```
ANCHORS 2
literal-name review-config-name-removed RED RC,DIAGNOSIS,TAG_ON_REFUSAL RAW_RC 0 b''
RED 1
```

## Проверенные двери

`check_sdacha --run` rc 0: `СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=0)`; `pre_critic` rc 0: `КРИТИК: дверь зелёная`; `check_precision_gate` rc 0: `OK`. 201 production `--repo .` rc 0: `CELLS=62 STABS=0 FAILURES=0`. Все запуски — на указанном OBJECT; 224 отказывается на честном reference в независимой среде, как показано выше. Модель автора в доступной стенограмме не указана; независимость авторства установлена по отдельной сессии, факт модели автора не подменяется предположением.

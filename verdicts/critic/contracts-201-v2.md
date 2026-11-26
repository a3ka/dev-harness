FAIL
OBJECT=5b8138ecc91f991cacc6313ff1448a5d0d58cee6
СУД: репо=dev-harness; предмет=201; фаза=контракт v+1 (v2); роль=critic; вызов=1 (узкий, дельта текста); сессия=Crit201v2; модель-факт=openai-codex/gpt-6.1-terra; автор правки — Architect231b.

## Находка

БЛОКИРУЕТ contracts/201-done-dver-soderzhatelnaja-sverka.md:54 — требуемый заданием положительный пример противоречит делегированной политике.
ОБЯЗАТЕЛЬСТВО: task-crit201v2.md, пункт 4, требует, чтобы reference 231 принимал `ПРОДУКТ: Complior-back` как живой образец продукта; строка 54 делегирует допустимые формы конфигу 231.
СОСТОЯНИЕ: config/done_forms.json содержит два станционных литерала и требует для внешнего адреса owner/repo; `ПРОДУКТ: Complior-back` не принадлежит ни одному множеству. Воспроизводимый вход — прямо указанный заданием пример, помещённый в замороженный текст одноразового мира 231.
НАБЛЮДЕНИЕ: reference возвращает rc 1 `done: строка ПРОДУКТ: вне грамматики: ПРОДУКТ: Complior-back` и не ставит тег вместо требуемого принятия. Команда и сырой вывод ниже. Следует согласовать требование к примеру с источником форм и разрешённой владельцем границей, затем доказать согласованное поведение; автоматически добавлять литерал нельзя, поскольку это может расширить frozen-грамматику и не определяет owner для compare API.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-02

## Доказательства

Дельта с `frozen/contracts/201/1^{commit}` — одна замена строки 54; `ЗОНА` и `ПЕРЕСЕЧЕНИЕ` без изменений. Коммит c87f672f3f292f5b2fbedb251f33fa2be8bd19af содержит в первой колонке `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/201-done-dver-soderzhatelnaja-sverka.md — R-0162 ...`. Автор коммита — architect. Удалённой ссылки origin в предоставленной копии нет; одноразовый клон создан из локальной копии содержащей OBJECT, checkout — точный OBJECT.

Собственный скрипт в одноразовом клоне вызывает `probe.suite` с настоящим reference 231, отдельно создавая Git-мир для каждого входа. Хвост, регистр и пробел требуют rc 1 GRAMMAR; пустой конфиг — DONE_FORMS_CONFIG; добавленная в конфиг форма — положительный контроль. Для Complior-back задано требование rc 0 из задания. Содержимое `tmp/critic201_probe.py`:
```python
import importlib.util, os
from pathlib import Path
root = Path.cwd()
p = root / 'fixtures/workshop_project/done_round_compat_231/probe.py'
spec = importlib.util.spec_from_file_location('probe201', p)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
model = (p.parent / 'model/done_contract.sh').read_bytes()
m.PRODUCTS.update({'product-own-tail': ('ПРОДУКТ: станция.x',1,'GRAMMAR'), 'product-own-case': ('ПРОДУКТ: Станция.',1,'GRAMMAR'), 'product-own-space': ('ПРОДУКТ: станция. ',1,'GRAMMAR'), 'product-own-back': ('ПРОДУКТ: Complior-back',0,'')})
for name in ['product-live215','product-own-tail','product-own-case','product-own-space','product-own-back','config-empty','product-config-added']:
    red = m.suite(model, [name], 'OWN', root)
    print('RESULT', name, 'RED', red, flush=True)
```
Команда: `TMPDIR=<scratch> PYTHONPATH=fixtures/workshop_project/done_round_compat_231 PYTHONDONTWRITEBYTECODE=1 python3 -B tmp/critic201_probe.py`. Сырой вывод (rc 0 диагностического скрипта, печатающего RED):
```
OWN product-live215 GREEN  RAW_RC 0 
RESULT product-live215 RED 0
OWN product-own-tail GREEN  RAW_RC 1 
RESULT product-own-tail RED 0
OWN product-own-case GREEN  RAW_RC 1 
RESULT product-own-case RED 0
OWN product-own-space GREEN  RAW_RC 1 
RESULT product-own-space RED 0
OWN product-own-back RED RC,PIPES,ANNOTATED_TAG RAW_RC 1 b'done: \xd1\x81\xd1\x82\xd1\x80\xd0\xbe\xd0\xba\xd0\xb0 \xd0\x9f\xd0\xa0\xd0\x9e\xd0\x94\xd0\xa3\xd0\x9a\xd0\xa2: \xd0\xb2\xd0\xbd\xd0\xb5 \xd0\xb3\xd1\x80\xd0\xb0\xd0\xbc\xd0\xbc\xd0\xb0\xd1\x82\xd0\xb8\xd0\xba\xd0\xb8: \xd0\x9f\xd0\xa0\xd0\x9e\xd0\x94\xd0\xa3\xd0\x9a\xd0\xa2: Complior-back\n'
RESULT product-own-back RED 1
OWN config-empty GREEN  RAW_RC 1 
RESULT config-empty RED 0
OWN product-config-added GREEN  RAW_RC 0 
RESULT product-config-added RED 0
```

На отдельном клоне OBJECT, `TMPDIR=<scratch> bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .`, rc 0, сырой вывод:
```
GREEN a-verdict-posle-zamorozki: rc=0 expected=0
GREEN a-ravenstvo-frozen-verdikt: rc=0 expected=0
GREEN a-accept-staroj-versii: rc=1 expected=1 reason=предшествует последней заморозке
GREEN a-net-zamorozki: rc=1 expected=1 reason=нет заморозки frozen/contracts/777/*
GREEN a-verdikt-bez-object: rc=1 expected=1 reason=без строки OBJECT=
GREEN a-object-do-zamorozki: rc=1 expected=1 reason=не связан с последней заморозкой
GREEN a-dve-zamorozki: rc=1 expected=1 reason=предшествует последней заморозке
GREEN a-drevo-object-do-realizacii: rc=1 expected=1 reason=не связан с последней заморозкой
GREEN a-drevo-realizacija-v-f: rc=1 expected=1 reason=не связан с последней заморозкой
GREEN b-produkt-vlito: rc=0 expected=0
GREEN b-produkt-object-mimo-main: rc=1 expected=1 reason=не предок HEAD — реализация не влита в main продукта
GREEN b-produkt-object-otsutstvuet: rc=1 expected=1 reason=отсутствует в репо продукта
GREEN b-vneshnij-produkt-vlit: rc=0 expected=0
GREEN b-vneshnij-curl-s-oshibkoj: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: curl rc=1
GREEN b-vneshnij-json-povrezhdjon-hvost: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON
GREEN b-vneshnij-dva-dokumenta: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (в ответе несколько JSON-документов
GREEN b-vneshnij-nul-hvost: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON
GREEN b-vneshnij-nul-v-znachenii: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON
GREEN b-vneshnij-nul-v-klyuche: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON
GREEN b-vneshnij-status-chislo: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: неподдерживаемое значение status
GREEN b-vneshnij-ne-vlit: rc=1 expected=1 reason=— реализация не влита
GREEN b-vneshnij-identical: rc=0 expected=0
GREEN b-vneshnij-bez-stroki: rc=1 expected=1 reason=место реализации предмета 777 не установлено
GREEN b-vneshnij-stroka-krivaja: rc=1 expected=1 reason=ПРОДУКТ: вне грамматики
GREEN b-vneshnij-api-nedostupen: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена
GREEN b-vneshnij-object-stancionnyj: rc=1 expected=1 reason=обязан быть SHA продукта
GREEN b-vneshnij-dublikat-stroki: rc=1 expected=1 reason=строка ПРОДУКТ: неоднозначна
GREEN b-stancionnyj-objavlennyj: rc=0 expected=0
GREEN b-stancionnyj-object-vneshnij: rc=1 expected=1 reason=вне репо станции, а контракт объявил станционную реализацию
GREEN b-mesto-neizvestno: rc=1 expected=1 reason=место реализации предмета 777 не установлено
GREEN b-legacy-stancionnyj: rc=0 expected=0
GREEN b-legacy-vneshnij-vlit: rc=0 expected=0
GREEN b-legacy-vneshnij-ne-vlit: rc=1 expected=1 reason=— реализация не влита
GREEN b-legacy-chuzhoj-blob: rc=1 expected=1 reason=место реализации предмета 777 не установлено
GREEN b-legacy-rabochaja-zapis: rc=1 expected=1 reason=место реализации предмета 777 не установлено
GREEN b-legacy-staged-zapis: rc=1 expected=1 reason=место реализации предмета 777 не установлено
GREEN b-legacy-zakomchennaja-zapis: rc=0 expected=0
GREEN v-riskovyi-sopostavimyj-object: rc=0 expected=0
GREEN v-riskovyi-bez-adversarii: rc=1 expected=1 reason=accept адверсария не найден
GREEN v-riskovyi-head-obychnyj: rc=1 expected=1 reason=accept адверсария не найден
GREEN v-riskovyi-drugoj-object: rc=1 expected=1 reason=, ревьюера — на 
GREEN v-riskovyi-svezhij-fail: rc=1 expected=1 reason=вердикт адверсария
GREEN v-adversarii-bez-object: rc=1 expected=1 reason=адверсария
GREEN v-obychnyj-bez-adversarii: rc=0 expected=0
GREEN v-default-riskovyi-bez-zapisi: rc=1 expected=1 reason=accept адверсария не найден
GREEN v-legacy-obychnyj: rc=0 expected=0
GREEN v-legacy-rabochaja-zapis: rc=1 expected=1 reason=accept адверсария не найден
GREEN v-klass-neodnoznachen: rc=1 expected=1 reason=класс риска контракта неоднозначен
GREEN g-arch-tochno-imja: rc=0 expected=0
GREEN g-arch-v-skobkah: rc=0 expected=0
GREEN g-arch-s-probelom: rc=0 expected=0
GREEN g-profil-povrezhdyon-fajl: rc=1 expected=1 reason=ОТКАЗ: профиль битый или workflowPaths вне репо
GREEN g-profil-dva-dokumenta: rc=1 expected=1 reason=ОТКАЗ: профиль битый или workflowPaths вне репо
GREEN g-profil-bez-canonical-remote: rc=0 expected=0
GREEN g-arch-curl-s-oshibkoj: rc=1 expected=1 reason=ARCH_CI
GREEN g-arch-json-povrezhdjon-hvost: rc=1 expected=1 reason=ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON
GREEN g-arch-dva-dokumenta: rc=1 expected=1 reason=ARCH_CI: ответ check-runs не разобран (в ответе несколько JSON-документов
GREEN g-archive: rc=1 expected=1 reason=ARCH_CI
GREEN g-architecture: rc=1 expected=1 reason=ARCH_CI
GREEN g-arche: rc=1 expected=1 reason=ARCH_CI
GREEN g-march: rc=1 expected=1 reason=ARCH_CI
GREEN g-arch-nul-hvost: rc=1 expected=1 reason=ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON
GREEN karta-jq-vyzovov: механизм _json_one_object × 5, jq вне механизма не читает недоверенные байты
CELLS=62 STABS=0 FAILURES=0
```

## Карта классов
К-01: чисто — вход: единственная дельта contracts/201:54 и коммит OBJECT.
К-02: блок — требуемый заданием пример Complior-back противоречит конфигу.
К-03: чисто — вход: diff frozen/201/1, единственная строка 54, остальные обязательства сохранены.
К-04: чисто — вход: diff frozen/201/1, зоны и пересечения неизменны.
К-05: чисто — вход: сохранены rc-команды приёмки 201 и регресс 231.
К-06: н/п — дельта не меняет классификацию отказов среды.
К-07: блок — заданный положительный вход Complior-back отказан reference.
К-08: чисто — вход: собственные проверки хвоста, регистра, пробела и пустого конфига выше.
К-09: блок — явно заданный положительный продуктовый вход не входит в конфиг.
К-10: чисто — вход: suite проверяет rc, stderr и отсутствие/наличие тега.
К-11: чисто — вход: suite использует независимые ожидания вне мира.
К-12: чисто — вход: ссылка 201:54 на схему и политику 231.
К-13: н/п — секреты дельтой не вводятся.
К-14: чисто — вход: исходный полный blob 215 и добавленный конфигом литерал проходят.
К-15: чисто — вход: собственный прогон 201 CELLS=62 FAILURES=0.
К-16: чисто — вход: класс авторизация и границы угроз 201 не менялись.
К-17: н/п — архитектурная модель в этой текстовой дельте не меняется.

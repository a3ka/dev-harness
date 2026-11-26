accept
OBJECT=8347d62b7e016bddca4229a1fa7f6b7c6a47f691
СУД: repo=dev-harness; предмет=201; фаза=контракт v+1 (v2); роль=critic; вызов=2 (узкий, после ошибки задания вызова 1); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit201v2c; модель-факт=openai-codex/gpt-6.1-terra; SHA=8347d62b7e016bddca4229a1fa7f6b7c6a47f691; предыдущий=FAIL 3de1cd620; исключение=нет; автор правки Architect231b.

Суд — только дельта 201:54 по R-0162 и политика 231, не новый полный суд 201. Пауза снята только для v+1 201 в объёме 231; прочие работы 201 этим решением не разрешаются. Первый блок основан на ошибке задания: `Complior-back` без owner не входит в допустимую грамматику, а требование его принять отозвано. Грамматика не расширяется ради этого примера.

`git diff frozen/contracts/201/1^{commit} HEAD -- contracts/201-done-dver-soderzhatelnaja-sverka.md` показывает единственную замену строки 54; зоны и пересечения не изменены. Текст делегирует конфигу версии 1 и контракту 231, который определяет также схему, чтение HEAD установки и отказ `DONE_FORMS_CONFIG`. Коммит 267eef98ee587772a8eda30164c379d791134684 содержит в первой колонке `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/201-done-dver-soderzhatelnaja-sverka.md — R-0162 ...`. Фактический trace среды указывает critic openai-codex/gpt-6.1-terra; автор коммита architect, не critic. Счёт прежнего вызова подтверждён вердиктом 3de1cd620. У предоставленной копии нет origin; точный OBJECT имелся в локальном хранилище, одноразовый клон сделан из этой копии и проверен по SHA.

## Адресные проверки

`python3 -B tmp/own201.py` rc 0, в отдельном клоне OBJECT. Запущены живой полный frozen blob 215, полный вердикт 227, обе конфигурированные станционные строки, внешний адрес и свои отрицательные варианты; suite проверяет полный stderr, rc, тег и неизменность HEAD. Внешний `a3ka/Complior-back` распознан как внешний, а не принят за станцию: намеренно локальный OBJECT даёт правильный отказ `обязан быть SHA продукта`.

```text
OWN201 product-station GREEN  RAW_RC 0 
OWN201 product-live215 GREEN  RAW_RC 0 
OWN201 own-owner GREEN  RAW_RC 1 
OWN201 own-tail GREEN  RAW_RC 1 
OWN201 own-substring GREEN  RAW_RC 1 
OWN201 own-uppercase GREEN  RAW_RC 1 
OWN201 own-trailing-space GREEN  RAW_RC 1 
OWN201 config-empty GREEN  RAW_RC 1 
OWN201 review-live227 GREEN  RAW_RC 0 
OWN201_CASES 9 RED 0
```

Собственные входы: `ПРОДУКТ: станция.xyz`, `ПРОДУКТ: нестанция.`, `ПРОДУКТ: Станция.`, `ПРОДУКТ: станция. `; для них ожидание — полный отказ вне грамматики, для пустого конфига — `DONE_FORMS_CONFIG` без тега. Это адресные проверки, не новый предметный поиск по 231.

## Карта классов
К-01: без изменений с вызова 1 — форма и двери вне изменённой постановки.
К-02: чисто — вход исправленного task-crit201v2b.md и config/done_forms.json; предыдущий блок снят исправлением требования.
К-03: чисто — вход diff frozen/contracts/201/1: только строка 54 и конфиг 231.
К-04: без изменений с вызова 1 — зоны и пересечения не изменены по diff.
К-05: без изменений с вызова 1 — команды приёмки 201 и 231 сохранены.
К-06: без изменений с вызова 1 — обработка отказов среды дельтой не менялась.
К-07: чисто — вход адресные проверки 215, 227 и внешнего адреса выше.
К-08: чисто — вход проверки хвоста, регистра, подстроки, пробела и пустого конфига выше.
К-09: чисто — вход config/done_forms.json: два станционных литерала и owner/repo; собственные проверки выше.
К-10: без изменений с вызова 1 — suite проверяет rc, полный stderr, тег и HEAD.
К-11: без изменений с вызова 1 — ожидания suite находятся вне проверяемого мира.
К-12: без изменений с вызова 1 — формат конфига задан схемой 231.
К-13: без изменений с вызова 1 — секреты дельтой не вводятся.
К-14: чисто — вход положительные контроли станция и полный blob 215 выше.
К-15: без изменений с вызова 1 — численные утверждения текста дельтой не менялись.
К-16: без изменений с вызова 1 — риск авторизации и модель угроз 201 не изменены.
К-17: без изменений с вызова 1 — архитектурная модель не меняется.

## Код адресных проверок

```python
import os, sys
from pathlib import Path
root = Path('/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t05aa9c88e/m/tmp/court201')
sys.path.insert(0, str(root / 'fixtures/workshop_project/done_round_compat_231'))
import probe
os.environ['TMPDIR'] = str(root.parent)
probe.PRODUCTS.update({
 'own-owner': ('ПРОДУКТ: a3ka/Complior-back', 1, 'EXTERNAL'),
 'own-tail': ('ПРОДУКТ: станция.xyz', 1, 'GRAMMAR'),
 'own-substring': ('ПРОДУКТ: нестанция.', 1, 'GRAMMAR'),
 'own-uppercase': ('ПРОДУКТ: Станция.', 1, 'GRAMMAR'),
 'own-trailing-space': ('ПРОДУКТ: станция. ', 1, 'GRAMMAR'),
})
cases = ['product-station', 'product-live215', 'own-owner', 'own-tail', 'own-substring', 'own-uppercase', 'own-trailing-space', 'config-empty', 'review-live227']
carrier = (root / 'fixtures/workshop_project/done_round_compat_231/model/done_contract.sh').read_bytes()
red = probe.suite(carrier, cases, 'OWN201', root)
print('OWN201_CASES', len(cases), 'RED', red)
sys.exit(bool(red))
```

## Регрессия 201

В одноразовом клоне точного OBJECT: `env TMPDIR=<scratch-в-копии> bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .`, rc 0, сырой вывод:

```text
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

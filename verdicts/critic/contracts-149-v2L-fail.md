FAIL
OBJECT=43e208f128007014945927729ea668ffac7c30e8
СУД: repo=dev-harness; предмет=149; фаза=контракт (лёгкий трек); роль=critic; вызов=1/лёгкий; модель-план=openai-codex/gpt-6-sol; сессия=Crit149L; модель-факт=openai-codex/gpt-6-sol; SHA=43e208f128007014945927729ea668ffac7c30e8; предыдущий=verdicts/critic/contracts-149-v2e-fail.md (закрытый полный трек 5/5); исключение=лёгкий трек по слову владельца 2026-11-03. Автор Arch149g — zai/glm-5.3 (задание); судья — Sol (модель сеанса); семейства независимы. Строка учёта в HANDOFF ещё не наблюдалась: оркестратору внести её и сверить фактический трейс ДО материализации вердикта в основной ветке. Основной checkout не изменялся.

БЛОКИРУЕТ fixtures/workshop_project/gespraech_tekst_149/piny.json:137 — класс причины: неверный ключ канонического UI Copy в обязательном пине голосовой подписи.
ОБЯЗАТЕЛЬСТВО: contracts/149-gespraech-tekst-chat.md:45-46 включает обязательный микрофон; fixtures/workshop_project/gespraech_tekst_149/SPEC.md:35-46 требует брать надписи по ключам `source/copy-de.json` из `piny.json.kopija_kljuchi`; `piny.json:4-5` объявляет пины единым источником для реализации. Продуктовый `AGENTS.md` §«Источники истины» требует UI Copy из источника.
СОСТОЯНИЕ: в поддерживаемых GA-11 и GA-12 обязательна голосовая цель `gespraech-mikrofon` (`fixtures/workshop_project/gespraech_tekst_149/karta.json:148-153`); дизайн-манифест обоих кадров содержит каноническую подпись `Sprechen`. Это рабочий сценарий экрана, не только допустимая грамматика.
НАБЛЮДЕНИЕ: источник входа — `.screens["GA-11"].copy_keys` и `.screens["GA-12"].copy_keys` в запиненном `docs/ux/05_Kompakt_D24/source/manifest.json` включают `ia115.entry.speak`, запись `source/copy-de.json.entries["ia115.entry.speak"].text` даёт `Sprechen`. Источник ошибочного механизма — уже имеющийся пин `piny.json.kopija_kljuchi.kompozer.Sprechen`: он равен `proposed.gespraech.voice.start (голос-цель; видимый знак — микрофон)`; ни это значение, ни ключ без пояснения `proposed.gespraech.voice.start` в `entries` не существуют. Сырой вывод:
```
$ jq -n --slurpfile p fixtures/workshop_project/gespraech_tekst_149/piny.json --slurpfile c /home/harness/dev-harness-projects/complior-mob/wt/wip-136-demo/docs/ux/05_Kompakt_D24/source/copy-de.json '{pinned:$p[0].kopija_kljuchi.kompozer.Sprechen,canonical:$c[0].entries["ia115.entry.speak"].text,pinned_entry:$c[0].entries[$p[0].kopija_kljuchi.kompozer.Sprechen],stripped_entry:$c[0].entries["proposed.gespraech.voice.start"]}'
{
  "pinned": "proposed.gespraech.voice.start (голос-цель; видимый знак — микрофон)",
  "canonical": "Sprechen",
  "pinned_entry": null,
  "stripped_entry": null
}
rc=0
```
Потребитель пина не может разрешить объявленный источник подписи; использование угаданного литерала вместо источника противоречит обязательству. Это прямое расхождение артефакта с действующим обязательством, а не специально написанный негативный фильтр или исследование батареи экрана.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: каждый заявленный пин UI Copy разрешается как ключ именно запиненного `copy-de.json`, а обязательная голосовая подпись соответствует источнику GA-11/GA-12; пояснение не входит в значение ключа. Как изменить запись — решает автор.

Сырые замеры на одноразовом архиве OBJECT с read-only alternates и импортированными историческими tag-refs, последовательно:
```
$ git cat-file -t 43e208f128007014945927729ea668ffac7c30e8
commit
rc=0
$ bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=5
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 148 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
$ bash scripts/check_precision_gate.sh . contracts/149-gespraech-tekst-chat.md
OK
rc=0
$ bash scripts/check_threat_model.sh . contracts/149-gespraech-tekst-chat.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 8 буллет(ов))
rc=0
$ bash scripts/check_spec_ready.sh . contracts/149-gespraech-tekst-chat.md
OK
rc=0
$ bash scripts/check_provodka.sh . contracts/149-gespraech-tekst-chat.md
проводка: guard-файл не существует: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh
rc=1 (именная предпосылка 158, ожидаемо до проводки)
$ bash scripts/check_zones.sh .
  ok   contracts/055-izoljacija-sostojanija-po-projectid.md — предстоящее v2: ЗОНА-строки читаются из рабочего файла ветки (accept-вердикт критика v2 на HEAD, РАЗРЕШИЛ-ВЛАДЕЛЕЦ в каждом коммите текста); тег публикуется после ленда (контракт 130)
rc=141 (проверка истории/зон не завершилась: зелёного результата НЕ заявляю; `--incr` без пути к кешу не применялся)
```
Первая попытка `check_ceilings` без tag-refs ошибочно сочла 68 исторических контрактов незамороженными; после импорта refs применим именно приведённый повторный rc=0.

Дополнительные живые измерения: все 19 именованных значений `piny.json.tokeny.znachenija` сопоставлены с `source/tokens.json` (вывод `pins=19, canonical=19, mismatches=[]`, rc=0). Все 24 уникальных кадра `piny.json.kadry.pikselnaja_sverka` сопоставлены с `frames/frames.json` по имени и полям screen/state/theme/profile и `frames/SHA256SUMS` по SHA256 (вывод `pinned=24, unique=24, mismatches=[]`, rc=0); команда `sha256sum --status -c SHA256SUMS` в каталоге canonical frames/ → rc=0 (188 кадров, без stdout). `sha256sum` пяти метафайлов совпадает с пятью пинами `piny.json.paket.sha256`. Из 120 touch-target записей GA-11/12/13/17/18/19 двух профилей с `hw/hh < 44` — 0. Карта: 26 целей, 6 состояний, 60 пар state×target на профиль, профили 390/393. Frozen-блобы 147/1, 148/1 и 143/2 побайтово равны соответствующим файлам кандидата; границы общих файлов и CI-записей сверены с ними. 149 не раздаёт правку tab-shell/theme/ui-copy; до именованной предпосылки экранный job и CI-запись запрещены, после — только собственное расширение; freeze 147/148 и landing 148→147→149 сохранены. Прежние продуктовые классы остались требованиями К КОДУ, устройство экранной батареи не пересуждалось.

СОВЕТ contracts/149-gespraech-tekst-chat.md:16 — в product main отсутствуют `docs/context/CONTEXT-POLICY.md`, `docs/design/INDEX.md`, `docs/backend/INDEX.md`, `.harness/state/module-map.md`, `mobile/scripts/check-context-sources.py`. Карта модулей доступна в read-only worktree wip-136-demo, SHA256 AGENTS.md/STRUCTURE.md/structure-policy.json/карты совпали с источниками кандидата. Контракт честно указывает отсутствие, PR #157 ожидает CI: согласно заданию оно не блокирует этот суд.

Негативные образцы/мутации батареи экрана не запускались: лёгкий трек исключает пересмотр её устройства. Блокер касается уже предъявленного значения пина относительно канонического рабочего входа.

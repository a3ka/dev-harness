FAIL
OBJECT=9f90379957a6a8e5d7c46a44e6b4f4301878b5db
СУД: repo=dev-harness; предмет=149; фаза=контракт (лёгкий трек); роль=critic; вызов=2/дельта; модель-план=openai-codex/gpt-6-sol; сессия=Crit149M; модель-факт=openai-codex/gpt-6-sol (workstation; фактический trace сверяет оркестратор перед материализацией); предыдущий=verdicts/critic/contracts-149-v2L-fail.md (FAIL, OBJECT=43e208f128007014945927729ea668ffac7c30e8); исключение=автор правки Arch149i (gpt-6-sol) = судья Sol: слово владельца 2026-11-04 ~19:55 UTC «149 отправляй критику. можно тоже Сол. в новом контексте она может найти ошибки и другого Сол»; свежий контекст. Если фактическая модель по трейсу иная (fallback), этот вердикт не материализуется: ESCALATE.

Область повторного суда: закрытие одного блока Crit149L и последствия дельты + НОВОЕ СВИДЕТЕЛЬСТВО РИСКА: опубликованная в Complior-mob origin/main обязательная политика контекста и её исполняемый валидатор теперь доступны, хотя прежний вердикт и пакет задания фиксировали отсутствие этих файлов. Не исследовал заново неизменённую экранную батарею.

Названный блок Crit149L ЗАКРЫТ: `fixtures/workshop_project/gespraech_tekst_149/piny.json:137` теперь задаёт `Sprechen: ia115.entry.speak`; `source/copy-de.json.entries["ia115.entry.speak"].text` = `Sprechen`, ключ присутствует в `source/manifest.json` для GA-11 и GA-12. В SPEC.md:35-46, karta.json:148-158 и contracts/149-gespraech-tekst-chat.md:44-56 иного ключа для этой подписи нет; ранее замороженная модель компонента уже употребляет `ia115.entry.speak`. Замер jq: `{ "pinned": "ia115.entry.speak", "canonical": "Sprechen", "resolved": "Sprechen", "ga11": 17, "ga12": 14 }`, rc=0. Дельта `git diff 43e208f12 9f9037995 -- contracts fixtures`: только контракт (+6/−1 строк) и piny.json (+1/−1 строк). И-10 и приёмка п. 6 (`contracts/149-gespraech-tekst-chat.md:56,69`) закрепляют одновременные (а) влитый 158 и наборный rc 0, (б) Maestro-флоу в HEAD PR, зелёный прогон и скриншоты в артефактах, (в) CI-карту и работника по лекалу после разрешения лёгкой пачки; перечислены команды `cat-file`, `ls-tree | grep`, `git grep` с rc 0 и отрицание ленда без любого условия. Порядок:155 и Раздача:201 запрещают вливание PR по частям, ленд 148 → 147 → 149; ПРОВОДКА/ПРЕДПОСЫЛКИ и ЗОНА-строки дельтой не изменены. Исключение freeze без живого PR дано словом владельца 2026-11-03/04; доказательства переносятся на ленд, а не снимаются.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:16 — класс причины: опубликованная обязательная цитатная проверка контекста экрана не принимает контракт: весь перечень `ИСТОЧНИК:` расположен внутри одной строки `КОНТЕКСТ`, а ни одной самостоятельной строки грамматики нет.
ОБЯЗАТЕЛЬСТВО: Complior-mob `docs/context/CONTEXT-POLICY.md` §«Контракт и цитата» требует `ИСТОЧНИК: путь@sha256 §N` и `mobile/scripts/check-context-sources.py` rc 0 для контракта экрана до critic (пакет `/tmp/dev-harness-verify/orch/mob-context.md`). Product `AGENTS.md` §«Источники истины» требует пользоваться действующим источником. Ранее исключение было только для ОТСУТСТВУЮЩЕГО инструмента/файлов, не для опубликованного красного инструмента.
СОСТОЯНИЕ: контракт 149 предъявлен на суд экрана с основным Complior-mob origin/main, содержащим `docs/context/CONTEXT-POLICY.md`, `docs/design/INDEX.md`, `docs/backend/INDEX.md`, `.harness/state/module-map.md` и `mobile/scripts/check-context-sources.py` (живой `git ls-tree -r --name-only origin/main -- ...` перечислил все пять). Тот же валидатор байтово совпадает на product main и origin/main (`git diff --stat origin/main main -- docs/context/CONTEXT-POLICY.md mobile/scripts/check-context-sources.py docs/design/INDEX.md` пуст).
НАБЛЮДЕНИЕ: `python3 /home/harness/projects/Complior-mob/mobile/scripts/check-context-sources.py --root /tmp/dev-harness-verify/Crit149M/repo --contract contracts/149-gespraech-tekst-chat.md` → `CITATIONS FAIL: контракт не содержит ИСТОЧНИК:`, rc=1. Проверяется именно заархивированный OBJECT; отказ счёта цитат не зависит от того, куда позже устанавливается контракт: скрипт принимает только строки, начинающиеся `ИСТОЧНИК:`. Это новая проверяемая норма на границе КОНТЕКСТ, прежде отмеченной советом как недоступной; не новый поиск по прежней экранной батарее.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: экранный контракт содержит валидные отдельные источники для фактически выбранного опубликованного контекста, и опубликованный `check-context-sources.py` на установленном в проект кандидате даёт rc=0. Конкретную форму исправления и актуальные хеши выбирает автор.

Сырые замеры на архиве OBJECT в /tmp/dev-harness-verify/Crit149M/repo с git alternates на read-only object store и frozen refs, в порядке задания:
```
git -C /home/harness/dev-harness cat-file -t 9f90379957a6a8e5d7c46a44e6b4f4301878b5db
commit
rc=0
bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=5
КРИТИК: дверь зелёная
rc=0
bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 148 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
bash scripts/check_precision_gate.sh . contracts/149-gespraech-tekst-chat.md
OK
rc=0
bash scripts/check_threat_model.sh . contracts/149-gespraech-tekst-chat.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 8 буллет(ов))
rc=0
bash scripts/check_spec_ready.sh . contracts/149-gespraech-tekst-chat.md
OK
rc=0
bash scripts/check_provodka.sh . contracts/149-gespraech-tekst-chat.md
проводка: guard-файл не существует: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh
rc=1 (ожидаемая непоставленная предпосылка 158, не зелень)
bash scripts/check_zones.sh .
  ok   contracts/055-izoljacija-sostojanija-po-projectid.md — предстоящее v2: ЗОНА-строки читаются из рабочего файла ветки (accept-вердикт критика v2 на HEAD, РАЗРЕШИЛ-ВЛАДЕЛЕЦ в каждом коммите текста); тег публикуется после ленда (контракт 130)
rc=141 (исторический гейт не завершился; полный вывод artifact://602, зелень зон НЕ заявляю)
```
Дополнительное сравнение неизменённых пинов ограничено зависимостями исправления: jq по `piny.json`/`source/tokens.json` → `pins=19 matches=19 mismatches=[]` rc=0; jq по `piny.json`/`frames/frames.json` → `pinned=24 unique=24 matched=24 missing=[]` rc=0; по `frames/SHA256SUMS` → `pins=24 matches=24 mismatches=[]` rc=0. Пять SHA256 метафайлов совпали с `piny.json.paket.sha256`.

Push не делал. Основной checkout не правил. Вердикт записан в личном каталоге для материализации оркестратором; при фактическом fallback вместо Sol суд неприменим.

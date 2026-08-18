accept

Замер закрытия трёх находок моего вердикта `verdicts/adversary/milestone-002.md`. Проверены только исправления из `054e72b`, `da4f710` и `ee2dae1`; пробы строились в отдельных подставных копиях `tmp/adversary/repo`, основное дерево не менялось.

## 1. Лишняя запись вне исключительного реестра — закрыто

В подставное дерево заново добавлена `decisions/008-proizvolnyj.md` с корректными шестью полями:

```text
дата: 2026-08-18
вопрос: можно ли обойти реестр
решение: да
основание: ca29f7e
область: всё
условие пересмотра: никогда
```

```text
bash scripts/check_decisions.sh ../closure-probes → 1
FAIL decisions/008-proizvolnyj.md: номер 008 вне ядра реестра 001-007
```

Путь назван. Штатный положительный контроль `bash scripts/check_decisions.sh` дал `0`: `записей: 7 · нарушений: 0`.

## 2. Дата вне грамматики — закрыто

В другой подставной копии заменена только дата записи 001 на `вчера после обеда`.

```text
bash scripts/check_decisions.sh ../closure-date → 1
FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: поле «дата» — «вчера после обеда», а грамматика требует ГГГГ-ММ-ДД
```

Отказ называет и запись, и поле. Это та же проба, что прошла в первом круге.

## 3. Поведенческая фикстура `always-ask` — закрыто

Существуют `scripts/check_approval.sh` и три фикстуры `fixtures/check_approval/case_*.sh`. Положительный контроль чистого конфига:

```text
bash scripts/check_approval.sh → 0
политика: always-ask · нарушений: 0
```

Повторный прогон всех фикстур предъявил красное исполнением:

```text
npm run check:antiplacebo → 0
check_approval/case_flag_zatiraet_politiku.sh → повторный прогон красный кодом 1
check_approval/case_politika_ne_always_ask.sh → повторный прогон красный кодом 1
check_approval/case_zapusk_bez_konfiga.sh → повторный прогон красный кодом 1
барьеров: 18 · фикстур: 114 · предъявлено красным повторным прогоном: 114
```

`.omp/config.yml` содержит `tools.approvalMode: always-ask`. Независимый запуск `workshop` из каталога без конфига под подставным `omp`, записывающим рабочий каталог и argv, показал:

```text
PWD /home/aka/Documents/dev-harness/tmp/adversary/closure-approval
ARG --profile dev
ARG --model zai/glm-5.2
ARG --append-system-prompt .../.zones/dev/session-prompt-architect.md
ARG --tools read,edit,write,bash,grep,glob,lsp,web_search,inspect_image,task,todo
```

То есть запуск перешёл в каталог с тем же конфигом, а захват не содержит `--approval-mode`, `--approvals`, `--yolo` или `--dangerously-skip-permissions`. Проверка отдельно предъявляет красным передачу каждого из этих флагов вызывающим.

## Новое за кругом закрытия

Не обнаружено.

Все три прежние заглушки теперь получают содержательный отказ, а положительные контроли зелёные. Вердикт: `accept`.

accept

# Adversary056 k2 — contract 056 (`--retake-ahead`)

## Стенограмма спавна

Детектор перед спавном: bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness → rc 0, «основной чекаут чист» (2026-09-29, CI зелёный 6/6 по af5543c).

## Scoped proof

- `bash fixtures/check_no_leak/red_dver_retake_ahead.sh` → rc 0. Клетки a0–a9 прошли два последовательных прогона с разными генерациями входов.
- Frozen-регресс-барьеры неизменны: `git diff --exit-code frozen/contracts/056/1..HEAD -- fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh` → rc 0.
- Отсутствующая утилита не маскируется успехом: `PATH=/nonexistent /bin/bash scripts/check_no_leak.sh --retake-ahead /tmp` → rc 2, `NOT_IMPLEMENTED: утилита git отсутствует`.

## Закрытие находок k1

- **F1 закрыта.** Отдельный toy-repo с чистым porcelain, snapshot до коммита и честной ahead-дельтой с буквальным путём `docs/a\b.md`: `--retake-ahead` → rc 0, затем `--check` → rc 0. Это проверяет объединение манифестного `enc_path` и `git diff -z --name-only` в одной форме.
- **F2 закрыта.** Из пустого не-repo cwd `bash <абсолютный-путь>/scripts/check_no_leak.sh --retake-ahead .` → rc 1, `ОТКАЗ: корень обязан быть абсолютным`; обращения к снимку в выводе нет. Мутант той же формы `./` также → rc 1 с той же причиной.
- **F3 закрыта.** `bash scripts/check_no_leak.sh --retake-ahead /tmp extra` → rc 1, `ОТКАЗ диспетчер: использование`. Пустой третий аргумент и четвёртый аргумент также отвергнуты rc 1 usage-ветвью.

## Новые обходы фикс-пачки

Новых обходов не найдено. Положительный контроль честной минимальной реализации дополнительно прошёл для каждой из следующих единственной ahead-дельты toy-repo: обратный слэш (F1), двойная кавычка, tab, newline, carriage return, Unicode NFC (`é`), Unicode NFD (`e` + combining acute), буквальная последовательность `\\n`, имя с пустым компонентом `docs/empty//part.md` и ведущий `-`. Для каждого: `--retake-ahead` → rc 0 со стенограммой `вне диффа 0`, последующий `--check` → rc 0.

Проверка не изменяла предмет или scoped-батарею; временный pathname-probe удалён до записи вердикта.

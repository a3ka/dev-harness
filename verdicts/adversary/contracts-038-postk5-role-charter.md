# Adversary 038 — role/charter post-K5 retains mutable-target and charter grammar bypasses

**Verdict: FAIL.** Судимый HEAD именно `81384be6187761d57492d37011ea519bbcb7d41b` (`81384be`). Предмет не менялся. Живой воспроизводитель всех результатов: [`contracts-038-postk5-bypasses.repro.sh`](contracts-038-postk5-bypasses.repro.sh).

```bash
bash verdicts/adversary/contracts-038-postk5-bypasses.repro.sh
```

## Найдены 3 обхода

### Б1 — `role=` всё ещё TOCTOU между К и г4

Воспроизводитель строит обычный `roles/honest.md`; Л, `-f` и `readlink -f` (К) видят именно этот плоский regular file. PATH-shim настоящего `readlink` печатает его подлинный результат, затем заменяет **сам канонический target** `roles/honest.md` симлинком на `policies/role-policy.md`. Норма существует только в policy-файле. `grep -Fxq -- "$norm" "$resolved"` повторно разыменовывает mutable pathname `$resolved` и даёт зелёный:

```text
role-canonical-target-replaced-accepted: rc=0
```

Это не старый swap исходного `roles/alias.md`: заменяется объект, который уже был выбран К. Следовательно, комментарий «Читаем ровно тот байт-объект, который К одобрил» неверен: shell pathname не закрепляет объект. Проверка приняла policy-норму как role-норму.

### Б2 — `charter=` не закреплён на `AGENTS.md` и не имеет К-связи

Грамматика контракта требует буквально `charter=AGENTS.md`, то есть секцию устава. Arm проверяет лишь `[ -f "$ROOT/$path" ]`; произвольный путь проходит. Воспроизводитель кладёт норму исключительно в `policies/not-charter.md` и получает:

```text
charter-arbitrary-target-accepted: rc=0
```

Даже буквальное `charter=AGENTS.md` не означает устав: прямой симлинк `AGENTS.md -> policies/charter-policy.md` зелёный (`charter-external-symlink-accepted: rc=0`). Кроме того, awk-shim заменяет честный `AGENTS.md` на этот внешний симлинк после `[ -f]`, но до `charter_section_body`; результат также зелёный:

```text
charter-post-existence-swap-accepted: rc=0
```

Это charter-аналог TOCTOU и одновременно отсутствие требуемого target pinning. Норма из не-устава была засчитана как charter-норма.

### Б3 — новая обёртка `header_text` пропускает нарушение разделителя

Для строки без обязательного разделителя между заголовком и нормой:

```text
- charter=AGENTS.md §Pinned section«Delimiterless charter norm.»
```

`header_text="${rest_after_section%%«*}"` тихо выделяет корректный заголовок, а реконструированный `norm_part` проходит строгий общий парсер. Строка вне объявленной формы `§<полный заголовок секции> «<норма-строка>»` принята:

```text
charter-missing-header-norm-delimiter-accepted: rc=0
```

Это отдельная laxity новой charter-обёртки до `extract_quoted`; строгость общей функции её не покрывает.

## Закрытые и положительные контроли

Тот же воспроизводитель подтверждает, что именно закрытая в круге 5 часть `extract_quoted` работает в обоих arms: role- и charter-строки с хвостовым мусором, а также с вложенными `«»`, дают `rc=1`. Он также проверяет отказ инструмента: подменённые `readlink` и `awk`, оба `exit 127`, дают соответственно `role-absent-readlink-fails-closed: rc=1` и `charter-absent-awk-fails-closed: rc=1`.

Обязательный реальный положительный контроль (три живых `role=` и один живой `charter=`) зелёный:

```text
$ bash scripts/check_provodka.sh . contracts/038-provodka-done-gejt.md
# rc=0; stdout/stderr пусты
```

Обязательные регрессии также зелёные:

```text
$ EXPECT_RC=0 bash fixtures/_krasnye_038.sh
итог: 31 файлов, расхождений 0 (режим ожидания rc=0)

$ bash scripts/verify_antiplacebo.sh --scope check_provodka
барьеров: 1 · фикстур: 16 · предъявлено красным повторным прогоном: 16
```

Регрессии и честный вход не опровергают воспроизводимые зелёные обманные реализации выше.

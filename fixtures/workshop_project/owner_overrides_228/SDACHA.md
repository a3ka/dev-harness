# СДАЧА 228 — owner-overrides

Лист architect до реализации. Машинные ряды задают ожидаемые rc, check_sdacha перепроверяет их исполнением. Production, CI и реестры не изменены. SHA базы и исходный census — source.json; прежняя адресная привязка — stabs/mutations.json; историческая — код historical_checks.py/historical_snapshot_checks.py.

## Двери

- честная-модель · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --model · 0 · 0
- адресные-стабы · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --stabs · 0 · 0
- синтаксис · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --sintaksis · 0 · 0
- census · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --catalog · 0 · 0
- гигиена-парсинга · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --parsing · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/228-sh3-owner-overrides.md · 0 · 0
- спецификация · bash scripts/check_spec_ready.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- пересечения · bash scripts/check_precision_gate.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- грамматика-проводки · bash scripts/check_provodka.sh --grammar . contracts/228-sh3-owner-overrides.md · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0

## Карта классов

- К-01 · чисто · вход: все двери формы перечислены выше; check_sdacha --run исполняет лист, SDACHA_OKRUG разрывает рекурсию · - · -
- К-02 · чисто · вход: R-0114/R-0102, FABLE-RECOMMENDATIONS-1121 §в/Ш-3/Б-6, PLAN-V9 §1/4 и ADR 21.11; фактические четыре двери установлены по census 237 · - · -
- К-03 · чисто · вход: context.py читает высшие frozen и canonical zones_load; регрессы 065/083/200/207/210/217/218/992/071 сохранены; 218 интегрируется прежде cutover · - · -
- К-04 · чисто · вход: зоны architect/implementer/orchestrator раздельны; precision-гейт проверяет пересечения; production/CI здесь не пишутся · - · -
- К-05 · чисто · вход: приёмка задаёт команды и rc; исторический живой пересъём явно ручной, не обязательная дверь · - · -
- К-06 · чисто · вход: historical-missing-tools запускает настоящий historical.py с PATH=/nonexistent и требует rc 2; timeout/SIGPIPE ручного check_zones явно записываются, не объявляются полным доказательством · - · -
- К-07 · чисто · вход: настоящие Bash API, Git и четыре CLI; parsing — runner 041; baseline-identity сравнивает материализованные двери с pinned git show, не двойник инструмента · - · -
- К-08 · чисто · вход: прежние 35 мутаций/43 предъявления и пять клеток/четыре стаба политики сохранены; новые snapshot-стабы адресно привязаны кодом, честный контроль обязателен · - · -
- К-09 · чисто · вход: все 148 строк/586 старых предикатных ответов и живые allow/deny миры сохранены; snapshot требует все 312 пар четырёх CLI на 78 SHA · - · -
- К-10 · чисто · вход: snapshot сверяет rc и хеши обеих труб, покрытие, закрытый перечень четырёх исключений и complete=false; реальный live replay вынесен в ручной --historical · - · -
- К-11 · чисто · вход: все oracle-байты снимаются до субъекта; equality-log и хеши закоммичены; реконструкция reference из измеренного равенства указана явно, не выдана за отдельно сохранённые actual-трубы · - · -
- К-12 · чисто · вход: Bash — bash -n и pinned shellcheck через validate_std; Python — ast; snapshot — JSON Schema Draft 2020-12 через jsonschema; git-факты — plumbing · - · -
- К-13 · н/п · секреты в выводе не предмет; новых secrets/variables/environments нет · - · -
- К-14 · чисто · вход: прежние listed/not-listed, scope/sibling, allowed/denied остаются; snapshot имеет честный контроль и mismatch/truncated/growth/complete/hash контрпримеры · - · -
- К-15 · чисто · вход: --catalog сверяет прежние числа с source.json; schema задаёт 78/4/312, snapshot независимо сверяет лог, исходные 532 ответа и точное декартово покрытие · - · -
- К-16 · чисто · вход: рисковая авторизация; граница исторического доказательства — cognitive-only с reviewer, literal-матрицей, живыми мирами и ручным replay перед ленд-ревью · - · -
- К-17 · н/п · станционный предмет, продуктовой модели 188 нет; общий reader и TSV вместо ветвей в дверях · - · -

## Исторический снимок: происхождение и граница

Решение оркестратора task-architect228c.md: обязательная приёмка включает литеральную матрицу 148/586, живые API/CLI миры и закоммиченный снимок паритета. Живой пересъём 133 SHA × четыре CLI в обязательную приёмку и CI НЕ входит.

Исходный historical.json — 532 ранее снятых ответа неизменённого baseline. Предыдущий прогон 228b длился 6421.70 с и завершился rc 2: timeout baseline/check_zones 60 с. Завершены 82 SHA: 78 с точным паритетом всех четырёх CLI и четыре исключённых из-за SIGPIPE. Полные actual-трубы reference не сохранялись. reproducibility.json поэтому явно имеет provenance.kind=reconstructed-from-equality-log: значения reference восстановлены из historical.json только для строк сохранённого stdout HISTORICAL_SHA <sha> doors=4, которые runner печатал после полного сравнения; это НЕ новый измеренный вывод и НЕ отдельный снимок сырых труб. Источник — прогон версии 247e39679b059dfb8d823e77bfbc95c25152004c, stdout сохранён побайтово в historical-parity.log, его hash включён в манифест/lock. Исключения сохраняют реально снятые saved/rechecked и причину BASELINE_SIGPIPE. complete=false сохраняется; оставшиеся SHA не объявлены доказанными.

Снимок проходит JSON Schema и проверки хешей, точного покрытия, обоих ответов каждой пары, списка исключений и равенства состава с equality-log. Подмена, усечение, скрытый complete=true и рост unreproducible — красные входы. Новые адресные мутанты: игнорирование паритета снимка, тихий рост исключений, игнорирование хеша, замена неизменённого baseline reference и включение live replay в --model. Прежние клетки/мутации не ослаблены; изменения probe.py — только добавления.

## НЕ ЗАЩИЩАЕТ

Живой пересъём исторического CLI-паритета по всем 133 SHA не входит в обязательную приёмку: baseline check_zones нестабилен (наследуемый SIGPIPE/timeout 60 с под нагрузкой); паритет на невоспроизведённых SHA не доказывается. Остаточный риск cognitive-only (AGENTS правило 1). Ловцы — reviewer (полный diff production), литеральная матрица 148/586, живые API/CLI миры, ручной --historical перед ленд-ревью. Пересмотр границы — консультант/владелец, не автор батареи.

Ручная команда: bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --historical. Для production: python3 fixtures/workshop_project/owner_overrides_228/historical.py --historical --repo .; ограничение --seconds 1..2400 (по умолчанию 2400). Она НЕ строка раздела «Двери» и НЕ CI. rc 0 означает только отсутствие расхождений на воспроизведённых; rc 1 — расхождение, rc 2 — недоступный инструмент. complete=false допустим при time budget/timeout/SIGPIPE check_zones, причины/расхождения печатаются и записываются в tmp/scratch-arch228/historical-manual.json; закоммиченные ожидания не перезаписываются.

## Рефлексия процесса

Измеренный дефект 228b — checkpoint сохранял baseline-наблюдения лишь при исключении и вообще не сохранял actual reference. Число 78 в манифесте само по себе не является снимком ответов: для переноса потребовался подлинный equality-log с явной provenance реконструкции. Новый ручной runner сохраняет отдельный scratch-отчёт, а неполный результат не маскируется complete=true. Это наблюдение конструкции стенда; А-NN может быть внесена только оркестратором в main, не в этой wip-ветке.

Первый собственный --stabs выявил двух живых hash-мутантов: вспомогательный rejected ошибочно считал успешный tuple загрузчика ненулевым rc. Исправлен тип наблюдаемого результата (только rc 1 либо именованное исключение), добавлен честный положительный контроль самого загрузчика. Это дефект проверки, не production и не основание ослабить hash-обязательство.

## Проводка исполнения

CI подключает orchestrator; до этого предъявляется только --grammar ПРОВОДКА, не done. Реализация production и регрессы после cutover остаются implementer согласно контракту. Исходный до-реализационный контроль 228b: --repo . rc 1, KLETKI=52 ZELENYE=6 KRASNYE=46; это не результат нового прогона 228c.

## Замер 228c

Последовательный прогон в собственном чистом SSH-origin-клоне с дельтой кандидата: --model rc 0 за 17.67 с; --stabs rc 0 за 35.33 с; --sintaksis rc 0; --catalog rc 0; --repo . rc 1, KLETKI=52 ZELENYE=6 KRASNYE=46. Старые стабы: 35/43, историческая политика: 4/4, снимок: 6/6; во всех группах ZHIVYH=0. Census клеток по группам: 52, 5, 9. Снимок: REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312, complete=false.

pre_critic rc 0 (136.36 с); SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 check_sdacha --run rc 0 (167.72 с, двери=12 карта=17/17 дельта=0); check_precision_gate rc 0 (21.78 с). Настоящий parsing 041 исполнен в листе, не подменён проверкой профиля.

Ровно одна фоновая ручная проба W --historical --seconds 120: rc 2 за 0.68 с, именованный GIT/tool failure при восстановлении refs.json — в чистом origin-клоне нет объекта ca425084bad2090fbb38535a33d9a5a0ae6445e1 (refs/tags/archive/wip-140-impl-v2-ca425084b). Проба не объявлена зелёной, исключения/ожидания ради неё не изменены; это недоступная предпосылка полного исторического мира, не обязательная дверь. Для живого replay перед ленд-ревью нужна полная объектная база сохранённых тегов.


accept

# Адверсарий 036, круг 4 — суженный суд корня A

Проверен клон HEAD `4ff5b343ba6e26acaabab63ecff1d8272dbceb67` по решению `74c1f8d`. Корень Б не объявлялся дефектом: его норма — согласованность N с M2_pre, M1 и M2_post; не неизменность дерева внутри окна M1.

## Корень A: физический выход через symlink

Пять замеров решения прошли на настоящем `scripts/check_spec_ready.sh`:

- честный `probes/*.txt` — `rc=0`, `OK`;
- внутренний symlink `b -> probes`, `b/*.txt` — `rc=0`, `OK`;
- корень, переданный через symlink-родителя — `rc=0`, `OK`;
- битый symlink, разрешающийся внутри корня — `rc=0`, `OK`;
- дословный к3 `a -> ../outside`, `a/*.txt` — `rc=1`: `спек-гейт 036: census вне корня: a/out.txt разрешается вне дерева-кандидата`.

Новые пробы суженного symlink-класса также отвергнуты той же именованной причиной:

- цепочка `a -> b`, `b -> ../outside` — `rc=1`, элемент `a/out.txt` вне корня;
- `**/*.txt` через symlink-каталог `a -> ../outside` — `rc=1`, элемент `a/out.txt` вне корня;
- битая ссылка на цель вне корня — `rc=1`, элемент `broken.txt` вне корня.

## TOCTOU и PATH

Проверена подмена `a` после первого `readlink -f`: PATH-wrapper сначала возвращает настоящий канонический внутренний путь и затем переключает `a` на `../outside`; M1 содержит обязательный предикат `test "$(cat a/out.txt)" = outside`, поэтому зелёный результат доказывает, что M1 действительно прочитал внешний файл. Перед M2_post wrapper возвращает `a` на внутреннюю цель. Настоящий гейт дал `rc=0`, `OK`.

Это не объявлено FAIL данного круга: состояние ссылки и census восстановлены до второй границы M2, N согласован на обеих границах; это форма явно выведенной решением restored-mutation boundary, а не ложный census на границе проверки. Отдельно проверено отсутствие утилит: при `PATH=/nonexistent` гейт не становится зелёным — `rc=2`, `NOT_IMPLEMENTED: нет git` (с предшествующими диагностическими ошибками отсутствующих утилит). Следовательно, класс «инструмента нет, но это считается успехом» не воспроизведён.

## Регресс к1–к2 и конформные контроли

Все шесть прежних эксплойтов отвергнуты:

- к1 command substitution — `rc=1`, `census-глоб вне грамматики path-glob`;
- к1 regex-author (`implementer-evil`) — `rc=1`, `перенос зоны ... нет коммитов автора`;
- к2 tab-author (`implementer<TAB>evil`) — `rc=1`, `имя автора вне грамматики (табуляция)`;
- к2 `../` — `rc=1`, `census-глоб вне грамматики path-glob (выход из корня)`;
- к2 persistent M1 mutation — `rc=1`, `дерево изменено замер-командой`;
- к2 background M1 mutation — `rc=1`, `дерево изменено замер-командой`.

Пустой glob с N=0 — `rc=0`, `OK`. Команда, отсутствующая из PATH, возвращает `rc=1`, `замер не исполнен: rc 127`. Позитивные честные контроли приведены выше и зелёные.

Дословный restored-вход к3 (`touch transient.txt; ...; rm transient.txt; printf 1`) — `rc=0`, `OK`; это ожидаемый named-boundary по решению 74c1f8d. Совпадающая константа и команда, считающая соседний glob при том же N, также зелёные; это известная cognitive-only граница frozen §«Остаточный риск» п.3, а не новый file-census обход: M2 независимо подтвердил N для заявленного glob.

## Приёмка и неизменность

Все четыре обязательные red-файла завершились `rc=0`:

- `fixtures/freeze_contract/red_prichina_predmeta_036.sh`;
- `fixtures/freeze_contract/red_zamer_036.sh`;
- `fixtures/check_zones/red_perenos_zony_036.sh`;
- `fixtures/freeze_contract/red_spec_preflight_036.sh`.

Scoped anti-placebo зелёный:

- `npm run check:antiplacebo -- --scope check_check_spec_ready` — 4 из 4 фикстур;
- `npm run check:antiplacebo -- --scope freeze_contract` — 15 из 15;
- `npm run check:antiplacebo -- --scope check_zones` — 21 из 21.

Дополнительно живой `bash scripts/check_spec_ready.sh . contracts/036-spec-tochnost-prefriz-gejt.md` завершился `OK`. `git diff --exit-code frozen/contracts/036/1 HEAD -- contracts/036-*.md` завершился `rc=0`. Детектор в клоне: `bash scripts/check_no_leak.sh --snapshot <clone> && bash scripts/check_no_leak.sh --check <clone>` завершился `rc=0`, вывод `основной чекаут чист`.

Итог: обязательный physical-resolve закрывает к3 и проверенные производные symlink-выходы, прежние к1–к2 регрессии не вернулись. По границе решения 74c1f8d — accept → reviewer 036 → done/036.

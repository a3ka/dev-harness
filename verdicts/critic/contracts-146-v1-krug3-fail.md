FAIL
OBJECT=f819bea3d9e6ddce0549a93bde0b5bfe4c5e3ccc
СУД: repo=dev-harness; предмет=146; фаза=контракт (один санкционированный scoped-критик после Arb146); роль=critic; вызов=1/1 после арбитража; модель-план=openai-codex/gpt-6-sol; сессия=Crit146c; модель-факт=openai-codex/gpt-6-sol; SHA=f819bea3d9e6ddce0549a93bde0b5bfe4c5e3ccc; предыдущий=/tmp/dev-harness-verify/Arb146/verdicts/arbitration/contracts-146-arbitraz.md; исключение=адресный scoped-вызов

БЛОКИРУЕТ contracts/146-shablon-dvizhenie.md:59 — один содержательный класс причины: объявленный конечный каталог адресов неполон. Арбитраж A.1–A.5/B.8 требует поведенческого отказа усечений на КАЖДОМ применимом адресе; 125/125 клеток и `KATALOG ...` не различают три допустимых усечения: (1) hex только первого/последнего keyframes-пина вопреки И-5 (:46), (2) подстановка существующей сцены вместо отсутствующей спеки объявленного pid вопреки И-3 (:44), (3) принятие физически отсутствующего обязательного поля `reduced_duration_ms` вопреки И-6 (:47). Это структурные адреса внутри явно закрытого пакета арбитража, а не допустимый числовой остаток B4. `osi.md:49-50,98-103,115-119` перечисляет оси, но отрицательные входы покрывают крайние пины и УД=`None`, не промежуточные пины/отсутствующий ключ; семейства отсутствующей сцены спеки нет.
ОБХОД: копия эталона как исполняемый субъект с заменой `for x in piny:` на `for x in piny[:1] + piny[-1:]:` проходит ВСЕ 125 поведенческих клеток при seed 146, 7 и 999 (каждый rc 0). Пин `GA-T35/light_reduced[2] = 'zz'*32` при пяти пинах, допустимых первом и последнем, — эталон rc 1 `ETALON_NE_HEX`, усечение rc 0 `SHABLON ... OK`. Независимый субъект с подстановкой первой существующей сцены вместо отсутствующей `GA-T31` также 125/125 rc 0: честно перепиненная спека даёт эталонный rc 1 `PEREHOD_BEZ_SPECY` и усечённый rc 0. Независимый субъект с двумя узкими заменами (требуемое множество полей без `reduced_duration_ms`, отсутствующее значение по умолчанию 0) тоже 125/125 rc 0: удаление поля GA-T35:3 из честно перепиненной спеки даёт эталонный rc 1 `TREK_BEZ_POLJA` + `PORYADOK_NARUSHEN` и усечённый rc 0. Нет traceback, подмены оракула или ложно заколотого источника. Отдельный PORT-барьер поймает неравенство файлов; арбитраж B.8 ТРЕБУЕТ также поведенческий барьер против усечений независимо от побайтовой поставки.
Закрывающее свойство: проверенные отрицательные подвходы с точным ожидаемым адресом для КАЖДОГО существующего keyframes-пина каждой темы, отдельно отсутствие сцены спеки у КАЖДОГО объявленного перехода, отдельно физическое удаление КАЖДОГО обязательного поля каждого применимого трека; честный положительный контроль и отказ этих трёх усечений именно поведением. Точную конструкцию семей и stab→вход выбирает architect ПО КОДУ (Н-39), не задаю её собственной прозой.

К ВЛАДЕЛЬЦУ: после двух critic-FAIL по тому же классу уже состоялся Arb146. Этот следующий FAIL одного адресно санкционированного scoped-вызова не выдаёт accept, не возобновляет автоматически бюджет и не разрешает freeze; решение о дальнейшем маршруте — владельцу (§Быстрый-процесс §Остановка).

Поимённая сверка A.1–C.14, только scoped-пакет арбитража и зависимый регресс:

| Условие | Наблюдение |
|---|---|
| A.1 | НЕ закрыто: каталог `perehodov=5 trekov=67 vidimyh=36 peremeshchenija=31 semey=61` печатается, но три указанные конечные оси не проверяются. |
| A.2 | НЕ закрыто: экранные и переходные удаления, обе стороны `sceny_znaka` представлены; отсутствие сцены спеки каждого pid отсутствует, соответствующее усечение 125/125. |
| A.3 | НЕ закрыто: 67 треков перечислены; `probe.py:557-560,770-775` присваивает отсутствующему УД-полю `None`, ни разу не удаляет ключ. Усечение отсутствующего ключа 125/125. |
| A.4 | Duration/delay/curve/spring/UD/end/order и оба класса УД представлены отрицательными клетками; адресная обязанность A.3 не закрыта. |
| A.5 | 0/25/50/75/100, темы обоих видов files представлены; промежуточные индексы keyframes-пинов не представлены. Усечение 125/125. |
| A.6 | По каждому manifest/spec/pozvonok: отсутствие, не-JSON/грамматика, SHA; `--oracle-tamper` 17 носителей, `--d24-real` проверяет 3 контекст-пина. |
| A.7 | Именованные отказы B.9 без traceback, обе части свежести в клетках; адресная полнота ожиданий не доказана из-за A.2/A.3/A.5. Изолированный таймаут эталона не испытывал. |
| B.8 | Два исходных мутанта красны поведением; три новых конечных усечения зелёны поведением. Независимый байтовый PORT-барьер действует, но другую гарантию не заменяет. |
| B.9 | `ETALON_BEZ_PINOV GA-T31` rc 1 без traceback, `SCENA_VNE_PEREHODA GA-T20` rc 1 измерены. |
| B.10 | На реальных входах продукта HEAD `e94ec4c07f7c434e471a5a27941f256b1a0d502f`: 24 сцены/488 треков, семей 51/51, атак 24/24. Это прямой суд грамматики эталоном, не E2E и не приёмка v3-пачки. |
| C.11 | Шесть `STATIC_BOUNDARY_REACHED; E2E_NOT_RUN` (v1 frozen132/v2 родителя/v3 model × две настоящие v1-пачки); `DIFF_V2_FORMA` согласен, 132 батарея 70/70 rc 0. Полным product E2E не называю. |
| C.12 | Рецепт :205 адекватен при фактическом исполнении по доступному SHA кандидата: диагностический PR, отдельный `.harness146`, явные вызовы кандидата на обеих пачках после штатных шагов, сохранение Maestro/e2e/сверки/provenance/Jest и required quality/android-e2e, логи пути/хеша/продуктового HEAD/run. Сам живой CI ещё не предъявлен, его делает оркестратор параллельно этому суду; это НЕ основание моего FAIL, но самостоятельное условие ДО freeze. |
| C.13 | НЕ закрыто: `osi.md:49-50,98-103,115-119` декларирует адреса, которых нет в отрицательных подвходах; отдельные числа 125 клеток/71 связей/17+3 пинов пересчитаны. |
| C.14 | Старый субъект честно красен 1/125; модель и 71 связь стабов зелёны, буквальный порт в копии 125/125, seed 7/999 проверены; исходные мутанты пойманы, B.9/B.10/C.11/132 наблюдались. Конечная адресная сдача неполна; живой CI — отдельно предстоит оркестратору. |

Команды/сырые ключевые строки результатов. Корень `/tmp/dev-harness-verify/Crit146c`, атаки только в `/tmp/dev-harness-verify/Crit146c-attack`; эталон, source.json и ожидаемые результаты НЕ изменялись. Батареи запускались по одной. Для красных батарей ниже приведены фактически напечатанные итоговые строки (промежуточные `CASE ... KRASNO` не повторены); `RC=` — напечатанный код команды.

```text
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py old 146
BEHAVIOR cells=125 green=63 red=62 seed=146 mode=old
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py old 7
BEHAVIOR cells=125 green=63 red=62 seed=7 mode=old
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py old 999
BEHAVIOR cells=125 green=64 red=61 seed=999 mode=old
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py first_track 146
BEHAVIOR cells=125 green=120 red=5 seed=146 mode=first_track
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py first_track 7
BEHAVIOR cells=125 green=121 red=4 seed=7 mode=first_track
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py first_track 999
BEHAVIOR cells=125 green=122 red=3 seed=999 mode=first_track
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py ud_edges_only 146
BEHAVIOR cells=125 green=120 red=5 seed=146 mode=ud_edges_only
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py keyframe_edges_only 146
BEHAVIOR cells=125 green=121 red=4 seed=146 mode=keyframe_edges_only
RC=1
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py pin_ends_only 146; printf 'RC=%s\n' "$?"
MUTATION pin_ends_only changed_once; seed 146
KATALOG perehodov=5 trekov=67 vidimyh=36 peremeshchenija=31 semey=61
BEHAVIOR cells=125 green=125 red=0 seed=146 mode=pin_ends_only
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py pin_ends_only 7
BEHAVIOR cells=125 green=125 red=0 seed=7 mode=pin_ends_only
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-attack-run.py pin_ends_only 999
BEHAVIOR cells=125 green=125 red=0 seed=999 mode=pin_ends_only
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-pin-repro.py; printf 'RC=%s\n' "$?"
GA-T35 light_reduced pin-index= 2 length= 5 first-last-valid= True
reference rc= 1 reason= ['PRICHINA\tETALON_NE_HEX\tGA-T35 light_reduced'] stdout_end= []
subset rc= 0 reason= [] stdout_end= ['SHABLON\tgespraech-mitte\tOK']
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-scene-run.py battery
MUTATION missing_scene_fallback changed_once
BEHAVIOR cells=125 green=125 red=0
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-scene-run.py counterexample; printf 'RC=%s\n' "$?"
MUTATION missing_scene_fallback changed_once
honest_spec_pin= True
reference rc= 1 reason= ['PRICHINA\tPEREHOD_BEZ_SPECY\tGA-T31'] stdout_end= [] traceback= False
subset rc= 0 reason= [] stdout_end= ['SHABLON\tgespraech-mitte\tOK'] traceback= False
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-field-run.py battery
MUTATION omitted_reduced_duration_default changed_twice
BEHAVIOR cells=125 green=125 red=0
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-field-run.py counterexample; printf 'RC=%s\n' "$?"
MUTATION omitted_reduced_duration_default changed_twice
honest_spec_pin= True
reference rc= 1 reason= ['PRICHINA\tTREK_BEZ_POLJA\tGA-T35:3', 'PRICHINA\tPORYADOK_NARUSHEN\tGA-T35'] stdout_end= [] traceback= False
subset rc= 0 reason= [] stdout_end= ['SHABLON\tgespraech-mitte\tOK'] traceback= False
RC=0
```

B.8: `attack-run.py` измеряет поведение всех 125 клеток с НЕИЗМЕНЁННЫМ независимым эталоном, исключает ТОЛЬКО отдельную проверку побайтовой идентичности исполняемого файла; PORT измерен отдельно. Н-39: привязку stab→вход даёт architect по коду, не эта проза.

Другие измерения — команды и строки результатов (длинные списки 125 `CASE ok`/71 `STAB ... KRASEN` здесь опущены, не объявлены E2E):

```text
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --model; printf 'RC=%s\n' "$?"
KATALOG perehodov=5 trekov=67 vidimyh=36 peremeshchenija=31 semey=61
клеток 125, зелёных 125, красных 0
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --model --seed 7
клеток 125, зелёных 125, красных 0
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --model --seed 999
клеток 125, зелёных 125, красных 0
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --stabs
клеток 125, зелёных 125, красных 0
SVJAZI 71
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --stabs --seed 7
клеток 125, зелёных 125, красных 0
SVJAZI 71
RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-default-run.py; printf 'SMOKE_RC=%s\n' "$?"
KATALOG perehodov=5 trekov=67 vidimyh=36 peremeshchenija=31 semey=61
CASE slice1-pachka ok
клеток 125, зелёных 1, красных 124
PORT_NE_DOOSLOVEN: scripts/ekran_shablon.py (sha256=0285a02c89aa9c3afb49e2596615273a511fde7eb9cf3d5c81d1a64a90aaac84, 1439 строк) != model/ekran_shablon.py (sha256=45ce56a45b5ff21b1f15cf8178698e3f7da9bc22abb8ae5d775cf35eda8ee647, 2116 строк) — предмет требует дословного порта
RC=1
SMOKE_RC=0
$ python3 /tmp/dev-harness-verify/Crit146c-port-run.py; printf 'RC=%s\n' "$?"
клеток 125, зелёных 125, красных 0
PORT_DOSLOVEN sha256=45ce56a45b5ff21b1f15cf8178698e3f7da9bc22abb8ae5d775cf35eda8ee647
RC=0
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --oracle-tamper
ORACLE_TAMPER_PROVERENO nositelej=17
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --d24-real /tmp/dev-harness-verify/Impl145/mob
D24_REAL_PINY realnyj-manifest=OK realnaja-speka=OK realnyj-pozvonok=OK product=e94ec4c07f7c434e471a5a27941f256b1a0d502f model_sha256=45ce56a45b5ff21b1f15cf8178698e3f7da9bc22abb8ae5d775cf35eda8ee647
D24_REAL ekranov=46 dvizhenija=24 scen_znaka=21 scen_speki=24 trekov=488 tokenov=31
D24_REAL_POKRYTIE semey=51 soglasnyh=51 adresnyh-polnoty=OK
D24_REAL_ATAKA scen=24 atak=24 otkazov=24 seed=146 pravil=9
D24_REAL: ZELEN
RC=0
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --differencial /tmp/dev-harness-verify/Impl145/mob
DIFF mobile/e2e-first-run v1-frozen132: STATIC_BOUNDARY_REACHED; E2E_NOT_RUN
DIFF mobile/e2e-first-run v2-baza-roditelja: STATIC_BOUNDARY_REACHED; E2E_NOT_RUN
DIFF mobile/e2e-first-run v3-model: STATIC_BOUNDARY_REACHED; E2E_NOT_RUN
DIFF mobile/e2e-erstinformation v1-frozen132: STATIC_BOUNDARY_REACHED; E2E_NOT_RUN
DIFF mobile/e2e-erstinformation v2-baza-roditelja: STATIC_BOUNDARY_REACHED; E2E_NOT_RUN
DIFF mobile/e2e-erstinformation v3-model: STATIC_BOUNDARY_REACHED; E2E_NOT_RUN
DIFF_V2_FORMA soglasno: rc=0, stdout=3 строк, причин=0
DIFF: ZELEN
RC=0
$ bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit146c; printf 'RC=%s\n' "$?"
замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37643 · проверено по зонам: 8429
RC=0
```

СОВЕТ contracts/146-shablon-dvizhenie.md:205 — в рецепте CI написано `android-e2n`, фактическая required job названа `android-e2e`; поправить при исполнении рецепта.

Остальные ворота: `pre_critic.sh --repo /tmp/dev-harness-verify/Crit146c contracts/146-shablon-dvizhenie.md` → `PREDPOSYLKI_OK settings=3`, `КРИТИК: дверь зелёная`, rc 0; `check_precision_gate` → `OK` rc 0; `check_spec_ready`, `check_ceilings`, `check_threat_model` (`ЗАЩИЩАЕТ 8, НЕ ЗАЩИЩАЕТ 7`), `check_predposylki` (`settings=3`), `check_contract_frozen` (`144/4/140`, реестр full) — rc 0. `check_provodka` — ожидаемо rc 1 до freeze («guard не подключён»), зона оркестратора. Сверка diff именно `f819bea3^..f819bea3`: 56 файлов, +15242 строки, вне зоны architect 0.

НЕ проверено: живой полный CI required quality/android-e2e/Jest/Maestro диагностического PR по опубликованному SHA кандидата и его URL/логи; байты Release PNG/MP4, визуальная точность на устройстве; будущие v3-пачки 147+; фактическая модель автора и fallback по трейсу (git author этого не удостоверяет); бесконечная числовая область вне конечных структурных адресов. Origin не коммитился и не пушился по прямому ограничению задания; локальный FAIL не заменяет accept и C.12.

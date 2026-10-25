FAIL
OBJECT=e812c418f5b79aabb6fb10108972179e9d619e87

# Критик 116 v3, круг 2/3 — гейт до заморозки

Предмет: закоммиченный контракт `contracts/116-cmp-mob-005-mission.md` на OBJECT, не продуктовая реализация. Основание: слово владельца 2026-10-24 23:30, Astra `REPORT-116.md` §3 шаг 1 (в точности, ничего сверх), первый FAIL `/tmp/dev-harness-verify/orch/keep116v3/critic-r1-FAIL.md`. Работа велась на своей копии `/tmp/dev-harness-verify/Critic116sol2/repo`; исходный клон Architect и продуктовый клон прочитаны без записи. **Блокеров: 1**. Три остальные причины FAIL круга 1 закрыты адресными красными экспериментами; четвёртая повторилась в новой форме.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25,37 — Инв. 4 утверждает, что **перед каждым** `takeScreenshot` стоит свой `assertVisible` раньше снимка индексом раскрытого потока; `sud_potok` в `fixtures/workshop_project/mission_116/teksty/proverka_text.py:165-181` принимает наличие **хотя бы одной** пары assert→screenshot с этим именем и затем берёт `idx[0]` для иной проверки. ДВА снимка `mission-f05-05` — первый до собственного assert, второй после — проходят `proverka` rc 0, статическую пробу rc 0, stand-in e2e rc 0 и 123 rc 0 (7×KADR 1.000). Ни одна новая адресная клетка 73 входов не различает эту подмену; `--model` и `--stabs` зелёные на закоммиченном, а в изменённом продуктовом дереве батарея сверяет оракул, не все повторы screenshot. Это повтор причины #3 круга 1, но не её старый одно-снимковый мутант: тот теперь корректно красен `FLOW_ASSERT_POSLE_KADRA`.
ОБХОД: в `mobile/.maestro/mission.yaml` заменить пару `assertVisible mission_frame_f05_05` → `takeScreenshot mission-f05-05` на последовательность `takeScreenshot mission-f05-05` → `assertVisible mission_frame_f05_05` → `takeScreenshot mission-f05-05`; оставить все семь имён и конечные PNG макетов. Первый фактически вызванный `takeScreenshot` не имеет предшествующего **своего** assert, а второй одноимённый кадр делает проверку существования пары зелёной и может записать окончательный путь PNG после появления testID. Продукт может уже отрисовать визуально правильный экран до объявления testID, затем объявить его и снять второй кадр: живой Maestro проходит оба снимка и assert, 123 сверяет выходной PNG, Jest проверяет рендер, но обязанность «перед каждым» не выполнена. Собственный стенд: `/tmp/dev-harness-verify/Critic116sol2/scratch/base/repo/mobile/.maestro/mission.yaml`; проверяющая команда и сырые результаты ниже. Это конструктивный контрпример к критерию, не утверждение о запущенном реальном эмуляторе.

АРБИТР: роль `arbiter` (`roles/arbiter.md`), спор critic ↔ architect — повторный FAIL по одной причине: должен ли Инв. 4 и его исполняемый критерий отклонять **первый** снимок при двух одноимённых `takeScreenshot`, если второй снимок стоит после собственного assert? Созыв обязателен уже на втором FAIL; вопрос инженерный, не эскалация владельцу.

СОВЕТ contracts/116-cmp-mob-005-mission.md:18,24 — bbox composer/navigacija F05.03 взяты «по сетке F05.02»; прежний замер критика нашёл CTA за пределами composer bbox, но удаление CTA краснит 123 ниже порога. Измеренного обхода этим советом нет; не причина FAIL. Новая ветвь appId=пакет и уточнения исчезновения подписи, собственного действия/тестID/порядка утверждают уже разрешённый Astra смысл про исполнимые сцены, не новый продуктовый предмет. Следить за стоимостью поддержки этих уточнений, не объявлять расширением без обхода.

## Scope → выполнен / доказательство

| Область | Итог | Основание |
|---|---|---|
| (1) Четыре блокера и ≥8 новых независимых мутаций | **Выполнено; один новый зелёный обход** | Таблица ниже; старые пять контрпримеров rc1 СВОЕЙ причиной без `FLOW_APPID_NE_PAKET`, новый `duplicate_early_screenshot` rc0. Проведены 14 новых вариантов поверх старых пяти + честного контроля, включая appId корня/ребёнка и app.json отсутствующий/пустой/symlink. `teksty/proverka_text.py:165-181,318-383`. |
| (2) Ничего сверх Astra, разрешение, сохранение норм | **Выполнено** | `git diff --name-only 8ffa2c066..e812c418` — 48 путей, только `contracts/116-cmp-mob-005-mission.md` и `fixtures/workshop_project/mission_116/`; нет 132/123/frozen/116/2. Коммиты с контрактом `53724ea7` и `e812c418` оба имеют требуемую дословную `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` первой строкой тела. v2 Инв.4 «перед каждым takeScreenshot — assertVisible своего селектора» не удалена, v3b `:25` её уточняет (дефект — исполнение критерия). Пин пробы `dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9`, без диффа; `s29–s51` поимённо неизменны, s28/s59 регенерированы. `REPORT-116.md:146-153` (§3.1–6); продуктовый appId привязывает носитель к фактическому пакету, а не добавляет экран. |
| (3) Scoped замеры на своей копии | **Выполнено** | Ниже сырые stdout/rc: W `--model` 73/73 +7 KADR; `--stabs` 60/60 KRASEN; `--tablica` 5 строк/33=33; на собственной `without-subject/` plain rc1 SHABLON_ABSENT KRASNO×73; `pre_critic` rc0; 123 на честном кадре rc0 7×1.000, MAKET_PODMENEN 0. Собственный AST+JSON (`count_axes.py`) 13+33+27=73, 53 стаба, 60 связей, биекция 33 уникальных; поиск `com.complior.demo` в каталоге mission_116 — пусто. Результат plain на обычном дереве со старым живым 132 отдельно rc1 по KADR_USTAREVSHIJ, **не** выдан за отсутствующий субъект. |
| (4) Остаток круга 1, пины | **Выполнено; bbox — совет** | `source.json` три пина B02/B02t/B09 и файлы `nositeli/maket/` совпадают побайтовым sha256 с `origin/main` продукта `/tmp/dev-harness-verify/Impl116/mob` @ `1e9bcc59` (без fetch). `source.json` три maski_pt=[] и порог 0.6; `teksty/povedenie.test.stand-in.tsx` прежний. CTA-удаление из прежнего круга краснело; нет обхода по bbox. |

### Адресные независимые мутанты (продуктовая proverka; отдельно собранный честный pack/repo)

| Мутация; изменённая ось | Результат и ТОЧНАЯ причина |
|---|---|
| honest | rc0 (none) |
| negative_assert_removed; upload/исчезновение | rc1 `FLOW_BEZ_CHIP_NEG_POSLE_UPLOADA` |
| child_no_action; V01 действие | rc1 `SCENARIJ_BEZ_DEJSTVIJA` |
| screenshot_before_assert; один F05.05 снимок | rc1 `FLOW_ASSERT_POSLE_KADRA` |
| manifest_swapped_children; manifest→свой testID | rc1 `SCENARIJ_BEZ_SVOEJ_TESTID` |
| orphan_v01_relocated_assert; manifest→запуск | rc1 `BEZPNG_SCENARIJ_NE_ZAPUSCHEN` |
| **duplicate_early_screenshot**; порядок каждого снимка | **rc0 (none), БЛОКИРУЕТ** |
| v01_send_before_input; действие до предусловия | rc0 (none), не объявлен отдельным обходом без доказанного runtime-исхода |
| v01_preloaded_visible_before_send; наблюдение до действия | rc1 `SCENARIJ_BEZ_DEJSTVIJA` |
| v01_send_after_other_child; действие в чужом ребёнке | rc1 `SCENARIJ_BEZ_DEJSTVIJA` |
| v04_two_sends_after_assert; порядок действия | rc1 `SCENARIJ_BEZ_DEJSTVIJA` |
| draft_sent_before_observe; нулевая отправка F05.07 | rc0 (none), без отдельного runtime-обхода |
| v02_no_negative_completed; отрицательная проверка | rc0 (none), Jest K9 проверяет инвариант interrupted≠completed; самостоятельный обход не показан |
| v04_only_one_send; количество действий | rc1 `SCENARIJ_BEZ_DEJSTVIJA` |
| root_foreign_appid | rc1 `FLOW_APPID_NE_PAKET` (mission.yaml) |
| child_foreign_appid | rc1 `FLOW_APPID_NE_PAKET` (mission-state-v01.yaml) |
| appjson_no_package | rc1 `APPJSON_BEZ_PAKETA` (+ четыре child `FLOW_APPID_NE_PAKET`) |
| appjson_empty_package | rc1 `APPJSON_BEZ_PAKETA` (+ четыре child `FLOW_APPID_NE_PAKET`) |
| appjson_symlink_foreign; симлинк на иной пакет | rc1 `FLOW_APPID_NE_PAKET` (корень+4 ребёнка); симлинк на *тот же* пакет не является обходом требования равенства |
| pending_before_attach; предусловие pending | rc0 (none); pending-assert после attach сохранён и служит реальным свидетелем, самостоятельный обход не предъявлен |

Файл испытания `/tmp/dev-harness-verify/Critic116sol2/mutations.py`; каждая мутация применена отдельно с восстановлением исходных flow, app.json и манифеста. Все четыре ранее названных обхода и orphan-класс воспроизведены в **своей** fixture с package `com.complior.mobile`, без побочного appId отказа. Опыт duplicate дополнительно `/tmp/dev-harness-verify/Critic116sol2/prove_duplicate.py`. Не считаю зелёные структурные мутанты доказательством живого Maestro, если для них не назван runtime-контрпример.

### Сырые результаты команд (без подмены rc)

```text
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
rc=0
CASE chestnyj-ekran ok
CASE proiskhozdenie-chip-neg-udalen ok
CASE proiskhozdenie-kadr-do-asserta ok
CASE proiskhozdenie-rebyonok-bez-dejstvija ok
CASE proiskhozdenie-v04-odna-otpravka ok
CASE proiskhozdenie-v02-bez-gesta ok
CASE proiskhozdenie-f05-07-bez-gesta ok
CASE proiskhozdenie-manifest-pereputan ok
CASE proiskhozdenie-sirot-testid ok
CASE proiskhozdenie-flow-appid-chuzhoj ok
CASE proiskhozdenie-scenarij-ne-zapushhen ok
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
rc=0
STAB s63_appid_propuskaet.py proiskhozdenie-flow-appid-chuzhoj KRASEN
STAB s64_dejstvie_propuskaet.py proiskhozdenie-rebyonok-bez-dejstvija KRASEN
STAB s64_dejstvie_propuskaet.py proiskhozdenie-v04-odna-otpravka KRASEN
STAB s65_svoej_testid_propuskaet.py proiskhozdenie-manifest-pereputan KRASEN
STAB s65_svoej_testid_propuskaet.py proiskhozdenie-sirot-testid KRASEN
STAB s66_chernovik_v_scenarii_propuskaet.py proiskhozdenie-v02-bez-gesta KRASEN
STAB s66_chernovik_v_scenarii_propuskaet.py proiskhozdenie-f05-07-bez-gesta KRASEN
STAB s67_chip_neg_udalen_propuskaet.py proiskhozdenie-chip-neg-udalen KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-kadr-do-asserta KRASEN
STAB s69_scenarij_ne_zapushhen_propuskaet.py proiskhozdenie-scenarij-ne-zapushhen KRASEN
SVJAZI 60
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --tablica
rc=0
OSI	строка	файл	клеток
OSI	osnovnoj-put	mission.yaml	18
OSI	f05-07	mission-state-f05-07.yaml	3
OSI	v01	mission-state-v01.yaml	7
OSI	v02	mission-state-v02.yaml	3
OSI	v04	mission-state-v04.yaml	2
OSI	итого	строк=5 клеток=33 клеток-потока=33
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh   # копия without-subject, scripts/ekran_shablon.py отсутствует
rc=1
SHABLON_ABSENT
CASE chestnyj-ekran KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-chip-neg-udalen KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-kadr-do-asserta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-flow-appid-chuzhoj KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-scenarij-ne-zapushhen KRASNO (SHABLON_ABSENT)
$ bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
rc=0
$ python3 count_axes.py
subjects: [('forma', 13), ('proverka', 33), ('statika', 27)]
rows: [('osnovnoj-put', 'mission.yaml', 18), ('f05-07', 'mission-state-f05-07.yaml', 3), ('v01', 'mission-state-v01.yaml', 7), ('v02', 'mission-state-v02.yaml', 3), ('v04', 'mission-state-v04.yaml', 2)]
bijection: 33 33 33 True
stubs/relations: 53 53 60
```

Здесь для длинных W приведены дословные отдельные строки stdout, не полный stdout. Все четыре режима W наблюдались в этой сессии; plain выполнялся на `without-subject/`. Числа подсчитаны отдельно `count_axes.py`.

```text
$ python3 /tmp/dev-harness-verify/Critic116sol2/mutations.py
honest	rc=0	(none)
negative_assert_removed	rc=1	PRICHINA FLOW_BEZ_CHIP_NEG_POSLE_UPLOADA mission_chip_wird_gelesen
child_no_action	rc=1	PRICHINA SCENARIJ_BEZ_DEJSTVIJA F05.V01 mission-state-v01.yaml
screenshot_before_assert	rc=1	PRICHINA FLOW_ASSERT_POSLE_KADRA mission-f05-05
manifest_swapped_children	rc=1	PRICHINA SCENARIJ_BEZ_SVOEJ_TESTID F05.V01 mission-state-f05-07.yaml
orphan_v01_relocated_assert	rc=1	PRICHINA BEZPNG_SCENARIJ_NE_ZAPUSCHEN mission-state-v01.yaml
duplicate_early_screenshot	rc=0	(none)
$ python3 /tmp/dev-harness-verify/Critic116sol2/prove_duplicate.py
proverka rc=0 stdout=(empty) stderr=(empty)
statika rc=0 stdout=(empty) stderr=(empty)
e2e_stand_in rc=0 stdout=(empty) stderr=(empty)
runner123 rc=0
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
```

Пинование (честный product `origin/main` и носители, sha256sum): B02 `eb4c4cf893b16347a9978c309c46e9b6025004147a8a98a99c2db185fa3d81db`, B02t `727ee59e681559440afc96cffacb266a27a89b945070145a965625b9a4063c9a`, B09 `ed7627cc96590f33d40e48028bbfbc1b72aef26340a91bbe0451fc542cae8294`. Реального эмулятора и product-CI не запускал, новых кадров продукта не заявляю. Нельзя замораживать заявленный контракт с этим обходом: новый круг — только после решения повтора и адресной правки автором, без расширения предмета.

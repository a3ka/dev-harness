accept
OBJECT=bf458d26c0688debdd6137a636d579505e3bcb14
СУД: repo=dev-harness; предмет=148; фаза=scoped-проверка приёмки 10 по решению консультанта 30.10; роль=critic-sol; сессия=Crit148c; модель-факт=openai-codex/gpt-6-sol; SHA=bf458d26c0688debdd6137a636d579505e3bcb14; предыдущий=Crit148b (блок 3); область=приёмка 10 и зависимый регресс. Автор HEAD: architect; трасса `scripts/models_actual.sh --tsv --bind` выдала `architect zai/glm-5.3 allowed Arch148h -` и `critic-sol openai-codex/gpt-6-sol allowed Crit148c bf458d26c0688debdd6137a636d579505e3bcb14`, семейства различны. Полный проход трассы rc 2 на старом историческом имени с кириллицей `Arbiter079Б1` ПОСЛЕ этих строк; он не устанавливает индивидуальную привязку SHA к Arch148h (OBJECT в задании автора `-`).

ГРАНИЦА. `git diff bf458d26^ bf458d26`: только `contracts/148-vkladki-tabov.md`, 4 добавленные и 4 удалённые строки (82, 183, 222, 249); код и батарея 148 не менялись (`git diff --exit-code bf458d26^ bf458d26 -- fixtures/workshop_project/vkladki_tabov_148` rc 0). Суд — именно дельта обязательства и зависимый регресс, не повторный полный суд экрана и не приёмка реализации.

ФОРМА contracts/148-vkladki-tabov.md:82: прежняя приёмка требовала в одном «полном прогоне CI» оба зелёных агрегата. Сейчас предъявляются два живых запуска на одном head SHA диаг-ветки: pull_request с `select-screens`, `quality` (общий вынос пачки до lint), `build-apk`, действительно исполняемым `e2e-vkladki` (валидатор, кадры/evidence, восстановление) и required `android-e2e` зелёными; workflow_dispatch той же ветки/SHA с `mobile-regression-signal` success. Две ссылки run id обязательны в «Живых измерениях». Набор проверок сохранён, оба исходных отказа #144 (`INVENTAR_KARTY`, «file outside allowed location/type») должны исчезнуть ДО freeze на SHA кандидата; без двух запусков freeze запрещён. Синхронизация `:183` (Порядок), `:222` (НЕ ЗАЩИЩАЕТ) и `:249` (НЕ проверено) не меняет этого условия. Реальные run id ещё не предъявлены: это будущая обязанность перед заморозкой, не заявление об уже проведённом продуктовом CI.

МОДЕЛЬ: в SSH-клоне `origin/main=0398bfca106528a4c6eac0845108a3001f0e835b`, модель `fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml`, sha256 `6137aa571ace1147ae1a29884c98008620c3b329eebf83617b5a971d57d0405e` (blob d97142d71a865844d194f1d0bf1f5b191384b97f = `frozen/contracts/143/2`); буквально `:19` — `  workflow_dispatch:`, `:1454` — `    if: always() && (github.event_name == 'pull_request' || github.event_name == 'push' || github.event_name == 'merge_group')` для android-e2e, `:1484` — `    if: always() && (github.event_name == 'schedule' || github.event_name == 'workflow_dispatch')` для mobile-regression-signal. Поэтому последний skipped на PR, но достижим на dispatch; два зелёных агрегата в одном PR невозможны именно по модели. У копии модели в ветке кандидата другой sha256 (`401071f04359000258dc3f4c34f0c27374f41762473f233e7646370105f5f896`): `git diff origin/main HEAD -- <путь модели>` показывает только прежний/новый способ выноса пачек в quality; trigger/оба if остались побайтово такими же. Не подменять hash основной ветки hash кандидата.

РЕГРЕСС (в изолированном SSH-клоне кандидата):
- `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model` → rc 0, дословно `клеток 44, зелёных 44, красных 0`.
- Та же команда без флага → rc 1, дословно `клеток 44, зелёных 2, красных 42` (ожидаемая до реализации краснота).
- `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` → rc 0, `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh . contracts/148-vkladki-tabov.md` → rc 0, `OK`; `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` → rc 0, `OK`; `bash scripts/check_ceilings.sh .` → rc 0, `потолки в порядке`; `bash scripts/check_threat_model.sh . contracts/148-vkladki-tabov.md` → rc 0, `модель угроз: секция валидна (ЗАЩИЩАЕТ 10 буллет(ов), НЕ ЗАЩИЩАЕТ 7 буллет(ов))`; `bash scripts/check_predposylki.sh . contracts/148-vkladki-tabov.md` → rc 0, `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=7`.

АТАКА: `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --stabs` → rc 0. Сырой stdout:
```text
CASE chestnyj-vkladki ok
CASE shablon-otsvtstvuet ok
CASE shablon-2-s-ga-kadrami ok
CASE priemka-bez-prokhoda ok
CASE prokhodimost-otsvtstvuet ok
CASE vtoroj-profil-otsvtstvuet ok
CASE maket-podmenen ok
CASE kadr-nizhe-poroga ok
CASE kadr-ustarevshij ok
CASE e2e-ne-proshla ok
CASE chuzhoj-kadr ok
CASE stroka-bez-izmenenija ok
CASE kasanie-menshe-normy ok
CASE kasanie-v-safe-zone ok
CASE demo-v-sostave ok
CASE demo-bez-otdelenija ok
CASE povtor-id ok
CASE profil-nizhe-minimuma ok
CASE profil-bez-insetov ok
CASE odna-tema ok
CASE marshrut-bez-obolochki ok
CASE marshrut-bez-snimka ok
CASE prokhod-ne-maestro ok
CASE prokhod-bez-pressable ok
CASE prokhod-ne-proshla ok
CASE literal-cveta ok
CASE kljuch-bez-kataloga ok
CASE scenarij-bez-snimka ok
CASE zony-rashodjatsja ok
CASE perehod-lishnij ok
CASE istochnik-ne-sovpadaet ok
CASE istochnik-otsutstvuet ok
CASE pr-chestnaja ok
CASE pr-shov-net ok
CASE pr-mitte-tab ok
CASE pr-pachka-net ok
CASE pr-makety-piny ok
CASE pr-maket-put-net ok
CASE pr-kopii-net ok
CASE pr-scenarij-net ok
CASE pr-kontent-net ok
CASE pr-live-predposylka ok
CASE pr-live-kontrol-krasen ok
CASE pr-live-mutant-zhiv ok
клеток 44, зелёных 44, красных 0
STAB s65_prokhodimost_propuskaet.py stroka-bez-izmenenija KRASEN
STAB s65_prokhodimost_propuskaet.py kasanie-menshe-normy KRASEN
STAB s65_prokhodimost_propuskaet.py kasanie-v-safe-zone KRASEN
STAB s65_prokhodimost_propuskaet.py demo-v-sostave KRASEN
STAB s65_prokhodimost_propuskaet.py demo-bez-otdelenija KRASEN
STAB s65_prokhodimost_propuskaet.py povtor-id KRASEN
STAB s66_profil_propuskaet.py profil-nizhe-minimuma KRASEN
STAB s66_profil_propuskaet.py profil-bez-insetov KRASEN
STAB s66_profil_propuskaet.py odna-tema KRASEN
STAB s67_marshrut_propuskaet.py marshrut-bez-obolochki KRASEN
STAB s67_marshrut_propuskaet.py marshrut-bez-snimka KRASEN
STAB s68_prokhod_propuskaet.py prokhod-ne-maestro KRASEN
STAB s68_prokhod_propuskaet.py prokhod-bez-pressable KRASEN
STAB s68_prokhod_propuskaet.py prokhod-ne-proshla KRASEN
STAB s69_literal_propuskaet.py literal-cveta KRASEN
STAB s70_ga_trigger_propuskaet.py shablon-2-s-ga-kadrami KRASEN
STAB s71_perehody_polnota.py perehod-lishnij KRASEN
STAB s72_kadry_propuskaet.py maket-podmenen KRASEN
STAB s72_kadry_propuskaet.py kadr-nizhe-poroga KRASEN
STAB s72_kadry_propuskaet.py kadr-ustarevshij KRASEN
STAB s73_e2e_propuskaet.py e2e-ne-proshla KRASEN
STAB s74_chuzhie_propuskaet.py chuzhoj-kadr KRASEN
STAB s75_shov_propuskaet.py pr-shov-net KRASEN
STAB s76_mitte_tab_propuskaet.py pr-mitte-tab KRASEN
STAB s77_pachka_propuskaet.py pr-pachka-net KRASEN
STAB s78_makety_propuskaet.py pr-makety-piny KRASEN
STAB s79_kopii_propuskaet.py pr-kopii-net KRASEN
STAB s80_scenarij_propuskaet.py pr-scenarij-net KRASEN
STAB s81_kontent_propuskaet.py pr-kontent-net KRASEN
STAB s82_ispolnimyj_propuskaet.py pr-live-predposylka KRASEN
STAB s82_ispolnimyj_propuskaet.py pr-live-kontrol-krasen KRASEN
STAB s82_ispolnimyj_propuskaet.py pr-live-mutant-zhiv KRASEN
STAB s83_maket_put_propuskaet.py pr-maket-put-net KRASEN
SVJAZI 33
```

СОВЕТ contracts/148-vkladki-tabov.md:82 — текстовая «мутация» удаления dispatch-пружины из приёмки не является мутацией продуктового кода, и имеющаяся красная батарея не судит два реальных Actions run id. Не выдавать её зелень за доказательство dispatch: при freeze вручную сопоставить оба run id, событие, один head SHA и success нужных jobs. Если убрать dispatch и оставить оба агрегата зелёными в одном PR, критерий снова станет недостижимым по `mobile.yml:1484`; это обнаруживается сравнением с моделью, а не батареей. Это совет о способе контроля будущего выполнения, не блок против достижимой текущей приёмки.

ОСТАТОК: реальные product PR/dispatch и ссылки run id отсутствуют до реализации 143 v2 и диагностического PR 148, потому здесь не заявлены проверенными; контракт не разрешает freeze без них.

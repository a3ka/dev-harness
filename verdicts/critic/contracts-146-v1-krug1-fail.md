FAIL
OBJECT=244ca4a435e1a0c4b36eb364833bff09439ff5da
СУД: repo=dev-harness; предмет=146; фаза=контракт (первая редакция); роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit146; модель-факт=openai-codex/gpt-6-sol; SHA=244ca4a435e1a0c4b36eb364833bff09439ff5da; предыдущий=нет; исключение=нет

БЛОКИРУЕТ contracts/146-shablon-dvizhenie.md:46 — класс содержательный: ложная достаточность красной приёмки И-6. Грамматика обещана ПО КАЖДОМУ объявленному переходу, но все красные изменения грамматики батареи применены только к GA-T28 (критерий: строки 54, 62). Исполняемый субъект, проверяющий лишь эту сцену, получает W 42/42, пропуская пружину у объявленного GA-T35. Другие объявленные сцены могут столь же бесконтрольно пропускать неверные кривые, УД, длительность и кадры. SHA256 файла спеки не подтверждает исполнение валидатора.
ОБХОД: в одноразовом клоне `/tmp/dev-harness-verify/Crit146/mut` исполняемый субъект — копия эталона, где `bad += _grammatika_sceny(sceny[pid], tk, pid)` исполняется только при `pid == 'GA-T28'`. Полная батарея W: 42/42, rc 0. На допустимой пачке GA-T35 находится в manifest/spec/perehody, а первый его трек содержит spring и `spec_sha256` честно обновлён: эталон rc 1 `PRUZHINA_ZAPRESHCHENA GA-T35:1`, мутант rc 0 `SHABLON gespraech-mitte OK`. Закрывающее свойство: независимый от субъекта отрицательный вход для И-6 на другом объявленном переходе с честным перепином; предпочтительно сеяный выбор из объявленных переходов, чтобы «литерал на месте, исполняемое иное» не вернулся на следующем каноне. Единственную реализацию не предписываю.

СОВЕТ contracts/146-shablon-dvizhenie.md:191 — в §Сдача одновременно указаны истинное «slice1-pachka ok + 41 KRASNO» и ложное «зелёных 2 / красных 40»; строка 192 вновь объявляет два зелёных контроля. Живой безфлаговый W: rc 1, 42 клетки, зелёных 1, красных 41. GA-пачка shablon 2 на старом субъекте получает rc 0 вместо ожидаемого отказа и тоже считается красной относительно оракула. `python3 -c` подсчитывает 42/20/47, но не полярность живого W. Числовое расхождение недопустимо как факт, но не меняет постусловия 42/42 и не даёт второго класса отказа.
СОВЕТ contracts/146-shablon-dvizhenie.md:65 — `--d24-real R` читает реальный manifest/spec/poses продукта и проверяет `_grammatika_sceny` всех 24 реальных сцен. Это проба настоящей грамматики, НЕ запуск `check_dvizhenie` на реальном ekran.json (нет реальных ∩-переходов/пинов/кадров/приёмки). Не именовать результат полным end-to-end прогоном всей ветки в продуктовой среде; реальная v3-пачка появится лишь после 146.
СОВЕТ contracts/146-shablon-dvizhenie.md:187 — полный CI продукта по SHA диагностического PR ещё не предъявлен. До freeze по норме 29.10 его должен предъявить оркестратор; локальные root tsc, npm test, lint/structure, typecheck на копии НЕ заменяют CI. `.github/workflows/mobile.yml:566,738` вызывает валидатор из неизменных жёстких ref `.harness135`/`.harness118`, а 995/999 используют иной `.harness`: изменение harness main не влияет на эти шаги до перепина. Перепин в продукте потребует полный живой CI, включая Maestro android-e2e.
СОВЕТ contracts/146-shablon-dvizhenie.md:193 — `check_contract_frozen.sh` rc 1 из-за базового (НЕ из diff 146) замороженного 145: и `HEAD~1`, и `HEAD` имеют blob `007c0414b01a9239630e9987ec739607db044fb8` для contracts/145-faden-dvizok.md, frozen 145/4 — `548212652117160214a171e48cdac35d69475d27`. `check_charter` rc 0, текст frozen 132/2 не менялся: v3 вводится отдельным контрактом 146 с зоной implementer `scripts/ekran_shablon.py` (строка 78). Устранить upstream до freeze, не переносить на 146.

Фактические команды/rc (cwd=`/tmp/dev-harness-verify/Crit146/repo`, кроме оговорённого):
- `git cat-file -t 244ca4a435e1a0c4b36eb364833bff09439ff5da` → `commit`, rc 0; HEAD клона = OBJECT. `git diff --name-only HEAD~1 HEAD | python3 -c 'import sys; paths=sys.stdin.read().splitlines(); unexpected=[p for p in paths if p != "contracts/146-shablon-dvizhenie.md" and not p.startswith("fixtures/workshop_project/shablon_dvizhenie_146/")]; print("changed",len(paths),"outside_architect_zone",unexpected)'` → `changed 44 outside_architect_zone []`, rc 0.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh` → `CASE slice1-pachka ok`; 41 `CASE … KRASNO`; `клеток 42, зелёных 1, красных 41`, rc 1; `ga-pachka-na-shablone2`: `rc=0, ожидался 1`.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --model` → 42 `CASE … ok`; `клеток 42, зелёных 42, красных 0`, rc 0.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --stabs` → 42 `CASE … ok`, 47 `STAB … KRASEN`, `SVJAZI 47`, rc 0; полный сырой вывод атаки ниже.
- `python3 -c 'import json,pathlib; s=json.loads(pathlib.Path("fixtures/workshop_project/shablon_dvizhenie_146/source.json").read_text()); print("kejsy",len(s["kejsy"]),"stabs",len(s["stab_vhod"]),"svjazi",sum(map(len,s["stab_vhod"].values())))'` → `kejsy 42 stabs 20 svjazi 47`, rc 0.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --d24-real /tmp/dev-harness-verify/Impl145/mob` → `D24_REAL ekranov=46 dvizhenija=24 scen_znaka=21 scen_speki=24 trekov=488 tokenov=31` / `D24_REAL: ZELEN — грамматика реальной спеки проходит ветку dvizhenie эталона без отказов`, rc 0.
- В копии продукта `/tmp/dev-harness-verify/Crit146/mob`: `python3 /tmp/dev-harness-verify/Crit146/v2/scripts/ekran_shablon.py --pack mobile/e2e-first-run --repo . --harness /tmp/dev-harness-verify/Crit146/repo` и тот же v2-скрипт для `mobile/e2e-erstinformation` → stdout пуст, stderr `PRICHINA\tE2E_NE_PROSHLA\trc=1`, rc 1 у каждого; те же две команды с `/tmp/dev-harness-verify/Crit146/repo/fixtures/workshop_project/shablon_dvizhenie_146/model/ekran_shablon.py` вместо v2 → дословно тот же stderr/rc. V2 извлечён из frozen 132/2 командой `git archive frozen/contracts/132/2 scripts/ekran_shablon.py | tar -x -C /tmp/dev-harness-verify/Crit146/v2`, rc 0. Статические фазы дошли до E2E, эмулятор не запускался.
- В disposable Crit146/mob/mobile после переноса `.harness`, обеих пачек и `kompozicija.stand-in.sh` как в quality: `./node_modules/.bin/tsc --noEmit -p tsconfig.json` → stdout пуст, rc 0; `node scripts/check-structure.cjs` → `structure: OK (repository inventory; external trees excluded)`, rc 0 (до переноса rc 1 из-за этих артефактов вне layout); `npm run lint` → structure OK, rc 0; `npm run typecheck` → `tsc --noEmit -p src/lib/faden/tsconfig.json`, rc 0; `npm test` → `Test Suites: 15 passed, 15 total`, `Tests: 149 passed, 149 total`, rc 0.
- `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit146/repo contracts/146-shablon-dvizhenie.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4`, `КРИТИК: дверь зелёная`, rc 0: Н-39 соблюдён. `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit146/repo contracts/146-shablon-dvizhenie.md` → `OK`, rc 0; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit146/repo contracts/146-shablon-dvizhenie.md` → `OK`, rc 0; `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit146/repo` → `потолки в порядке`, rc 0; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit146/repo contracts/146-shablon-dvizhenie.md` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))`, rc 0; `bash scripts/check_predposylki.sh /tmp/dev-harness-verify/Crit146/repo contracts/146-shablon-dvizhenie.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4`, rc 0.
- `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit146/repo contracts/146-shablon-dvizhenie.md` → `проводка: guard не подключён: fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh не вызывается в .githooks/ или .github/workflows/`, rc 1: объявленный долг orchestrator после freeze. `bash scripts/check_charter.sh /tmp/dev-harness-verify/Crit146/repo` → `уставных документов: 142 · изменений в них: 364 · с разрешения: 364`, rc 0. `bash scripts/check_contract_frozen.sh /tmp/dev-harness-verify/Crit146/repo` → `FAIL contracts/145-faden-dvizok.md изменён без новой заморозки: на HEAD блоб 007c0414b01a9239630e9987ec739607db044fb8, в заморозке v4 — 548212652117160214a171e48cdac35d69475d27`, rc 1 (базовый 145).
- Последним из гейтов `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit146/repo` (timeout=1200): async-result stdout кончается `замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37350 · проверено по зонам: 8345`, стенка 326.43 s; отказов в просмотренном выводе нет. Числового exit code async-result НЕ показал, поэтому rc не утверждаю (первичный замер пользователя rc 0).

Атаки: сырые выводы каждой реально выполненной атаки.
```
$ python3 /tmp/dev-harness-verify/Crit146/attack_scene.py
MUTATION: only GA-T28 receives spec grammar; GA-T29/31/35 skipped
MODEL rc=1 stdout=[] stderr=['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:1']
MUTANT rc=0 stdout=['SHABLON\tgespraech-mitte\tOK'] stderr=[]
[exit=0]
$ (cwd=/tmp/dev-harness-verify/Crit146/mut) bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh
CASE slice1-pachka ok
CASE chestnyj-d24-ekran ok
CASE shablon3-bez-dvizhenija ok
CASE ga-pachka-na-shablone2 ok
CASE dvizhenie-na-shablone2 ok
CASE priemka-s-lishnim-kljuchom ok
CASE ekrany-ne-polny ok
CASE ekrany-vne-manifesta ok
CASE ekran-bez-kadrov ok
CASE perehody-ne-polny ok
CASE perehod-vne-manifesta ok
CASE perehod-lishnij ok
CASE sceny-znaka-ne-polny ok
CASE scena-vne-orakula ok
CASE piny-istochnikov-neverny ok
CASE istochnik-otsutstvuet ok
CASE etalony-bez-pina ok
CASE etalony-ne-polny ok
CASE etalon-ne-hex ok
CASE etalon-lishnij ok
CASE etalon-tema-otsutstvuet ok
CASE video-etalon-ne-polon ok
CASE priemka-dvizhenija-bez-otcheta ok
CASE priemka-dvizhenija-ne-proshla ok
CASE otchet-otsutstvuet ok
CASE otchet-ustarevshij ok
CASE otchet-s-provalami ok
CASE otchet-pustoj ok
CASE otchet-ne-chitaetsja ok
CASE pruzhina-v-spetse ok
CASE krivaya-vne-kanona ok
CASE dlitelnost-bez-tokena ok
CASE dlitelnost-ne-tokenu ok
CASE zaderzhka-ne-po-grammatike ok
CASE zaderzhka-ne-soglasna ok
CASE ud-narushen-peremeshchenie ok
CASE ud-narushen-cveta ok
CASE ud-bez-stolbca ok
CASE end-ms-ne-raven ok
CASE poryadok-narushen ok
CASE kljuchevye-kadry-neverny ok
CASE fajly-etalonov-ne-polny ok
клеток 42, зелёных 42, красных 0
[exit=0]
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --stabs
CASE slice1-pachka ok
CASE chestnyj-d24-ekran ok
CASE shablon3-bez-dvizhenija ok
CASE ga-pachka-na-shablone2 ok
CASE dvizhenie-na-shablone2 ok
CASE priemka-s-lishnim-kljuchom ok
CASE ekrany-ne-polny ok
CASE ekrany-vne-manifesta ok
CASE ekran-bez-kadrov ok
CASE perehody-ne-polny ok
CASE perehod-vne-manifesta ok
CASE perehod-lishnij ok
CASE sceny-znaka-ne-polny ok
CASE scena-vne-orakula ok
CASE piny-istochnikov-neverny ok
CASE istochnik-otsutstvuet ok
CASE etalony-bez-pina ok
CASE etalony-ne-polny ok
CASE etalon-ne-hex ok
CASE etalon-lishnij ok
CASE etalon-tema-otsutstvuet ok
CASE video-etalon-ne-polon ok
CASE priemka-dvizhenija-bez-otcheta ok
CASE priemka-dvizhenija-ne-proshla ok
CASE otchet-otsutstvuet ok
CASE otchet-ustarevshij ok
CASE otchet-s-provalami ok
CASE otchet-pustoj ok
CASE otchet-ne-chitaetsja ok
CASE pruzhina-v-spetse ok
CASE krivaya-vne-kanona ok
CASE dlitelnost-bez-tokena ok
CASE dlitelnost-ne-tokenu ok
CASE zaderzhka-ne-po-grammatike ok
CASE zaderzhka-ne-soglasna ok
CASE ud-narushen-peremeshchenie ok
CASE ud-narushen-cveta ok
CASE ud-bez-stolbca ok
CASE end-ms-ne-raven ok
CASE poryadok-narushen ok
CASE kljuchevye-kadry-neverny ok
CASE fajly-etalonov-ne-polny ok
клеток 42, зелёных 42, красных 0
STAB s45_dvizhenie_bez_suda.py shablon3-bez-dvizhenija KRASEN
STAB s45_dvizhenie_bez_suda.py ga-pachka-na-shablone2 KRASEN
STAB s45_dvizhenie_bez_suda.py perehody-ne-polny KRASEN
STAB s45_dvizhenie_bez_suda.py etalony-bez-pina KRASEN
STAB s45_dvizhenie_bez_suda.py pruzhina-v-spetse KRASEN
STAB s45_dvizhenie_bez_suda.py istochnik-otsutstvuet KRASEN
STAB s46_sostav_shablona3.py dvizhenie-na-shablone2 KRASEN
STAB s47_priemka_alfavit.py priemka-s-lishnim-kljuchom KRASEN
STAB s48_jakorja_ga.py ga-pachka-na-shablone2 KRASEN
STAB s48_jakorja_ga.py ekrany-ne-polny KRASEN
STAB s48_jakorja_ga.py ekran-bez-kadrov KRASEN
STAB s49_ekrany_polnota.py ekrany-ne-polny KRASEN
STAB s49_ekrany_polnota.py ekrany-vne-manifesta KRASEN
STAB s49_ekrany_polnota.py ekran-bez-kadrov KRASEN
STAB s50_perehody_polnota.py perehody-ne-polny KRASEN
STAB s50_perehody_polnota.py perehod-vne-manifesta KRASEN
STAB s50_perehody_polnota.py perehod-lishnij KRASEN
STAB s51_sceny_znaka.py sceny-znaka-ne-polny KRASEN
STAB s51_sceny_znaka.py scena-vne-orakula KRASEN
STAB s52_piny_istochnikov.py piny-istochnikov-neverny KRASEN
STAB s53_etalony.py etalony-bez-pina KRASEN
STAB s53_etalony.py etalony-ne-polny KRASEN
STAB s53_etalony.py etalon-ne-hex KRASEN
STAB s53_etalony.py etalon-lishnij KRASEN
STAB s53_etalony.py etalon-tema-otsutstvuet KRASEN
STAB s53_etalony.py video-etalon-ne-polon KRASEN
STAB s54_dlitzelnost_token.py dlitelnost-bez-tokena KRASEN
STAB s54_dlitzelnost_token.py dlitelnost-ne-tokenu KRASEN
STAB s55_zaderzhka_grammatika.py zaderzhka-ne-po-grammatike KRASEN
STAB s55_zaderzhka_grammatika.py zaderzhka-ne-soglasna KRASEN
STAB s56_mekhanika_krivye.py krivaya-vne-kanona KRASEN
STAB s56_mekhanika_krivye.py pruzhina-v-spetse KRASEN
STAB s57_ud.py ud-narushen-peremeshchenie KRASEN
STAB s57_ud.py ud-narushen-cveta KRASEN
STAB s57_ud.py ud-bez-stolbca KRASEN
STAB s58_end_ms.py end-ms-ne-raven KRASEN
STAB s59_sceny_poryadok.py poryadok-narushen KRASEN
STAB s60_sceny_kadry.py kljuchevye-kadry-neverny KRASEN
STAB s61_fajly_etalonov.py fajly-etalonov-ne-polny KRASEN
STAB s62_priemka_forma.py priemka-dvizhenija-bez-otcheta KRASEN
STAB s63_priemka_ispolnenie.py priemka-dvizhenija-ne-proshla KRASEN
STAB s63_priemka_ispolnenie.py otchet-otsutstvuet KRASEN
STAB s63_priemka_ispolnenie.py otchet-ustarevshij KRASEN
STAB s63_priemka_ispolnenie.py otchet-s-provalami KRASEN
STAB s63_priemka_ispolnenie.py otchet-pustoj KRASEN
STAB s63_priemka_ispolnenie.py otchet-ne-chitaetsja KRASEN
STAB s64_v2_slomano.py slice1-pachka KRASEN
SVJAZI 47
[exit=0]
```

НЕ проверено: живой CI по SHA диагностического PR, android-e2e с настоящим эмулятором и пиннованным checkout; экранные пачки 147+ на реальном v3; байты Release 480 PNG/96 MP4 вне git. Фактическая модель архитектора по трейсу в доступном HANDOFF не найдена (нарезка Arch146 указывает GLM); независимость от модели автора не удостоверена. Вердикт сохранён в Crit146, не коммичен в origin по прямому заданию.

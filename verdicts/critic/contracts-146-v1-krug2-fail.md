FAIL
OBJECT=22971252d67da2a91b69273df80d4be54ef74734
СУД: repo=dev-harness; предмет=146; фаза=контракт (исправительный круг); роль=critic; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit146b; модель-факт=openai-codex/gpt-6-sol; SHA=22971252d67da2a91b69273df80d4be54ef74734; предыдущий=/tmp/dev-harness-verify/Crit146/verdicts/critic/contracts-146-v1.md; исключение=нет

БЛОКИРУЕТ contracts/146-shablon-dvizhenie.md:46 — класс содержательный, ложная достаточность И-6: клеточная ротация закрыла только ось ПЕРЕХОДОВ, а не ось ТРЕКОВ. Ни одна из 13 сеяных мутаций и клетка «пружина во всех переходах» не вводит запрещённую кривую или пружину на НЕпервом треке (несколько клеток меняют поля сцены или УД-трек другого индекса). Исполняемый субъект, судящий кривую/пружину только у первого трека КАЖДОЙ объявленной сцены, проходит W 43/43, хотя пропускает пружину во втором треке GA-T35. «Каждый переход» не означает «каждый его трек». Повтор причины предыдущего FAIL: проверка подмножества вместо всей заявленной грамматики. Закрывающее свойство: красный контрпример с честным перепином источника, где дефект механики на НЕпервом треке объявленного перехода различает эталон и субъект; приёмка должна отвергать подобное подмножество без привязки к константному индексу.
ОБХОД: в отдельном клоне Crit146b-mut субъект — копия эталона с одной заменой `        _proverka_mekhaniki(t, tk, gde, bad)` на `        if i == 0:\n            _proverka_mekhaniki(t, tk, gde, bad)`. Безфлаговая батарея даёт `клеток 43, зелёных 43, красных 0`, rc 0. Отдельная допустимая пачка GA-T35 с `tracks[1].spring`, spec_sha256 == sha256 изменённых байтов: эталон rc 1 `PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:2`; мутант rc 0 `SHABLON\tgespraech-mitte\tOK`. Другие проверки в мутанте сохранены; подмена пина/оракула не применялась.
АРБИТР: Astra — второй critic-FAIL по классу «субъект судит грамматику только по подмножеству объявленных элементов»; спор о достаточности красной приёмки И-6, теперь по трекам при закрытой оси переходов. Решение арбитра не есть accept или третий critic-вызов: scoped-критик после арбитража только по явному решению владельца, если бюджет исчерпан (roles/critic.md §Быстрый-процесс §Остановка).

СОВЕТ contracts/146-shablon-dvizhenie.md:66 — равный отказ E2E_NE_PROSHLA на обеих реальных v2-пачках показывает прохождение статической фазы без регрессии ДО запуска e2e, не эквивалентность полноценного выполнения/кадров на эмуляторе. В `.github/workflows/mobile.yml:492,566` first-run валидатор вызывается из ref `ca277b3ac80c052bdb6b984953fa3ba23c64bab5` `.harness135`, а на `:644,738` erstinformation из ref `5dbcb549dcd226b2bdc858a06aeb2a1be7bcbf04` `.harness118`. Изменение `scripts/ekran_shablon.py` в harness main их НЕ меняет до перепина. Требование владельца 29.10 о живом полном CI по SHA кандидата ДО заморозки остаётся обязанностью оркестратора: диагностический PR, и после перепина отдельно CI с новым пином; непропиненный продуктовый CI сам по себе вообще не выполняет 146/v3.

Фактические команды, результат и сырой вывод (cwd `/tmp/dev-harness-verify/Crit146b`, атаки — `/tmp/dev-harness-verify/Crit146b-mut`; команды исполнялись по одной):
- `git cat-file -t 22971252d67da2a91b69273df80d4be54ef74734` → `commit`, rc 0. HEAD = OBJECT, родитель `a7c83ea7cd546bddb6ba256b5f5f847f4fcad7d3`, один commit architect. `git diff 22971252^ 22971252 --stat` → `45 files +11261 -0`, rc 0; `git diff 22971252^ 22971252 --name-only` → 45 файлов: `contracts/146-shablon-dvizhenie.md` и `fixtures/workshop_project/shablon_dvizhenie_146/**`, вне architect-зоны 0.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh` → `CASE slice1-pachka ok`, 42 `KRASNO`, `клеток 43, зелёных 1, красных 42`, rc 1.
- `python3 -c` over source.json/perehody and rotation `(i+seed)%4` → `declared [GA-T28,GA-T29,GA-T31,GA-T35] grammar_cells 13`; seeds 146, 7, 999 each cover all four (rc 0).
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --model` → `клеток 43, зелёных 43, красных 0`, rc 0; `--model --seed 999` → тот же вывод, rc 0.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --stabs` → `CASE pruzhina-vo-vseh-perehodah ok`, `STAB s65_grammatika_odin_perehod.py pruzhina-vo-vseh-perehodah KRASEN`, `SVJAZI 48`, rc 0; `--stabs --seed 7` → те же строки, 48 KRASEN, rc 0; 21 файл-стаб.
- `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --d24-real /tmp/dev-harness-verify/Impl145/mob` → `D24_REAL ekranov=46 dvizhenija=24 scen_znaka=21 scen_speki=24 trekov=488 tokenov=31` / `D24_REAL_ATAKA scen=24 atak=24 otkazov=24 seed=146 pravil=9` / `D24_REAL: ZELEN — грамматика реальной спеки проходит ветку dvizhenie эталона без отказов; сеяный дефект на КАЖДОЙ из 24 сцен отказом назван`, rc 0. Аналогично `--seed 77` → `D24_REAL_ATAKA scen=24 atak=24 otkazov=24 seed=77 pravil=9`, rc 0. Это проба реальной спеки эталоном, не исполнение v3-пачки продукта.
- Из клона `/tmp/dev-harness-verify/Crit146b-mob` с созданными пустыми mobile/maestro-out-first-run и mobile/maestro-out-erstinformation: `python3 /tmp/dev-harness-verify/Crit146/v2/scripts/ekran_shablon.py --pack mobile/e2e-first-run --repo . --harness /tmp/dev-harness-verify/Crit146b` → stderr `PRICHINA\tE2E_NE_PROSHLA\trc=1`, rc 1; подстановка `.../Crit146b/fixtures/workshop_project/shablon_dvizhenie_146/model/ekran_shablon.py` → ровно те же stderr и rc 1. Обе аналогичные команды для `mobile/e2e-erstinformation` → ровно те же stderr и rc 1.
- `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit146b contracts/146-shablon-dvizhenie.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4` / `КРИТИК: дверь зелёная`, rc 0 (Н-39); `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit146b contracts/146-shablon-dvizhenie.md` → `OK`, rc 0; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit146b contracts/146-shablon-dvizhenie.md` → `OK`, rc 0; `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit146b` → `потолки в порядке`, rc 0; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit146b contracts/146-shablon-dvizhenie.md` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))`, rc 0; `bash scripts/check_predposylki.sh /tmp/dev-harness-verify/Crit146b contracts/146-shablon-dvizhenie.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4`, rc 0; `bash scripts/check_contract_frozen.sh /tmp/dev-harness-verify/Crit146b` → `планов и контрактов на HEAD: 144 · черновиков: 4 · заморожено: 140 · реестр: full`, rc 0.

- Последний гейт: `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit146b` (`timeout=1200`, async bg_1604; дождался completed / async-result, wall 320.08 s). Необработанный итог: `замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37490 · проверено по зонам: 8381`; в доступном выводе отказов нет. Код возврата завершившегося async-задания инструмент НЕ показал, поэтому rc не утверждаю.

Сырые атаки (все команды в одноразовом клоне; неизменённый субъект извлечён из model/ekran_shablon.py, скрипт установки `/tmp/dev-harness-verify/Crit146b-attack.py` изменяет один указанный callsite):
```
$ python3 /tmp/dev-harness-verify/Crit146b-attack.py old
MUTATION old subject /tmp/dev-harness-verify/Crit146b-mut/scripts/ekran_shablon.py changed_once
[exit=0]
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh
CASE slice1-pachka ok
CASE pruzhina-v-spetse KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T31:1']
CASE krivaya-vne-kanona KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tKRIVAYA_VNE_KANONA\tGA-T35:1: ease-in-out']
CASE dlitelnost-bez-tokena ok
CASE dlitelnost-ne-tokenu KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tZNACHENIE_NE_TOKENA\tGA-T29:1: motion-fast']
CASE zaderzhka-ne-po-grammatike KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tZADERZHKA_NE_PO_GRAMMATIKE\tGA-T31:1: позже камня']
CASE zaderzhka-ne-soglasna KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tZADERZHKA_NE_SOGLASNA\tGA-T35:1: motion-fast']
CASE ud-narushen-peremeshchenie ok
CASE ud-narushen-cveta KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tUD_NARUSHEN\tGA-T29:1: opacity']
CASE ud-bez-stolbca KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tUD_BEZ_STOLBCA\tGA-T31:1']
CASE end-ms-ne-raven KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tEND_MS_NE_RAVEN\tGA-T35:1']
CASE poryadok-narushen ok
CASE kljuchevye-kadry-neverny KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tKLJUCHEVYE_KADRY_NE_RAVNY\tGA-T29: 25%']
CASE fajly-etalonov-ne-polny KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tFAJLY_ETALONOV_NE_POLNY\tGA-T31']
CASE pruzhina-vo-vseh-perehodah KRASNO: prichiny=['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T28:1'], ожидались ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T28:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T29:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T31:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:1']
клеток 43, зелёных 32, красных 11
[exit=1]
$ python3 /tmp/dev-harness-verify/Crit146b-attack.py first_track
MUTATION first_track subject /tmp/dev-harness-verify/Crit146b-mut/scripts/ekran_shablon.py changed_once
[exit=0]
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh
CASE pruzhina-v-spetse ok
CASE krivaya-vne-kanona ok
CASE pruzhina-vo-vseh-perehodah ok
клеток 43, зелёных 43, красных 0
[exit=0]
$ python3 /tmp/dev-harness-verify/Crit146b-counterexample.py
GA-T35 second-track spring; sha256 true: True
reference rc 1 prichiny ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:2'] stdout-last []
mutant rc 0 prichiny [] stdout-last ['SHABLON\tgespraech-mitte\tOK']
[exit=0]
$ python3 /tmp/dev-harness-verify/Crit146b-attack.py seed_subset
MUTATION seed_subset subject /tmp/dev-harness-verify/Crit146b-mut/scripts/ekran_shablon.py changed_once
[exit=0]
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh
CASE pruzhina-v-spetse KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T31:1']
CASE pruzhina-vo-vseh-perehodah KRASNO: prichiny=['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T28:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T29:1'], ожидались ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T28:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T29:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T31:1', 'PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:1']
клеток 43, зелёных 35, красных 8
[exit=1]
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --seed 7
CASE pruzhina-v-spetse KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:1']
клеток 43, зелёных 35, красных 8
[exit=1]
$ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --seed 999
CASE pruzhina-v-spetse KRASNO: rc=0, ожидался 1; prichiny=[], ожидались ['PRICHINA\tPRUZHINA_ZAPRESHCHENA\tGA-T35:1']
клеток 43, зелёных 35, красных 8
[exit=1]
```
Сырые строки атак выше — выборка из фактического stdout (остальные 42/43 CASE, включая их полные KADR-stdout в строках расхождений, опущены для читаемости; числовые totals — дословный итог полного W). `old` судит только `pid == 'GA-T28'`; `seed_subset` судит только GA-T28/GA-T29, красен при 146, 7, 999. Контрпример `first_track` — отдельная ось и актуальный блок.

НЕ проверено: живой полный CI продукта/харнесса по SHA диагностического PR и Maestro на эмуляторе; визуальная сверка Release 480 PNG/96 MP4; пачки v3 147+ в продукте; фактическая модель автора из трейса (git author architect, но фактическая модель не установлена). По user-ограничению origin не пушился/не коммитился; локальный вердикт не является зелёным пропуском к freeze.

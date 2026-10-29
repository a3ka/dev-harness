FAIL
OBJECT=f69df3bbba672e428c972c41efd1e3eb9331f39d
СУД: repo=dev-harness; предмет=145; фаза=контракт (один дополнительный scoped-критик после конечного арбитража Astra); роль=critic; модель-план=openai-codex/gpt-6-sol; сессия=Crit145c (agent id; UUID трейса не предъявлен); модель-факт=openai-codex/gpt-6-sol; SHA=f69df3bbba672e428c972c41efd1e3eb9331f39d; предыдущий=/tmp/dev-harness-verify/Arb145/verdicts/arbitration/contracts-145-arbitraz.md; исключение=адресно разрешённый дополнительный scoped-вызов.
МАРШРУТ: следующий FAIL — к владельцу, НЕ новый арбитраж/круг. Commit/push по прямому ограничению задания не делал.

БЛОКИРУЕТ contracts/145-faden-dvizok.md:66,89,209 — B.6/B.8/C.11: обязательный продуктовый live-протокол L невозможно запустить даже при выполненных предпосылках. В `probe.py:273–277` копия `kopija = <temp>/mobile`, но `FADEN = 'mobile/src/ui/faden/FadenSign.tsx'`, поэтому `(kopija / FADEN)` обращается к несуществующему `<temp>/mobile/mobile/src/...`. Необработанный FileNotFoundError происходит ДО позитивного контроля и всех 15 мутантов. Это НЕ предусмотренный rc 2 «нет Jest».
ОБЯЗАТЕЛЬСТВО: L на продукте с установленным Jest/jest-expo, конфигурацией и SVG действительно запускает контроль и конечную матрицу на изолированной копии; приёмка требует W, `npm test -- faden` и L на одном SHA.
СОСТОЯНИЕ: в одноразовом `probe-live-path-probe` честные produkt-файлы дополнены пакетно-образными `mobile/package.json`, `jest.config.js`, файлами метаданных трёх зависимостей и ФИКТИВНЫМ исполняемым `jest` только для прохождения предиката предпосылок, НЕ для объявления работающего Jest. Тот же путь возникает и при реальных пакетах.
НАБЛЮДЕНИЕ: `W --live-component --repo probe-live-path-probe` → rc 1; traceback на `probe.py:277`: `FileNotFoundError: ... '/tmp/faden-145-live-rpi3xdy3/mobile/mobile/src/ui/faden/FadenSign.tsx'`; фиктивный Jest даже не был запущен. Закрывающее свойство: исправить путь внутри копии, добиться запуска именно установленного продуктового Jest и поимённых результатов контроля/15 предметных проб; отсутствие среды остаётся именованным rc 2. Полный TSX-run ДО freeze арбитр НЕ требовал; здесь требуется исполнимый протокол, не самодельный React-шим.

БЛОКИРУЕТ contracts/145-faden-dvizok.md:184 — входная норма Н-39 (architect связывает стабы с наблюдаемыми ветвями ПО КОДУ, не текстом контракта): в §Модель угроз написано «молчаливое отображение ловится стабом istochnik_vydumannaja_faza при ЗЕЛЁНОМ i01». Машинная дверь действительно закрыта; исправление не требует менять корректную кодовую привязку i02.
ОБЯЗАТЕЛЬСТВО: `pre_critic --repo . contracts/145-faden-dvizok.md` возвращает rc 0; точные stab→клетка соответствия задаются кодом и `source.json:.stab_vhod`.
СОСТОЯНИЕ: контракт OBJECT содержит запрещённое текстовое обещание, несмотря на зелёные реальные i01/i02 и стаб-матрицу.
НАБЛЮДЕНИЕ: `$ bash scripts/pre_critic.sh --repo . contracts/145-faden-dvizok.md` → `ОТКАЗ: Н-39: привязка стаба в прозе, строка 184`, rc 1. Закрывающее свойство: убрать именно текстовую связку без потери содержательной границы угроз и кодовых проб; получить rc 0.

СОВЕТ contracts/145-faden-dvizok.md:68,187 — принятый остаток B4/C.12 не переоткрываю. `W --repo .../produkt --seed 7/42/2026` — каждый 46/46 rc 0. Сообщение архитектора `--stabs --seed 42` → rc 1 `STAB_ZHIV: stab_pose_vne_setki` принимаю как факт и НЕ перезапускал: код стаба привязан к первой точке DEFAULT seed 145 (t=3624.158); другая выборка НЕ обязана содержать иглу. Это ложный красный selftest при дополнительном сочетании флагов, но НЕ дефект p14/p15 и НЕ нарушение C.12 (обязательный `--stabs` назван без иного seed). Можно разъяснить семантику CLI без текстового назначения стабов к ветвям (Н-39).

Сырые замеры (cwd `/tmp/dev-harness-verify/Crit145c`, кроме явно отмеченных; W — дословно `bash fixtures/workshop_project/faden_dvizok_145/red_faden_dvizok_145.sh`; каждый прогон последователен). В безфлаговом W реально наблюдались все 46 именованных `SUBJECT_ABSENT`, здесь после сводки не повторяются 46 одинаковых причин:
```
$ git cat-file -t f69df3bbba672e428c972c41efd1e3eb9331f39d # cwd=/tmp/dev-harness-worktrees/c907157c/wip-145-architect
commit
rc=0
$ git rev-parse HEAD
f69df3bbba672e428c972c41efd1e3eb9331f39d
rc=0
$ W
клеток 46, зелёных 0, красных 46 — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)
КЛЕТКА s-ga-t29 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t35 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t33 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t32 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t34 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t08 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t27 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t37 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t16 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t17 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t18 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t19 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t20 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t21 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t22 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t23 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-t24 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-r2 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-r2-393 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-r3 КРАСНА: SUBJECT_ABSENT
КЛЕТКА s-ga-r3-393 КРАСНА: SUBJECT_ABSENT
КЛЕТКА p01-sostojanija-tiry КРАСНА: SUBJECT_ABSENT
КЛЕТКА p02-emocii КРАСНА: SUBJECT_ABSENT
КЛЕТКА p03-prime КРАСНА: SUBJECT_ABSENT
КЛЕТКА p04-tab КРАСНА: SUBJECT_ABSENT
КЛЕТКА p05-path-svg КРАСНА: SUBJECT_ABSENT
КЛЕТКА p06-morph КРАСНА: SUBJECT_ABSENT
КЛЕТКА p07-adaptive КРАСНА: SUBJECT_ABSENT
КЛЕТКА p08-voicebars КРАСНА: SUBJECT_ABSENT
КЛЕТКА p09-tierfor КРАСНА: SUBJECT_ABSENT
КЛЕТКА p10-bezier КРАСНА: SUBJECT_ABSENT
КЛЕТКА p11-katalog КРАСНА: SUBJECT_ABSENT
КЛЕТКА p12-instance-sglazhivanie КРАСНА: SUBJECT_ABSENT
КЛЕТКА p13-instance-restart КРАСНА: SUBJECT_ABSENT
КЛЕТКА d01-ud-pozy КРАСНА: SUBJECT_ABSENT
КЛЕТКА d02-ud-instance КРАСНА: SUBJECT_ABSENT
КЛЕТКА d03-ud-sceny КРАСНА: SUBJECT_ABSENT
КЛЕТКА t01-tokemy КРАСНА: SUBJECT_ABSENT
КЛЕТКА i01-istochnik-funkcija КРАСНА: SUBJECT_ABSENT
КЛЕТКА i02-istochnik-vydumannaja-faza КРАСНА: SUBJECT_ABSENT
КЛЕТКА a01-drajver-zapis КРАСНА: SUBJECT_ABSENT
КЛЕТКА a02-fajly-komponenta КРАСНА: SUBJECT_ABSENT
КЛЕТКА p14-pose-sejanye-vhody КРАСНА: SUBJECT_ABSENT
КЛЕТКА p15-instance-sejanye-vhody КРАСНА: SUBJECT_ABSENT
КЛЕТКА a03-jest-dvizhok-kanon КРАСНА: SUBJECT_ABSENT
КЛЕТКА a05-jest-znak-celesnost КРАСНА: SUBJECT_ABSENT
rc=1
$ W --model
клеток 46, зелёных 46, красных 0
rc=0
$ W --stabs
клеток 46, зелёных 46, красных 0
стабов 20, привязок 29, непойманных 0
rc=0
$ W --repo fixtures/workshop_project/faden_dvizok_145/produkt
клеток 46, зелёных 46, красных 0
rc=0
$ W --repo fixtures/workshop_project/faden_dvizok_145/produkt --seed 7
клеток 46, зелёных 46, красных 0
rc=0
$ W --repo fixtures/workshop_project/faden_dvizok_145/produkt --seed 42
клеток 46, зелёных 46, красных 0
rc=0
$ W --repo fixtures/workshop_project/faden_dvizok_145/produkt --seed 2026
клеток 46, зелёных 46, красных 0
rc=0
$ W --live-component
NEIZVESTNYJ_ARGUMENT: --live-component требует --repo R
rc=2
$ W --live-component --repo fixtures/workshop_project/faden_dvizok_145/produkt
LIVE_PREDPOSYLKA: нет mobile/package.json; нет mobile/jest.config.{js,json} — продуктовая конфигурация jest; не установлен пакет jest-expo (ПРЕДПОСЫЛКА react-native-svg — поставка реализации); не установлен пакет react-native-svg (ПРЕДПОСЫЛКА react-native-svg — поставка реализации); не установлен пакет @testing-library/react-native (ПРЕДПОСЫЛКА react-native-svg — поставка реализации); нет node_modules/.bin/jest
rc=2
$ python3 mutations.py
/tmp/dev-harness-verify/Crit145c/probe-null-working
/tmp/dev-harness-verify/Crit145c/probe-no-replay
/tmp/dev-harness-verify/Crit145c/probe-dead-sign-test
/tmp/dev-harness-verify/Crit145c/probe-invented-phase
/tmp/dev-harness-verify/Crit145c/probe-no-source
/tmp/dev-harness-verify/Crit145c/probe-live-path-probe
rc=0
$ W --repo probe-null-working
клеток 46, зелёных 46, красных 0
rc=0 [ожидаемая граница чистой батареи: null(working) должен судить L при приёмке; L пока неисполняем]
$ W --repo probe-no-replay
клеток 46, зелёных 45, красных 1
КЛЕТКА a03-jest-dvizhok-kanon КРАСНА: TEST_IZMENEN: sha256 c73ff69b414e96bd94bb3ae03bba1b76ce16b3e7563219eddcdda005d95bf006 != канон 590c20e882baf8c6f9efee6f49dee67d517cf95abd441492608299539d9bffe3 — обязательный движковый тест (реплей 21 сцена/6680 строк) ≠ пиннованному артефакту батареи
rc=1
$ W --repo probe-dead-sign-test
клеток 46, зелёных 45, красных 1
КЛЕТКА a05-jest-znak-celesnost КРАСНА: TEST_IZMENEN: sha256 d157cecc87514869aaf850935cf15bab608a7f03b25771d186831496987f20ad != канон 170dd2ee43926dadeb2606929ae884b5715f03987eb50cbf0ea19e63382f19b7 — обязательный знаковый тест ≠ пиннованному артефакту батареи
rc=1
$ W --repo probe-invented-phase
клеток 46, зелёных 45, красных 1
КЛЕТКА i02-istochnik-vydumannaja-faza КРАСНА: VYDUMANNAA_PROSHLA_0: {"side":"client","state":"thinking","session":"sess-145-synth-1","turn":3,"generation":"gen-145-synth-7","mission":"miss → субъект {"ok":true,"patch":{"state":"working"}} != эталон {"ok":false,"refusal":"VYDUMANNAA_FAZA:neizvestnoe_sostojanie"}
rc=1
$ W --repo probe-no-source
клеток 46, зелёных 44, красных 2
КЛЕТКА i01-istochnik-funkcija КРАСНА: Error: ISTOCHNIK_OTSVTSTVUET: /tmp/dev-harness-verify/Crit145c/probe-no-source/mobile/src/ui/faden/faden-state-source.ts
КЛЕТКА i02-istochnik-vydumannaja-faza КРАСНА: Error: ISTOCHNIK_OTSVTSTVUET: /tmp/dev-harness-verify/Crit145c/probe-no-source/mobile/src/ui/faden/faden-state-source.ts
rc=1
$ W --live-component --repo probe-live-path-probe
Traceback (most recent call last):
  File "/tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/probe.py", line 460, in <module>
    sys.exit(glavnaja())
             ^^^^^^^^^^
  File "/tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/probe.py", line 400, in glavnaja
    return zhivoj_komponent(repo_root)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/probe.py", line 277, in zhivoj_komponent
    ishodnyj = (kopija / FADEN).read_text(encoding='utf-8')
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/pathlib.py", line 1029, in read_text
    with self.open(mode='r', encoding=encoding, errors=errors) as f:
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/pathlib.py", line 1015, in open
    return io.open(self, mode, buffering, encoding, errors, newline)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
FileNotFoundError: [Errno 2] No such file or directory: '/tmp/faden-145-live-rpi3xdy3/mobile/mobile/src/ui/faden/FadenSign.tsx'
rc=1
$ env FADEN_ORAKUL_DIR=/tmp/dev-harness-verify/Crit145c/missing-oracles node /tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/model/jest_shim.mjs src/ui/faden/__tests__/faden-motion.test.ts # cwd=fixture/produkt/mobile
{"proshlo":0,"upalo":1,"testov":0,"pervaya_oshibka":"IMPORT/OBRABOTKA: ENOENT: no such file or directory, open '/tmp/dev-harness-verify/Crit145c/missing-oracles/faden-poses-gespraech.json'"}
rc=1
$ env FADEN_ORAKUL_DIR=/tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/model/oracle node /tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/model/jest_shim.mjs src/ui/faden/__tests__/faden-motion.test.ts # cwd=fixture/produkt/mobile
{"proshlo":3,"upalo":0,"testov":3,"pervaya_oshibka":""}
rc=0
$ python3 tamper.py
/tmp/dev-harness-verify/Crit145c/probe-oracle-faden-poses-gespraech
/tmp/dev-harness-verify/Crit145c/probe-oracle-input-tracks
/tmp/dev-harness-verify/Crit145c/probe-oracle-motion-spec-gespraech
/tmp/dev-harness-verify/Crit145c/probe-pin
rc=0
$ bash probe-pin/red_faden_dvizok_145.sh --model
ORACLE_TAMPERED: пин istochnik-sostojanij.mjs: sha256 2c0255714586270567c8ec48ca47ada338eb638425da1f720270e2cb2fa0379a != ccc4e65acab3a1cc3bcc0dc3151fa8c42969f86ecfae637500f4572cb0a34bae
rc=2
$ env FADEN_ORAKUL_DIR=/tmp/dev-harness-verify/Crit145c/probe-oracle-faden-poses-gespraech node /tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/model/jest_shim.mjs src/ui/faden/__tests__/faden-motion.test.ts # cwd=fixture/produkt/mobile
{"proshlo":2,"upalo":1,"testov":3,"pervaya_oshibka":"faden-motion (И-8): движок знака против docs-оракула D 2.4 › оракул продукта: sha256 трёх файлов совпадает с пинами: toBe(\"9763fdc06b0c0a3c3138f7abac57bf5efbc714403f53d221c3b7c8d225c4f002\") на факте \"6e49685e009337b8a3412acedffa512c290d7448f004af199d358f368d42bd2e\""}
rc=1
$ env FADEN_ORAKUL_DIR=/tmp/dev-harness-verify/Crit145c/probe-oracle-input-tracks node /tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/model/jest_shim.mjs src/ui/faden/__tests__/faden-motion.test.ts # cwd=fixture/produkt/mobile
{"proshlo":2,"upalo":1,"testov":3,"pervaya_oshibka":"faden-motion (И-8): движок знака против docs-оракула D 2.4 › оракул продукта: sha256 трёх файлов совпадает с пинами: toBe(\"40e068c92e01e12676254ff40ae6315ad3474c76602d0dfb84cdd00975314b94\") на факте \"e3152cd755b0291cb6cdd96b4f2444299d1a12c77814993bfaf2b838f28b5b24\""}
rc=1
$ env FADEN_ORAKUL_DIR=/tmp/dev-harness-verify/Crit145c/probe-oracle-motion-spec-gespraech node /tmp/dev-harness-verify/Crit145c/fixtures/workshop_project/faden_dvizok_145/model/jest_shim.mjs src/ui/faden/__tests__/faden-motion.test.ts # cwd=fixture/produkt/mobile
{"proshlo":2,"upalo":1,"testov":3,"pervaya_oshibka":"faden-motion (И-8): движок знака против docs-оракула D 2.4 › оракул продукта: sha256 трёх файлов совпадает с пинами: toBe(\"064d7821428f425d431fbd1efd65cbec37263bb62ef974924746a07e769cd318\") на факте \"6b97dba9c4ecb5b7524c762209fe7237a67782c3e2a7114738a604fd95659611\""}
rc=1
```
Дополнительно `node model/probe_runner.mjs ... --mode repo | python3 -c ...` → i01 true (19 конформных фактов), i02 true (22 отказа), a03 true (3 теста/18 подпроб: честный, каталог, 3 SHA, m1/m2, R+2×11), rc 0. Инвентаризация source.json/драйвера/оракула (node, rc 0): 21 сцена, 6680 строк, все 11 состояний, 46 клеток/20 стабов/29 привязок/17 пинов. Прямой node-вызов `fadenInput` на синтетических listening/needs_action/error и thinking (rc 0) вернул три `{ok:true,patch:{state}}` и отказ `VYDUMANNAA_FAZA:neizvestnoe_sostojanie`. SHA256 входного бэкенд-документа `1e7b2790d2449b8e257cbe2505d4bf26242598684ea6077b5ee633c6700cb54c` (rc 0). `git merge-base --is-ancestor 518d8e7b18b8aad92060168a9fdbbd525c129bc1 origin/main` в `/tmp/dev-harness-verify/D24/mob` → пустой stdout, rc 0 (#137 в main).

Гейты (последним check_zones, 320.62 с):
```
$ bash scripts/pre_critic.sh --repo . contracts/145-faden-dvizok.md
ОТКАЗ: Н-39: привязка стаба в прозе, строка 184
rc=1
$ bash scripts/check_precision_gate.sh . contracts/145-faden-dvizok.md
OK
rc=0
$ bash scripts/check_spec_ready.sh . contracts/145-faden-dvizok.md
OK
rc=0
$ bash scripts/check_ceilings.sh . contracts/145-faden-dvizok.md
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 139 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
$ bash scripts/check_threat_model.sh . contracts/145-faden-dvizok.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 8 буллет(ов), НЕ ЗАЩИЩАЕТ 7 буллет(ов))
rc=0
$ bash scripts/check_charter.sh . contracts/145-faden-dvizok.md
уставных документов: 141 · изменений в них: 361 · с разрешения: 361
rc=0 [между началом и итогом поимённые ok; stdout: artifact://11852]
$ bash scripts/check_predposylki.sh . contracts/145-faden-dvizok.md
PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
rc=0
$ bash scripts/check_zones.sh . contracts/145-faden-dvizok.md
процессных вне суда:
замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 36909 · проверено по зонам: 8223
rc=0 [INFERENCE: фоновый интерфейс показал завершение, но не отдельный exit code; в полном выводе artifact://11861 нет FAIL/ОТКАЗ, скрипт завершает кодом 0 при fails=0, иначе 1]
```

НЕ проверено: реальный product Jest/jest-expo/RNTL/React Native/TSX (нет установленного Jest/SVG), живая матрица L на продукте и CI quality с product SHA, эмулятор/устройство/iPhone, фактическая модель автора по runtime-трейсу и UUID собственной сессии. Node-шим НЕ равен jest-expo, фиктивные метаданные path-атаки НЕ считаются Jest-run. Формальную независимость по трейсам сверяет оркестратор до подписи. Численные оси, i01/i02, целостность обязательных тестов и зависимый регресс в периметре A.1–C.14 проверены; закрытые блоки 1/3 прежнего вердикта и принятый B4 не пересуждаю.

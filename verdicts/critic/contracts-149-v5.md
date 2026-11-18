FAIL
OBJECT=bbcb39a063476ec80c516353893f6712271df2ec
СУД: repo=dev-harness; предмет=149; фаза=контракт, один узкий вызов по К-08 и геометрии; роль=critic; вызов=ОДИН по адресной санкции владельца 2026-11-18 ~14:05 UTC, ранее ≥8 вердиктов и Crit149V5 FAIL; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit149V6; модель-факт=openai-codex/gpt-6.1-terra (models_actual --bind: allowed); SHA=bbcb39a063476ec80c516353893f6712271df2ec; предыдущий=archive/149/crit149v5-verdict-298f21cbd8; исключение=слово владельца §7+§8 батча №2, ровно один узкий вызов.

Основание поиска: новый продуктовый путь и дельта геометрии; прежние неизменённые поверхности не пересуждаются. Автор OBJECT — architect, судья — critic. Запись СУД до вызова: state-HANDOFF, 15:21 UTC; дополнение фактической сессии и материализация — оркестратор. Повторный замер Chrome не проводился: заявленный автором отказ CDP не доказывает геометрию повторным измерением.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:74,90,108-119,246 — новый обязательный продуктовый spec находится вне распределённых зон.
ОБЯЗАТЕЛЬСТВО: И-12 и критерий 7 требуют реальный `docs/ux/05_Kompakt_D24/motion/motion-spec-gespraech-kompakt-149.json` и его пин; у каждого файла исполнения контракта должна быть названная зона исполнителя, а не последующая неразданная работа.
СОСТОЯНИЕ: кандидат поручает создание spec implementer после freeze, но среди ЗОНА-строк пути `docs/ux/05_Kompakt_D24/motion/` нет; строка 246 прямо откладывает расширение зоны до отдельной раздачи оркестратора. Новая семантика пути внесена геометрической дельтой.
НАБЛЮДЕНИЕ: исполнитель по замороженной раздаче не имеет зоны для необходимого файла: исполнение останавливается до внешней повторной раздачи либо выходит за границы. Закрывающее свойство: до freeze предъявить исполнимую раздачу требуемого файла с корректными границами и необходимыми пересечениями либо иной законный путь создания источника, совместимый с И-12 и приёмкой.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-04

Проверка закрытия прежней атаки в одноразовом временном мире внутри клона:
```sh
python3 -c 'import importlib.util,tempfile,pathlib,subprocess,sys; p=pathlib.Path("fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py"); s=importlib.util.spec_from_file_location("red",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=tempfile.TemporaryDirectory(dir="."); r=pathlib.Path(t.name); m.postroj_model(r); w=r/m.WORKFLOW; text=w.read_text(); old="- run: npm ci --no-audit --no-fund"; assert text.count(old)==1; w.write_text(text.replace(old,"- run: echo installation-skipped")); q=subprocess.run([sys.executable,str(p),"--repo",str(r)],text=True,capture_output=True); print("mutation: npm ci -> echo installation-skipped"); print("rc:",q.returncode); print(q.stdout,end=""); print(q.stderr,end="")'
mutation: npm ci -> echo installation-skipped
rc: 1
PRICHINA RABOTNIK_BEZ_USTANOVKI: активной команды установки 'npm ci --no-audit --no-fund' в job e2e-gespraech-tekst нет — заменена, закомментирована, выключена или перенесена в другой job
```
`python3 fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --stabs` → rc 0, 50/50, включая адресный стаб 41 и setup-node 49–50. `python3 fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --stabs` → rc 0, `STABY 68 / 68 HONEST_CONTROLS 2`; `--model` → rc 0 `GEOMETRIJA_KOMPAKT_11`. Попытка отдельной соседней мутации setup-node с ошибочно выбранным якорем `actions/setup-node@v4` остановилась `AssertionError`, rc 1; это не наблюдение работы барьера (реальный якорь — v7).

## Карта классов

К-01: чисто — вход: двери и сдаточный лист rc 0 из задания; повтор не назначен.
К-02: чисто — вход: motion-delta.md Kompakt-1.1, источник geometry и слово владельца в OBJECT; повторный Chrome-замер не доказан.
К-03: чисто — вход: git diff 97c6b417f1..OBJECT и таблица снятия норм, геометрическая дельта адресная.
К-04: блок — обязательный продуктовый spec вне распределённых зон.
К-05: чисто — вход: contracts/149-gespraech-tekst-chat.md:90, команды геометрии и коды.
К-06: н/п — отказ Chrome самостоятельно не воспроизведён; автор сообщает rc 2.
К-07: чисто — python3 fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --model, rc 0; реальная реализация после freeze не предъявлена.
К-08: чисто — атака Crit149V5 rc 1 RABOTNIK_BEZ_USTANOVKI; red_ci_149.py --stabs rc 0, 50/50.
К-09: чисто — вход: red_geo_149.py judge/stabs, обе темы и концы прямоугольников; --stabs rc 0.
К-10: чисто — вход: red_geo_149.py repository читает spec субъекта и проверяет пин; живой рендер отдельно за приёмкой.
К-11: чисто — вход: red_geo_149.py oracle загружает запиненный носитель и архив до субъекта.
К-12: чисто — вход: red_geo_149.py использует json и независимый носитель; сравнение с повторным Chrome не заявляется.
К-13: чисто — вход: неизменённый PILOT_DEMO_CODE, git diff 97c6b417f1..OBJECT.
К-14: чисто — red_geo_149.py --stabs rc 0, HONEST_CONTROLS 2, включая численные эквиваленты и порядок ключей.
К-15: чисто — red_geo_149.py --stabs rc 0 68/68; red_ci_149.py --stabs rc 0 50/50.
К-16: чисто — вход: модель угроз contracts/149-gespraech-tekst-chat.md и объявленная граница статической геометрии.
К-17: н/п — архитектурная модель 188 в задании не предъявлена; дельта не меняет её операции.

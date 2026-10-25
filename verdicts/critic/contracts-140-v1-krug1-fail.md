FAIL
OBJECT=0bab3eed8397c5a63582b3a400d7645dd92af674
СУД: repo=dev-harness; предмет=140; фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic140; модель-факт=openai-codex/gpt-6-sol; SHA=0bab3eed8397c5a63582b3a400d7645dd92af674; предыдущий=нет; исключение=нет
Независимость: автор Architect140 — zai/glm-5.3 (трасса в задании); судья — openai-codex/gpt-6-sol (фактическая модель окружения). SSH-клон воспроизвёл HEAD^{tree}=6e04d6004fc826cd283bac7016a7fb97a0415905, равный дереву OBJECT в клоне автора.

## Блокирует

БЛОКИРУЕТ contracts/140-odin-agent-na-predmet.md:58 — батарея `--model`/`--stabs` и её CI-проводка (:71, :82) судят только замороженную модель, а не реализацию `scripts/zamok_predmeta.sh` и не подключение `.omp/extensions/spawn-guard.ts`. Три будущие живые пробы :60 не проверяют остальные обещанные исходы :39, :43–49. Один класс причины: красные клетки не подключены к поставляемому субъекту.
ОБЯЗАТЕЛЬСТВО: отказ дублю рабочего, судье до yield/на чужом OBJECT, обратному порядку рискового суда, переполнению лимита и частичному batch; красный критерий кодовой задачи должен краснеть на обманной реализации (AGENTS.md §Воркфлоу майлстоуна п.1, §Правила п.3).
КЛАСС ПРИЧИНЫ: ложная достаточность критерия — проверка эталона вместо фактической двери/хука.
СОСТОЯНИЕ: достижимая реализационная пачка, в которой model/, stubs/, source.json неизменны, а поставленный скрипт двери всегда разрешает судью до yield и другие запрещённые спавны. На самом OBJECT скрипт поставки ещё отсутствует, но зелёная батарея уже есть.
НАБЛЮДЕНИЕ: в одноразовом клоне `attack-repo` добавлена обманная дверь, пропускающая запрос critic-sol до сдачи; вызов её вернул `PUSCHEM`, rc 0, а `W --stabs` вернул rc 0, все 48 CASE ok, 27 STAB KRASEN, SVJAZI 27 (полный вывод атаки ниже). На исходном OBJECT `test -e scripts/zamok_predmeta.sh` → rc 1 при том же зелёном `W --stabs`.
ОБХОД: оставить эталонную модель и стабы неизменными; поставить дверь, пропускающую судью до yield или обходящую проверку OBJECT/лимитов, при этом получить зелёную автоматическую приёмку. Три живые пробы :60 не являются командой с кодом возврата, не включают OBJECT≠tip, порядок судей, лимиты или atomic batch и не спасают ложную достаточность. Мутация доказывает обход именно красной батареи; прохождение будущих трёх станционных проб этой мутацией не проверялось.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: критерий даёт красный код на обманных вариантах самой поставленной двери и интеграции task-хука, проверяет на реальном субъекте исходы из заявленной таблицы осей и атомарный пакет; ранний прогон модели и стабов может оставаться предварительным доказательством, но не подменяет измерения поставленного механизма.

## Измерения

Объект восстановлен командой `git checkout -q -b critic140-object 68e459a4 && GIT_COMMITTER_NAME=architect GIT_COMMITTER_EMAIL=architect@dev-harness.local git -c core.hooksPath=/tmp/dev-harness-verify/nohooks am /tmp/dev-harness-verify/Architect140/patches/0001-140-odin-agent-na-predmet-v1-48-27-0.patch` → rc 0, вывод `Applying: 140 odin-agent-na-predmet: контракт v1 + красная батарея (48 входов, 27 стабов/связей, живых 0)`.

- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` → rc 1; первая строка `SUBJECT_ABSENT: нет --model/--stabs — зелень без субъекта невозможна`; 48 `CASE … KRASNO (SUBJECT_ABSENT)`.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0; 48 `CASE … ok`.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs` → rc 0; 48 CASE ok, 27 STAB KRASEN, `SVJAZI 27`, живых 0.
- `env -i PATH=/usr/bin:/bin HOME=/tmp TMPDIR=/tmp bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs` → rc 0; 48 CASE ok, 27 STAB KRASEN, `SVJAZI 27`; не требует omp и сети.
- `bash scripts/pre_critic.sh contracts/140-odin-agent-na-predmet.md` → rc 0: `ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4`; `КРИТИК: дверь зелёная`.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic140/repo contracts/140-odin-agent-na-predmet.md` → rc 0, `OK`.
- `bash scripts/check_ceilings.sh` → rc 0: `ok   персоны: 12 файл(ов), потолок 61440 байт`; `ok   правила: 1 файл(ов), потолок 30720 байт`; `ok   раздел требований: 135 черновик(ов) судится, замороженные — по тегам`; `потолки в порядке`.
- Порча носителя, check_provodka на копии, живой спавн станции не выполнены; после доказанного блокера исследование остановлено. Никакого результата этим действиям не приписываю.

### Атака в одноразовом клоне: команда и сырой вывод

`git clone --shared -q /tmp/dev-harness-verify/Critic140/repo /tmp/dev-harness-verify/Critic140/attack-repo && git -C /tmp/dev-harness-verify/Critic140/attack-repo rev-parse HEAD^{tree}` → rc 0, `6e04d6004fc826cd283bac7016a7fb97a0415905`. Только в `attack-repo` записан файл `scripts/zamok_predmeta.sh` (свидетель оставлен); событие — `/tmp/dev-harness-verify/Critic140/judge-before-yield.json`. Модель и стабы НЕ изменялись.

```text
$ bash scripts/zamok_predmeta.sh --sudit --sostojanie /tmp/dev-harness-verify/Critic140 --zhurnaly /tmp/dev-harness-verify/Critic140 --repo /tmp/dev-harness-verify/Critic140/repo /tmp/dev-harness-verify/Critic140/judge-before-yield.json  # cwd attack-repo
PUSCHEM
[exit=0]
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs  # cwd attack-repo
CASE b01-paket-dva-predmeta ok
CASE b02-dubl-v-pakete ok
CASE b03-smeshannyj-otkat ok
CASE b04-gonka-dva-protsessa ok
CASE b05-izolirovannyj-invariant ok
CASE b06-paket-rabochij-plus-scout ok
CASE g01-prefiks-kollizija ok
CASE g02-dve-stroki-subject ok
CASE g03-tab-v-imeni ok
CASE g04-bityj-vhod ok
CASE g05-samo-prolozhenie ok
CASE g06-podstroka-pina ok
CASE s01-sudja-posle-yield ok
CASE s02-kritik-pri-zhivom-rabochem ok
CASE s03-object-rashoditsja ok
CASE s04-object-net ok
CASE s05-vtoroj-sudja-zhiv ok
CASE s06-object-uzhe-suzhen ok
CASE s07-ispravitelnyj-novyj-object ok
CASE s08-rabochego-net ok
CASE s09-adv-do-rev ok
CASE s10-adv-do-rev-zakryt ok
CASE s11-obychnyj-bez-adv ok
CASE s12-vetka-nedostupna ok
CASE s13-klass-riska-net ok
CASE s14-pin-rashozhdenie ok
CASE s22-avtor-zhiv-bez-zamka ok
CASE u01-uchet-svod ok
CASE u02-uchet-pust ok
CASE w01-pervyj-rabochij ok
CASE w02-vtoroj-rabochij-zhiv ok
CASE w03-posle-yield-novyj-rabochij ok
CASE w04-dubl-posle-restarta ok
CASE w05-osvobodit-broshennyj ok
CASE w06-osvobodit-zhivoj ok
CASE w07-subject-net ok
CASE w08-subject-vne-grammatiki ok
CASE w09-imja-net ok
CASE w10-pauza ok
CASE w11-scout-propusk ok
CASE w12-arbiter-propusk ok
CASE w13-limit-harness ok
CASE w14-limit-mob-tri-ok ok
CASE w15-limit-mob-chetyre ok
CASE w16-limit-slovo ok
CASE w17-limit-done-osvobozhdaet ok
CASE w18-limit-pauza-osvobozhdaet ok
CASE w19-gruppa-iz-pina ok
STAB s01-bez-dublja-rabochego w02-vtoroj-rabochij-zhiv KRASEN
STAB s02-bez-yield-predikata w03-posle-yield-novyj-rabochij KRASEN
STAB s03-avto-relis-broshennogo w04-dubl-posle-restarta KRASEN
STAB s04-osvobodit-zhivogo w06-osvobodit-zhivoj KRASEN
STAB s05-subjekt-bez-jakorja g01-prefiks-kollizija KRASEN
STAB s06-pin-bez-jakorja g06-podstroka-pina KRASEN
STAB s07-object-fabricuet s04-object-net KRASEN
STAB s08-bez-object-sverki s03-object-rashoditsja KRASEN
STAB s09-avtor-ne-sdal s22-avtor-zhiv-bez-zamka KRASEN
STAB s10-vtoroj-sudja s05-vtoroj-sudja-zhiv KRASEN
STAB s11-uzhe-suzhen s06-object-uzhe-suzhen KRASEN
STAB s12-bez-rabochego s08-rabochego-net KRASEN
STAB s13-klass-riska-mjagko s13-klass-riska-net KRASEN
STAB s14-bez-adv-do-rev s09-adv-do-rev KRASEN
STAB s15-bez-pauzy w10-pauza KRASEN
STAB s16-slovo-vsegda w15-limit-mob-chetyre KRASEN
STAB s17-done-net w17-limit-done-osvobozhdaet KRASEN
STAB s18-gruppa-vsegda-harness w19-gruppa-iz-pina KRASEN
STAB s19-bez-dublja-v-pakete b02-dubl-v-pakete KRASEN
STAB s20-otkaz-ne-ostanavlivaet b03-smeshannyj-otkat KRASEN
STAB s21-bez-atomarnosti b04-gonka-dva-protsessa KRASEN
STAB s22-bez-starta w01-pervyj-rabochij KRASEN
STAB s23-pustota-prohodit g04-bityj-vhod KRASEN
STAB s24-sudi-propusk s01-sudja-posle-yield KRASEN
STAB s25-bez-pin-rashozhdenija s14-pin-rashozhdenie KRASEN
STAB s26-uchet-bez-zhurnala u01-uchet-svod KRASEN
STAB s27-pauza-schitaetsja w18-limit-pauza-osvobozhdaet KRASEN
SVJAZI 27
[exit=0]
```

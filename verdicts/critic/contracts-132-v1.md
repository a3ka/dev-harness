accept
OBJECT=19d3c5c618be14e4bbace1230bae9e912098ab42

Суд только по «Перечень правок» и «Приёмка микро-круга» `verdicts/arbitration/contracts-132-krug3-kap.md`. Блокирующих находок: 0.

- П-1/П-2: `contracts/132-ekran-shablon.md:25,27,54-55,68`; `P --model` rc 0 (35/35); `P --stabs` rc 0 (32 KRASEN / SVJAZI 32). s19 красен на А1–А3, s20 красен на Б1–Б2. Отдельный прямой CLI эталона на свежих `probe.build_pack`/`probe.build_repo`: А1–А3 rc 1 `LITERAL_VNE_AUDITA batareja/red_ekrana.sh:7`; Б1 rc 1 `NE_TSELIKOM Old screen only`; Б2 rc 1 `CHUZHIE_KADRY Splash dark` и `Splash light`; Б3 rc 1 `ZAMENJAET_NE_POLON fixtures/workshop_project/old_screen_002/kadry.json`.
- П-3/П-4: `contracts/132-ekran-shablon.md:25,55,100,108-117,119-121` — обещание сужено до трёх классов, остаточные нотации дословно перечислены, опровергнутая оговорка об аргументе-дайджесте снята; прямой CLI: А4 (`16.dp`/`22.sp`) и А5 (`red`, `Color.Red`, голое `0xFFF3F2EE`) rc 0. Честная пачка rc 0, `KADR Splash dark 0.783` / `Splash light 0.782`, `SHABLON demo-vkhod OK`.
- П-5/П-6: `contracts/132-ekran-shablon.md:65-70,74-79,92,125-130` — `P` rc 1 `SHABLON_ABSENT` и 35 KRASNO, отдельный подсчёт source.json: 35 входов, 20 стабов, 32 связи. Сравнение с b4da9518b: правки ограничены контрактом и семейством `fixtures/workshop_project/ekran_shablon_132/`; грамматика 17 полей, меры З/Е, раннер 123 и зоны не менялись.

ФОРК: n117-first-run-sverka
ВОПРОС: Complior-mob#114 (`cmp-mob-117/vkhod` @ `2e005cc08`, run 39649735473, job android-e2e 119396951336): всё до сверки зелёное (995 native rc=0 testcases=6; Maestro-прогон по двум темам), красным остаётся ШАГ СВЕРКИ 123 (`python3 .harness123/scripts/sverka_maketa.py --manifest …/kadry_117.json --kadry mobile/maestro-out-117`): `Splash dark 0.783 / Splash light 0.782` (порог 0.600) — OK; `First-Run dark 0.000` и `First-Run light 0.000` (худший элемент wordmark, порог 0.600) — NIZHE_POROGA, rc 1. [ИНФЕРЕНЦИЯ, кадр не смотрен: ровно 0.000 на обеих темах указывает скорее на несовпадение раскладки/кадра, чем на тонкую цветовую разницу.] Варианты: (А, рекомендация) посмотреть кадр `vkhod-117-first-run` из артефакта `maestro-117-a9360ad4fc3ba2c109ef9c529115c9e7819525b7-39649735473-1` против `First-Run.png` и поправить либо экран 117 (implementer, зона mob), либо bbox/маску манифеста `kadry_117.json` (зона 123/architect; v+1 с РАЗРЕШИЛ-ВЛАДЕЛЕЦ, если правится текст frozen); (Б) сузить манифест до Splash dark/light по v2-сужению 117 (splash+иконка; F03/First-Run перенесены в first-run-ekran) — тогда First-Run-кадры вне сверки 117. Судей по кадрам (vision) до решения не зову: сверка 123 красная, а правило В требует зелёную сверку.
КЛАСС: инженерный
ПРИЗНАК: блокирует CI
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T19:10:00Z
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: да

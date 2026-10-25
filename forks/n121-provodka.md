ФОРК: n121-provodka
ВОПРОС: Контракт 121: судьи круга 3 — Adv121r3 accept (`verdicts/adversary/contracts-121-impl-v3.md`), Rev121r3 accept (`verdicts/review/contracts-121-impl-v3.md`, OBJECT b85230f21e30f8a82db43354849f61e028e6cfbc; `.review/2026-10-21-07.md` status ready — только советы A3/A4/A7/A8) в main. `done_contract.sh` ОТКАЗАЛ: «ПРОВОДКА красна: guard не подключён: fixtures/workshop_project/yadro_121/yadro_oracle.sh не вызывается в .githooks/ или .github/workflows/». Проводка (registry/ci-steps.tsv + ci-zamery.tsv + package.json + ci.yml) — вне зоны оркестратора. ПРЕДЛАГАЮ (рекомендация, прецедент n114-provodka → owner-коммит 184f58dce): применить готовый патч `/tmp/dev-harness-verify/orch/wire121.patch` owner-коммитом (`git apply --check` на main — OK; проверен в скретч-клоне: `verify_ci_parity` rc 0, 0 расхождений; `check_provodka.sh` на контракте 121 rc 0; `yadro_oracle.sh --model` rc 0, 24 декоя). После — я ставлю `done/contracts/121/1`. ПЛЮС (продукт, прежний форк n121-impl-push): запушить в Complior-back#153 коммиты `cbf42ad4`, `b85230f2` (клон `/tmp/dev-harness-verify/Impl121/back`, ветка `cmp-bck-003/yadro`, HEAD b85230f21e30f8a82db43354849f61e028e6cfbc); при merge — сквош A8 (FILES.sha256 на промежуточном коммите устарел).
ПРИЗНАК: норма
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T09:10:00Z
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: да

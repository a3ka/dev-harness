#!/usr/bin/env bash
# ПРИЧИНА: контракт-ссылка
#
# Arbiter-резолюции в verdicts/arbitration/ названы по номеру предмета-контракта
# (например `043-bs7-cmdline-pozicii-env-s.md` — резолюция по 8bf084e/d467f4e).
# До этого check_ids.sh трактовал их как VERDICT-класс (через roles/arbiter.md
# verdict:-объявления), ожидал id/VERDICT/<N> теги, и ВСЕ arbitration-файлы краснели
# как «номер N назначен рукой, а не механизмом» — ложное красное, потому что
# arbitration пишется мимо mint-механизма 031.
#
# Решение владельца 2026-09-25 (через орк-канал): verdicts/arbitration/ — ОТДЕЛЬНЫЙ
# класс ARBITRATION (link-class). Ведущие 3 цифры в имени — ССЫЛКА на предмет-контракт,
# сверяемая на СУЩЕСТВОВАНИЕ контракта (id/CONTRACT/<N> или contracts/<N>-*.md), а не
# на id/VERDICT/<N>. Файлы без номера (oblast-i-porog.md) остаются вне грамматики.
#
# Положительный контроль: arbitration-файл `037-b4-...md` с контрактом 037 в виде
# `id/CONTRACT/037` ИЛИ черновика `contracts/037-*.md` — зелёный. Красное: arbitration-файл
# `999-b4-...md` без контракта 999 — барьер видит «контракт-ссылка 999 не разрешается».
set -euo pipefail

cd "$WORK"
git init -q .
git config user.email "fixture@test"
git config user.name "fixture"
git config commit.gpgsign false
git config core.hooksPath /dev/null

# Контракт 037 как ЧЕРНОВИК: contracts/037-toy.md (без минта — это draft-форма,
# validate_contract_ref ищет contracts/<N>-*.md, что покрывает и черновики, и
# замёрзшие файлы).
mkdir -p contracts verdicts/arbitration
printf '# контракт 037 — toy (черновик)\n' > contracts/037-toy.md
git add contracts/ verdicts/
git commit -q -m "contract 037 draft"
# Минтим id/CONTRACT/037 — иначе CONTRACT-класс ругает «назначен рукой» (037 без тега).
# Замёрзший тег покрывает и resolve_contract_ref (прямой id/CONTRACT/<N>).
git tag id/CONTRACT/037 -m "выдача механизмом"

# Две arbitration-резолюции по ОДНОМУ контракту — один контракт может иметь НЕСКОЛЬКО
# резолюций (Б4, БС7 и т.д.). Это НЕ дубль — uniqueness-ключ для ARBITRATION это
# ПОЛНЫЙ basename (контракт+слаг).
printf '## Решение по 037/Б4\n' > verdicts/arbitration/037-b4-test.md
printf '## Решение по 037/БС7\n' > verdicts/arbitration/037-bs7-test.md
git add verdicts/arbitration/
git commit -q -m "arbiter резолюции 037"

# Положительный контроль: arbitration-файлы ссылаются на СУЩЕСТВУЮЩИЙ контракт 037
# (через черновик contracts/037-toy.md) — зелёные.
"$BARRIER" "$WORK"

# Обман: arbitration-файл с НЕсуществующим контрактом 999 — барьер должен увидеть
# «контракт-ссылка 999 не разрешается» (нет ни id/CONTRACT/999, ни contracts/999-*.md).
printf '## Решение по несуществующему 999\n' > verdicts/arbitration/999-b4-test.md
git add verdicts/arbitration/
git commit -q -m "arbiter резолюция 999 (контракт отсутствует)"

"$BARRIER" "$WORK"

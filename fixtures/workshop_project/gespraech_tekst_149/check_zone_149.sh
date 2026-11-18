#!/usr/bin/env bash
# Scoped evidence for Crit149V6 K-04; not a product or battery check.
set -euo pipefail
contract="${1:-contracts/149-gespraech-tekst-chat.md}"
grep -Fxq 'ЗОНА implementer: docs/ux/05_Kompakt_D24/motion/motion-spec-gespraech-kompakt-149.json' "$contract"
grep -Fxq 'Пути продуктовых ЗОНА implementer — от корня Complior-mob. В docs/ux/05_Kompakt_D24/motion/ исполнитель 149 создаёт только motion-spec-gespraech-kompakt-149.json как производный источник И-12 с происхождением и sha256; оригиналы пакета, motion-delta.md, motion-delta-frames/, source/, frames/, README_RU.md, SHA256SUMS и производный motion-spec-gespraech-kompakt-147.json не меняются. Производный файл не становится новым дизайнерским каноном. Его доставка и dvizhenie.spec/spec_sha256 в mobile/e2e-gespraech-tekst/ekran.json — работа implementer 149 после freeze, в том же продуктовом PR, с приёмкой по И-12 и критерию 7.' "$contract"
grep -Fxq -- '- компактный источник motion-spec-gespraech-kompakt-149.json и новый dvizhenie.spec/spec_sha256 — implementer после заморозки в объявленной точной зоне docs/ux/05_Kompakt_D24/motion/motion-spec-gespraech-kompakt-149.json; красный SPEC_NET_ILI_NE_JSON на прежнем кандидате не выдаётся за дефект регистрации К-08.' "$contract"
printf 'ZONA_149_VYDANA\n'

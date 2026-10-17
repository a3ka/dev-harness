ФОРК: n-991-cloud-runner-disk-space
ВОПРОС: `.github/workflows/mobile-cloud-e2e.yml` (КАРКАС контракта 991, запрет по
умолчанию, изменяемо только названными дельтами Д1–Д4 — §contracts/991 строки
107-119) падает ДВА РАЗА ПОДРЯД на одной и той же причине, НЕ связанной с
Maestro-версией или workflow_dispatch (то, что чинили Рв991-FP-1/FP-2): шаг
`Эмулятор API 36 + сценарии Maestro` (`reactivecircus/android-emulator-runner@v2`)
падает на `sdkmanager --install 'system-images;android-36;google_apis;x86_64'` с
`No space left on device` (GH-hosted `ubuntu-24.04` раннер исчерпывает диск ДО
установки системного образа эмулятора — gradle-сборка release-APK + toolcache уже
занимают место). Живая проверка: `gh run list --repo a3ka/Complior-mob --workflow
mobile-cloud-e2e.yml` показывает РОВНО ДВА прогона за всю историю workflow (оба
мои, сегодня, оба `failure`, идентичная причина в логе шага) — это не флуктуация
одного запуска, это первый реальный прогон workflow вообще (файл существовал на
main ДО базы 991 `dc396b6`, т.е. не добавлен контрактом, но ни разу не
исполнялся до сегодняшнего workflow_dispatch).

Контракт 991 требует именно этот прогон как положительное cloud-evidence (шаг 6→7
контракта, см. HANDOFF «Следующей сессии»/обе `## ГДЕ МЫ`). Без прогона —
приёмка 991 недостижима. Карта контракта не предусматривает дельту на
disk-space: Д1 (APK upload), Д2 (maestro upload error), Д3 (Maestro 2.11.0 +
version check), Д4 (rehearsal evidence check) — ни одна не трогает шаг установки
SDK/эмулятора. Добавление шага очистки диска (`rm -rf /usr/share/dotnet
/usr/local/lib/android/sdk/ndk /opt/ghc` или готовый action
`jlumbroso/free-disk-space`) ПЕРЕД `Install Android SDK` — минимальная правка вне
названных Д1–Д4, то есть вне допуска implementer по тексту §109 без v+1.

КЛАСС: дизайн
ПРИЗНАК: инфраструктура CI (кросс-репо, GH-hosted раннер)
МАРШРУТ: со-ревью

ЗАВЕДЁН: 2026-10-17T16:56:12Z
АВТОР: orchestrator (anthropic/claude-sonnet-5)

БЛОКИРУЕТ: да — без v+1 (новая дельта Д5: шаг освобождения диска в
`mobile-cloud-e2e.yml` ПЕРЕД установкой Android SDK/эмулятора, с architect-текстом
и критик/owner допуском) cloud e2e прогон контракта 991 не может завершиться
успехом НИ РАЗУ на GH-hosted раннере независимо от содержимого #106/#107 —
повтор дозвона бессмыслен без правки каркаса.

ОТВЕЧЕНО: нет

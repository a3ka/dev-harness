# Mission · Bildschirmvertrag (F05)
## Воля владельца
F05.01–F05.06 und F05.V03 folgen strikt ihren PNG-Maketen; F05.07, V01, V02, V04
sind ohne PNG nach Komponenten und Tokenen D2.2.5.1 gebaut (Sverka nach Designer-Paket).
## Существующее
108: Composer-Fläche; 123: Bildvergleich; 132: Bildschirmform; 117/118: Start-Pfad.
## Инварианты
Ein Mission-Gespräch: Text und Anhang im selben mission_id; Entwurf bleibt bei
Anhang, Offline-Fehler und Wiederholung; already_accepted erzeugt kein Duplikat;
interrupted wird nie als fertige Antwort gezeigt; neues Thema = neuer Intent ohne
privaten Kontext; widerrufene Quelle öffnet nicht aus altem Exchange.
F05.03: Tab-Leiste überdeckt die Vorlage — bbox nur über dem lesbaren Teil.
## Приёмочный критерий
android-e2e rc 0; jeder Bildscore aus 123 ist mindestens sein Manifest-Grenzwert.
Vor jedem Bild steht ein Übergang und ein eigener Selektor; keine Bytekopie.
Die vier PNG-losen Rahmen: Strukturprobe Zustand/Kopie/Token/testID rot bei
Erfundener Kopie, Token außerhalb tokens.css, Selektor ohne Fläche.
## Зоны и исполнители
ЗОНА architect: contracts/116-cmp-mob-005-mission.md fixtures/workshop_project/mission_116/
ЗОНА implementer: mobile/src/features/conversation/
ЗОНА implementer: mobile/src/ui/conversation-composer/
ЗОНА implementer: mobile/.maestro/
ЗОНА implementer: mobile/e2e-mission/
ЗОНА implementer: .github/workflows/mobile.yml
## ПРОВОДКА
Produkt-CI führt Formprüfung und Provenienzprüfung nach Maestro in einem Job aus.
## Модель угроз
ЗАЩИЩАЕТ: falsches Bild, fehlender Übergang, Bytekopie und erfundene Kopie werden rot.
НЕ ЗАЩИЩАЕТ: der Stand-in beweist keinen laufenden Emulator; Produkt-CI muss
Maestro ausführen; Pixel der vier PNG-losen Rahmen bis zum Designer-Paket.

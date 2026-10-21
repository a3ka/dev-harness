FAIL
OBJECT=cb04074f9652d6c671d90349d2bcbb8fb595e910

Найдены два наблюдаемых обхода И-6 в scripts/connect_project.sh; оба пропущены зелёной батареей.

1. Короткое значение секрета.
Строка 123 строит список для сканирования так: `sed ... "$DOM_SEKRETOV" | awk 'length($0) >= 8'`. Контракт не задаёт минимальной длины секрета: значение `METERING_PROXY_TOKEN=short` является значением дома секретов и не может попадать в файл, индексируемый git. Репро `.adversary_short_secret.sh`: в git-клоне создан отслеживаемый `leak.txt` с `secret=short`; подменён только workshop-маркер. Фактически rc=0 и stdout `WORKSHOP-RUN`, вместо rc=1 с `sekret-v-dereve`. Секрет в отслеживаемом файле остаётся, сессия запускается.

2. Отсутствующий инструмент маскируется успехом.
Сканирование не fail-closed: сбой `awk` в той же строке оставляет пустой файл значений, а код продолжает до exec workshop. Репро `.adversary_no_awk.sh`: в PATH есть все нужные для сценария утилиты, кроме awk; секрет обычной длины `very-secret-value` лежит в отслеживаемом `leak.txt`. Фактически rc=0, stderr `scripts/connect_project.sh: line 123: awk: command not found`, затем stdout `WORKSHOP-RUN`; ожидаем именованный отказ без запуска сессии. Это класс «инструмент мимо PATH / отказ выглядит успехом».

Проверка не ловит эти состояния: `bash fixtures/workshop_project/sessii_125/red_sessii_125.sh` — rc 0, 70/0; `--model` — rc 0, 70/0; `--stabs` — rc 0, стабов 37, привязок 128, непойманных 0. Негативный контроль сева честен: после удаления блока сева в отдельном клоне батарея дала rc 1, 66/4, красны ровно b02-sev-pobajtno b03-drejf b04-zapis-ne-v-dev b08-sverka-chestnaya.

Дополнительное нарушение приёмки Н-391: `bash scripts/verify_antiplacebo.sh --scope check_project_session connect_project` — rc 1: для обоих новых барьеров нет fixtures/<ключ>/case_*.sh.

Не блокирующие зелёные замеры: `bash scripts/pre_critic.sh contracts/125-sessii-proektov.md` — rc 0, «КРИТИК: дверь зелёная»; 11 батарей наследия дали rc: profil_dva_sloja=0, izoljacija_projectid=1, sharing_agentdb=0, config_do_overlay_105=0, ext_ustanovki_105=0, otkaz_flagov_105=0, proba_odin_kod_105=0, roli_v_profil_105=0, samodostatochnost_repo_060=0, github_token_070=0, sverka_puti_profylja=0.

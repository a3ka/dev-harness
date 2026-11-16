# Обманный стаб: lane-форма F2 потеряла закрытую привязку — корневой
# package.json объявляет ci:zamer другим значением (dispatch не обязан
# вести к пиннованному zamer_obryva.sh): KANON_150_LANE.
import json


def mutiruj(koren):
    p = koren / 'package.json'
    paket = json.loads(p.read_text(encoding='utf-8'))
    paket['scripts']['ci:zamer'] = 'bash mobile/scripts/nikogda-net.sh'
    p.write_text(json.dumps(paket, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

FAIL

OBJECT=3fbfc6e91dd1a8dc13ec09d93dcb47cc2e277520. Проверка закрытия F-1 пробита: красная батарея не отличает реализацию Г3, которая при `--freeze` вообще не сверяет объявленные `variable`, от честной реализации.

Обманная заглушка `probe_skip_variable_freeze.sh` была построена из честной модели Г3 удалением ровно ветви `- variable … -> check_kind variable`; остальная логика, включая проверку secret, сохранена. Прогон:

`PYTHONDONTWRITEBYTECODE=1 CI_PROEKTA_122_GATES=./probe_skip_variable_freeze.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model`

дал rc=0, `ИТОГ 122 (model): клеток 45, зелёных 45, красных 0`.

Причина обхода наблюдаема: z2 делает одновременно отсутствующим `PILOT_DEMO_CODE` (secret) и оставляет `NPM_TOKEN` (variable). Гейт честно отказывает на первом отсутствующем secret, поэтому пропущенная ветвь variable ни разу не исполняется. Контракт §Г3 требует инвентаризацию каждого declared secret/variable, а не только первого класса.

Позитивный контроль и минимальный контрпример (`probe_variable_freeze_control.sh`): единственное объявление `- variable ONLY_VARIABLE`, фикстурный `gh variable list` успешно возвращает пустой инвентарь. Настоящий субъект OBJECT: rc=1, `sekrety-ne-zavedeny: ONLY_VARIABLE`; построенная заглушка: rc=0, `PREDPOSYLKI_OK secrets=0 variables=1 environments=0 settings=0`. Значит зелёная батарея у заглушки — дефект проверки, а не шум/вечно-красный тест.

Требуемая правка архитектора: отдельная отрицательная клетка `--freeze` с variable-only контрактом и успешным `gh variable list`, где имя отсутствует; ожидаются rc=1 и `sekrety-ne-zavedeny: <variable>`. После этого повторить мутант выше.

Дополнительные прогоны (все в одноразовом клоне):
- настоящая батарея: rc=0, 45/45;
- честная модель (позитивный контроль): rc=0, 45/45;
- текстовый `--check` вместо байтов: rc=1, 43/2 (g8 CRLF и CR);
- мутант без сверки `if`: rc=1, 43/2;
- мутант без сверки `with`: rc=1, 44/1;
- мутант рабочего каталога без вложенности: rc=1, 42/3; полу-починка от исходного R: rc=1, 44/1;
- константный генератор: rc=1, 27/18; слепой Г3: rc=1, 41/4; всегда-успех и всегда-отказ Г3: rc=1, 38/7 каждый;
- пустая/неизвестная выборка `--cell net-takoj`: rc=2;
- `probe_gh_127.sh`: rc=1, `gh-nedostupen: gh secret list rc=127` (PATH/127 fail-closed);
- `bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md`: rc=0, `КРИТИК: дверь зелёная`;
- зона дельты `b3bc3399d..OBJECT`: ровно `scripts/{ci_preflight,freeze_contract,gen_project_workflow,pre_critic}.sh`; `git diff --check`: rc=0.

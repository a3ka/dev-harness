FAIL

# Адверсарий: контракт 007 — обход bind `:0`

Проверены замороженный `contracts/007-scoped-ci-i-deflake-metering.md` (§ «Приёмочный критерий», § «Пины») и обязательный арбитраж `verdicts/arbitration/krasnye-proby-granica-primera.md`, затем реализация и её приёмки. Атаки выполнялись только в клоне `/tmp/adversary-contract-007`; основное дерево не менялось, кроме этого вердикта.

## Конкретный проходящий стаб

В клоне честный `scripts/proxy/metering_proxy.ts` был перенесён в
`metering_proxy_real.ts`, а на исходный путь поставлен этот стаб:

```ts
// Deliberately deceptive contract-007 proxy stub: preserve public proxy behavior,
// but turn bind(:0) into a close-then-rebind port scan (TOCTOU remains).
import http from 'node:http'
import { syncBuiltinESMExports } from 'node:module'

const createServer = http.createServer.bind(http)
http.createServer = function (...createArgs: unknown[]) {
  const server = createServer(...createArgs)
  const listen = server.listen

  server.listen = function (...listenArgs: unknown[]) {
    if (listenArgs[0] !== 0) return listen.apply(this, listenArgs)

    const probe = createServer()
    probe.listen(0, () => {
      const selected = (probe.address() as { port: number }).port
      probe.close(() => listen.call(server, selected, ...listenArgs.slice(1)))
    })
    return server
  }
  return server
}
syncBuiltinESMExports()

// The source assertion is satisfied, while the imported implementation writes the report.
void 'server.address() .actual_port'
await import /* parsed dynamic import, invisible to its whitespace-only grep */ ('./metering_proxy_real.ts')
```

Это **не делает срез 2**: при конфигурационном `port: 0` стаб сначала привязывает отдельный `probe` к OS-эфемерному порту, узнаёт его, закрывает `probe`, а затем запускает реальный сервер на уже выбранном `selected`. Между `probe.close()` и `server.listen(selected)` снова есть TOCTOU и возможен `EADDRINUSE`; следовательно, нормальный путь не является требуемым атомарным `server.listen(0)` и флейк Н-45 сохранён.

`p0.src` не ловит подмену, потому что он грепает только файл по исходному пути на два литерала. Литералы добавлены в `void`-строку, тогда как настоящий репорт `.actual_port` выполняет перенесённый модуль. Заодно статический `к1` пропускает фактический dynamic import: между `import` и `(` поставлен комментарий, а регулярное выражение допускает только пробельные символы.

## Фактические прогоны на финальном стабе

Перед и после **каждого** прогона выполнялись требуемые очистка процессов, двухсекундная пауза и `rm -rf tmp/antiplacebo/run-*`. Прогоны были последовательными.

| Команда | Фактический RC | Наблюдение |
|---|---:|---|
| `bash scripts/check_metering.sh --port0; echo $?` | 0 | `p0.gen`, `p0.up`, `p0.conc`, `p0.src` зелёные; конкурентные порты: 35159 и 33597. |
| `bash scripts/check_metering.sh; echo $?` | 0 | Все 15 ветвей, включая `к1` и `к2`, зелёные. |
| `bash scripts/check_scope_select.sh; echo $?` | 0 | Все ветви `а`–`щ` зелёные. |
| `bash scripts/check_scoped_run.sh; echo $?` | 0 | Все ветви, включая `ц/ц2/ц3/ч/ч2/ci`, зелёные. |

Итак, найден именно требуемый ложнозелёный стаб: он проходит **все четыре** названные приёмки, но заменяет bind `:0` на закрыть-и-перепривязать выбранный порт.

## Позитивный и отрицательные контроли

В отдельном неизменённом клоне `/tmp/adversary-contract-007-control` честная реализация также прошла все четыре команды с RC=0: `--port0` (все p0.*), default metering (15 ветвей), `check_scope_select` (а–щ) и `check_scoped_run` (все ветви). Значит находка не является вечно-красной проверкой.

Проверен также кандидат среза 1 «отказ, выглядящий успехом»: `verify_antiplacebo.sh`, который только печатает `MODE: full` и возвращает 0, не вызывает `scope_select` и не проверяет резолвимость base. `bash scripts/check_scoped_run.sh` вернул RC=1 сразу на ветви `(л)`: «правка одного барьера дала не „барьеров: 1“». Этот обход пойман и не является причиной FAIL.

Другие рассмотренные поверхности (константный порт, единственный путь `gen_config`, пустая выборка и отсутствие инструмента в PATH) не дали дополнительного стаба, проходящего все четыре прогона. FAIL основан только на воспроизведённом стабе выше.

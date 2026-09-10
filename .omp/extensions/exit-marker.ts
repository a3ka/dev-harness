// Расширение omp: маркер [exit=N] в каждом bash tool_result.
// Контракт 025 §Пачка B-2.
//
// tool_result-патчер: в КАЖДЫЙ bash tool_result дописывает строку `[exit=N]` из
// details харнеса (details.exitCode — независимая от эха агента мера;
// bash-tool-runtime.md). rc=0 с лживым `echo rc=1`/`echo rc=0` в выводе
// расходится с маркером — видимо судье по стенограмме.
//
// Два режима:
//   1. CLI: `node exit-marker.ts --judge '<json>'` — синтетический tool_result,
//      выход одна строка JSON {"append":"[exit=N]"|null} | rc 2.
//   2. Factory: default-export; omp грузит на старте, регистрирует tool_result
//      handler (или post-call патчер — по фактической схеме события omp).
//
// Фикстура red_marker_exit.sh гоняет judge CLI:
//   {"tool":"bash","result":{"exitCode":<N|null>,"output":"…"}}
//   → {"append":"[exit=N]"}     при N числовом
//   → {"append":"[exit=?]"}     при N === null
//   → {"append":null}           для не-bash

type JudgeInput = {
  tool: string;
  result?: { exitCode?: unknown; output?: unknown };
};

type JudgeOutput = { append: string | null };

export function judge(input: JudgeInput): JudgeOutput {
  if (input.tool !== 'bash') return { append: null };
  const r = input.result;
  if (!r || typeof r !== 'object') return { append: '[exit=?]' };
  const ec = r.exitCode;
  if (typeof ec === 'number' && Number.isFinite(ec)) {
    return { append: `[exit=${ec}]` };
  }
  if (ec === 0) return { append: '[exit=0]' };
  return { append: '[exit=?]' };
}

function runCLI(): void {
  const argv = process.argv.slice(2);
  const i = argv.indexOf('--judge');
  if (i === -1 || !argv[i + 1]) {
    console.error('FAIL: нужен --judge <json>');
    process.exit(2);
  }
  let input: JudgeInput;
  try {
    input = JSON.parse(argv[i + 1]);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error(`FAIL: невалидный JSON: ${msg}`);
    process.exit(2);
  }
  process.stdout.write(`${JSON.stringify(judge(input))}\n`);
  process.exit(0);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  runCLI();
}

// ── Фабрика расширения omp ────────────────────────────────────────────────────
// omp зовёт default-export на старте сессии. Регистрируем tool_result handler,
// который добавляет строку `[exit=N]` в каждый bash-результат. Источник N —
// поле result.exitCode из details харнеса, не разбор output.

type PiLike = {
  on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown;
};

// Структура tool_result-события omp проверяется инлайн (см. §Правила контракта
// 011: на границе с внешним поставщиком — проверка полей, не слепой каст).
function readExitCode(event: unknown): { tool: string; exitCode: unknown } {
  if (event === null || typeof event !== 'object') return { tool: '', exitCode: undefined };
  const e = event as Record<string, unknown>;
  const tool = typeof e.tool === 'string' ? e.tool : '';
  const result = e.result;
  if (result === null || typeof result !== 'object') return { tool, exitCode: undefined };
  const r = result as Record<string, unknown>;
  return { tool, exitCode: r.exitCode };
}

export default function register(pi: unknown): void {
  if (!pi || typeof pi !== 'object') return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;

  p.on('tool_result', (event: unknown) => {
    const { tool, exitCode } = readExitCode(event);
    const out = judge({
      tool,
      result: { exitCode, output: undefined },
    });
    if (out.append === null) return undefined;
    return { append: out.append };
  });
}

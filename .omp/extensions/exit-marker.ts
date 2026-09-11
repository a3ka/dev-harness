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

// Структура omp-события tool_result (замерено живым probe025, формат ИЗ ЭТОГО ПРОГОНА):
//   { role:'toolResult', toolName:'edit'|'bash'|..., toolCallId, content:[{text}],
//     details:{exitCode, timeoutSeconds, wallTimeMs, ...}, isError, timestamp }
// Раньше код читал e.tool/e.result.exitCode — оба undefined в новой форме, handler
// тихо возвращал undefined (нет append) и [exit=N] в tool_result не появлялся.
// Регрессия поймана живым probe025: bash false|true → exit 1, агент видел текст
// "(no output) ... Command exited with code 1", без маркера [exit=1].

function readToolAndExit(event: unknown): { tool: string; exitCode: unknown } {
  if (event === null || typeof event !== 'object') return { tool: '', exitCode: undefined };
  const e = event as Record<string, unknown>;
  const tool = typeof e.toolName === 'string' ? e.toolName : '';
  const details = e.details;
  if (details === null || typeof details !== 'object') return { tool, exitCode: undefined };
  const d = details as Record<string, unknown>;
  return { tool, exitCode: d.exitCode };
}

export default function register(pi: unknown): void {
  if (!pi || typeof pi !== 'object') return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;

  p.on('tool_result', (event: unknown) => {
    const { tool, exitCode } = readToolAndExit(event);
    const out = judge({
      tool,
      result: { exitCode, output: undefined },
    });
    if (out.append === null) return undefined;
    // omp API (shared-events.ts ToolResultEventResult) принимает content/details/
    // isError; поле append НЕ ВХОДИТ в схему и тихо игнорируется харнесом.
    // Дописываем маркер В ПОСЛЕДНИЙ текстовый блок content (или добавляем
    // новый блок, если текстовых нет). Так судья видит [exit=N] и в стенограмме,
    // и при ручном чтении.
    const ev = event as Record<string, unknown>;
    const content = Array.isArray(ev.content) ? (ev.content as Array<Record<string, unknown>>) : [];
    const newContent = content.map((c) => ({ ...c }));
    let lastTextIdx = -1;
    for (let i = newContent.length - 1; i >= 0; i--) {
      if (newContent[i] && newContent[i].type === 'text') { lastTextIdx = i; break; }
    }
    if (lastTextIdx >= 0) {
      const t = newContent[lastTextIdx];
      newContent[lastTextIdx] = { ...t, text: `${String(t.text ?? '')}\n${out.append}` };
    } else {
      newContent.push({ type: 'text', text: out.append });
    }
    return { content: newContent };
  });
}

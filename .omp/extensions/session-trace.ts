// Живое свидетельство ведущей сессии. Архивные строки остальных ролей
// собирает лаунчер; назначение модели не выдаётся за её фактический запуск.
import { mkdirSync, readFileSync, renameSync, writeFileSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';

type ModelEntry = { type: string; model?: string; resolvedModelIsFallback?: boolean };
type Context = {
  sessionManager: {
    getSessionFile(): string | undefined;
    getBranch(): readonly ModelEntry[];
  };
  models: { current(): { provider: string; id: string } | undefined };
};
type Runtime = {
  on(event: string, handler: (event: unknown, ctx: Context) => void): void;
  sendMessage(text: string, options: { deliverAs: string }): void;
};
const TOP_SESSION = /^\d{4}-\d{2}-\d{2}T.*_[A-Za-z0-9-]+\.jsonl$/;

export default function register(pi: Runtime): void {
  let publishedModel = '';
  const refresh = (_event: unknown, ctx: Context): void => {
    const file = ctx.sessionManager?.getSessionFile();
    if (!file || !TOP_SESSION.test(basename(file))) return;
    const home = process.env.HARNESS_SESSION_HOME;
    const model = ctx.models?.current();
    if (!home || !model) return;
    const identity = `${model.provider}/${model.id}`;
    const path = process.env.HARNESS_MODEL_TRACE ?? join(home, 'runtime', 'model-trace.tsv');
    try {
      let previous = '';
      try { previous = readFileSync(path, 'utf8'); } catch (error) {
        if ((error as NodeJS.ErrnoException).code !== 'ENOENT') throw error;
      }
      const rows = previous.split('\n').filter((row) => row && !row.startsWith('orchestrator\t'));
      const branch = ctx.sessionManager.getBranch();
      let selection: ModelEntry | undefined;
      for (let i = branch.length - 1; i >= 0; --i) {
        if (branch[i].type === 'model_change') {
          selection = branch[i];
          break;
        }
      }
      const ready = selection?.model === identity;
      if (ready) {
        // Отсутствующий optional-флаг означает обычный выбор (session.md).
        const status = selection.resolvedModelIsFallback === true ? 'denied' : 'allowed';
        rows.push(`orchestrator\t${identity}\t${status}`);
      }
      mkdirSync(dirname(path), { recursive: true });
      const temporary = `${path}.${process.pid}.new`;
      writeFileSync(temporary, `${rows.join('\n')}\n`, { mode: 0o600 });
      renameSync(temporary, path);
      process.env.HARNESS_MODEL_TRACE = path;
      // Не оставляем старое свидетельство, если live API и журнал разошлись.
      if (!ready) throw new Error('текущий model_change не подтверждает live model');
      publishedModel = identity;
    } catch (error) {
      publishedModel = '';
      pi.sendMessage(`TRACE_NOT_READY: ${String(error)}; make_task не получает вымышленного свидетельства.`, { deliverAs: 'nextTurn' });
    }
  };
  pi.on('session_start', refresh);
  pi.on('before_agent_start', refresh);
  pi.on('tool_call', (event, ctx) => {
    const model = ctx.models?.current();
    if (model && `${model.provider}/${model.id}` !== publishedModel) refresh(event, ctx);
  });
}

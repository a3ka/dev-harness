// ОБМАННЫЙ СТАБ s7 (контракт 129): цикл смены/повтора без предела — на каждом
// ходе, оборванном исчерпанием (429 с ожиданием сверх retry.maxDelayMs), сессия
// сама себе ставит новый ход «продолжи на запасной модели». Списочный цикл
// (чередование запасная/примарий в model[]) omp гасит сам — замер 2026-10-21:
// подавленные селекторы цепочки не перебираются повторно; поэтому цикл
// реализуется повторными ходами. Различим в клетке c5 (исчерпаны все).
export default function register(pi: unknown): void {
  const p = pi as {
    on: (n: string, h: (ev: unknown) => unknown) => unknown;
    sendUserMessage: (content: string, opts?: { deliverAs?: string; attribution?: string }) => unknown;
  };
  p.on('message_end', (ev: unknown) => {
    const m = (ev as { message?: Record<string, unknown> }).message;
    const wait = /retry-after-ms=(\d+)/.exec(String(m?.errorMessage ?? ''));
    if (m?.role === 'assistant' && m.errorStatus === 429 && wait && Number(wait[1]) > 300_000) {
      setTimeout(() => { p.sendUserMessage('Повтори на запасной модели.', { deliverAs: 'followUp', attribution: 'agent' }); }, 50);
    }
    return undefined;
  });
}

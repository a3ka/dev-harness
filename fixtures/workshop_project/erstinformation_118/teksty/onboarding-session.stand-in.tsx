// stand-in production-крючка срока (118 v2 круг 1, блокер 1): composition
// root app/onboarding-session.tsx несёт проверку срока сессии ДЕЙСТВИТЕЛЬНЫМ
// для приложения способом — Date.parse(expires_at) > Date.now() в момент
// чтения порта (не кэш монтирования, не строковое сравнение, не тип string).
// Экспорт-формы сокращены до проверяемого шва; полная реализация —
// implementer 118 по пин-форме kontrakt пачки.
export function srokDejstvitelen(payload: { expires_at: string }): boolean {
  return Date.parse(payload.expires_at) > Date.now();
}

export function isSessionPayload(value: unknown): boolean {
  if (typeof value !== 'object' || value === null) return false;
  const payload = value as Record<string, unknown>;
  return (
    typeof payload.principal_ref === 'string' &&
    payload.principal_ref !== '' &&
    typeof payload.display_name === 'string' &&
    typeof payload.auth_time === 'string' &&
    typeof payload.expires_at === 'string' &&
    typeof payload.locale === 'string' &&
    Array.isArray(payload.disclosure_requirements)
  );
}

/** Порт допуска: срок сессии читается В МОМЕНТ действия (getter), не
 * кэшируется на монтировании — истечение между mount и действием закрывает
 * допуск W0 (fail-closed). */
export function portDopuska(session: { expires_at: string } | null): {
  get admission(): 'W1A' | 'W0';
} {
  return {
    get admission() {
      return session !== null && Date.parse(session.expires_at) > Date.now()
        ? 'W1A'
        : 'W0';
    },
  };
}

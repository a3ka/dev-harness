#!/usr/bin/env bash
# НЕ БАРЬЕР: библиотека, а не гейт. Решение о выдаче/минте/заморозке принимает тот, кто
# её подключил; библиотека только СЧИТАЕТ множество активных NNN контрактов по ЖИВОМУ
# `git ls-remote origin` (контракт 078 §Инварианты И-1, И-2). Классификация объявлена
# явно, потому что `scripts/verify_antiplacebo.sh` требует от каждого барьера фикстуру
# и не догадывается: файл без объявленной роли — отказ.
#
# Контракт 078 §И-1/И-2/И-6: N активен ⟺ (∃ refs/tags/frozen/contracts/N/* на origin ∨
# ∃ refs/heads/wip/N/* на origin) ∧ ¬∃ refs/tags/done/contracts/N/* на origin. NNN —
# ровно три цифры. Источник — живой ls-remote origin (три паттерна: frozen, done, wip);
# локальные refs, теги и рабочее дерево для счёта не читаются — новая wip-ветка на
# origin иначе осталась бы невидимой (dual-control 068, тот же прецедент).
#
# Дедуп пересечения пространств: act — МНОЖЕСТВО, оба пространства пишут ОДИН ключ
# act[k]=1 (не инкремент, не отдельные ключи) — NNN, лежащий и в frozen, и в wip,
# активен ОДИН раз. Обход double_namespace, находка критика 078 к2 (стаб-Ж батареи
# ломает именно это).
#
# FAIL-CLOSED (И-2): remote origin не настроен ИЛИ ls-remote отказал → rc 1, в stderr
# именованный отказ «авторитет недоступен, данные неизвестны — fail-closed». Имя
# отказа ОТДЕЛЬНО от «лимит превышен» (прецедент 068: «авторитет недоступен» — не
# санкция, обрыв сети ≠ лимит). При недоступном origin число и список активных НЕ
# выдумываются (И-9).
#
# active_contracts_list <КОРЕНЬ>
#   Печатает активные NNN (отсортированные, по одному в строке) в stdout; rc 0.
#   rc 1 — авторитет недоступен, в stderr именованный отказ fail-closed. Тело awk
#   живёт в одном экземпляре (прецедент parse_artifact_basename, lib_registry): три
#   скрипта импортируют одну и ту же функцию и переизобретение разбора ref'ов в
#   потребителях запрещено.

# Герметичность нужна и библиотеке: она зовёт git, а унаследованные переменные подменяют
# предмет до первой команды. Снимается здесь, а не у вызывающего, чтобы не зависеть от
# его аккуратности (тот же приём, что в lib_registry.sh:108-110).
active_contracts_list() {
  local root="${1:?использование: active_contracts_list <корень>}"
  command -v git >/dev/null 2>&1 || {
    printf 'ОТКАЗ: лимит активных контрактов: авторитет недоступен (нет git), данные неизвестны — fail-closed\n' >&2
    return 1
  }

  if ! git -C "$root" remote get-url origin >/dev/null 2>&1; then
    printf 'ОТКАЗ: лимит активных контрактов: авторитет недоступен (remote origin не настроен), данные неизвестны — fail-closed\n' >&2
    return 1
  fi

  local refs ls_rc=0
  refs="$(git -C "$root" ls-remote origin 'refs/tags/frozen/contracts/*' 'refs/tags/done/contracts/*' 'refs/heads/wip/*' 2>/dev/null)" || ls_rc=$?
  if [ "$ls_rc" -ne 0 ]; then
    printf 'ОТКАЗ: лимит активных контрактов: авторитет недоступен (ls-remote origin rc=%s), данные неизвестны — fail-closed\n' "$ls_rc" >&2
    return 1
  fi

  # И-1/И-6: разбор трёх пространств и счёт активных — один awk, множество внутри;
  # NNN — ровно три цифры, прочие ref-компоненты молча вне счёта.
  # Индексы split: frozen/done NNN = a[5] (refs, tags, frozen|done, contracts, NNN, v),
  # wip NNN = a[4] (refs, heads, wip, NNN, автор). Сдвиг индекса — измеренный дефект
  # первой редакции (клетка нарушА ловила «активных 0» живым прогоном).
  printf '%s\n' "$refs" | awk '
    $2 ~ /^refs\/tags\/frozen\/contracts\/[0-9][0-9][0-9]\// { split($2, a, "/"); f[a[5]]=1 }
    $2 ~ /^refs\/tags\/done\/contracts\/[0-9][0-9][0-9]\//   { split($2, a, "/"); d[a[5]]=1 }
    $2 ~ /^refs\/heads\/wip\/[0-9][0-9][0-9]\//              { split($2, a, "/"); w[a[4]]=1 }
    END {
      for (k in f) act[k]=1
      for (k in w) act[k]=1
      for (k in d) delete act[k]
      for (k in act) print k
    }' | sort -u
}

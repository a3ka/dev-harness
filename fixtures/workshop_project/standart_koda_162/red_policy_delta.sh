#!/usr/bin/env bash
# Independent counterexamples: claim appended alone is honest; an extra item,
# removed predecessor, or altered unrelated key must never pass the policy check.
set -euo pipefail
root="$(cd "$(dirname "$0")/../../.." && pwd)"
check="$root/fixtures/workshop_project/standart_koda_162/check_policy_delta.py"
before='{"mobileFiles":["keep","second"],"externalTrees":["api"]}'
claim='scripts/coding-standards-claims.tsv'
honest='{"mobileFiles":["keep","second","'"$claim"'"],"externalTrees":["api"]}'
output="$(printf '%s\n%s\n' "$before" "$honest" | python3 "$check" --pair)"
[[ "$output" == '162: policy delta OK' ]] || { printf 'ОТКАЗ фикстуры: честная пара красная\n' >&2; exit 1; }
for dishonest in \
  '{"mobileFiles":["keep","second","scripts/coding-standards-claims.tsv","undisclosed.tsv"],"externalTrees":["api"]}' \
  '{"mobileFiles":["keep","scripts/coding-standards-claims.tsv"],"externalTrees":["api"]}' \
  '{"mobileFiles":["keep","second","scripts/coding-standards-claims.tsv"],"externalTrees":["api","extra"]}'; do
  if output="$(printf '%s\n%s\n' "$before" "$dishonest" | python3 "$check" --pair 2>&1)"; then
    printf 'ОТКАЗ фикстуры: обманная пара принята: %s\n' "$dishonest" >&2
    exit 1
  fi
  [[ "$output" == *'ОТКАЗ 162: policy не одна разрешающая строка'* ]] || { printf 'ОТКАЗ фикстуры: неименованный отказ: %s\n' "$output" >&2; exit 1; }
done

#!/usr/bin/env python3
"""Check the isolated 162 policy change and its preservation after merging 143."""
import argparse
import json
import subprocess
import sys

POLICY = "mobile/structure-policy.json"
CLAIM = "scripts/coding-standards-claims.tsv"


def policy_pair(before, after):
    if not isinstance(before, dict) or not isinstance(after, dict):
        return False
    prior = before.get("mobileFiles")
    if not isinstance(prior, list) or CLAIM in prior:
        return False
    return after == {**before, "mobileFiles": [*prior, CLAIM]}


def git(repo, *args):
    return subprocess.run(["git", "-C", repo, *args], check=True, text=True, capture_output=True).stdout


def show_policy(repo, ref):
    return json.loads(git(repo, "show", f"{ref}:{POLICY}"))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo")
    parser.add_argument("--base")
    parser.add_argument("--feature")
    parser.add_argument("--main")
    parser.add_argument("--head")
    parser.add_argument("--pair", action="store_true", help="independent JSON-line counterexample input")
    args = parser.parse_args()
    try:
        if args.pair:
            if any((args.repo, args.base, args.feature, args.main, args.head)):
                parser.error("--pair and git range options are mutually exclusive")
            before, after = (json.loads(line) for line in sys.stdin.read().splitlines())
            if not policy_pair(before, after):
                raise ValueError("policy не одна разрешающая строка")
        else:
            if not all((args.repo, args.base, args.feature, args.main, args.head)):
                parser.error("--repo --base --feature --main --head обязательны")
            if git(args.repo, "diff", "--name-only", f"{args.base}..{args.feature}").splitlines() != [POLICY]:
                raise ValueError("diff содержит второй файл или не содержит политику")
            if git(args.repo, "diff", "--numstat", f"{args.base}..{args.feature}").splitlines() != [f"1\t1\t{POLICY}"]:
                raise ValueError("numstat: ожидалось 1 TAB 1 TAB mobile/structure-policy.json")
            if not policy_pair(show_policy(args.repo, args.base), show_policy(args.repo, args.feature)):
                raise ValueError("feature: policy не одна разрешающая строка")
            if not policy_pair(show_policy(args.repo, args.main), show_policy(args.repo, args.head)):
                raise ValueError("merge: policy не одна разрешающая строка")
    except (ValueError, subprocess.CalledProcessError, json.JSONDecodeError) as exc:
        print(f"ОТКАЗ 162: {exc}", file=sys.stderr)
        return 1
    print("162: policy delta OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())

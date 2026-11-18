#!/usr/bin/env python3
"""Executable model of 122/6's freeze leg (not a production freeze substitute).

The context transport is validated by JSON Schema. Identity/workflow paths are
resolved by the REAL candidate tools; Г3 is the real gate, real git writes the
station's tag and registry. Only the unrelated freeze gates are outside scope.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

import jsonschema

HERE = Path(__file__).resolve().parent


def call(args):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True,
                          timeout=20)


def git(root, *args):
    p = call(['git', '-C', root, '-c', 'user.name=fixture122', '-c',
              'user.email=fixture122@local', '-c', 'commit.gpgsign=false',
              '-c', 'core.hooksPath=/dev/null', *args])
    if p.returncode:
        raise ValueError(p.stderr)
    return p.stdout.strip()


def refusal(reason):
    print('ОТКАЗ: ' + reason, file=sys.stderr)
    return 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('root', type=Path)
    parser.add_argument('target')
    parser.add_argument('context', type=Path, nargs='?')
    parser.add_argument('--mutant', default='')
    args = parser.parse_args()
    root, target, mutant = args.root.resolve(), args.target, args.mutant
    try:
        if args.context is None:
            # Legacy single-repository CLI resolves its own project_workflow.
            env = dict(os.environ, HARNESS_PROJECT_LAYER_ROOT=str(root))
            resolved = subprocess.run(['bash', str(root / 'scripts/profile_resolver.sh'),
                                       '--repo', str(root)], env=env, text=True,
                                      capture_output=True, timeout=20)
            if resolved.returncode:
                return refusal('project-workflow-otsutstvuet')
            prof = json.loads(resolved.stdout)
            ctx = {'schemaVersion': 1, 'subject': {
                'root': str(root), 'path': target,
                'blob': git(root, 'rev-parse', 'HEAD:' + target),
                'origin': git(root, 'remote', 'get-url', 'origin')},
                'project': {'root': str(root), 'projectId': prof['projectId']['value'],
                            'repoId': prof['repoId']['value'],
                            'canonicalRemote': prof['git']['value']['canonicalRemote']}}
        else:
            ctx = json.loads(args.context.read_text())
    except (OSError, ValueError):
        if mutant != 'missing-context-ignored':
            return refusal('project-workflow-otsutstvuet')
        ctx = {'project': {'root': str(root)}}
    if isinstance(ctx, list):
        if mutant != 'ambiguous-context-first':
            return refusal('project-workflow-neodnoznachen')
        ctx = ctx[0]
    if mutant not in ('unchecked-context', 'missing-context-ignored'):
        try:
            schema = json.loads((HERE / 'project_workflow.schema.json').read_text())
            jsonschema.validate(ctx, schema)
            if mutant == 'restricted-identity':
                # Prior 122/6 schema, incompatible with resolver contract 054.
                jsonschema.validate(ctx['project']['projectId'],
                                    {'pattern': '^[a-zA-Z0-9][a-zA-Z0-9_-]*$'})
            s = ctx['subject']
            assert Path(s['root']).resolve() == root
            assert s['path'] == target
            assert s['blob'] == git(root, 'rev-parse', 'HEAD:' + target)
            assert s['origin'] == git(root, 'remote', 'get-url', 'origin')
            project = Path(ctx['project']['root']).resolve(strict=True)
            # Bind both the project and the exact repository within that project.
            # A path supplied by argv/env never supplies identity by itself.
            env = dict(os.environ)
            env['HARNESS_PROJECT_LAYER_ROOT'] = str(project)
            resolved = subprocess.run(['bash', str(root / 'scripts/profile_resolver.sh'),
                                       '--repo', str(project)], env=env, text=True,
                                      capture_output=True, timeout=20)
            assert resolved.returncode == 0, resolved.stderr
            prof = json.loads(resolved.stdout)
            for key in ('projectId', 'repoId'):
                assert ctx['project'][key] == prof[key]['value']
            remote = git(project, 'remote', 'get-url', 'origin')
            assert ctx['project']['canonicalRemote'] == prof['git']['value']['canonicalRemote'] == remote
            if project != root and mutant not in (
                    'unbound-project', 'binding-missing-ignored', 'binding-invalid-ignored'):
                # Independent authority: the actual committed subject, never a
                # declaration supplied by the transport or by the selected repo.
                prefix = 'ПРОЕКТ-ПРЕДПОСЫЛОК: '
                subject = git(root, 'show', 'HEAD:' + target)
                bindings = [line[len(prefix):] for line in subject.split('\n')
                            if line.startswith(prefix)]
                if mutant != 'binding-duplicate-first':
                    assert len(bindings) == 1
                declared = json.loads(bindings[0])
                jsonschema.validate(declared, {
                    '$schema': schema['$schema'], '$defs': schema['$defs'],
                    '$ref': '#/$defs/projectIdentity', 'unevaluatedProperties': False})
                keys = (['canonicalRemote'] if mutant == 'remote-only-binding'
                        else schema['$defs']['projectIdentity']['required'])
                assert {key: declared[key] for key in keys} == {
                    key: ctx['project'][key] for key in keys}
            # Resolve workflow context using the existing helper, not a new path convention.
            workflow = call(['bash', root / 'scripts/project_workflow.sh', '--repo', root])
            assert workflow.returncode == 0
            assert (root / target).resolve().is_relative_to(Path(json.loads(workflow.stdout)['contracts']).resolve())
        except (AssertionError, IndexError, KeyError, TypeError, ValueError, OSError, jsonschema.ValidationError):
            return refusal('project-workflow-rashozhdenie')
    project = Path(ctx['project']['root'])
    if mutant == 'mono-rejected' and project.resolve() == root:
        return refusal('project-workflow-rashozhdenie')
    inventory_root = root if mutant == 'station-inventory' else project
    checked = call(['bash', root / 'scripts/check_predposylki.sh', inventory_root,
                    root / target, '--freeze'])
    sys.stdout.write(checked.stdout)
    sys.stderr.write(checked.stderr)
    if checked.returncode and mutant not in ('missing-secret-ignored', 'gh-error-ignored',
                                             'unchecked-context', 'missing-context-ignored'):
        return 1
    writer = project if mutant == 'project-writer' else root
    tag = 'frozen/contracts/731/1'
    git(writer, 'tag', '-a', tag, '-m', 'fixture122 roots')
    sha = git(writer, 'rev-parse', '--verify', tag)
    registry = writer / 'registry/contracts.tsv'
    registry.parent.mkdir(parents=True, exist_ok=True)
    registry.write_text(f'731 → {sha}\n')
    git(writer, 'add', 'registry/contracts.tsv')
    git(writer, 'commit', '-qm', 'fixture122 registry')
    print('v1')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

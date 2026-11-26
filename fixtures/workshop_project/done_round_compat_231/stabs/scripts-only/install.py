import shutil
import subprocess


def install(work, carrier, tools_repo):
    tools = work / 'tools'
    shutil.copytree(tools_repo / 'scripts', tools / 'scripts')
    (tools / 'scripts/done_contract.sh').write_bytes(carrier)
    subprocess.run(['bash', '-n', tools / 'scripts/done_contract.sh'], check=True)
    return tools / 'scripts/done_contract.sh'

import json
import git
import argparse

parser = argparse.ArgumentParser(description='Updates the vscode source git repo working directory to be the commit hash mentioned in the given product.json file.')
parser.add_argument('--product_json', required=True, help='full path to the product.json file containing the commit hash')
parser.add_argument('--vscode_repo', required=True, help='full path to the vscode source git repo location')
args = parser.parse_args()

with open(args.product_json) as json_data:
    d = json.load(json_data)
    repo = git.Repo(args.vscode_repo)
    repo.git.reset('--hard', d['commit'])

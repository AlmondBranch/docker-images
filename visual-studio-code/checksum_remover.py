import re
import argparse

parser = argparse.ArgumentParser(description='Removes checksums from product.json since the docker image uses a different packaging format than the vscode team does.')
parser.add_argument('--product_json', required=True, help='full path to the product.json file containing the commit hash')
args = parser.parse_args()

with open(args.product_json) as f:
    original = f.read()

with open(args.product_json, 'w') as f:
    r = re.compile('"checksums"\s*:\s*\{(\n|\r|.)*?\}')
    f.write(re.sub(r, '"checksums": {}', original))



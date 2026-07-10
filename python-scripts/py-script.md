## Contents

- [ ] text-to-tree.py `to-do: convert to script from clipboad & update clipboard`
- [ ] a4_to_a5_booklet_manual.py `verify it's working`

## Execution

- Ensure packages are installed
  `python3 -m pip install pypdf`

- To run
  `python3 a4_to_a5_booklet_manual.py input.pdf output/booklet`

## Implement arguments

```
parser.add_argument() - argparse input arguments
args = parser.parse_args() - reads from cli
args.prefix - second positional argument
```

## migration from shell to python

- important to add try/except, logging, graceful recovery!
- subprocess & pathlib module - cli commands

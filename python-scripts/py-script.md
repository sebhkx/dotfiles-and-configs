## Contents

- [ ] text-to-tree.py `to-do: convert to script from clipboard & update clipboard`
- [ ] Image slicing & appending.py `pillow cut and append`

## Execution

- Ensure packages are installed
  `python3 -m pip install <>`

- To run
  `python3 script.py <input>`

## Implement arguments

```
parser.add_argument() - argparse input arguments
args = parser.parse_args() - reads from cli
args.prefix - second positional argument
```

## migration from shell to python

- important to add try/except, logging, graceful recovery!
- subprocess & pathlib module - cli commands

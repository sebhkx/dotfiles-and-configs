# make into shell command - pbpaste

#!/usr/bin/env python3
import sys

def text_to_tree(text: str) -> str:
    lines = [line.rstrip() for line in text.splitlines() if line.strip()]
    items = []

    for line in lines:
        indent = len(line) - len(line.lstrip(" "))
        name = line.strip()
        level = indent // 2  # change to 4 if you use 4-space indents
        items.append((level, name))

    out = ["."]
    for i, (level, name) in enumerate(items):
        is_last = True
        for next_level, _ in items[i + 1:]:
            if next_level == level:
                is_last = False
                break
            if next_level < level:
                break

        prefix = ""
        for parent_level in range(level):
            has_more_siblings = any(
                l == parent_level
                for l, _ in items[i + 1:]
            )
            prefix += "│   " if has_more_siblings else "    "

        branch = "└── " if is_last else "├── "
        out.append(prefix + branch + name)

    return "\n".join(out)


input_text = """
src
  app.py
  utils/
      io.py
tests/
README.md
"""

print(text_to_tree(input_text))

#!/bin/bash

# Default to current directory if no argument is supplied
ROOT_DIR="${1:-.}"

# Resolve to an absolute path (optional but nice)
ROOT_DIR="$(cd "$ROOT_DIR" 2>/dev/null && pwd)" || {
    echo "Error: Directory '$1' does not exist."
    exit 1
}

OUTPUT="folder_tree.html"

cat << 'EOF' > "$OUTPUT"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Foldable Folder Tree</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; font-size: 14px; line-height: 1.6; padding: 20px; background-color: #f6f8fa; color: #24292f; }
        details { margin-left: 16px; }
        summary { cursor: pointer; font-weight: 600; padding: 2px 4px; border-radius: 4px; outline: none; list-style-type: "📁 "; }
        details[open] > summary { list-style-type: "📂 "; }
        summary:hover { background-color: #eaeef2; }
        .file { margin-left: 32px; color: #57606a; }
        .file::before { content: "📄 "; }
        .container { background: white; border: 1px solid #d0d7de; border-radius: 6px; padding: 24px; max-width: 800px; margin: 0 auto; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
        .root { font-size: 18px; font-weight: 700; margin-bottom: 12px; }
    </style>
</head>
<body>
<div class="container">
EOF

echo "<div class=\"root\">$(basename "$ROOT_DIR")</div>" >> "$OUTPUT"

traverse() {
    local dir="$1"

    # Directories first
    for item in "$dir"/*; do
        [ -e "$item" ] || continue
        local name=$(basename "$item")
        [[ "$name" == .* ]] && continue

        if [ -d "$item" ]; then
            echo "<details><summary>$name</summary>" >> "$OUTPUT"
            traverse "$item"
            echo "</details>" >> "$OUTPUT"
        fi
    done

    # Then files
    for item in "$dir"/*; do
        [ -e "$item" ] || continue
        local name=$(basename "$item")
        [[ "$name" == .* ]] && continue

        if [ -f "$item" ]; then
            echo "<div class=\"file\">$name</div>" >> "$OUTPUT"
        fi
    done
}

traverse "$ROOT_DIR"

cat << 'EOF' >> "$OUTPUT"
</div>
</body>
</html>
EOF

echo "Success! Open $OUTPUT in your browser."
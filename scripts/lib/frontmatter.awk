# Parse a SKILL.md YAML frontmatter and print one field.
# Usage: awk -v want=name|desc -f frontmatter.awk SKILL.md
# Handles an inline `description:` and a YAML block scalar (`description: |`).
# Exit 2 if the file does not start with `---`.
BEGIN { infm = 0; endedfm = 0; name = ""; desc = ""; inblock = 0 }

NR == 1 {
    if ($0 !~ /^---[[:space:]]*$/) { exit 2 }
    infm = 1
    next
}

infm == 1 && endedfm == 0 {
    if ($0 ~ /^---[[:space:]]*$/) { endedfm = 1; next }

    if (inblock == 1) {
        # Indented (or blank) lines belong to the block scalar.
        if ($0 ~ /^[[:space:]]/ || $0 ~ /^[[:space:]]*$/) {
            line = $0
            sub(/^[[:space:]]+/, "", line)
            sub(/[[:space:]]+$/, "", line)
            if (line != "") desc = desc (desc == "" ? "" : " ") line
            next
        }
        inblock = 0   # a non-indented line ends the block; re-parse it as a key
    }

    if ($0 ~ /^name:[[:space:]]*/) {
        n = $0
        sub(/^name:[[:space:]]*/, "", n)
        sub(/[[:space:]]+$/, "", n)
        name = n
        next
    }

    if ($0 ~ /^description:[[:space:]]*/) {
        d = $0
        sub(/^description:[[:space:]]*/, "", d)
        sub(/[[:space:]]+$/, "", d)
        if (d ~ /^[|>][-+]?$/) {
            inblock = 1; desc = ""
        } else {
            sub(/^"/, "", d); sub(/"$/, "", d)
            desc = d
        }
        next
    }
    next
}

END {
    gsub(/[[:space:]]+/, " ", desc)
    sub(/^ /, "", desc); sub(/ $/, "", desc)
    if (want == "name") print name
    else if (want == "desc") print desc
}

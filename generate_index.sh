#!/bin/bash

OUTPUT_DIR=~/org/website
mkdir -p "$OUTPUT_DIR"

# Static header
cat > "$OUTPUT_DIR/index.html" <<'EOL'
<html>
<head>
    <title>Dylan's Blog</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=UnifrakturMaguntia&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="style.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
</head>
<body>
<div class="navbar">
    <a href="index.html">Home</a> | <a href="about.html">About</a>
</div>
<h1 class="rainbow-title">Dylan's Blog</h1>
<div class ="box"></box>

<div align="center" style="position: relative; top: 20px; margin-bottom: -10px;">
    <a href='https://www.counter12.com'>
        <img src='https://www.counter12.com/img-Aw9y22ZZbYdwd50w-24.gif' border='0' alt='web counter free'>
    </a>
    <script type='text/javascript' src='https://www.counter12.com/ad.js?id=Aw9y22ZZbYdwd50w'></script>
</div>

<div style="height: 0px;"></div>

<ul>
EOL

declare -A unique_tags
posts=()

# Extract metadata
for file in "$OUTPUT_DIR"/*.org; do
    filename=$(basename "$file" .org)

    title=$(awk -F': ' '/^#\+TITLE:/ {print $2}' "$file")
    subtitle=$(awk -F': ' '/^#\+SUBTITLE:/ {print $2}' "$file")
    date=$(awk -F': ' '/^#\+DATE:/ {print $2}' "$file")
    tags=$(awk -F': ' '/^#\+TAGS:/ {print $2}' "$file")
    convert=$(awk -F': ' '/^#\+CONVERT:/ {print $2}' "$file")

    [[ -z "$date" ]] && date="1970-01-01"

    timestamp=$(date -d "$date" +%s 2>/dev/null || echo 0)

    clean_tags=$(echo "$tags" | sed 's/,/ /g' | xargs)

    for tag in $clean_tags; do
        unique_tags["$tag"]=1
    done

    posts+=("$timestamp|$date|$filename|$title|$subtitle|$clean_tags|$convert")
done

IFS=$'\n' sorted_posts=($(sort -t '|' -rn <<<"${posts[*]}"))
unset IFS

# Generate HTML for each post
for post in "${sorted_posts[@]}"; do
    IFS='|' read -r timestamp pdate filename title subtitle tags convert<<< "$post"

    [[ "$filename" == "" ]] && continue
    [[ "$convert" != "yes" ]] && continue

    cat >> "$OUTPUT_DIR/index.html" <<EOL
    <li class="post-item">
        <a href="$filename.html" class="post-link">
            <strong class="post-title">$title</strong>
            <span class="post-date">($pdate)</span><br>
            <span class="post-subtitle">$subtitle</span>
        </a>
        <div class="post-tags">
EOL
    for tag in $tags; do
        # Kept the span, removed the onclick
        echo "            <span class='tag'>$tag</span>" >> "$OUTPUT_DIR/index.html"
    done

    echo "        </div>" >> "$OUTPUT_DIR/index.html"
    echo "    </li>" >> "$OUTPUT_DIR/index.html"
done

# JavaScript: Restored COLOR logic, removed FILTER logic
cat >> "$OUTPUT_DIR/index.html" <<'EOL'
</ul>

<div class="footer">© Dylan 2026. Written in Emacs Orgmode because I am the man, man.</div>

<script>
let tagColors = new Map();

const colorPalette = [
    "#CC241D", // Muted Red
    "#D79921", // Warm Yellow
    "#458588", // Teal Blue
    "#B16286", // Muted Magenta
    "#689D6A", // Forest Green
    "#D65D0E", // Rust Orange
    "#FABD2F", // Deep Golden Yellow
    "#83A598", // Cool Cyan
    "#FE8019", // Darker Orange
    "#928374", // Neutral Brown-Gray
    "#A89984", // Faded Taupe
    "#665C54", // Gruvbox Darker Gray
    "#3C3836", // Gruvbox Darkest Brown
];

function getTagColor(tag) {
    if (!tagColors.has(tag)) {
        let index = tagColors.size % colorPalette.length;
        tagColors.set(tag, colorPalette[index]);
    }
    return tagColors.get(tag);
}

document.addEventListener('DOMContentLoaded', () => {
    // Just color the tags, no filtering listeners
    document.querySelectorAll('.post-tags .tag').forEach(tagElement => {
        const tagText = tagElement.innerText.trim();
        tagElement.style.backgroundColor = getTagColor(tagText);
        tagElement.style.color = '#fff';
    });
});
</script>
</body>
</html>
EOL

echo "✅ Index successfully generated at $OUTPUT_DIR/index.html"

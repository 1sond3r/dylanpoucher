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
<link href="https://fonts.googleapis.com/css2?family=Ibarra+Real+Nova:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
</head>
<body>
<div class="navbar">
    <a href="index.html">Home</a> | <a href="about.html">About</a>
</div>
<h1 class="rainbow-title">Dylan's Blog</h1>
<div id="active-filters"><strong>  ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎  </strong></div>
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

    [[ "$filename" == "about" ]] && continue
    [[ "$convert" != "yes" ]] && continue

    cat >> "$OUTPUT_DIR/index.html" <<EOL
    <li class="post-item" data-tags="$tags">
        <a href="$filename.html" class="post-link">
            <strong class="post-title">$title</strong>
            <span class="post-date">($pdate)</span><br>
            <span class="post-subtitle">$subtitle</span>
        </a>
        <div class="post-tags">
EOL
    for tag in $tags; do
        echo "            <span class='tag' onclick=\"toggleFilter('$tag')\">$tag</span>" >> "$OUTPUT_DIR/index.html"
    done

    echo "        </div>" >> "$OUTPUT_DIR/index.html"
    echo "    </li>" >> "$OUTPUT_DIR/index.html"
done

# JavaScript (corrected and checked carefully!)
cat >> "$OUTPUT_DIR/index.html" <<'EOL'
</ul>
<div class="footer">© Dylan 2025. Written in Emacs Orgmode because I am the man, man.</div>
<script>
let activeFilters = new Set();

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


function updateFilters() {
    const posts = document.querySelectorAll('.post-item');
    const activeFilterContainer = document.getElementById('active-filters');

    if (activeFilters.size === 0) {
        posts.forEach(post => post.style.display = 'block');
        activeFilterContainer.innerHTML = '<strong>    ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎    </strong>';
        return;
    }

    posts.forEach(post => {
        const postTags = post.dataset.tags.split(' ');
        post.style.display = [...activeFilters].some(tag => postTags.includes(tag)) ? 'block' : 'none';
    });

    activeFilterContainer.innerHTML = '<strong> Filters: </strong>';
    activeFilters.forEach(tag => {
        const tagElement = document.createElement('span');
        tagElement.className = 'tag active-filter';
        tagElement.innerText = tag;
        tagElement.style.backgroundColor = getTagColor(tag);
        tagElement.style.color = '#fff';
        tagElement.onclick = () => toggleFilter(tag);
        activeFilterContainer.appendChild(tagElement);
    });
}

function toggleFilter(tag) {
    if (activeFilters.has(tag)) activeFilters.delete(tag);
    else activeFilters.add(tag);
    updateFilters();
}

document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.post-tags .tag').forEach(tagElement => {
        const tagText = tagElement.innerText.trim();
        tagElement.style.backgroundColor = getTagColor(tagText);
        tagElement.style.color = '#fff';
        tagElement.onclick = () => toggleFilter(tagText);
    });
});
</script>
</body>
</html>
EOL

echo "✅ Index successfully generated at $OUTPUT_DIR/index.html"

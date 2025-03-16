#!/bin/bash

OUTPUT_DIR=~/org/website
mkdir -p "$OUTPUT_DIR"

echo "<html><head><title>Dylan's Blog</title>" > "$OUTPUT_DIR/index.html"
echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> "$OUTPUT_DIR/index.html"
echo "<link href='https://fonts.googleapis.com/css2?family=Ibarra+Real+Nova&display=swap' rel='stylesheet'>" >> "$OUTPUT_DIR/index.html"
echo "<link rel='stylesheet' type='text/css' href='style.css'/>" >> "$OUTPUT_DIR/index.html"
echo "</head><body>" >> "$OUTPUT_DIR/index.html"

# Navbar
echo "<div class='navbar'>" >> "$OUTPUT_DIR/index.html"
echo "<a href='index.html'>Home</a> | <a href='about.html'>About</a>" >> "$OUTPUT_DIR/index.html"
echo "</div>" >> "$OUTPUT_DIR/index.html"

echo "<h1 class="rainbow-title">Dylan's Blog</h1>" >> "$OUTPUT_DIR/index.html"
echo "<ul>" >> "$OUTPUT_DIR/index.html"

# Extract and sort blog posts by date
posts=()
for file in "$OUTPUT_DIR"/*.org; do
    filename=$(basename "$file" .org)

    # Extract metadata from Org files
    title=$(awk -F': ' '/^#\+TITLE:/ {print $2}' "$file")
    subtitle=$(awk -F': ' '/^#\+SUBTITLE:/ {print $2}' "$file")
    date=$(awk -F': ' '/^#\+DATE:/ {print $2}' "$file")

    # If the date is missing, assign a default to avoid sorting errors
    if [ -z "$date" ]; then
        date="1970-01-01"
    fi

    # Convert date to Unix timestamp for sorting
    timestamp=$(date -d "$date" +%s 2>/dev/null || echo 0)

    # Add post info to array
    posts+=("$timestamp|$date|$filename|$title|$subtitle")
done

# Sort posts by date (newest first)
IFS=$'\n' sorted_posts=($(sort -rn <<<"${posts[*]}"))
unset IFS
for post in "${sorted_posts[@]}"; do
    IFS='|' read -r timestamp pdate filename title subtitle <<< "$post"
        # Skip about.html
    if [[ "$filename" == "about" ]]; then
        continue
    fi
    echo "<li>" >> "$OUTPUT_DIR/index.html"
    echo "<a href='$filename.html' class='post-link'>" >> "$OUTPUT_DIR/index.html"
    echo "<strong class='post-title'>$title</strong>" >> "$OUTPUT_DIR/index.html"
    echo "<span class='post-date'>($pdate)</span><br>" >> "$OUTPUT_DIR/index.html"
    echo "<span class='post-subtitle'>$subtitle</span>" >> "$OUTPUT_DIR/index.html"
    echo "</a>" >> "$OUTPUT_DIR/index.html"
    echo "</li>" >> "$OUTPUT_DIR/index.html"
done

echo "</ul>" >> "$OUTPUT_DIR/index.html"
#echo "<p><a href='https://www.hitwebcounter.com' target='_blank'>Visit Counter</a></p>" >> "$OUTPUT_DIR/index.html"
#echo "<script type='text/javascript' src='https://counter.websiteout.com/js/3/15/0/0'></script>" >> "$OUTPUT_DIR/index.html"

# Footer
echo "<div class='footer'> © Dylan 2025. Written in Emacs Orgmode because I am the man.</div>" >> "$OUTPUT_DIR/index.html"
echo "</body></html>" >> "$OUTPUT_DIR/index.html"

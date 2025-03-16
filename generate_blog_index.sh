
#!/bin/bash

BLOG_DIR=~/org/website/blog
mkdir -p "$BLOG_DIR"

echo "<html><head><title>Blog</title></head><body>" > "$BLOG_DIR/index.html"
echo "<h1>My Blog</h1><ul>" >> "$BLOG_DIR/index.html"

for file in "$BLOG_DIR"/*.html; do
    filename=$(basename "$file")
    title=$(grep -m 1 '<title>' "$file" | sed 's/<[^>]*>//g')
    echo "<li><a href=\"$filename\">$title</a></li>" >> "$BLOG_DIR/index.html"
done

echo "</ul></body></html>" >> "$BLOG_DIR/index.html"

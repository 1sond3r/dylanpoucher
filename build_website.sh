#!/bin/bash

#!/bin/bash

echo "🚀 Starting website build..."

# Step 1: Export website Org files to HTML (Fixing batch-mode export)
echo "📄 Exporting Org files to HTML..."
emacs --batch --eval "(progn (setq org-directory \"~/org/website/\") (mapc (lambda (file) (with-current-buffer (find-file-noselect file) (org-html-export-to-html))) (directory-files \"~/org/website/\" t \"\\.org$\")))"

# Step 2: Generate website index
echo "📌 Generating main index..."
bash ~/org/website/generate_index.sh

# Step 3: Generate blog index
echo "📝 Generating blog index..."
bash ~/org/website/generate_blog_index.sh

# Step 4: Ensure CSS file exists, then copy it
if [ ! -f ~/org/website/style.css ]; then
    echo "🎨 Creating default style.css..."
    cat <<EOL > ~/org/website/style.css
body { font-family: Arial, sans-serif; max-width: 800px; margin: auto; padding: 20px; background-color: #f8f8f8; color: #333; }
h1, h2, h3 { color: #222; }
a { color: #0077cc; }
EOL
fi
echo "🎨 Copying CSS..."
cp -f ~/org/website/style.css ~/org/website/

# Step 5: Serve website locally
echo "🌍 Opening website at http://localhost:8000"
cd ~/org/website && python3 -m http.server 8000

echo "✅ Website build complete!"

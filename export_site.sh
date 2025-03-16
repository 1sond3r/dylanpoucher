#!/bin/bash

# Step 1: Export website Org files to HTML
emacs --batch --eval "(my/org-export-website)"

# Step 2: Generate website index
~/org/website/generate_index.sh

# Step 3: Copy CSS styling
cp ~/org/website/style.css ~/org/website/

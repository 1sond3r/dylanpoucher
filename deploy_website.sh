#!/bin/bash

echo "🔄 Fetching latest changes from GitHub..."

# Step 1: Check for unstaged changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️ Unstaged changes detected! Stashing changes temporarily..."
    git stash push -m "Auto-stash before pulling" || { echo "❌ Stash failed!"; exit 1; }
    STASHED=1
else
    STASHED=0
fi

# Step 2: Pull latest changes from GitHub
git pull origin main --rebase || { echo "❌ Git pull failed! Resolve conflicts and try again."; exit 1; }

# Step 3: Apply stashed changes (if any)
if [ $STASHED -eq 1 ]; then
    echo "🔄 Applying stashed changes..."
    git stash pop || { echo "⚠️ Failed to apply stash! You may need to resolve conflicts manually."; exit 1; }
fi

# Step 5: Stage all changes
echo "📌 Staging changes..."
git add .

# Step 6: Commit changes
commit_msg="🚀 Website update: $(date)"
git commit -m "$commit_msg" || { echo "⚠️ No new changes to commit."; exit 0; }

# Step 7: Push to GitHub
echo "📤 Pushing to GitHub..."
git push origin main || { echo "❌ Push failed! Check your SSH keys and try again."; exit 1; }

# Step 8: Success message
echo "✅ Website successfully updated!"

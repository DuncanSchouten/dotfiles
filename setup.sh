#!/bin/bash
# Setup script for dotfiles
# Creates symlinks from dotfiles to their expected locations

set -e  # Exit on error

echo "🔧 Setting up dotfiles..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}Dotfiles directory: ${DOTFILES_DIR}${NC}"

# Create Claude commands directory if it doesn't exist
echo "📁 Creating ~/.claude/commands directory..."
mkdir -p ~/.claude/commands

# Symlink Claude commands
echo "🔗 Creating symlinks for Claude commands..."
for cmd in "${DOTFILES_DIR}"/claude/commands/*.md; do
  if [ -f "$cmd" ]; then
    cmd_name=$(basename "$cmd")
    target=~/.claude/commands/"$cmd_name"

    # Remove existing file/symlink
    if [ -L "$target" ]; then
      echo "  Removing existing symlink: $cmd_name"
      rm "$target"
    elif [ -f "$target" ]; then
      echo "  Backing up existing file: $cmd_name"
      mv "$target" "$target.backup"
    fi

    # Create new symlink
    ln -s "$cmd" "$target"
    echo -e "  ${GREEN}✓${NC} Linked: $cmd_name"
  fi
done

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Claude commands are now symlinked:"
echo "  ~/.claude/commands/ -> ~/dotfiles/claude/commands/"
echo ""
echo "Edit files in ~/dotfiles/ and changes will reflect immediately."

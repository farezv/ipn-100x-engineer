#!/bin/bash
# Auto-generate changelog entry after each Claude session

DATE=$(date +"%Y-%m-%d %H:%M")
CHANGELOG="$CLAUDE_PROJECT_DIR/.claude/CHANGELOG.md"

# Create changelog if it doesn't exist
if [ ! -f "$CHANGELOG" ]; then
  echo "# Claude Code Session Changelog" > "$CHANGELOG"
  echo "" >> "$CHANGELOG"
  echo "This file is auto-updated after each Claude Code session." >> "$CHANGELOG"
  echo "" >> "$CHANGELOG"
  echo "---" >> "$CHANGELOG"
fi

# Get git diff summary
CHANGES=$(git -C "$CLAUDE_PROJECT_DIR" diff --stat HEAD 2>/dev/null | tail -1)

if [ -n "$CHANGES" ]; then
  echo "" >> "$CHANGELOG"
  echo "## $DATE" >> "$CHANGELOG"
  echo "" >> "$CHANGELOG"
  echo "### Files Modified" >> "$CHANGELOG"
  git -C "$CLAUDE_PROJECT_DIR" diff --name-only HEAD 2>/dev/null | while read file; do
    echo "- \`$file\`" >> "$CHANGELOG"
  done
  echo "" >> "$CHANGELOG"
  echo "**Stats:** $CHANGES" >> "$CHANGELOG"
  echo "" >> "$CHANGELOG"
  echo "---" >> "$CHANGELOG"
fi

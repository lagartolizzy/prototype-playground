#!/bin/bash

# ============================================================
# publish.sh — Publish a prototype to the Playground
#
# Usage:
#   ./publish.sh "Prototype Name" ./path/to/file.html
#
# Options:
#   --author "Name"       Your name (default: git user.name)
#   --status "Draft"      Status: Draft, In Review, Final (default: Draft)
#   --tags "AI Agent,Onboarding"   Comma-separated tags
#   --description "..."   Short description
#   --update              Update an existing prototype (same filename)
#
# Examples:
#   ./publish.sh "AI Agent Onboarding V2" ./onboarding.html
#   ./publish.sh "SMS Flow Builder" ./sms-flow.html --author "Lisa" --status "In Review" --tags "SMS,Flows"
#   ./publish.sh "AI Agent Onboarding V2" ./onboarding.html --update
# ============================================================

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================
# CONFIGURATION — Update these for your setup
# ============================================================
GITHUB_USERNAME="YOUR_GITHUB_USERNAME"       # ← Change this
REPO_NAME="prototype-playground"              # ← Change if different
# ============================================================

PAGES_URL="https://${GITHUB_USERNAME}.github.io/${REPO_NAME}"

# --- Parse arguments ---
if [ $# -lt 2 ]; then
  echo -e "${RED}Error:${NC} Missing arguments."
  echo ""
  echo -e "  Usage: ${CYAN}./publish.sh \"Prototype Name\" ./path/to/file.html${NC}"
  echo ""
  echo "  Options:"
  echo "    --author \"Name\"          Your name (default: git user.name)"
  echo "    --status \"Draft\"         Draft | In Review | Final"
  echo "    --tags \"Tag1,Tag2\"       Comma-separated tags"
  echo "    --description \"...\"      Short description"
  echo "    --update                 Update an existing prototype"
  exit 1
fi

PROTO_NAME="$1"
SOURCE_FILE="$2"
shift 2

# Defaults
AUTHOR=$(git config user.name 2>/dev/null || echo "Unknown")
STATUS="Draft"
TAGS=""
DESCRIPTION=""
UPDATE_MODE=false

# Parse optional flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --author) AUTHOR="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --update) UPDATE_MODE=true; shift ;;
    *) echo -e "${RED}Unknown option:${NC} $1"; exit 1 ;;
  esac
done

# --- Validate ---
if [ ! -f "$SOURCE_FILE" ]; then
  echo -e "${RED}Error:${NC} File not found: ${SOURCE_FILE}"
  exit 1
fi

if [[ ! "$SOURCE_FILE" == *.html ]]; then
  echo -e "${YELLOW}Warning:${NC} File is not .html — continuing anyway."
fi

# --- Find repo root ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# Check if we're in the right repo
if [ ! -f "$REPO_ROOT/prototypes.json" ]; then
  echo -e "${RED}Error:${NC} prototypes.json not found. Run this script from the prototype-playground repo root."
  exit 1
fi

# --- Generate filename slug ---
SLUG=$(echo "$PROTO_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
FILENAME="${SLUG}.html"
DEST_DIR="$REPO_ROOT/prototypes"
DEST_FILE="$DEST_DIR/$FILENAME"

# Create prototypes directory if needed
mkdir -p "$DEST_DIR"

echo ""
echo -e "${BOLD}◈ Prototype Playground${NC}"
echo -e "${DIM}─────────────────────────────────${NC}"

# --- Check for existing ---
if [ -f "$DEST_FILE" ] && [ "$UPDATE_MODE" = false ]; then
  echo -e "${YELLOW}⚠${NC}  A prototype with filename ${CYAN}${FILENAME}${NC} already exists."
  echo -e "   Use ${CYAN}--update${NC} flag to overwrite it."
  echo ""
  read -p "   Overwrite? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${DIM}   Cancelled.${NC}"
    exit 0
  fi
  UPDATE_MODE=true
fi

# --- Copy file ---
cp "$SOURCE_FILE" "$DEST_FILE"
echo -e "${GREEN}✓${NC}  Copied → ${CYAN}prototypes/${FILENAME}${NC}"

# --- Update prototypes.json ---
TODAY=$(date +%Y-%m-%d)

# Convert tags string to JSON array
if [ -n "$TAGS" ]; then
  TAGS_JSON=$(echo "$TAGS" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')
  TAGS_JSON="[$TAGS_JSON]"
else
  TAGS_JSON="[]"
fi

# Build new entry JSON
NEW_ENTRY=$(cat <<EOF
{
  "name": "${PROTO_NAME}",
  "author": "${AUTHOR}",
  "date": "${TODAY}",
  "status": "${STATUS}",
  "tags": ${TAGS_JSON},
  "description": "${DESCRIPTION}",
  "file": "${FILENAME}"
}
EOF
)

# Check if jq is available for clean JSON manipulation
if command -v jq &> /dev/null; then
  if [ "$UPDATE_MODE" = true ]; then
    # Remove existing entry with same filename, then add new one
    jq --argjson entry "$NEW_ENTRY" \
      '[.[] | select(.file != "'"$FILENAME"'")] + [$entry]' \
      "$REPO_ROOT/prototypes.json" > "$REPO_ROOT/prototypes.json.tmp"
  else
    # Append new entry
    jq --argjson entry "$NEW_ENTRY" '. + [$entry]' \
      "$REPO_ROOT/prototypes.json" > "$REPO_ROOT/prototypes.json.tmp"
  fi
  mv "$REPO_ROOT/prototypes.json.tmp" "$REPO_ROOT/prototypes.json"
else
  # Fallback without jq: use Python (available on most systems)
  python3 -c "
import json, sys

with open('$REPO_ROOT/prototypes.json', 'r') as f:
    data = json.load(f)

entry = json.loads('''$NEW_ENTRY''')

if $( [ "$UPDATE_MODE" = true ] && echo "True" || echo "False" ):
    data = [p for p in data if p.get('file') != '$FILENAME']

data.append(entry)

with open('$REPO_ROOT/prototypes.json', 'w') as f:
    json.dump(data, f, indent=2)
"
fi

echo -e "${GREEN}✓${NC}  Updated ${CYAN}prototypes.json${NC}"

# --- Git commit + push ---
cd "$REPO_ROOT"

# Pull latest first to avoid conflicts
echo -e "${DIM}   Pulling latest changes…${NC}"
git pull --rebase --quiet 2>/dev/null || true

git add "prototypes/$FILENAME" prototypes.json
if [ "$UPDATE_MODE" = true ]; then
  git commit -m "update: ${PROTO_NAME}" --quiet
else
  git commit -m "add: ${PROTO_NAME}" --quiet
fi

echo -e "${DIM}   Pushing to GitHub…${NC}"
git push --quiet

echo -e "${GREEN}✓${NC}  Pushed to GitHub"

# --- Done ---
PROTO_URL="${PAGES_URL}/prototypes/${FILENAME}"

echo ""
echo -e "${DIM}─────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}Published!${NC}"
echo ""
echo -e "  ${BOLD}Prototype:${NC}  ${PROTO_URL}"
echo -e "  ${BOLD}Dashboard:${NC}  ${PAGES_URL}"
echo ""

# Copy URL to clipboard if possible
if command -v pbcopy &> /dev/null; then
  echo -n "$PROTO_URL" | pbcopy
  echo -e "  ${DIM}(URL copied to clipboard)${NC}"
elif command -v xclip &> /dev/null; then
  echo -n "$PROTO_URL" | xclip -selection clipboard
  echo -e "  ${DIM}(URL copied to clipboard)${NC}"
fi

echo ""

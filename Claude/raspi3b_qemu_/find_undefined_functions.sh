#!/bin/bash

# Define the functions to search for
FUNCTIONS=(
  "fsync"
  "lseek"
  "__errno"
  "strerror"
  "openpgp_cipher_algo_name"
  "openpgp_cipher_open"
  "gcry_cipher_setkey"
  "gpg_strerror"
  "bug_at"
  "gpgrt_fputs"
  "gpgrt_fputc"
)

# Define the source directory - change this to the root of your codebase
SRC_DIR="./src"

# Colors for nicer output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Searching for undefined functions in ${SRC_DIR}...${NC}\n"

# Count total occurrences
total_occurrences=0

# Loop through each function and find occurrences
for func in "${FUNCTIONS[@]}"; do
  echo -e "${GREEN}Searching for function: ${func}${NC}"
  
  # Use grep to find all occurrences, format as file:line:content
  results=$(grep -n --include="*.c" --include="*.h" -r "${func}(" ${SRC_DIR} 2>/dev/null)
  
  # Check if any results were found
  if [ -z "$results" ]; then
    # Try without parenthesis in case it's just referenced
    results=$(grep -n --include="*.c" --include="*.h" -r "${func}" ${SRC_DIR} 2>/dev/null)
  fi
  
  # Format each result as a clickable link
  if [ ! -z "$results" ]; then
    count=$(echo "$results" | wc -l)
    total_occurrences=$((total_occurrences + count))
    echo -e "Found ${count} occurrence(s):"
    
    while IFS= read -r line; do
      # Extract filename and line number
      file=$(echo "$line" | cut -d':' -f1)
      linenum=$(echo "$line" | cut -d':' -f2)
      content=$(echo "$line" | cut -d':' -f3-)
      
      # Format as VSCode clickable link
      echo -e "  ${file}:${linenum}:1 ${content}"
    done <<< "$results"
  else
    echo "  No occurrences found"
  fi
  
  echo ""
done

echo -e "${YELLOW}Search complete. Found ${total_occurrences} total occurrences.${NC}"
echo "You can click on any of the file:line references above to open in VS Code."


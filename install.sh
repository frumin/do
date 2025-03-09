#!/bin/bash

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building todo CLI tool...${NC}"
cd TodoCLI
swift build -c release

echo -e "${GREEN}Installing todo CLI tool...${NC}"
# Create the bin directory if it doesn't exist
mkdir -p ~/bin

# Copy the built binary
cp -f .build/release/todo ~/bin/

# Add ~/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    echo -e "${GREEN}Added ~/bin to PATH in ~/.zshrc${NC}"
fi

echo -e "${GREEN}✨ Installation complete!${NC}"
echo -e "Run 'todo --help' to get started" 
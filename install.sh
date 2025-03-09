#!/bin/bash

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building todo app...${NC}"
swift build -c release

# Determine installation path
INSTALL_PATH="/usr/local/bin/todo"
if [ ! -w "/usr/local/bin" ]; then
    echo -e "${RED}Need sudo permission to install to ${INSTALL_PATH}${NC}"
    sudo cp -f .build/release/todo "$INSTALL_PATH"
else
    cp -f .build/release/todo "$INSTALL_PATH"
fi

echo -e "${GREEN}Successfully installed todo to ${INSTALL_PATH}${NC}"
echo -e "Try it out with: ${BLUE}todo --help${NC}" 
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
    # Source the updated profile
    source ~/.zshrc
fi

echo -e "${GREEN}✨ Installation complete!${NC}"
echo -e "Run 'todo --help' to get started"

# Generate shell completions
echo -e "${GREEN}Generating shell completions...${NC}"
~/bin/todo --generate-completion-script zsh > ~/.zsh/completion/_todo 2>/dev/null || {
    mkdir -p ~/.zsh/completion
    ~/bin/todo --generate-completion-script zsh > ~/.zsh/completion/_todo
}

# Add completion directory to fpath if not already present
if ! grep -q "fpath=(~/.zsh/completion \$fpath)" ~/.zshrc; then
    echo 'fpath=(~/.zsh/completion $fpath)' >> ~/.zshrc
    echo 'autoload -U compinit && compinit' >> ~/.zshrc
    echo -e "${GREEN}Added completion support to ~/.zshrc${NC}"
fi

echo -e "${GREEN}✨ Shell completions installed!${NC}"
echo "Please restart your shell or run 'source ~/.zshrc' to enable completions" 
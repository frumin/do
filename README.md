# todo

A simple, Unix-style command-line todo application written in Swift. Following Unix principles, it stores todos in a plain text file and provides simple, focused commands for managing your tasks.

## Features

- Simple command-line interface
- Stores todos in `~/.todo.json` (JSON format)
- Priority levels (high/medium/low) with color coding
- Due dates with overdue detection
- Natural language date parsing
- Tags support with filtering
- Flexible sorting and filtering options
- Color-coded output
- HTML output support
- Shell completion support (zsh/bash/fish)
- Built with Swift and ArgumentParser
- Follows Unix philosophy

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later

## Installation

### Quick Install

```bash
git clone https://github.com/frumin/do.git
cd do
./install.sh
```

This will build the app and install it to `/usr/local/bin/todo`. You might need to enter your password if sudo is required.

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/frumin/do.git
cd do
```

2. Build the project:
```bash
swift build -c release
```

3. Copy the binary to your preferred location:
```bash
sudo cp .build/release/todo /usr/local/bin/
```

## Usage

### Adding Todos

Add a simple todo:
```bash
todo add "Buy groceries"
```

Add with priority:
```bash
todo add "Important meeting" -p high
```

Add with due date:
```bash
todo add "Submit report" --due 2024-03-15
```

Add with tags:
```bash
todo add "Team meeting" --tags work,meeting
```

Add with all options:
```bash
todo add "Quarterly review" -p high --due 2024-03-20 --tags work,important
```

### Listing Todos

List all todos:
```bash
todo list
```

Sort by priority:
```bash
todo list -p
# or
todo list --by-priority
```

Sort by due date:
```bash
todo list -d
# or
todo list --by-due
```

Show only high priority items:
```bash
todo list -h
# or
todo list --high-priority
```

Show overdue items:
```bash
todo list -o
# or
todo list --overdue
```

Filter by tag:
```bash
todo list -t work
# or
todo list --tag work
```

Disable colored output:
```bash
todo list -n
# or
todo list --no-color
```

Output as HTML:
```bash
todo list --html
```

Save HTML output to file:
```bash
todo list -f todos.html
# or
todo list --output-file todos.html
```

### Managing Todos

Mark a todo as done:
```bash
todo done 1
```

Remove a todo:
```bash
todo remove 1
```

Edit a todo's text:
```bash
todo edit 1 --text "Updated text"
```

Change priority:
```bash
todo edit 1 --priority high
```

Update due date (supports natural language):
```bash
todo edit 1 --due "next monday"
todo edit 1 --due "in 2 weeks"
todo edit 1 --due 2024-03-15
todo edit 1 --due none  # Remove due date
```

Update tags:
```bash
todo edit 1 --tags "work,important"
todo edit 1 --tags none  # Remove all tags
```

Multiple changes at once:
```bash
todo edit 1 --text "Important meeting" --priority high --due tomorrow --tags "work,meeting"
```

## Output Format

Todos are displayed with various indicators:
- Priority levels: ⚡(high), ●(medium), ○(low)
- Due dates: 📅 with date (red if overdue)
- Tags: #tag-name
- Color coding:
  - High priority: Red
  - Medium priority: Yellow
  - Low priority: Green
  - Due dates: Cyan (Red if overdue)
  - Tags: Purple

Example output:
```
1. ⚡ Important meeting 📅 3/15/24 #work #meeting
2. ● Buy groceries 📅 3/10/24 #shopping
3.   Call mom #family
```

## Storage

Todos are stored in `~/.todo.json` in JSON format, making it easy to interact with other tools or scripts. The file is atomic-safe and uses ISO-8601 date formatting.

## License

This project is open source and available under the MIT License.

## Shell Completion

Generate and install shell completions:

### Zsh
```bash
todo completion --shell zsh --output ~/.todo.zsh
echo 'source ~/.todo.zsh' >> ~/.zshrc
source ~/.zshrc
```

### Bash
```bash
todo completion --shell bash --output ~/.todo.bash
echo 'source ~/.todo.bash' >> ~/.bashrc  # or ~/.bash_profile on macOS
source ~/.bashrc  # or source ~/.bash_profile on macOS
```

### Fish
```bash
todo completion --shell fish --output ~/.config/fish/completions/todo.fish
```

After installation, you can use tab completion for:
- Commands (add, list, edit, done, remove, archive, stats)
- Options (--priority, --due, --tags, etc.)
- Values (priority levels, archive reasons, etc.) 
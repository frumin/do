# todo

A simple, Unix-style command-line todo application written in Swift. Following Unix principles, it stores todos in a plain text file and provides simple, focused commands for managing your tasks.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Commands](#basic-commands)
  - [Managing Priorities](#managing-priorities)
  - [Working with Due Dates](#working-with-due-dates)
  - [Using Tags](#using-tags)
  - [Filtering and Sorting](#filtering-and-sorting)
  - [HTML Export](#html-export)
  - [Statistics](#statistics)
  - [Shell Completion](#shell-completion)
- [Output Format](#output-format)
- [Storage](#storage)
- [License](#license)

## Features

- Simple command-line interface
- Stores todos in `~/.todo.json` (JSON format)
- Priority levels (high/medium/low) with color coding
- Due dates with overdue detection
- Natural language date parsing
- Tags support with filtering
- Flexible sorting and filtering options
- Color-coded output
- HTML export for todos, archives, and statistics
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

### Basic Commands

Add a todo:
```bash
todo add "Buy groceries"
```

List todos:
```bash
todo list
```

Mark as done:
```bash
todo done 1
todo done 1 2 3  # Mark multiple tasks as done
```

Remove a todo:
```bash
todo remove 1              # Remove a single task
todo remove 1 2 3         # Remove multiple tasks at once
```

Edit a todo:
```bash
todo edit 1 --text "Updated text"
```

### Managing Priorities

Add with priority:
```bash
todo add "Important meeting" -p high
```

Change priority:
```bash
todo edit 1 --priority high
```

List by priority:
```bash
todo list --by-priority
```

Show high priority only:
```bash
todo list --high-priority
```

### Working with Due Dates

Add with due date:
```bash
todo add "Submit report" --due 2024-03-15
```

Natural language dates:
```bash
todo add "Team meeting" --due "next monday"
todo add "Review" --due "in 2 weeks"
```

Update due date:
```bash
todo edit 1 --due tomorrow
todo edit 1 --due none  # Remove due date
```

Show overdue items:
```bash
todo list --overdue
```

### Using Tags

Add with tags:
```bash
todo add "Team meeting" --tags work,meeting
```

Update tags:
```bash
todo edit 1 --tags "work,important"
todo edit 1 --tags none  # Remove all tags
```

Filter by tag:
```bash
todo list --tag work
```

### Filtering and Sorting

Sort by priority:
```bash
todo list --by-priority
```

Sort by due date:
```bash
todo list --by-due
```

Filter by tag:
```bash
todo list --tag work
```

Disable colors:
```bash
todo list --no-color
```

### HTML Export

The todo app supports exporting todos, archives, and statistics to HTML format for better visualization and sharing.

Export current todos:
```bash
todo list --html --output-file todos.html
```

Export archived items:
```bash
todo archive --html --output-file archive.html
```

Export statistics:
```bash
todo stats --html --output-file stats.html
```

HTML exports include:
- Responsive layout
- Color-coded priorities
- Interactive tag filtering
- Due date highlighting
- Progress bars for statistics
- Print-friendly styling

### Statistics

View basic stats:
```bash
todo stats
```

Include archived items:
```bash
todo stats --include-archived
```

Show detailed tag stats:
```bash
todo stats --tags
```

Export as HTML:
```bash
todo stats --html --output-file stats.html
```

### Shell Completion

Generate and install shell completions:

#### Zsh
```bash
todo completion --shell zsh --output ~/.todo.zsh
echo 'source ~/.todo.zsh' >> ~/.zshrc
source ~/.zshrc
```

#### Bash
```bash
todo completion --shell bash --output ~/.todo.bash
echo 'source ~/.todo.bash' >> ~/.bashrc  # or ~/.bash_profile on macOS
source ~/.bashrc  # or source ~/.bash_profile on macOS
```

#### Fish
```bash
todo completion --shell fish --output ~/.config/fish/completions/todo.fish
```

After installation, you can use tab completion for:
- Commands (add, list, edit, done, remove, archive, stats)
- Options (--priority, --due, --tags, etc.)
- Values (priority levels, archive reasons, etc.)

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
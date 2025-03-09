# Todo App 📝

A simple yet powerful todo management system with both a CLI and macOS app, built with Swift.

## Project Structure

The project consists of three main components:

- `TodoKit`: A shared Swift library that handles todo management
- `TodoCLI`: A command-line interface for managing todos
- `TodoApp`: A native macOS app for managing todos

## Installation

### CLI Tool

To install the CLI tool:

```bash
./install.sh
```

This will:
1. Build the CLI tool
2. Install it to `~/bin`
3. Add `~/bin` to your PATH (if needed)
4. Set up shell completions for zsh

After installation, restart your shell or run:
```bash
source ~/.zshrc
```

### macOS App

Coming soon!

## Usage

### CLI Commands

```bash
# Add a new todo
todo add "Buy groceries"
todo add "Call mom" --priority high --due "tomorrow 2pm"

# List todos
todo list                  # List all todos
todo list --priority high  # List high priority todos
todo list --overdue       # List overdue todos

# Mark todos as done
todo done 1               # Mark todo #1 as done
todo done 1 2 3          # Mark multiple todos as done

# Remove todos
todo remove 1            # Remove todo #1
todo remove 1 2 3       # Remove multiple todos

# Edit todos
todo edit 1 --text "New text" --priority medium
```

For more details on any command, use:
```bash
todo help <command>
```

## Development

### Requirements

- macOS 13 or later
- Swift 5.9 or later
- Xcode 15 or later (for macOS app development)

### Building from Source

To build the CLI tool:
```bash
cd TodoCLI
swift build
```

To build the macOS app:
```bash
cd TodoApp
swift build
```

### Running Tests

```bash
cd TodoCLI
swift test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 
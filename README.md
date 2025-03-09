# todo

A simple, Unix-style command-line todo application written in Swift. Following Unix principles, it stores todos in a plain text file and provides simple, focused commands for managing your tasks.

## Features

- Simple command-line interface
- Stores todos in `~/.todo.txt` (plain text)
- Basic CRUD operations (add, list, complete, remove)
- Built with Swift and ArgumentParser
- Follows Unix philosophy

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later

## Installation

1. Clone the repository:
```bash
git clone https://github.com/frumin/do.git
cd do
```

2. Build the project:
```bash
swift build -c release
```

3. (Optional) Install to your system:
```bash
sudo cp .build/release/todo /usr/local/bin/
```

## Usage

### Add a new todo
```bash
todo add "Buy groceries"
```

### List all todos
```bash
todo list
```

### Mark a todo as done
```bash
todo done 1
```

### Remove a todo
```bash
todo remove 1
```

## Storage

Todos are stored in `~/.todo.txt` in a simple line-based format, making it easy to interact with other Unix tools if desired.

## License

This project is open source and available under the MIT License. 
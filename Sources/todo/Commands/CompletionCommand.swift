import ArgumentParser
import Foundation

struct CompletionCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "completion",
        abstract: "Generate shell completion scripts"
    )
    
    @Option(name: .shortAndLong, help: "Shell to generate completions for (zsh/bash/fish)")
    var shell: String
    
    @Option(name: .shortAndLong, help: "Output file (optional)")
    var output: String?
    
    func run() throws {
        let script: String
        switch shell.lowercased() {
        case "zsh":
            script = generateZshCompletion()
        case "bash":
            script = generateBashCompletion()
        case "fish":
            script = generateFishCompletion()
        default:
            throw ValidationError("Unsupported shell: \(shell). Use: zsh, bash, or fish")
        }
        
        if let output = output {
            try script.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)
            print("Completion script written to \(output)")
            print("Add the following to your shell configuration:")
            switch shell.lowercased() {
            case "zsh":
                print("  source \(output)")
            case "bash":
                print("  source \(output)")
            case "fish":
                print("  source \(output)")
            default:
                break
            }
        } else {
            print(script)
        }
    }
    
    private func generateZshCompletion() -> String {
        return """
        #compdef todo
        
        function _todo {
            local -a commands
            commands=(
                'add:Add a new todo item'
                'list:List all todo items'
                'edit:Edit a todo item'
                'done:Mark a todo item as done'
                'remove:Remove a todo item'
                'archive:View or manage archived todo items'
                'stats:Show todo statistics'
                'completion:Generate shell completion scripts'
            )
            
            local -a priorities
            priorities=(
                'high:High priority'
                'medium:Medium priority'
                'low:Low priority'
            )
            
            _arguments -C \\
                '1: :{_describe "todo command" commands}' \\
                '*:: :->args'
            
            case $state in
                args)
                    case $words[1] in
                        add)
                            _arguments \\
                                '(-p --priority)'{-p,--priority}'[Priority level]:priority:(high medium low)' \\
                                '(-d --due)'{-d,--due}'[Due date]' \\
                                '(-t --tags)'{-t,--tags}'[Tags (comma-separated)]'
                            ;;
                        list)
                            _arguments \\
                                '(-p --by-priority)'{-p,--by-priority}'[Sort by priority]' \\
                                '(-d --by-due)'{-d,--by-due}'[Sort by due date]' \\
                                '(-h --high-priority)'{-h,--high-priority}'[Show only high priority items]' \\
                                '(-o --overdue)'{-o,--overdue}'[Show only overdue items]' \\
                                '(-t --tag)'{-t,--tag}'[Filter by tag]' \\
                                '(-n --no-color)'{-n,--no-color}'[Disable colored output]' \\
                                '--html[Output as HTML]' \\
                                '(-f --output-file)'{-f,--output-file}'[Output HTML to file]'
                            ;;
                        edit)
                            _arguments \\
                                '1:todo number' \\
                                '--text[New text for the todo]' \\
                                '--priority[New priority level]:priority:(high medium low)' \\
                                '--due[New due date]' \\
                                '--tags[New tags (comma-separated)]'
                            ;;
                        done|remove)
                            _arguments '1:todo number'
                            ;;
                        archive)
                            _arguments \\
                                '(-p --by-priority)'{-p,--by-priority}'[Sort by priority]' \\
                                '(-d --by-date)'{-d,--by-date}'[Sort by archive date]' \\
                                '(-t --tag)'{-t,--tag}'[Filter by tag]' \\
                                '--reason[Filter by archive reason]:reason:(completed deleted expired)' \\
                                '(-n --no-color)'{-n,--no-color}'[Disable colored output]' \\
                                '--html[Output as HTML]' \\
                                '(-f --output-file)'{-f,--output-file}'[Output HTML to file]'
                            ;;
                        stats)
                            _arguments \\
                                '(-i --include-archived)'{-i,--include-archived}'[Include archived todos in stats]' \\
                                '(-t --tags)'{-t,--tags}'[Show detailed tag statistics]' \\
                                '(-n --no-color)'{-n,--no-color}'[Disable colored output]' \\
                                '--html[Output as HTML]' \\
                                '(-f --output-file)'{-f,--output-file}'[Output HTML to file]'
                            ;;
                        completion)
                            _arguments \\
                                '(-s --shell)'{-s,--shell}'[Shell to generate completions for]:shell:(zsh bash fish)' \\
                                '(-o --output)'{-o,--output}'[Output file]'
                            ;;
                    esac
                    ;;
            esac
        }
        
        _todo
        """
    }
    
    private func generateBashCompletion() -> String {
        return """
        _todo() {
            local cur prev words cword
            _init_completion || return
            
            local commands="add list edit done remove archive stats completion"
            local priorities="high medium low"
            
            if [ $cword -eq 1 ]; then
                COMPREPLY=($(compgen -W "$commands" -- "$cur"))
                return
            fi
            
            case ${words[1]} in
                add)
                    case $prev in
                        -p|--priority)
                            COMPREPLY=($(compgen -W "$priorities" -- "$cur"))
                            ;;
                        *)
                            COMPREPLY=($(compgen -W "-p --priority -d --due -t --tags" -- "$cur"))
                            ;;
                    esac
                    ;;
                list)
                    COMPREPLY=($(compgen -W "-p --by-priority -d --by-due -h --high-priority -o --overdue -t --tag -n --no-color --html -f --output-file" -- "$cur"))
                    ;;
                edit)
                    case $prev in
                        --priority)
                            COMPREPLY=($(compgen -W "$priorities" -- "$cur"))
                            ;;
                        *)
                            COMPREPLY=($(compgen -W "--text --priority --due --tags" -- "$cur"))
                            ;;
                    esac
                    ;;
                archive)
                    case $prev in
                        --reason)
                            COMPREPLY=($(compgen -W "completed deleted expired" -- "$cur"))
                            ;;
                        *)
                            COMPREPLY=($(compgen -W "-p --by-priority -d --by-date -t --tag --reason -n --no-color --html -f --output-file" -- "$cur"))
                            ;;
                    esac
                    ;;
                stats)
                    COMPREPLY=($(compgen -W "-i --include-archived -t --tags -n --no-color --html -f --output-file" -- "$cur"))
                    ;;
                completion)
                    case $prev in
                        -s|--shell)
                            COMPREPLY=($(compgen -W "zsh bash fish" -- "$cur"))
                            ;;
                        *)
                            COMPREPLY=($(compgen -W "-s --shell -o --output" -- "$cur"))
                            ;;
                    esac
                    ;;
            esac
        }
        
        complete -F _todo todo
        """
    }
    
    private func generateFishCompletion() -> String {
        return """
        function __fish_todo_needs_command
            set -l cmd (commandline -opc)
            if [ (count $cmd) -eq 1 ]
                return 0
            end
            return 1
        end
        
        function __fish_todo_using_command
            set -l cmd (commandline -opc)
            if [ (count $cmd) -gt 1 ]
                if [ $argv[1] = $cmd[2] ]
                    return 0
                end
            end
            return 1
        end
        
        # Commands
        complete -f -c todo -n '__fish_todo_needs_command' -a add -d 'Add a new todo item'
        complete -f -c todo -n '__fish_todo_needs_command' -a list -d 'List all todo items'
        complete -f -c todo -n '__fish_todo_needs_command' -a edit -d 'Edit a todo item'
        complete -f -c todo -n '__fish_todo_needs_command' -a done -d 'Mark a todo item as done'
        complete -f -c todo -n '__fish_todo_needs_command' -a remove -d 'Remove a todo item'
        complete -f -c todo -n '__fish_todo_needs_command' -a archive -d 'View or manage archived todo items'
        complete -f -c todo -n '__fish_todo_needs_command' -a stats -d 'Show todo statistics'
        complete -f -c todo -n '__fish_todo_needs_command' -a completion -d 'Generate shell completion scripts'
        
        # Add command options
        complete -f -c todo -n '__fish_todo_using_command add' -s p -l priority -a 'high medium low' -d 'Priority level'
        complete -f -c todo -n '__fish_todo_using_command add' -s d -l due -d 'Due date'
        complete -f -c todo -n '__fish_todo_using_command add' -s t -l tags -d 'Tags (comma-separated)'
        
        # List command options
        complete -f -c todo -n '__fish_todo_using_command list' -s p -l by-priority -d 'Sort by priority'
        complete -f -c todo -n '__fish_todo_using_command list' -s d -l by-due -d 'Sort by due date'
        complete -f -c todo -n '__fish_todo_using_command list' -s h -l high-priority -d 'Show only high priority items'
        complete -f -c todo -n '__fish_todo_using_command list' -s o -l overdue -d 'Show only overdue items'
        complete -f -c todo -n '__fish_todo_using_command list' -s t -l tag -d 'Filter by tag'
        complete -f -c todo -n '__fish_todo_using_command list' -s n -l no-color -d 'Disable colored output'
        complete -f -c todo -n '__fish_todo_using_command list' -l html -d 'Output as HTML'
        complete -f -c todo -n '__fish_todo_using_command list' -s f -l output-file -d 'Output HTML to file'
        
        # Edit command options
        complete -f -c todo -n '__fish_todo_using_command edit' -l text -d 'New text for the todo'
        complete -f -c todo -n '__fish_todo_using_command edit' -l priority -a 'high medium low' -d 'New priority level'
        complete -f -c todo -n '__fish_todo_using_command edit' -l due -d 'New due date'
        complete -f -c todo -n '__fish_todo_using_command edit' -l tags -d 'New tags (comma-separated)'
        
        # Archive command options
        complete -f -c todo -n '__fish_todo_using_command archive' -s p -l by-priority -d 'Sort by priority'
        complete -f -c todo -n '__fish_todo_using_command archive' -s d -l by-date -d 'Sort by archive date'
        complete -f -c todo -n '__fish_todo_using_command archive' -s t -l tag -d 'Filter by tag'
        complete -f -c todo -n '__fish_todo_using_command archive' -l reason -a 'completed deleted expired' -d 'Filter by archive reason'
        complete -f -c todo -n '__fish_todo_using_command archive' -s n -l no-color -d 'Disable colored output'
        complete -f -c todo -n '__fish_todo_using_command archive' -l html -d 'Output as HTML'
        complete -f -c todo -n '__fish_todo_using_command archive' -s f -l output-file -d 'Output HTML to file'
        
        # Stats command options
        complete -f -c todo -n '__fish_todo_using_command stats' -s i -l include-archived -d 'Include archived todos in stats'
        complete -f -c todo -n '__fish_todo_using_command stats' -s t -l tags -d 'Show detailed tag statistics'
        complete -f -c todo -n '__fish_todo_using_command stats' -s n -l no-color -d 'Disable colored output'
        complete -f -c todo -n '__fish_todo_using_command stats' -l html -d 'Output as HTML'
        complete -f -c todo -n '__fish_todo_using_command stats' -s f -l output-file -d 'Output HTML to file'
        
        # Completion command options
        complete -f -c todo -n '__fish_todo_using_command completion' -s s -l shell -a 'zsh bash fish' -d 'Shell to generate completions for'
        complete -f -c todo -n '__fish_todo_using_command completion' -s o -l output -d 'Output file'
        """
    }
} 
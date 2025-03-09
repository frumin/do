// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation

struct Todo: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "todo",
        abstract: "Your friendly task manager for the command line 🌟",
        subcommands: [
            AddCommand.self,
            ListCommand.self,
            EditCommand.self,
            DoneCommand.self,
            RemoveCommand.self,
            ArchiveCommand.self,
            StatsCommand.self,
            CompletionCommand.self
        ]
    )
    
    static var storage = TodoStorage()
}

Todo.main()

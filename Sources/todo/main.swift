// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation

struct Todo: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "todo",
        abstract: "A simple todo manager",
        subcommands: [
            AddCommand.self,
            ListCommand.self,
            EditCommand.self,
            DoneCommand.self,
            RemoveCommand.self,
            ArchiveCommand.self
        ]
    )
    
    static var storage = TodoStorage()
}

Todo.main()

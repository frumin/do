// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation
import TodoKit

struct TodoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "todo",
        abstract: "A simple command-line todo app 📝",
        subcommands: [
            AddCommand.self,
            ListCommand.self,
            DoneCommand.self,
            RemoveCommand.self,
            EditCommand.self,
            StatsCommand.self
        ]
    )
}

TodoCommand.main()

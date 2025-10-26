//
//  File.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//

import Foundation

public extension Command {
    /// Execute a utility using the `env` command
    ///
    /// - Parameters:
    ///   - utility: The name of the utility to run
    ///   - arguments: Arguments for the utility
    ///   - currentDirectory: The current working directory for execution
    ///   - environment: The execution environment
    ///
    /// - Returns: A command that will run a utility using `env`
    static func env(
        utility: String,
        arguments: [String] = [],
        currentDirectory: URL? = nil,
        environment: Environment? = nil
    ) -> Command {
        Command(
            executableURL: .init(filePath: "/usr/bin/env"),
            arguments: [utility] + arguments,
            currentDirectory: currentDirectory,
            environment: environment
        )
    }
}

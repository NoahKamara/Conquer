//
//  Command+env.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension Command {
    /// Construct a command that invokes a utility via `/usr/bin/env`.
    ///
    /// - Parameters:
    ///   - utility: The name of the utility to run.
    ///   - arguments: Arguments for the utility.
    ///   - currentDirectory: Optional working directory for execution.
    ///   - environment: Optional execution environment for the launched process.
    ///
    /// - Returns: A command that will run a utility using `env`.
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

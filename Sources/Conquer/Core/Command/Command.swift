//
//  Command.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A Command can be run using an Executor
public struct Command: Sendable {
    /// the url to the executable for the command
    public let executableURL: URL

    /// the arguments for the command
    public var arguments: [String]

    /// the current working directory to use
    /// when executing this command
    public var currentDirectory: URL?

    /// the environment variables to set
    /// for the execution of this command
    public var environment: Environment?

    public init(
        executableURL: URL,
        arguments: [String] = [],
        currentDirectory: URL? = nil,
        environment: Environment? = nil
    ) {
        self.executableURL = executableURL
        self.arguments = arguments
        self.currentDirectory = currentDirectory
        self.environment = environment
    }

    public init(
        executablePath: String,
        arguments: [String] = [],
        currentDirectory: String? = nil,
        environment: Environment? = nil
    ) {
        self.init(
            executableURL: URL(filePath: executablePath),
            arguments: arguments,
            currentDirectory: currentDirectory.map({ URL(filePath: $0) }),
            environment: environment
        )
    }
}

//
//  Command.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A description of a process invocation that can be executed by an `Executor`.
///
/// A `Command` encapsulates the executable to run, its arguments, an optional
/// working directory, and an optional `Environment` to use for the spawned
/// process. You typically construct a `Command` directly or via convenience
/// helpers such as `Command.env(utility:arguments:currentDirectory:environment:)`.
public struct Command: Sendable {
    /// The file URL of the executable to launch.
    public let executableURL: URL

    /// The arguments passed to the executable.
    public var arguments: [String]

    /// The working directory to use when executing this command.
    public var currentDirectory: URL?

    /// The environment to provide to the spawned process.
    /// If `nil`, the current process environment is inherited.
    public var environment: Environment?

    /// Create a `Command` from an executable URL.
    ///
    /// - Parameters:
    ///   - executableURL: The file URL of the executable to run.
    ///   - arguments: Arguments to pass to the executable. Defaults to an empty array.
    ///   - currentDirectory: Optional working directory. If `nil`, inherits the current directory.
    ///   - environment: Optional environment variables. If `nil`, inherits the current process
    /// environment.
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

    /// Create a `Command` from an executable path.
    ///
    /// - Parameters:
    ///   - executablePath: Absolute or relative path of the executable to run.
    ///   - arguments: Arguments to pass to the executable. Defaults to an empty array.
    ///   - currentDirectory: Optional working directory as a path string.
    ///   - environment: Optional environment variables. If `nil`, inherits the current process
    /// environment.
    public init(
        executablePath: String,
        arguments: [String] = [],
        currentDirectory: String? = nil,
        environment: Environment? = nil
    ) {
        self.init(
            executableURL: URL(filePath: executablePath),
            arguments: arguments,
            currentDirectory: currentDirectory.map { URL(filePath: $0) },
            environment: environment
        )
    }
}

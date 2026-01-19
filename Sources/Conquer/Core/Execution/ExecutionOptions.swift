//
//  ExecutionOptions.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct ExecutionOptions: @unchecked Sendable {
    /// Data source to use as the process standard input, such as a `Pipe`.
    public var standardInput: Any?

    /// Maximum time, in seconds, to wait for the process to finish before timing out. Defaults to
    /// 10 seconds.
    public var timeout: Double = 10

    /// Defines how a process termination with a non-zero exit code is handled.
    public enum NonZeroExitBehavior: Sendable {
        /// Treat a non-zero exit code as an error and throw `ExecutionError.nonZeroExitCode`.
        case throwError

        /// Do not throw on a non-zero exit code; instead, return the execution result
        /// containing the exit code, stdout, and stderr.
        case returnResult
    }

    /// Controls how non-zero exit codes are handled during command execution.
    /// Defaults to `.throwError`.
    public var nonZeroExitBehavior: NonZeroExitBehavior = .throwError

    /// Create execution options.
    /// - Parameters:
    ///   - standardInput: The standard input to provide to the process.
    ///   - timeout: Optional timeout in seconds. When `nil`, the default is used.
    public init(standardInput: Sendable? = nil, timeout: Double? = nil) {
        self.standardInput = standardInput
        if let timeout {
            self.timeout = timeout
        }
    }
}

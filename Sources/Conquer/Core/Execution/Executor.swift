//
//  Executor.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation.NSURL

/// An executor that can execute a command
public protocol Executor {
    /// Run a command asynchronously and stream the output
    ///
    /// - Parameters:
    ///   - command: the command to run
    ///   - options: options for execution
    /// - Returns: A throwing stream emitting writes to stdout and stderr
    /// - Throws: ExecutionError When an error occurs during execution or the process exits with a non-zero exit code
    func stream(_ command: Command, options: ExecutionOptions) -> AsyncThrowingStream<CommandOutput, Error>

    /// Run a command concurrently and return the result
    ///
    /// - Parameters:
    ///   - command: the command to run
    ///   - options: options for execution
    /// - Returns: The result of the execution
    /// - Throws: ExecutionError When an error occurs during execution or the process exits with a non-zero exit code
    func run(_ command: Command, options: ExecutionOptions) throws(ExecutionError) -> ExecutionResult
}

public extension Executor {
    /// Run a command asynchronously and stream the output
    ///
    /// - Parameters command: the command to run
    /// - Returns: A throwing stream emitting writes to stdout and stderr
    /// - Throws: ExecutionError When an error occurs during execution or the process exits with a non-zero exit code
    func stream(_ command: Command) -> AsyncThrowingStream<CommandOutput, Error> {
        self.stream(command, options: ExecutionOptions())
    }

    /// Run a command concurrently and return the result
    /// - Parameter command: the command to run
    /// - Returns: The result of the execution
    /// - Throws: ExecutionError When an error occurs during execution or the process exits with a non-zero exit code
    func run(_ command: Command) throws(ExecutionError) -> ExecutionResult {
        try self.run(command, options: ExecutionOptions())
    }
}

public struct ExecutionOptions {
    public var standardInput: Any? = nil
    public var timeout: TimeInterval = 10

    public init(standardInput: Any? = nil, timeout: TimeInterval? = nil) {
        self.standardInput = standardInput
        if let timeout {
            self.timeout = timeout
        }
    }
}



public enum ExecutionError: Error, LocalizedError {
    case executionFailed(Error)
    case timeout(Double)
    case failedToReadOutput(Error)
    case nonZeroExitCode(Int32)
    case uncaughtSignal
    case unknown

    public var errorDescription: String? {
        switch self {
        case .executionFailed(let error):
            "Command execution failed: \(error)"
        case .timeout(let timeout):
            "Command execution timed out after \(timeout.formatted(.number.precision(.fractionLength(3)))) seconds"
        case .failedToReadOutput(let error):
            "Command execution failed to read output: \(error)"
        case .nonZeroExitCode(let exitCode):
            "Command execution terminated with non-zero exit code: \(exitCode)"
        case .uncaughtSignal:
            "Command execution terminated due to an uncaught signal"
        case .unknown:
            "Command execution terminated due to an unknown error"
        }
    }
}

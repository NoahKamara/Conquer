//
//  Executor.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation.NSURL

/// An abstraction capable of executing a `Command`.
///
/// Conforming types implement both streaming and collected execution. Use
/// ``stream(_:options:)`` to consume output incrementally, or ``run(_:options:)``
/// to wait for completion and receive an ``ExecutionResult``.
public protocol Executor: Sendable {
    /// Run a command asynchronously and stream the output.
    ///
    /// - Parameters:
    ///   - command: The command to run.
    ///   - options: Options controlling execution behavior, such as timeout or standard input.
    /// - Returns: A throwing stream emitting ``CommandOutput`` chunks from stdout and stderr.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code, or ends due to an uncaught signal.
    func stream(_ command: Command, options: ExecutionOptions)
        -> AsyncThrowingStream<CommandOutput, Error>

    /// Run a command and return the collected result.
    ///
    /// - Parameters:
    ///   - command: The command to run.
    ///   - options: Options controlling execution behavior, such as timeout or standard input.
    /// - Returns: The collected ``ExecutionResult``.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code, or ends due to an uncaught signal.
    func run(_ command: Command, options: ExecutionOptions) throws(ExecutionError)
        -> ExecutionResult
}

public extension Executor {
    /// Run a command asynchronously and stream the output.
    ///
    /// - Parameters command: The command to run.
    /// - Returns: A throwing stream emitting ``CommandOutput`` chunks from stdout and stderr.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code, or ends due to an uncaught signal.
    func stream(_ command: Command) -> AsyncThrowingStream<CommandOutput, Error> {
        self.stream(command, options: ExecutionOptions())
    }

    /// Run a command and return the collected result.
    /// - Parameter command: The command to run.
    /// - Returns: The collected ``ExecutionResult``.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code, or ends due to an uncaught signal.
    func run(_ command: Command) throws(ExecutionError) -> ExecutionResult {
        try self.run(command, options: ExecutionOptions())
    }
}

public struct ExecutionOptions {
    /// Data source to use as the process standard input, such as a `Pipe`.
    public var standardInput: Any?
    /// Maximum time, in seconds, to wait for the process to finish before timing out. Defaults to
    /// 10 seconds.
    public var timeout: TimeInterval = 10

    /// Create execution options.
    /// - Parameters:
    ///   - standardInput: The standard input to provide to the process.
    ///   - timeout: Optional timeout in seconds. When `nil`, the default is used.
    public init(standardInput: Any? = nil, timeout: TimeInterval? = nil) {
        self.standardInput = standardInput
        if let timeout {
            self.timeout = timeout
        }
    }
}

public enum ExecutionError: Error, LocalizedError {
    /// Process failed to spawn or begin running.
    case executionFailed(Error)
    /// Process exceeded the configured timeout (in seconds) and was terminated.
    case timeout(Double)
    /// Reading from stdout or stderr failed with the underlying error.
    case failedToReadOutput(Error)
    /// Process terminated with a non-zero exit status.
    case nonZeroExitCode(Int32)
    /// Process ended due to an uncaught signal.
    case uncaughtSignal
    /// An unknown failure occurred.
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

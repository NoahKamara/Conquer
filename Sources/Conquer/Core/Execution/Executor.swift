//
//  Executor.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation.NSURL

/// An abstraction capable of executing a `Command`.
///
/// Conforming types implement both streaming and collected execution.
///
/// You have two choices for command execution:
/// - Use ``run(_:options:)`` to wait for completion and receive an ``ExecutionResult``, or
/// - Use ``stream(_:options:)`` to consume output/error incrementally.
public protocol Executor: Sendable {
    /// Run a command asynchronously and stream the output.
    ///
    /// - Parameters:
    ///   - command: The command to run.
    ///   - options: Options controlling execution behavior, such as timeout or standard input.
    /// - Returns: A throwing stream emitting ``CommandOutput`` chunks from stdout and stderr.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code (including stdout/stderr in the error), or ends due
    /// to an uncaught signal.
    func stream(_ command: Command, options: ExecutionOptions)
        -> AsyncThrowingStream<CommandOutput, Error>

    /// Run a command and return the collected result.
    ///
    /// - Parameters:
    ///   - command: The command to run.
    ///   - options: Options controlling execution behavior, such as timeout or standard input.
    /// - Returns: The collected ``ExecutionResult``.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code (including stdout/stderr in the error), or ends due
    /// to an uncaught signal.
    func run(_ command: Command, options: ExecutionOptions) throws(ExecutionError)
        -> ExecutionResult
}

public extension Executor {
    /// Run a command asynchronously and stream the output.
    ///
    /// - Parameters command: The command to run.
    /// - Returns: A throwing stream emitting ``CommandOutput`` chunks from stdout and stderr.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code (including stdout/stderr in the error), or ends due
    /// to an uncaught signal.
    func stream(_ command: Command) -> AsyncThrowingStream<CommandOutput, Error> {
        self.stream(command, options: ExecutionOptions())
    }

    /// Run a command and return the collected result.
    /// - Parameter command: The command to run.
    /// - Returns: The collected ``ExecutionResult``.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code (including stdout/stderr in the error), or ends due
    /// to an uncaught signal.
    func run(_ command: Command) throws(ExecutionError) -> ExecutionResult {
        try self.run(command, options: ExecutionOptions())
    }
}

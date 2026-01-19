//
//  SystemExecutor.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// An `Executor` backed by `Process` that runs commands on the local system.
///
/// `SystemExecutor` launches child processes using Foundation's `Process`,
/// supporting both incremental streaming via ``Executor/stream(_:options:)``
/// and collected execution via ``Executor/run(_:options:)``.
public struct SystemExecutor: Sendable, Executor {
    enum TerminationError: Error, Equatable {
        case exited(Int32)
        case uncaughtSignal
    }

    /// Create a new `SystemExecutor`.
    public init() {}

    private func create(_ command: Command, options: ExecutionOptions) -> Process {
        let process = Process()
        process.executableURL = command.executableURL
        process.arguments = command.arguments

        if let currentDirectory = command.currentDirectory {
            process.currentDirectoryURL = currentDirectory
        }

        if let environment = command.environment {
            process.environment = environment._values
        }

        if let standardInput = options.standardInput {
            process.standardInput = standardInput
        }

        return process
    }

    /// Run a command asynchronously and stream incremental output.
    ///
    /// - Parameters:
    ///   - command: The command to run.
    ///   - options: Options controlling execution behavior, such as timeout or standard input.
    /// - Returns: A throwing stream emitting ``CommandOutput`` from stdout and stderr.
    /// - Throws: ``ExecutionError`` when the process fails to spawn or terminates abnormally.
    public func stream(
        _ command: Command,
        options: ExecutionOptions
    ) -> AsyncThrowingStream<CommandOutput, Error> {
        AsyncThrowingStream(CommandOutput.self) { continuation in
            let process = self.create(command, options: options)

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            continuation.onTermination = { _ in
                if process.isRunning { process.terminate() }
            }

            let stdoutHandle = stdoutPipe.fileHandleForReading
            let stderrHandle = stderrPipe.fileHandleForReading

            // Actor to safely collect output data from concurrent handlers
            actor OutputCollector {
                var stdoutData = Data()
                var stderrData = Data()

                func appendStdout(_ data: Data) {
                    self.stdoutData.append(data)
                }

                func appendStderr(_ data: Data) {
                    self.stderrData.append(data)
                }

                func getStdoutString() -> String {
                    String(data: self.stdoutData, encoding: .utf8) ?? ""
                }

                func getStderrString() -> String {
                    String(data: self.stderrData, encoding: .utf8) ?? ""
                }
            }

            let outputCollector = OutputCollector()

            stdoutHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    Task {
                        await outputCollector.appendStdout(data)
                        continuation.yield(.stdout(data))
                    }
                }
            }

            stderrHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    Task {
                        await outputCollector.appendStderr(data)
                        continuation.yield(.stderr(data))
                    }
                }
            }

            final class TimeoutState: @unchecked Sendable {
                var didTimeout = false
                var task: Task<Void, Never>?
            }
            let timeoutState = TimeoutState()

            let timeout = options.timeout
            process.terminationHandler = { process in
                // stop timeout task if still running
                timeoutState.task?.cancel()
                stdoutHandle.readabilityHandler = nil
                stderrHandle.readabilityHandler = nil

                Task {
                    let stdoutString = await outputCollector.getStdoutString()
                    let stderrString = await outputCollector.getStderrString()

                    switch process.terminationReason {
                    case .exit:
                        if process.terminationStatus != 0 {
                            continuation
                                .finish(throwing: ExecutionError
                                    .nonZeroExitCode(
                                        process.terminationStatus,
                                        stdout: stdoutString,
                                        stderr: stderrString
                                    ))
                        } else {
                            continuation.finish()
                        }
                    case .uncaughtSignal:
                        if timeoutState.didTimeout {
                            continuation.finish(throwing: ExecutionError.timeout(timeout))
                        } else {
                            continuation
                                .finish(throwing: ExecutionError
                                    .uncaughtSignal(process.terminationStatus))
                        }
                    @unknown default:
                        continuation.finish(throwing: ExecutionError.unknown)
                    }
                }
            }

            do {
                try process.run()
            } catch {
                continuation.finish(throwing: ExecutionError.executionFailed(error))
                return
            }

            if options.timeout > 0 {
                let timeout = options.timeout
                let task = Task.detached { [weak process] in
                    let nanos = UInt64(timeout * 1000000000)
                    try? await Task.sleep(nanoseconds: nanos)
                    if let process, process.isRunning {
                        timeoutState.didTimeout = true
                        process.terminate()
                    }
                }
                timeoutState.task = task
            }
        }
    }

    /// Run a command and return the collected result.
    ///
    /// - Parameters:
    ///   - command: The command to run.
    ///   - options: Options controlling execution behavior, such as timeout or standard input.
    /// - Returns: The collected ``ExecutionResult``.
    /// - Throws: ``ExecutionError`` when the process fails to spawn, times out,
    ///   terminates with a non-zero exit code, or ends due to an uncaught signal.
    @discardableResult
    public func run(
        _ command: Command,
        options: ExecutionOptions
    ) throws(ExecutionError) -> ExecutionResult {
        let process = self.create(command, options: options)

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
        } catch {
            throw ExecutionError.executionFailed(error)
        }

        // Wait with timeout for termination
        let semaphore = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in semaphore.signal() }

        let timeoutResult = semaphore.wait(timeout: .now() + options.timeout)

        if timeoutResult == .timedOut {
            if process.isRunning {
                process.terminate()
            }

            throw ExecutionError.timeout(options.timeout)
        }

        let stdoutData: Data?
        let stderrData: Data?

        do {
            stdoutData = try stdoutPipe.fileHandleForReading.readToEnd()
            stderrData = try stderrPipe.fileHandleForReading.readToEnd()
        } catch {
            throw ExecutionError.failedToReadOutput(error)
        }

        let stdoutString = String(data: stdoutData ?? Data(), encoding: .utf8) ?? ""
        let stderrString = String(data: stderrData ?? Data(), encoding: .utf8) ?? ""

        switch process.terminationReason {
        case .exit:
            if process.terminationStatus != 0 {
                throw ExecutionError.nonZeroExitCode(
                    process.terminationStatus,
                    stdout: stdoutString,
                    stderr: stderrString
                )
            }
        case .uncaughtSignal:
            throw ExecutionError.uncaughtSignal(process.terminationStatus)
        @unknown default:
            throw ExecutionError.unknown
        }

        return ExecutionResult(
            exitCode: process.terminationStatus,
            stdout: stdoutString,
            stderr: stderrString
        )
    }
}

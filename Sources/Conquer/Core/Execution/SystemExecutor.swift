//
//  SystemExecutor.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct SystemExecutor: Executor {
    enum TerminationError: Error, Equatable {
        case exited(Int32)
        case uncaughtSignal
    }

    public init() {}

    private func create(_ command: Command) -> Process {
        let process = Process()
        process.executableURL = command.executableURL
        process.arguments = command.arguments

        if let currentDirectory = command.currentDirectory {
            process.currentDirectoryURL = currentDirectory
        }

        if let environment = command.environment {
            process.environment = environment.values
        }
        return process
    }

    public func stream(_ command: Command) -> AsyncThrowingStream<CommandOutput, Error> {
        AsyncThrowingStream(CommandOutput.self) { continuation in
            let process = self.create(command)
            let outputStream = process.streamOutput()

            Task {
                for try await output in outputStream {
                    continuation.yield(output)
                }
            }

            process.waitUntilExit()
            print(process.terminationReason)

            switch process.terminationReason {
            case .exit:
                if process.terminationStatus != 0 {
                    continuation.finish(
                        throwing: TerminationError.exited(process.terminationStatus)
                    )
                }
            case .uncaughtSignal:
                continuation.finish(throwing: TerminationError.uncaughtSignal)
            default: break
            }
        }
    }

    @discardableResult
    public func run(_ command: Command) throws(ExecutionError) -> ExecutionResult {
        let process = self.create(command)

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
        } catch {
            throw ExecutionError.executionFailed(error)
        }

        process.waitUntilExit()

        let stdoutData: Data?
        let stderrData: Data?

        do {
            stdoutData = try stdoutPipe.fileHandleForReading.readToEnd()
            stderrData = try stderrPipe.fileHandleForReading.readToEnd()
        } catch {
            throw ExecutionError.failedToReadOutput(error)
        }

        switch process.terminationReason {
        case .exit:
            if process.terminationStatus != 0 {
                throw ExecutionError.nonZeroExitCode(process.terminationStatus)
            }
        case .uncaughtSignal:
            throw ExecutionError.uncaughtSignal
        @unknown default:
            throw ExecutionError.unknown
        }

        let stdoutString = String(data: stdoutData ?? Data(), encoding: .utf8) ?? ""
        let stderrString = String(data: stderrData ?? Data(), encoding: .utf8) ?? ""

        return ExecutionResult(
            exitCode: process.terminationStatus,
            stdout: stdoutString,
            stderr: stderrString
        )
    }
}


private extension Process {
    func streamOutput() -> AsyncThrowingStream<CommandOutput, Error> {
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        self.standardOutput = stdoutPipe
        self.standardError = stderrPipe

        return AsyncThrowingStream(CommandOutput.self) { continuation in
            continuation.onTermination = { _ in
                self.terminate()
            }

            let stdoutHandle = stdoutPipe.fileHandleForReading
            let stderrHandle = stderrPipe.fileHandleForReading

            stdoutHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    continuation.yield(.stdout(data))
                }
            }

            stderrHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    continuation.yield(.stdout(data))
                }
            }

            do {
                try self.run()
                self.waitUntilExit()
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}

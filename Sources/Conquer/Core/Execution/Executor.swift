//
//  Executor.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation.NSURL

public protocol Executor {
//    func stream(_ command: Command) -> AsyncThrowingStream<CommandOutput, Error>
    func run(_ command: Command) throws(ExecutionError) -> ExecutionResult
}

public enum ExecutionError: Error, LocalizedError {
    case executionFailed(Error)
    case failedToReadOutput(Error)
    case nonZeroExitCode(Int32)
    case uncaughtSignal
    case unknown

    public var errorDescription: String? {
        switch self {
        case .executionFailed(let error):
            "Command execution failed: \(error)"
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

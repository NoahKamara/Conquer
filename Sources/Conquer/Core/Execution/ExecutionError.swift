//
//  ExecutionError.swift
//  Conquer
//
//  Created by Noah Kamara on 20.01.2026.
//

import Foundation

public enum ExecutionError: Error, LocalizedError {
    /// Process failed to spawn or begin running.
    case executionFailed(Error)
    /// Process exceeded the configured timeout (in seconds) and was terminated.
    case timeout(Double)
    /// Reading from stdout or stderr failed with the underlying error.
    case failedToReadOutput(Error)
    /// Process terminated with a non-zero exit status.
    /// The stdout and stderr output from the process are included for debugging purposes.
    case nonZeroExitCode(Int32, stdout: String, stderr: String)
    /// Process ended due to an uncaught signal.
    case uncaughtSignal(Int32)
    /// An unknown failure occurred.
    case unknown

    public var errorDescription: String? {
        switch self {
        case .executionFailed(let error):
            return "Command execution failed: \(error)"
        case .timeout(let timeout):
            return "Command execution timed out after \(timeout.formatted(.number.precision(.fractionLength(3)))) seconds"
        case .failedToReadOutput(let error):
            return "Command execution failed to read output: \(error)"
        case .nonZeroExitCode(let exitCode, let stdout, let stderr):
            var description = "Command execution terminated with non-zero exit code: \(exitCode)"
            if !stdout.isEmpty {
                description += "\nstdout: \(stdout)"
            }
            if !stderr.isEmpty {
                description += "\nstderr: \(stderr)"
            }
            return description
        case .uncaughtSignal(let signal):
            return "Command execution terminated due to an uncaught signal: \(signal)"
        case .unknown:
            return "Command execution terminated due to an unknown error"
        }
    }
}

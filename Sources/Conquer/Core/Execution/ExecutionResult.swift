//
//  ExecutionResult.swift
//
//  Copyright © 2024 Noah Kamara.
//

/// The completed result of a command execution.
///
/// Instances of `ExecutionResult` are returned by ``Executor/run(_:options:)``
/// once the child process has terminated successfully (exit code 0). The
/// standard output and error are provided as UTF-8 strings.
public struct ExecutionResult {
    /// The exit status of the process (0 indicates success).
    let exitCode: Int32
    /// Text collected from the process standard output, interpreted as UTF-8.
    let stdout: String
    /// Text collected from the process standard error, interpreted as UTF-8.
    let stderr: String

    init(exitCode: Int32, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

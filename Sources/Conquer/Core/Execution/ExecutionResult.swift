//
//  ExecutionResult.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//


/// The result when executing a command
public struct ExecutionResult {
    let exitCode: Int32
    let stdout: String
    let stderr: String

    init(exitCode: Int32, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

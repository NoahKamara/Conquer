//
//  SystemExecutorTests.swift
//
//  Copyright © 2024 Noah Kamara.
//

@testable import Conquer
import Foundation
import Testing

@Suite("SystemExecutor")
struct SystemExecutorTests {
    let executor = SystemExecutor()

    @Test
    func executableNotFoundThrows() throws {
        do {
            _ = try self.executor.run(Command(executablePath: "/nonexistent_06sl4sh"))

            // should have thrown an error
            try #require(Bool(false))
        } catch let error as ExecutionError {
            guard case .executionFailed(let error) = error else {
                // must be non-zero error
                try #require(Bool(false))
                return
            }

            let nsError = error as NSError

            #expect(nsError.domain == "NSCocoaErrorDomain")
            #expect(nsError.code == 4)
            #expect(nsError.localizedDescription == "The file “nonexistent_06sl4sh” doesn’t exist.")
        }
    }

    @Test
    func nunNullExitCodeDoesNotThrow() throws {
        _ = try self.executor.run(.testScript("exit-code.sh", with: "0"))
    }

    @Test(arguments: [1, 255])
    func nonNullExitCodeThrows(code: Int32) async throws {
        do {
            try self.executor.run(.testScript("exit-code.sh", with: code.description))

            // should have thrown an error
            try #require(Bool(false))
        } catch let error as ExecutionError {
            guard case .nonZeroExitCode(let exitCode, let stdout, let stderr) = error else {
                // must be non-zero error
                try #require(Bool(false))
                return
            }

            #expect(exitCode == code)
            // stdout and stderr are now guaranteed to be strings
        }
    }

    @Test
    func nonZeroExitCodeIncludesOutput() throws {
        do {
            // Use a command that produces output and exits with non-zero code
            try self.executor.run(Command(
                executablePath: "/bin/sh",
                arguments: ["-c", "echo 'error output' >&2; echo 'stdout output'; exit 42"]
            ))

            // should have thrown an error
            try #require(Bool(false))
        } catch let error as ExecutionError {
            guard case .nonZeroExitCode(let exitCode, let stdout, let stderr) = error else {
                // must be non-zero error
                try #require(Bool(false))
                return
            }

            #expect(exitCode == 42)
            #expect(stdout == "stdout output\n")
            #expect(stderr == "error output\n")
        }
    }

    @Test(arguments: [
        ["FOO": "bar"],
        [:],
    ])
    func environment(_ expectedEnvironment: Environment) throws {
        let result = try self.executor.run(.printEnv(environment: expectedEnvironment))

        let environment: Environment = result.stdout
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .reduce(into: Environment()) { environment, line in
                let parts = line.split(separator: "=", maxSplits: 1)
                environment[String(parts[0])] = (parts.count > 1 ? String(parts[1]) : "")
            }

        #expect(environment == expectedEnvironment)
    }

    @Test
    func inheritedEnvironment() throws {
        let result = try self.executor.run(.printEnv(environment: nil))

        let environment: Environment = result.stdout
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .reduce(into: Environment()) { environment, line in
                let parts = line.split(separator: "=", maxSplits: 1)
                environment[String(parts[0])] = (parts.count > 1 ? String(parts[1]) : "")
            }

        #expect(environment.contains("PATH"))
    }

    @Test
    func currentDirectory() throws {
        let result = try executor.run(
            Command(executablePath: "/bin/pwd", currentDirectory: "/tmp")
        )

        let currentDirectory = result.stdout.trimmingCharacters(in: .newlines)
        #expect(currentDirectory == "/tmp")
    }

    @Test
    func runTimeoutThrows() throws {
        do {
            _ = try self.executor.run(
                Command(executablePath: "/bin/sleep", arguments: ["5"]),
                options: .init(timeout: 0.2)
            )

            // should have thrown a timeout
            try #require(Bool(false))
        } catch let error as ExecutionError {
            switch error {
            case .timeout:
                // expected
                break
            default:
                try #require(Bool(false))
            }
        }
    }

    @Test
    func streamTimeoutThrows() async throws {
        do {
            for try await _ in self.executor.stream(
                Command(executablePath: "/bin/sleep", arguments: ["5"]),
                options: .init(timeout: 0.2)
            ) {}

            // should have thrown a timeout
            try #require(Bool(false))
        } catch let error as ExecutionError {
            switch error {
            case .timeout:
                // expected
                break
            default:
                print(error)
                try #require(Bool(false))
            }
        }
    }

    @Test
    func runCapturesStdout() throws {
        let input = "hello stdout\n"
        let stdin = Self.makeInputPipe(input)

        let result = try self.executor.run(
            .testScript("stdin-to.sh", with: "stdout"),
            options: .init(standardInput: stdin, timeout: 10)
        )

        #expect(result.stdout == input)
        #expect(result.stderr == "")
    }

    @Test
    func runCapturesStderr() throws {
        let input = "hello stderr\n"
        let stdin = Self.makeInputPipe(input)

        let result = try self.executor.run(
            .testScript("stdin-to.sh", with: "stderr"),
            options: .init(standardInput: stdin, timeout: 10)
        )

        #expect(result.stdout == "")
        #expect(result.stderr == input)
    }

    @Test
    func streamCapturesStdout() async throws {
        let input = "stream hello stdout\n"
        let stdin = Self.makeInputPipe(input)

        var stdoutData = Data()
        var stderrData = Data()

        for try await chunk in self.executor.stream(
            .testScript("stdin-to.sh", with: "stdout"),
            options: .init(standardInput: stdin, timeout: 2)
        ) {
            switch chunk {
            case .stdout(let data):
                stdoutData.append(data)
            case .stderr(let data):
                stderrData.append(data)
            }
        }

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        #expect(stdout == input)
        #expect(stderr == "")
    }

    @Test
    func streamCapturesStderr() async throws {
        let input = "stream hello stderr\n"
        let stdin = Self.makeInputPipe(input)

        var stdoutData = Data()
        var stderrData = Data()

        for try await chunk in self.executor.stream(
            .testScript("stdin-to.sh", with: "stderr"),
            options: .init(standardInput: stdin)
        ) {
            switch chunk {
            case .stdout(let data):
                stdoutData.append(data)
            case .stderr(let data):
                stderrData.append(data)
            }
        }

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        #expect(stdout == "")
        #expect(stderr == input)
    }

    @Test
    func streamNonZeroExitCodeIncludesOutput() async throws {
        var collectedStdout = Data()
        var collectedStderr = Data()

        do {
            // Use a command that produces output and exits with non-zero code
            for try await chunk in self.executor.stream(
                Command(
                    executablePath: "/bin/sh",
                    arguments: ["-c", "echo 'stream stdout'; echo 'stream stderr' >&2; exit 1"]
                )
            ) {
                switch chunk {
                case .stdout(let data):
                    collectedStdout.append(data)
                case .stderr(let data):
                    collectedStderr.append(data)
                }
            }

            // should have thrown an error
            try #require(Bool(false))
        } catch let error as ExecutionError {
            guard case .nonZeroExitCode(let exitCode, let stdout, let stderr) = error else {
                // must be non-zero error
                try #require(Bool(false))
                return
            }

            #expect(exitCode == 1)
            #expect(stdout == "stream stdout\n")
            #expect(stderr == "stream stderr\n")

            // Also verify we collected the same output via streaming
            let collectedStdoutString = String(data: collectedStdout, encoding: .utf8) ?? ""
            let collectedStderrString = String(data: collectedStderr, encoding: .utf8) ?? ""
            #expect(collectedStdoutString == "stream stdout\n")
            #expect(collectedStderrString == "stream stderr\n")
        }
    }
}

private extension Command {
    static func pwd(
        currentDirectory: URL?
    ) -> Command {
        Command(executableURL: .init(filePath: "/bin/pwd"), currentDirectory: currentDirectory)
    }

    static func printEnv(
        environment: Environment? = nil
    ) -> Command {
        Command(executableURL: .init(filePath: "/usr/bin/env"), environment: environment)
    }
}

private extension SystemExecutorTests {
    static func makeInputPipe(_ string: String) -> Pipe {
        let pipe = Pipe()
        if let data = string.data(using: .utf8) {
            pipe.fileHandleForWriting.write(data)
        }
        try? pipe.fileHandleForWriting.close()
        return pipe
    }
}

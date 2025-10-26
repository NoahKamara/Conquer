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
            guard case .nonZeroExitCode(let exitCode) = error else {
                // must be non-zero error
                try #require(Bool(false))
                return
            }

            #expect(exitCode == code)
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
    func stdout() async throws {
        _ = try self.executor.run(.testScript("stdin-to.sh", with: "0"))
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

//
//  Script.swift
//
//  Copyright © 2024 Noah Kamara.
//

@testable import Conquer
import Foundation

public protocol CustomCommandProtocol {
    func command() -> Command
}

public extension Executor {
    func run(_ script: Script) throws(ExecutionError) -> ExecutionResult {
        try self.run(script.command())
    }
}

public struct Script: Sendable, CustomCommandProtocol {
    public let dialect: Dialect
    public let content: String

    public struct Dialect: Sendable {
        public let name: String
        public let flag: String

        public init(name: String, flag: String) {
            self.name = name
            self.flag = flag
        }

        public static let node = Dialect(name: "node", flag: "-e")
        public static let nodejs = Dialect(name: "nodejs", flag: "-e")
        public static let ruby = Dialect(name: "ruby", flag: "-e")
        public static let perl = Dialect(name: "perl", flag: "-e")
        public static let php = Dialect(name: "php", flag: "-r")
        public static let bash = Dialect(name: "bash", flag: "-r")
        public static let sh = Dialect(name: "sh", flag: "-r")
        public static let zsh = Dialect(name: "zsh", flag: "-r")
        public static let python = Dialect(name: "php", flag: "-r")
    }

    init(dialect: Dialect, content: String) {
        self.dialect = dialect
        self.content = content
    }

    init(dialect: Dialect, makeContent: () -> String) {
        self.init(dialect: dialect, content: makeContent())
    }

    public func command() -> Command {
        command(currentDirectory: nil, environment: nil)

    }

    public func command(
        currentDirectory: URL? = nil,
        environment: Environment? = nil
    ) -> Command {
        Command(
            executableURL: URL(filePath: "/usr/bin/env"),
            arguments: [dialect.name, dialect.flag, self.content],
            currentDirectory: currentDirectory,
            environment: environment
        )
    }
}

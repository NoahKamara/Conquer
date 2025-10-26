//
//  File.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//

import Foundation

public extension Command {
    static func env(
        utility: String,
        arguments: [String] = [],
        currentDirectory: URL? = nil,
        environment: Environment? = nil
    ) -> Command {
        Command(
            executableURL: .init(filePath: "/usr/bin/env"),
            arguments: [utility] + arguments,
            currentDirectory: currentDirectory,
            environment: environment
        )
    }

    static func echo(
        _ message: Any...,
        currentDirectory: URL? = nil,
        environment: [String : String]? = nil
    ) -> Command {
        Command.env(utility: "echo", arguments: message.map(String.init(describing:)))
    }
}

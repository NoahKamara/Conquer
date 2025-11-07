//
//  Command+echo.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension Command {
    /// Create a command that writes the specified operands to standard output using the `echo`
    /// utility.
    ///
    /// This uses `/usr/bin/env echo` rather than a shell builtin to provide consistent behavior.
    ///
    /// - Parameters:
    ///   - operands: The values to print to standard output.
    ///   - omitTrailingNewline: When `true`, pass `-n` to `echo` to suppress the trailing newline.
    /// - Returns: A ``Command`` that will execute the system `echo` utility.
    static func echo(_ operands: String..., omitTrailingNewline: Bool = false) -> Command {
        var args: [String] = []
        if omitTrailingNewline { args.append("-n") }
        args.append(contentsOf: operands)
        return Command.env(utility: "echo", arguments: args)
    }
}

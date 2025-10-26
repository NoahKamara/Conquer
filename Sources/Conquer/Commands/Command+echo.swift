//
//  File.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//

import Foundation

extension Command {
    /// The echo utility writes any specified operands to the standard output.
    ///
    /// Some shells may provide a builtin echo command which is
    /// similar or identical to this utility.  Most notably,
    /// the builtin echo in sh does not accept the -n
    /// option.
    ///
    /// - Parameters:
    ///   - operands: the operands to write to standard output
    ///   - omitTrailingNewline: Do not print the trailing newline character
    public static func echo(_ operands: String..., omitTrailingNewline: Bool = false) -> Command {
        Command.env(utility: "echo", arguments: operands)
    }
}

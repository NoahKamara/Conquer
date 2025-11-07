//
//  CommandOutput.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation.NSData

/// A chunk of process output produced while executing a command.
///
/// Values are produced incrementally by streaming APIs such as
/// ``Executor/stream(_:options:)``. Each case contains a slice of the
/// corresponding pipe's data; collect and concatenate if you need the full
/// output.
public enum CommandOutput: Sendable {
    /// Bytes read from the process standard output pipe.
    case stdout(Data)
    /// Bytes read from the process standard error pipe.
    case stderr(Data)
}

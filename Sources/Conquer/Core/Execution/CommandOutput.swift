//
//  CommandOutput.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//


import Foundation.NSData

/// the output of a command during execution. this is a slice, not the entire output
public enum CommandOutput: Sendable {
    case stdout(Data)
    case stderr(Data)
}

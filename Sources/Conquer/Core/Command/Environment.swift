//
//  Environment.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A lightweight, type-safe representation of a process environment.
///
/// `Environment` stores a mapping of variable names to values and can be
/// constructed directly from a dictionary literal. Use it to provide a custom
/// environment when executing a `Command`, or access the current process
/// environment via ``Environment/current()``.
public struct Environment: Sendable, Equatable, ExpressibleByDictionaryLiteral,
    CustomStringConvertible
{
    private(set) var values: [String: String] = [:]

    /// Create a new `Environment` with the given key-value pairs.
    /// - Parameter values: The initial variables to set.
    public init(values: [String: String] = [:]) {
        self.values = values
    }

    /// Create a new `Environment` from a dictionary literal.
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init(values: .init(uniqueKeysWithValues: elements))
    }

    /// Access or modify a variable by name.
    /// - Parameter name: The variable name.
    /// - Returns: The value if set; otherwise `nil`.
    public subscript(_ name: String) -> String? {
        get { self.values[name] }
        set { self.values[name] = newValue }
    }

    /// Whether the environment has no variables.
    public var isEmpty: Bool {
        self.values.isEmpty
    }

    /// Returns `true` if a variable with the given name exists.
    public func contains(_ name: String) -> Bool {
        self.values.keys.contains(name)
    }

    /// The current process environment
    public static func current() -> Environment {
        Environment(values: ProcessInfo.processInfo.environment)
    }

    /// A human-readable representation of the environment for debugging.
    public var description: String {
        "Environment(\(self.values))"
    }
}

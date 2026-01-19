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
public struct Environment: Sendable, Equatable, CustomStringConvertible {
    private(set) var _values: [String: String] = [:]

    /// Create a new `Environment` with the given key-value pairs.
    /// - Parameter values: The initial variables to set.
    public init(values: [String: String] = [:]) {
        self._values = values
    }

    /// Access or modify a variable by name.
    /// - Parameter name: The variable name.
    /// - Returns: The value if set; otherwise `nil`.
    public subscript(_ name: String) -> String? {
        get { self._values[name] }
        set { self._values[name] = newValue }
    }

    /// Whether the environment has no variables.
    public var isEmpty: Bool {
        self._values.isEmpty
    }

    /// Returns `true` if a variable with the given name exists.
    public func contains(_ name: String) -> Bool {
        self._values.keys.contains(name)
    }

    /// The current process environment
    public static func current() -> Environment {
        Environment(values: ProcessInfo.processInfo.environment)
    }

    /// A human-readable representation of the environment for debugging.
    public var description: String {
        "Environment(\(self._values))"
    }
}

extension Environment: ExpressibleByDictionaryLiteral {
    /// Create a new `Environment` from a dictionary literal.
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init(values: .init(uniqueKeysWithValues: elements))
    }
}

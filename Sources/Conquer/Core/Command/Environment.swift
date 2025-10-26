//
//  Environment.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//

import Foundation

public struct Environment: Sendable, Equatable, ExpressibleByDictionaryLiteral,
    CustomStringConvertible
{
    private(set) var values: [String: String] = [:]

    public init(values: [String: String] = [:]) {
        self.values = values
    }

    public init(dictionaryLiteral elements: (String, String)...) {
        self.init(values: .init(uniqueKeysWithValues: elements))
    }

    public subscript(_ name: String) -> String? {
        get { values[name] }
        set { values[name] = newValue }
    }

    public var isEmpty: Bool {
        values.isEmpty
    }

    public func contains(_ name: String) -> Bool {
        values.keys.contains(name)
    }

    /// The current process environment
    public static func current() -> Environment {
        Environment(values: ProcessInfo.processInfo.environment)
    }

    public var description: String {
        "Environment(\(values))"
    }
}

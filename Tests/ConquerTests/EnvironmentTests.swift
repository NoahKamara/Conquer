//
//  File.swift
//  Conquer
//
//  Created by Noah Kamara on 26.10.2025.
//

import Testing
@testable import Conquer
import Foundation

@Suite("Environment")
struct EnvironmentTests {
    @Test(.disabled(if: ProcessInfo.processInfo.environment.isEmpty))
    func currentProcess() async throws {
        let env = Environment.current()
        #expect(!env.isEmpty)
        #expect(env["PWD"] != nil)
        #expect(env.contains("PWD"))
    }

    @Test
    func editEnvironment() async throws {
        var env: Environment = [:]
        try #require(env.isEmpty)
        env["HELLO"] = "THERE"
        #expect(env["HELLO"] == "THERE")
        #expect(env == ["HELLO": "THERE"])
    }
}

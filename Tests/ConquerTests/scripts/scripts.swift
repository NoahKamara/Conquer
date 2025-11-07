//
//  scripts.swift
//
//  Copyright © 2024 Noah Kamara.
//

import Conquer
import Foundation

extension Command {
    static func testScript(_ name: String, with arguments: String...) -> Command {
        let scriptURL = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .appending(component: name)

        return Command(
            executableURL: .init(filePath: "/usr/bin/env"),
            arguments: ["bash", scriptURL.path] + arguments
        )
    }
}

// extension Command {
//    static func testExitCode(_ code: Int32) -> Command {
//        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
//        let scriptURL = testsDirectory.appendingPathComponent("scripts/exit-code.sh")
//
//        return Command(
//            executableURL: .init(filePath: "/usr/bin/env"),
//            arguments: ["bash", scriptURL.path, String(code)]
//        )
//    }
//
//    static func cat(_ code: Int32) -> Command {
//        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
//        let scriptURL = testsDirectory.appendingPathComponent("scripts/exit-code.sh")
//
//        return Command(
//            executableURL: .init(filePath: "/usr/bin/env"),
//            arguments: ["bash", scriptURL.path, String(code)]
//        )
//    }
//
//    static func stdinToStdout(_ code: Int32) -> Command {
//        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
//        let scriptURL = testsDirectory.appendingPathComponent("scripts/stdin-to.sh")
//
//        return Command(
//            executableURL: .init(filePath: "/usr/bin/env"),
//            arguments: ["bash", scriptURL.path, String(code)]
//        )
//    }
// }

//import Testing
//@testable import Conquer
//import Foundation
//
//extension Command {
//    static func env(
//        _ executableName: String,
//        arguments: [String] = [],
//        currentDirectory: URL? = nil,
//        environment: Environment? = nil
//    ) -> Command {
//        Command(
//            executableURL: .init(filePath: "/usr/bin/env"),
//            arguments: [executableName] + arguments,
//            currentDirectory: currentDirectory,
//            environment: environment
//        )
//    }
//}
//
//extension Command {
//    static func echo(
//        _ message: Any...,
//        currentDirectory: URL? = nil,
//        environment: [String : String]? = nil
//    ) -> Command {
//        Command.env("echo", arguments: message.map(String.init(describing:)))
//    }
//}
//
//@Test(arguments: [
//    Command.env("echo", arguments: ["hello"])
//])
//func example(command: Command) async throws {
//    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//}

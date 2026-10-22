// SPDX-License-Identifier: MIT
import Foundation

struct Check {
    let name: String
    let run: () throws -> Void
    init(_ name: String, run: @escaping () throws -> Void) { self.name = name; self.run = run }
}

struct CheckFailure: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

func expect(_ condition: @autoclosure () -> Bool, file: StaticString = #filePath, line: UInt = #line) throws {
    if !condition() { throw CheckFailure(message: "Expectation failed at \(file):\(line)") }
}

@main
struct Runner {
    static func main() {
        let checks = visibilityChecks + preferencesChecks
        var failures = 0
        for check in checks {
            do { try check.run(); print("PASS \(check.name)") }
            catch { failures += 1; print("FAIL \(check.name): \(error)") }
        }
        print("\(checks.count - failures)/\(checks.count) checks passed")
        if failures > 0 { exit(1) }
    }
}

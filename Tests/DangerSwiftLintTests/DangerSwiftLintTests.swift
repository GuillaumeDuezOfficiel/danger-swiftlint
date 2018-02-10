import XCTest
import Danger
@testable import DangerSwiftLint

class DangerSwiftLintTests: XCTestCase {
    var executor: FakeShellExecutor!
    var danger: DangerDSL!
    var markdownMessage: String?

    override func setUp() {
        executor = FakeShellExecutor()
        // This is for me, testing. Uncomment if you're running tests locally.
        FileManager.default.changeCurrentDirectoryPath("/Users/lukaszmroz/Projects/OtherProjects/Libraries/danger-swiftlint")
        let dslJSONContents = FileManager.default.contents(atPath: "./Tests/Fixtures/harness.json")!
        danger = try! JSONDecoder().decode(DSL.self, from: dslJSONContents).danger
        markdownMessage = nil
    }

    func testExecutesTheShell() {
        _ = SwiftLint.lint(danger: danger, shellExecutor: executor)
        XCTAssertNotEqual(executor.invocations.dropFirst().count, 0)
    }

    func testExecutesSwiftLintWithConfigWhenPassed() {
        let configFile = "/Path/to/config/.swiftlint.yml"

        _ = SwiftLint.lint(danger: danger, shellExecutor: executor, configFile: configFile)

        let swiftlintCommands = executor.invocations.filter { $0.command == "swiftlint" }
        XCTAssertTrue(swiftlintCommands.count > 0)
        swiftlintCommands.forEach { command, arguments in
            XCTAssertTrue(arguments.contains("--config \(configFile)"))
        }
    }

    func testExecutesSwiftLintWithDirectoryPassed() {
        let dslJSONContents = FileManager.default.contents(atPath: "./Tests/Fixtures/harness_directories.json")!
        danger = try! JSONDecoder().decode(DSL.self, from: dslJSONContents).danger
        let directory = "Tests"

        _ = SwiftLint.lint(danger: danger, shellExecutor: executor, directory: directory)
        
        let swiftlintCommands = executor.invocations.filter { $0.command == "swiftlint" }
        XCTAssertTrue(swiftlintCommands.count == 1)
        XCTAssertTrue(swiftlintCommands.first!.arguments.contains("--path Tests/SomeFile.swift"))
    }

    func testFiltersOnSwiftFiles() {
        _ = SwiftLint.lint(danger: danger, shellExecutor: executor)
        let filesExtensions = Set(executor.invocations.dropFirst().flatMap { $0.arguments[2].split(separator: ".").last })
        XCTAssertEqual(filesExtensions, ["swift"])
    }

    func testPrintsNoMarkdownIfNoViolations() {
        _ = SwiftLint.lint(danger: danger, shellExecutor: executor)
        XCTAssertNil(markdownMessage)
    }

    func testViolations() {
        mockViolationJSON()
        let violations = SwiftLint.lint(danger: danger, shellExecutor: executor, markdown: writeMarkdown)
        XCTAssertEqual(violations.count, 2) // Two files, one (identical oops) violation returned for each.
    }

    func testMarkdownReporting() {
        mockViolationJSON()
        _ = SwiftLint.lint(danger: danger, shellExecutor: executor, markdown: writeMarkdown)
        XCTAssertNotNil(markdownMessage)
        XCTAssertTrue(markdownMessage!.contains("SwiftLint found issues"))
    }

    func mockViolationJSON() {
        executor.output = """
        [
            {
                "rule_id" : "opening_brace",
                "reason" : "Opening braces should be preceded by a single space and on the same line as the declaration.",
                "character" : 39,
                "file" : "/Users/ash/bin/Harvey/Sources/Harvey/Harvey.swift",
                "severity" : "Warning",
                "type" : "Opening Brace Spacing",
                "line" : 8
            }
        ]
        """
    }

    func writeMarkdown(_ m: String) {
        markdownMessage = m
    }

    static var allTests = [
        ("testExecutesTheShell", testExecutesTheShell),
        ("testFiltersOnSwiftFiles", testFiltersOnSwiftFiles),
        ("testPrintsNoMarkdownIfNoViolations", testPrintsNoMarkdownIfNoViolations),
        ("testViolations", testViolations),
        ("testMarkdownReporting", testMarkdownReporting)
    ]
}

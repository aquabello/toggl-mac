import XCTest
import SwiftData
@testable import TogglMac

final class ProjectTests: XCTestCase {

    func testCreation() {
        let project = Project(name: "Work", colorHex: "FF6B6B")

        XCTAssertEqual(project.name, "Work")
        XCTAssertEqual(project.colorHex, "FF6B6B")
        XCTAssertNotNil(project.id)
        XCTAssertNotNil(project.createdAt)
    }

    func testTimeEntriesRelationship() {
        let project = Project(name: "Work", colorHex: "4ECDC4")
        XCTAssertNil(project.timeEntries)
    }
}

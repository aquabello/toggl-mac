import XCTest
@testable import TogglMac

final class HotkeyServiceTests: XCTestCase {

    func testServiceInitializesWithoutCrash() {
        let service = HotkeyService()
        XCTAssertNotNil(service)
    }

    func testUnregisterWithoutRegisterDoesNotCrash() {
        let service = HotkeyService()
        service.unregister()
        // No crash expected
    }
}

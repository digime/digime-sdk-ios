import XCTest
@testable import DigiMePlugin

class DigiPluginTests: XCTestCase {
    func testEcho() {
        // This is an example of a functional test case for a plugin.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let implementation = DigiPlugin()
        let value = "Hello, World!"
        let result = implementation.fetchHealthData(value)

        XCTAssertEqual(value, result)
    }
}

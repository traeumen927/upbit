import XCTest
@testable import upbit

// Extend SocketRequestType for Codable conformance in tests
extension SocketRequestType: Codable {}

final class SocketRequestTypeTests: XCTestCase {
    func testJSONEncodingDecoding() throws {
        let cases: [SocketRequestType] = [.ticker, .orderbook, .myOrder, .trade]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for value in cases {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(SocketRequestType.self, from: data)
            XCTAssertEqual(decoded, value)
        }
    }

    func testAuthenticationRequirement() {
        XCTAssertTrue(SocketRequestType.myOrder.requiresAuth)
        XCTAssertFalse(SocketRequestType.ticker.requiresAuth)
    }
}

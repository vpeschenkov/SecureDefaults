import XCTest
@testable import SecureDefaults

final class SecureDefaultsTests: XCTestCase {
    
    func testEncryption() {
        let key = "test.key.string"
        let value = "Just a test message"
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertTrue((defaults.rawObject(forKey: key) as? Data != nil))
        XCTAssertTrue((defaults.rawObject(forKey: key) as? String == nil))
    }
    
    func testString() {
        let key = "test.key.string"
        let value = "Just a test message"
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.string(forKey: key), value)
    }
    
    func testStringWithWrongPassword() {
        // Prepare data
        let key = "test.key.string"
        let value = "Just a test message"
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.string(forKey: key), value)
        // Test
        let wrongDefaults = SecureDefaults()
        wrongDefaults.password = "test.wrong.password"
        XCTAssertNotEqual(wrongDefaults.string(forKey: key), value)
    }
    
    func testURL() {
        let key = "test.key.url"
        let value = URL(string: "https://github.com/vpeschenkov/SecureDefaults")!
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.url(forKey: key), value)
    }
    
    func testInteger() {
        let key = "test.key.integer"
        let value = Int(10)
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.integer(forKey: key), value)
    }
    
    func testFloat() {
        let key = "test.key.float"
        let value = Float(10.0)
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.float(forKey: key), value)
    }
    
    func testDouble() {
        let key = "test.key.double"
        let value = Double(10.0)
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.double(forKey: key), value)
    }
    
    func testBool() {
        let key = "test.key.bool"
        let value = true
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.bool(forKey: key), value)
    }

    static var allTests = [
        ("testEncryption", testEncryption),
        ("testString", testString),
        ("testStringWithWrongPassword", testStringWithWrongPassword),
        ("testURL", testURL),
        ("testInteger", testInteger),
        ("testFloat", testFloat),
        ("testDouble", testDouble),
        ("testBool", testBool),
    ]
}

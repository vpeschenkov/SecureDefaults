import XCTest
@testable import SecureDefaults

final class SecureDefaultsTests: XCTestCase {
    
    func testString() {
        let key = "test.key.string"
        let value = "Just a test message"
        let defaults = SecureDefaults()
        defaults.password = "test.password"
        defaults.set(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.string(forKey: key), value)
    }
    
    func testRawObject() {
        let key = "test.key.string"
        let value = "Just a test message"
        let defaults = SecureDefaults()
        defaults.setRawObject(value, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.rawObject(forKey: key) as? String, value)
    }
    
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


    func testKeychainAccessibleAlwaysMigrationOnRead() {
        let key = "test.key.keychainAccessibleAlwaysMigration"
        let value = "Just a test message"
        let password = "test.password"
        let kSecAttrAccessibleAlways = "dk"

        cleanupKeychain()

        // Save data using deprecated default accessible attribute
        let defaultsSecAttrAccessibleAlways = SecureDefaults()
        defaultsSecAttrAccessibleAlways.keychainAccessible = kSecAttrAccessibleAlways
        if !defaultsSecAttrAccessibleAlways.isKeyCreated {
            defaultsSecAttrAccessibleAlways.password = password
        }
        defaultsSecAttrAccessibleAlways.set(value, forKey: key)
        defaultsSecAttrAccessibleAlways.synchronize()
        XCTAssertEqual(defaultsSecAttrAccessibleAlways.string(forKey: key), value)

        // Read data using default accessible attribute
        let defaults = SecureDefaults()
        if !defaults.isKeyCreated {
            defaults.password = password
        }
        XCTAssertEqual(defaults.string(forKey: key), value)

        // Clean up (remove keys from the keychain)
        cleanupKeychain()
    }

    func testKeychainAccessibleAlwaysMigrationOnWrite() {
        let key = "test.key.keychainAccessibleAlwaysMigration"
        let value = "Just a test message"
        let newValue = "Just a new test message"
        let password = "test.password"
        let kSecAttrAccessibleAlways = "dk"

        cleanupKeychain()

        // Save data using deprecated default accessible attribute
        let defaultsSecAttrAccessibleAlways = SecureDefaults()
        defaultsSecAttrAccessibleAlways.keychainAccessible = kSecAttrAccessibleAlways
        if !defaultsSecAttrAccessibleAlways.isKeyCreated {
            defaultsSecAttrAccessibleAlways.password = password
        }
        defaultsSecAttrAccessibleAlways.set(value, forKey: key)
        defaultsSecAttrAccessibleAlways.synchronize()
        XCTAssertEqual(defaultsSecAttrAccessibleAlways.string(forKey: key), value)

        // Save data using default accessible attribute
        let defaults = SecureDefaults()
        if !defaults.isKeyCreated {
            defaults.password = password
        }
        defaults.set(newValue, forKey: key)
        defaults.synchronize()
        XCTAssertEqual(defaults.string(forKey: key), newValue)

        // Clean up (remove keys from the keychain)
        cleanupKeychain()
    }

    func cleanupKeychain() {
        let kSecAttrAccessibleAlways = "dk"
        KeychainHelper.remove(forKey: SecureDefaults.Keys.AESKey, accessible: kSecAttrAccessibleAlways)
        KeychainHelper.remove(forKey: SecureDefaults.Keys.AESKey, accessible: kSecAttrAccessibleAfterFirstUnlock as String)
        KeychainHelper.remove(forKey: SecureDefaults.Keys.AESIV, accessible: kSecAttrAccessibleAlways)
        KeychainHelper.remove(forKey: SecureDefaults.Keys.AESIV, accessible: kSecAttrAccessibleAfterFirstUnlock as String)
    }
}

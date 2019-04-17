//
// SecureDefaults.swift
// SecureDefaults
//
// Copyright 2019 Victor Peschenkov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// o this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import CommonCrypto

/**
 Overrides the `NSUserDefaults` class within addition to encrypt and decrypt data. It uses the
 Advanced Encryption Standard (AES) to encrypt and decrypt data.
 
 - SeeAlso: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
 */
@objc(PVSecureDefaults)
public class SecureDefaults: UserDefaults {
    
    private enum Keys {
        static let AESIV = "SecureDefaults.AESIV"
        static let AESKey = "SecureDefaults.AESKey"
    }
    
    /** Use this instead of `NSUserDefaults.standard` */
    static public let shared = SecureDefaults()
    
    /**
     A key whose value indicates when a keychain item is accessible.
     
     - SeeAlso: https://developer.apple.com/documentation/security/ksecattraccessible
     */
    public var keychainAccessible: String = kSecAttrAccessibleAlways as String
    
    /**
     A key whose value is a string indicating the access group an item is in.
     
     - SeeAlso: https://developer.apple.com/documentation/security/ksecattraccessgroup
     */
    public var keychainAccessGroup: String?

    /** A password to build a key if the one isn't set manually by `key` property */
    public var password: String? {
        didSet {
            let AESKey = suitename != nil ? "\(Keys.AESKey)-\(suitename!)" : Keys.AESKey
            let AESIVKey = suitename != nil ? "\(Keys.AESIV)-\(suitename!)" : Keys.AESIV
            KeychainHelper.remove(forKey: AESIVKey, accessible: keychainAccessible)
            KeychainHelper.remove(forKey: AESKey, accessible: keychainAccessible)
        }
    }
    
    /**
     A `key` to use within encrypting and decrypting. The key is regenerated for each `suitName` and stored
     in Keychain as \(Keys.AESKey)-\(suitename).
     
     - Note: You are able to make you own key and set it by using this property.
     */
    public var key: Data! {
        get {
            if _key == nil {
                assert(password != nil, "Password can't be nil!")
                _key = try? AES256.createKey(
                    password: password!.data(using: .utf8)!,
                    salt: AES256.randomSalt()
                )
            }
            return _key
        }
        set {
            _key = newValue
        }
    }
    
    /// Use this property to check that password is already created for this particular defaults.
    /// It can be useful if you share user defaults and keychain groups. Or just to ensure that you set a
    /// password only once.
    ///
    /// ```
    /// if (!defaults.isKeyCreated) {
    ///     defaults.password = "AnyPassword"
    /// }
    ///
    /// ```
    public var isKeyCreated: Bool {
        get {
            return _key != nil
        }
    }
    
    /**
     A `IV` to use within encrypting and decrypting. The key is regenerated for each `suitName` and stored
     in Keychain as \(Keys.AESIV)-\(suitename).
     
     - Note: You are able to make you own `iv` and set it by using this property.
     */
    public var IV: Data! {
        get {
            if _IV == nil {
                _IV = AES256.randomIV()
            }
            return _IV
        }
        set {
            _IV = newValue
        }
    }
    
    public override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
        self.suitename = suitename
    }
    
    // MARK - Public Methods
    
    public func rawObject(forKey defaultName: String) -> Any? {
        return super.object(forKey: defaultName)
    }
    
    public func setRawObject(_ value: Any?, forKey defaultName: String) {
        super.set(value, forKey: defaultName)
    }
    
    public override func object(forKey defaultName: String) -> Any? {
        return secretObject(forKey: defaultName)
    }
    
    public override func set(_ value: Any?, forKey defaultName: String) {
        setSecret(value as Any, forKey: defaultName)
    }
    
    public override func set(_ value: Int, forKey defaultName: String) {
        setSecret(value as Any, forKey: defaultName)
    }
    
    public override func set(_ value: Float, forKey defaultName: String) {
        setSecret(value as Any, forKey: defaultName)
    }
    
    public override func set(_ value: Double, forKey defaultName: String) {
        setSecret(value as Any, forKey: defaultName)
    }
    
    public override func set(_ value: Bool, forKey defaultName: String) {
        setSecret(value as Any, forKey: defaultName)
    }
    
    public override func set(_ url: URL?, forKey defaultName: String) {
        setSecret(url as Any?, forKey: defaultName)
    }
    
    public override func string(forKey defaultName: String) -> String? {
        return secretObject(forKey: defaultName) as? String
    }
    
    public override func array(forKey defaultName: String) -> [Any]? {
        return secretObject(forKey: defaultName) as? [Any]
    }
    
    public override func dictionary(forKey defaultName: String) -> [String : Any]? {
        return secretObject(forKey: defaultName) as? [String : Any]
    }
    
    public override func data(forKey defaultName: String) -> Data? {
        return secretObject(forKey: defaultName) as? Data
    }
    
    public override func stringArray(forKey defaultName: String) -> [String]? {
        return secretObject(forKey: defaultName) as? [String]
    }
    
    public override func integer(forKey defaultName: String) -> Int {
        return secretObject(forKey: defaultName) as? Int ?? 0
    }
    
    public override func float(forKey defaultName: String) -> Float {
        return secretObject(forKey: defaultName) as? Float ?? Float.nan
    }
    
    public override func double(forKey defaultName: String) -> Double {
        return secretObject(forKey: defaultName) as? Double ?? Double.nan
    }
    
    public override func bool(forKey defaultName: String) -> Bool {
        return secretObject(forKey: defaultName) as? Bool ?? false
    }
    
    public override func url(forKey defaultName: String) -> URL? {
        return secretObject(forKey: defaultName) as? URL
    }
    
    // MARK - Private Methods
    
    private var suitename: String?
    
    private lazy var decrypter = {
        return try! AES256(key: self.key, iv: self.IV)
    }()
    
    private lazy var encrypter = {
        return try! AES256(key: self.key, iv: self.IV)
    }()
    
    private var _key: Data? {
        get {
            let key = suitename != nil ? "\(Keys.AESKey)-\(suitename!)" : Keys.AESKey
            return KeychainHelper.get(
                forKey: key,
                group: keychainAccessGroup,
                accessible: keychainAccessible
                ) as Data?
        }
        set {
            let key = suitename != nil ? "\(Keys.AESKey)-\(suitename!)" : Keys.AESKey
            KeychainHelper.set(
                newValue as Data?,
                forKey: key,
                group: keychainAccessGroup,
                accessible: keychainAccessible
            )
        }
    }
    
    private var _IV: Data? {
        get {
            let key = suitename != nil ? "\(Keys.AESIV)-\(suitename!)" : Keys.AESIV
            return KeychainHelper.get(
                forKey: key,
                group: keychainAccessGroup,
                accessible: keychainAccessible
                ) as Data?
        }
        set {
            let key = suitename != nil ? "\(Keys.AESIV)-\(suitename!)" : Keys.AESIV
            KeychainHelper.set(
                newValue as Data?,
                forKey: key,
                group: keychainAccessGroup,
                accessible: keychainAccessible
            )
        }
    }
    
    private func secretObject(forKey defaultName: String) -> Any? {
        let object = super.object(forKey: defaultName)
        if let object = object {
            let decrypted = try! decrypter.decrypt(object as! Data)
            let data = NSKeyedUnarchiver.unarchiveObject(with: decrypted)
            return data
        }
        return object
    }
    
    private func setSecret(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            super.set(try! encrypter.encrypt(data), forKey: defaultName)
            return
        }
        super.set(nil, forKey: defaultName)
    }
}

//
// KeychainHelper.swift
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

final class KeychainHelper {
    
    @discardableResult
    static func set(
        _ data: Data?,
        forKey key: String,
        group: String?,
        accessible: String
        ) -> Bool {
        guard let data = data else {
            var query = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccessible as String: accessible,
                kSecAttrAccount as String: key
            ] as [String : Any]
            if let group = group {
                query[kSecAttrAccessGroup as String] = group
            }
            return (SecItemDelete(query as CFDictionary) == noErr)
        }
        var query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccessible as String: accessible,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String : Any]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == noErr
    }
    
    @discardableResult
    static func get(
        forKey key: String,
        group: String?,
        accessible: String
        ) -> Data? {
        var query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccessible as String: accessible,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        var dataRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
        if status == noErr {
            return dataRef as? Data
        }
        return nil
    }
    
    @discardableResult
    static func remove(forKey key: String, accessible: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccessible as String: accessible,
            kSecAttrAccount as String: key
        ] as [String : Any]
        return (SecItemDelete(query as CFDictionary) == noErr)
    }
}

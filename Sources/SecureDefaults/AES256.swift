//
// AES256.swift
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
 Note: https://gist.github.com/hfossli/7165dc023a10046e2322b0ce74c596f8
 */
struct AES256 {
    
    private var key: Data
    private var IV: Data
    
    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.IV = iv
    }
    
    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }
    
    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }
    
    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes { (inputBuffer: UnsafeRawBufferPointer) in
            IV.withUnsafeBytes { (IVBuffer: UnsafeRawBufferPointer) in
                key.withUnsafeBytes { (keyBuffer: UnsafeRawBufferPointer) in
                    let inputBytes = inputBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    let IVBytes = IVBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    let keyBytes = keyBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    status = CCCrypt(
                        operation,
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes,
                        key.count,
                        IVBytes,
                        inputBytes,
                        input.count,
                        &outBytes,
                        outBytes.count,
                        &outLength
                    )
                }
            }
        }
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
    }
    
    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBuffer: UnsafeRawBufferPointer) in
            salt.withUnsafeBytes { (saltBuffer: UnsafeRawBufferPointer) in
                let passwordBytes = passwordBuffer.baseAddress?.assumingMemoryBound(to: Int8.self)
                let saltBytes = saltBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                status = CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordBytes,
                    password.count,
                    saltBytes,
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                    10000,
                    &derivedBytes,
                    length
                )
            }
        }
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
    
    static func randomIV() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }
    
    static func randomSalt() -> Data {
        return randomData(length: 8)
    }
    
    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { buffer -> Int32 in
            if let bytes = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                return SecRandomCopyBytes(kSecRandomDefault, length, bytes)
            }
            return -1
        }
        assert(status == Int32(0))
        return data
    }
}

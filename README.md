# SecureDefaults for iOS, macOS

[![Build Status](https://travis-ci.com/vpeschenkov/SecureDefaults.svg?token=HrZYyqqJZx2172zxUQSb&branch=master&style=flat)](https://travis-ci.com/vpeschenkov/SecureDefaults)
[![Platform](https://img.shields.io/cocoapods/p/SecureDefaults.svg?style=flat)](https://cocoapods.org/pods/SecureDefaults)
[![Version](https://img.shields.io/cocoapods/v/SecureDefaults.svg?style=flat)](https://cocoapods.org/pods/SecureDefaults)
[![Carthage compatible](https://img.shields.io/badge/carthage-compatible-blue.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![License](https://img.shields.io/cocoapods/l/SecureDefaults.svg?style=flat)](https://cocoapods.org/pods/SecureDefaults)

<p align="center">
    <a href="#requirements">Requirements</a>
  • <a href="#usage">Usage</a>
  • <a href="#installation">Installation</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#acknowledgmentsn">Acknowledgments</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#author">Author</a>
  • <a href="#license">License</a>
</p>

`SecureDefaults` is a wrapper over `UserDefaults/NSUserDefaults` with an extra [AES-256](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) encryption layer (key size has **256-bit** length). It encludes:
- AES-256 encryption
- Password stretching with PBKDF2
- Encrypt-then-hash HMAC
- Password salting
- Random IV

> The design and strength of all key lengths of the AES algorithm (i.e., 128, 192 and 256) are sufficient to protect classified information up to the SECRET level. TOP SECRET information will require use of either the 192 or 256 key lengths. The implementation of AES in products intended to protect national security systems and/or information must be reviewed and certified by NSA prior to their acquisition and use. <sup>[\[1\]](https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/archived-crypto-projects/aes-development)</sup>

## Motivation

- Avoiding the following behavior https://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled. (Yes, there is still a key, but there is no data)
- Avoiding additional thinking about there is a good place to store a particular value. (choice between Keychain and `UserDefaults`)
- Improving a situation with security on the iOS platform. Many apps I've seen didn't use `Keychain`. They store all sensitive data in `UserDefaults` (access tokens, passwords, etc)... At least, this can help to make such apps a bit more secured without pain. Perhaps, if this framework is almost the same as `UserDefaults`, maybe developers will start using it?
- It doesn't look good to keep many simple keys in `Keychain`.

## Requirements

- iOS 8.0+
- macOS 10.11+
- Xcode 10.1+
- Swift 4.2+

## Usage

It is pretty simple to use `SeccureDefaults` instead of `UserDefaults/NSUserDefaults`. In most cases, it is the same thing that is `UserDefaults`. You just need to set a password to make it work.

Replace the following code:

```swift
UserDefaults.standard
```

by this one:

```swift
let defaults = SecureDefaults.shared
// Ensures that a password was not set before. Otherwise, if 
// you set a password one more time, it will re-generate a key. 
// That means that we lose old data as well.
if !defaults.isKeyCreated {
    defaults.password = NSUUID().uuidString // Or any password you wish
}
```

To use the app and keychain groups:

```swift
let defaults = SecureDefaults(suitName: "app.group") // Set a shared app group
defaults.keychainAccessGroup = "keychain.group" // Set a shrared keychain group 
if !defaults.isKeyCreated {
    defaults.password = NSUUID().uuidString // Or any password you wish
}
```

`SecureDefaults` is not able to catch that any particular data is encrypted, to obtain a raw value, use the following method:

```swift
public func rawObject(forKey defaultName: String) -> Any?
```

## Installation

### [CocoaPods](https://cocoapods.org)

`SecureDefaults` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SecureDefaults', '1.0.5' # Swift 5.0
pod 'SecureDefaults', '1.0.0' # Swift 4.2
```

### [Carthage](https://github.com/Carthage/Carthage)

Add this to `Cartfile`

```ruby
github "vpeschenkov/SecureDefaults" == 1.0.5 # Swift 5.0
github "vpeschenkov/SecureDefaults" == 1.0.0 # Swift 4.2
```

```sh
$ carthage update
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.

```swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(url: "https://github.com/vpeschenkov/SecureDefaults", "1.0.4")
  ],
  targets: [
    .target(name: "YourProject", dependencies: ["SecureDefaults"])
  ]
)
```

```sh
$ swift build
```

## Contributing

- If you **need help** or you'd like to **ask a general question**, open an issue.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Acknowledgments

A big thanks to the following individuals:

- [Rob Napier](https://github.com/rnapier) - for this awesome article ["Properly Encrypting With AES With CommonCrypto"](http://robnapier.net/aes-commoncrypto)
- [Håvard Fossli](https://github.com/hfossli) - for this awesome Gist ["AES 256 in swift 4 with CommonCrypto"](https://gist.github.com/hfossli/7165dc023a10046e2322b0ce74c596f8)

## Author

Victor Peschenkov, v.peschenkov@gmail.com

## License

`SecureDefaults` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

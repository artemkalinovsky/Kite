![swift workflow](https://github.com/artemkalinovsky/Kite/actions/workflows/swift.yml/badge.svg)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)](https://developer.apple.com/macos/)
[![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)](https://developer.apple.com/ios/)
[![tvOS](https://img.shields.io/badge/tvOS-15%2B-blue.svg)](https://developer.apple.com/tvos/)
[![watchOS](https://img.shields.io/badge/watchOS-8%2B-blue.svg)](https://developer.apple.com/watchos/)
[![driverKit](https://img.shields.io/badge/driverKit-19%2B-blue.svg)](https://developer.apple.com/driverkit/)
[![visionOS](https://img.shields.io/badge/visionOS-1%2B-blue.svg)](https://developer.apple.com/visionos/)

<img src="https://github.com/user-attachments/assets/67d7a28c-e45b-4abd-bdf4-86b329c439b5" width="20%" />


# Kite 

Kite is named after the kite bird, known for its lightness, speed, and agile flight. This Swift Package aims to embody those qualities—offering a lightweight, fast, and flexible networking layer that soars across Apple platforms.

### Features:

* ***Swift Concurrency (async/await)***: Easily manage asynchronous networking operations.
* Lightweight API Client: A simple APIClient class lets you execute requests that conform to HTTPRequestProtocol or DeserializeableRequest.
* JSON & XML Deserialization: Built-in JSONDeserializer and XMLDeserializer types for decoding server responses.

## Project Status

This project is considered production-ready. Contributions—whether pull requests, questions, or suggestions—are always welcome! 😃

## Installation 📦 

* #### Swift Package Manager

You can use Xcode SPM GUI: *File -> Swift Packages -> Add Package Dependency -> Pick "Up to Next Major Version 3.0.0"*.

Or add the following to your `Package.swift` file:

``` swift
.package(url: "https://github.com/artemkalinovsky/Kite.git", from: "3.0.0")

```

Then specify "Kite" as a dependency of the target in which you wish to use Kite.

Here's an example `Package.swift`:

``` swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/artemkalinovsky/Kite.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["Kite"])
    ]
)
```
## Usage 🧑‍💻

Let's suppose we want to fetch a list of users from JSON and the response looks like this:

``` json
{ 
   "results":[ 
      { 
         "name":{ 
            "first":"brad",
            "last":"gibson"
         },
         "email":"brad.gibson@example.com"
      }
   ]
}
```

* #### Setup

1. Create `APIClient` :

``` swift
    let apiClient = APIClient()
```

2. Create the Response Model:

``` swift
struct User: Decodable {
    struct Name: Decodable {
        let first: String
        let last: String
    }
    
    let name: Name
    let email: String
}
```

3. Create a Request with Endpoint Path and Desired Response Deserializer:

``` swift
import Foundation
import Kite

struct FetchRandomUsersRequest: DeserializeableRequestProtocol {
    var baseURL: URL { URL(string: "https://randomuser.me")! }
    var path: String {"api"}

    var deserializer: ResponseDataDeserializer<[User]> {
        JSONDeserializer<User>.collectionDeserializer(keyPath: "results")
    }
}
```

* #### Perform the Request

``` swift
Task {
    let (users, urlResponse) = try await apiClient.execute(request: FetchRandomUsersRequest())
}
```

Voilà!🧑‍🎨

## Apps using Kite

- [PinPlace](https://apps.apple.com/ua/app/pinplace/id1571349149)

## Credits 👏

* @0111b for [JSONDecoder-Keypath](https://github.com/0111b/JSONDecoder-Keypath)
* @drmohundro for [SWXMLHash](https://github.com/drmohundro/SWXMLHash)

## License 📄

Kite is released under an MIT license. See [LICENCE](https://github.com/artemkalinovsky/Kite/blob/master/LICENSE) for more information.

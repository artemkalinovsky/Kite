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

- `async`/`await`-first request execution
- Small protocol-based request model
- Built-in JSON and XML response deserializers
- Raw-data and no-op deserializers for simple endpoints
- Query-string, JSON body, auth-header, and multipart upload support
- Explicit error behavior for invalid URLs, auth failures, decode failures, and non-2xx responses

## Requirements

- Swift 6
- macOS 12+
- iOS 15+
- tvOS 15+
- watchOS 8+
- visionOS 1+
- driverKit 19+

## Installation 📦

### Swift Package Manager

In Xcode, choose:

`File` -> `Add Package Dependencies...` -> `Up to Next Major Version` starting at `4.0.0`

Or add Kite to `Package.swift`:

```swift
.package(url: "https://github.com/artemkalinovsky/Kite.git", from: "4.0.0")
```

Example:

```swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/artemkalinovsky/Kite.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["Kite"]
        )
    ]
)
```

## Quick Start 🧑‍💻

Suppose you want to fetch users from this JSON payload:

```json
{
  "results": [
    {
      "name": {
        "first": "brad",
        "last": "gibson"
      },
      "email": "brad.gibson@example.com"
    }
  ]
}
```

Create the client:

```swift
import Kite

let apiClient = APIClient()
```

Define the response model:

```swift
struct User: Decodable {
    struct Name: Decodable {
        let first: String
        let last: String
    }

    let name: Name
    let email: String
}
```

Define the request:

```swift
import Foundation
import Kite

struct FetchRandomUsersRequest: DeserializeableRequestProtocol {
    var baseURL: URL { URL(string: "https://randomuser.me")! }
    var path: String { "api" }

    var deserializer: any ResponseDataDeserializer<[User]> {
        JSONDeserializer<User>.collectionDeserializer(keyPath: "results")
    }
}
```

Execute it:

```swift
let (users, _) = try await apiClient.execute(request: FetchRandomUsersRequest())
```

## Request Defaults

`HTTPRequestProtocol` keeps the required surface deliberately small:

- `baseURL` is the only required property.
- `path` defaults to `""`.
- `method` defaults to `.get`.
- `parameters` defaults to `nil`.
- `headers` defaults to `[:]`.
- `multipartFormData` defaults to `nil`.
- `url` defaults to `baseURL.appendingPathComponent(path)`, but you can override it if needed.

Parameter behavior is built in:

- For `.get` requests, `parameters` are encoded as query items.
- For non-GET requests, `parameters` are encoded as a JSON body and `Content-Type` is set to `application/json`.

## Deserializers

Kite ships with three built-in deserializer styles:

- `VoidDeserializer()` for endpoints where you only care whether the request succeeded
- `RawDataDeserializer()` when you want the raw response bytes
- `JSONDeserializer` for `Decodable` models and `XMLDeserializer` for types that conform to `XMLObjectDeserialization`

Examples:

```swift
let users = JSONDeserializer<User>.collectionDeserializer(keyPath: "results")
let profile = JSONDeserializer<User>.singleObjectDeserializer()
let feed = XMLDeserializer<FeedUser>.collectionDeserializer(keyPath: "response", "users", "user")
```

## Authenticated Requests

Conform to `AuthRequestProtocol` when the endpoint requires an `Authorization` header:

```swift
import Foundation
import Kite

struct FetchProfileRequest: AuthRequestProtocol, DeserializeableRequestProtocol {
    let accessToken: String

    var baseURL: URL { URL(string: "https://api.example.com")! }
    var path: String { "profile" }

    var deserializer: any ResponseDataDeserializer<User> {
        JSONDeserializer<User>.singleObjectDeserializer()
    }
}
```

By default, Kite sends:

```http
Authorization: Bearer <accessToken>
```

If your backend uses a different prefix, override `accessTokenPrefix`.

## Raw Data Requests

Use `RawDataDeserializer` when the endpoint does not return JSON or XML:

```swift
import Foundation
import Kite

struct DownloadAvatarRequest: DeserializeableRequestProtocol {
    var baseURL: URL { URL(string: "https://cdn.example.com")! }
    var path: String { "avatar.png" }

    var deserializer: any ResponseDataDeserializer<Data> {
        RawDataDeserializer()
    }
}
```

## Multipart Uploads

Provide a `[String: URL]` dictionary through `multipartFormData` to upload files:

```swift
import Foundation
import Kite

struct UploadAvatarRequest: AuthRequestProtocol, DeserializeableRequestProtocol {
    let accessToken: String
    let imageURL: URL

    var baseURL: URL { URL(string: "https://api.example.com")! }
    var path: String { "upload" }
    var method: HTTPMethod { .post }
    var multipartFormData: [String: URL]? { ["file": imageURL] }

    var deserializer: any ResponseDataDeserializer<URL> {
        JSONDeserializer<URL>.singleObjectDeserializer(keyPath: "avatar_url")
    }
}
```

Kite builds the multipart body and sets the correct `Content-Type` boundary automatically.

## Error Handling

Kite keeps failure modes explicit:

- `URLError(.badURL)` when the request URL is invalid
- `URLError(.userAuthenticationRequired)` when an authenticated request resolves to an empty `Authorization` header
- `APIClientError.unacceptableStatusCode` for non-2xx HTTP responses
- `JSONDeserializerError` and `XMLDeserializerError` for decode failures

Example:

```swift
do {
    let (users, _) = try await apiClient.execute(request: FetchRandomUsersRequest())
    print(users)
} catch let error as APIClientError {
    print(error.localizedDescription)
} catch {
    print(error.localizedDescription)
}
```

## Project Status

Kite is production-ready. Pull requests, questions, and suggestions are welcome.

## Apps Using Kite

- [PinPlace](https://apps.apple.com/ua/app/pinplace/id1571349149)

## Credits 👏

- @0111b for [JSONDecoder-Keypath](https://github.com/0111b/JSONDecoder-Keypath)
- @drmohundro for [SWXMLHash](https://github.com/drmohundro/SWXMLHash)

## License 📄

Kite is released under the MIT license. See [LICENSE](https://github.com/artemkalinovsky/Kite/blob/master/LICENSE) for details.

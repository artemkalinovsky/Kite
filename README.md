![swift workflow](https://github.com/artemkalinovsky/Kite/actions/workflows/swift.yml/badge.svg) 

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

and then specify `"Kite"` as a dependency of the Target in which you wish to use Legatus.
Here's an example `PackageDescription` :

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

Let's suppose we want to fetch list of users from JSON and response is look like this:

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

2. Create response model:

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

3. Create request with endpoint path and desired reponse deserializer:

``` swift
import Foundation
import Kite

struct FetchRandomUsersRequest: DeserializeableRequest {
    var baseURL: URL { URL(string: "https://randomuser.me")! }
    var path: String {"api"}

    var deserializer: ResponseDeserializer<[User]> {
        JSONDeserializer<User>.collectionDeserializer(keyPath: "results")
    }
}
```

* #### Perfrom created request

``` swift
   let users = try await apiClient.execute(request: FetchRandomUsersRequest())
```

Voilà!🧑‍🎨

## Apps using Kite

- [PinPlace](https://apps.apple.com/ua/app/pinplace/id1571349149)

## Credits 👏

* @0111b for [JSONDecoder-Keypath](https://github.com/0111b/JSONDecoder-Keypath)
* @drmohundro for [SWXMLHash](https://github.com/drmohundro/SWXMLHash)

## License 📄

Kite is released under an MIT license. See [LICENCE](https://github.com/artemkalinovsky/Kite/blob/master/LICENSE) for more information.

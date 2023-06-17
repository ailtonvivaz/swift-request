# SwiftRequest
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Failtonvivaz%2Fswift-request%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ailtonvivaz/swift-request)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Failtonvivaz%2Fswift-request%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ailtonvivaz/swift-request)

SwiftRequest is a lightweight, type-safe HTTP client for Swift, streamlining the construction and execution of HTTP requests.

[Overview](#overview) • [Installation](#installation) • [Supported HTTP Methods](#supported-http-methods) • [Parameters](#parameters) • [License](#license)
## Overview

SwiftRequest abstracts away the repetitive boilerplate code that's typically associated with setting up HTTP requests in Swift. It utilizes macros introduced in Swift 5.9, which can be associated with specific declarations to enhance and extend their functionality.

Here's a quick look at how you'd define a service to fetch quotes:

```swift
@Service(resource: "quotes")
protocol QuoteService {
    @GET("random")
    func getRandomQuotes(@QueryParam limit: Int?) async throws -> [Quote]
    
    @GET("{id}")
    func getQuote(@Path by id: String) async throws -> Quote
}
```

To make a request using SwiftRequest, you just need to create an instance of the service and call the method you want to use:

```swift
let service = QuoteServiceImpl(baseURL: "https://api.quotable.io")
let quotes = try await service.getRandomQuotes(limit: 5)
let quote = try await service.getQuote(by: "69Ldsxcdm-")
```

## Installation

### Xcode

> It requires Xcode 15 or later.

In Xcode, go to `File > Add Package Dependency` and paste the repository URL:
```
https://github.com/ailtonvivaz/swift-request.git
```

### Swift Package Manager

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ailtonvivaz/swift-request.git", from: "0.1.0")
]
```

And then add the dependency to your targets.


## Supported HTTP Methods

SwiftRequest offers support for the following HTTP methods:

- `@GET`
- `@POST`
- `@PUT`
- `@PATCH`
- `@DELETE`
- `@HEAD`
- `@OPTIONS`
  
Each of these methods accepts a string for the request path (optional). You can use just `@GET` or `@GET("path")` if you want to specify the path.
  
## Parameters

SwiftRequest provides several parameters that can be used in conjunction with the HTTP methods:

- `@Header`: Use this property wrapper to define a request header. The header name is optional. If it's not provided, SwiftRequest uses the property name as the header name.
    ```swift
    func getQuote(@Header("Cache-Control") cacheControl: String) async throws -> Quote
    ```
- `@QueryParam`: Use this property wrapper to define a URL query parameter. The query parameter name is optional. If it's not provided, SwiftRequest uses the property name as the query parameter name.
    ```swift
    func getRandomQuotes(@QueryParam limit: Int?) async throws -> [Quote]
    ```
    In this case, the limit parameter will be used as the query parameter name. Example: `https://api.quotable.io/quotes/random?limit=10`
- `@Path`: Use this property wrapper to define a path parameter in the URL. The path parameter name is optional. If it's not provided, SwiftRequest uses the property name as the path parameter name.
    ```swift
    @GET("{id}")
    func getQuote(@Path by id: String) async throws -> Quote
    ```
    In this case, the id parameter will be used as the path parameter name. Example: `https://api.quotable.io/quotes/123`
    > It's important to note that the path parameter name must match the name of the property that's being used to define the path parameter and need to be write in the path between curly braces.
- `@Body`: Use this property wrapper to define the request body. This wrapper can only be used with the `@POST`, `@PUT`, `@PATCH`, and `@DELETE` HTTP methods.
    ```swift
    @POST("quotes")
    func createQuote(@Body quote: Quote) async throws -> Quote
    ```
    Here, the quote parameter will be used as the request body, and the `Content-Type: application/json` header will be automatically added to the request.
- `@FormField`: Use this property wrapper to define a field parameter in the request body. This wrapper can only be used with the `@POST`, `@PUT`, `@PATCH`, and `@DELETE` HTTP methods.
    ```swift
    @POST("quotes")
    func createQuote(@FormField("author") authorName: String, @FormField content: String) async throws -> Quote
    ```
    In this case, the author and content parameters will be used as field parameters in the request body, and the `Content-Type: application/x-www-form-urlencoded` header will be automatically added to the request. Example: `author=John%20Doe&content=Hello%20World`

## License

SwiftRequest is available under the MIT license. See the [LICENSE](LICENSE) for details.

# SwiftRequest

A type-safe HTTP client for Swift.

## Introduction

SwiftRequest creates all the boilerplate code for you HTTP requests. It uses attached macros, a feature introduced in Swift 5.9, which are associated with a specific declaration in the program that they can augment and extend.

```swift
@Service(route: "quotes")
class QuoteService {
    @GET<[Quote]>("random")
    private func getRandomQuotes(@QueryParam limit: Int? = nil) {}
}
```

With this code, you can make a request to the API:

```swift
let baseURL = URL(string: "https://api.quotable.io")!
let service = QuoteService(baseURL: baseURL)
let (quotes, _) = try await service.getRandomQuotes()
```

## Available HTTP Methods

SwiftRequest supports the following HTTP methods:

- `@GET`
- `@POST`
- `@PUT`
- `@PATCH`
- `@DELETE`
- `@HEAD`
- `@OPTIONS`
  
## Parameters

SwiftRequest provides several parameters that can be used in conjunction with the HTTP methods:

- `@Header`: This property wrapper can be used to specify a request header.
- `@QueryParam`: This property wrapper can be used to specify a URL query parameter.
- `@PathParam`: This property wrapper can be used to specify a path parameter in the URL.
- `@Body`: This property wrapper can be used to specify the request body.
- `@FieldParam`: This property wrapper can be used to specify a field parameter in the request body.
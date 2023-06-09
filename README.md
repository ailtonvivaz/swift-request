# SwiftRequest

SwiftRequest is a library designed to simplify the creation of URLSession requests in Swift by utilizing Swift's macro features.

## How it works

SwiftRequest uses attached macros, a feature introduced in Swift 5.9, which are associated with a specific declaration in the program that they can augment and extend. These macros are written using the custom attribute syntax (e.g., `@GET`, `@POST`).

## Available HTTP Methods

SwiftRequest supports the following HTTP methods:

- `@GET`
- `@POST`
- `@PUT`
- `@PATCH`
- `@DELETE`
  
## Parameters

SwiftRequest provides several parameters that can be used in conjunction with the HTTP methods:

`@QueryParam`: This property wrapper can be used to specify a URL query parameter.
`@PathParam`: This property wrapper can be used to specify a path parameter in the URL.
`@Body`: This property wrapper can be used to specify the request body.
`@Header`: This property wrapper can be used to specify a request header.

## Example of Use

Here's an example of how you can use SwiftRequest to interact with a web API:

```swift
import SwiftRequest
import Foundation

struct Quote: Decodable {
    let id: String
    let content: String
    let author: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case author
        case tags
    }
}

@Service
class QuoteService {
    @GET<[Quote]>("quotes/random")
    private func getRandomQuotes(@QueryParam("author") authorSlug: String? = nil) {}
    
    @GET<Quote>("quotes/{id}")
    private func getQuote(@PathParam by id: String) {}
}

let baseURL = URL(string: "https://api.quotable.io")!
let service = QuoteService(baseURL: baseURL)

do {
    let (quotes, _) = try await service.getRandomQuotes(authorSlug: "agatha-christie")
    print(quotes[0])
    
    let (quote, _) = try await service.getQuote(by: quotes[0].id)
    print(quote)
} catch {
    print(error)
}
```

In the above example, a `QuoteService` class is defined with two methods: `getRandomQuotes` and `getQuote`. The `@Service` macro indicates that the `QuoteService` class is a service that will make HTTP requests. The `@GET` property wrapper is used to define the HTTP method and endpoint for each request.

Parameters for the HTTP request can be provided using the @QueryParam, @PathParam, @Body, and @Header. These property wrappers are designed to simplify the process of including parameters in the request, whether they are query parameters, path parameters, a request body, or headers.

To use this service, you would do the following:

```swift
let baseURL = URL(string: "https://api.quotable.io")!
let service = QuoteService(baseURL: baseURL)

do {
    let (quotes, _) = try await service.getRandomQuotes(authorSlug: "agatha-christie")
    print(quotes[0])
    
    let (quote, _) = try await service.getQuote(by: quotes[0].id)
    print(quote)
} catch {
    print(error)
}
```

To execute a request, you create an instance of the service class and call the appropriate method. In the example, an instance of `QuoteService` is created with the base URL of the API, and then the `getRandomQuotes` and `getQuote` methods are called to make the requests.

## License

SwiftRequest is available under the MIT license. See the LICENSE file for more info
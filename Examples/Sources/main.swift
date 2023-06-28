import Foundation
import SwiftRequest

let useAlamofire: Bool = Bool.random()
print("Using Alamofire: \(useAlamofire)")

let executor: any ServiceExecutor = if useAlamofire {
    AlamofireServiceExecutor()
} else {
    URLSessionServiceExecutor()
}

let service = QuoteServiceImpl(baseURL: "https://api.quotable.io", executor: executor)

do {
    let quotes = try await service.getRandomQuotes(limit: 3)
    print(quotes)
    
    let quote = try await service.getQuote(by: "69Ldsxcdm-")
    print(quote)
} catch {
    print(error)
}

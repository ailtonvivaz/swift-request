import Foundation

let baseURL = URL(string: "https://api.quotable.io")!
let service = QuoteService(baseURL: baseURL)

do {
    let (quotes, _) = try await service.getRandomQuotes(limit: 3)
    print(quotes)
    
    let (quote, _) = try await service.getQuote(by: "69Ldsxcdm")
    print(quote)
} catch {
    print(error)
}

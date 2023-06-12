import Foundation

let service = QuoteService(baseURL: "https://api.quotable.io")

do {
    let (quotes, _) = try await service.getRandomQuotes(limit: 3)
    print(quotes)
    
    let (quote, _) = try await service.getQuote(by: "69Ldsxcdm-")
    print(quote)
} catch {
    print(error)
}

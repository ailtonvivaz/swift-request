import Foundation
import SwiftRequest

let service = QuoteServiceImpl(baseURL: "https://api.quotable.io")

do {
    let quotes = try await service.getRandomQuotes(limit: 3)
    print(quotes)
    
    let quote = try await service.getQuote(by: "69Ldsxcdm-")
    print(quote)
} catch {
    print(error)
}

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

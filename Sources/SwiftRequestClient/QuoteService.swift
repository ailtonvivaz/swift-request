import Foundation
import SwiftRequest

@Service(resource: "quotes")
class QuoteService {
    @GET<[Quote]>("random")
    private func getRandomQuotes(@QueryParam limit: Int? = nil) {}
    
    @GET<Quote>("{id}")
    private func getQuote(@PathParam by id: String) {}
}

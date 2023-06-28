import Foundation
import SwiftRequest

@Service(resource: "quotes")
protocol QuoteService {
    @GET("random")
    func getRandomQuotes(@QueryParam limit: Int?) async throws -> [Quote]
    
    @GET("{id}")
    func getQuote(@Path by id: String) async throws -> Quote
}

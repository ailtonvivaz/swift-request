import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftRequestMacros

final class ServiceTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "Service": ServiceMacro.self,
        "GET": MethodMacro.self,
    ]
    
    func testMacro() {
        assertMacroExpansion(
            """
            @Service(resource: "quotes")
            protocol QuoteService {
                @GET("random")
                func getRandomQuotes(@QueryParam limit: Int?) async throws -> [Quote]
                
                @GET("{id}")
                func getQuote(@Path by id: String) async throws -> Quote
            }
            """,
            expandedSource: """
            
            protocol QuoteService {
                func getRandomQuotes(@QueryParam limit: Int?) async throws -> [Quote]
                func getQuote(@Path by id: String) async throws -> Quote
            }
            class QuoteServiceImpl: Service, QuoteService {
                private lazy var resourceURL: URL = baseURL.appendingPathComponent("quotes")

                func getRandomQuotes(limit: Int? = nil) async throws -> [Quote] {
                    let request = Request(url: resourceURL.appendingPathComponent("random"), queryParams: ["limit": limit])
                    return try await session.execute(request)
                }

                func getQuote(by id: String) async throws -> Quote {
                    let request = Request(url: resourceURL.appendingPathComponent("\\(id)"))
                    return try await session.execute(request)
                }
            }
            """,
            macros: testMacros
        )
    }
}

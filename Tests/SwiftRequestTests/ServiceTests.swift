import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftRequestMacros

final class ServiceTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "Service": ServiceMacro.self,
        "GET": MethodMacro.self,
        "POST": MethodMacro.self,
        "BodyField": ParamMacro.self,
        "QueryParam": ParamMacro.self,
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
                    return try await executor(request)
                }

                func getQuote(by id: String) async throws -> Quote {
                    let request = Request(url: resourceURL.appendingPathComponent("\\(id)"))
                    return try await executor(request)
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testBodyFieldMacro() {
        assertMacroExpansion(
            """
            @Service(resource: "quotes")
            protocol QuoteService {
                @POST("random")
                func getRandomQuotes(@BodyField limit: Int?) async throws -> [Quote]
            }
            """,
            expandedSource: """
            
            protocol QuoteService {
                func getRandomQuotes(@BodyField limit: Int?) async throws -> [Quote]
            }
            class QuoteServiceImpl: Service, QuoteService {
                private lazy var resourceURL: URL = baseURL.appendingPathComponent("quotes")

                func getRandomQuotes(limit: Int? = nil) async throws -> [Quote] {
                    let request = Request(url: resourceURL.appendingPathComponent("random"), method: "POST", bodyFields: ["limit": limit])
                    return try await executor(request)
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testNestedTypeMacro() {
        assertMacroExpansion(
            """
            struct Namespace {
                struct Output: Codable {
                    let hello: String
                }
            }
            @Service(resource: "quotes")
            protocol QuoteService {
                @POST("random")
                func getRandomQuotes(@BodyField limit: Int?) async throws -> Namespace.Output
            }
            """,
            expandedSource: """
            struct Namespace {
                struct Output: Codable {
                    let hello: String
                }
            }
            protocol QuoteService {
                func getRandomQuotes(@BodyField limit: Int?) async throws -> Namespace.Output
            }
            class QuoteServiceImpl: Service, QuoteService {
                private lazy var resourceURL: URL = baseURL.appendingPathComponent("quotes")

                func getRandomQuotes(limit: Int? = nil) async throws -> Namespace.Output {
                    let request = Request(url: resourceURL.appendingPathComponent("random"), method: "POST", bodyFields: ["limit": limit])
                    return try await executor(request)
                }
            }
            """,
            macros: testMacros
        )
    }
}

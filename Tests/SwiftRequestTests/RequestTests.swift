import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftRequestMacros

final class RequestTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "GET": GetRequestMacro.self,
        "POST": PostRequestMacro.self,
        "PUT": PutRequestMacro.self,
        "PATCH": PatchRequestMacro.self,
        "DELETE": DeleteRequestMacro.self,
    ]
    
    func testGetMacroWithSimplePathAndData() {
        assertMacroExpansion(
            """
            @GET<Data>("hello")
            private func hello() {}
            """,
            expandedSource: """
            
            private func hello() {
            }
            func hello() async throws -> (Data, HTTPURLResponse) {
                let url = baseURL.appendingPathComponent("hello")
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
                guard (200 ..< 300).contains(response.statusCode) else {
                    throw HTTPResponseError(data: data, response: response)
                }
                return (data, response)
            }
            """,
            macros: testMacros
        )
    }
    
}

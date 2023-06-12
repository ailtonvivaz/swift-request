import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftRequestMacros

final class ServiceTests: XCTestCase {    
    let testMacros: [String: Macro.Type] = [
        "Service": ServiceMacro.self,
    ]
    
    func testMacro() {
        assertMacroExpansion(
            """
            @Service
            class MyService {
            }
            """,
            expandedSource: """
            
            class MyService {
                private let baseURL: URL
                private let session: URLSession
                required init(baseURL: URL, session: URLSession) {
                    self.baseURL = baseURL
                    self.session = session
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacroWithResource() {
        assertMacroExpansion(
            """
            @Service(resource: "quotes")
            class MyService {
            }
            """,
            expandedSource: """
            
            class MyService {
                private let baseURL: URL
                private let session: URLSession
                required init(baseURL: URL, session: URLSession) {
                    self.baseURL = baseURL.appendingPathComponent("quotes")
                    self.session = session
                }
            }
            """,
            macros: testMacros
        )
    }
}

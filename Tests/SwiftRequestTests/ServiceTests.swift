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
                init(baseURL: URL, session: URLSession = .shared) {
                    self.baseURL = baseURL
                    self.session = session
                }
            }
            """,
            macros: testMacros
        )
    }
}

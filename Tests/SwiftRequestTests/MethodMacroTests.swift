import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftRequestMacros

final class MethodMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "GET": MethodMacro.self,
        "POST": MethodMacro.self,
        "PUT": MethodMacro.self,
        "PATCH": MethodMacro.self,
        "DELETE": MethodMacro.self,
        "HEAD": MethodMacro.self,
        "OPTIONS": MethodMacro.self,
    ]
    
//    func testMacro() {
//        assertMacroExpansion(
//            """
//            @GET
//            func hello() async throws -> String
//            """,
//            expandedSource: """
//            
//            func hello() async throws -> String
//            """,
//            macros: testMacros
//        )
//    }
//    
//    func testMacroRequiresFunction() {
//        assertMacroExpansion(
//            """
//            @GET
//            var hello: String
//            """,
//            expandedSource: """
//            
//            var hello: String
//            """,
//            diagnostics: [
//                .init(message: "@GET requires a function", line: 1, column: 1)
//            ],
//            macros: testMacros
//        )
//    }
//    
//    func testMacroRequiresANonStaticFunction() {
//        assertMacroExpansion(
//            """
//            @GET
//            static func hello() async throws -> String
//            """,
//            expandedSource: """
//            
//            static func hello() async throws -> String
//            """,
//            diagnostics: [
//                .init(
//                    message: "@GET requires a non static function",
//                    line: 1,
//                    column: 1,
//                    fixIts: [
//                        .init(message: "remove static keyword")
//                    ]
//                )
//            ],
//            macros: testMacros
//        )
//    }
    
    
}

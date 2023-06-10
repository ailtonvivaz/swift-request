import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ServiceMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let attribute = Attribute(from: node)
        let route = attribute.arguments.first?.value
        
        let baseUrlExpr = if let route {
            "baseURL.appendingPathComponent(\"\(route)\")"
        } else {
            "baseURL"
        }
        
        let declarations: [DeclSyntax] = [
            """
            private let baseURL: URL
            private let session: URLSession
            """,
            """
            required init(baseURL: URL, session: URLSession) {
                self.baseURL = \(raw: baseUrlExpr)
                self.session = session
            }
            """
        ]
        
        return declarations
    }
}

extension ServiceMacro: ConformanceMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)]  {
        [("Service", nil)]
    }
}

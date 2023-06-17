import SwiftSyntax
import SwiftSyntaxMacros
import Foundation
import SwiftDiagnostics

public class ParamMacro: MemberMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

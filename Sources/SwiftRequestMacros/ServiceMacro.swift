import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ServiceMacro: PeerMacro {
    static var diagnostics : ServiceDiagnostics { ServiceDiagnostics() }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            return []
        }
        
        guard let protocolName = getProtocolName(from: declaration, in: context) else {
            return []
        }
        
        let resource = node.argument?.as(TupleExprElementListSyntax.self)?.first?.as(TupleExprElementSyntax.self)?.expression
        
        let declarations = protocolDecl.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .map { expansion(of: $0, with: resource, in: context) }
            .compactMap { $0 }
        
        let implementationSyntax = try ClassDeclSyntax("class \(raw: protocolName)Impl: Service, \(raw: protocolName)") {
            if let resource {
                """
                private lazy var resourceURL: URL = baseURL.appendingPathComponent(\(resource))
                """ as DeclSyntax
            }
            for declaration in declarations {
                declaration
            }
        }
        
        return [
            implementationSyntax.as(DeclSyntax.self)
        ].compactMap { $0 }
    }
    
    private static func expansion(
        of declaration: FunctionDeclSyntax,
        with resource: ExprSyntax?,
        in context: some MacroExpansionContext
    ) -> FunctionDeclSyntax? {
        // TODO: require method
        guard let method = declaration.attributes?.first?.as(AttributeSyntax.self)?.attributeName.description else {
            context.diagnose(diagnostics.methodRequired(node: declaration))
            return nil
        }
        
        let expander = ServiceMethodExpander(
            method: method,
            resource: resource
        )
        return try? expander.expand(declaration: declaration, in: context)
    }
    
    private static func getProtocolName(
        from declaration: some SyntaxProtocol,
        in context: some MacroExpansionContext
    ) -> String? {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            context.diagnose(diagnostics.protocolRequired(node: declaration))
            return nil
        }
        
        return protocolDecl.identifier.text
    }
}

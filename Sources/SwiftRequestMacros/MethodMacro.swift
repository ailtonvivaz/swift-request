import SwiftSyntax
import SwiftSyntaxMacros
import Foundation
import SwiftDiagnostics

public class MethodMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let method = node.attributeName.description
        let diagnostics = MethodDiagnostics(method: method)
        
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.diagnose(diagnostics.justFunction(node: declaration))
            return []
        }
        
        if let staticModifier = funcDecl.modifiers?.first(where: {
            $0.name.tokenKind == TokenKind.keyword(.static)
        })?.as(DeclModifierSyntax.self) {
            context.diagnose(diagnostics.nonStaticFunction(node: funcDecl, staticModifier: staticModifier))
            return []
        }
        
        let effectSpecifiers = funcDecl.signature.effectSpecifiers
        guard effectSpecifiers?.asyncSpecifier != nil, effectSpecifiers?.throwsSpecifier != nil else {
            context.diagnose(diagnostics.asyncAndThrowsRequired(node: funcDecl))
            return []
        }
        
        guard let returnType = funcDecl.signature.output?.returnType else {
            context.diagnose(diagnostics.outputTypeRequired(node: funcDecl))
            return []
        }
        
        guard validate(outputType: returnType, in: context) else {
            context.diagnose(diagnostics.outputTypeMustBeTypeOrTuple(node: funcDecl))
            return []
        }
        
        return []
    }
    
    private static func validate(
        outputType: TypeSyntax,
        in context: some MacroExpansionContext
    ) -> Bool {
        if outputType.is(SimpleTypeIdentifierSyntax.self) {
            return true
        }
        
        if let arrayType = outputType.as(ArrayTypeSyntax.self) {
            return validate(outputType: arrayType.elementType, in: context)
        }
        
        guard let tupleSyntax = outputType.as(TupleTypeSyntax.self),
              let tupleElements = tupleSyntax.elements.as(TupleTypeElementListSyntax.self),
              tupleElements.count == 2,
              let secondElement = tupleElements.last?.as(TupleTypeElementSyntax.self),
              secondElement.type.description == "HTTPURLResponse" else {
            return false
        }
        
        return true
    }
    
}

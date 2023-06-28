import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder

struct CustomFixItMessage: FixItMessage {
    let message: String
    let fixItID: MessageID
    
    static var removeStaticModifier: Self {
        .init(message: "remove static keyword", fixItID: .init(domain: "fix", id: "removeStaticModifier"))
    }
}

struct MethodDiagnostics: Diagnostics {
    static var domain: String { "httpMethod" }
    
    let method: String
    
    func justFunction(node: some DeclSyntaxProtocol) -> Diagnostic {
        diagnostic(for: node, message: "@\(method) requires a function", id: "justFunction")
    }
    
    func nonStaticFunction(node: FunctionDeclSyntax, staticModifier: DeclModifierSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires a non static function",
            id: "nonStaticFunction"
        )
    }
    
    func asyncAndThrowsRequired(node: FunctionDeclSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires async and throws",
            id: "asyncAndThrowsRequired"
        )
    }
    
    func outputTypeRequired(node: FunctionDeclSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires a ouput type",
            id: "returnTypeRequired"
        )
    }
    
    func outputTypeMustBeTypeOrTuple(node: FunctionDeclSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires a ouput type explicit or a tuple (T, HTTPURLResponse)",
            id: "returnTypeMustBeTypeOrTuple"
        )
    }
    
    func pathLiteralRequired(node: ExprSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires a path literal",
            id: "pathLiteralRequired"
        )
    }
    
    func pathInterpolationNotSupported(node: ExprSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) does not support path interpolation",
            id: "pathInterpolationNotSupported"
        )
    }
    
    func missing(parameters: [String], in node: FunctionDeclSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires parameters: \(parameters.joined(separator: ", "))",
            id: "missingParameters"
        )
    }
    
    func extra(parameters: [String], in node: FunctionDeclSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) does not support parameters: \(parameters.joined(separator: ", "))",
            id: "extraParameters"
        )
    }
    
    func tooManyBodyParameters(in node: FunctionDeclSyntax) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(method) requires only one body parameter",
            id: "tooManyBodyParameters"
        )
    }

    func optionalParameterNotSupported(in node: FunctionParameterSyntax, attribute: String) -> Diagnostic {
        diagnostic(
            for: node,
            message: "@\(attribute) does not support optional parameters",
            id: "optionalParameterNotSupported"
        )
    }
}

import SwiftSyntax
import SwiftDiagnostics

struct RequestDiagnostics{
    let method: String
    
    private static let domain = "endpoint"
    
    private func diagnostic(for node: Syntax, text: String, id: String, severity: DiagnosticSeverity = .error) -> Diagnostic {
        Diagnostic(
            node: node,
            message: SimpleDiagnosticMessage(
                message: text,
                diagnosticID: .init(
                    domain: Self.domain,
                    id: id
                ),
                severity: severity
            )
        )
    }
    
    func justFunction(node: Syntax) -> Diagnostic {
        diagnostic(for: node, text: "@\(method) requires a function", id: "justFunction")
    }
    
    func justPrivate(node: Syntax) -> Diagnostic {
        diagnostic(for: node, text: "@\(method) requires a private function", id: "justPrivate")
    }
    
    func pathRequired(node: Syntax) -> Diagnostic {
        diagnostic(for: node, text: "@\(method) requires a path", id: "pathRequired")
    }
    
    func outputTypeRequired(node: Syntax) -> Diagnostic {
        diagnostic(for: node, text: "@\(method) requires a type as a generic argument", id: "outputTypeRequired")
    }
    
    func uniquePathParams(node: Syntax) -> Diagnostic {
        diagnostic(for: node, text: "@\(method) requires unique path params", id: "uniquePathParams")
    }
    
    func bodyAndFields(node: Syntax) -> Diagnostic {
        diagnostic(for: node, text: "@\(method) requires either a body or fields, but not both", id: "bodyAndFields")
    }
}

struct MacroExpansionError: Error {}

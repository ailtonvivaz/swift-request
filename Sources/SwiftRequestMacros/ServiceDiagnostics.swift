import SwiftSyntax
import SwiftDiagnostics

struct ServiceDiagnostics: Diagnostics {
    static var domain: String { "service" }
    
    func protocolRequired(node: some SyntaxProtocol) -> Diagnostic {
        diagnostic(for: node, message: "Service requires a protocol", id: "protocolRequired")
    }
    
    func methodRequired(node: some SyntaxProtocol) -> Diagnostic {
        diagnostic(for: node, message: "Function requires a HTTP method", id: "methodRequired")
    }
}

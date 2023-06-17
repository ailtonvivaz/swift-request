import SwiftSyntax
import SwiftDiagnostics

protocol Diagnostics {
    static var domain: String { get }
}

extension Diagnostics {
    func diagnostic(
        for node: Syntax,
        message: String,
        id: String,
        severity: DiagnosticSeverity = .error,
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        Diagnostic(
            node: node,
            message: CustomMessage(message, id: .init(domain: Self.domain, id: id), severity: severity),
            fixIts: fixIts
        )
    }
    
    func diagnostic(
        for node: SyntaxProtocol,
        message: String,
        id: String,
        severity: DiagnosticSeverity = .error,
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        diagnostic(for: Syntax(node), message: message, id: id, severity: severity, fixIts: fixIts)
    }
}

struct CustomMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
    
    init(_ message: String, id: MessageID, severity: DiagnosticSeverity) {
        self.message = message
        self.diagnosticID = id
        self.severity = severity
    }
}


import SwiftSyntax

class FunctionParameter {
    let syntax: FunctionParameterSyntax
    let value: TokenSyntax
    let optional: Bool
    
    required init(_ syntax: FunctionParameterSyntax) {
        self.syntax = syntax
        self.value = syntax.secondName ?? syntax.firstName
        self.optional = syntax.type.as(OptionalTypeSyntax.self) != nil
    }
    
    static func getArguments(from syntax: FunctionParameterSyntax) -> TupleExprElementListSyntax? {
        return syntax.attributes?.first?.as(AttributeSyntax.self)?.argument?.as(TupleExprElementListSyntax.self)
    }
}

class FunctionNamedParameter: FunctionParameter {
    let name: String
    
    required init(_ syntax: FunctionParameterSyntax) {
        if let name = Self.getArguments(from: syntax)?.first {
            self.name = name.expression.as(StringLiteralExprSyntax.self)?.segments.first?.description ?? ""
        } else {
            self.name = (syntax.secondName ?? syntax.firstName).text
        }
        super.init(syntax)
    }
}

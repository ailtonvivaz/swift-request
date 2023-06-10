import SwiftSyntax

struct AttributeArgument {
    let label: String?
    let value: String
    
    init(label: String?, value: String) {
        self.label = label
        self.value = value
    }
    
    init(from syntax: TupleExprElementSyntax) {
        let label = syntax.label?.text
        let value = syntax.expression.as(StringLiteralExprSyntax.self)?.segments.first?.description
        
        self.init(label: label, value: value!)
    }
}

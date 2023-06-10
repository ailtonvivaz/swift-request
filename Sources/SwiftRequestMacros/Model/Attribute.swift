import SwiftSyntax

struct Attribute {
    let name: String
    let arguments: [AttributeArgument]
    
    init(name: String, arguments: [AttributeArgument]) {
        self.name = name
        self.arguments = arguments
    }
    
    init(from syntax: AttributeSyntax) {
        let name = syntax.attributeName.as(SimpleTypeIdentifierSyntax.self)?.name.text ?? syntax.attributeName.description
        let arguments = syntax.argument?.as(TupleExprElementListSyntax.self)?.map(AttributeArgument.init) ?? []
        
        self.init(name: name, arguments: arguments)
    }
    
    init?(from syntax: AttributeListSyntax.Element) {
        guard let syntax = syntax.as(AttributeSyntax.self) else {
            return nil
        }
        
        self.init(from: syntax)
    }
}

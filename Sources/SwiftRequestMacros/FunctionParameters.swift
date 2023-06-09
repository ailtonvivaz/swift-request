import SwiftSyntax

struct FunctionParameter {
    let attribute: Attribute
    let label: String?
    let name: String
    let type: String
    let optional: Bool
}

struct Attribute {
    let name: String
    let arguments: [AttributeArgument]
}

struct AttributeArgument {
    let label: String?
    let value: String
}

extension FunctionParameter {
    init(from syntax: FunctionParameterSyntax) {
        let attributes = syntax.attributes?.compactMap(Attribute.init) ?? []
        let label: String?
        let name: String
        if let secondName = syntax.secondName {
            label = syntax.firstName.text
            name = secondName.text
        } else {
            label = nil
            name = syntax.firstName.text
        }
        let type = syntax.type.description
        let optional = syntax.type.as(OptionalTypeSyntax.self) != nil
        
        self.init(
            attribute: attributes[0],
            label: label,
            name: name,
            type: type,
            optional: optional
        )
    }
}

extension Attribute {
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

extension AttributeArgument {
    init(from syntax: TupleExprElementSyntax) {
        let label = syntax.label?.text
        let value = syntax.expression.as(StringLiteralExprSyntax.self)?.segments.first?.description
        
        self.init(label: label, value: value!)
    }
}

typealias FunctionParameters = [FunctionParameter]

extension FunctionParameters {
    init(from syntax: FunctionParameterListSyntax) {
        self.init(syntax.map(FunctionParameter.init))
    }
    
    func getHeaders() -> [FunctionParameter] {
        filter { $0.attribute.name == "Header" }
    }
    
    func getQueryParams() -> [FunctionParameter] {
        filter { $0.attribute.name == "QueryParam" }
    }
    
    func getPathParams() -> [FunctionParameter] {
        filter { $0.attribute.name == "PathParam" }
    }
    
    func getBody() -> FunctionParameter? {
        first { $0.attribute.name == "Body" }
    }
}



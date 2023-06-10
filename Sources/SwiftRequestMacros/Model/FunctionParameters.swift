import SwiftSyntax

struct FunctionParameter {
    let attribute: Attribute
    let label: String?
    let name: String
    let type: String
    let optional: Bool
    
    init(attribute: Attribute, label: String?, name: String, type: String, optional: Bool) {
        self.attribute = attribute
        self.label = label
        self.name = name
        self.type = type
        self.optional = optional
    }
    
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
    
    func getFieldParams() -> [FunctionParameter] {
        filter { $0.attribute.name == "FieldParam" }
    }
}



import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

class ServiceMethodExpander {
    let method: String
    let resource: ExprSyntax?
    let diagnostics: MethodDiagnostics
    
    init(method: String, resource: ExprSyntax?) {
        self.method = method
        self.resource = resource
        self.diagnostics = MethodDiagnostics(method: method)
    }
    
    func expand(
        declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) throws -> FunctionDeclSyntax? {
        let methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD"]
        
        var newAttributes: [AttributeListSyntax.Element] = []
        
        var methodAttribute: AttributeSyntax!
        
        if let attributes = declaration.attributes {
            for attributeElement in attributes {
                guard let attribute = attributeElement.as(AttributeSyntax.self),
                      let attributeType = attribute.attributeName.as(SimpleTypeIdentifierSyntax.self)
                else {
                  continue
                }
                
                if methods.contains(where: { $0 == attributeType.description }) {
                    methodAttribute = attribute
                    continue
                }
                
                newAttributes.append(attributeElement)
                print(attribute)
            }
        }
        
        let newListAttributes = AttributeListSyntax(newAttributes)
        
        guard let endpointExpr = expandEndpoint(from: methodAttribute, of: declaration, in: context) else {
            return nil
        }
        
        let request = expandRequest(endpoint: endpointExpr, of: declaration, in: context)
        
        let codeBlock = CodeBlockSyntax {
            VariableDeclSyntax(Keyword.let, name: "request", initializer: .init(value: request))
            ReturnStmtSyntax(expression: "try await executor(request)" as ExprSyntax)
        }
        
        let newDeclaration = declaration
            .with(\.funcKeyword,
                   declaration.funcKeyword
                .with(\.leadingTrivia, .newlines(2))
            )
            .with(\.signature.input.parameterList, convert(declaration.signature.input.parameterList))
            .with(\.attributes, newListAttributes.isEmpty ? nil : newListAttributes)
            .with(\.body, codeBlock)
        
        return newDeclaration
    }
    
    private func convert(_ parameters: FunctionParameterListSyntax) -> FunctionParameterListSyntax {
        FunctionParameterListSyntax(parameters.map { parameter in
            var newParameter = parameter.with(\.attributes, nil)
            
            if parameter.type.is(OptionalTypeSyntax.self) {
                newParameter = newParameter.with(\.defaultArgument, .init(value: "nil" as ExprSyntax))
            }
            
            return newParameter
        })
    }
    
    private func expandRequest(
        endpoint: ExprSyntax,
        of declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> FunctionCallExprSyntax{
        FunctionCallExprSyntax(callee: "Request" as ExprSyntax) {
            TupleExprElementSyntax(label: "url", expression: endpoint)
            
            if method != "GET" {
                TupleExprElementSyntax(label: "method", expression: StringLiteralExprSyntax(content: method))
            }
            
            if let queryParams = expandParameter("QueryParam", of: declaration, in: context) {
                TupleExprElementSyntax(label: "queryParams", expression: queryParams)
            }
            
            if let headers = expandParameter("Header", of: declaration, in: context) {
                TupleExprElementSyntax(label: "headers", expression: headers)
            }
            
            if let formFields = expandParameter("FormField", of: declaration, in: context) {
                TupleExprElementSyntax(label: "formFields", expression: formFields)
            }
            
            if let body = expandBody(of: declaration, in: context) {
                TupleExprElementSyntax(label: "body", expression: IdentifierExprSyntax(identifier: body))
            }
        }
    }
    
    private func expandBody(
        of declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> TokenSyntax? {
        let parameters: [FunctionNamedParameter] = getParameters(from: declaration, with: "Body")
        
        guard parameters.count <= 1 else {
            context.diagnose(diagnostics.tooManyBodyParameters(in: declaration))
            return nil
        }
        
        guard let body = parameters.first else {
            return nil
        }
        
        return body.value
    }
    
    private func expandParameter(
        _ name: String,
        of declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> DictionaryExprSyntax? {
        let parameters: [FunctionNamedParameter] = getParameters(from: declaration, with: name)
        
        if parameters.isEmpty {
            return nil
        }
        
        let dict = DictionaryElementListSyntax {
            for parameter in parameters {
                DictionaryElementSyntax(
                    keyExpression: StringLiteralExprSyntax(content: parameter.name),
                    valueExpression: "\(raw: parameter.value)" as ExprSyntax
                )
            }
        }
        
        return DictionaryExprSyntax(content: .elements(dict))
    }
    
    private func expandEndpoint(
        from attribute: AttributeSyntax,
        of declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax? {
        let arguments = attribute.argument?.as(TupleExprElementListSyntax.self)
        
        let parameters: [FunctionNamedParameter] = getParameters(from: declaration, with: "Path")
        
        for parameter in parameters {
            if parameter.optional {
                context.diagnose(
                    diagnostics.optionalParameterNotSupported(
                        in: parameter.syntax,
                        attribute: "Path"
                    )
                )
            }
        }
        
        guard let path = arguments?.first?.expression else {
            guard parameters.isEmpty else {
                context.diagnose(diagnostics.extra(parameters: parameters.map(\.name), in: declaration))
                return nil
            }            
            
            return resource != nil ? "resourceURL" : "baseURL"
        }
        
        guard let pathLiteral = path.as(StringLiteralExprSyntax.self) else {
            context.diagnose(diagnostics.pathLiteralRequired(node: path))
            return nil
        }
        
        guard pathLiteral.segments.count == 1 else {
            context.diagnose(diagnostics.pathInterpolationNotSupported(node: path))
            return nil
        }
        
        let replacementBlocks = getReplacementBlocks(from: path)
        
        let parameterNames = parameters.map(\.name)
        
        let missingParameters = replacementBlocks.filter { !parameterNames.contains($0) }
        
        guard missingParameters.isEmpty else {
            context.diagnose(diagnostics.missing(parameters: missingParameters, in: declaration))
            return nil
        }
        
        let extraParameters = parameterNames.filter { !replacementBlocks.contains($0) }
        
        guard extraParameters.isEmpty else {
            context.diagnose(diagnostics.extra(parameters: extraParameters, in: declaration))
            return nil
        }
        
        // replace
        let newPath = pathLiteral.with(\.segments, StringLiteralSegmentsSyntax(
            pathLiteral.segments.compactMap { segment in
                guard let stringSegment = segment.as(StringSegmentSyntax.self) else {
                    return nil
                }
                
                let newPath = parameters.reduce(stringSegment.content.text) { content, parameter in
                    content.replacingOccurrences(of: "{\(parameter.name)}", with: "\\(\(parameter.value.text))")
                }
                
                return StringLiteralSegmentsSyntax.Element(StringSegmentSyntax(content: .stringSegment(newPath)))
            }
        ))
        
        let baseURLExpr: ExprSyntax = resource != nil ? "resourceURL" : "baseURL"
        
        return "\(baseURLExpr).appendingPathComponent(\(newPath))"
    }
    
    private func getParameters<T: FunctionParameter>(from declaration: FunctionDeclSyntax, with attributeName: String) -> [T] {
        return declaration.signature.input.parameterList.filter { parameter in
            parameter.attributes?.contains(where: { attribute in
                attribute.as(AttributeSyntax.self)?.attributeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == attributeName
            }) ?? false
        }.map(T.init)
    }
    
    private func getReplacementBlocks(from path: ExprSyntax) -> [String] {
        let pattern = "\\{([^}]*)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let results = regex.matches(in: path.description, range: NSRange(location: 0, length: path.description.count))
        
        let matches = results.map { result -> String in
            let range = Range(result.range(at: 1), in: path.description)!
            return String(path.description[range])
        }
        
        return matches
    }
}
